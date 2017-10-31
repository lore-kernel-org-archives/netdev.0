From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 06/10] bnxt: Add devlink support for config
 get/set
Date: Tue, 31 Oct 2017 08:19:56 +0100
Message-ID: <20171031071956.GC1972@nanopsycho.orion>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
 <1509374776-45869-7-git-send-email-steven.lin1@broadcom.com>
 <20171030173505.GH4115@nanopsycho.orion>
 <CA+Jmh7GuFAV2FRBFRbYixuLVJBOh81D2anhgb41FZSKD-tGtkQ@mail.gmail.com>
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
Received: from mail-wm0-f67.google.com ([74.125.82.67]:54523 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751798AbdJaHT7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 03:19:59 -0400
Received: by mail-wm0-f67.google.com with SMTP id r68so20937309wmr.3
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 00:19:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+Jmh7GuFAV2FRBFRbYixuLVJBOh81D2anhgb41FZSKD-tGtkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 30, 2017 at 09:20:17PM CET, steven.lin1@broadcom.com wrote:
>On Mon, Oct 30, 2017 at 1:35 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Mon, Oct 30, 2017 at 03:46:12PM CET, steven.lin1@broadcom.com wrote:
>>>Implements get and set of configuration parameters using new devlink
>>>config get/set API. Parameters themselves defined in later patches.
>>>
>>>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>>>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>>>---
>>> drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 258 +++++++++++++++++++++-
>>> drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h |  17 ++
>>> 2 files changed, 263 insertions(+), 12 deletions(-)
>>>
>>>diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
>>>index 402fa32..deb24e0 100644
>>
>> [...]
>>
>>>+static int bnxt_dl_perm_config_set(struct devlink *devlink,
>>>+                                 enum devlink_perm_config_param param,
>>>+                                 enum devlink_perm_config_type type,
>>>+                                 union devlink_perm_config_value *value,
>>>+                                 bool *restart_reqd)
>>>+{
>>>+      struct bnxt *bp = bnxt_get_bp_from_dl(devlink);
>>>+      struct bnxt_drv_cfgparam *entry = NULL;
>>>+      u32 value_int;
>>>+      u32 bytesize;
>>>+      int idx = 0;
>>>+      int ret = 0;
>>>+      u16 val16;
>>>+      u8 val8;
>>>+      int i;
>>>+
>>>+      *restart_reqd = 0;
>>>+
>>>+      /* Find parameter in table */
>>>+      for (i = 0; i < BNXT_NUM_DRV_CFGPARAM; i++) {
>>>+              if (param == bnxt_drv_cfgparam_list[i].param) {
>>>+                      entry = &bnxt_drv_cfgparam_list[i];
>>>+                      break;
>>>+              }
>>>+      }
>>>+
>>>+      /* Not found */
>>>+      if (!entry)
>>>+              return -EINVAL;
>>>+
>>>+      /* Check to see if this func type can access variable */
>>>+      if (BNXT_PF(bp) && !(entry->func & BNXT_DRV_PF))
>>>+              return -EOPNOTSUPP;
>>>+      if (BNXT_VF(bp) && !(entry->func & BNXT_DRV_VF))
>>>+              return -EOPNOTSUPP;
>>>+
>>>+      /* If parameter is per port or function, compute index */
>>>+      if (entry->appl == BNXT_DRV_APPL_PORT) {
>>>+              idx = bp->pf.port_id;
>>>+      } else if (entry->appl == BNXT_DRV_APPL_FUNCTION) {
>>>+              if (BNXT_PF(bp))
>>>+                      idx = bp->pf.fw_fid - BNXT_FIRST_PF_FID;
>>>       }
>>>
>>>+      bytesize = roundup(entry->bitlength, BITS_PER_BYTE) / BITS_PER_BYTE;
>>>+
>>>+      /* Type expected by device may or may not be the same as type passed
>>>+       * in from devlink API.  So first convert to an interval u32 value,
>>>+       * then to type needed by device.
>>>+       */
>>>+      if (type == DEVLINK_PERM_CONFIG_TYPE_U8) {
>>>+              value_int = value->value8;
>>>+      } else if (type == DEVLINK_PERM_CONFIG_TYPE_U16) {
>>>+              value_int = value->value16;
>>>+      } else if (type == DEVLINK_PERM_CONFIG_TYPE_U32) {
>>>+              value_int = value->value32;
>>>+      } else {
>>>+              /* Unsupported type */
>>>+              return -EINVAL;
>>>+      }
>>>+
>>>+      if (bytesize == 1) {
>>>+              val8 = value_int;
>>
>>>+              ret = bnxt_nvm_write(bp, entry->nvm_param, idx, &val8,
>>>+                                   entry->bitlength);
>>>+      } else if (bytesize == 2) {
>>>+              val16 = value_int;
>>>+              ret = bnxt_nvm_write(bp, entry->nvm_param, idx, &val16,
>>>+                                   entry->bitlength);
>>>+      } else {
>>>+              ret = bnxt_nvm_write(bp, entry->nvm_param, idx, &value_int,
>>>+                                   entry->bitlength);
>>>+      }
>>>+
>>>+      /* Restart required for all nvm parameter writes */
>>>+      *restart_reqd = 1;
>>>+
>>>+      return ret;
>>>+}
>>
>> I don't like this swissknife approach for setters and getters. It's
>> messy, and hard to read. There should be clean get/set pair function
>> per parameter defined in array.
>
>The advantage of the swiss kinfe approach is that you don't have a
>large number of almost-identical functions (i.e. any "set" that
>operates on a u32 will be doing essentially the exact same thing) in
>the driver, which could lead to code bloat and also make it harder to
>catch errors (since any bug that may creep in during the copy/paste to
>make so many functions will only be caught when that specific
>parameter is set, rather than when any parameter is set).

You can always do some common functions to do the work. But if gives the
driver freedom, unlike the swissknife approach.


>
>In general, I very much appreciate the thorough review.  I do feel,
>though, like some of this basic architectural stuff could have been
>addressed more efficiently in v1 or v2, rather than v5.  I admit that
>when the comments to v4 included suggestions like removing extra
>spaces in the commit message, I was thinking that we were close to
>reaching consensus. :)

