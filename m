From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v5 01/10] devlink: Add permanent config parameter
 get/set operations
Date: Mon, 30 Oct 2017 16:17:01 -0400
Message-ID: <CA+Jmh7Hu-NQ6Ak2H=TQRfBK3DXtRQ57OuoHwfWbaRB1LPPgNtA@mail.gmail.com>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
 <1509374776-45869-2-git-send-email-steven.lin1@broadcom.com> <20171030170301.GE4115@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>,
        Yuval Mintz <yuvalm@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:48069 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752062AbdJ3URW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 16:17:22 -0400
Received: by mail-qk0-f196.google.com with SMTP id m189so17753413qke.4
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 13:17:22 -0700 (PDT)
In-Reply-To: <20171030170301.GE4115@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 1:03 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Oct 30, 2017 at 03:46:07PM CET, steven.lin1@broadcom.com wrote:
>>Add support for permanent config parameter get/set commands. Used
>>for persistent device configuration parameters.
>>
>>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>
> In general, I don't like how you use netlink. Please see the rest of
> this code. We should do things in the common way. More info inlined.
>
>
> [...]
>
>>
>>+/* Permanent config parameters */
>>+enum devlink_perm_config_param {
>>+      __DEVLINK_PERM_CONFIG_MAX,
>>+      DEVLINK_PERM_CONFIG_MAX = __DEVLINK_PERM_CONFIG_MAX - 1
>>+};
>>+
>>+/* Permanent config types */
>>+enum devlink_perm_config_type {
>>+      DEVLINK_PERM_CONFIG_TYPE_UNSPEC,
>
> You should not need this. Type should be always specified.

This was an attempt to align enum devlink_perm_config_type with the
NLA_* enums in netlink.h, which include the unspecified type.  I will
remove the unspecified enum, but it seems like having multiple type
enums that are not aligned with each other could be problematic.

>
>
>>+      DEVLINK_PERM_CONFIG_TYPE_U8,
>>+      DEVLINK_PERM_CONFIG_TYPE_U16,
>>+      DEVLINK_PERM_CONFIG_TYPE_U32,
>>+};
>
> This definitelly should not be in uapi header.
>
>
>>+
>>+/* Permanent config value */
>>+union devlink_perm_config_value {
>>+      __u8    value8;
>>+      __u16   value16;
>>+      __u32   value32;
>>+};
>
> This definitelly should not be in uapi header.

Ok, will move these.

>
>
>
>>+
>> #endif /* _UAPI_LINUX_DEVLINK_H_ */
>
> [...]
>
>
>>+static int devlink_nl_config_get_fill(struct sk_buff *msg,
>>+                                    struct devlink *devlink,
>>+                                    enum devlink_command cmd,
>>+                                    struct genl_info *info)
>>+{
>>+      struct nlattr *tb[DEVLINK_ATTR_MAX + 1];
>>+      enum devlink_perm_config_param param;
>>+      enum devlink_perm_config_type type;
>>+      struct nlattr *cfgparam_attr;
>>+      struct nlattr *attr;
>>+      void *hdr;
>>+      int err;
>>+      int rem;
>>+
>>+      hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
>>+                        &devlink_nl_family, 0, cmd);
>>+      if (!hdr)
>>+              return -EMSGSIZE;
>>+
>>+      err = devlink_nl_put_handle(msg, devlink);
>>+      if (err)
>>+              goto nla_put_failure;
>>+
>>+      if (!info->attrs[DEVLINK_ATTR_PERM_CONFIGS]) {
>>+              err = -EINVAL;
>>+              goto nla_put_failure;
>>+      }
>>+
>>+      cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIGS);
>>+
>>+      nla_for_each_nested(attr, info->attrs[DEVLINK_ATTR_PERM_CONFIGS],
>
>
> Okay. So I have to know what is in kernel in order to get the value.
>
> We need a dump operation. In fact, why can't we just have dump operation?

Ok, I can add a dump operation.

>
>
>
>>+                          rem) {
>>+              err = nla_parse_nested(tb, DEVLINK_ATTR_MAX, attr,
>>+                                     devlink_nl_policy, NULL);
>>+              if (err)
>>+                      goto nla_nest_failure;
>>+              if (!tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] ||
>>+                  !tb[DEVLINK_ATTR_PERM_CONFIG_TYPE])
>>+                      continue;
>>+
>>+              param = nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER]);
>>+              type = nla_get_u8(tb[DEVLINK_ATTR_PERM_CONFIG_TYPE]);
>
> So to get parameter, I have to specify a type? What if I specify wrong
> type? That is wrong. The type should be read attr for get.

For set, seems like the user would need to know and set the type.  So,
I was just doing the same for get().  But I can make the type a read
attribute for get.

