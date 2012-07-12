From: David Miller <davem@davemloft.net>
Subject: [PATCH 05/16] ipv4: Generalize ip_do_redirect() and hook into new
 dst_ops->redirect.
Date: Thu, 12 Jul 2012 01:11:08 -0700 (PDT)
Message-ID: <20120712.011108.1163869605581840179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab2GLILJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:11:09 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5A2FB5824C9
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:11:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All of the redirect acceptance policy is now contained within.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst_ops.h |    1 +
 net/ipv4/route.c      |   94 ++++++++++++++++++++++++++++---------------------
 2 files changed, 55 insertions(+), 40 deletions(-)

diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 4badc86..085931f 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -25,6 +25,7 @@ struct dst_ops {
 	struct dst_entry *	(*negative_advice)(struct dst_entry *);
 	void			(*link_failure)(struct sk_buff *);
 	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
+	void			(*redirect)(struct dst_entry *dst, struct sk_buff *skb);
 	int			(*local_out)(struct sk_buff *skb);
 	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst,
 						struct sk_buff *skb,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f8921b4..f3d2565 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -149,6 +149,7 @@ static void		 ipv4_dst_destroy(struct dst_entry *dst);
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
+static void		 ip_do_redirect(struct dst_entry *dst, struct sk_buff *skb);
 static int rt_garbage_collect(struct dst_ops *ops);
 
 static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
@@ -179,6 +180,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.negative_advice =	ipv4_negative_advice,
 	.link_failure =		ipv4_link_failure,
 	.update_pmtu =		ip_rt_update_pmtu,
+	.redirect =		ip_do_redirect,
 	.local_out =		__ip_local_out,
 	.neigh_lookup =		ipv4_neigh_lookup,
 };
@@ -1271,42 +1273,18 @@ static void rt_del(unsigned int hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
-static void ip_do_redirect(struct rtable *rt, __be32 old_gw, __be32 new_gw)
-{
-	struct neighbour *n;
-
-	if (rt->rt_gateway != old_gw)
-		return;
-
-	n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
-	if (n) {
-		if (!(n->nud_state & NUD_VALID)) {
-			neigh_event_send(n, NULL);
-		} else {
-			rt->rt_gateway = new_gw;
-			rt->rt_flags |= RTCF_REDIRECTED;
-			call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
-		}
-		neigh_release(n);
-	}
-}
-
-/* called in rcu_read_lock() section */
-void ip_rt_redirect(struct sk_buff *skb, __be32 new_gw)
+static void ip_do_redirect(struct dst_entry *dst, struct sk_buff *skb)
 {
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	__be32 new_gw = icmp_hdr(skb)->un.gateway;
 	__be32 old_gw = ip_hdr(skb)->saddr;
+	struct net_device *dev = skb->dev;
 	__be32 daddr = iph->daddr;
 	__be32 saddr = iph->saddr;
-	struct net_device *dev = skb->dev;
-	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	int    ikeys[2] = { dev->ifindex, 0 };
-	__be32 skeys[2] = { saddr, 0 };
+	struct in_device *in_dev;
+	struct neighbour *n;
+	struct rtable *rt;
 	struct net *net;
-	int s, i;
-
-	if (!in_dev)
-		return;
 
 	switch (icmp_hdr(skb)->code & 7) {
 	case ICMP_REDIR_NET:
@@ -1319,6 +1297,14 @@ void ip_rt_redirect(struct sk_buff *skb, __be32 new_gw)
 		return;
 	}
 
+	rt = (struct rtable *) dst;
+	if (rt->rt_gateway != old_gw)
+		return;
+
+	in_dev = __in_dev_get_rcu(dev);
+	if (!in_dev)
+		return;
+
 	net = dev_net(dev);
 	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev) ||
 	    ipv4_is_multicast(new_gw) || ipv4_is_lbcast(new_gw) ||
@@ -1335,6 +1321,43 @@ void ip_rt_redirect(struct sk_buff *skb, __be32 new_gw)
 			goto reject_redirect;
 	}
 
+	n = ipv4_neigh_lookup(dst, NULL, &new_gw);
+	if (n) {
+		if (!(n->nud_state & NUD_VALID)) {
+			neigh_event_send(n, NULL);
+		} else {
+			rt->rt_gateway = new_gw;
+			rt->rt_flags |= RTCF_REDIRECTED;
+			call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
+		}
+		neigh_release(n);
+	}
+	return;
+
+reject_redirect:
+#ifdef CONFIG_IP_ROUTE_VERBOSE
+	if (IN_DEV_LOG_MARTIANS(in_dev))
+		net_info_ratelimited("Redirect from %pI4 on %s about %pI4 ignored\n"
+				     "  Advised path = %pI4 -> %pI4\n",
+				     &old_gw, dev->name, &new_gw,
+				     &saddr, &daddr);
+#endif
+	;
+}
+
+/* called in rcu_read_lock() section */
+void ip_rt_redirect(struct sk_buff *skb, __be32 new_gw)
+{
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	__be32 daddr = iph->daddr;
+	__be32 saddr = iph->saddr;
+	struct net_device *dev = skb->dev;
+	int    ikeys[2] = { dev->ifindex, 0 };
+	__be32 skeys[2] = { saddr, 0 };
+	struct net *net;
+	int s, i;
+
+	net = dev_net(dev);
 	for (s = 0; s < 2; s++) {
 		for (i = 0; i < 2; i++) {
 			unsigned int hash;
@@ -1358,21 +1381,12 @@ void ip_rt_redirect(struct sk_buff *skb, __be32 new_gw)
 				    rt->dst.dev != dev)
 					continue;
 
-				ip_do_redirect(rt, old_gw, new_gw);
+				ip_do_redirect(&rt->dst, skb);
 			}
 		}
 	}
 	return;
 
-reject_redirect:
-#ifdef CONFIG_IP_ROUTE_VERBOSE
-	if (IN_DEV_LOG_MARTIANS(in_dev))
-		net_info_ratelimited("Redirect from %pI4 on %s about %pI4 ignored\n"
-				     "  Advised path = %pI4 -> %pI4\n",
-				     &old_gw, dev->name, &new_gw,
-				     &saddr, &daddr);
-#endif
-	;
 }
 
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
-- 
1.7.10.4
