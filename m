From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v2 1/6] devlink: Add permanent config parameter
 get/set operations
Date: Fri, 20 Oct 2017 09:11:24 -0400
Message-ID: <CA+Jmh7Gdud=T47iK=ZjgoXvXj+frBgP=HcvGDWHzJxUzN9L=tA@mail.gmail.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-2-git-send-email-steven.lin1@broadcom.com> <AM0PR0502MB3683FB1536D1A204E5D1369EBF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Yuval Mintz <yuvalm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:53272 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751798AbdJTNLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 09:11:45 -0400
Received: by mail-qt0-f194.google.com with SMTP id n61so18332474qte.10
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 06:11:44 -0700 (PDT)
In-Reply-To: <AM0PR0502MB3683FB1536D1A204E5D1369EBF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 4:21 PM, Yuval Mintz <yuvalm@mellanox.com> wrote:
>> Subject: [PATCH net-next v2 1/6] devlink: Add permanent config parameter
>> get/set operations
>>
>> Add support for permanent config parameter get/set commands. Used
>> for parameters held in NVRAM, persistent device configuration.
>
> Given some of the attributes aren't Boolean, what about an API that
> allows the user to learn of supported values per option?
> Otherwise only way for configuring some of them would be trial & error.

Interesting suggestion.  There's a couple of places where this could
be a factor.  (1) When a user wants to know what values are
defined/available in the API, and (2) When the user wants to know what
values are supported by a specific driver/device.

The intention for (1) is to push that into userspace.  The userspace
devlink tool patches I am working on (not yet submitted) essentially
mirror the config parameters and their options, with string "keywords"
associated with each parameter and option, since it's the userspace
app that will be parsing the command line strings and converting to
API enums.  So the userspace app can provide the list of
parameters/options it supports, which could be a subset of what's
available in the API.

