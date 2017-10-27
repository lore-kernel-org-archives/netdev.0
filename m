From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 01/10] devlink: Add permanent config
 parameter get/set operations
Date: Fri, 27 Oct 2017 23:04:55 +0200
Message-ID: <20171027210455.GC1980@nanopsycho.orion>
References: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
 <1509137654-1580-2-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, davem@davemloft.net,
        michael.chan@broadcom.com, linville@tuxdriver.com,
        gospo@broadcom.com, yuvalm@mellanox.com
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:46689 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932103AbdJ0VE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 17:04:57 -0400
Received: by mail-wm0-f68.google.com with SMTP id m72so5580699wmc.1
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 14:04:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1509137654-1580-2-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 27, 2017 at 10:54:05PM CEST, steven.lin1@broadcom.com wrote:
>Add support for permanent config parameter get/set commands. Used
>for persistent device configuration parameters.
>
>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>---
> include/net/devlink.h        |   7 ++
> include/uapi/linux/devlink.h |  25 ++++
> net/core/devlink.c           | 287 +++++++++++++++++++++++++++++++++++++++++++
> 3 files changed, 319 insertions(+)
>
>diff --git a/include/net/devlink.h b/include/net/devlink.h
>index b9654e1..c7dd912 100644
>--- a/include/net/devlink.h
>+++ b/include/net/devlink.h
>@@ -270,6 +270,13 @@ struct devlink_ops {
> 	int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
> 	int (*eswitch_encap_mode_get)(struct devlink *devlink, u8 *p_encap_mode);
> 	int (*eswitch_encap_mode_set)(struct devlink *devlink, u8 encap_mode);
>+	int (*perm_config_get)(struct devlink *devlink,
>+			       enum devlink_perm_config_param param, u8 type,
>+			       union devlink_perm_config_value *value);
>+	int (*perm_config_set)(struct devlink *devlink,
>+			       enum devlink_perm_config_param param, u8 type,
>+			       union devlink_perm_config_value *value,
>+			       u8 *restart_reqd);

type should be enum and restart_reqd should be bool.

[...]	
	
	
>+static int devlink_nl_single_param_set(struct sk_buff *msg,
>+				       struct devlink *devlink,
>+				       u32 param, u8 type,
>+				       union devlink_perm_config_value *value)
>+{
>+	const struct devlink_ops *ops = devlink->ops;
>+	struct nlattr *cfgparam_attr;
>+	u8 need_restart;
>+	int err;
>+
>+	/* Now set parameter */
>+	err = ops->perm_config_set(devlink, param, type, value, &need_restart);
>+	if (err)
>+		return err;
>+
>+	cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
>+	/* Update restart reqd - if any param needs restart, should be set */
>+	if (need_restart) {
>+		err = nla_put_u8(msg,
>+				 DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED, 1);

Why don't you just put this flag always? Otherwise it could be NLA_FLAG


>+		if (err)
>+			goto nest_fail;
>+	}
>+
