From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v2 3/6] gtp: unify genl_find_pdp and prepare for per socket lookup
Date: Mon, 30 Jan 2017 17:37:10 +0100
Message-ID: <20170130163713.17524-4-aschultz@tpip.net>
References: <20170130163713.17524-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:36347 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932400AbdA3QhU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 11:37:20 -0500
In-Reply-To: <20170130163713.17524-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This unifies duplicate code into a helper. It also prepares the
groundwork to add a lookup version that uses the socket to find
attache pdp contexts.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 120 +++++++++++++++++++++++-------------------------------
 1 file changed, 51 insertions(+), 69 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index c96c71f..6b7a3c2 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1027,47 +1027,62 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+static struct pdp_ctx *gtp_genl_find_pdp_by_link(struct sk_buff *skb,
+						 struct genl_info *info)
+{
+	struct gtp_dev *gtp;
+
+	gtp = gtp_genl_find_dev(sock_net(skb->sk), info->attrs);
+	if (!gtp)
+		return ERR_PTR(-ENODEV);
+
+	if (info->attrs[GTPA_MS_ADDRESS]) {
+		__be32 ip = nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
+
+		return ipv4_pdp_find(gtp, ip);
+	} else if (info->attrs[GTPA_VERSION]) {
+		u32 gtp_version = nla_get_u32(info->attrs[GTPA_VERSION]);
+
+		if (gtp_version == GTP_V0 && info->attrs[GTPA_TID])
+			return gtp0_pdp_find(gtp, nla_get_u64(
+						     info->attrs[GTPA_TID]));
+		else if (gtp_version == GTP_V1 && info->attrs[GTPA_I_TEI])
+			return gtp1_pdp_find(gtp, nla_get_u32(
+						     info->attrs[GTPA_I_TEI]));
+	}
+
+	return ERR_PTR(-EINVAL);
+}
+
+static struct pdp_ctx *gtp_genl_find_pdp(struct sk_buff *skb,
+					 struct genl_info *info)
+{
+	struct pdp_ctx *pctx;
+
+	if (info->attrs[GTPA_LINK])
+		pctx = gtp_genl_find_pdp_by_link(skb, info);
+	else
+		pctx = ERR_PTR(-EINVAL);
+
+	if (!pctx)
+		pctx = ERR_PTR(-ENOENT);
+
+	return pctx;
+}
+
 static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct pdp_ctx *pctx;
-	struct gtp_dev *gtp;
 	int err = 0;
 
-	if (!info->attrs[GTPA_VERSION] ||
-	    !info->attrs[GTPA_LINK])
+	if (!info->attrs[GTPA_VERSION])
 		return -EINVAL;
 
 	rcu_read_lock();
 
-	gtp = gtp_genl_find_dev(sock_net(skb->sk), info->attrs);
-	if (!gtp) {
-		err = -ENODEV;
-		goto out_unlock;
-	}
-
-	switch (nla_get_u32(info->attrs[GTPA_VERSION])) {
-	case GTP_V0:
-		if (!info->attrs[GTPA_TID]) {
-			err = -EINVAL;
-			goto out_unlock;
-		}
-		pctx = gtp0_pdp_find(gtp, nla_get_u64(info->attrs[GTPA_TID]));
-		break;
-	case GTP_V1:
-		if (!info->attrs[GTPA_I_TEI]) {
-			err = -EINVAL;
-			goto out_unlock;
-		}
-		pctx = gtp1_pdp_find(gtp, nla_get_u64(info->attrs[GTPA_I_TEI]));
-		break;
-
-	default:
-		err = -EINVAL;
-		goto out_unlock;
-	}
-
-	if (!pctx) {
-		err = -ENOENT;
+	pctx = gtp_genl_find_pdp(skb, info);
+	if (IS_ERR(pctx)) {
+		err = PTR_ERR(pctx);
 		goto out_unlock;
 	}
 
@@ -1129,49 +1144,16 @@ static int gtp_genl_get_pdp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct pdp_ctx *pctx = NULL;
 	struct sk_buff *skb2;
-	struct gtp_dev *gtp;
-	u32 gtp_version;
 	int err;
 
-	if (!info->attrs[GTPA_VERSION] ||
-	    !info->attrs[GTPA_LINK])
+	if (!info->attrs[GTPA_VERSION])
 		return -EINVAL;
 
-	gtp_version = nla_get_u32(info->attrs[GTPA_VERSION]);
-	switch (gtp_version) {
-	case GTP_V0:
-	case GTP_V1:
-		break;
-	default:
-		return -EINVAL;
-	}
-
 	rcu_read_lock();
 
-	gtp = gtp_genl_find_dev(sock_net(skb->sk), info->attrs);
-	if (!gtp) {
-		err = -ENODEV;
-		goto err_unlock;
-	}
-
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
-
-	if (pctx == NULL) {
-		err = -ENOENT;
+	pctx = gtp_genl_find_pdp(skb, info);
+	if (IS_ERR(pctx)) {
+		err = PTR_ERR(pctx);
 		goto err_unlock;
 	}
 
-- 
2.10.2
