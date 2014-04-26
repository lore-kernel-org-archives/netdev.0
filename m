From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2] ipv6: Set flow label to skb_hash on transmit
Date: Sat, 26 Apr 2014 16:00:30 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:35543 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbaDZXAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 19:00:31 -0400
Received: by mail-oa0-f73.google.com with SMTP id m1so1171613oag.2
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 16:00:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On IPv6 transmit if there is no flow label preset use the skb_hash
or skb->sk->sk_hash as a flow label to support the transmit side of
RFC6438. Added an IPv6 sysctl auto_flow_labels to enable/disable this
behavior.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ipv6.h         | 14 ++++++++++++++
 include/net/netns/ipv6.h   |  1 +
 net/ipv6/af_inet6.c        |  1 +
 net/ipv6/ip6_gre.c         |  7 +++++--
 net/ipv6/ip6_output.c      |  5 +++--
 net/ipv6/ip6_tunnel.c      |  3 ++-
 net/ipv6/sysctl_net_ipv6.c |  8 ++++++++
 7 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d640925..9354ae2 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -664,6 +664,20 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
 
 int ip6_dst_hoplimit(struct dst_entry *dst);
 
+static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
+					__be32 flowlabel)
+{
+	__be32 hash;
+
+	if (flowlabel || !net->ipv6.sysctl.auto_flowlabels)
+		return flowlabel;
+
+	hash = skb->sk && skb->sk->sk_hash ? skb->sk->sk_hash :
+					     skb_get_hash_raw(skb);
+
+	return hash & IPV6_FLOWLABEL_MASK;
+}
+
 /*
  *	Header manipulation
  */
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 21edaf1..de5b01d 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -28,6 +28,7 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_mtu_expires;
 	int ip6_rt_min_advmss;
 	int flowlabel_consistency;
+	int auto_flowlabels;
 	int icmpv6_time;
 	int anycast_src_echo_reply;
 };
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d935889..74d19ab 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -776,6 +776,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.bindv6only = 0;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency = 1;
+	net->ipv6.sysctl.auto_flowlabels = 1;
 	atomic_set(&net->ipv6.rt_genid, 0);
 
 	err = ipv6_init_mibs(net);
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 75277b7..2ae6e21 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -733,7 +733,8 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	 *	Push down and install the IP header.
 	 */
 	ipv6h = ipv6_hdr(skb);
-	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield), fl6->flowlabel);
+	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel));
 	ipv6h->hop_limit = tunnel->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
@@ -1183,8 +1184,10 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb_push(skb, t->hlen);
 	__be16 *p = (__be16 *)(ipv6h+1);
+	struct net *net = dev_net(dev);
 
-	ip6_flow_hdr(ipv6h, 0, t->fl.u.ip6.flowlabel);
+	ip6_flow_hdr(ipv6h, 0,
+		     ip6_make_flowlabel(net, skb, t->fl.u.ip6.flowlabel));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = NEXTHDR_GRE;
 	ipv6h->saddr = t->parms.laddr;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 40e7581..4bde649 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -205,7 +205,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	ip6_flow_hdr(hdr, tclass, fl6->flowlabel);
+	ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel));
 
 	hdr->payload_len = htons(seg_len);
 	hdr->nexthdr = proto;
@@ -1553,7 +1553,8 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb_reset_network_header(skb);
 	hdr = ipv6_hdr(skb);
 
-	ip6_flow_hdr(hdr, np->cork.tclass, fl6->flowlabel);
+	ip6_flow_hdr(hdr, np->cork.tclass,
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel));
 	hdr->hop_limit = np->cork.hop_limit;
 	hdr->nexthdr = proto;
 	hdr->saddr = fl6->saddr;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index b05b609..9595f96 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1045,7 +1045,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
-	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield), fl6->flowlabel);
+	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield,
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel)));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 7f405a1..93bdee8 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -38,6 +38,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "auto_flowlabels",
+		.data		= &init_net.ipv6.sysctl.auto_flowlabels,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -67,6 +74,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 	ipv6_table[1].data = &net->ipv6.sysctl.anycast_src_echo_reply;
 	ipv6_table[2].data = &net->ipv6.sysctl.flowlabel_consistency;
+	ipv6_table[3].data = &net->ipv6.sysctl.auto_flowlabels;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
1.9.1.423.g4596e3a
