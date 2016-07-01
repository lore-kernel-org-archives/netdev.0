From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V3 08/16] net/devlink: Add E-Switch mode control
Date: Fri,  1 Jul 2016 14:51:01 +0300
Message-ID: <1467373869-22746-9-git-send-email-saeedm@mellanox.com>
References: <1467373869-22746-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53265 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751207AbcGAMTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2016 08:19:23 -0400
In-Reply-To: <1467373869-22746-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add the commands to set and show the mode of SRIOV E-Switch, two modes
are supported:

* legacy: operating in the "old" L2 based mode (DMAC --> VF vport)

* switchdev: the E-Switch is referred to as whitebox switch configured
using standard tools such as tc, bridge, openvswitch etc. To allow
working with the tools, for each VF, a VF representor netdevice is
created by the E-Switch manager vendor device driver instance (e.g PF).

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/devlink.h        |  3 ++
 include/uapi/linux/devlink.h |  8 ++++
 net/core/devlink.c           | 87 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 98 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index 1d45b61..c99ffe8 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -90,6 +90,9 @@ struct devlink_ops {
 				       u16 tc_index,
 				       enum devlink_sb_pool_type pool_type,
 				       u32 *p_cur, u32 *p_max);
+
+	int (*eswitch_mode_get)(struct devlink *devlink, u16 *p_mode);
+	int (*eswitch_mode_set)(struct devlink *devlink, u16 mode);
 };
 
 static inline void *devlink_priv(struct devlink *devlink)
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index ba0073b..915bfa7 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -57,6 +57,8 @@ enum devlink_command {
 	DEVLINK_CMD_SB_OCC_SNAPSHOT,
 	DEVLINK_CMD_SB_OCC_MAX_CLEAR,
 
+	DEVLINK_CMD_ESWITCH_MODE_GET,
+	DEVLINK_CMD_ESWITCH_MODE_SET,
 	/* add new commands above here */
 
 	__DEVLINK_CMD_MAX,
@@ -95,6 +97,11 @@ enum devlink_sb_threshold_type {
 
 #define DEVLINK_SB_THRESHOLD_TO_ALPHA_MAX 20
 
+enum devlink_eswitch_mode {
+	DEVLINK_ESWITCH_MODE_LEGACY,
+	DEVLINK_ESWITCH_MODE_SWITCHDEV,
+};
+
 enum devlink_attr {
 	/* don't change the order or add anything between, this is ABI! */
 	DEVLINK_ATTR_UNSPEC,
@@ -125,6 +132,7 @@ enum devlink_attr {
 	DEVLINK_ATTR_SB_TC_INDEX,		/* u16 */
 	DEVLINK_ATTR_SB_OCC_CUR,		/* u32 */
 	DEVLINK_ATTR_SB_OCC_MAX,		/* u32 */
+	DEVLINK_ATTR_ESWITCH_MODE,		/* u16 */
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 933e8d4..b2e592a 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1394,6 +1394,78 @@ static int devlink_nl_cmd_sb_occ_max_clear_doit(struct sk_buff *skb,
 	return -EOPNOTSUPP;
 }
 
+static int devlink_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
+				enum devlink_command cmd, u32 portid,
+				u32 seq, int flags, u16 mode)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (devlink_nl_put_handle(msg, devlink))
+		goto nla_put_failure;
+
+	if (nla_put_u16(msg, DEVLINK_ATTR_ESWITCH_MODE, mode))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static int devlink_nl_cmd_eswitch_mode_get_doit(struct sk_buff *skb,
+						struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	const struct devlink_ops *ops = devlink->ops;
+	struct sk_buff *msg;
+	u16 mode;
+	int err;
+
+	if (!ops || !ops->eswitch_mode_get)
+		return -EOPNOTSUPP;
+
+	err = ops->eswitch_mode_get(devlink, &mode);
+	if (err)
+		return err;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	err = devlink_eswitch_fill(msg, devlink, DEVLINK_CMD_ESWITCH_MODE_GET,
+				   info->snd_portid, info->snd_seq, 0, mode);
+
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_reply(msg, info);
+}
+
+static int devlink_nl_cmd_eswitch_mode_set_doit(struct sk_buff *skb,
+						struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	const struct devlink_ops *ops = devlink->ops;
+	u16 mode;
+
+	if (!info->attrs[DEVLINK_ATTR_ESWITCH_MODE])
+		return -EINVAL;
+
+	mode = nla_get_u16(info->attrs[DEVLINK_ATTR_ESWITCH_MODE]);
+
+	if (ops && ops->eswitch_mode_set)
+		return ops->eswitch_mode_set(devlink, mode);
+	return -EOPNOTSUPP;
+}
+
 static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_BUS_NAME] = { .type = NLA_NUL_STRING },
 	[DEVLINK_ATTR_DEV_NAME] = { .type = NLA_NUL_STRING },
@@ -1407,6 +1479,7 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE] = { .type = NLA_U8 },
 	[DEVLINK_ATTR_SB_THRESHOLD] = { .type = NLA_U32 },
 	[DEVLINK_ATTR_SB_TC_INDEX] = { .type = NLA_U16 },
+	[DEVLINK_ATTR_ESWITCH_MODE] = { .type = NLA_U16 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
@@ -1525,6 +1598,20 @@ static const struct genl_ops devlink_nl_ops[] = {
 				  DEVLINK_NL_FLAG_NEED_SB |
 				  DEVLINK_NL_FLAG_LOCK_PORTS,
 	},
+	{
+		.cmd = DEVLINK_CMD_ESWITCH_MODE_GET,
+		.doit = devlink_nl_cmd_eswitch_mode_get_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
+	{
+		.cmd = DEVLINK_CMD_ESWITCH_MODE_SET,
+		.doit = devlink_nl_cmd_eswitch_mode_set_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
 };
 
 /**
-- 
2.8.0
