From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/5] net: Pass optional SKB and SK arguments to
 dst_ops->{update_pmtu,redirect}()
Date: Tue, 17 Jul 2012 06:14:31 -0700 (PDT)
Message-ID: <20120717.061431.1030128912733570035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab2GQNOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:14:32 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id E125D5837B7
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 06:14:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This will be used so that we can compose a full flow key.

Even though we have a route in this context, we need more.  In the
future the routes will be without destination address, source address,
etc. keying.  One ipv4 route will cover entire subnets, etc.

In this environment we have to have a way to possess persistent storage
for redirects and PMTU information.  This persistent storage will exist
in the FIB tables, and that's why we'll need to be able to rebuild a
full lookup flow key here.  Using that flow key will do a fib_lookup()
and create/update the persistent entry.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_cm.c |    2 +-
 include/net/dst_ops.h                   |    6 ++++--
 net/bridge/br_netfilter.c               |    6 ++++--
 net/dccp/ipv4.c                         |    2 +-
 net/dccp/ipv6.c                         |    2 +-
 net/decnet/dn_route.c                   |   12 ++++++++----
 net/ipv4/inet_connection_sock.c         |    2 +-
 net/ipv4/ip_gre.c                       |    2 +-
 net/ipv4/ipip.c                         |    2 +-
 net/ipv4/route.c                        |   21 +++++++++++++--------
 net/ipv4/tcp_ipv4.c                     |    2 +-
 net/ipv4/xfrm4_policy.c                 |   10 ++++++----
 net/ipv6/inet6_connection_sock.c        |    2 +-
 net/ipv6/ip6_tunnel.c                   |    6 +++---
 net/ipv6/route.c                        |   21 +++++++++++++--------
 net/ipv6/sit.c                          |    2 +-
 net/ipv6/tcp_ipv6.c                     |    2 +-
 net/ipv6/xfrm6_policy.c                 |   10 ++++++----
 net/netfilter/ipvs/ip_vs_xmit.c         |    4 ++--
 net/sctp/input.c                        |    2 +-
 net/sctp/transport.c                    |    2 +-
 21 files changed, 71 insertions(+), 49 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 014504d..1ca7322 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -1397,7 +1397,7 @@ void ipoib_cm_skb_too_long(struct net_device *dev, struct sk_buff *skb,
 	int e = skb_queue_empty(&priv->cm.skb_queue);
 
 	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
 	skb_queue_tail(&priv->cm.skb_queue, skb);
 	if (e)
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 085931f..d079fc6 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -24,8 +24,10 @@ struct dst_ops {
 					  struct net_device *dev, int how);
 	struct dst_entry *	(*negative_advice)(struct dst_entry *);
 	void			(*link_failure)(struct sk_buff *);
-	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
-	void			(*redirect)(struct dst_entry *dst, struct sk_buff *skb);
+	void			(*update_pmtu)(struct dst_entry *dst, struct sock *sk,
+					       struct sk_buff *skb, u32 mtu);
+	void			(*redirect)(struct dst_entry *dst, struct sock *sk,
+					    struct sk_buff *skb);
 	int			(*local_out)(struct sk_buff *skb);
 	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst,
 						struct sk_buff *skb,
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 81f76c4..68e8f36 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -111,11 +111,13 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
 	 pppoe_proto(skb) == htons(PPP_IPV6) && \
 	 brnf_filter_pppoe_tagged)
 
-static void fake_update_pmtu(struct dst_entry *dst, u32 mtu)
+static void fake_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			     struct sk_buff *skb, u32 mtu)
 {
 }
 
-static void fake_redirect(struct dst_entry *dst, struct sk_buff *skb)
+static void fake_redirect(struct dst_entry *dst, struct sock *sk,
+			  struct sk_buff *skb)
 {
 }
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 683902f..ab4f44c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -193,7 +193,7 @@ static void dccp_do_redirect(struct sk_buff *skb, struct sock *sk)
 	struct dst_entry *dst = __sk_dst_check(sk, 0);
 
 	if (dst)
