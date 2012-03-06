From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 5/6] stmmac: configure burst related GMAC DMA parameters
Date: Tue, 06 Mar 2012 08:43:08 +0100
Message-ID: <4F55C00C.6030208@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <1330692928-30330-5-git-send-email-deepak.sikri@st.com> <1330692928-30330-6-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: spear-devel@list.st.com, netdev@vger.kernel.org,
	Shiraz Hashim <shiraz.hashim@st.com>,
	Vikas Manocha <vikas.manocha@st.com>
To: Deepak Sikri <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:53857 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756795Ab2CFHo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 02:44:26 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7E82B221
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 07:44:22 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0CEB11698
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 07:44:22 +0000 (GMT)
In-Reply-To: <1330692928-30330-6-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Deepak,

On 3/2/2012 1:55 PM, Deepak Sikri wrote:
> SPEAr1340 GMAC is a different version (3.61a) of Synopsys IP where
> instead of 4xPBL we have 8xPBL, hence pbl value supplied by platform
> data in
> 	- SPEAr1340 results in 8 * pbl
> 	- rest devices result in 4 * pbl
> 
> Further it is observed that rest of the devices (older version) which
> have an AXI wrapper over AHB are limited  to incr 32 burst where as this
> can go up to incr 128 in case of SPEAr1340.
> 
> Also, with fixed burst configuration we need to program permissible
> burst values in newer versions (AXI supported) of gmac. This
> AXI_BUS_MODE) register is reserved for earlier versions of gmac and
> writing to them has no impact.
> 
> Signed-off-by: Shiraz Hashim <shiraz.hashim@st.com>
> Signed-off-by: Vikas Manocha <vikas.manocha@st.com>
> Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
> ---
>  .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   14 +++++++++++++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
>  2 files changed, 14 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> index 4d5402a..ed6ffa3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> @@ -48,7 +48,7 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
>  	if (limit < 0)
>  		return -EBUSY;
>  
> -	value = /* DMA_BUS_MODE_FB | */ DMA_BUS_MODE_4PBL |
> +	value = DMA_BUS_MODE_FB | DMA_BUS_MODE_4PBL |
>  	    ((pbl << DMA_BUS_MODE_PBL_SHIFT) |
>  	     (pbl << DMA_BUS_MODE_RPBL_SHIFT));


bit 24 in the Bus Mode Register represents the 8xPBL in databooks newer
than the 3.50a. In older databook it is 4xPBL.
So maybe, the DMA_BUS_MODE_4PBL define should be renamed as
DMA_BUS_PBL_MODE (to be more generic and surrounded by a nice comment
that details its meaning for different devices).

but ...

> @@ -56,6 +56,18 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
>  	value |= DMA_BUS_MODE_DA;	/* Rx has priority over tx */
>  #endif
>  	writel(value, ioaddr + DMA_BUS_MODE);
> +	/*
> +	 * We need to program DMA_AXI_BUS_MODE for supported bursts in
> +	 * case DMA_BUS_MODE_FB mode is selected
> +	 * Note: This is applicable only for revision GMACv3.61a. For
> +	 * older version this register is reserved and shall have no
> +	 * effect.
> +	 * Further we directly write 0xFF to this register. This would
> +	 * ensure that all bursts supported by platform is set and those
> +	 * which are not supported would remain ineffective.
> +	 */
> +	if (value & DMA_BUS_MODE_FB)
> +		writel(0xFF, ioaddr + DMA_AXI_BUS_MODE);

... this patch sets the FB: Fixed Burst (not set on other GMAC!) and
then always writes into the DMA_AXI_BUS_MODE register.

I agree that the DMA_AXI_BUS_MODE Reg is reserved in old devices but I'd
like to have a new platform parameter to do this kind of thing.

We could have .fixed_burst in the linux/stmmac.h (like .pbl).

If it is passed, so we set the DMA_BUS_MODE_FB in the DMA Reg 0.

In this case, we can also set the DMA reg11 but, pls, not using 0xff.
I wonder if you could improve the code adding the defines for this register.

With this approach we have no impact on other GMAC!

peppe

>  	/* Mask interrupts by writing to CSR7 */
>  	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
> index 437edac..6e0360f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
> @@ -32,6 +32,7 @@
>  #define DMA_CONTROL		0x00001018	/* Ctrl (Operational Mode) */
>  #define DMA_INTR_ENA		0x0000101c	/* Interrupt Enable */
>  #define DMA_MISSED_FRAME_CTR	0x00001020	/* Missed Frame Counter */
> +#define DMA_AXI_BUS_MODE       0x00001028      /* AXI Bus Mode */
>  #define DMA_CUR_TX_BUF_ADDR	0x00001050	/* Current Host Tx Buffer */
>  #define DMA_CUR_RX_BUF_ADDR	0x00001054	/* Current Host Rx Buffer */
>  #define DMA_HW_FEATURE		0x00001058	/* HW Feature Register */
