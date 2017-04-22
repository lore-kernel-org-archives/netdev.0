From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 1/5] net/devlink: Add E-Switch encapsulation control
Date: Sat, 22 Apr 2017 21:45:03 +0300
Message-ID: <20170422184507.26569-2-saeedm@mellanox.com>
References: <20170422184507.26569-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48068 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1426088AbdDVSpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 14:45:44 -0400
In-Reply-To: <20170422184507.26569-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

This is an e-switch global knob to enable HW support for applying
encapsulation/decapsulation to VF traffic as part of SRIOV e-switch offloading.

The actual encap/decap is carried out (along with the matching and other actions)
per offloaded e-switch rules, e.g as done when offloading the TC tunnel key action.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/devlink.h        |  2 ++
 include/uapi/linux/devlink.h |  7 +++++++
 net/core/devlink.c           | 26 +++++++++++++++++++++++---
 3 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index 24de13f8c94f..ed7687bbf5d0 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -268,6 +268,8 @@ struct devlink_ops {
 	int (*eswitch_mode_set)(struct devlink *devlink, u16 mode);
 	int (*eswitch_inline_mode_get)(struct devlink *devlink, u8 *p_inline_mode);
 	int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
+	int (*eswitch_encap_mode_get)(struct devlink *devlink, u8 *p_encap_mode);
+	int (*eswitch_encap_mode_set)(struct devlink *devlink, u8 encap_mode);
 };
 
 static inline void *devlink_priv(struct devlink *devlink)
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index b47bee277347..b0e807ac53bb 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -119,6 +119,11 @@ enum devlink_eswitch_inline_mode {
 	DEVLINK_ESWITCH_INLINE_MODE_TRANSPORT,
 };
 
+enum devlink_eswitch_encap_mode {
+	DEVLINK_ESWITCH_ENCAP_MODE_NONE,
+	DEVLINK_ESWITCH_ENCAP_MODE_BASIC,
+};
+
 enum devlink_attr {
 	/* don't change the order or add anything between, this is ABI! */
 	DEVLINK_ATTR_UNSPEC,
@@ -195,6 +200,8 @@ enum devlink_attr {
 
 	DEVLINK_ATTR_PAD,
 
+	DEVLINK_ATTR_ESWITCH_ENCAP_MODE,	/* u8 */
+
 	/* add new attributes above here, update the policy in devlink.c */
 
 	__DEVLINK_ATTR_MAX,
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 0afac5800b57..b0b87a292e7c 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1397,10 +1397,10 @@ static int devlink_nl_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
 				   u32 seq, int flags)
 {
 	const struct devlink_ops *ops = devlink->ops;
+	u8 inline_mode, encap_mode;
 	void *hdr;
 	int err = 0;
 	u16 mode;
-	u8 inline_mode;
 
 	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
 	if (!hdr)
@@ -1429,6 +1429,15 @@ static int devlink_nl_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
 			goto nla_put_failure;
 	}
 
+	if (ops->eswitch_encap_mode_get) {
+		err = ops->eswitch_encap_mode_get(devlink, &encap_mode);
+		if (err)
+			goto nla_put_failure;
+		err = nla_put_u8(msg, DEVLINK_ATTR_ESWITCH_ENCAP_MODE, encap_mode);
+		if (err)
+			goto nla_put_failure;
+	}
+
 	genlmsg_end(msg, hdr);
 	return 0;
 
@@ -1468,9 +1477,9 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
 {
 	struct devlink *devlink = info->user_ptr[0];
 	const struct devlink_ops *ops = devlink->ops;
-	u16 mode;
-	u8 inline_mode;
+	u8 inline_mode, encap_mode;
 	int err = 0;
+	u16 mode;
 
 	if (!ops)
 		return -EOPNOTSUPP;
@@ -1493,6 +1502,16 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
 		if (err)
 			return err;
 	}
+
+	if (info->attrs[DEVLINK_ATTR_ESWITCH_ENCAP_MODE]) {
+		if (!ops->eswitch_encap_mode_set)
+			return -EOPNOTSUPP;
+		encap_mode = nla_get_u8(info->attrs[DEVLINK_ATTR_ESWITCH_ENCAP_MODE]);
+		err = ops->eswitch_encap_mode_set(devlink, encap_mode);
+		if (err)
+			return err;
+	}
+
 	return 0;
 }
 
@@ -2190,6 +2209,7 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_SB_TC_INDEX] = { .type = NLA_U16 },
 	[DEVLINK_ATTR_ESWITCH_MODE] = { .type = NLA_U16 },
 	[DEVLINK_ATTR_ESWITCH_INLINE_MODE] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_ESWITCH_ENCAP_MODE] = { .type = NLA_U8 },
 	[DEVLINK_ATTR_DPIPE_TABLE_NAME] = { .type = NLA_NUL_STRING },
 	[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] = { .type = NLA_U8 },
 };
-- 
2.11.0
