From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 4/7] devlink: Add E-Switch inline mode control
Date: Mon, 21 Nov 2016 15:05:58 +0200
Message-ID: <1479733561-26601-5-git-send-email-saeedm@mellanox.com>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46921 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932325AbcKUNHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:07:19 -0500
In-Reply-To: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

Some HWs need the VF driver to put part of the packet headers on the
TX descriptor so the e-switch can do proper matching and steering.

The supported modes: none, link, network, transport.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/devlink.h        |  2 ++
 include/uapi/linux/devlink.h |  8 +++++
 net/core/devlink.c           | 70 ++++++++++++++++++++++++++++++++------------
 3 files changed, 61 insertions(+), 19 deletions(-)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index 211bd3c..d29e5fc 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -92,6 +92,8 @@ struct devlink_ops {
 
 	int (*eswitch_mode_get)(struct devlink *devlink, u16 *p_mode);
 	int (*eswitch_mode_set)(struct devlink *devlink, u16 mode);
+	int (*eswitch_inline_mode_get)(struct devlink *devlink, u8 *p_inline_mode);
+	int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
 };
 
 static inline void *devlink_priv(struct devlink *devlink)
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 915bfa7..9014c33 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -102,6 +102,13 @@ enum devlink_eswitch_mode {
 	DEVLINK_ESWITCH_MODE_SWITCHDEV,
 };
 
+enum devlink_eswitch_inline_mode {
+	DEVLINK_ESWITCH_INLINE_MODE_NONE,
+	DEVLINK_ESWITCH_INLINE_MODE_LINK,
+	DEVLINK_ESWITCH_INLINE_MODE_NETWORK,
+	DEVLINK_ESWITCH_INLINE_MODE_TRANSPORT,
+};
+
 enum devlink_attr {
 	/* don't change the order or add anything between, this is ABI! */
 	DEVLINK_ATTR_UNSPEC,
@@ -133,6 +140,7 @@ enum devlink_attr {
 	DEVLINK_ATTR_SB_OCC_CUR,		/* u32 */
 	DEVLINK_ATTR_SB_OCC_MAX,		/* u32 */
 	DEVLINK_ATTR_ESWITCH_MODE,		/* u16 */
+	DEVLINK_ATTR_ESWITCH_INLINE_MODE,	/* u8 */
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index c14f8b6..2b5bf9e 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1394,26 +1394,45 @@ static int devlink_nl_cmd_sb_occ_max_clear_doit(struct sk_buff *skb,
 
 static int devlink_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
 				enum devlink_command cmd, u32 portid,
-				u32 seq, int flags, u16 mode)
+				u32 seq, int flags)
 {
+	const struct devlink_ops *ops = devlink->ops;
 	void *hdr;
+	int err = 0;
+	u16 mode;
+	u8 inline_mode;
 
 	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
 	if (!hdr)
 		return -EMSGSIZE;
 
-	if (devlink_nl_put_handle(msg, devlink))
-		goto nla_put_failure;
+	err = devlink_nl_put_handle(msg, devlink);
+	if (err)
+		goto out;
 
-	if (nla_put_u16(msg, DEVLINK_ATTR_ESWITCH_MODE, mode))
-		goto nla_put_failure;
+	err = ops->eswitch_mode_get(devlink, &mode);
+	if (err)
+		goto out;
+	err = nla_put_u16(msg, DEVLINK_ATTR_ESWITCH_MODE, mode);
+	if (err)
+		goto out;
+
+	if (ops->eswitch_inline_mode_get) {
+		err = ops->eswitch_inline_mode_get(devlink, &inline_mode);
+		if (err)
+			goto out;
+		err = nla_put_u8(msg, DEVLINK_ATTR_ESWITCH_INLINE_MODE,
+				 inline_mode);
+		if (err)
+			goto out;
+	}
 
 	genlmsg_end(msg, hdr);
 	return 0;
 
-nla_put_failure:
+out:
 	genlmsg_cancel(msg, hdr);
-	return -EMSGSIZE;
+	return err;
 }
 
 static int devlink_nl_cmd_eswitch_mode_get_doit(struct sk_buff *skb,
@@ -1422,22 +1441,17 @@ static int devlink_nl_cmd_eswitch_mode_get_doit(struct sk_buff *skb,
 	struct devlink *devlink = info->user_ptr[0];
 	const struct devlink_ops *ops = devlink->ops;
 	struct sk_buff *msg;
-	u16 mode;
 	int err;
 
 	if (!ops || !ops->eswitch_mode_get)
 		return -EOPNOTSUPP;
 
-	err = ops->eswitch_mode_get(devlink, &mode);
-	if (err)
-		return err;
-
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return -ENOMEM;
 
 	err = devlink_eswitch_fill(msg, devlink, DEVLINK_CMD_ESWITCH_MODE_GET,
-				   info->snd_portid, info->snd_seq, 0, mode);
+				   info->snd_portid, info->snd_seq, 0);
 
 	if (err) {
 		nlmsg_free(msg);
@@ -1453,15 +1467,32 @@ static int devlink_nl_cmd_eswitch_mode_set_doit(struct sk_buff *skb,
 	struct devlink *devlink = info->user_ptr[0];
 	const struct devlink_ops *ops = devlink->ops;
 	u16 mode;
+	u8 inline_mode;
+	int err = 0;
 
-	if (!info->attrs[DEVLINK_ATTR_ESWITCH_MODE])
-		return -EINVAL;
+	if (!ops)
+		return -EOPNOTSUPP;
 
-	mode = nla_get_u16(info->attrs[DEVLINK_ATTR_ESWITCH_MODE]);
+	if (info->attrs[DEVLINK_ATTR_ESWITCH_MODE]) {
+		if (!ops->eswitch_mode_set)
+			return -EOPNOTSUPP;
+		mode = nla_get_u16(info->attrs[DEVLINK_ATTR_ESWITCH_MODE]);
+		err = ops->eswitch_mode_set(devlink, mode);
+		if (err)
+			return err;
+	}
 
-	if (ops && ops->eswitch_mode_set)
-		return ops->eswitch_mode_set(devlink, mode);
-	return -EOPNOTSUPP;
+	if (info->attrs[DEVLINK_ATTR_ESWITCH_INLINE_MODE]) {
+		if (!ops->eswitch_inline_mode_set)
+			return -EOPNOTSUPP;
+		inline_mode = nla_get_u8(
+				info->attrs[DEVLINK_ATTR_ESWITCH_INLINE_MODE]);
+		err = ops->eswitch_inline_mode_set(devlink, inline_mode);
+		if (err)
+			return err;
+	}
+
+	return 0;
 }
 
 static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
@@ -1478,6 +1509,7 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_SB_THRESHOLD] = { .type = NLA_U32 },
 	[DEVLINK_ATTR_SB_TC_INDEX] = { .type = NLA_U16 },
 	[DEVLINK_ATTR_ESWITCH_MODE] = { .type = NLA_U16 },
+	[DEVLINK_ATTR_ESWITCH_INLINE_MODE] = { .type = NLA_U8 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
-- 
2.7.4
