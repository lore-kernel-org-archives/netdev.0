From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 03/14] i40e: Add PF reset when Malicious driver event
 for PF
Date: Tue, 24 Jun 2014 18:11:46 +0400
Message-ID: <53A98722.8020900@cogentembedded.com>
References: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com> <1403570858-13548-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net, Neerav Parikh <neerav.parikh@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:63989 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbaFXOLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 10:11:45 -0400
Received: by mail-lb0-f176.google.com with SMTP id w7so526056lbi.35
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 07:11:43 -0700 (PDT)
In-Reply-To: <1403570858-13548-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/24/2014 04:47 AM, Jeff Kirsher wrote:

> From: Neerav Parikh <neerav.parikh@intel.com>

> As per the spec when the PF driver receives a Malicious driver event
> the queue that caused the event is already stopped and it is expected
> that the function that owns the queue will reset the queue.
> In some cases it may not be possible to determine the queue and it is
> suggested to reset the whole function.

> This patch takes the later approach when the event is owned by the PF
> that owns it.

> Change-ID: I40f9764a6a5e068c0ef8438db00c5aa9c2c6c1c8
> Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 25 +++++++++++++++++++++++++
>   1 file changed, 25 insertions(+)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 0a68065..b751258 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
[...]
> @@ -5867,6 +5868,30 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
>   		mdd_detected = true;
>   	}
>
> +	if (mdd_detected) {
> +		reg = rd32(hw, I40E_PF_MDET_TX);
> +		if (reg & I40E_PF_MDET_TX_VALID_MASK) {
> +			wr32(hw, I40E_PF_MDET_TX, 0xFFFF);
> +			dev_info(&pf->pdev->dev,
> +				 "MDD TX event is for this function 0x%08x requesting PF reset.\n",

    Need some punctuation after a number.

> +				 reg);
> +			pf_mdd_detected = true;
> +		}
> +		reg = rd32(hw, I40E_PF_MDET_RX);
> +		if (reg & I40E_PF_MDET_RX_VALID_MASK) {
> +			wr32(hw, I40E_PF_MDET_RX, 0xFFFF);
> +			dev_info(&pf->pdev->dev,
> +				 "MDD RX event is for this function 0x%08x requesting PF reset.\n",

    Likewise.

> +				 reg);
> +			pf_mdd_detected = true;
> +		}
> +		/* Queue belongs to the PF initiate a reset */

    Need some punctuation after PF.

> +		if (pf_mdd_detected) {
> +			set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
> +			i40e_service_event_schedule(pf);
> +		}
> +	}
> +
>   	/* see if one of the VFs needs its hand slapped */
>   	for (i = 0; i < pf->num_alloc_vfs && mdd_detected; i++) {
>   		vf = &(pf->vf[i]);
>

WBR, Sergei