-		dst->ops->redirect(dst, skb);
+		dst->ops->redirect(dst, sk, skb);
 }
 
 /*
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 3ee0342..56840b2 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -134,7 +134,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
 
 		if (dst)
-			dst->ops->redirect(dst, skb);
+			dst->ops->redirect(dst, sk, skb);
 	}
 
 	if (type == ICMPV6_PKT_TOOBIG) {
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index e9c4e2e..47de90d 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -117,8 +117,10 @@ static void dn_dst_destroy(struct dst_entry *);
 static void dn_dst_ifdown(struct dst_entry *, struct net_device *dev, int how);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
-static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu);
-static void dn_dst_redirect(struct dst_entry *dst, struct sk_buff *skb);
+static void dn_dst_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			       struct sk_buff *skb , u32 mtu);
+static void dn_dst_redirect(struct dst_entry *dst, struct sock *sk,
+			    struct sk_buff *skb);
 static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst,
 					     struct sk_buff *skb,
 					     const void *daddr);
@@ -266,7 +268,8 @@ static int dn_dst_gc(struct dst_ops *ops)
  * We update both the mtu and the advertised mss (i.e. the segment size we
  * advertise to the other end).
  */
-static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
+static void dn_dst_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			       struct sk_buff *skb, u32 mtu)
 {
 	struct dn_route *rt = (struct dn_route *) dst;
 	struct neighbour *n = rt->n;
@@ -294,7 +297,8 @@ static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
 	}
 }
 
-static void dn_dst_redirect(struct dst_entry *dst, struct sk_buff *skb)
+static void dn_dst_redirect(struct dst_entry *dst, struct sock *sk,
+			    struct sk_buff *skb)
 {
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 200d218..3ea4652 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -840,7 +840,7 @@ struct dst_entry *inet_csk_update_pmtu(struct sock *sk, u32 mtu)
 		if (!dst)
 			goto out;
 	}
-	dst->ops->update_pmtu(dst, mtu);
+	dst->ops->update_pmtu(dst, sk, NULL, mtu);
 
 	dst = __sk_dst_check(sk, 0);
 	if (!dst)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0c31235..42c44b1 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -833,7 +833,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
 
 	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		df |= (old_iph->frag_off&htons(IP_DF));
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index c2d0e6d..2c2c35b 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -519,7 +519,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		if (skb_dst(skb))
-			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
 		if ((old_iph->frag_off & htons(IP_DF)) &&
 		    mtu < ntohs(old_iph->tot_len)) {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index aad2181..b35d3bf 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -148,8 +148,10 @@ static unsigned int	 ipv4_mtu(const struct dst_entry *dst);
 static void		 ipv4_dst_destroy(struct dst_entry *dst);
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
-static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
-static void		 ip_do_redirect(struct dst_entry *dst, struct sk_buff *skb);
+static void		 ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+					   struct sk_buff *skb, u32 mtu);
+static void		 ip_do_redirect(struct dst_entry *dst, struct sock *sk,
+					struct sk_buff *skb);
 static int rt_garbage_collect(struct dst_ops *ops);
 
 static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
@@ -1273,7 +1275,7 @@ static void rt_del(unsigned int hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
-static void ip_do_redirect(struct dst_entry *dst, struct sk_buff *skb)
+static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buff *skb)
 {
 	__be32 new_gw = icmp_hdr(skb)->un.gateway;
 	__be32 old_gw = ip_hdr(skb)->saddr;
@@ -1506,7 +1508,8 @@ out:	kfree_skb(skb);
 	return 0;
 }
 
-static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
+static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			      struct sk_buff *skb, u32 mtu)
 {
 	struct rtable *rt = (struct rtable *) dst;
 
@@ -1531,7 +1534,7 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 			   iph->daddr, iph->saddr, 0, 0);
 	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
-		ip_rt_update_pmtu(&rt->dst, mtu);
+		ip_rt_update_pmtu(&rt->dst, NULL, skb, mtu);
 		ip_rt_put(rt);
 	}
 }
@@ -1559,7 +1562,7 @@ void ipv4_redirect(struct sk_buff *skb, struct net *net,
 			   protocol, flow_flags, iph->daddr, iph->saddr, 0, 0);
 	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
