From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH net] amd-xgbe: Enable IRQs only if napi_complete_done() is
 true
Date: Fri, 10 Mar 2017 10:33:22 -0600
Message-ID: <3e8765da-19ee-c320-0ddb-7fe3b585607f@arm.com>
References: <20170309234823.11010.87592.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:60164 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755252AbdCJQdn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Mar 2017 11:33:43 -0500
In-Reply-To: <20170309234823.11010.87592.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2017 05:48 PM, Tom Lendacky wrote:
> Depending on the hardware, the amd-xgbe driver may use disable_irq_nosync()
> and enable_irq() when an interrupt is received to process Rx packets. If
> the napi_complete_done() return value isn't checked an unbalanced enable
> for the IRQ could result, generating a warning stack trace.
>
> Update the driver to only enable interrupts if napi_complete_done() returns
> true.

I've been running this for a few hours now and haven't seen the warning. 
So it appears to be fixed. Thanks!

I guess Dave M picked it up already, but I will toss this in anyway.


Tested-by: Jeremy Linton <jeremy.linton@arm.com>

>
> Reported-by: Jeremy Linton <jeremy.linton@arm.com>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
> index 248f60d..ffea985 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
> @@ -2272,10 +2272,7 @@ static int xgbe_one_poll(struct napi_struct *napi, int budget)
>  	processed = xgbe_rx_poll(channel, budget);
>
>  	/* If we processed everything, we are done */
> -	if (processed < budget) {
> -		/* Turn off polling */
> -		napi_complete_done(napi, processed);
> -
> +	if ((processed < budget) && napi_complete_done(napi, processed)) {
>  		/* Enable Tx and Rx interrupts */
>  		if (pdata->channel_irq_mode)
>  			xgbe_enable_rx_tx_int(pdata, channel);
> @@ -2317,10 +2314,7 @@ static int xgbe_all_poll(struct napi_struct *napi, int budget)
>  	} while ((processed < budget) && (processed != last_processed));
>
>  	/* If we processed everything, we are done */
> -	if (processed < budget) {
> -		/* Turn off polling */
> -		napi_complete_done(napi, processed);
> -
> +	if ((processed < budget) && napi_complete_done(napi, processed)) {
>  		/* Enable Tx and Rx interrupts */
>  		xgbe_enable_rx_tx_ints(pdata);
>  	}
>
