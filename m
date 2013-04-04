From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 3/7] stmmac: review private structure fields
Date: Thu, 04 Apr 2013 08:11:34 +0200
Message-ID: <515D1996.8030501@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>   <1364967689-11155-3-git-send-email-peppe.cavallaro@st.com>  <1364973691.13853.7.camel@edumazet-glaptop> <515BDB30.4080603@st.com> <1365005352.2897.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog122.obsmtp.com ([207.126.144.153]:42519 "EHLO
	eu1sys200aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761228Ab3DDGLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 02:11:40 -0400
In-Reply-To: <1365005352.2897.12.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2013 6:09 PM, Ben Hutchings wrote:
> On Wed, 2013-04-03 at 09:33 +0200, Giuseppe CAVALLARO wrote:
>> On 4/3/2013 9:21 AM, Eric Dumazet wrote:
>>> On Wed, 2013-04-03 at 07:41 +0200, Giuseppe CAVALLARO wrote:
>>>> recently many new supports have been added in the stmmac driver w/o taking care
>>>> about where each new field had to be placed inside the private structure for
>>>> guaranteeing the best cache usage.
>>>> This is what I wanted in the beginning, so this patch reorganizes all the fields
>>>> in order to keep adjacent fields for cache effect.
>>>> I have also tried to optimize them by using pahole.
>>>>
>>>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>>>> ---
>>>>    drivers/net/ethernet/stmicro/stmmac/stmmac.h |   70 +++++++++++++-------------
>>>>    1 files changed, 35 insertions(+), 35 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>>>> index 75f997b..8aa28c5 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>>>> @@ -35,36 +35,45 @@
>>>>
>>>>    struct stmmac_priv {
>>>>    	/* Frequently used values are kept adjacent for cache effect */
>>>> -	struct dma_desc *dma_tx ____cacheline_aligned;	/* Basic TX desc */
>>>> -	struct dma_extended_desc *dma_etx;	/* Extended TX descriptor */
>>>> -	dma_addr_t dma_tx_phy;
>>>> -	struct sk_buff **tx_skbuff;
>>>> -	dma_addr_t *tx_skbuff_dma;
>>>> +	struct dma_extended_desc *dma_etx;
>>>> +	struct dma_desc *dma_tx ____cacheline_aligned_in_smp;
>>>> +	struct sk_buff **tx_skbuff ____cacheline_aligned_in_smp;
>>>
>>> dma_tx & tx_skbuff are readonly, why put them in separate cache lines ?
>>
>> I put tx_skbuff in a separate cache line because, when we use extended
>> descriptors, the driver works with dma_etx instead of dma_tx.
>> So my idea was to have both dma_etx, dma_tx and tx_skbuff aligned in
>> any case.
> [...]
>
> It's generally not that important to put fields at the beginning of a
> cache line.  (If you've measured with typical systems using stmmac and
> found an advantage, then I accept that you have a good reason to do
> this.  But that advantage is unlikely to be specific to SMP systems.)

That is the point. I had seen an improvement when testing on SH4
platforms if these pointers were at the beginning of a cache line.

> I would use ____cacheline_aligned_in_smp to separate fields that are
> likely to be changed on different CPUs, so that the cache line doesn't
> bounce between their caches.  Fields that are rarely modified (such as
> these pointers), or are used together on the same CPU should be packed
> together into a small number of cache lines.

Thx Ben for this explanation. Let me do some other tests on SMP ARM.
I'll rework this patch trying to balance the "abuse" of
____cacheline_aligned_in_smp and the best performances (I can re-test
on ARM and SH4).

peppe
>
> Ben.
>
