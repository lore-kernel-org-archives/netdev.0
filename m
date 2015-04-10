From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [net-next PATCH 2/3] net: macb: Add support for jumbo frames
Date: Fri, 10 Apr 2015 11:50:58 +0200
Message-ID: <392788e2-6d6b-44c7-83eb-151d1fde0b49@BN1BFFO11FD052.protection.gbl>
References: <1428657441-27710-1-git-send-email-harinik@xilinx.com>
 <1428657441-27710-2-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>
To: Harini Katakam <harini.katakam@xilinx.com>,
	<nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428657441-27710-2-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/10/2015 11:17 AM, Harini Katakam wrote:
> Check for "cdns,zynqmp-gem" compatible string and enable jumbo frame support
> in NWCFG register, update descriptor length masks and registers accordingly.
> Jumbo max length register should be set according to support in SoC; it is
> set to 10240 for Zynq Ultrascale ZynqMPSoC.
> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
> ---
>  drivers/net/ethernet/cadence/macb.c |   19 ++++++++++++++++---
>  drivers/net/ethernet/cadence/macb.h |    8 ++++++++
>  2 files changed, 24 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 448a323..85de91d 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -779,7 +779,7 @@ static int gem_rx(struct macb *bp, int budget)
>  		}
>  		/* now everything is ready for receiving packet */
>  		bp->rx_skbuff[entry] = NULL;
> -		len = MACB_BFEXT(RX_FRMLEN, ctrl);
> +		len = ctrl & bp->rx_frm_len_mask;
>  
>  		netdev_vdbg(bp->dev, "gem_rx %u (len %u)\n", entry, len);
>  
> @@ -825,7 +825,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
>  	struct macb_dma_desc *desc;
>  
>  	desc = macb_rx_desc(bp, last_frag);
> -	len = MACB_BFEXT(RX_FRMLEN, desc->ctrl);
> +	len = desc->ctrl & bp->rx_frm_len_mask;
>  
>  	netdev_vdbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
>  		macb_rx_ring_wrap(first_frag),
> @@ -1630,7 +1630,10 @@ static void macb_init_hw(struct macb *bp)
>  	config |= MACB_BF(RBOF, NET_IP_ALIGN);	/* Make eth data aligned */
>  	config |= MACB_BIT(PAE);		/* PAuse Enable */
>  	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
> -	config |= MACB_BIT(BIG);		/* Receive oversized frames */
> +	if (bp->isjumbo)
> +		config |= MACB_BIT(JFRAME);	/* Enable jumbo frames */
> +	else
> +		config |= MACB_BIT(BIG);	/* Receive oversized frames */
>  	if (bp->dev->flags & IFF_PROMISC)
>  		config |= MACB_BIT(CAF);	/* Copy All Frames */
>  	else if (macb_is_gem(bp) && bp->dev->features & NETIF_F_RXCSUM)
> @@ -1639,8 +1642,13 @@ static void macb_init_hw(struct macb *bp)
>  		config |= MACB_BIT(NBC);	/* No BroadCast */
>  	config |= macb_dbw(bp);
>  	macb_writel(bp, NCFGR, config);
> +	if (bp->isjumbo && bp->jumbo_max_len)
> +		gem_writel(bp, JML, bp->jumbo_max_len);
>  	bp->speed = SPEED_10;
>  	bp->duplex = DUPLEX_HALF;
> +	bp->rx_frm_len_mask = MACB_RX_FRMLEN_MASK;
> +	if (bp->isjumbo)
> +		bp->rx_frm_len_mask = MACB_RX_JFRMLEN_MASK;
>  
>  	macb_configure_dma(bp);
>  
> @@ -2759,6 +2767,11 @@ static int macb_probe(struct platform_device *pdev)
>  	bp->pclk = pclk;
>  	bp->hclk = hclk;
>  	bp->tx_clk = tx_clk;
> +	if (of_device_is_compatible(pdev->dev.of_node, "cdns,zynqmp-gem")) {
> +		bp->isjumbo = 1;
> +		bp->jumbo_max_len = GEM_ZYNQMP_JUMBO_MAX;
> +	}

Not like this.

Nicolas will look at the rest but I think you should extend "struct
macb_config" and add that setup there instead of checking compatible
string here.
Maybe isjumbo can be hadled via caps bit already present in this
structure but please wait for others.

Thanks,
Michal
