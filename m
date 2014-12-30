From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next 1/5] ixgbe: Add a RETA query command to VF-PF
 channel API
Date: Tue, 30 Dec 2014 11:21:33 -0800
Message-ID: <CAL3LdT4mfE72fmA3b3iG=-b9iP9MXHfAJMBwqFzfYyC1pebc8A@mail.gmail.com>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
	<1419957035-1078-2-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, gleb@cloudius-systems.com,
	avi@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34677 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbaL3TVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 14:21:34 -0500
Received: by mail-oi0-f48.google.com with SMTP id u20so33434342oif.7
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 11:21:33 -0800 (PST)
In-Reply-To: <1419957035-1078-2-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
<vladz@cloudius-systems.com> wrote:
> 82599 VFs and PF share the same RSS redirection table (RETA). Therefore we
> just return it for all VFs.
>
> RETA table is an array of 32 registers and the maximum number of registers
> that may be delivered in a single VF-PF channel command is 15. Therefore
> we will deliver the whole table in 3 steps: 12, 12 and 8 registers in each
> step correspondingly. Thus this patch does the following:
>
>   - Adds a new API version (to specify a new commands set).
>   - Adds the IXGBE_VF_GET_RETA_[0,1,2] commands to the VF-PF commands set.
>
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  6 +++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 35 ++++++++++++++++++++++++++
>  2 files changed, 41 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> index a5cb755..c1123d9 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> @@ -73,6 +73,7 @@ enum ixgbe_pfvf_api_rev {
>         ixgbe_mbox_api_10,      /* API version 1.0, linux/freebsd VF driver */
>         ixgbe_mbox_api_20,      /* API version 2.0, solaris Phase1 VF driver */
>         ixgbe_mbox_api_11,      /* API version 1.1, linux/freebsd VF driver */
> +       ixgbe_mbox_api_12,      /* API version 1.2, linux/freebsd VF driver */
>         /* This value should always be last */
>         ixgbe_mbox_api_unknown, /* indicates that API version is not known */
>  };
> @@ -91,6 +92,11 @@ enum ixgbe_pfvf_api_rev {
>  /* mailbox API, version 1.1 VF requests */
>  #define IXGBE_VF_GET_QUEUES    0x09 /* get queue configuration */
>
> +/* mailbox API, version 1.2 VF requests */
> +#define IXGBE_VF_GET_RETA_0    0x0a /* get RETA[0..11]  */
> +#define IXGBE_VF_GET_RETA_1    0x0b /* get RETA[12..23] */
> +#define IXGBE_VF_GET_RETA_2    0x0c /* get RETA[24..31] */
> +
>  /* GET_QUEUES return data indices within the mailbox */
>  #define IXGBE_VF_TX_QUEUES     1       /* number of Tx queues supported */
>  #define IXGBE_VF_RX_QUEUES     2       /* number of Rx queues supported */
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> index c76ba90..84db1a5 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -427,6 +427,7 @@ static s32 ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
>  #endif /* CONFIG_FCOE */
>                 switch (adapter->vfinfo[vf].vf_api) {
>                 case ixgbe_mbox_api_11:
> +               case ixgbe_mbox_api_12:
>                         /*
>                          * Version 1.1 supports jumbo frames on VFs if PF has
>                          * jumbo frames enabled which means legacy VFs are
> @@ -894,6 +895,7 @@ static int ixgbe_negotiate_vf_api(struct ixgbe_adapter *adapter,
>         switch (api) {
>         case ixgbe_mbox_api_10:
>         case ixgbe_mbox_api_11:
> +       case ixgbe_mbox_api_12:
>                 adapter->vfinfo[vf].vf_api = api;
>                 return 0;
>         default:
> @@ -917,6 +919,7 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
>         switch (adapter->vfinfo[vf].vf_api) {
>         case ixgbe_mbox_api_20:
>         case ixgbe_mbox_api_11:
> +       case ixgbe_mbox_api_12:
>                 break;
>         default:
>                 return -1;
> @@ -944,6 +947,29 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
>         return 0;
>  }
>
> +static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter,
> +                            u32 *msgbuf, u32 vf, int reta_offset_dw,
> +                            size_t dwords)
> +{
> +       struct ixgbe_hw *hw = &adapter->hw;
> +       int i;
> +       u32 *reta = &msgbuf[1];
> +
> +       /* verify the PF is supporting the correct API */
> +       switch (adapter->vfinfo[vf].vf_api) {
> +       case ixgbe_mbox_api_12:
> +               break;
> +       default:
> +               return -EPERM;
> +       }

A switch statement is overkill for a single case.  It would be far
simpler to just have

if (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12)
        return -EPERM;

Later on, if there are multiple API's or future API's that also
support this, then we could move to a case statement.
