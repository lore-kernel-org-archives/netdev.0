From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 5/6] gtp: add socket to pdp context
Date: Mon, 30 Jan 2017 17:31:59 +0100
Message-ID: <20170130163200.17070-6-aschultz@tpip.net>
References: <20170130163200.17070-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:45592 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751160AbdA3QeX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 11:34:23 -0500
In-Reply-To: <20170130163200.17070-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having the socket present in context simplifies the sending logic.
It also fixes the invalid assumption that we have to use the same
sending socket for all client IP's on a specific gtp interface.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 72 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 39 insertions(+), 33 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 68c6c9b..ff00597 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -58,6 +58,8 @@ struct pdp_ctx {
 	struct in_addr		ms_addr_ip4;
 	struct in_addr		sgsn_addr_ip4;
 
+	struct sock		*sk;
+
 	atomic_t		tx_seq;
 	struct rcu_head		rcu_head;
 };
@@ -371,8 +373,9 @@ static void gtp_dev_uninit(struct net_device *dev)
 	free_percpu(dev->tstats);
 }
 
-static struct rtable *ip4_route_output_gtp(struct net *net, struct flowi4 *fl4,
-					   const struct sock *sk, __be32 daddr)
+static struct rtable *ip4_route_output_gtp(struct flowi4 *fl4,
+					   const struct sock *sk,
+					   __be32 daddr)
 {
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->flowi4_oif		= sk->sk_bound_dev_if;
@@ -381,7 +384,7 @@ static struct rtable *ip4_route_output_gtp(struct net *net, struct flowi4 *fl4,
 	fl4->flowi4_tos		= RT_CONN_FLAGS(sk);
 	fl4->flowi4_proto	= sk->sk_protocol;
 
-	return ip_route_output_key(net, fl4);
+	return ip_route_output_key(sock_net(sk), fl4);
 }
 
 static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
@@ -470,7 +473,6 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt;
 	struct flowi4 fl4;
 	struct iphdr *iph;
-	struct sock *sk;
 	__be16 df;
 	int mtu;
 
@@ -486,30 +488,7 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	}
 	netdev_dbg(dev, "found PDP context %p\n", pctx);
 
-	switch (pctx->gtp_version) {
-	case GTP_V0:
-		if (gtp->sock0)
-			sk = gtp->sock0->sk;
-		else
-			sk = NULL;
-		break;
-	case GTP_V1:
-		if (gtp->sock1u)
-			sk = gtp->sock1u->sk;
-		else
-			sk = NULL;
-		break;
-	default:
-		return -ENOENT;
-	}
-
-	if (!sk) {
-		netdev_dbg(dev, "no userspace socket is available, skip\n");
-		return -ENOENT;
-	}
-
-	rt = ip4_route_output_gtp(sock_net(sk), &fl4, gtp->sock0->sk,
-				  pctx->sgsn_addr_ip4.s_addr);
+	rt = ip4_route_output_gtp(&fl4, pctx->sk, pctx->sgsn_addr_ip4.s_addr);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to SSGN %pI4\n",
 			   &pctx->sgsn_addr_ip4.s_addr);
@@ -554,7 +533,7 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 		goto err_rt;
 	}
 
-	gtp_set_pktinfo_ipv4(pktinfo, sk, iph, pctx, rt, &fl4, dev);
+	gtp_set_pktinfo_ipv4(pktinfo, pctx->sk, iph, pctx, rt, &fl4, dev);
 	gtp_push_header(skb, pktinfo);
 
 	return 0;
@@ -908,7 +887,8 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 	}
 }
 
-static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
+static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
+			struct genl_info *info)
 {
 	u32 hash_ms, hash_tid = 0;
 	struct pdp_ctx *pctx;
@@ -948,6 +928,8 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
 	if (pctx == NULL)
 		return -ENOMEM;
 
+	sock_hold(sk);
+	pctx->sk = sk;
 	ipv4_pdp_fill(pctx, info);
 	atomic_set(&pctx->tx_seq, 0);
 
@@ -984,16 +966,26 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
 	return 0;
 }
 
+static void pdp_context_free(struct rcu_head *head)
+{
+	struct pdp_ctx *pctx = container_of(head, struct pdp_ctx, rcu_head);
+
+	sock_put(pctx->sk);
+	kfree(pctx);
+}
+
 static void pdp_context_delete(struct pdp_ctx *pctx)
 {
 	hlist_del_rcu(&pctx->hlist_tid);
 	hlist_del_rcu(&pctx->hlist_addr);
-	kfree(pctx);
+	call_rcu(&pctx->rcu_head, pdp_context_free);
 }
 
 static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 {
+	unsigned int version;
 	struct gtp_dev *gtp;
+	struct socket *sock;
 	int err;
 
 	if (!info->attrs[GTPA_VERSION] ||
@@ -1002,7 +994,9 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	    !info->attrs[GTPA_MS_ADDRESS])
 		return -EINVAL;
 
-	switch (nla_get_u32(info->attrs[GTPA_VERSION])) {
+	version = nla_get_u32(info->attrs[GTPA_VERSION]);
+
+	switch (version) {
 	case GTP_V0:
 		if (!info->attrs[GTPA_TID] ||
 		    !info->attrs[GTPA_FLOW])
@@ -1026,7 +1020,19 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 		goto out_unlock;
 	}
 
-	err = ipv4_pdp_add(gtp, info);
+	if (version == GTP_V0)
+		sock = gtp->sock0;
+	else if (version == GTP_V1)
+		sock = gtp->sock1u;
+	else
+		sock = NULL;
+
+	if (!sock || !sock->sk) {
+		err = -ENODEV;
+		goto out_unlock;
+	}
+
+	err = ipv4_pdp_add(gtp, sock->sk, info);
 
 out_unlock:
 	rcu_read_unlock();
-- 
2.10.2
