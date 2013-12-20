From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to protect forward path to use pmtu info
Date: Fri, 20 Dec 2013 14:08:22 +0100
Message-ID: <20131220130822.GD32129@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42437 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320Ab3LTNIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 08:08:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide a mode where the forwarding path does not use the protocol path
MTU to calculate the maximum size for a forwarded packet but instead
uses the interface or the per-route locked MTU.

It is easy to inject bogus or malicious path mtu information which
will cause either unneeded fragmentation-needed icmp errors (in case
of DF-bit set) or unnecessary fragmentation of packets (by default down
to min_pmtu). This could be used to either create blackholes on routers
(if the generated DF-bit gets dropped later on) or to leverage attacks
on fragmentation.

Forwarded skbs are marked with IPSKB_FORWARDED in ip_forward. This flag
was introduced for multicast forwarding, but as it does not conflict with
our usage in the unicast code path it is perfect for reuse.

I moved the functions ip_sk_accept_pmtu, ip_sk_use_pmtu and ip_skb_dst_mtu
along with the new ip_dst_mtu_secure to net/ip.h to fix circular
dependencies because of IPSKB_FORWARDED.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2:
* forwarding_uses_pmtu default to on
* reworded documentation and changelog

 Documentation/networking/ip-sysctl.txt | 13 +++++++++++++
 include/net/ip.h                       | 32 ++++++++++++++++++++++++++++++++
 include/net/netns/ipv4.h               |  1 +
 include/net/route.h                    | 19 +++----------------
 net/ipv4/ip_forward.c                  |  7 +++++--
 net/ipv4/ip_output.c                   |  9 ++++++---
 net/ipv4/route.c                       |  3 ---
 net/ipv4/sysctl_net_ipv4.c             |  7 +++++++
 8 files changed, 67 insertions(+), 24 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d71afa8..1077c92 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -32,6 +32,19 @@ ip_no_pmtu_disc - INTEGER
 min_pmtu - INTEGER
 	default 552 - minimum discovered Path MTU
 
+forwarding_uses_pmtu - BOOLEAN
+	Don't trust path MTUs while forwarding. Path MTU notifications
+	can easily be forged and lead to unwanted and unnecessary
+	fragmentation or, in case DF-bit being set, dropping of a
+	packet and generation of fragmentation-needed ICMPs . If this
+	mode is enabled, only interface and per-route locked MTUs are
+	considered for fragmentation and fragmentation-needed
+	generation.
+	Default: 1 (enabled)
+	Possible values:
+	0 - disabled
+	1 - enabled
+
 route/max_size - INTEGER
 	Maximum number of routes allowed in the kernel.  Increase
 	this when using large numbers of interfaces and/or routes.
diff --git a/include/net/ip.h b/include/net/ip.h
index 5356644..58fbedc 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -263,6 +263,38 @@ int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
 		 !(dst_metric_locked(dst, RTAX_MTU)));
 }
 
+static inline bool ip_sk_accept_pmtu(const struct sock *sk)
+{
+	return inet_sk(sk)->pmtudisc != IP_PMTUDISC_INTERFACE;
+}
+
+static inline bool ip_sk_use_pmtu(const struct sock *sk)
+{
+	return inet_sk(sk)->pmtudisc < IP_PMTUDISC_PROBE;
+}
+static inline unsigned int ip_dst_mtu_secure(const struct dst_entry *dst,
+					     bool forwarding)
+{
+	struct net *net = dev_net(dst->dev);
+
+	if (net->ipv4.sysctl_ip_fwd_use_pmtu ||
+	    dst_metric_locked(dst, RTAX_MTU) ||
+	    !forwarding)
+		return dst_mtu(dst);
+
+	return min(dst->dev->mtu, IP_MAX_MTU);
+}
+
+static inline unsigned int ip_skb_dst_mtu(const struct sk_buff *skb)
+{
+	if (!skb->sk || ip_sk_use_pmtu(skb->sk)) {
+		bool forwarding = !!(IPCB(skb)->flags & IPSKB_FORWARDED);
+		return ip_dst_mtu_secure(skb_dst(skb), forwarding);
+	} else {
+		return min(skb_dst(skb)->dev->mtu, IP_MAX_MTU);
+	}
+}
+
 void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more);
 
 static inline void ip_select_ident(struct sk_buff *skb, struct dst_entry *dst, struct sock *sk)
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 929a668..80f500a 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -70,6 +70,7 @@ struct netns_ipv4 {
 
 	int sysctl_tcp_ecn;
 	int sysctl_ip_no_pmtu_disc;
+	int sysctl_ip_fwd_use_pmtu;
 
 	kgid_t sysctl_ping_group_range[2];
 
diff --git a/include/net/route.h b/include/net/route.h
index 638e3eb..9d1f423 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -36,6 +36,9 @@
 #include <linux/cache.h>
 #include <linux/security.h>
 
+/* IPv4 datagram length is stored into 16bit field (tot_len) */
+#define IP_MAX_MTU	0xFFFFU
+
 #define RTO_ONLINK	0x01
 
 #define RT_CONN_FLAGS(sk)   (RT_TOS(inet_sk(sk)->tos) | sock_flag(sk, SOCK_LOCALROUTE))
@@ -311,20 +314,4 @@ static inline int ip4_dst_hoplimit(const struct dst_entry *dst)
 	return hoplimit;
 }
 