For (2), currently there is no mechanism other than trial/error as you
suggest (up to driver to either return an error or else make use of
the value specified by the user).  We could contemplate adding such a
mechanism, but it's a little complicated as some options take a range
(i.e. # of VFs per PF for example), and others may take one of a set
of enumerated values (pre-boot link speed for example).

To clarify, are you suggesting some mechanism to allow a driver to
report which parameters and options it supports (case (2))?  Or are
you suggesting something in the kernel API to handle case (1) above?

>
>>
>> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>> Acked-by: Andy Gospodarek <gospo@broadcom.com>
>> ---
>>  include/net/devlink.h        |   3 +
>>  include/uapi/linux/devlink.h |  11 ++
>>  net/core/devlink.c           | 234
>> +++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 248 insertions(+)
>>
>> diff --git a/include/net/devlink.h b/include/net/devlink.h
>> index b9654e1..bd64623 100644
>> --- a/include/net/devlink.h
>> +++ b/include/net/devlink.h
>> @@ -270,6 +270,9 @@ struct devlink_ops {
>>       int (*eswitch_inline_mode_set)(struct devlink *devlink, u8
>> inline_mode);
>>       int (*eswitch_encap_mode_get)(struct devlink *devlink, u8
>> *p_encap_mode);
>>       int (*eswitch_encap_mode_set)(struct devlink *devlink, u8
>> encap_mode);
>> +     int (*perm_config_get)(struct devlink *devlink, u32 param, u32
>> *value);
>> +     int (*perm_config_set)(struct devlink *devlink, u32 param, u32
>> value,
>> +                            u8 *restart_reqd);
>>  };
>>
>>  static inline void *devlink_priv(struct devlink *devlink)
>> diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>> index 0cbca96..47cc584 100644
>> --- a/include/uapi/linux/devlink.h
>> +++ b/include/uapi/linux/devlink.h
>> @@ -70,6 +70,10 @@ enum devlink_command {
>>       DEVLINK_CMD_DPIPE_HEADERS_GET,
>>       DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
>>
>> +     /* Permanent (NVRAM) device config get/set */
>> +     DEVLINK_CMD_PERM_CONFIG_GET,
>> +     DEVLINK_CMD_PERM_CONFIG_SET,
>> +
>>       /* add new commands above here */
>>       __DEVLINK_CMD_MAX,
>>       DEVLINK_CMD_MAX = __DEVLINK_CMD_MAX - 1
>> @@ -202,6 +206,13 @@ enum devlink_attr {
>>
>>       DEVLINK_ATTR_ESWITCH_ENCAP_MODE,        /* u8 */
>>
>> +     /* Permanent Configuration Parameters */
>> +     DEVLINK_ATTR_PERM_CONFIGS,                      /* nested */
>> +     DEVLINK_ATTR_PERM_CONFIG,                       /* nested */
>> +     DEVLINK_ATTR_PERM_CONFIG_PARAMETER,             /* u32 */
>> +     DEVLINK_ATTR_PERM_CONFIG_VALUE,                 /*
>> u32 */
>> +     DEVLINK_ATTR_PERM_CONFIG_RESTART_REQUIRED,      /* u8 */
>> +
>>       /* add new attributes above here, update the policy in devlink.c */
>>
>>       __DEVLINK_ATTR_MAX,
>> diff --git a/net/core/devlink.c b/net/core/devlink.c
>> index 7d430c1..c2cc7c6 100644
>> --- a/net/core/devlink.c
>> +++ b/net/core/devlink.c
>> @@ -1566,6 +1566,224 @@ static int
>> devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
>>       return 0;
>>  }
>>
>> +static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1];
>> +
>> +static int devlink_nl_single_param_get(struct sk_buff *msg,
>> +                                    struct devlink *devlink,
>> +                                    uint32_t param)
>> +{
>> +     u32 value;
>> +     int err;
>> +     const struct devlink_ops *ops = devlink->ops;
>> +     struct nlattr *param_attr;
>> +
>> +     err = ops->perm_config_get(devlink, param, &value);
>> +     if (err)
>> +             return err;
>> +
>> +     param_attr = nla_nest_start(msg, DEVLINK_ATTR_PERM_CONFIG);
>> +     nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_PARAMETER,
>> param);
>> +     nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, value);
>> +     nla_nest_end(msg, param_attr);
>> +
>> +     return 0;
>> +}
>> +
>> +static int devlink_nl_config_get_fill(struct sk_buff *msg,
>> +                                   struct devlink *devlink,
>> +                                   enum devlink_command cmd,
>> +                                   struct genl_info *info)
>> +{
>> +     void *hdr;
>> +     int err;
>> +     struct nlattr *attr;
>> +     int param_count = 0;
>> +     struct nlattr *cfgparam_attr;
>> +     int rem;
>> +     struct nlattr *tb[DEVLINK_ATTR_MAX + 1];
>> +     u32 param;
>> +
>> +     hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
>> +                       &devlink_nl_family, 0, cmd);
>> +     if (!hdr) {
>> +             err = -EMSGSIZE;
>> +             goto nla_msg_failure;
>> +     }
>> +
>> +     err = devlink_nl_put_handle(msg, devlink);
>> +     if (err)
>> +             goto nla_put_failure;
>> +
>> +     if (!info->attrs[DEVLINK_ATTR_PERM_CONFIGS]) {
>> +             /* No configuration parameters */
>> +             goto nla_put_failure;
>> +     }
>> +
>> +     cfgparam_attr = nla_nest_start(msg,
>> DEVLINK_ATTR_PERM_CONFIGS);
>> +
>> +     nla_for_each_nested(attr, info-
>> >attrs[DEVLINK_ATTR_PERM_CONFIGS],
>> +                         rem) {
> Isn't it possible that a response for a single request for multiple ATTRs
> wouldn't fit in a single message?
>

Hmm... Given the small size and relatively small total number of these
attributes, even when additional drivers add their own, I think it's
unlikely that a single request would require a multipart message, even
in the event it's requesting all of the parameters for a given device.
I guess we could support NLM_F_MULTI type messages, but it didn't seem
necessary to me for this application?  Thoughts?


>> +             if (err)
>> +                     goto nla_nest_failure;
>> +             param_count++;
>
> Looks like an unused parameter
>> +
>> +     if (restart_reqd) {
>
> Doesn't seem like you're ever setting it.
> A leftover from when this was an attribute of the configs instead
> of per-config perhaps?

Thanks for catching these two issues - you're right, they are leftover
from the v1 implementation; apologies for not catching them in v2.
Will fix in v3.
