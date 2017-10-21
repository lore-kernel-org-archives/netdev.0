From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 1/6] devlink: Add permanent config parameter
 get/set operations
Date: Sat, 21 Oct 2017 11:24:21 +0200
Message-ID: <20171021092421.GB1948@nanopsycho.orion>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-2-git-send-email-steven.lin1@broadcom.com>
 <20171020143948.GC1994@nanopsycho.orion>
 <CA+Jmh7GptV5EZYWpQzHnT8Q1KDSZ-juQCfOr=VKFt4jyMOqFYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:47813 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdJUJYX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 05:24:23 -0400
Received: by mail-wm0-f68.google.com with SMTP id t69so1630409wmt.2
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2017 02:24:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+Jmh7GptV5EZYWpQzHnT8Q1KDSZ-juQCfOr=VKFt4jyMOqFYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 20, 2017 at 05:13:39PM CEST, steven.lin1@broadcom.com wrote:
>On Fri, Oct 20, 2017 at 10:39 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Thu, Oct 19, 2017 at 09:17:05PM CEST, steven.lin1@broadcom.com wrote:
>>>Add support for permanent config parameter get/set commands. Used
>>>for parameters held in NVRAM, persistent device configuration.
>>>
>>>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>>>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>>>---
>>> include/net/devlink.h        |   3 +
>>> include/uapi/linux/devlink.h |  11 ++
>>> net/core/devlink.c           | 234 +++++++++++++++++++++++++++++++++++++++++++
>>> 3 files changed, 248 insertions(+)
>>>
>>>diff --git a/include/net/devlink.h b/include/net/devlink.h
>>>index b9654e1..bd64623 100644
>>>--- a/include/net/devlink.h
>>>+++ b/include/net/devlink.h
>>>@@ -270,6 +270,9 @@ struct devlink_ops {
>>>       int (*eswitch_inline_mode_set)(struct devlink *devlink, u8 inline_mode);
>>>       int (*eswitch_encap_mode_get)(struct devlink *devlink, u8 *p_encap_mode);
>>>       int (*eswitch_encap_mode_set)(struct devlink *devlink, u8 encap_mode);
>>>+      int (*perm_config_get)(struct devlink *devlink, u32 param, u32 *value);
>>>+      int (*perm_config_set)(struct devlink *devlink, u32 param, u32 value,
>>
>> Please use enum instead of "u32 param". Also, what would happen if the
>> value is >u32, like string for example? I believe we need to take it into
>> the consideration for the UAPI sake.
>>
>>
>
>Using enum instead of u32 param: ok, will do in v3, thanks.
>
>Value > u32:  In the RFC and v1 versions of the patch, each parameter
>was its own attribute, so could have its own type (u32, string,
>whatever).  In v2, trying to move to nested parameters w/ parameter
>being an enum, as requested, it seems to mean that the parameter value
>now must be defined as a specific type, so I went with u32.

Why? I have to be missing something. In the nest all is same as outside
of the nest.

Also, please see team_nl_cmd_options_set() where something similar is
done, for multiple option types.



>
>If we need to support strings or other types > u32, then the
>perm_config_value attribute will not be a fixed type, so can't be
>policy checked.  Or, I could go back to non-nested as in RFC/v1 case
>and have each parameter with its own type.
>
>> [...]
>>
>>
>>>+
>>>+static int devlink_nl_single_param_set(struct sk_buff *msg,
>>>+                                     struct devlink *devlink,
>>>+                                     u32 param, u32 value)
>>>+{
>>>+      u32 orig_value;
>>>+      u8 need_restart;
>>>+      int err;
>>>+      const struct devlink_ops *ops = devlink->ops;
>>>+      struct nlattr *cfgparam_attr;
>>
>> Reverse christmas tree please (this applies to all functions)
>
>Will do in v3, thanks.
>
>>
>>
>>>+
>>>+      /* First get current value of parameter */
>>>+      err = ops->perm_config_get(devlink, param, &orig_value);
>>
>> I'm missing why this is needed.
>>
>>
>>>+      if (err)
>>>+              return err;
>>>+
>>>+      /* Now set parameter */
>>>+      err = ops->perm_config_set(devlink, param, value, &need_restart);
>>>+      if (err)
>>>+              return err;
>>>+
>>>+      cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
>>>+      /* Update restart reqd - if any param needs restart, should be set */
>>>+      if (need_restart)
>>>+              err = nla_put_u8(msg,
>>>+                               DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED, 1);
>>>+
>>>+      /* Since set was successful, write attr back to msg with orig val */
>>>+      err = nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_PARAMETER, param);
>>>+      err = nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, orig_value);
>>
>> Why to write it back?
>
>In a response to the "RFC" version of this patch, you wrote:  "Also,
>we need to expose to the user the original value (currently being
>used) and the new one (to be used after driver re-instatiation)".
>
>I understood that to mean that we need to return the current/original
>value of the parameter (and the user knows the new value, since they
>are setting it).
>
>If I mis-interpreted that comment, then I'm happy to remove returning
>the original value to the user; it wasn't in there originally.
>
>>
>>
>>>+
>>>+      nla_nest_end(msg, cfgparam_attr);
>>>+
>>>+      return 0;
>>>+}
>>>+
>>>+static int devlink_nl_cmd_perm_config_set_doit(struct sk_buff *skb,
>>>+                                             struct genl_info *info)
>>>+{
>>>+      struct devlink *devlink = info->user_ptr[0];
>>>+      struct sk_buff *msg;
>>>+      void *hdr;
>>>+      struct nlattr *attr;
>>>+      int rem;
>>>+      int err;
>>>+      u8 restart_reqd = 0;
>>>+      struct nlattr *cfgparam_attr;
>>>+      struct nlattr *tb[DEVLINK_ATTR_MAX + 1];
>>>+      u32 param;
>>>+      u32 value;
>>>+
>>>+      if (!devlink->ops || !devlink->ops->perm_config_get ||
>>>+          !devlink->ops->perm_config_set)
>>>+              return -EOPNOTSUPP;
>>>+
>>>+      msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>>>+      if (!msg)
>>>+              return -ENOMEM;
>>>+
>>>+      hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
>>>+                        &devlink_nl_family, 0, DEVLINK_CMD_PERM_CONFIG_SET);
>>>+      if (!hdr) {
>>>+              err = -EMSGSIZE;
>>>+              goto nla_msg_failure;
>>>+      }
>>>+
>>>+      err = devlink_nl_put_handle(msg, devlink);
>>>+      if (err)
>>>+              goto nla_put_failure;
>>>+
>>>+      cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIGS);
>>>+
>>>+      nla_for_each_nested(attr, info->attrs[DEVLINK_ATTR_PERM_CONFIGS], rem) {
>>>+              err = nla_parse_nested(tb, DEVLINK_ATTR_MAX, attr,
>>>+                                     devlink_nl_policy, NULL);
>>>+              if (err)
>>>+                      goto nla_nest_failure;
>>>+
>>>+              if (!tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] ||
>>>+                  !tb[DEVLINK_ATTR_PERM_CONFIG_VALUE])
>>>+                      continue;
>>>+
>>>+              param = nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER]);
>>
>> You should check it the "param" value is withing the enum boundary.
>
>Will do in v3, I'll add a DEVLINK_PERM_CONFIG_MAX enum and check against that.
>
>>
>>
>>>+              value = nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_VALUE]);
>>>+              err = devlink_nl_single_param_set(msg, devlink, param,
>>>+                                                value);
>>>+              if (err)
>>>+                      goto nla_nest_failure;
>>
>> Wouldn't it make sense to rollback to old values if any of the config
>> parameters set would fail?
>
>Hmmmm....  We could do a rollback on failure of any of the set cmds,
>but I feel like that's more useful when the user doesn't know which
>sets failed. (i.e. if the response was just a boolean ok/not-ok
>response).
>
>If the user knows which sets worked and which didn't, then maybe no
>rollback is necessary.  So perhaps I change the code so that rather
>than falling out on error, it continues to try all the set cmds, but
>just returns the parameters which were successful.
>
>Is there a convention for this?  I'm fine either way.
>
>>
>>
>>>+      }
>>>+
>>>+      nla_nest_end(msg, cfgparam_attr);
>>>+
>>>+      if (restart_reqd) {
>>>+              err = nla_put_u8(msg, DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED,
>>>+                               restart_reqd);
>>>+              if (err)
>>>+                      goto nla_put_failure;
>>>+      }
>>>+
>>>+      genlmsg_end(msg, hdr);
>>>+      return genlmsg_reply(msg, info);
>>>+
>>>+nla_nest_failure:
>>>+      nla_nest_cancel(msg, cfgparam_attr);
>>>+nla_put_failure:
>>>+      genlmsg_cancel(msg, hdr);
>>>+nla_msg_failure:
>>>+      return err;
>>>+}
>>>+
>>> int devlink_dpipe_match_put(struct sk_buff *skb,
>>>                           struct devlink_dpipe_match *match)
>>> {
>>>@@ -2291,6 +2509,8 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
>>>       [DEVLINK_ATTR_ESWITCH_ENCAP_MODE] = { .type = NLA_U8 },
>>>       [DEVLINK_ATTR_DPIPE_TABLE_NAME] = { .type = NLA_NUL_STRING },
>>>       [DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] = { .type = NLA_U8 },
>>>+      [DEVLINK_ATTR_PERM_CONFIG_PARAMETER] = { .type = NLA_U32 },
>>>+      [DEVLINK_ATTR_PERM_CONFIG_VALUE] = { .type = NLA_U32 },
>>> };
>>>
>>> static const struct genl_ops devlink_nl_ops[] = {
>>>@@ -2451,6 +2671,20 @@ static const struct genl_ops devlink_nl_ops[] = {
>>>               .flags = GENL_ADMIN_PERM,
>>>               .internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>>>       },
>>>+      {
>>>+              .cmd = DEVLINK_CMD_PERM_CONFIG_GET,
>>>+              .doit = devlink_nl_cmd_perm_config_get_doit,
>>>+              .policy = devlink_nl_policy,
>>>+              .flags = GENL_ADMIN_PERM,
>>>+              .internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>>>+      },
>>>+      {
>>>+              .cmd = DEVLINK_CMD_PERM_CONFIG_SET,
>>>+              .doit = devlink_nl_cmd_perm_config_set_doit,
>>>+              .policy = devlink_nl_policy,
>>>+              .flags = GENL_ADMIN_PERM,
>>>+              .internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>>>+      },
>>> };
>>>
>>> static struct genl_family devlink_nl_family __ro_after_init = {
>>>--
>>>2.7.4
>>>