Yeah, I noticed this just now.

>
>I just want to make sure that you feel that the overall goal of this
>effort is worthwhile - I will make the changes you've suggested here
>and in the other replies to v5, but I am hopeful that v6 does not
>result in another set of big architectural changes.

Hopefully.


>
>> Something like:
>>
>> static int bnxt_param_sriov_enabled_get(struct devlink *devlink, bool *p_value)
>> {
>>         ...
>> }
>>
>> static int bnxt_param_sriov_enabled_set(struct devlink *devlink, bool value,
>>                                         bool *restart_reqd)
>> {
>>         ...
>> }
>>
>> static int bnxt_param_num_vf_per_pf_get(struct devlink *devlink, u32 *p_value)
>> {
>>         ...
>> }
>>
>> static int bnxt_param_num_vf_per_pf_set(struct devlink *devlink, u32 value,
>>                                         bool *restart_reqd)
>> {
>>         ...
>> }
>>
>> static const struct devlink_config_param bnxt_params[] = {
>>         DEVLINK_CONFIG_PARAM_BOOL(DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
>>                                   bnxt_param_sriov_enabled_get,
>>                                   bnxt_param_sriov_enabled_set),
>>         DEVLINK_CONFIG_PARAM_U32(DEVLINK_PERM_CONFIG_NUM_VF_PER_PF,
>>                                  bnxt_param_num_vf_per_pf_get,
>>                                  bnxt_param_num_vf_per_pf_set),
>> };
>>
>> and then in init:
>>
>> err = devlink_config_param_register(devlink, bnxt_params,
>>                                     ARRAY_SIZE(bnxt_params));
>>
>> The register function will check types against the internal devlink
>> param->type table.
>>
>> Also, the restart_reqd could be signalized by some pre-defined positive
>> setter return value.
>
>Understood - like I said, I thought it preferable to use a global
>getter/setter rather than one for each individual parameter, but I
>will make the requested change, in hopes of reaching a conclusion
>soon.
