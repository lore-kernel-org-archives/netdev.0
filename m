From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 10/17] gtp: add socket to pdp context
Date: Mon, 23 Jan 2017 12:56:59 +0100
Message-ID: <20170123115706.4354-11-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:52054 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750726AbdAWMGx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:53 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having the socket present in context simplifies the sending logic.
It also fixes the invalid assumtion that we have to use the same
sending socket for all client IP's on a specific gtp interface.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 70 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 38 insertions(+), 32 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 762dd6b..6600c92 100644
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
@@ -353,8 +355,9 @@ static void gtp_dev_uninit(struct net_device *dev)
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
@@ -363,7 +366,7 @@ static struct rtable *ip4_route_output_gtp(struct net *net, struct flowi4 *fl4,
 	fl4->flowi4_tos		= RT_CONN_FLAGS(sk);
 	fl4->flowi4_proto	= sk->sk_protocol;
 
-	return ip_route_output_key(net, fl4);
+	return ip_route_output_key(sock_net(sk), fl4);
 }
 
 static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
@@ -452,7 +455,6 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt;
 	struct flowi4 fl4;
 	struct iphdr *iph;
-	struct sock *sk;
 	__be16 df;
 	int mtu;
 
@@ -468,30 +470,7 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
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
@@ -536,7 +515,7 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 		goto err_rt;
 	}
 
-	gtp_set_pktinfo_ipv4(pktinfo, sk, iph, pctx, rt, &fl4, dev);
+	gtp_set_pktinfo_ipv4(pktinfo, pctx->sk, iph, pctx, rt, &fl4, dev);
 	gtp_push_header(skb, pktinfo);
 
 	return 0;
@@ -906,7 +885,8 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 	}
 }
 
-static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
+static int ipv4_pdp_add(struct net_device *dev, struct sock *sk,
+			struct genl_info *info)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
 	u32 hash_ms, hash_tid = 0;
@@ -947,6 +927,8 @@ static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
 	if (pctx == NULL)
 		return -ENOMEM;
 
+	sock_hold(sk);
+	pctx->sk = sk;
 	ipv4_pdp_fill(pctx, info);
 	atomic_set(&pctx->tx_seq, 0);
 
@@ -985,15 +967,33 @@ static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
 
 static void pdp_context_delete(struct pdp_ctx *pctx)
 {
+	sock_put(pctx->sk);
 	hlist_del_rcu(&pctx->hlist_tid);
 	hlist_del_rcu(&pctx->hlist_addr);
 	kfree_rcu(pctx, rcu_head);
 }
 
+static struct socket *gtp_genl_new_pdp_select_socket(int version,
+						     struct net_device *dev)
+{
+	struct gtp_dev *gtp = netdev_priv(dev);
+
+	switch (version) {
+	case GTP_V0:
+		return gtp->sock0;
+	case GTP_V1:
+		return gtp->sock1u;
+	default:
+		return NULL;
+	}
+}
+
 static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 {
+	unsigned int version;
 	struct net_device *dev;
 	struct net *net;
+	struct socket *sock;
 
 	if (!info->attrs[GTPA_VERSION] ||
 	    !info->attrs[GTPA_LINK] ||
@@ -1001,7 +1001,9 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	    !info->attrs[GTPA_MS_ADDRESS])
 		return -EINVAL;
 
-	switch (nla_get_u32(info->attrs[GTPA_VERSION])) {
+	version = nla_get_u32(info->attrs[GTPA_VERSION]);
+
+	switch (version) {
 	case GTP_V0:
 		if (!info->attrs[GTPA_TID] ||
 		    !info->attrs[GTPA_FLOW])
@@ -1029,7 +1031,11 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	}
 	put_net(net);
 
-	return ipv4_pdp_add(dev, info);
+	sock = gtp_genl_new_pdp_select_socket(version, dev);
+	if (!sock)
+		return -ENODEV;
+
+	return ipv4_pdp_add(dev, sock->sk, info);
 }
 
 static struct pdp_ctx *gtp_genl_find_pdp_by_link(struct sk_buff *skb,
-- 
2.10.2
