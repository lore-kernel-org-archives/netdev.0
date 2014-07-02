From: Tom Herbert <therbert@google.com>
Subject: [PATCH 7/8] ipv6: Implement automatic flow label generation on
 transmit
Date: Tue, 1 Jul 2014 21:33:10 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407012100290.20628@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:61261 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbaGBEdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:33:11 -0400
Received: by mail-yh0-f74.google.com with SMTP id b6so1171355yha.1
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:33:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Automatically generate flow labels for IPv6 packets on transmit.
The flow label is computed based on skb_get_hash. The flow label will
only automatically be set when it is zero otherwise (i.e. flow label
manager hasn't set one). This supports the transmit side functionality
of RFC 6438.

Added an IPv6 sysctl auto_flowlabels to enable/disable this behavior
system wide, and added IPV6_AUTOFLOWLABEL socket option to enable this
functionality per socket.

By default, auto flowlabels are disabled to avoid possible conflicts
with flow label manager, however if this feature proves useful we
may want to enable it by default.

It should also be noted that FreeBSD has already implemented automatic
flow labels (including the sysctl and socket option). In FreeBSD,
automatic flow labels default to enabled.

Performance impact:

Running super_netperf with 200 flows for TCP_RR and UDP_RR for
IPv6. Note that in UDP case, __skb_get_hash will be called for
every packet with explains slight regression. In the TCP case
the hash is saved in the socket so there is no regression.

Automatic flow labels disabled:

  TCP_RR:
    86.53% CPU utilization
    127/195/322 90/95/99% latencies
    1.40498e+06 tps

  UDP_RR:
    90.70% CPU utilization
    118/168/243 90/95/99% latencies
    1.50309e+06 tps

Automatic flow labels enabled:

  TCP_RR:
    85.90% CPU utilization
    128/199/337 90/95/99% latencies
    1.40051e+06

  UDP_RR
    92.61% CPU utilization
    115/164/236 90/95/99% latencies
    1.4687e+06

Signed-off-by: Tom Herbert <therbert@google.com>
---
 Documentation/networking/ip-sysctl.txt |  9 +++++++++
 include/linux/ipv6.h                   |  3 ++-
 include/net/ipv6.h                     | 20 ++++++++++++++++++++
 include/net/netns/ipv6.h               |  1 +
 include/uapi/linux/in6.h               |  1 +
 net/ipv6/af_inet6.c                    |  1 +
 net/ipv6/ip6_gre.c                     |  7 +++++--
 net/ipv6/ip6_output.c                  |  7 +++++--
 net/ipv6/ip6_tunnel.c                  |  3 ++-
 net/ipv6/ipv6_sockglue.c               |  8 ++++++++
 net/ipv6/sysctl_net_ipv6.c             |  8 ++++++++
 11 files changed, 62 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 10e216c..f35bfe4 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1132,6 +1132,15 @@ flowlabel_consistency - BOOLEAN
 	FALSE: disabled
 	Default: TRUE
 
+auto_flowlabels - BOOLEAN
+	Automatically generate flow labels based based on a flow hash
+	of the packet. This allows intermediate devices, such as routers,
+	to idenfify packet flows for mechanisms like Equal Cost Multipath
+	Routing (see RFC 6438).
+	TRUE: enabled
+	FALSE: disabled
+	Default: false
+
 anycast_src_echo_reply - BOOLEAN
 	Controls the use of anycast addresses as source addresses for ICMPv6
 	echo reply
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index b0f2452..9093adf 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -199,7 +199,8 @@ struct ipv6_pinfo {
 						 * 010: prefer public address
 						 * 100: prefer care-of address
 						 */
-				dontfrag:1;
+				dontfrag:1,
+				autoflowlabel:1;
 	__u8			min_hopcount;
 	__u8			tclass;
 	__be32			rcv_flowinfo;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 2aa86e1..4308f2a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -699,6 +699,26 @@ static inline void ip6_set_txhash(struct sock *sk)
 	sk->sk_txhash = flow_hash_from_keys(&keys);
 }
 
+static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
+					__be32 flowlabel, bool autolabel)
+{
+	if (!flowlabel && (autolabel || net->ipv6.sysctl.auto_flowlabels)) {
+		__be32 hash;
+
+		hash = skb_get_hash(skb);
+
+		/* Since this is being sent on the wire obfuscate hash a bit
+		 * to minimize possbility that any useful information to an
+		 * attacker is leaked. Only lower 20 bits are relevant.
+		 */
+		hash ^= hash >> 12;
+
+		flowlabel = hash & IPV6_FLOWLABEL_MASK;
+	}
+
+	return flowlabel;
+}
+
 /*
  *	Header manipulation
  */
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 19d3446..eade27a 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -28,6 +28,7 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_mtu_expires;
 	int ip6_rt_min_advmss;
 	int flowlabel_consistency;
