From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 3/7] stmmac: review private structure fields
Date: Wed, 03 Apr 2013 09:33:04 +0200
Message-ID: <515BDB30.4080603@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>  <1364967689-11155-3-git-send-email-peppe.cavallaro@st.com> <1364973691.13853.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:50565 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762799Ab3DCHdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 03:33:09 -0400
In-Reply-To: <1364973691.13853.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2013 9:21 AM, Eric Dumazet wrote:
> On Wed, 2013-04-03 at 07:41 +0200, Giuseppe CAVALLARO wrote:
>> recently many new supports have been added in the stmmac driver w/o taking care
>> about where each new field had to be placed inside the private structure for
>> guaranteeing the best cache usage.
>> This is what I wanted in the beginning, so this patch reorganizes all the fields
>> in order to keep adjacent fields for cache effect.
>> I have also tried to optimize them by using pahole.
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac.h |   70 +++++++++++++-------------
>>   1 files changed, 35 insertions(+), 35 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>> index 75f997b..8aa28c5 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>> @@ -35,36 +35,45 @@
>>
>>   struct stmmac_priv {
>>   	/* Frequently used values are kept adjacent for cache effect */
>> -	struct dma_desc *dma_tx ____cacheline_aligned;	/* Basic TX desc */
>> -	struct dma_extended_desc *dma_etx;	/* Extended TX descriptor */
>> -	dma_addr_t dma_tx_phy;
>> -	struct sk_buff **tx_skbuff;
>> -	dma_addr_t *tx_skbuff_dma;
>> +	struct dma_extended_desc *dma_etx;
>> +	struct dma_desc *dma_tx ____cacheline_aligned_in_smp;
>> +	struct sk_buff **tx_skbuff ____cacheline_aligned_in_smp;
>
> dma_tx & tx_skbuff are readonly, why put them in separate cache lines ?

I put tx_skbuff in a separate cache line because, when we use extended
descriptors, the driver works with dma_etx instead of dma_tx.
So my idea was to have both dma_etx, dma_tx and tx_skbuff aligned in
any case.

>
> It seems there is an abuse of ____cacheline_aligned_in_smp in this
> driver (especially if this driver only runs on UP arch)

Yes I know that there is this abuse but why do you see an abuse for UP?
In that case we should fall through ____cacheline_aligned (e.g. it is ok 
for SH4).

peppe

>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
