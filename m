From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v3 01/10] devlink: Add permanent config parameter
 get/set operations
Date: Tue, 24 Oct 2017 22:14:19 -0400
Message-ID: <CA+Jmh7FGWf=WVsVZzsLHvZpeo81iG7gzerF94T8dtn5SpUj+VQ@mail.gmail.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
 <1508875962-39233-2-git-send-email-steven.lin1@broadcom.com> <AM0PR0502MB368378B824556ED230AF10C7BF470@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuval Mintz <yuvalm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:51568 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932347AbdJYCOk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 22:14:40 -0400
Received: by mail-qk0-f193.google.com with SMTP id 17so28719937qkq.8
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 19:14:40 -0700 (PDT)
In-Reply-To: <AM0PR0502MB368378B824556ED230AF10C7BF470@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 5:22 PM, Yuval Mintz <yuvalm@mellanox.com> wrote:
>> Add support for permanent config parameter get/set commands. Used
>> for persistent device configuration parameters.
>>
> ...
>> +     int (*perm_config_get)(struct devlink *devlink,
>> +                            enum devlink_perm_config_param param, u8
>> type,
>> +                            void *value);
>> +     int (*perm_config_set)(struct devlink *devlink,
>> +                            enum devlink_perm_config_param param, u8
>> type,
>> +                            void *value, u8 *restart_reqd);
>>  };
>> +static int devlink_nl_single_param_get(struct sk_buff *msg,
>> +                                    struct devlink *devlink,
>> +                                    u32 param, u8 type)
>> +{
>> +     const struct devlink_ops *ops = devlink->ops;
>> +     struct nlattr *param_attr;
>> +     void *value;
>> +     u32 val;
>> +     int err;
>> +
>> +     /* Allocate buffer for parameter value */
>> +     switch (type) {
>> +     case NLA_U8:
>> +             value = kmalloc(sizeof(u8), GFP_KERNEL);
>> +             break;
>> +     case NLA_U16:
>> +             value = kmalloc(sizeof(u16), GFP_KERNEL);
>> +             break;
>> +     case NLA_U32:
>> +             value = kmalloc(sizeof(u32), GFP_KERNEL);
>> +             break;
>> +     default:
>> +             return -EINVAL; /* Unsupported Type */
>> +     }
>> +
>> +     if (!value)
>> +             return -ENOMEM;
>> +
>> +     err = ops->perm_config_get(devlink, param, type, value);
>> +     if (err)
>> +             return err;
>
> I suspect this logic might be risky - its dependent on the driver to cast the
> 'value' into the proper type or else, E.g., the following switch might break
> for BE platforms.
> Is there any reason to have the devlink <-> driver API be based on void*
> and not on some typed data [of sufficient size]?
> ...
>> +     switch (type) {
>> +     case NLA_U8:
>> +             val = *((u8 *)value);
>> +             if (nla_put_u8(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE,
>> val))
>> +                     goto nest_err;
>> +             break;
>> +     case NLA_U16:
>> +             val = *((u16 *)value);
>> +             if (nla_put_u16(msg,
>> DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
>> +                     goto nest_err;
>> +             break;
>> +     case NLA_U32:
>> +             val = *((u32 *)value);
>> +             if (nla_put_u32(msg,
>> DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
>> +                     goto nest_err;
>> +             break;
>> +     }

Why might this break on a BE system?  It's not as though driver will
be compiled LE and kernel BE or vice versa - as long as driver and
kernel are same endian-ness, I would think it should be okay?

In general, the issue is that the parameter could be any of the
netlink types (per Jiri's suggestion to the previous version of this
patch).  So, we allocate some space, tell the driver the type we're
expecting (the type argument to the perm_config_get() function), and
yes, we rely on the driver to write something of the type we request
to the pointer we provide.  Are you suggesting defining a union of
U8/U16/U32, and passing a pointer to that for the driver to fill in?
The issue is that whatever the types we support now, we want future
parameters to be able to be of arbitrary types.  Defining the
interface to use the void pointer means that some future parameter can
be of some other type, without having to update all the drivers using
this API...

Or did I misunderstand your suggestion?