+	int auto_flowlabels;
 	int icmpv6_time;
 	int anycast_src_echo_reply;
 	int fwmark_reflect;
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 0d8e0f0..22b7a69 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -233,6 +233,7 @@ struct in6_flowlabel_req {
 #if 0	/* not yet */
 #define IPV6_USE_MIN_MTU	63
 #endif
+#define IPV6_AUTOFLOWLABEL	64
 
 /*
  * Netfilter (1)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7cb4392..4979bcd 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -765,6 +765,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.bindv6only = 0;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency = 1;
+	net->ipv6.sysctl.auto_flowlabels = 0;
 	atomic_set(&net->ipv6.rt_genid, 0);
 
 	err = ipv6_init_mibs(net);
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 3873181..365b2b6 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -723,7 +723,8 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	 *	Push down and install the IP header.
 	 */
 	ipv6h = ipv6_hdr(skb);
-	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield), fl6->flowlabel);
+	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false));
 	ipv6h->hop_limit = tunnel->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
@@ -1174,7 +1175,9 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 	struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb_push(skb, t->hlen);
 	__be16 *p = (__be16 *)(ipv6h+1);
 
-	ip6_flow_hdr(ipv6h, 0, t->fl.u.ip6.flowlabel);
+	ip6_flow_hdr(ipv6h, 0,
+		     ip6_make_flowlabel(dev_net(dev), skb,
+					t->fl.u.ip6.flowlabel, false));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = NEXTHDR_GRE;
 	ipv6h->saddr = t->parms.laddr;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cb9df0e..fa83bdd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -205,7 +205,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	ip6_flow_hdr(hdr, tclass, fl6->flowlabel);
+	ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel,
+						     np->autoflowlabel));
 
 	hdr->payload_len = htons(seg_len);
 	hdr->nexthdr = proto;
@@ -1569,7 +1570,9 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb_reset_network_header(skb);
 	hdr = ipv6_hdr(skb);
 
-	ip6_flow_hdr(hdr, np->cork.tclass, fl6->flowlabel);
+	ip6_flow_hdr(hdr, np->cork.tclass,
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel,
+					np->autoflowlabel));
 	hdr->hop_limit = np->cork.hop_limit;
 	hdr->nexthdr = proto;
 	hdr->saddr = fl6->saddr;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index afa0824..51a1eb1 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1046,7 +1046,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
-	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield), fl6->flowlabel);
+	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index edb58af..c1d6ca9 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -834,6 +834,10 @@ pref_skip_coa:
 		np->dontfrag = valbool;
 		retv = 0;
 		break;
+	case IPV6_AUTOFLOWLABEL:
+		np->autoflowlabel = valbool;
+		retv = 0;
+		break;
 	}
 
 	release_sock(sk);
@@ -1273,6 +1277,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->dontfrag;
 		break;
 
+	case IPV6_AUTOFLOWLABEL:
+		val = np->autoflowlabel;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 058f3ec..5bf7b61 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -39,6 +39,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "auto_flowlabels",
+		.data		= &init_net.ipv6.sysctl.auto_flowlabels,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "fwmark_reflect",
 		.data		= &init_net.ipv6.sysctl.fwmark_reflect,
 		.maxlen		= sizeof(int),
@@ -74,6 +81,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 	ipv6_table[1].data = &net->ipv6.sysctl.anycast_src_echo_reply;
 	ipv6_table[2].data = &net->ipv6.sysctl.flowlabel_consistency;
+	ipv6_table[3].data = &net->ipv6.sysctl.auto_flowlabels;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
2.0.0.526.g5318336
