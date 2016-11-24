From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH] net: stmmac: enable tx queue 0 for gmac4 IPs synthesized
 with multiple TX queues
Date: Thu, 24 Nov 2016 19:11:49 +0100
Message-ID: <0516ebe9-6b66-5991-1f96-1cc10178977a@st.com>
References: <1479998194-7113-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:35073 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S935877AbcKXSMI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 13:12:08 -0500
In-Reply-To: <1479998194-7113-1-git-send-email-niklass@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Niklas,

On 11/24/2016 03:36 PM, Niklas Cassel wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>
>
> The dwmac4 IP can synthesized with 1-8 number of tx queues.
> On an IP synthesized with DWC_EQOS_NUM_TXQ > 1, all txqueues are disabled
> by default. For these IPs, the bitfield TXQEN is R/W.
>
> Always enable tx queue 0. The write will have no effect on IPs synthesized
> with DWC_EQOS_NUM_TXQ == 1.
>
> The driver does still not utilize more than one tx queue in the IP.
>
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h     |  3 +++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c | 12 +++++++++++-
>  2 files changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> index 6f4f5ce25114..3e8d4fefa5e0 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> @@ -155,8 +155,11 @@ enum power_event {
>  #define MTL_CHAN_RX_DEBUG(x)		(MTL_CHANX_BASE_ADDR(x) + 0x38)
>
>  #define MTL_OP_MODE_RSF			BIT(5)
> +#define MTL_OP_MODE_TXQEN		BIT(3)
>  #define MTL_OP_MODE_TSF			BIT(1)
>
> +#define MTL_OP_MODE_TQS_MASK		GENMASK(24, 16)
> +
>  #define MTL_OP_MODE_TTC_MASK		0x70
>  #define MTL_OP_MODE_TTC_SHIFT		4
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> index 116151cd6a95..577316de6ba8 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> @@ -213,7 +213,17 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
>  		else
>  			mtl_tx_op |= MTL_OP_MODE_TTC_512;
>  	}
> -
> +	/* For an IP with DWC_EQOS_NUM_TXQ == 1, the fields TXQEN and TQS are RO
> +	 * with reset values: TXQEN on, TQS == DWC_EQOS_TXFIFO_SIZE.
> +	 * For an IP with DWC_EQOS_NUM_TXQ > 1, the fields TXQEN and TQS are R/W
> +	 * with reset values: TXQEN off, TQS 256 bytes.
> +	 *
> +	 * Write the bits in both cases, since it will have no effect when RO.
> +	 * For DWC_EQOS_NUM_TXQ > 1, the top bits in MTL_OP_MODE_TQS_MASK might
> +	 * be RO, however, writing the whole TQS field will result in a value
> +	 * equal to DWC_EQOS_TXFIFO_SIZE, just like for DWC_EQOS_NUM_TXQ == 1.
> +	 */
> +	mtl_tx_op |= MTL_OP_MODE_TXQEN | MTL_OP_MODE_TQS_MASK;

Your patch sounds good. Just one question:

In synopsys databook I use, I see that MTL_OP_MODE_TXQEN for channel 2 
can take several values "disabled / enabled / Enabled in AV mode":

Transmit Queue Enable
This field is used to enable/disable the transmit queue 1. 00 R/W
■ 2'b00 - Not enabled
■ 2'b01 - Enable in AV mode (Reserved when Enable Audio Video
Bridging is not selected while configuring the core)
■ 2'b10 - Enabled
■ 2'b11 - Reserved

Do you plan to manage av mode in a future patch ?

Regards
Alex

>  	writel(mtl_tx_op, ioaddr +  MTL_CHAN_TX_OP_MODE(channel));
>
>  	mtl_rx_op = readl(ioaddr + MTL_CHAN_RX_OP_MODE(channel));
>