>
> You should have a param -> type table and always use that.
>
>
>>+              if (param > DEVLINK_PERM_CONFIG_MAX ||
>>+                  type > NLA_TYPE_MAX) {
>>+                      continue;
>>+              }
>>+              /* Note if single_param_get fails, that param won't be in
>>+               * response msg, so caller will know which param(s) failed to
>>+               * get.
>>+               */
>>+              devlink_nl_single_param_get(msg, devlink, param, type);
>>+      }
>>+
>>+      nla_nest_end(msg, cfgparam_attr);
>>+
>>+      genlmsg_end(msg, hdr);
>>+      return 0;
>>+
>>+nla_nest_failure:
>>+      nla_nest_cancel(msg, cfgparam_attr);
>>+nla_put_failure:
>
>
> You should make this multipart aware. If config parameters won't fit
> into a single skb, you have to allocate another one. See devlink_dpipe_tables_fill
> as an example how to do it. It is important to have this from the
> beginning as the userspace knows to expect multipart message.

In a response to a similar comment from v2, I tried to describe why I
felt multipart messages wouldn't be required.  There was no response
to my reply, so I thought that my argument was accepted.  Apparently
not, so I will add multipart support.

>
>
>
>>+      genlmsg_cancel(msg, hdr);
>>+      return err;
>>+}
>>+
>>+static int devlink_nl_cmd_perm_config_get_doit(struct sk_buff *skb,
>>+                                             struct genl_info *info)
>>+{
>>+      struct devlink *devlink = info->user_ptr[0];
>>+      struct sk_buff *msg;
>>+      int err;
>>+
>>+      if (!devlink->ops || !devlink->ops->perm_config_get)
>>+              return -EOPNOTSUPP;
>>+
>>+      msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>>+      if (!msg)
>>+              return -ENOMEM;
>>+
>>+      err = devlink_nl_config_get_fill(msg, devlink,
>>+                                       DEVLINK_CMD_PERM_CONFIG_GET, info);
>>+
>>+      if (err) {
>>+              nlmsg_free(msg);
>>+              return err;
>>+      }
>>+
>>+      return genlmsg_reply(msg, info);
>>+}
>>+
>>+static int devlink_nl_single_param_set(struct sk_buff *msg,
>>+                                     struct devlink *devlink,
>>+                                     enum devlink_perm_config_param param,
>>+                                     enum devlink_perm_config_type type,
>>+                                     union devlink_perm_config_value *value)
>>+{
>>+      const struct devlink_ops *ops = devlink->ops;
>>+      struct nlattr *cfgparam_attr;
>>+      bool need_restart;
>>+      int err;
>>+
>>+      /* Now set parameter */
>>+      err = ops->perm_config_set(devlink, param, type, value, &need_restart);
>>+      if (err)
>>+              return err;
>>+
>>+      cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
>>+      /* Update restart reqd - if any param needs restart, should be set */
>>+      if (need_restart) {
>
> You should propagate this out so the caller would fill it to the
> message. This is a global thing, not per-param, shoult not be nested.

The idea here was that some parameters may require a restart and some
may not.  By reporting it per param, the caller knows which parameter
have taken effect immediately.

But, per your comment below, I will no longer report back which
parameters were successfully set (and thus also not return the
restart_required information), and instead just put any extra needed
information into extack.

>
>
>
>>+              err = nla_put_flag(msg,
>>+                               DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED);
>>+              if (err)
>>+                      goto nest_fail;
>>+      }
>>+
>>+      /* Since set was successful, write attr back to msg */
>>+      err = nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_PARAMETER, param);
>>+      if (err)
>>+              goto nest_fail;
>>+
>>+      nla_nest_end(msg, cfgparam_attr);
>>+
>>+      return 0;
>>+
>>+nest_fail:
>>+      nla_nest_cancel(msg, cfgparam_attr);
>>+      return err;
>>+}
>>+
>>+static int devlink_nl_cmd_perm_config_set_doit(struct sk_buff *skb,
>>+                                             struct genl_info *info)
>>+{
>>+      struct devlink *devlink = info->user_ptr[0];
>>+      struct nlattr *tb[DEVLINK_ATTR_MAX + 1];
>>+      union devlink_perm_config_value value;
>>+      enum devlink_perm_config_param param;
>>+      enum devlink_perm_config_type type;
>>+      struct nlattr *cfgparam_attr;
>>+      struct sk_buff *msg;
>>+      struct nlattr *attr;
>>+      void *hdr;
>>+      int rem;
>>+      int err;
>>+
>>+      if (!devlink->ops || !devlink->ops->perm_config_get ||
>>+          !devlink->ops->perm_config_set)
>>+              return -EOPNOTSUPP;
>>+
>>+      msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
>>+      if (!msg)
>>+              return -ENOMEM;
>>+
>>+      hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
>>+                        &devlink_nl_family, 0, DEVLINK_CMD_PERM_CONFIG_SET);
>>+      if (!hdr) {
>>+              err = -EMSGSIZE;
>>+              goto nla_msg_failure;
>>+      }
>>+
>>+      err = devlink_nl_put_handle(msg, devlink);
>>+      if (err)
>>+              goto nla_put_failure;
>>+
>>+      cfgparam_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIGS);
>>+
>>+      nla_for_each_nested(attr, info->attrs[DEVLINK_ATTR_PERM_CONFIGS], rem) {
>>+              err = nla_parse_nested(tb, DEVLINK_ATTR_MAX, attr,
>>+                                     devlink_nl_policy, NULL);
>>+              if (err)
>>+                      goto nla_nest_failure;
>>+
>>+              if (!tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER] ||
>>+                  !tb[DEVLINK_ATTR_PERM_CONFIG_TYPE] ||
>>+                  !tb[DEVLINK_ATTR_PERM_CONFIG_VALUE])
>>+                      continue;
>>+
>>+              param = nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_PARAMETER]);
>>+              type = nla_get_u8(tb[DEVLINK_ATTR_PERM_CONFIG_TYPE]);
>>+              if (param > DEVLINK_PERM_CONFIG_MAX ||
>>+                  type > NLA_TYPE_MAX) {
>>+                      continue;
>>+              }
>>+
>>+              switch (type) {
>>+              case DEVLINK_PERM_CONFIG_TYPE_U8:
>>+                      value.value8 =
>>+                              nla_get_u8(tb[DEVLINK_ATTR_PERM_CONFIG_VALUE]);
>>+                      break;
>>+              case DEVLINK_PERM_CONFIG_TYPE_U16:
>>+                      value.value16 =
>>+                              nla_get_u16(tb[DEVLINK_ATTR_PERM_CONFIG_VALUE]);
>>+                      break;
>>+              case DEVLINK_PERM_CONFIG_TYPE_U32:
>>+                      value.value32 =
>>+                              nla_get_u32(tb[DEVLINK_ATTR_PERM_CONFIG_VALUE]);
>>+                      break;
>>+              default:
>>+                      continue;
>>+              }
>>+
>>+              /* Note if single_param_set fails, that param won't be in
>>+               * response msg, so caller will know which param(s) failed to
>>+               * set.
>
> No. You should not send the params back on set operation. That is wrong.
> You should use extact in order to tell anything useful to the user.

Ok, see above.

>
>
>>+               */
>>+              devlink_nl_single_param_set(msg, devlink, param, type, &value);
>>+      }
>>+
>>+      nla_nest_end(msg, cfgparam_attr);
>>+
>>+      genlmsg_end(msg, hdr);
>>+      return genlmsg_reply(msg, info);
>>+
>>+nla_nest_failure:
>>+      nla_nest_cancel(msg, cfgparam_attr);
>>+nla_put_failure:
>>+      genlmsg_cancel(msg, hdr);
>>+nla_msg_failure:
>>+      return err;
>>+}
>>+
>> int devlink_dpipe_match_put(struct sk_buff *skb,
>>                           struct devlink_dpipe_match *match)
>> {
>>@@ -2291,6 +2568,8 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
>>       [DEVLINK_ATTR_ESWITCH_ENCAP_MODE] = { .type = NLA_U8 },
>>       [DEVLINK_ATTR_DPIPE_TABLE_NAME] = { .type = NLA_NUL_STRING },
>>       [DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] = { .type = NLA_U8 },
>>+      [DEVLINK_ATTR_PERM_CONFIG_PARAMETER] = { .type = NLA_U32 },
>>+      [DEVLINK_ATTR_PERM_CONFIG_TYPE] = { .type = NLA_U8 },
>> };
>>
>> static const struct genl_ops devlink_nl_ops[] = {
>>@@ -2451,6 +2730,20 @@ static const struct genl_ops devlink_nl_ops[] = {
>>               .flags = GENL_ADMIN_PERM,
>>               .internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>>       },
>>+      {
>>+              .cmd = DEVLINK_CMD_PERM_CONFIG_GET,
>>+              .doit = devlink_nl_cmd_perm_config_get_doit,
>
> As I said, you need dumpit.
>
>
>
>>+              .policy = devlink_nl_policy,
>>+              .flags = GENL_ADMIN_PERM,
>>+              .internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>>+      },
>>+      {
>>+              .cmd = DEVLINK_CMD_PERM_CONFIG_SET,
>>+              .doit = devlink_nl_cmd_perm_config_set_doit,
>>+              .policy = devlink_nl_policy,
>>+              .flags = GENL_ADMIN_PERM,
>>+              .internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
>>+      },
>> };
>>
>> static struct genl_family devlink_nl_family __ro_after_init = {
>>--
>>2.7.4
>>
