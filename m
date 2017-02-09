From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/2] net/devlink: Add E-Switch encapsulation control
Date: Thu,  9 Feb 2017 18:23:17 +0200
Message-ID: <1486657398-6298-2-git-send-email-ogerlitz@mellanox.com>
References: <1486657398-6298-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47975 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751446AbdBIQYc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 11:24:32 -0500
In-Reply-To: <1486657398-6298-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

This is an e-switch global knob to enable/disable HW support for applying
encapsulation/decapsulation to VF traffic as part of SRIOV e-switch offloading.

The actual encap/decap is carried out (along with the matching and other actions)
per offloaded e-switch rules, e.g as done when offloading the TC tunnel key action.

The supported mode are enable/disable.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/net/devlink.h        |  2 ++
 include/uapi/linux/devlink.h |  1 +
 net/core/devlink.c           | 22 ++++++++++++++++++++++
 3 files changed, 25 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index d29e5fc..a09bff4 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -94,6 +94,8 @@ struct devlink_ops {
 	int (*eswitch_mode_set)(struct devlink *devlink, u16 mode);
 	int (*eswitch_inline_mode_get)(struct devlink *devlink, u8 *p_inline_mode);
 	int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
+	int (*eswitch_encap_get)(struct devlink *devlink, bool *p_encap);
+	int (*eswitch_encap_set)(struct devlink *devlink, bool encap);
 };
 
 static inline void *devlink_priv(struct devlink *devlink)
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 0f1f3a1..c3f05c6 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -147,6 +147,7 @@ enum devlink_attr {
 	DEVLINK_ATTR_SB_OCC_MAX,		/* u32 */
 	DEVLINK_ATTR_ESWITCH_MODE,		/* u16 */
 	DEVLINK_ATTR_ESWITCH_INLINE_MODE,	/* u8 */
+	DEVLINK_ATTR_ESWITCH_ENCAP,		/* u8 */
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index e9c1e6a..9af5372 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1401,6 +1401,7 @@ static int devlink_nl_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
 	int err = 0;
 	u16 mode;
 	u8 inline_mode;
+	bool encap;
 
 	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
 	if (!hdr)
@@ -1429,6 +1430,15 @@ static int devlink_nl_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
 			goto nla_put_failure;
 	}
 
+	if (mode == DEVLINK_ESWITCH_MODE_SWITCHDEV && ops->eswitch_encap_get) {
+		err = ops->eswitch_encap_get(devlink, &encap);
+		if (err)
+			goto nla_put_failure;
+		err = nla_put_u8(msg, DEVLINK_ATTR_ESWITCH_ENCAP, encap);
+		if (err)
+			goto nla_put_failure;
+	}
+
 	genlmsg_end(msg, hdr);
 	return 0;
 
@@ -1470,11 +1480,23 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
 	const struct devlink_ops *ops = devlink->ops;
 	u16 mode;
 	u8 inline_mode;
+	bool encap;
 	int err = 0;
 
 	if (!ops)
 		return -EOPNOTSUPP;
 
+	if (info->attrs[DEVLINK_ATTR_ESWITCH_ENCAP]) {
+		if (!ops->eswitch_encap_set)
+			return -EOPNOTSUPP;
+		if (!info->attrs[DEVLINK_ATTR_ESWITCH_MODE])
+			return -EINVAL;
+		encap = nla_get_u8(info->attrs[DEVLINK_ATTR_ESWITCH_ENCAP]);
+		err = ops->eswitch_encap_set(devlink, encap);
+		if (err)
+			return err;
+	}
+
 	if (info->attrs[DEVLINK_ATTR_ESWITCH_MODE]) {
 		if (!ops->eswitch_mode_set)
 			return -EOPNOTSUPP;
-- 
2.5.5
