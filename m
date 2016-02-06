From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 13/20] i40evf: add new write-back mode
Date: Sat, 6 Feb 2016 15:38:21 +0300
Message-ID: <56B5E93D.6080709@cogentembedded.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1454586551-35919-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:36217 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbcBFMi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 07:38:26 -0500
Received: by mail-lb0-f177.google.com with SMTP id dx2so62784269lbd.3
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 04:38:25 -0800 (PST)
In-Reply-To: <1454586551-35919-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/4/2016 2:49 PM, Jeff Kirsher wrote:

> From: Anjali Singhai Jain <anjali.singhai@intel.com>
>
> Add write-back on interrupt throttle rate timer expiration support
> for the i40evf driver, when running on X722 devices.
>
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

[...]
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> index 7a00657..7d663fb 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> @@ -252,6 +252,22 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
>   	tx_ring->q_vector->tx.total_bytes += total_bytes;
>   	tx_ring->q_vector->tx.total_packets += total_packets;
>
> +	if (tx_ring->flags & I40E_TXR_FLAGS_WB_ON_ITR) {
> +		unsigned int j = 0;

    Pointless initializer, you override it on the next line.

> +		/* check to see if there are < 4 descriptors
> +		 * waiting to be written back, then kick the hardware to force
> +		 * them to be written back in case we stay in NAPI.
> +		 * In this mode on X722 we do not enable Interrupt.
> +		 */
> +		j = i40evf_get_tx_pending(tx_ring);
> +
> +		if (budget &&
> +		    ((j / (WB_STRIDE + 1)) == 0) && (j > 0) &&
> +		    !test_bit(__I40E_DOWN, &tx_ring->vsi->state) &&
> +		    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count))
> +			tx_ring->arm_wb = true;
> +	}
> +
>   	netdev_tx_completed_queue(netdev_get_tx_queue(tx_ring->netdev,
>   						      tx_ring->queue_index),
>   				  total_packets, total_bytes);
[...]

MBR, Sergei
