From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH 1/7] devlink: Add permanent config parameter get/set operations
Date: Wed, 18 Oct 2017 11:46:01 -0400
Message-ID: <CA+Jmh7F17i+K6xG7hcqkRxO15wDmmFcJuBbzwB+h8p4dyBH=mQ@mail.gmail.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-2-git-send-email-steven.lin1@broadcom.com> <CAJ3xEMgzy+hm5zeOEHGewpQoxc_3t2z3O49rFOC7hLhUa9Rt-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:44856 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdJRPqX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:46:23 -0400
Received: by mail-qt0-f196.google.com with SMTP id 8so10814322qtv.1
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 08:46:22 -0700 (PDT)
In-Reply-To: <CAJ3xEMgzy+hm5zeOEHGewpQoxc_3t2z3O49rFOC7hLhUa9Rt-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 11:22 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Oct 17, 2017 at 11:44 PM, Steve Lin <steven.lin1@broadcom.com>
> wrote:
>>
>> Add support for permanent config parameter get/set commands. Used
>> for parameters held in NVRAM, persistent device configuration.
>> The config_get() and config_set() operations operate as expected, but
>> note that the driver implementation of the config_set() operation can
>> indicate whether a restart is necessary for the setting to take
>> effect.  This indication of a necessary restart is passed via the
>> DEVLINK_ATTR_PERM_CFG_RESTART_REQUIRED attribute.
>>
>> First set of parameters defined are PCI SR-IOV and per-VF
>> configuration:
>>
>> DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED: Enable SR-IOV capability.
>> DEVLINK_ATTR_PERM_CFG_NUM_VF_PER_PF: Maximum number of VFs per PF, in
>> SR-IOV mode.
>> DEVLINK_ATTR_PERM_CFG_MAX_NUM_PF_MSIX_VECT: Maximum number of
>> MSI-X vectors assigned per PF.
>> DEVLINK_ATTR_PERM_CFG_MSIX_VECTORS_PER_VF: Number of MSI-X vectors
>> allocated per VF.
>>
>> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>> Acked-by: Andy Gospodarek <gospo@broadcom.com>
>> ---
>>  include/net/devlink.h        |   4 +
>>  include/uapi/linux/devlink.h |  20 ++++
>>  net/core/devlink.c           | 266
>> +++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 290 insertions(+)
>>
>> diff --git a/include/net/devlink.h b/include/net/devlink.h
>> index b9654e1..952966c 100644
>> --- a/include/net/devlink.h
>> +++ b/include/net/devlink.h
>> @@ -270,6 +270,10 @@ struct devlink_ops {
>>         int (*eswitch_inline_mode_set)(struct devlink *devlink, u8
>> inline_mode);
>>         int (*eswitch_encap_mode_get)(struct devlink *devlink, u8
>> *p_encap_mode);
>>         int (*eswitch_encap_mode_set)(struct devlink *devlink, u8
>> encap_mode);
>> +       int (*config_get)(struct devlink *devlink, enum devlink_attr attr,
>> +                         u32 *value);
>> +       int (*config_set)(struct devlink *devlink, enum devlink_attr attr,
>> +                         u32 value, u8 *restart_reqd);
>>  };
>>
>>  static inline void *devlink_priv(struct devlink *devlink)
>> diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>> index 0cbca96..34de44d 100644
>> --- a/include/uapi/linux/devlink.h
>> +++ b/include/uapi/linux/devlink.h
>> @@ -70,6 +70,9 @@ enum devlink_command {
>>         DEVLINK_CMD_DPIPE_HEADERS_GET,
>>         DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
>>
>> +       DEVLINK_CMD_CONFIG_GET,
>> +       DEVLINK_CMD_CONFIG_SET,
>> +
>>         /* add new commands above here */
>>         __DEVLINK_CMD_MAX,
>>         DEVLINK_CMD_MAX = __DEVLINK_CMD_MAX - 1
>> @@ -202,6 +205,23 @@ enum devlink_attr {
>>
>>         DEVLINK_ATTR_ESWITCH_ENCAP_MODE,        /* u8 */
>>
>> +       /* Permanent Configuration Parameters */
>> +       DEVLINK_ATTR_PERM_CFG,                          /* nested */
>> +
>> +       /* When config doesn't take effect until next reboot (config
>> +        * just changed NVM which isn't read until boot, for example),
>> +        * this attribute should be set by the driver.
>> +        */
>> +       DEVLINK_ATTR_PERM_CFG_RESTART_REQUIRED,         /* u8 */
>> +       DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED,            /* u8 */
>> +       DEVLINK_ATTR_PERM_CFG_FIRST = DEVLINK_ATTR_PERM_CFG_SRIOV_ENABLED,
>
>
> ??? can you explain /   document this one?

I attempted to explain in the patch commit message, but I will try to
add more detail when I resubmit, with each attribute in a separate
patch.

>
> I would join Jiri's request to have patch #1 not defining any attributes,
> review will be much
> easier and robust.

Ok, I'll do that when I resubmit.

>
> Talking on attributes... what is your plan for vendor specific attributes?
>

They will be added just like common attributes, any given driver
doesn't have to support all attributes.

Steve
