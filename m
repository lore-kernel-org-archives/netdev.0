From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: xgbe unbalanced enable for IRQ XX in 4.11-rc1
Date: Thu, 9 Mar 2017 17:24:46 -0600
Message-ID: <c6ed2749-a9c7-70b0-c2ab-989a7268d432@amd.com>
References: <41df0f3a-5867-b0d5-a7f9-14b66eaff7a2@arm.com>
 <e6f6df1d-18fa-070f-f28c-75cd3aae4582@amd.com>
 <25762623-5aae-bfb1-64fd-dd431630c6c9@arm.com>
 <ad2abd2c-5a67-b2d5-d5c8-8252505a71cc@amd.com>
 <1489100780.28631.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Linton <jeremy.linton@arm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0051.outbound.protection.outlook.com ([104.47.41.51]:22432
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751623AbdCIXY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 18:24:56 -0500
In-Reply-To: <1489100780.28631.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/9/2017 5:06 PM, Eric Dumazet wrote:
> On Thu, 2017-03-09 at 16:35 -0600, Tom Lendacky wrote:
>> On 3/9/2017 4:17 PM, Jeremy Linton wrote:
>>> Hi,
>>>
>>> On 03/09/2017 03:39 PM, Tom Lendacky wrote:
>>>> On 3/9/2017 3:26 PM, Jeremy Linton wrote:
>>>>> Hi,
>>>>
>>>> Hi Jeremy,
>>>>
>>>> I'll have a look at it.  Can you send me your kernel config just in
>>>> case?
>>>
>>> Sure, i will send it to you off list to avoid spamming everyone with a
>>> 43k gziped file.
>>>
>>
>> I'm able to recreate the problem with my current config.  If I revert
>> patch 39e6c8208d7b ("net: solve a NAPI race"), then the problem goes
>> away.
>>
>> Eric, any thoughts on this?  I'm guessing the driver should check that
>> napi_complete_done returns true before enabling IRQs...
>>
>> Thanks,
>> Tom
>
> Yes, it seems this driver has a conditional disable_irq_nosync()
> following the napi_schedule_prep()
>
> So it probably needs the same for the enable_irq() side.

I verified that the issue goes away when the return value for
napi_complete_done() is checked.  I'll prepare a patch for
both calls in the driver.

>
> This would be broken with busy polling anyway, before my patch.

Yes, I see that busy polling went into 4.10 so I'll submit it back
to 4.10 stable as well.

Thanks,
Tom

>
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
> index 248f60d171a5a0ce76744a95e2d59039939e6538..c47a3a93f034ab608286d1ae343e9b7778063df8 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
> @@ -2272,9 +2272,8 @@ static int xgbe_one_poll(struct napi_struct *napi, int budget)
>  	processed = xgbe_rx_poll(channel, budget);
>
>  	/* If we processed everything, we are done */
> -	if (processed < budget) {
> -		/* Turn off polling */
> -		napi_complete_done(napi, processed);
> +	if (processed < budget &&
> +	    napi_complete_done(napi, processed)) {
>
>  		/* Enable Tx and Rx interrupts */
>  		if (pdata->channel_irq_mode)
>
>
