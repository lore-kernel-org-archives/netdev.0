From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH v2 18/18] gtp: add dst_cache support
Date: Tue, 24 Jan 2017 16:28:48 +0100
Message-ID: <20170124152848.6120-19-aschultz@tpip.net>
References: <20170124152848.6120-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:56579 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751165AbdAXP27 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 10:28:59 -0500
In-Reply-To: <20170124152848.6120-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 4637ce7..c3e40cc 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -61,6 +61,10 @@ struct pdp_ctx {
 	struct net_device       *dev;
 	struct sock		*sk;
 
+#ifdef CONFIG_DST_CACHE
+	struct dst_cache        dst_cache;
+#endif
+
 	atomic_t		tx_seq;
 	struct rcu_head		rcu_head;
 };
@@ -485,12 +489,18 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	}
 	netdev_dbg(dev, "found PDP context %p\n", pctx);
 
-	rt = ip4_route_output_gtp(&fl4, pctx->sk, pctx->sgsn_addr_ip4.s_addr);
-	if (IS_ERR(rt)) {
-		netdev_dbg(dev, "no route to SSGN %pI4\n",
-			   &pctx->sgsn_addr_ip4.s_addr);
-		dev->stats.tx_carrier_errors++;
-		goto err;
+	rt = dst_cache_get_ip4(&pctx->dst_cache, &pctx->sgsn_addr_ip4.s_addr);
+	if (!rt) {
+		rt = ip4_route_output_gtp(&fl4, pctx->sk, pctx->sgsn_addr_ip4.s_addr);
+		if (IS_ERR(rt)) {
+			netdev_dbg(dev, "no route to SSGN %pI4\n",
+				   &pctx->sgsn_addr_ip4.s_addr);
+			dev->stats.tx_carrier_errors++;
+			goto err;
+		}
+
+		dst_cache_set_ip4(&pctx->dst_cache, &rt->dst,
+				  pctx->sgsn_addr_ip4.s_addr);
 	}
 
 	if (rt->dst.dev == dev) {
@@ -883,6 +893,8 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 	pctx->ms_addr_ip4.s_addr =
 		nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
 
+	dst_cache_reset(&pctx->dst_cache);
+
 	switch (pctx->gtp_version) {
 	case GTP_V0:
 		/* According to TS 09.60, sections 7.5.1 and 7.5.2, the flow
@@ -910,6 +922,7 @@ static int ipv4_pdp_add(struct net_device *dev, struct sock *sk,
 	struct pdp_ctx *pctx;
 	bool found = false;
 	__be32 ms_addr;
+	int err;
 
 	gsk = rcu_dereference_sk_user_data(sk);
 	if (!gsk)
@@ -948,6 +961,12 @@ static int ipv4_pdp_add(struct net_device *dev, struct sock *sk,
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
 	pctx->dev = dev;
@@ -992,6 +1011,7 @@ static void pdp_context_free(struct rcu_head *head)
 	struct pdp_ctx *pctx = container_of(head, struct pdp_ctx, rcu_head);
 
 	sock_put(pctx->sk);
+	dst_cache_destroy(&pctx->dst_cache);
 	kfree(pctx);
 }
 
-- 
2.10.2
