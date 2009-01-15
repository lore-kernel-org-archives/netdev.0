From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH] fec: Add mx2 support (WIP)
Date: Thu, 15 Jan 2009 17:22:21 +1000
Message-ID: <496EE42D.4040300@snapgear.com>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-2-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-3-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-4-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-5-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-6-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-7-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sebastian Siewior <bigeasy@linutronix.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:33631 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754747AbZAOHWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 02:22:25 -0500
In-Reply-To: <1231949353-29630-7-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

Sascha Hauer wrote:
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> ---
>  drivers/net/Kconfig |    2 +-
>  drivers/net/fec.c   |  121 +++++++++++++++++++++++++++++++++++++++++++++++++--
>  drivers/net/fec.h   |   11 ++++-
>  3 files changed, 127 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 9fe8cb7..5333e65 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1829,7 +1829,7 @@ config 68360_ENET
>  
>  config FEC
>  	bool "FEC ethernet controller (of ColdFire CPUs)"
> -	depends on M523x || M527x || M5272 || M528x || M520x
> +	depends on M523x || M527x || M5272 || M528x || M520x || ARCH_MX2
>  	help
>  	  Say Y here if you want to use the built-in 10/100 Fast ethernet
>  	  controller on some Motorola ColdFire processors.
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 81c8e11..a3e5b63 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -38,10 +38,14 @@
>  #include <linux/bitops.h>
>  #include <linux/io.h>
>  #include <linux/irq.h>
> +#include <linux/clk.h>
>  
>  #include <asm/cacheflush.h>
> +
> +#ifndef CONFIG_ARCH_MX2
>  #include <asm/coldfire.h>
>  #include <asm/mcfsim.h>
> +#endif
>  
>  #include "fec.h"
>  
> @@ -51,6 +55,13 @@
>  #define	FEC_MAX_PORTS	1
>  #endif
>  
> +#ifdef CONFIG_ARCH_MX2
> +#include <mach/hardware.h>
> +#define FEC_ALIGNMENT	0xf
> +#else
> +#define FEC_ALIGNMENT	0x3
> +#endif
> +
>  #if defined(CONFIG_M5272)
>  #define HAVE_mii_link_interrupt
>  #endif
> @@ -70,6 +81,8 @@ static unsigned int fec_hw[] = {
>  	(MCF_MBAR+0x30000),
>  #elif defined(CONFIG_M532x)
>  	(MCF_MBAR+0xfc030000),
> +#elif defined(CONFIG_ARCH_MX2)
> +	(unsigned int)IO_ADDRESS(FEC_BASE_ADDR),
>  #endif
>  };
>  
> @@ -156,7 +169,7 @@ typedef struct {
>   * account when setting it.
>   */
>  #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
> -    defined(CONFIG_M520x) || defined(CONFIG_M532x)
> +    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARCH_MX2)
>  #define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
>  #else
>  #define	OPT_FRAME_SIZE	0
> @@ -337,7 +350,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	 *	4-byte boundaries. Use bounce buffers to copy data
>  	 *	and get it aligned. Ugh.
>  	 */
> -	if (bdp->cbd_bufaddr & 0x3) {
> +	if (bdp->cbd_bufaddr & FEC_ALIGNMENT) {
>  		unsigned int index;
>  		index = bdp - fep->tx_bd_base;
>  		memcpy(fep->tx_bounce[index], (void *)skb->data, skb->len);
> @@ -354,8 +367,8 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	/* Push the data cache so the CPM does not get stale memory
>  	 * data.
>  	 */
> -	flush_dcache_range((unsigned long)skb->data,
> -			   (unsigned long)skb->data + skb->len);
> +	dma_sync_single(NULL, bdp->cbd_bufaddr,
> +			bdp->cbd_datlen, DMA_TO_DEVICE);
>  
>  	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
>  	 * it's the last BD of the frame, and to put the CRC on the end.
> @@ -628,6 +641,9 @@ while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
>  	dev->stats.rx_bytes += pkt_len;
>  	data = (__u8*)__va(bdp->cbd_bufaddr);
>  
> +	dma_sync_single(NULL, (unsigned long)__pa(data),
> +			pkt_len - 4, DMA_FROM_DEVICE);
> +
>  	/* This does 16 byte alignment, exactly what we need.
>  	 * The packet length includes FCS, but we don't want to
>  	 * include that when passing upstream as it messes up
> @@ -1109,7 +1125,14 @@ static phy_info_t const phy_info_am79c874 = {
>  /* register definitions for the 8721 */
>  
>  #define MII_KS8721BL_RXERCR	21
> +#ifdef CONFIG_ARCH_MX2
> + /* FIXME: is this a bug or board specific?
> +  * 27 was found somewhere in the Freescale code
> +  */
> +#define MII_KS8721BL_ICSR	27
> +#else
>  #define MII_KS8721BL_ICSR	22
> +#endif
>  #define	MII_KS8721BL_PHYCR	31
>  
>  static phy_cmd_t const phy_cmd_ks8721bl_config[] = {
> @@ -1698,6 +1721,95 @@ static void __inline__ fec_phy_ack_intr(void)
>  {
>  }
>  
> +#elif defined(CONFIG_ARCH_MX2)
> +
> +/*
> + * do some initializtion based architecture of this chip
> + */
> +static void inline fec_arch_init(void)
> +{
> +	struct clk *clk;
> +	clk = clk_get(NULL, "fec_clk");
> +	clk_enable(clk);
> +	clk_put(clk);
> +	return;
> +}

ColdFire builds break on fec_arch_init(), since it is only
defined for ARCH_MX2.

Regards
Greg



> +/*
> + * Code specific to Freescale i.MXC
> + */
> +static void inline fec_request_intrs(struct net_device *dev)
> +{
> +	/* Setup interrupt handlers. */
> +	if (request_irq(MXC_INT_FEC, fec_enet_interrupt, 0, "fec", dev) != 0)
> +		panic("FEC: Could not allocate FEC IRQ(%d)!\n", MXC_INT_FEC);
> +}
> +
> +static void inline fec_set_mii(struct net_device *dev,
> +				   struct fec_enet_private *fep)
> +{
> +	u32 rate;
> +	struct clk *clk;
> +	volatile fec_t *fecp;
> +	fecp = fep->hwp;
> +	fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;
> +	fecp->fec_x_cntrl = 0x00;
> +
> +	/*
> +	 * Set MII speed to 2.5 MHz
> +	 */
> +	clk = clk_get(NULL, "fec_clk");
> +	rate = clk_get_rate(clk);
> +	clk_put(clk);
> +
> +	fep->phy_speed = ((((rate / 2 + 4999999) / 2500000) / 2) & 0x3F) << 1;
> +	fecp->fec_mii_speed = fep->phy_speed;
> +	fec_restart(dev, 0);
> +}
> +
> +static void inline fec_get_mac(struct net_device *dev)
> +{
> +	struct fec_enet_private *fep = netdev_priv(dev);
> +	volatile fec_t *fecp;
> +	unsigned char *iap, tmpaddr[ETH_ALEN];
> +	int i;
> +	unsigned long l;
> +	unsigned char mac_preinitialized = 0;
> +	fecp = fep->hwp;
> +
> +	/* check if mac address was already initialized by firmware */
> +	l = fecp->fec_addr_low;
> +	tmpaddr[0] = (unsigned char)((l & 0xFF000000) >> 24);
> +	tmpaddr[1] = (unsigned char)((l & 0x00FF0000) >> 16);
> +	tmpaddr[2] = (unsigned char)((l & 0x0000FF00) >> 8);
> +	tmpaddr[3] = (unsigned char)((l & 0x000000FF) >> 0);
> +	l = fecp->fec_addr_high;
> +	tmpaddr[4] = (unsigned char)((l & 0xFF000000) >> 24);
> +	tmpaddr[5] = (unsigned char)((l & 0x00FF0000) >> 16);
> +
> +	for (i = 0; i < ETH_ALEN; i++)
> +		mac_preinitialized |= tmpaddr[i];
> +
> +	if (mac_preinitialized) {
> +		iap = &tmpaddr[0];
> +		memcpy(dev->dev_addr, iap, ETH_ALEN);
> +	}
> +}
> +
> +static void inline fec_disable_phy_intr(void)
> +{
> +}
> +
> +static void inline fec_phy_ack_intr(void)
> +{
> +}
> +
> +static void inline fec_localhw_setup(void)
> +{
> +}
> +
> +/* ------------------------------------------------------------------------- */
> +
>  #endif
>  
>  /* ------------------------------------------------------------------------- */
> @@ -2404,6 +2516,7 @@ static int __init fec_enet_module_init(void)
>  	int i, err;
>  
>  	printk("FEC ENET Version 0.2\n");
> +	fec_arch_init();
>  
>  	for (i = 0; (i < FEC_MAX_PORTS); i++) {
>  		dev = alloc_etherdev(sizeof(struct fec_enet_private));
> diff --git a/drivers/net/fec.h b/drivers/net/fec.h
> index 292719d..ca36ea0 100644
> --- a/drivers/net/fec.h
> +++ b/drivers/net/fec.h
> @@ -14,7 +14,7 @@
>  /****************************************************************************/
>  
>  #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
> -    defined(CONFIG_M520x) || defined(CONFIG_M532x)
> +    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARCH_MX2)
>  /*
>   *	Just figures, Motorola would have to change the offsets for
>   *	registers in the same peripheral device on different models
> @@ -103,12 +103,19 @@ typedef struct fec {
>  /*
>   *	Define the buffer descriptor structure.
>   */
> +#ifdef CONFIG_ARCH_MXC
> +typedef struct bufdesc {
> +	unsigned short cbd_datlen;	/* Data length */
> +	unsigned short cbd_sc;	/* Control and status info */
> +	unsigned long cbd_bufaddr;	/* Buffer address */
> +} cbd_t;
> +#else
>  typedef struct bufdesc {
>  	unsigned short	cbd_sc;			/* Control and status info */
>  	unsigned short	cbd_datlen;		/* Data length */
>  	unsigned long	cbd_bufaddr;		/* Buffer address */
>  } cbd_t;
> -
> +#endif
>  
>  /*
>   *	The following definitions courtesy of commproc.h, which where

-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear, a McAfee Company                  PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
