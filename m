From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH 2/2] net: calexdaxgmac: fixup endian issues after __raw
 IO function change
Date: Sun, 10 Feb 2013 16:32:32 -0600
Message-ID: <51182000.7090004@gmail.com>
References: <1360510721-17860-1-git-send-email-ben.dooks@codethink.co.uk> <1360510721-17860-3-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:44613 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756854Ab3BJWch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 17:32:37 -0500
Received: by mail-ob0-f179.google.com with SMTP id un3so5502066obb.24
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 14:32:36 -0800 (PST)
In-Reply-To: <1360510721-17860-3-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2013 09:38 AM, Ben Dooks wrote:
> When changing to __raw acccessors in 0ec6d343f7bcf9e0944aa9ff65287b987ec00c0f
> ("net: calxedaxgmac: use raw i/o accessors in rx and tx paths"), the driver
> is now broken on big endian systems as the readl/writel have an implict
> endian swap in them.
> 
> Change all the places where the __raw calls are used to correctly convert
> the constants in big endian format to the little endian data that the
> peripheral expects to see.

This is a bit ugly. The correct fix is really to enable the _relaxed
accessors on more arches.

Perhaps a local definition of readl_relaxed and writel_relaxed would be
a cleaner temporary solution.

Rob

> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> ---
>  drivers/net/ethernet/calxeda/xgmac.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
> index f91d9b2..96fd538 100644
> --- a/drivers/net/ethernet/calxeda/xgmac.c
> +++ b/drivers/net/ethernet/calxeda/xgmac.c
> @@ -1202,7 +1202,8 @@ static int xgmac_poll(struct napi_struct *napi, int budget)
>  
>  	if (work_done < budget) {
>  		napi_complete(napi);
> -		__raw_writel(DMA_INTR_DEFAULT_MASK, priv->base + XGMAC_DMA_INTR_ENA);
> +		__raw_writel(le32_to_cpu((__force __le32)DMA_INTR_DEFAULT_MASK),
> +			     priv->base + XGMAC_DMA_INTR_ENA);
>  	}
>  	return work_done;
>  }
> @@ -1348,7 +1349,7 @@ static irqreturn_t xgmac_pmt_interrupt(int irq, void *dev_id)
>  	void __iomem *ioaddr = priv->base;
>  
>  	intr_status = __raw_readl(ioaddr + XGMAC_INT_STAT);
> -	if (intr_status & XGMAC_INT_STAT_PMT) {
> +	if (intr_status & le32_to_cpu((__force __le32)XGMAC_INT_STAT_PMT)) {
>  		netdev_dbg(priv->dev, "received Magic frame\n");
>  		/* clear the PMT bits 5 and 6 by reading the PMT */
>  		readl(ioaddr + XGMAC_PMT);
> @@ -1369,6 +1370,8 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
>  	intr_status &= __raw_readl(priv->base + XGMAC_DMA_INTR_ENA);
>  	__raw_writel(intr_status, priv->base + XGMAC_DMA_STATUS);
>  
> +	intr_status = (__force u32)cpu_to_le32(intr_status);
> +
>  	/* It displays the DMA process states (CSR5 register) */
>  	/* ABNORMAL interrupts */
>  	if (unlikely(intr_status & DMA_STATUS_AIS)) {
> @@ -1403,7 +1406,8 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
>  
>  	/* TX/RX NORMAL interrupts */
>  	if (intr_status & (DMA_STATUS_RI | DMA_STATUS_TU | DMA_STATUS_TI)) {
> -		__raw_writel(DMA_INTR_ABNORMAL, priv->base + XGMAC_DMA_INTR_ENA);
> +		__raw_writel(le32_to_cpu((__force __le32)DMA_INTR_ABNORMAL),
> +			     priv->base + XGMAC_DMA_INTR_ENA);
>  		napi_schedule(&priv->napi);
>  	}
>  
> 
