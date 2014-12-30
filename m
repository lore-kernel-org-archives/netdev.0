From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next 3/5] ixgbe: Add GET_RSS_KEY command to VF-PF
 channel commands set
Date: Tue, 30 Dec 2014 11:23:31 -0800
Message-ID: <CAL3LdT50tUsJOW+y15GbO=90UDYWNLjMyOF6AqFgj_ciqBeTUQ@mail.gmail.com>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
	<1419957035-1078-4-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Gleb Natapov <gleb@cloudius-systems.com>,
	Avi Kivity <avi@cloudius-systems.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:61034 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbaL3TXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 14:23:32 -0500
Received: by mail-oi0-f48.google.com with SMTP id u20so33440278oif.7
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 11:23:31 -0800 (PST)
In-Reply-To: <1419957035-1078-4-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
<vladz@cloudius-systems.com> wrote:
> 82599 VFs and PF share the same RSS Key. Therefore we will return
> the same RSS key for all VFs.
>
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  2 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 25 +++++++++++++++++++++++++
>  2 files changed, 27 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> index c1123d9..52e775b 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> @@ -97,6 +97,8 @@ enum ixgbe_pfvf_api_rev {
>  #define IXGBE_VF_GET_RETA_1    0x0b /* get RETA[12..23] */
>  #define IXGBE_VF_GET_RETA_2    0x0c /* get RETA[24..31] */
>
> +#define IXGBE_VF_GET_RSS_KEY   0x0d /* get RSS key */
> +
>  /* GET_QUEUES return data indices within the mailbox */
>  #define IXGBE_VF_TX_QUEUES     1       /* number of Tx queues supported */
>  #define IXGBE_VF_RX_QUEUES     2       /* number of Rx queues supported */
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> index 84db1a5..fc8233e 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -970,6 +970,28 @@ static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter,
>         return 0;
>  }
>
> +static int ixgbe_get_vf_rss_key(struct ixgbe_adapter *adapter,
> +                               u32 *msgbuf, u32 vf)
> +{
> +       struct ixgbe_hw *hw = &adapter->hw;
> +       int i;
> +       u32 *rss_key = &msgbuf[1];
> +
> +       /* verify the PF is supporting the correct API */
> +       switch (adapter->vfinfo[vf].vf_api) {
> +       case ixgbe_mbox_api_12:
> +               break;
> +       default:
> +               return -EPERM;
> +       }

Same as in patch 01 of the series, a switch statement is overkill for
a single case.  It would be far simpler to just have

if (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12)
        return -EPERM;

Later on, if there are multiple API's or future API's that also
support this, then we could move to a case statement.
