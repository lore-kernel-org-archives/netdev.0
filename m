From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH 2/2] net: calexdaxgmac: fixup endian issues after __raw
 IO function change
Date: Mon, 11 Feb 2013 18:27:59 +0000
Message-ID: <5119382F.8000809@codethink.co.uk>
References: <1360510721-17860-1-git-send-email-ben.dooks@codethink.co.uk>  <1360510721-17860-3-git-send-email-ben.dooks@codethink.co.uk> <1360606656.2701.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Rob Herring <rob.herring@calxeda.com>,
	linux-arm-kernel@lists.infradead.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:47278 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758776Ab3BKS2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 13:28:02 -0500
In-Reply-To: <1360606656.2701.18.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/13 18:17, Ben Hutchings wrote:
> On Sun, 2013-02-10 at 15:38 +0000, Ben Dooks wrote:
>> When changing to __raw acccessors in 0ec6d343f7bcf9e0944aa9ff65287b987ec00c0f
>> ("net: calxedaxgmac: use raw i/o accessors in rx and tx paths"), the driver
>> is now broken on big endian systems as the readl/writel have an implict
>> endian swap in them.
>>
>> Change all the places where the __raw calls are used to correctly convert
>> the constants in big endian format to the little endian data that the
>> peripheral expects to see.
>
> You are using le32_to_cpu() and cpu_to_le32() the wrong way round, and
> then putting casts on the wrong side, i.e. it should be:
>
> 	value = le32_to_cpu((__force __le32)__raw_readl(addr));
> 	__raw_writel((__force u32)cpu_to_le32(value), addr);
>
> (I do wonder why __raw I/O functions aren't declared to take/return __le
> types... it would avoid the need to cast altogether.)

Because they do things with the order the cpu is working in, the
read{x} and write{x} transfer cpu to bus-endian so returning an __le
type would not be correct.

I think you are right about the conversions, it is a headache trying
to think through.

It may be easier to provide _relaxed IO variants for all systems so
that we can avoid this in future.

>> Signed-off-by: Ben Dooks<ben.dooks@codethink.co.uk>
>> ---
>>   drivers/net/ethernet/calxeda/xgmac.c |   10 +++++++---
>>   1 file changed, 7 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
>> index f91d9b2..96fd538 100644
>> --- a/drivers/net/ethernet/calxeda/xgmac.c
>> +++ b/drivers/net/ethernet/calxeda/xgmac.c
>> @@ -1202,7 +1202,8 @@ static int xgmac_poll(struct napi_struct *napi, int budget)
>>
>>   	if (work_done<  budget) {
>>   		napi_complete(napi);
>> -		__raw_writel(DMA_INTR_DEFAULT_MASK, priv->base + XGMAC_DMA_INTR_ENA);
>> +		__raw_writel(le32_to_cpu((__force __le32)DMA_INTR_DEFAULT_MASK),
>> +			     priv->base + XGMAC_DMA_INTR_ENA);
>>   	}
>>   	return work_done;
>>   }
>> @@ -1348,7 +1349,7 @@ static irqreturn_t xgmac_pmt_interrupt(int irq, void *dev_id)
>>   	void __iomem *ioaddr = priv->base;
>>
>>   	intr_status = __raw_readl(ioaddr + XGMAC_INT_STAT);
>> -	if (intr_status&  XGMAC_INT_STAT_PMT) {
>> +	if (intr_status&  le32_to_cpu((__force __le32)XGMAC_INT_STAT_PMT)) {
>>   		netdev_dbg(priv->dev, "received Magic frame\n");
>>   		/* clear the PMT bits 5 and 6 by reading the PMT */
>>   		readl(ioaddr + XGMAC_PMT);
>> @@ -1369,6 +1370,8 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
>>   	intr_status&= __raw_readl(priv->base + XGMAC_DMA_INTR_ENA);
>>   	__raw_writel(intr_status, priv->base + XGMAC_DMA_STATUS);
>>
>> +	intr_status = (__force u32)cpu_to_le32(intr_status);
>
> Perhaps intr_status should be split into two variables, for native and
> little-endian order.
>
> Ben.

That would be a possibility, although it would end up changing more code.

>>   	/* It displays the DMA process states (CSR5 register) */
>>   	/* ABNORMAL interrupts */
>>   	if (unlikely(intr_status&  DMA_STATUS_AIS)) {
>> @@ -1403,7 +1406,8 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
>>
>>   	/* TX/RX NORMAL interrupts */
>>   	if (intr_status&  (DMA_STATUS_RI | DMA_STATUS_TU | DMA_STATUS_TI)) {
>> -		__raw_writel(DMA_INTR_ABNORMAL, priv->base + XGMAC_DMA_INTR_ENA);
>> +		__raw_writel(le32_to_cpu((__force __le32)DMA_INTR_ABNORMAL),
>> +			     priv->base + XGMAC_DMA_INTR_ENA);
>>   		napi_schedule(&priv->napi);
>>   	}
>>
>


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
