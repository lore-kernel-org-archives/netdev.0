From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/3] drivers: net: stmmac: add blackfin support
Date: Tue, 22 May 2012 14:36:34 +0200
Message-ID: <4FBB8852.7060403@st.com>
References: <1337672336-7378-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, francesco.virlinzi@st.com,
	rayagond@vayavyalabs.com, sr@denx.de, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Bob Liu <lliubbo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:59066 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751247Ab2EVMhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 08:37:06 -0400
In-Reply-To: <1337672336-7378-1-git-send-email-lliubbo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Bob Liu

On 5/22/2012 9:38 AM, Bob Liu wrote:
> Blackfin arch use stmmac on its reference board bf609-ezkit, the stmmac ip
> version is 3.61a.
> 
> But the spec seems a little different, some register addr and define are not
> the same with current code.
> 
> This patch add the support for blackfin arch following the spec.

The 3.61a is supported and you have to point to the dw1000.h header file.

To support this GMAC generation you only need to pass from the platform
the field has_gmac (see stmmac.txt).
Also the 3.61a has the HW cap registers so many internal fields (e.g. rx
coe, enhanced descr ...) will be fixed at run-time (although you can
pass them from the platform).

Your patch adds the GMAC SPEC in the old MAC 10/100.

Also I am reluctant to have specific ifdef <ARCH> within the code.
I do think the driver already has all the platform fields to run on your
board. If you need extra conf pls feel free to enhance the
plat_stmmacenet_data.