-		ip_do_redirect(&rt->dst, skb);
+		ip_do_redirect(&rt->dst, NULL, skb);
 		ip_rt_put(rt);
 	}
 }
@@ -2587,11 +2590,13 @@ static unsigned int ipv4_blackhole_mtu(const struct dst_entry *dst)
 	return mtu ? : dst->dev->mtu;
 }
 
-static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
+static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, struct sock *sk,
+					  struct sk_buff *skb, u32 mtu)
 {
 }
 
-static void ipv4_rt_blackhole_redirect(struct dst_entry *dst, struct sk_buff *skb)
+static void ipv4_rt_blackhole_redirect(struct dst_entry *dst, struct sock *sk,
+				       struct sk_buff *skb)
 {
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b8e7e05..d9caf5c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -319,7 +319,7 @@ static void do_redirect(struct sk_buff *skb, struct sock *sk)
 	struct dst_entry *dst = __sk_dst_check(sk, 0);
 
 	if (dst)
-		dst->ops->redirect(dst, skb);
+		dst->ops->redirect(dst, sk, skb);
 }
 
 /*
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 737131c..fcf7678 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -194,20 +194,22 @@ static inline int xfrm4_garbage_collect(struct dst_ops *ops)
 	return (dst_entries_get_slow(ops) > ops->gc_thresh * 2);
 }
 
-static void xfrm4_update_pmtu(struct dst_entry *dst, u32 mtu)
+static void xfrm4_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			      struct sk_buff *skb, u32 mtu)
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 	struct dst_entry *path = xdst->route;
 
-	path->ops->update_pmtu(path, mtu);
+	path->ops->update_pmtu(path, sk, skb, mtu);
 }
 
-static void xfrm4_redirect(struct dst_entry *dst, struct sk_buff *skb)
+static void xfrm4_redirect(struct dst_entry *dst, struct sock *sk,
+			   struct sk_buff *skb)
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 	struct dst_entry *path = xdst->route;
 
-	path->ops->redirect(path, skb);
+	path->ops->redirect(path, sk, skb);
 }
 
 static void xfrm4_dst_destroy(struct dst_entry *dst)
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 62539a4..4a0c4d2 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -269,7 +269,7 @@ struct dst_entry *inet6_csk_update_pmtu(struct sock *sk, u32 mtu)
 
 	if (IS_ERR(dst))
 		return NULL;
-	dst->ops->update_pmtu(dst, mtu);
+	dst->ops->update_pmtu(dst, sk, NULL, mtu);
 
 	return inet6_csk_route_socket(sk);
 }
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 61d1065..db32846 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -609,10 +609,10 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		if (rel_info > dst_mtu(skb_dst(skb2)))
 			goto out;
 
-		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), rel_info);
+		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), NULL, skb2, rel_info);
 	}
 	if (rel_type == ICMP_REDIRECT)
-		skb_dst(skb2)->ops->redirect(skb_dst(skb2), skb2);
+		skb_dst(skb2)->ops->redirect(skb_dst(skb2), NULL, skb2);
 
 	icmp_send(skb2, rel_type, rel_code, htonl(rel_info));
 
@@ -952,7 +952,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 	if (skb->len > mtu) {
 		*pmtu = mtu;
 		err = -EMSGSIZE;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2a4c8d4..31af1ed 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -78,8 +78,10 @@ static int		 ip6_dst_gc(struct dst_ops *ops);
 static int		ip6_pkt_discard(struct sk_buff *skb);
 static int		ip6_pkt_discard_out(struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
-static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
-static void		rt6_do_redirect(struct dst_entry *dst, struct sk_buff *skb);
+static void		ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+					   struct sk_buff *skb, u32 mtu);
+static void		rt6_do_redirect(struct dst_entry *dst, struct sock *sk,
+					struct sk_buff *skb);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_add_route_info(struct net *net,
@@ -187,11 +189,13 @@ static unsigned int ip6_blackhole_mtu(const struct dst_entry *dst)
 	return mtu ? : dst->dev->mtu;
 }
 
-static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
+static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, struct sock *sk,
+					 struct sk_buff *skb, u32 mtu)
 {
 }
 
-static void ip6_rt_blackhole_redirect(struct dst_entry *dst, struct sk_buff *skb)
+static void ip6_rt_blackhole_redirect(struct dst_entry *dst, struct sock *sk,
+				      struct sk_buff *skb)
 {
 }
 
@@ -1071,7 +1075,8 @@ static void ip6_link_failure(struct sk_buff *skb)
 	}
 }
 
-static void ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
+static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			       struct sk_buff *skb, u32 mtu)
 {
 	struct rt6_info *rt6 = (struct rt6_info*)dst;
 
@@ -1108,7 +1113,7 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
-		ip6_rt_update_pmtu(dst, ntohl(mtu));
+		ip6_rt_update_pmtu(dst, NULL, skb, ntohl(mtu));
 	dst_release(dst);
 }
 EXPORT_SYMBOL_GPL(ip6_update_pmtu);
@@ -1136,7 +1141,7 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
-		rt6_do_redirect(dst, skb);
+		rt6_do_redirect(dst, NULL, skb);
 	dst_release(dst);
 }
 EXPORT_SYMBOL_GPL(ip6_redirect);
@@ -1639,7 +1644,7 @@ static int ip6_route_del(struct fib6_config *cfg)
 	return err;
 }
 
-static void rt6_do_redirect(struct dst_entry *dst, struct sk_buff *skb)
+static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
 	struct netevent_redirect netevent;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index fbf1622..3bd1bfc 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -807,7 +807,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		}
 
 		if (tunnel->parms.iph.daddr && skb_dst(skb))
-			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
 		if (skb->len > mtu) {
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ecdf241..c9dabdd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -367,7 +367,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
 
 		if (dst)
-			dst->ops->redirect(dst,skb);
+			dst->ops->redirect(dst, sk, skb);
 	}
 
 	if (type == ICMPV6_PKT_TOOBIG) {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f5a9cb8..ef39812 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -207,20 +207,22 @@ static inline int xfrm6_garbage_collect(struct dst_ops *ops)
 	return dst_entries_get_fast(ops) > ops->gc_thresh * 2;
 }
 
-static void xfrm6_update_pmtu(struct dst_entry *dst, u32 mtu)
+static void xfrm6_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			      struct sk_buff *skb, u32 mtu)
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 	struct dst_entry *path = xdst->route;
 
-	path->ops->update_pmtu(path, mtu);
+	path->ops->update_pmtu(path, sk, skb, mtu);
 }
 
-static void xfrm6_redirect(struct dst_entry *dst, struct sk_buff *skb)
+static void xfrm6_redirect(struct dst_entry *dst, struct sock *sk,
+			   struct sk_buff *skb)
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 	struct dst_entry *path = xdst->route;
 
-	path->ops->redirect(path, skb);
+	path->ops->redirect(path, sk, skb);
 }
 
 static void xfrm6_dst_destroy(struct dst_entry *dst)
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 71d6ecb..65b616a 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -797,7 +797,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 	}
 	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
 	df |= (old_iph->frag_off & htons(IP_DF));
 
@@ -913,7 +913,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error_put;
 	}
 	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
 	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
 	    !skb_is_gso(skb)) {
diff --git a/net/sctp/input.c b/net/sctp/input.c
index a67bc31..c201b26 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -432,7 +432,7 @@ void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
 		return;
 	dst = sctp_transport_dst_check(t);
 	if (dst)
-		dst->ops->redirect(dst, skb);
+		dst->ops->redirect(dst, sk, skb);
 }
 
 /*
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index e69e1a2..a6b7ee9 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -249,7 +249,7 @@ void sctp_transport_update_pmtu(struct sock *sk, struct sctp_transport *t, u32 p
 		t->af_specific->get_dst(t, &t->saddr, &t->fl, sk);
 
 	if (dst) {
-		dst->ops->update_pmtu(dst, pmtu);
+		dst->ops->update_pmtu(dst, sk, NULL, pmtu);
 
 		dst = sctp_transport_dst_check(t);
 		if (!dst)
-- 
1.7.10.4