-static inline bool ip_sk_accept_pmtu(const struct sock *sk)
-{
-	return inet_sk(sk)->pmtudisc != IP_PMTUDISC_INTERFACE;
-}
-
-static inline bool ip_sk_use_pmtu(const struct sock *sk)
-{
-	return inet_sk(sk)->pmtudisc < IP_PMTUDISC_PROBE;
-}
-
-static inline int ip_skb_dst_mtu(const struct sk_buff *skb)
-{
-	return (!skb->sk || ip_sk_use_pmtu(skb->sk)) ?
-	       dst_mtu(skb_dst(skb)) : skb_dst(skb)->dev->mtu;
-}
-
 #endif	/* _ROUTE_H */
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 694de3b..66d027f 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -54,6 +54,7 @@ static int ip_forward_finish(struct sk_buff *skb)
 
 int ip_forward(struct sk_buff *skb)
 {
+	u32 mtu;
 	struct iphdr *iph;	/* Our header */
 	struct rtable *rt;	/* Route we use */
 	struct ip_options *opt	= &(IPCB(skb)->opt);
@@ -88,11 +89,13 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_uses_gateway)
 		goto sr_failed;
 
-	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
+	IPCB(skb)->flags |= IPSKB_FORWARDED;
+	mtu = ip_dst_mtu_secure(&rt->dst, true);
+	if (unlikely(skb->len > mtu && !skb_is_gso(skb) &&
 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(dst_mtu(&rt->dst)));
+			  htonl(mtu));
 		goto drop;
 	}
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 9124027..f2574d4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -449,6 +449,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	__be16 not_last_frag;
 	struct rtable *rt = skb_rtable(skb);
 	int err = 0;
+	bool forwarding = !!(IPCB(skb)->flags & IPSKB_FORWARDED);
 
 	dev = rt->dst.dev;
 
@@ -458,12 +459,13 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 	iph = ip_hdr(skb);
 
+	mtu = ip_dst_mtu_secure(&rt->dst, forwarding);
 	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->local_df) ||
 		     (IPCB(skb)->frag_max_size &&
-		      IPCB(skb)->frag_max_size > dst_mtu(&rt->dst)))) {
+		      IPCB(skb)->frag_max_size > mtu))) {
 		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(ip_skb_dst_mtu(skb)));
+			  htonl(mtu));
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
@@ -473,7 +475,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	 */
 
 	hlen = iph->ihl * 4;
-	mtu = dst_mtu(&rt->dst) - hlen;	/* Size of data space */
+	mtu = mtu - hlen;	/* Size of data space */
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (skb->nf_bridge)
 		mtu -= nf_bridge_mtu_reduction(skb);
@@ -1547,6 +1549,7 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 
 void __init ip_init(void)
 {
+	init_net.ipv4.sysctl_ip_fwd_use_pmtu = 1;
 	ip_rt_init();
 	inet_initpeers();
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f8da282..25071b4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,9 +112,6 @@
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
 
-/* IPv4 datagram length is stored into 16bit field (tot_len) */
-#define IP_MAX_MTU	0xFFFF
-
 #define RT_GC_TIMEOUT (300*HZ)
 
 static int ip_rt_max_size;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d7b63a6..56cc374 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -831,6 +831,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "forwarding_uses_pmtu",
+		.data		= &init_net.ipv4.sysctl_ip_fwd_use_pmtu,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
-- 
1.8.3.1
