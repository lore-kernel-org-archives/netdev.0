From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 05/17] gtp: unify genl_find_pdp and prepare for per socket lookup
Date: Mon, 23 Jan 2017 12:56:54 +0100
Message-ID: <20170123115706.4354-6-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:53046 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750903AbdAWMGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:54 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TEID are unique per socket and not per network device. Therefore
the API needs to be changed here.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 99 +++++++++++++++++--------------------------------------
 1 file changed, 31 insertions(+), 68 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index e95c856..7a3c5f6 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1044,56 +1044,61 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	return ipv4_pdp_add(dev, info);
 }
 
-static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
+static struct pdp_ctx *gtp_genl_find_pdp_by_link(struct sk_buff *skb,
+						 struct genl_info *info)
 {
 	struct net_device *dev;
-	struct pdp_ctx *pctx;
 	struct gtp_dev *gtp;
 	struct net *net;
+	__be32 ms_addr;
 
-	if (!info->attrs[GTPA_VERSION] ||
-	    !info->attrs[GTPA_LINK])
-		return -EINVAL;
+	if (!info->attrs[GTPA_MS_ADDRESS])
+		return ERR_PTR(-EINVAL);
+	ms_addr = nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
 
 	net = gtp_genl_get_net(sock_net(skb->sk), info->attrs);
 	if (IS_ERR(net))
-		return PTR_ERR(net);
+		return ERR_PTR(PTR_ERR(net));
 
 	/* Check if there's an existing gtpX device to configure */
 	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
 	if (dev == NULL) {
 		put_net(net);
-		return -ENODEV;
+		return ERR_PTR(-ENODEV);
 	}
 	put_net(net);
 
 	gtp = netdev_priv(dev);
 
-	switch (nla_get_u32(info->attrs[GTPA_VERSION])) {
-	case GTP_V0:
-		if (!info->attrs[GTPA_TID])
-			return -EINVAL;
-		pctx = gtp0_pdp_find(gtp, nla_get_u64(info->attrs[GTPA_TID]));
-		break;
-	case GTP_V1:
-		if (!info->attrs[GTPA_I_TEI])
-			return -EINVAL;
-		pctx = gtp1_pdp_find(gtp, nla_get_u64(info->attrs[GTPA_I_TEI]));
-		break;
+	return ipv4_pdp_find(gtp, ms_addr);
+}
 
-	default:
+static struct pdp_ctx *gtp_genl_find_pdp(struct sk_buff *skb,
+					 struct genl_info *info)
+{
+	if (info->attrs[GTPA_LINK])
+		return gtp_genl_find_pdp_by_link(skb, info);
+	else
+		return ERR_PTR(-EINVAL);
+}
+
+static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
+{
+	struct pdp_ctx *pctx;
+
+	if (!info->attrs[GTPA_VERSION])
 		return -EINVAL;
-	}
 
+	pctx = gtp_genl_find_pdp(skb, info);
 	if (IS_ERR(pctx))
 		return PTR_ERR(pctx);
 
 	if (pctx->gtp_version == GTP_V0)
-		netdev_dbg(dev, "GTPv0-U: deleting tunnel id = %llx (pdp %p)\n",
-			   pctx->u.v0.tid, pctx);
+		pr_debug("GTPv0-U: deleting tunnel id = %llx (pdp %p)\n",
+			 pctx->u.v0.tid, pctx);
 	else if (pctx->gtp_version == GTP_V1)
-		netdev_dbg(dev, "GTPv1-U: deleting tunnel id = %x/%x (pdp %p)\n",
-			   pctx->u.v1.i_tei, pctx->u.v1.o_tei, pctx);
+		pr_debug("GTPv1-U: deleting tunnel id = %x/%x (pdp %p)\n",
+			 pctx->u.v1.i_tei, pctx->u.v1.o_tei, pctx);
 
 	hlist_del_rcu(&pctx->hlist_tid);
 	hlist_del_rcu(&pctx->hlist_addr);
@@ -1143,57 +1148,15 @@ static int gtp_genl_fill_info(struct sk_buff *skb, u32 snd_portid, u32 snd_seq,
 static int gtp_genl_get_pdp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct pdp_ctx *pctx = NULL;
-	struct net_device *dev;
 	struct sk_buff *skb2;
-	struct gtp_dev *gtp;
-	u32 gtp_version;
-	struct net *net;
 	int err;
 
-	if (!info->attrs[GTPA_VERSION] ||
-	    !info->attrs[GTPA_LINK])
-		return -EINVAL;
-
-	gtp_version = nla_get_u32(info->attrs[GTPA_VERSION]);
-	switch (gtp_version) {
-	case GTP_V0:
-	case GTP_V1:
-		break;
-	default:
+	if (!info->attrs[GTPA_VERSION])
 		return -EINVAL;
-	}
-
-	net = gtp_genl_get_net(sock_net(skb->sk), info->attrs);
-	if (IS_ERR(net))
-		return PTR_ERR(net);
-
-	/* Check if there's an existing gtpX device to configure */
-	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL) {
-		put_net(net);
-		return -ENODEV;
-	}
-	put_net(net);
-
-	gtp = netdev_priv(dev);
 
 	rcu_read_lock();
-	if (gtp_version == GTP_V0 &&
-	    info->attrs[GTPA_TID]) {
-		u64 tid = nla_get_u64(info->attrs[GTPA_TID]);
-
-		pctx = gtp0_pdp_find(gtp, tid);
-	} else if (gtp_version == GTP_V1 &&
-		 info->attrs[GTPA_I_TEI]) {
-		u32 tid = nla_get_u32(info->attrs[GTPA_I_TEI]);
-
-		pctx = gtp1_pdp_find(gtp, tid);
-	} else if (info->attrs[GTPA_MS_ADDRESS]) {
-		__be32 ip = nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
-
-		pctx = ipv4_pdp_find(gtp, ip);
-	}
 
+	pctx = gtp_genl_find_pdp(skb, info);
 	if (IS_ERR(pctx)) {
 		err = PTR_ERR(pctx);
 		goto err_unlock;
-- 
2.10.2
