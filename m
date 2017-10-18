From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/7] devlink: Add permanent config parameter get/set
 operations
Date: Wed, 18 Oct 2017 09:11:40 +0200
Message-ID: <20171018071140.GB2028@nanopsycho>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-2-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, davem@davemloft.net,
        michael.chan@broadcom.com, linville@tuxdriver.com,
        gospo@broadcom.com
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:49500 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755589AbdJRHLm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 03:11:42 -0400
Received: by mail-wr0-f195.google.com with SMTP id g90so3940358wrd.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 00:11:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508273069-40461-2-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 17, 2017 at 10:44:23PM CEST, steven.lin1@broadcom.com wrote:
>Add support for permanent config parameter get/set commands. Used
>for parameters held in NVRAM, persistent device configuration.
>The config_get() and config_set() operations operate as expected, but
>note that the driver implementation of the config_set() operation can
>indicate whether a restart is necessary for the setting to take
>effect.  This indication of a necessary restart is passed via the
>DEVLINK_ATTR_PERM_CFG_RESTART_REQUIRED attribute.
>
>First set of parameters defined are PCI SR-IOV and per-VF
>configuration:
>
>DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED: Enable SR-IOV capability.
>DEVLINK_ATTR_PERM_CFG_NUM_VF_PER_PF: Maximum number of VFs per PF, in
>SR-IOV mode.
>DEVLINK_ATTR_PERM_CFG_MAX_NUM_PF_MSIX_VECT: Maximum number of
>MSI-X vectors assigned per PF.
>DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF: Number of MSI-X vectors
>allocated per VF.
>
>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>---
> include/net/devlink.h        |   4 +
> include/uapi/linux/devlink.h |  20 ++++
> net/core/devlink.c           | 266 +++++++++++++++++++++++++++++++++++++++++++
> 3 files changed, 290 insertions(+)
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
>index 0cbca96..34de44d 100644
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
>@@ -202,6 +205,23 @@ enum devlink_attr {
> 
> 	DEVLINK_ATTR_ESWITCH_ENCAP_MODE,	/* u8 */
> 
>+	/* Permanent Configuration Parameters */
>+	DEVLINK_ATTR_PERM_CFG,				/* nested */
>+
>+	/* When config doesn't take effect until next reboot (config
>+	 * just changed NVM which isn't read until boot, for example),
>+	 * this attribute should be set by the driver.
>+	 */
>+	DEVLINK_ATTR_PERM_CFG_RESTART_REQUIRED,		/* u8 */
>+	DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED,		/* u8 */
>+	DEVLINK_ATTR_PERM_CFG_FIRST = DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED,
>+	DEVLINK_ATTR_PERM_CFG_NUM_VF_PER_PF,		/* u32 */
>+	DEVLINK_ATTR_PERM_CFG_MAX_NUM_PF_MSIX_VECT,	/* u32 */
>+	DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF,	/* u32 */

Steve. As I originally requested, could you please split this to:
1) single patch adding config get/set commands, without any config attributes
2) single patch per config attribute - please don't add them in bulk.
   We also need very strict description for every single attribute so
   other vendors know what it is and can re-use it. There is need to
   avoid duplication here. Also, please send just few attribites in the
   first run, not like 40 you are sending now. Impossible to review.

Also, why didn't you put it into nested attribute we were discussing?


>+
>+	/* Add new permanent config parameters above here */
>+	DEVLINK_ATTR_PERM_CFG_LAST = DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF,

Yeah, this is odd, it replaces nested attribute aproach.


>+
> 	/* add new attributes above here, update the policy in devlink.c */
> 
> 	__DEVLINK_ATTR_MAX,
>diff --git a/net/core/devlink.c b/net/core/devlink.c
>index 7d430c1..427a65e 100644
>--- a/net/core/devlink.c
>+++ b/net/core/devlink.c
>@@ -1566,6 +1566,254 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
> 	return 0;
> }
> 
>+static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
>+
>+static int devlink_nl_sing_param_get(struct sk_buff *msg,

I was wondering what song it will sing :) Just add "le", it's just 2
chars :)