Peppe
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac100.h     |   29 ++++++++++++++++++++
>  .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    6 +++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    3 ++
>  drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    5 +++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    2 +
>  5 files changed, 44 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h b/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
> index 7c6d857..cc3ac4f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
> @@ -29,6 +29,18 @@
>   *	 			MAC BLOCK defines
>   *---------------------------------------------------------------------------*/
>  /* MAC CSR offset */
> +#ifdef CONFIG_BLACKFIN
> +#define MAC_CONTROL		0x00000000	/* MAC Control */
> +#define MAC_FRAME_FILTER	0x0000004	/* Frame filter */
> +#define MAC_HASH_HIGH		0x00000008	/* Multicast Hash Table High */
> +#define MAC_HASH_LOW		0x0000000c	/* Multicast Hash Table Low */
> +#define MAC_MII_ADDR		0x00000010	/* MII Address */
> +#define MAC_MII_DATA		0x00000014	/* MII Data */
> +#define MAC_FLOW_CTRL		0x00000018	/* Flow Control */
> +#define MAC_VLAN1		0x0000001c	/* VLAN1 Tag */
> +#define MAC_ADDR_HIGH		0x00000040	/* MAC Address High */
> +#define MAC_ADDR_LOW		0x00000044	/* MAC Address Low */
> +#else
>  #define MAC_CONTROL	0x00000000	/* MAC Control */
>  #define MAC_ADDR_HIGH	0x00000004	/* MAC Address High */
>  #define MAC_ADDR_LOW	0x00000008	/* MAC Address Low */
> @@ -39,6 +51,18 @@
>  #define MAC_FLOW_CTRL	0x0000001c	/* Flow Control */
>  #define MAC_VLAN1	0x00000020	/* VLAN1 Tag */
>  #define MAC_VLAN2	0x00000024	/* VLAN2 Tag */
> +#endif
> +
> +#ifdef CONFIG_BLACKFIN
> +/* MAC_FRAME_FILTER defines */
> +#define MAC_FRAME_FILTER_RA  0x80000000
> +#define MAC_FRAME_FILTER_PR  0x00000001
> +#define MAC_FRAME_FILTER_HMC 0x00000004
> +#define MAC_FRAME_FILTER_PM  0x00000010
> +
> +#define MAC_FRAME_FILTER_INIT (MAC_FRAME_FILTER_RA | MAC_FRAME_FILTER_PR | \
> +		MAC_FRAME_FILTER_HMC | MAC_FRAME_FILTER_PM)
> +#endif
>  
>  /* MAC CTRL defines */
>  #define MAC_CONTROL_RA	0x80000000	/* Receive All Mode */
> @@ -54,6 +78,7 @@
>  #define MAC_CONTROL_IF	0x00020000	/* Inverse Filtering */
>  #define MAC_CONTROL_PB	0x00010000	/* Pass Bad Frames */
>  #define MAC_CONTROL_HO	0x00008000	/* Hash Only Filtering Mode */
> +#define MAC_CONTROL_FES	0x00004000	/* Speed in Fast Ethernet Mode */
>  #define MAC_CONTROL_HP	0x00002000	/* Hash/Perfect Filtering Mode */
>  #define MAC_CONTROL_LCC	0x00001000	/* Late Collision Control */
>  #define MAC_CONTROL_DBF	0x00000800	/* Disable Broadcast Frames */
> @@ -67,7 +92,11 @@
>  #define MAC_CONTROL_TE		0x00000008	/* Transmitter Enable */
>  #define MAC_CONTROL_RE		0x00000004	/* Receiver Enable */
>  
> +#ifdef CONFIG_BLACKFIN
> +#define MAC_CORE_INIT (MAC_CONTROL_FES | MAC_CONTROL_DBF)
> +#else
>  #define MAC_CORE_INIT (MAC_CONTROL_HBD | MAC_CONTROL_ASTP)
> +#endif
>  
>  /* MAC FLOW CTRL defines */
>  #define MAC_FLOW_CTRL_PT_MASK	0xffff0000	/* Pause Time Mask */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
> index 138fb8d..1c49d96 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
> @@ -35,7 +35,9 @@
>  static void dwmac100_core_init(void __iomem *ioaddr)
>  {
>  	u32 value = readl(ioaddr + MAC_CONTROL);
> -
> +#ifdef CONFIG_BLACKFIN
> +	writel(MAC_FRAME_FILTER_INIT, ioaddr + MAC_FRAME_FILTER);
> +#endif
>  	writel((value | MAC_CORE_INIT), ioaddr + MAC_CONTROL);
>  
>  #ifdef STMMAC_VLAN_TAG_USED
> @@ -68,8 +70,10 @@ static void dwmac100_dump_mac_regs(void __iomem *ioaddr)
>  		MAC_FLOW_CTRL, readl(ioaddr + MAC_FLOW_CTRL));
>  	pr_info("\tVLAN1 tag (offset 0x%x): 0x%08x\n", MAC_VLAN1,
>  		readl(ioaddr + MAC_VLAN1));
> +#ifndef CONFIG_BLACKFIN
>  	pr_info("\tVLAN2 tag (offset 0x%x): 0x%08x\n", MAC_VLAN2,
>  		readl(ioaddr + MAC_VLAN2));
> +#endif
>  }
>  
>  static void dwmac100_irq_status(void __iomem *ioaddr)
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
> index bc17fd0..d682a0b 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
> @@ -50,6 +50,9 @@ static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
>  	if (limit < 0)
>  		return -EBUSY;
>  
> +#ifdef CONFIG_BLACKFIN
> +	writel(DMA_AXI_BUS_BLEN4 | DMA_AXI_BUS_UNDEF, ioaddr + DMA_AXI_BUS);
> +#endif
>  	/* Enable Application Access by writing to DMA CSR0 */
>  	writel(DMA_BUS_MODE_DEFAULT | (pbl << DMA_BUS_MODE_PBL_SHIFT),
>  	       ioaddr + DMA_BUS_MODE);
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
> index 437edac..e75269a 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
> @@ -32,6 +32,7 @@
>  #define DMA_CONTROL		0x00001018	/* Ctrl (Operational Mode) */
>  #define DMA_INTR_ENA		0x0000101c	/* Interrupt Enable */
>  #define DMA_MISSED_FRAME_CTR	0x00001020	/* Missed Frame Counter */
> +#define DMA_AXI_BUS		0x00001028	/* Axi Bus */
>  #define DMA_CUR_TX_BUF_ADDR	0x00001050	/* Current Host Tx Buffer */
>  #define DMA_CUR_RX_BUF_ADDR	0x00001054	/* Current Host Rx Buffer */
>  #define DMA_HW_FEATURE		0x00001058	/* HW Feature Register */
> @@ -40,6 +41,10 @@
>  #define DMA_CONTROL_ST		0x00002000	/* Start/Stop Transmission */
>  #define DMA_CONTROL_SR		0x00000002	/* Start/Stop Receive */
>  
> +/* DMA Axi bus register defines */
> +#define DMA_AXI_BUS_UNDEF	0x00000001
> +#define DMA_AXI_BUS_BLEN4	0x00000002
> +
>  /* DMA Normal interrupt */
>  #define DMA_INTR_ENA_NIE 0x00010000	/* Normal Summary */
>  #define DMA_INTR_ENA_TIE 0x00000001	/* Transmit Interrupt */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 48d56da..714faa2 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1279,8 +1279,10 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
>  			frame_len = priv->hw->desc->get_rx_frame_len(p);
>  			/* ACS is set; GMAC core strips PAD/FCS for IEEE 802.3
>  			 * Type frames (LLC/LLC-SNAP) */
> +#ifndef CONFIG_BLACKFIN
>  			if (unlikely(status != llc_snap))
>  				frame_len -= ETH_FCS_LEN;
> +#endif
>  #ifdef STMMAC_RX_DEBUG
>  			if (frame_len > ETH_FRAME_LEN)
>  				pr_debug("\tRX frame size %d, COE status: %d\n",
