From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 03/12] gtp: Call common functions to get tunnel routes and add dst_cache
Date: Tue, 26 Sep 2017 21:57:54 -0700
Message-ID: <20170927045803.2477-4-tom@quantonium.net>
References: <20170927045803.2477-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:45100 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967161AbdI0E6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 00:58:46 -0400
Received: by mail-pf0-f179.google.com with SMTP id z84so6672392pfi.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 21:58:46 -0700 (PDT)
In-Reply-To: <20170927045803.2477-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call ip_tunnel_get_route and dst_cache to pdp context which should
improve performance by obviating the need to perform a route lookup
on every packet.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c | 62 +++++++++++++++++++++++++++++++------------------------
 1 file changed, 35 insertions(+), 27 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index f38e32a7ec9c..6dabd605607c 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -63,6 +63,8 @@ struct pdp_ctx {
 
 	atomic_t		tx_seq;
 	struct rcu_head		rcu_head;
+
+	struct dst_cache	dst_cache;
 };
 
 /* One instance of the GTP device. */
@@ -379,20 +381,6 @@ static void gtp_dev_uninit(struct net_device *dev)
 	free_percpu(dev->tstats);
 }
 
-static struct rtable *ip4_route_output_gtp(struct flowi4 *fl4,
-					   const struct sock *sk,
-					   __be32 daddr)
-{
-	memset(fl4, 0, sizeof(*fl4));
-	fl4->flowi4_oif		= sk->sk_bound_dev_if;
-	fl4->daddr		= daddr;
-	fl4->saddr		= inet_sk(sk)->inet_saddr;
-	fl4->flowi4_tos		= RT_CONN_FLAGS(sk);
-	fl4->flowi4_proto	= sk->sk_protocol;
-
-	return ip_route_output_key(sock_net(sk), fl4);
-}
-
 static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 {
 	int payload_len = skb->len;
@@ -479,6 +467,8 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt;
 	struct flowi4 fl4;
 	struct iphdr *iph;
+	struct sock *sk;
+	__be32 saddr;
 	__be16 df;
 	int mtu;
 
@@ -498,19 +488,30 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	}
 	netdev_dbg(dev, "found PDP context %p\n", pctx);
 
-	rt = ip4_route_output_gtp(&fl4, pctx->sk, pctx->peer_addr_ip4.s_addr);
-	if (IS_ERR(rt)) {
-		netdev_dbg(dev, "no route to SSGN %pI4\n",
-			   &pctx->peer_addr_ip4.s_addr);
-		dev->stats.tx_carrier_errors++;
-		goto err;
-	}
+	sk = pctx->sk;
+	saddr = inet_sk(sk)->inet_saddr;
 
-	if (rt->dst.dev == dev) {
-		netdev_dbg(dev, "circular route to SSGN %pI4\n",
-			   &pctx->peer_addr_ip4.s_addr);
-		dev->stats.collisions++;
-		goto err_rt;
+	/* Source address returned by route lookup is ignored since
+	 * we get the address from a socket.
+	 */
+	rt = ip_tunnel_get_route(dev, skb, sk->sk_protocol,
+				 sk->sk_bound_dev_if, RT_CONN_FLAGS(sk),
+				 pctx->peer_addr_ip4.s_addr, &saddr,
+				 pktinfo->gtph_port, pktinfo->gtph_port,
+				 &pctx->dst_cache, NULL);
+
+	if (IS_ERR(rt)) {
+		if (rt == ERR_PTR(-ELOOP)) {
+			netdev_dbg(dev, "circular route to SSGN %pI4\n",
+				   &pctx->peer_addr_ip4.s_addr);
+			dev->stats.collisions++;
+			goto err_rt;
+		} else {
+			netdev_dbg(dev, "no route to SSGN %pI4\n",
+				   &pctx->peer_addr_ip4.s_addr);
+			dev->stats.tx_carrier_errors++;
+			goto err;
+		}
 	}
 
 	skb_dst_drop(skb);
@@ -543,7 +544,7 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 		goto err_rt;
 	}
 
-	gtp_set_pktinfo_ipv4(pktinfo, pctx->sk, iph, pctx, rt, &fl4, dev);
+	gtp_set_pktinfo_ipv4(pktinfo, sk, iph, pctx, rt, &fl4, dev);
 	gtp_push_header(skb, pktinfo);
 
 	return 0;
@@ -917,6 +918,7 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
 	struct pdp_ctx *pctx;
 	bool found = false;
 	__be32 ms_addr;
+	int err;
 
 	ms_addr = nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
 	hash_ms = ipv4_hashfn(ms_addr) % gtp->hash_size;
@@ -951,6 +953,12 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
 	if (pctx == NULL)
 		return -ENOMEM;
 
+	err = dst_cache_init(&pctx->dst_cache, GFP_KERNEL);
+	if (err) {
+		kfree(pctx);
+		return err;
+	}
+
 	sock_hold(sk);
 	pctx->sk = sk;
 	pctx->dev = gtp->dev;
-- 
2.11.0
