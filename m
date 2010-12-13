From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] ipv4: Don't pre-seed hoplimit metric.
Date: Mon, 13 Dec 2010 10:04:00 -0800 (PST)
Message-ID: <20101213.100400.39192396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757763Ab0LMSDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 13:03:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CD60524C088
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 10:04:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Always go through a new ip4_dst_hoplimit() helper, just like ipv6.

This allowed several simplifications:

1) The interim dst_metric_hoplimit() can go as it's no longer
   userd.

2) The sysctl_ip_default_ttl entry no longer needs to use
   ipv4_doint_and_flush, since the sysctl is not cached in
   routing cache metrics any longer.

3) ipv4_doint_and_flush no longer needs to be exported and
   therefore can be marked static.

When ipv4_doint_and_flush_strategy was removed some time ago,
the external declaration in ip.h was mistakenly left around
so kill that off too.

We have to move the sysctl_ip_default_ttl declaration into
ipv4's route cache definition header net/route.h, because
currently net/ip.h (where the declaration lives now) has
a back dependency on net/route.h

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/pptp.c              |    2 +-
 include/net/dst.h               |    6 ------
 include/net/ip.h                |   10 ----------
 include/net/route.h             |   11 +++++++++++
 net/ipv4/devinet.c              |    6 +++---
 net/ipv4/ip_gre.c               |    2 +-
 net/ipv4/ip_output.c            |    3 ++-
 net/ipv4/netfilter/ipt_REJECT.c |    2 +-
 net/ipv4/route.c                |    2 --
 net/ipv4/sysctl_net_ipv4.c      |    2 +-
 net/ipv4/xfrm4_mode_tunnel.c    |    2 +-
 11 files changed, 21 insertions(+), 27 deletions(-)

diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index c83e168..164cfad 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -277,7 +277,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	iph->tos      = 0;
 	iph->daddr    = rt->rt_dst;
 	iph->saddr    = rt->rt_src;
-	iph->ttl      = dst_metric_hoplimit(&rt->dst);
+	iph->ttl      = ip4_dst_hoplimit(&rt->dst);
 	iph->tot_len  = htons(skb->len);
 
 	skb_dst_drop(skb);
diff --git a/include/net/dst.h b/include/net/dst.h
index 9208b50..755ac6c 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -116,12 +116,6 @@ dst_metric(const struct dst_entry *dst, const int metric)
 	return dst_metric_raw(dst, metric);
 }
 
-static inline u32
-dst_metric_hoplimit(const struct dst_entry *dst)
-{
-	return dst_metric_raw(dst, RTAX_HOPLIMIT);
-}
-
 static inline void dst_metric_set(struct dst_entry *dst, int metric, u32 val)
 {
 	dst->_metrics[metric-1] = val;
diff --git a/include/net/ip.h b/include/net/ip.h
index 86e2b18..67fac78 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -201,7 +201,6 @@ static inline int inet_is_reserved_local_port(int port)
 	return test_bit(port, sysctl_local_reserved_ports);
 }
 
-extern int sysctl_ip_default_ttl;
 extern int sysctl_ip_nonlocal_bind;
 
 extern struct ctl_path net_core_path[];
@@ -428,15 +427,6 @@ extern void	ip_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
 extern void	ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
 			       u32 info);
 
-/* sysctl helpers - any sysctl which holds a value that ends up being
- * fed into the routing cache should use these handlers.
- */
-int ipv4_doint_and_flush(ctl_table *ctl, int write,
-			 void __user *buffer,
-			 size_t *lenp, loff_t *ppos);
-int ipv4_doint_and_flush_strategy(ctl_table *table,
-				  void __user *oldval, size_t __user *oldlenp,
-				  void __user *newval, size_t newlen);
 #ifdef CONFIG_PROC_FS
 extern int ip_misc_proc_init(void);
 #endif
diff --git a/include/net/route.h b/include/net/route.h
index b8c1f77..2700236 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -231,4 +231,15 @@ static inline int inet_iif(const struct sk_buff *skb)
 	return skb_rtable(skb)->rt_iif;
 }
 
+extern int sysctl_ip_default_ttl;
+
+static inline int ip4_dst_hoplimit(const struct dst_entry *dst)
+{
+	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
+
+	if (hoplimit == 0)
+		hoplimit = sysctl_ip_default_ttl;
+	return hoplimit;
+}
+
 #endif	/* _ROUTE_H */
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 3b06770..748cb5b 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1430,9 +1430,9 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 	return ret;
 }
 
-int ipv4_doint_and_flush(ctl_table *ctl, int write,
-			 void __user *buffer,
-			 size_t *lenp, loff_t *ppos)
+static int ipv4_doint_and_flush(ctl_table *ctl, int write,
+				void __user *buffer,
+				size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
 	int val = *valp;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 46eb3dc..eb68a0e 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -890,7 +890,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			iph->ttl = ((struct ipv6hdr *)old_iph)->hop_limit;
 #endif
 		else
-			iph->ttl = dst_metric_hoplimit(&rt->dst);
+			iph->ttl = ip4_dst_hoplimit(&rt->dst);
 	}
 
 	((__be16 *)(iph + 1))[0] = tunnel->parms.o_flags;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index ea28fa5..04c7b3b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -82,6 +82,7 @@
 #include <linux/tcp.h>
 
 int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
+EXPORT_SYMBOL(sysctl_ip_default_ttl);
 
 /* Generate a checksum for an outgoing IP datagram. */
 __inline__ void ip_send_check(struct iphdr *iph)
@@ -130,7 +131,7 @@ static inline int ip_select_ttl(struct inet_sock *inet, struct dst_entry *dst)
 	int ttl = inet->uc_ttl;
 
 	if (ttl < 0)
-		ttl = dst_metric_hoplimit(dst);
+		ttl = ip4_dst_hoplimit(dst);
 	return ttl;
 }
 
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index f130907..1ff79e5 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -116,7 +116,7 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	if (ip_route_me_harder(nskb, addr_type))
 		goto free_nskb;
 
-	niph->ttl	= dst_metric_hoplimit(skb_dst(nskb));
+	niph->ttl	= ip4_dst_hoplimit(skb_dst(nskb));
 
 	/* "Never happens" */
 	if (nskb->len > dst_mtu(skb_dst(nskb)))
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 90b5a37..770f704 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1821,8 +1821,6 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 	} else
 		dst_metric_set(dst, RTAX_MTU, dst->dev->mtu);
 
-	if (dst_metric_raw(dst, RTAX_HOPLIMIT) == 0)
-		dst_metric_set(dst, RTAX_HOPLIMIT, sysctl_ip_default_ttl);
 	if (dst_mtu(dst) > IP_MAX_MTU)
 		dst_metric_set(dst, RTAX_MTU, IP_MAX_MTU);
 	if (dst_metric(dst, RTAX_ADVMSS) == 0)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1b4ec21..e85ff59 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -155,7 +155,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_ip_default_ttl,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= ipv4_doint_and_flush,
+		.proc_handler	= proc_dointvec,
 		.extra2		= &init_net,
 	},
 	{
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 63b854e..534972e 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -56,7 +56,7 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 		0 : (XFRM_MODE_SKB_CB(skb)->frag_off & htons(IP_DF));
 	ip_select_ident(top_iph, dst->child, NULL);
 
-	top_iph->ttl = dst_metric_hoplimit(dst->child);
+	top_iph->ttl = ip4_dst_hoplimit(dst->child);
 
 	top_iph->saddr = x->props.saddr.a4;
 	top_iph->daddr = x->id.daddr.a4;
-- 
1.7.3.2

