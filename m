From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 01/10] devlink: Add permanent config
 parameter get/set operations
Date: Sat, 28 Oct 2017 09:16:31 +0200
Message-ID: <20171028071631.GA1980@nanopsycho.orion>
References: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
 <1509137654-1580-2-git-send-email-steven.lin1@broadcom.com>
 <20171027210455.GC1980@nanopsycho.orion>
 <CA+Jmh7EeJv_kTRpvtx7q-tR8ugA-E7vQB6pBabggrN-ojB=2Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>,
        Yuval Mintz <yuvalm@mellanox.com>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:52086 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdJ1HQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 03:16:34 -0400
Received: by mail-wm0-f68.google.com with SMTP id b9so7259010wmh.0
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 00:16:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+Jmh7EeJv_kTRpvtx7q-tR8ugA-E7vQB6pBabggrN-ojB=2Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 27, 2017 at 11:26:52PM CEST, steven.lin1@broadcom.com wrote:
>On Fri, Oct 27, 2017 at 5:04 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Fri, Oct 27, 2017 at 10:54:05PM CEST, steven.lin1@broadcom.com wrote:
>>>Add support for permanent config parameter get/set commands. Used
>>>for persistent device configuration parameters.
>>>
>>>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>>>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>>>---
>>> include/net/devlink.h        |   7 ++
>>> include/uapi/linux/devlink.h |  25 ++++
>>> net/core/devlink.c           | 287 +++++++++++++++++++++++++++++++++++++++++++
>>> 3 files changed, 319 insertions(+)
>>>
>>>diff --git a/include/net/devlink.h b/include/net/devlink.h
>>>index b9654e1..c7dd912 100644
>>>--- a/include/net/devlink.h
>>>+++ b/include/net/devlink.h
>>>@@ -270,6 +270,13 @@ struct devlink_ops {
>>>       int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
>>>       int (*eswitch_encap_mode_get)(struct devlink *devlink, u8 *p_encap_mode);
>>>       int (*eswitch_encap_mode_set)(struct devlink *devlink, u8 encap_mode);
>>>+      int (*perm_config_get)(struct devlink *devlink,
>>>+                             enum devlink_perm_config_param param, u8 type,
>>>+                             union devlink_perm_config_value *value);
>>>+      int (*perm_config_set)(struct devlink *devlink,
>>>+                             enum devlink_perm_config_param param, u8 type,
>>>+                             union devlink_perm_config_value *value,
>>>+                             u8 *restart_reqd);
>>
>> type should be enum and restart_reqd should be bool.
>
>Throughout devlink/netlink code, NLA_* types are not a named enum;
>they're defined like this in netlink.h:
>
>enum {
>        NLA_UNSPEC,
>        NLA_U8,
>        NLA_U16,
>        NLA_U32,
>        .... additional types follow ....
>};
>
>and are, I believe referred to as u8 or u16 in the code.  I could
>define a new enum specifically for the config get/set types, but that
>seems duplicative with the NLA_* types already defined - is that what
>you're suggesting?

Yes, and that should be aligned with union devlink_perm_config_value.


>
>I will change restart_reqd to be bool.
>
>>
>> [...]
>>
>>
>>>+static int devlink_nl_single_param_set(struct sk_buff *msg,
>>>+                                     struct devlink *devlink,
>>>+                                     u32 param, u8 type,
>>>+                                     union devlink_perm_config_value *value)
>>>+{
>>>+      const struct devlink_ops *ops = devlink->ops;
>>>+      struct nlattr *cfgparam_attr;
>>>+      u8 need_restart;
>>>+      int err;
>>>+
>>>+      /* Now set parameter */
>>>+      err = ops->perm_config_set(devlink, param, type, value, &need_restart);
>>>+      if (err)
>>>+              return err;
>>>+
>>>+      cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
>>>+      /* Update restart reqd - if any param needs restart, should be set */
>>>+      if (need_restart) {
>>>+              err = nla_put_u8(msg,
>>>+                               DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED, 1);
>>
>> Why don't you just put this flag always? Otherwise it could be NLA_FLAG
>
>Ok, I will change to NLA_FLAG.
>
>Thanks,
>Steve
