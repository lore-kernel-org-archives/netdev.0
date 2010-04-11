From: Michal Simek <michal.simek@petalogix.com>
Subject: Re: [PATCH 2/2] [V5] Add non-Virtex5 support for LL TEMAC driver
Date: Sun, 11 Apr 2010 15:16:25 +0200
Message-ID: <4BC1CBA9.9050403@petalogix.com>
References: <1270746482-29914-1-git-send-email-john.linn@xilinx.com> <960dddba-8a63-4480-8245-f06fad59ab36@SG2EHSMHS005.ehs.local>
Reply-To: michal.simek@petalogix.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	eric.dumazet@gmail.com, john.williams@petalogix.com,
	John Tyner <jtyner@cs.ucr.edu>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:43508 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977Ab0DKNQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 09:16:35 -0400
Received: by bwz19 with SMTP id 19so294795bwz.21
        for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 06:16:33 -0700 (PDT)
In-Reply-To: <960dddba-8a63-4480-8245-f06fad59ab36@SG2EHSMHS005.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Linn wrote:
> This patch adds support for using the LL TEMAC Ethernet driver on
> non-Virtex 5 platforms by adding support for accessing the Soft DMA
> registers as if they were memory mapped instead of solely through the
> DCR's (available on the Virtex 5).
> 
> The patch also updates the driver so that it runs on the MicroBlaze.
> The changes were tested on the PowerPC 440, PowerPC 405, and the
> MicroBlaze platforms.
> 
> Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> Signed-off-by: John Linn <john.linn@xilinx.com>
> 
> ---
> 
> V2 - Incorporated comments from Grant and added more logic to allow the driver
> to work on MicroBlaze.
> 
> V3 - Only updated it to apply to head, minor change to include slab.h. Also
> verified that it now builds for MicroBlaze. Retested on PowerPC and MicroBlaze.
> 
> V4 - Removed buffer alignment for skb and called the network functions that
> already do the alignment for cache line and word alignment. Added constants
> to MicroBlaze system to make sure network alignment is maintained. Also updated
> the Kconfig so it depends on Microblaze or PPC based on Grant's comment.
> 
> V5 - Respun the patch on top of a new patch to the driver which removed the
> call to virt_to_bus as it's now illegal and caused a failure when building
> the driver in linux-next. Retested with 440, 405 and Microblaze.
> 
> Grant, can you do a build test to verify no build issues?
> ---
>  arch/microblaze/include/asm/system.h |   11 +++
>  drivers/net/Kconfig                  |    2 +-
>  drivers/net/ll_temac.h               |   14 +++-
>  drivers/net/ll_temac_main.c          |  137 +++++++++++++++++++++++++--------
>  4 files changed, 126 insertions(+), 38 deletions(-)
> 
> diff --git a/arch/microblaze/include/asm/system.h b/arch/microblaze/include/asm/system.h
> index 59efb3f..48c4f03 100644
> --- a/arch/microblaze/include/asm/system.h
> +++ b/arch/microblaze/include/asm/system.h
> @@ -12,6 +12,7 @@
>  #include <asm/registers.h>
>  #include <asm/setup.h>
>  #include <asm/irqflags.h>
> +#include <asm/cache.h>
>  
>  #include <asm-generic/cmpxchg.h>
>  #include <asm-generic/cmpxchg-local.h>
> @@ -96,4 +97,14 @@ extern struct dentry *of_debugfs_root;
>  
>  #define arch_align_stack(x) (x)
>  
> +/*
> + * MicroBlaze doesn't handle unaligned accesses in hardware.
> + *
> + * Based on this we force the IP header alignment in network drivers.
> + * We also modify NET_SKB_PAD to be a cacheline in size, thus maintaining
> + * cacheline alignment of buffers.
> + */
> +#define NET_IP_ALIGN	2
> +#define NET_SKB_PAD	L1_CACHE_BYTES
> +
>  #endif /* _ASM_MICROBLAZE_SYSTEM_H */

I personally prefer to separate this from this patch as we did with 
ioread/iowrite.

Michal



> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 7b832c7..9073741 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2434,8 +2434,8 @@ config MV643XX_ETH
>  
>  config XILINX_LL_TEMAC
>  	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC) driver"
> +	depends on PPC || MICROBLAZE
>  	select PHYLIB
> -	depends on PPC_DCR_NATIVE
>  	help
>  	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
>  	  core used in Xilinx Spartan and Virtex FPGAs
> diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
> index 1af66a1..c033584 100644
> --- a/drivers/net/ll_temac.h
> +++ b/drivers/net/ll_temac.h
> @@ -5,8 +5,11 @@
>  #include <linux/netdevice.h>
>  #include <linux/of.h>
>  #include <linux/spinlock.h>
> +
> +#ifdef CONFIG_PPC_DCR
>  #include <asm/dcr.h>
>  #include <asm/dcr-regs.h>
> +#endif
>  
>  /* packet size info */
>  #define XTE_HDR_SIZE			14      /* size of Ethernet header */
> @@ -290,9 +293,6 @@ This option defaults to enabled (set) */
>  
>  #define TX_CONTROL_CALC_CSUM_MASK   1
>  
> -#define XTE_ALIGN       32
> -#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_ALIGN)
> -
>  #define MULTICAST_CAM_TABLE_NUM 4
>  
>  /* TX/RX CURDESC_PTR points to first descriptor */
> @@ -335,9 +335,15 @@ struct temac_local {
>  	struct mii_bus *mii_bus;	/* MII bus reference */
>  	int mdio_irqs[PHY_MAX_ADDR];	/* IRQs table for MDIO bus */
>  
> -	/* IO registers and IRQs */
> +	/* IO registers, dma functions and IRQs */
>  	void __iomem *regs;
> +	void __iomem *sdma_regs;
> +#ifdef CONFIG_PPC_DCR
>  	dcr_host_t sdma_dcrs;
> +#endif
> +	u32 (*dma_in)(struct temac_local *, int);
> +	void (*dma_out)(struct temac_local *, int, u32);
> +
>  	int tx_irq;
>  	int rx_irq;
>  	int emac_num;
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
> index ce9aa78..2b69d6c 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -20,9 +20,6 @@
>   *   or rx, so this should be okay.
>   *
>   * TODO:
> - * - Fix driver to work on more than just Virtex5.  Right now the driver
> - *   assumes that the locallink DMA registers are accessed via DCR
> - *   instructions.
>   * - Factor out locallink DMA code into separate driver
>   * - Fix multicast assignment.
>   * - Fix support for hardware checksumming.
> @@ -116,17 +113,86 @@ void temac_indirect_out32(struct temac_local *lp, int reg, u32 value)
>  	temac_iow(lp, XTE_CTL0_OFFSET, CNTLREG_WRITE_ENABLE_MASK | reg);
>  }
>  
> +/**
> + * temac_dma_in32 - Memory mapped DMA read, this function expects a
> + * register input that is based on DCR word addresses which
> + * are then converted to memory mapped byte addresses
> + */
>  static u32 temac_dma_in32(struct temac_local *lp, int reg)
>  {
> -	return dcr_read(lp->sdma_dcrs, reg);
> +	return in_be32((u32 *)(lp->sdma_regs + (reg << 2)));
>  }
>  
> +/**
> + * temac_dma_out32 - Memory mapped DMA read, this function expects a
> + * register input that is based on DCR word addresses which
> + * are then converted to memory mapped byte addresses
> + */
>  static void temac_dma_out32(struct temac_local *lp, int reg, u32 value)
>  {
> +	out_be32((u32 *)(lp->sdma_regs + (reg << 2)), value);
> +}
> +
> +/* DMA register access functions can be DCR based or memory mapped.
> + * The PowerPC 440 is DCR based, the PowerPC 405 and MicroBlaze are both
> + * memory mapped.
> + */
> +#ifdef CONFIG_PPC_DCR
> +
> +/**
> + * temac_dma_dcr_in32 - DCR based DMA read
> + */
> +static u32 temac_dma_dcr_in(struct temac_local *lp, int reg)
> +{
> +	return dcr_read(lp->sdma_dcrs, reg);
> +}
> +
> +/**
> + * temac_dma_dcr_out32 - DCR based DMA write
> + */
> +static void temac_dma_dcr_out(struct temac_local *lp, int reg, u32 value)
> +{
>  	dcr_write(lp->sdma_dcrs, reg, value);
>  }
>  
>  /**
> + * temac_dcr_setup - If the DMA is DCR based, then setup the address and
> + * I/O  functions
> + */
> +static int temac_dcr_setup(struct temac_local *lp, struct of_device *op,
> +				struct device_node *np)
> +{
> +	unsigned int dcrs;
> +
> +	/* setup the dcr address mapping if it's in the device tree */
> +
> +	dcrs = dcr_resource_start(np, 0);
> +	if (dcrs != 0) {
> +		lp->sdma_dcrs = dcr_map(np, dcrs, dcr_resource_len(np, 0));
> +		lp->dma_in = temac_dma_dcr_in;
> +		lp->dma_out = temac_dma_dcr_out;
> +		dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
> +		return 0;
> +	}
> +	/* no DCR in the device tree, indicate a failure */
> +	return -1;
> +}
> +
> +#else
> +
> +/*
> + * temac_dcr_setup - This is a stub for when DCR is not supported,
> + * such as with MicroBlaze
> + */
> +static int temac_dcr_setup(struct temac_local *lp, struct of_device *op,
> +				struct device_node *np)
> +{
> +	return -1;
> +}
> +
> +#endif
> +
> +/**
>   * temac_dma_bd_init - Setup buffer descriptor rings
>   */
>  static int temac_dma_bd_init(struct net_device *ndev)
> @@ -156,14 +222,14 @@ static int temac_dma_bd_init(struct net_device *ndev)
>  		lp->rx_bd_v[i].next = lp->rx_bd_p +
>  				sizeof(*lp->rx_bd_v) * ((i + 1) % RX_BD_NUM);
>  
> -		skb = alloc_skb(XTE_MAX_JUMBO_FRAME_SIZE
> -				+ XTE_ALIGN, GFP_ATOMIC);
> +		skb = netdev_alloc_skb_ip_align(ndev,
> +						XTE_MAX_JUMBO_FRAME_SIZE);
> +
>  		if (skb == 0) {
>  			dev_err(&ndev->dev, "alloc_skb error %d\n", i);
>  			return -1;
>  		}
>  		lp->rx_skb[i] = skb;
> -		skb_reserve(skb,  BUFFER_ALIGN(skb->data));
>  		/* returns physical address of skb->data */
>  		lp->rx_bd_v[i].phys = dma_map_single(ndev->dev.parent,
>  						     skb->data,
> @@ -173,23 +239,23 @@ static int temac_dma_bd_init(struct net_device *ndev)
>  		lp->rx_bd_v[i].app0 = STS_CTRL_APP0_IRQONEND;
>  	}
>  
> -	temac_dma_out32(lp, TX_CHNL_CTRL, 0x10220400 |
> +	lp->dma_out(lp, TX_CHNL_CTRL, 0x10220400 |
>  					  CHNL_CTRL_IRQ_EN |
>  					  CHNL_CTRL_IRQ_DLY_EN |
>  					  CHNL_CTRL_IRQ_COAL_EN);
>  	/* 0x10220483 */
>  	/* 0x00100483 */
> -	temac_dma_out32(lp, RX_CHNL_CTRL, 0xff010000 |
> +	lp->dma_out(lp, RX_CHNL_CTRL, 0xff010000 |
>  					  CHNL_CTRL_IRQ_EN |
>  					  CHNL_CTRL_IRQ_DLY_EN |
>  					  CHNL_CTRL_IRQ_COAL_EN |
>  					  CHNL_CTRL_IRQ_IOE);
>  	/* 0xff010283 */
>  
> -	temac_dma_out32(lp, RX_CURDESC_PTR,  lp->rx_bd_p);
> -	temac_dma_out32(lp, RX_TAILDESC_PTR,
> +	lp->dma_out(lp, RX_CURDESC_PTR,  lp->rx_bd_p);
> +	lp->dma_out(lp, RX_TAILDESC_PTR,
>  		       lp->rx_bd_p + (sizeof(*lp->rx_bd_v) * (RX_BD_NUM - 1)));
> -	temac_dma_out32(lp, TX_CURDESC_PTR, lp->tx_bd_p);
> +	lp->dma_out(lp, TX_CURDESC_PTR, lp->tx_bd_p);
>  
>  	return 0;
>  }
> @@ -427,9 +493,9 @@ static void temac_device_reset(struct net_device *ndev)
>  	temac_indirect_out32(lp, XTE_RXC1_OFFSET, val & ~XTE_RXC1_RXEN_MASK);
>  
>  	/* Reset Local Link (DMA) */
> -	temac_dma_out32(lp, DMA_CONTROL_REG, DMA_CONTROL_RST);
> +	lp->dma_out(lp, DMA_CONTROL_REG, DMA_CONTROL_RST);
>  	timeout = 1000;
> -	while (temac_dma_in32(lp, DMA_CONTROL_REG) & DMA_CONTROL_RST) {
> +	while (lp->dma_in(lp, DMA_CONTROL_REG) & DMA_CONTROL_RST) {
>  		udelay(1);
>  		if (--timeout == 0) {
>  			dev_err(&ndev->dev,
> @@ -437,7 +503,7 @@ static void temac_device_reset(struct net_device *ndev)
>  			break;
>  		}
>  	}
> -	temac_dma_out32(lp, DMA_CONTROL_REG, DMA_TAIL_ENABLE);
> +	lp->dma_out(lp, DMA_CONTROL_REG, DMA_TAIL_ENABLE);
>  
>  	temac_dma_bd_init(ndev);
>  
> @@ -598,7 +664,7 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  		lp->tx_bd_tail = 0;
>  
>  	/* Kick off the transfer */
> -	temac_dma_out32(lp, TX_TAILDESC_PTR, tail_p); /* DMA start */
> +	lp->dma_out(lp, TX_TAILDESC_PTR, tail_p); /* DMA start */
>  
>  	return NETDEV_TX_OK;
>  }
> @@ -638,16 +704,15 @@ static void ll_temac_recv(struct net_device *ndev)
>  		ndev->stats.rx_packets++;
>  		ndev->stats.rx_bytes += length;
>  
> -		new_skb = alloc_skb(XTE_MAX_JUMBO_FRAME_SIZE + XTE_ALIGN,
> -				GFP_ATOMIC);
> +		new_skb = netdev_alloc_skb_ip_align(ndev,
> +						XTE_MAX_JUMBO_FRAME_SIZE);
> +
>  		if (new_skb == 0) {
>  			dev_err(&ndev->dev, "no memory for new sk_buff\n");
>  			spin_unlock_irqrestore(&lp->rx_lock, flags);
>  			return;
>  		}
>  
> -		skb_reserve(new_skb, BUFFER_ALIGN(new_skb->data));
> -
>  		cur_p->app0 = STS_CTRL_APP0_IRQONEND;
>  		cur_p->phys = dma_map_single(ndev->dev.parent, new_skb->data,
>  					     XTE_MAX_JUMBO_FRAME_SIZE,
> @@ -662,7 +727,7 @@ static void ll_temac_recv(struct net_device *ndev)
>  		cur_p = &lp->rx_bd_v[lp->rx_bd_ci];
>  		bdstat = cur_p->app0;
>  	}
> -	temac_dma_out32(lp, RX_TAILDESC_PTR, tail_p);
> +	lp->dma_out(lp, RX_TAILDESC_PTR, tail_p);
>  
>  	spin_unlock_irqrestore(&lp->rx_lock, flags);
>  }
> @@ -673,8 +738,8 @@ static irqreturn_t ll_temac_tx_irq(int irq, void *_ndev)
>  	struct temac_local *lp = netdev_priv(ndev);
>  	unsigned int status;
>  
> -	status = temac_dma_in32(lp, TX_IRQ_REG);
> -	temac_dma_out32(lp, TX_IRQ_REG, status);
> +	status = lp->dma_in(lp, TX_IRQ_REG);
> +	lp->dma_out(lp, TX_IRQ_REG, status);
>  
>  	if (status & (IRQ_COAL | IRQ_DLY))
>  		temac_start_xmit_done(lp->ndev);
> @@ -691,8 +756,8 @@ static irqreturn_t ll_temac_rx_irq(int irq, void *_ndev)
>  	unsigned int status;
>  
>  	/* Read and clear the status registers */
> -	status = temac_dma_in32(lp, RX_IRQ_REG);
> -	temac_dma_out32(lp, RX_IRQ_REG, status);
> +	status = lp->dma_in(lp, RX_IRQ_REG);
> +	lp->dma_out(lp, RX_IRQ_REG, status);
>  
>  	if (status & (IRQ_COAL | IRQ_DLY))
>  		ll_temac_recv(lp->ndev);
> @@ -793,7 +858,7 @@ static ssize_t temac_show_llink_regs(struct device *dev,
>  	int i, len = 0;
>  
>  	for (i = 0; i < 0x11; i++)
> -		len += sprintf(buf + len, "%.8x%s", temac_dma_in32(lp, i),
> +		len += sprintf(buf + len, "%.8x%s", lp->dma_in(lp, i),
>  			       (i % 8) == 7 ? "\n" : " ");
>  	len += sprintf(buf + len, "\n");
>  
> @@ -819,7 +884,6 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
>  	struct net_device *ndev;
>  	const void *addr;
>  	int size, rc = 0;
> -	unsigned int dcrs;
>  
>  	/* Init network device structure */
>  	ndev = alloc_etherdev(sizeof(*lp));
> @@ -869,13 +933,20 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
>  		goto nodev;
>  	}
>  
> -	dcrs = dcr_resource_start(np, 0);
> -	if (dcrs == 0) {
> -		dev_err(&op->dev, "could not get DMA register address\n");
> -		goto nodev;
> +	/* Setup the DMA register accesses, could be DCR or memory mapped */
> +	if (temac_dcr_setup(lp, op, np)) {
> +
> +		/* no DCR in the device tree, try non-DCR */
> +		lp->sdma_regs = of_iomap(np, 0);
> +		if (lp->sdma_regs) {
> +			lp->dma_in = temac_dma_in32;
> +			lp->dma_out = temac_dma_out32;
> +			dev_dbg(&op->dev, "MEM base: %p\n", lp->sdma_regs);
> +		} else {
> +			dev_err(&op->dev, "unable to map DMA registers\n");
> +			goto nodev;
> +		}
>  	}
> -	lp->sdma_dcrs = dcr_map(np, dcrs, dcr_resource_len(np, 0));
> -	dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
>  
>  	lp->rx_irq = irq_of_parse_and_map(np, 0);
>  	lp->tx_irq = irq_of_parse_and_map(np, 1);


-- 
Michal Simek, Ing. (M.Eng)
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f: +61-7-30090663
