From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC 1/3] devlink: Add config parameter get/set operations
Date: Thu, 12 Oct 2017 16:03:17 +0200
Message-ID: <20171012140317.GC14672@nanopsycho>
References: <1507815262-33294-1-git-send-email-steven.lin1@broadcom.com>
 <1507815262-33294-2-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, davem@davemloft.net,
        michael.chan@broadcom.com, linux-pci@vger.kernel.org,
        linville@tuxdriver.com, gospo@broadcom.com
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507815262-33294-2-git-send-email-steven.lin1@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Oct 12, 2017 at 03:34:20PM CEST, steven.lin1@broadcom.com wrote:
>Add support for config parameter get/set commands. Initially used by
>bnxt driver, but other drivers can use the same, or new, attributes.
>The config_get() and config_set() operations operate as expected, but
>note that the driver implementation of the config_set() operation can
>indicate whether a restart is necessary for the setting to take
>effect.
>

First of all, I like this approach.

I would like to see this patch split into:
1) config-options infrastructure introduction
2) specific config options introductions - would be best to have it
   per-option. We need to make sure every option is very well described
   and explained usecases. This is needed in order vendors to share
   attributes among drivers.

More nits inlined.


>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>---
> include/net/devlink.h        |   4 +
> include/uapi/linux/devlink.h | 108 ++++++++++++++++++++++
> net/core/devlink.c           | 207 +++++++++++++++++++++++++++++++++++++++++++
> 3 files changed, 319 insertions(+)
>
>diff --git a/include/net/devlink.h b/include/net/devlink.h
>index b9654e1..952966c 100644
>--- a/include/net/devlink.h
>+++ b/include/net/devlink.h
>@@ -270,6 +270,10 @@ struct devlink_ops {
> 	int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
> 	int (*eswitch_encap_mode_get)(struct devlink *devlink, u8 *p_encap_mode);
> 	int (*eswitch_encap_mode_set)(struct devlink *devlink, u8 encap_mode);
>+	int (*config_get)(struct devlink *devlink, enum devlink_attr attr,
>+			  u32 *value);
>+	int (*config_set)(struct devlink *devlink, enum devlink_attr attr,
>+			  u32 value, u8 *restart_reqd);
> };
> 
> static inline void *devlink_priv(struct devlink *devlink)
>diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>index 0cbca96..e959716 100644
>--- a/include/uapi/linux/devlink.h
>+++ b/include/uapi/linux/devlink.h
>@@ -70,6 +70,9 @@ enum devlink_command {
> 	DEVLINK_CMD_DPIPE_HEADERS_GET,
> 	DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
> 
>+	DEVLINK_CMD_CONFIG_GET,
>+	DEVLINK_CMD_CONFIG_SET,
>+
> 	/* add new commands above here */
> 	__DEVLINK_CMD_MAX,
> 	DEVLINK_CMD_MAX = __DEVLINK_CMD_MAX - 1
>@@ -124,6 +127,68 @@ enum devlink_eswitch_encap_mode {
> 	DEVLINK_ESWITCH_ENCAP_MODE_BASIC,
> };
> 
>+enum devlink_dcbx_mode {
>+	DEVLINK_DCBX_MODE_DISABLED,
>+	DEVLINK_DCBX_MODE_IEEE,
>+	DEVLINK_DCBX_MODE_CEE,
>+	DEVLINK_DCBX_MODE_IEEE_CEE,
>+};
>+
>+enum devlink_multifunc_mode {
>+	DEVLINK_MULTIFUNC_MODE_ALLOWED,		/* Ext switch activates MF */
>+	DEVLINK_MULTIFUNC_MODE_FORCE_SINGFUNC,
>+	DEVLINK_MULTIFUNC_MODE_NPAR10,		/* NPAR 1.0 */
>+	DEVLINK_MULTIFUNC_MODE_NPAR15,		/* NPAR 1.5 */
>+	DEVLINK_MULTIFUNC_MODE_NPAR20,		/* NPAR 2.0 */
>+};
>+
>+enum devlink_autoneg_protocol {
>+	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_BAM,
>+	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_CONSORTIUM,
>+	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY,
>+	DEVLINK_AUTONEG_PROTOCOL_BAM,		/* Broadcom Autoneg Mode */
>+	DEVLINK_AUTONEG_PROTOCOL_CONSORTIUM,	/* Consortium Autoneg Mode */
>+};
>+
>+enum devlink_pre_os_link_speed {
>+	DEVLINK_PRE_OS_LINK_SPEED_AUTONEG,
>+	DEVLINK_PRE_OS_LINK_SPEED_1G,
>+	DEVLINK_PRE_OS_LINK_SPEED_10G,
>+	DEVLINK_PRE_OS_LINK_SPEED_25G,
>+	DEVLINK_PRE_OS_LINK_SPEED_40G,
>+	DEVLINK_PRE_OS_LINK_SPEED_50G,
>+	DEVLINK_PRE_OS_LINK_SPEED_100G,
>+	DEVLINK_PRE_OS_LINK_SPEED_5G = 0xe,
>+	DEVLINK_PRE_OS_LINK_SPEED_100M = 0xf,
>+};
>+
>+enum devlink_mba_boot_type {
>+	DEVLINK_MBA_BOOT_TYPE_AUTO_DETECT,
>+	DEVLINK_MBA_BOOT_TYPE_BBS,		/* BIOS Boot Specification */
>+	DEVLINK_MBA_BOOT_TYPE_INTR18,		/* Hook interrupt 0x18 */
>+	DEVLINK_MBA_BOOT_TYPE_INTR19,		/* Hook interrupt 0x19 */
>+};
>+
>+enum devlink_mba_setup_hot_key {
>+	DEVLINK_MBA_SETUP_HOT_KEY_CTRL_S,
>+	DEVLINK_MBA_SETUP_HOT_KEY_CTRL_B,
>+};
>+
>+enum devlink_mba_boot_protocol {
>+	DEVLINK_MBA_BOOT_PROTOCOL_PXE,
>+	DEVLINK_MBA_BOOT_PROTOCOL_ISCSI,
>+	DEVLINK_MBA_BOOT_PROTOCOL_NONE = 0x7,
>+};
>+
>+enum devlink_mba_link_speed {
>+	DEVLINK_MBA_LINK_SPEED_AUTONEG,
>+	DEVLINK_MBA_LINK_SPEED_1G,
>+	DEVLINK_MBA_LINK_SPEED_10G,
>+	DEVLINK_MBA_LINK_SPEED_25G,
>+	DEVLINK_MBA_LINK_SPEED_40G,
>+	DEVLINK_MBA_LINK_SPEED_50G,
>+};
>+
> enum devlink_attr {
> 	/* don't change the order or add anything between, this is ABI! */
> 	DEVLINK_ATTR_UNSPEC,
>@@ -202,6 +267,49 @@ enum devlink_attr {
> 
> 	DEVLINK_ATTR_ESWITCH_ENCAP_MODE,	/* u8 */
> 
>+	/* Configuration Parameters */
>+	DEVLINK_ATTR_SRIOV_ENABLED,		/* u8 */
>+	DEVLINK_ATTR_NUM_VF_PER_PF,		/* u32 */
>+	DEVLINK_ATTR_MAX_NUM_PF_MSIX_VECT,	/* u32 */
>+	DEVLINK_ATTR_MSIX_VECTORS_PER_VF,	/* u32 */
>+	DEVLINK_ATTR_NPAR_NUM_PARTITIONS_PER_PORT,	/* u32 */
>+	DEVLINK_ATTR_NPAR_BW_IN_PERCENT,	/* u8 */
>+	DEVLINK_ATTR_NPAR_BW_RESERVATION,	/* u8 */
>+	DEVLINK_ATTR_NPAR_BW_RESERVATION_VALID,	/* u8 */
>+	DEVLINK_ATTR_NPAR_BW_LIMIT,		/* u8 */
>+	DEVLINK_ATTR_NPAR_BW_LIMIT_VALID,	/* u8 */
>+	DEVLINK_ATTR_DCBX_MODE,			/* u8 */
>+	DEVLINK_ATTR_RDMA_ENABLED,		/* u8 */
>+	DEVLINK_ATTR_MULTIFUNC_MODE,		/* u8 */
>+	DEVLINK_ATTR_SECURE_NIC_ENABLED,	/* u8 */
>+	DEVLINK_ATTR_IGNORE_ARI_CAPABILITY,	/* u8 */
>+	DEVLINK_ATTR_LLDP_NEAREST_BRIDGE_ENABLED,	/* u8 */
>+	DEVLINK_ATTR_LLDP_NEAREST_NONTPMR_BRIDGE_ENABLED,	/* u8 */
>+	DEVLINK_ATTR_PME_CAPABILITY_ENABLED,	/* u8 */
>+	DEVLINK_ATTR_MAGIC_PACKET_WOL_ENABLED,	/* u8 */
>+	DEVLINK_ATTR_EEE_PWR_SAVE_ENABLED,	/* u8 */
>+	DEVLINK_ATTR_AUTONEG_PROTOCOL,		/* u8 */
>+	DEVLINK_ATTR_MEDIA_AUTO_DETECT,		/* u8 */
>+	DEVLINK_ATTR_PHY_SELECT,		/* u8 */
>+	DEVLINK_ATTR_PRE_OS_LINK_SPEED_D0,	/* u8 */
>+	DEVLINK_ATTR_PRE_OS_LINK_SPEED_D3,	/* u8 */
>+	DEVLINK_ATTR_MBA_ENABLED,		/* u8 */
>+	DEVLINK_ATTR_MBA_BOOT_TYPE,		/* u8 */
>+	DEVLINK_ATTR_MBA_DELAY_TIME,		/* u32 */
>+	DEVLINK_ATTR_MBA_SETUP_HOT_KEY,		/* u8 */
>+	DEVLINK_ATTR_MBA_HIDE_SETUP_PROMPT,	/* u8 */
>+	DEVLINK_ATTR_MBA_BOOT_RETRY_COUNT,	/* u32 */
>+	DEVLINK_ATTR_MBA_VLAN_ENABLED,		/* u8 */
>+	DEVLINK_ATTR_MBA_VLAN_TAG,		/* u16 */
>+	DEVLINK_ATTR_MBA_BOOT_PROTOCOL,		/* u8 */
>+	DEVLINK_ATTR_MBA_LINK_SPEED,		/* u8 */

Okay, I think it is about the time we should start thinking about
putting this new config attributes under nester attribute. What do you
think?


>+
>+	/* When config doesn't take effect until next reboot (config
>+	 * just changed NVM which isn't read until boot, for example),
>+	 * this attribute should be set by the driver.
>+	 */
>+	DEVLINK_ATTR_RESTART_REQUIRED,		/* u8 */
>+
> 	/* add new attributes above here, update the policy in devlink.c */
> 
> 	__DEVLINK_ATTR_MAX,
>diff --git a/net/core/devlink.c b/net/core/devlink.c
>index 7d430c1..701c84b 100644
>--- a/net/core/devlink.c
>+++ b/net/core/devlink.c
>@@ -1566,6 +1566,164 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
> 	return 0;
> }
> 
>+static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
>+
>+static int devlink_nl_config_fill(struct sk_buff *msg,
>+				  struct devlink *devlink,
>+				  enum devlink_command cmd,
>+				  struct genl_info *info)
>+{
>+	const struct devlink_ops *ops = devlink->ops;
>+	void *hdr;
>+	int err;
>+	enum devlink_attr attr = -1;

-1 is not a valid enum value. Better to just have bool to indicate attr
was found or not.


>+	u32 value;
>+	int i;
>+	struct nla_policy policy;
>+	u8 restart_reqd;
>+
>+	if (!ops->config_get)
>+		return -EOPNOTSUPP;
>+
>+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
>+			  &devlink_nl_family, 0, cmd);
>+	if (!hdr) {
>+		err = -EMSGSIZE;
>+		goto nla_msg_failure;
>+	}
>+
>+	err = devlink_nl_put_handle(msg, devlink);
>+	if (err)
>+		goto nla_put_failure;
>+
>+	for (i = 0; i < DEVLINK_ATTR_MAX; i++)
>+		if (info->attrs[i])
>+			attr = i;
>+
>+	if (attr == -1) {
>+		/* Not found - invalid/unknown attribute? */
>+		err = -EINVAL;
>+		goto nla_put_failure;
>+	}
>+
>+	policy = devlink_nl_policy[attr];
>+
>+	if (cmd == DEVLINK_CMD_CONFIG_GET) {
>+		err = ops->config_get(devlink, attr, &value);
>+
>+		if (err)
>+			goto nla_put_failure;
>+
>+		switch (policy.type) {
>+		case NLA_U8:
>+			err = nla_put_u8(msg, attr, value);
>+			break;
>+		case NLA_U16:
>+			err = nla_put_u16(msg, attr, value);
>+			break;
>+		case NLA_U32:
>+			err = nla_put_u32(msg, attr, value);
>+			break;
>+		default:
>+			goto nla_put_failure;
>+		}
>+
>+		if (err)
>+			goto nla_put_failure;
>+	} else {
>+		/* Must be config_set command */
>+		u8 *val8;
>+		u16 *val16;
>+		u32 *val32;
>+
>+		switch (policy.type) {
>+		case NLA_U8:
>+			val8 = nla_data(info->attrs[attr]);
>+			value = *val8;
>+			break;
>+		case NLA_U16:
>+			val16 = nla_data(info->attrs[attr]);
>+			value = *val16;
>+			break;
>+		case NLA_U32:
>+			val32 = nla_data(info->attrs[attr]);
>+			value = *val32;
>+			break;
>+		default:
>+			goto nla_put_failure;
>+		}
>+
>+		err = ops->config_set(devlink, attr, value, &restart_reqd);
>+		if (err)
>+			goto nla_put_failure;
>+
>+		if (restart_reqd) {
>+			err = nla_put_u8(msg, DEVLINK_ATTR_RESTART_REQUIRED,
>+					 restart_reqd);
>+			if (err)
>+				goto nla_put_failure;
>+		}
>+	}
>+
>+	genlmsg_end(msg, hdr);
>+	return 0;
>+
>+nla_put_failure:
>+	genlmsg_cancel(msg, hdr);
>+nla_msg_failure:
>+	return err;
>+}
>+
>+static int devlink_nl_cmd_config_get_doit(struct sk_buff *skb,
>+					  struct genl_info *info)
>+{
>+	struct devlink *devlink = info->user_ptr[0];
>+	struct sk_buff *msg;
>+	int err;
>+
>+	if (!devlink->ops)
>+		return -EOPNOTSUPP;
>+
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>+	if (!msg)
>+		return -ENOMEM;
>+
>+	err = devlink_nl_config_fill(msg, devlink, DEVLINK_CMD_CONFIG_GET,
>+				     info);
>+
>+	if (err) {
>+		nlmsg_free(msg);
>+		return err;
>+	}
>+
>+	return genlmsg_reply(msg, info);
>+}
>+
>+static int devlink_nl_cmd_config_set_doit(struct sk_buff *skb,
>+					  struct genl_info *info)
>+{
>+	struct devlink *devlink = info->user_ptr[0];
>+	struct sk_buff *msg;
>+	int err;
>+
>+	if (!devlink->ops)
>+		return -EOPNOTSUPP;
>+
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>+	if (!msg)
>+		return -ENOMEM;
>+
>+	err = devlink_nl_config_fill(msg, devlink, DEVLINK_CMD_CONFIG_SET,
>+				     info);

This is odd. You are using "fill" function for "set". It should be used
for "get". But for set, it really sounds odd. Please split the
devlink_nl_config_fill function into get and set parts.

Also, get should dump all available options. 


>+
>+	if (err) {
>+		nlmsg_free(msg);
>+		return err;
>+	}
>+
>+	return genlmsg_reply(msg, info);
>+}
>+
> int devlink_dpipe_match_put(struct sk_buff *skb,
> 			    struct devlink_dpipe_match *match)
> {
>@@ -2291,6 +2449,41 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
> 	[DEVLINK_ATTR_ESWITCH_ENCAP_MODE] = { .type = NLA_U8 },
> 	[DEVLINK_ATTR_DPIPE_TABLE_NAME] = { .type = NLA_NUL_STRING },
> 	[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_SRIOV_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_NUM_VF_PER_PF] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_MAX_NUM_PF_MSIX_VECT] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_MSIX_VECTORS_PER_VF] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_NPAR_NUM_PARTITIONS_PER_PORT] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_NPAR_BW_IN_PERCENT] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_NPAR_BW_RESERVATION] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_NPAR_BW_RESERVATION_VALID] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_NPAR_BW_LIMIT] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_NPAR_BW_LIMIT_VALID] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_DCBX_MODE] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_RDMA_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_MULTIFUNC_MODE] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_SECURE_NIC_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_IGNORE_ARI_CAPABILITY] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_LLDP_NEAREST_BRIDGE_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_LLDP_NEAREST_NONTPMR_BRIDGE_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_PME_CAPABILITY_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_MAGIC_PACKET_WOL_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_EEE_PWR_SAVE_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_AUTONEG_PROTOCOL] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_MEDIA_AUTO_DETECT] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_PHY_SELECT] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_PRE_OS_LINK_SPEED_D0] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_PRE_OS_LINK_SPEED_D3] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_MBA_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_MBA_BOOT_TYPE] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_MBA_DELAY_TIME] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_MBA_SETUP_HOT_KEY] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_MBA_HIDE_SETUP_PROMPT] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_MBA_BOOT_RETRY_COUNT] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_MBA_VLAN_ENABLED] = { .type = NLA_U8 },
>+	[DEVLINK_ATTR_MBA_VLAN_TAG] = { .type = NLA_U16 },
>+	[DEVLINK_ATTR_MBA_BOOT_PROTOCOL] = { .type = NLA_U32 },
>+	[DEVLINK_ATTR_MBA_LINK_SPEED] = { .type = NLA_U32 },
> };
> 
> static const struct genl_ops devlink_nl_ops[] = {
>@@ -2451,6 +2644,20 @@ static const struct genl_ops devlink_nl_ops[] = {
> 		.flags = GENL_ADMIN_PERM,
> 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
> 	},
>+	{
>+		.cmd = DEVLINK_CMD_CONFIG_GET,
>+		.doit = devlink_nl_cmd_config_get_doit,
>+		.policy = devlink_nl_policy,
>+		.flags = GENL_ADMIN_PERM,
>+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>+	},
>+	{
>+		.cmd = DEVLINK_CMD_CONFIG_SET,
>+		.doit = devlink_nl_cmd_config_set_doit,
>+		.policy = devlink_nl_policy,
>+		.flags = GENL_ADMIN_PERM,
>+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>+	},
> };
> 
> static struct genl_family devlink_nl_family __ro_after_init = {
>-- 
>2.7.4
>
