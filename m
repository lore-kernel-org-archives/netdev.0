From: U Bhaskar-B22300 <B22300@freescale.com>
Subject: RE: [PATCH 3/4] powerpc/p1010: FlexCAN Controller for of_ type
Date: Tue, 9 Aug 2011 10:29:44 +0000
Message-ID: <9C64B7751C3BCA41B64A68E23005A7BE1BF197@039-SN1MPN1-004.039d.mgd.msft.net>
References: <1312815640-25804-1-git-send-email-bhaskar.upadhaya@freescale.com>
 <4E3FFEEB.8070400@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"holt@sgi.com" <holt@sgi.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linuxppc-release@linux.freescale.net"
	<linuxppc-release@linux.freescale.net>,
	"socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:35321
	"EHLO AM1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752804Ab1HIK3v convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 06:29:51 -0400
In-Reply-To: <4E3FFEEB.8070400@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
> Sent: Monday, August 08, 2011 8:51 PM
> To: U Bhaskar-B22300
> Cc: netdev@vger.kernel.org; holt@sgi.com; wg@grandegger.com;
> davem@davemloft.net; linuxppc-release@linux.freescale.net; U Bhaskar-
> B22300; socketcan-core@lists.berlios.de
> Subject: Re: [PATCH 3/4] powerpc/p1010: FlexCAN Controller for of_ type
> 
> On 08/08/2011 05:00 PM, Bhaskar Upadhaya wrote:
> > Provide FlexCAN support for Freescale P1010 SoC.
> > Modify the existing FlexCAN, so as to support the of_type approach on
> > P1010(power architecture based)SoC.
> >
> > FlexCAN is a communication controller implementing the CAN protocol
> > according to the CAN 2.0B protocol specification.
> > This controller is available on Freescale P1010 platform.
> > Signed-off-by: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
> 
> NACK - your patch does more than the description states (debug code).
[Bhaskar] Ok I will change description as below
	This patch introduces the following features
	1. provides the support for FlexCAN on P1010 SoC.
	2. Provides the common read/write interface for ARM and PowerPC based FlexCAN.
	3. Provides the clock interface for PowerPC based FlexCAN.
	Will it be OK ?

> Further you still add bugs to the driver. I've send you patches to fix
> them.
[Bhaskar] Please mention what sort of BUG you are seeing ..
	    
> 
> Marc
> 
> > ---
> > Based on
> > git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
> >  Branch master
> >
> >  drivers/net/can/Kconfig         |    8 +-
> >  drivers/net/can/Makefile        |    4 +-
> >  drivers/net/can/flexcan.c       |  162 ++++++++++++------------
> >  drivers/net/can/flexcan_iface.c |  261
> > +++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 349 insertions(+), 86 deletions(-)  create mode
> > 100644 drivers/net/can/flexcan_iface.c
> >
> > diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig index
> > f6c98fb..882da54 100644
> > --- a/drivers/net/can/Kconfig
> > +++ b/drivers/net/can/Kconfig
> > @@ -98,9 +98,12 @@ config HAVE_CAN_FLEXCAN
> >
> >  config CAN_FLEXCAN
> >  	tristate "Support for Freescale FLEXCAN based chips"
> > -	depends on CAN_DEV && HAVE_CAN_FLEXCAN
> > +	depends on CAN_DEV && (!ARM || HAVE_CAN_FLEXCAN)
> > +	select PPC_CLOCK
> >  	---help---
> > -	  Say Y here if you want to support for Freescale FlexCAN.
> > +	  Say Y here if you want support for Freescale FlexCAN.
> > +	  Flexcan Module is implementing the CAN Protocol
> > +	  version 2.0
> >
> >  config PCH_CAN
> >  	tristate "PCH CAN"
> > @@ -123,6 +126,7 @@ source "drivers/net/can/softing/Kconfig"
> >  config CAN_DEBUG_DEVICES
> >  	bool "CAN devices debugging messages"
> >  	depends on CAN
> > +	default N
> >  	---help---
> >  	  Say Y here if you want the CAN device drivers to produce a bunch
> of
> >  	  debug messages to the system log.  Select this if you are having
> > diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile index
> > 24ebfe8..4965e6f 100644
> > --- a/drivers/net/can/Makefile
> > +++ b/drivers/net/can/Makefile
> > @@ -19,7 +19,9 @@ obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
> >  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
> >  obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
> >  obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
> > -obj-$(CONFIG_CAN_FLEXCAN)	+= flexcan.o
> > +obj-$(CONFIG_CAN_FLEXCAN)	+= flexcan_driver.o
> > +flexcan_driver-objs := flexcan.o \
> > +		flexcan_iface.o
> >  obj-$(CONFIG_PCH_CAN)		+= pch_can.o
> >
> >  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG diff --git
> > a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c index
> > a24aa12..1c1af24 100644
> > --- a/drivers/net/can/flexcan.c
> > +++ b/drivers/net/can/flexcan.c
> > @@ -22,10 +22,8 @@
> >
> >  #include <linux/netdevice.h>
> >  #include <linux/can.h>
> > -#include <linux/can/dev.h>
> >  #include <linux/can/error.h>
> >  #include <linux/can/platform/flexcan.h> -#include <linux/clk.h>
> > #include <linux/delay.h>  #include <linux/if_arp.h>  #include
> > <linux/if_ether.h> @@ -34,11 +32,6 @@  #include <linux/kernel.h>
> > #include <linux/list.h>  #include <linux/module.h> -#include
> > <linux/platform_device.h>
> > -
> > -#include <mach/clock.h>
> > -
> > -#define DRV_NAME			"flexcan"
> >
> >  /* 8 for RX fifo and 2 error handling */
> >  #define FLEXCAN_NAPI_WEIGHT		(8 + 2)
> > @@ -167,19 +160,6 @@ struct flexcan_regs {
> >  	struct flexcan_mb cantxfg[64];
> >  };
> >
> > -struct flexcan_priv {
> > -	struct can_priv can;
> > -	struct net_device *dev;
> > -	struct napi_struct napi;
> > -
> > -	void __iomem *base;
> > -	u32 reg_esr;
> > -	u32 reg_ctrl_default;
> > -
> > -	struct clk *clk;
> > -	struct flexcan_platform_data *pdata;
> > -};
> > -
> >  static struct can_bittiming_const flexcan_bittiming_const = {
> >  	.name = DRV_NAME,
> >  	.tseg1_min = 4,
> > @@ -229,9 +209,10 @@ static inline void flexcan_chip_enable(struct
> flexcan_priv *priv)
> >  	struct flexcan_regs __iomem *regs = priv->base;
> >  	u32 reg;
> >
> > -	reg = readl(&regs->mcr);
> > +	reg = flexcan_read(&regs->mcr);
> > +
> >  	reg &= ~FLEXCAN_MCR_MDIS;
> > -	writel(reg, &regs->mcr);
> > +	flexcan_write(reg, &regs->mcr);
> >
> >  	udelay(10);
> >  }
> > @@ -248,9 +229,10 @@ static inline void flexcan_chip_disable(struct
> flexcan_priv *priv)
> >  	struct flexcan_regs __iomem *regs = priv->base;
> >  	u32 reg;
> >
> > -	reg = readl(&regs->mcr);
> > +	reg = flexcan_read(&regs->mcr);
> > +
> >  	reg |= FLEXCAN_MCR_MDIS;
> > -	writel(reg, &regs->mcr);
> > +	flexcan_write(reg, &regs->mcr);
> >  }
> >
> >  /**
> > @@ -266,9 +248,9 @@ static int flexcan_get_berr_counter(const struct
> > net_device *dev,  {
> >  	const struct flexcan_priv *priv = netdev_priv(dev);
> >  	struct flexcan_regs __iomem *regs = priv->base;
> > -	u32 reg = readl(&regs->ecr);
> >
> > -	bec->txerr = (reg >> 0) & 0xff;
> > +	u32 reg = flexcan_read(&regs->ecr);
> > +	bec->txerr = reg & 0xff;
> >  	bec->rxerr = (reg >> 8) & 0xff;
> >
> >  	return 0;
> > @@ -294,6 +276,7 @@ static int flexcan_start_xmit(struct sk_buff *skb,
> struct net_device *dev)
> >  	u32 can_id;
> >  	u32 ctrl = FLEXCAN_MB_CNT_CODE(0xc) | (cf->can_dlc << 16);
> >
> > +	flexcan_reg_dump(dev);
> >  	if (can_dropped_invalid_skb(dev, skb))
> >  		return NETDEV_TX_OK;
> >
> > @@ -311,21 +294,24 @@ static int flexcan_start_xmit(struct sk_buff
> > *skb, struct net_device *dev)
> >
> >  	if (cf->can_dlc > 0) {
> >  		u32 data = be32_to_cpup((__be32 *)&cf->data[0]);
> > -		writel(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[0]);
> > +		flexcan_write(data,
> > +			&regs->cantxfg[FLEXCAN_TX_BUF_ID].data[0]);
> >  	}
> >  	if (cf->can_dlc > 3) {
> >  		u32 data = be32_to_cpup((__be32 *)&cf->data[4]);
> > -		writel(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[1]);
> > +		flexcan_write(data,
> > +			&regs->cantxfg[FLEXCAN_TX_BUF_ID].data[1]);
> >  	}
> >
> > -	writel(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
> > -	writel(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
> > +	flexcan_write(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
> > +	flexcan_write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
> >
> >  	kfree_skb(skb);
> >
> >  	/* tx_packets is incremented in flexcan_irq */
> >  	stats->tx_bytes += cf->can_dlc;
> >
> > +	flexcan_reg_dump(dev);
> >  	return NETDEV_TX_OK;
> >  }
> >
> > @@ -440,7 +426,8 @@ static void do_state(struct net_device *dev,
> >  				CAN_ERR_CRTL_TX_WARNING :
> >  				CAN_ERR_CRTL_RX_WARNING;
> >  		}
> > -	case CAN_STATE_ERROR_WARNING:	/* fallthrough */
> > +		/* fallthrough */
> > +	case CAN_STATE_ERROR_WARNING:
> >  		/*
> >  		 * from: ERROR_ACTIVE, ERROR_WARNING
> >  		 * to  : ERROR_PASSIVE, BUS_OFF
> > @@ -536,8 +523,8 @@ static void flexcan_read_fifo(const struct
> net_device *dev,
> >  	struct flexcan_mb __iomem *mb = &regs->cantxfg[0];
> >  	u32 reg_ctrl, reg_id;
> >
> > -	reg_ctrl = readl(&mb->can_ctrl);
> > -	reg_id = readl(&mb->can_id);
> > +	reg_ctrl = flexcan_read(&mb->can_ctrl);
> > +	reg_id = flexcan_read(&mb->can_id);
> >  	if (reg_ctrl & FLEXCAN_MB_CNT_IDE)
> >  		cf->can_id = ((reg_id >> 0) & CAN_EFF_MASK) | CAN_EFF_FLAG;
> >  	else
> > @@ -547,12 +534,13 @@ static void flexcan_read_fifo(const struct
> net_device *dev,
> >  		cf->can_id |= CAN_RTR_FLAG;
> >  	cf->can_dlc = get_can_dlc((reg_ctrl >> 16) & 0xf);
> >
> > -	*(__be32 *)(cf->data + 0) = cpu_to_be32(readl(&mb->data[0]));
> > -	*(__be32 *)(cf->data + 4) = cpu_to_be32(readl(&mb->data[1]));
> > +	*(__be32 *) (&cf->data[0]) =
> > +	    cpu_to_be32(flexcan_read(&mb->data[0]));
> > +	*(__be32 *) (&cf->data[4]) =
> > +	    cpu_to_be32(flexcan_read(&mb->data[1]));
> >
> >  	/* mark as read */
> > -	writel(FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
> > -	readl(&regs->timer);
> > +	flexcan_write(FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
> >  }
> >
> >  static int flexcan_read_frame(struct net_device *dev) @@ -596,17
> > +584,17 @@ static int flexcan_poll(struct napi_struct *napi, int quota)
> >  	 * The error bits are cleared on read,
> >  	 * use saved value from irq handler.
> >  	 */
> > -	reg_esr = readl(&regs->esr) | priv->reg_esr;
> > +	reg_esr = flexcan_read(&regs->esr) | priv->reg_esr;
> >
> >  	/* handle state changes */
> >  	work_done += flexcan_poll_state(dev, reg_esr);
> >
> >  	/* handle RX-FIFO */
> > -	reg_iflag1 = readl(&regs->iflag1);
> > -	while (reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_AVAILABLE &&
> > -	       work_done < quota) {
> > +	reg_iflag1 = flexcan_read(&regs->iflag1);
> > +	while ((reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_AVAILABLE) &&
> > +	       (work_done < quota)) {
> >  		work_done += flexcan_read_frame(dev);
> > -		reg_iflag1 = readl(&regs->iflag1);
> > +		reg_iflag1 = flexcan_read(&regs->iflag1);
> >  	}
> >
> >  	/* report bus errors */
> > @@ -616,8 +604,8 @@ static int flexcan_poll(struct napi_struct *napi,
> int quota)
> >  	if (work_done < quota) {
> >  		napi_complete(napi);
> >  		/* enable IRQs */
> > -		writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
> > -		writel(priv->reg_ctrl_default, &regs->ctrl);
> > +		flexcan_write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
> > +		flexcan_write(priv->reg_ctrl_default, &regs->ctrl);
> >  	}
> >
> >  	return work_done;
> > @@ -641,9 +629,10 @@ static irqreturn_t flexcan_irq(int irq, void
> *dev_id)
> >  	struct flexcan_regs __iomem *regs = priv->base;
> >  	u32 reg_iflag1, reg_esr;
> >
> > -	reg_iflag1 = readl(&regs->iflag1);
> > -	reg_esr = readl(&regs->esr);
> > -	writel(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
> > +	flexcan_reg_dump(dev);
> > +	reg_iflag1 = flexcan_read(&regs->iflag1);
> > +	reg_esr = flexcan_read(&regs->esr);
> > +	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);/* ACK err IRQ */
> >
> >  	/*
> >  	 * schedule NAPI in case of:
> > @@ -659,16 +648,17 @@ static irqreturn_t flexcan_irq(int irq, void
> *dev_id)
> >  		 * save them for later use.
> >  		 */
> >  		priv->reg_esr = reg_esr & FLEXCAN_ESR_ERR_BUS;
> > -		writel(FLEXCAN_IFLAG_DEFAULT &
> ~FLEXCAN_IFLAG_RX_FIFO_AVAILABLE,
> > -		       &regs->imask1);
> > -		writel(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_ALL,
> > -		       &regs->ctrl);
> > +		flexcan_write(FLEXCAN_IFLAG_DEFAULT &
> > +			~FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->imask1);
> > +		flexcan_write(priv->reg_ctrl_default &
> > +			~FLEXCAN_CTRL_ERR_ALL, &regs->ctrl);
> >  		napi_schedule(&priv->napi);
> >  	}
> >
> >  	/* FIFO overflow */
> >  	if (reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_OVERFLOW) {
> > -		writel(FLEXCAN_IFLAG_RX_FIFO_OVERFLOW, &regs->iflag1);
> > +		flexcan_write(FLEXCAN_IFLAG_RX_FIFO_OVERFLOW,
> > +			&regs->iflag1);
> >  		dev->stats.rx_over_errors++;
> >  		dev->stats.rx_errors++;
> >  	}
> > @@ -677,10 +667,11 @@ static irqreturn_t flexcan_irq(int irq, void
> *dev_id)
> >  	if (reg_iflag1 & (1 << FLEXCAN_TX_BUF_ID)) {
> >  		/* tx_bytes is incremented in flexcan_start_xmit */
> >  		stats->tx_packets++;
> > -		writel((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
> > +		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
> >  		netif_wake_queue(dev);
> >  	}
> >
> > +	flexcan_reg_dump(dev);
> >  	return IRQ_HANDLED;
> >  }
> >
> > @@ -698,7 +689,7 @@ static void flexcan_set_bittiming(struct net_device
> *dev)
> >  	struct flexcan_regs __iomem *regs = priv->base;
> >  	u32 reg;
> >
> > -	reg = readl(&regs->ctrl);
> > +	reg = flexcan_read(&regs->ctrl);
> >  	reg &= ~(FLEXCAN_CTRL_PRESDIV(0xff) |
> >  		 FLEXCAN_CTRL_RJW(0x3) |
> >  		 FLEXCAN_CTRL_PSEG1(0x7) |
> > @@ -722,11 +713,11 @@ static void flexcan_set_bittiming(struct
> net_device *dev)
> >  		reg |= FLEXCAN_CTRL_SMP;
> >
> >  	dev_info(dev->dev.parent, "writing ctrl=0x%08x\n", reg);
> > -	writel(reg, &regs->ctrl);
> > +	flexcan_write(reg, &regs->ctrl);
> >
> >  	/* print chip status */
> >  	dev_dbg(dev->dev.parent, "%s: mcr=0x%08x ctrl=0x%08x\n", __func__,
> > -		readl(&regs->mcr), readl(&regs->ctrl));
> > +		flexcan_read(&regs->mcr), flexcan_read(&regs->ctrl));
> >  }
> >
> >  /**
> > @@ -751,10 +742,10 @@ static int flexcan_chip_start(struct net_device
> *dev)
> >  	flexcan_chip_enable(priv);
> >
> >  	/* soft reset */
> > -	writel(FLEXCAN_MCR_SOFTRST, &regs->mcr);
> > +	flexcan_write(FLEXCAN_MCR_SOFTRST, &regs->mcr);
> >  	udelay(10);
> >
> > -	reg_mcr = readl(&regs->mcr);
> > +	reg_mcr = flexcan_read(&regs->mcr);
> >  	if (reg_mcr & FLEXCAN_MCR_SOFTRST) {
> >  		dev_err(dev->dev.parent,
> >  			"Failed to softreset can module (mcr=0x%08x)\n", @@ -
> 776,12
> > +767,12 @@ static int flexcan_chip_start(struct net_device *dev)
> >  	 * choose format C
> >  	 *
> >  	 */
> > -	reg_mcr = readl(&regs->mcr);
> > +	reg_mcr = flexcan_read(&regs->mcr);
> >  	reg_mcr |= FLEXCAN_MCR_FRZ | FLEXCAN_MCR_FEN | FLEXCAN_MCR_HALT |
> >  		FLEXCAN_MCR_SUPV | FLEXCAN_MCR_WRN_EN |
> >  		FLEXCAN_MCR_IDAM_C;
> >  	dev_dbg(dev->dev.parent, "%s: writing mcr=0x%08x", __func__,
> reg_mcr);
> > -	writel(reg_mcr, &regs->mcr);
> > +	flexcan_write(reg_mcr, &regs->mcr);
> >
> >  	/*
> >  	 * CTRL
> > @@ -799,7 +790,7 @@ static int flexcan_chip_start(struct net_device
> *dev)
> >  	 * (FLEXCAN_CTRL_ERR_MSK), too. Otherwise we don't get any
> >  	 * warning or bus passive interrupts.
> >  	 */
> > -	reg_ctrl = readl(&regs->ctrl);
> > +	reg_ctrl = flexcan_read(&regs->ctrl);
> >  	reg_ctrl &= ~FLEXCAN_CTRL_TSYN;
> >  	reg_ctrl |= FLEXCAN_CTRL_BOFF_REC | FLEXCAN_CTRL_LBUF |
> >  		FLEXCAN_CTRL_ERR_STATE | FLEXCAN_CTRL_ERR_MSK; @@ -807,38
> +798,40
> > @@ static int flexcan_chip_start(struct net_device *dev)
> >  	/* save for later use */
> >  	priv->reg_ctrl_default = reg_ctrl;
> >  	dev_dbg(dev->dev.parent, "%s: writing ctrl=0x%08x", __func__,
> reg_ctrl);
> > -	writel(reg_ctrl, &regs->ctrl);
> > +	flexcan_write(reg_ctrl, &regs->ctrl);
> >
> >  	for (i = 0; i < ARRAY_SIZE(regs->cantxfg); i++) {
> > -		writel(0, &regs->cantxfg[i].can_ctrl);
> > -		writel(0, &regs->cantxfg[i].can_id);
> > -		writel(0, &regs->cantxfg[i].data[0]);
> > -		writel(0, &regs->cantxfg[i].data[1]);
> > +		flexcan_write(0, &regs->cantxfg[i].can_ctrl);
> > +		flexcan_write(0, &regs->cantxfg[i].can_id);
> > +		flexcan_write(0, &regs->cantxfg[i].data[0]);
> > +		flexcan_write(0, &regs->cantxfg[i].data[1]);
> >
> >  		/* put MB into rx queue */
> > -		writel(FLEXCAN_MB_CNT_CODE(0x4), &regs->cantxfg[i].can_ctrl);
> > +		flexcan_write(FLEXCAN_MB_CNT_CODE(0x4),
> > +			&regs->cantxfg[i].can_ctrl);
> >  	}
> >
> >  	/* acceptance mask/acceptance code (accept everything) */
> > -	writel(0x0, &regs->rxgmask);
> > -	writel(0x0, &regs->rx14mask);
> > -	writel(0x0, &regs->rx15mask);
> > +	flexcan_write(0x0, &regs->rxgmask);
> > +	flexcan_write(0x0, &regs->rx14mask);
> > +	flexcan_write(0x0, &regs->rx15mask);
> >
> >  	flexcan_transceiver_switch(priv, 1);
> >
> >  	/* synchronize with the can bus */
> > -	reg_mcr = readl(&regs->mcr);
> > +	reg_mcr = flexcan_read(&regs->mcr);
> >  	reg_mcr &= ~FLEXCAN_MCR_HALT;
> > -	writel(reg_mcr, &regs->mcr);
> > +	flexcan_write(reg_mcr, &regs->mcr);
> >
> >  	priv->can.state = CAN_STATE_ERROR_ACTIVE;
> >
> >  	/* enable FIFO interrupts */
> > -	writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
> > +	flexcan_write(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
> >
> >  	/* print chip status */
> >  	dev_dbg(dev->dev.parent, "%s: reading mcr=0x%08x ctrl=0x%08x\n",
> > -		__func__, readl(&regs->mcr), readl(&regs->ctrl));
> > +		__func__, flexcan_read(&regs->mcr),
> > +			flexcan_read(&regs->ctrl));
> >
> >  	return 0;
> >
> > @@ -860,12 +853,12 @@ static void flexcan_chip_stop(struct net_device
> *dev)
> >  	u32 reg;
> >
> >  	/* Disable all interrupts */
> > -	writel(0, &regs->imask1);
> > +	flexcan_write(0, &regs->imask1);
> >
> >  	/* Disable + halt module */
> > -	reg = readl(&regs->mcr);
> > +	reg = flexcan_read(&regs->mcr);
> >  	reg |= FLEXCAN_MCR_MDIS | FLEXCAN_MCR_HALT;
> > -	writel(reg, &regs->mcr);
> > +	flexcan_write(reg, &regs->mcr);
> >
> >  	flexcan_transceiver_switch(priv, 0);
> >  	priv->can.state = CAN_STATE_STOPPED; @@ -935,6 +928,8 @@ static int
> > flexcan_set_mode(struct net_device *dev, enum can_mode mode)
> >  		break;
> >
> >  	default:
> > +		dev_dbg(dev->dev.parent, "Setting flexcan mode(%d) in func %s
> in line"
> > +					"%d \r\n", mode, __func__, __LINE__);
> >  		return -EOPNOTSUPP;
> >  	}
> >
> > @@ -957,24 +952,24 @@ static int __devinit register_flexcandev(struct
> > net_device *dev)
> >
> >  	/* select "bus clock", chip must be disabled */
> >  	flexcan_chip_disable(priv);
> > -	reg = readl(&regs->ctrl);
> > +	reg = flexcan_read(&regs->ctrl);
> >  	reg |= FLEXCAN_CTRL_CLK_SRC;
> > -	writel(reg, &regs->ctrl);
> > +	flexcan_write(reg, &regs->ctrl);
> >
> >  	flexcan_chip_enable(priv);
> >
> >  	/* set freeze, halt and activate FIFO, restrict register access */
> > -	reg = readl(&regs->mcr);
> > +	reg = flexcan_read(&regs->mcr);
> >  	reg |= FLEXCAN_MCR_FRZ | FLEXCAN_MCR_HALT |
> >  		FLEXCAN_MCR_FEN | FLEXCAN_MCR_SUPV;
> > -	writel(reg, &regs->mcr);
> > +	flexcan_write(reg, &regs->mcr);
> >
> >  	/*
> >  	 * Currently we only support newer versions of this core
> >  	 * featuring a RX FIFO. Older cores found on some Coldfire
> >  	 * derivates are not yet supported.
> >  	 */
> > -	reg = readl(&regs->mcr);
> > +	reg = flexcan_read(&regs->mcr);
> >  	if (!(reg & FLEXCAN_MCR_FEN)) {
> >  		dev_err(dev->dev.parent,
> >  			"Could not enable RX FIFO, unsupported core\n"); @@ -
> 984,6 +979,7
> > @@ static int __devinit register_flexcandev(struct net_device *dev)
> >
> >  	err = register_candev(dev);
> >
> > +	return err;
> 
> If you return here, the clock stays enabled....not good
> 
> >   out:
> >  	/* disable core and turn off clocks */
> >  	flexcan_chip_disable(priv);
> > @@ -992,7 +988,7 @@ static int __devinit register_flexcandev(struct
> net_device *dev)
> >  	return err;
> >  }
> >
> > -static void __devexit unregister_flexcandev(struct net_device *dev)
> > +void __devexit unregister_flexcandev(struct net_device *dev)
> >  {
> >  	unregister_candev(dev);
> >  }
> > diff --git a/drivers/net/can/flexcan_iface.c
> > b/drivers/net/can/flexcan_iface.c new file mode 100644 index
> > 0000000..0c5f6dd
> > --- /dev/null
> > +++ b/drivers/net/can/flexcan_iface.c
> > @@ -0,0 +1,261 @@
> > +/*
> > + * flexcan_iface.c
> > + *
> > + * Copyright 2011 Freescale Semiconductor, Inc.
> > + *
> > + * Based on code originally by Andrey Volkov <avolkov@varma-el.com>
> > + *
> > + * LICENCE:
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public License as
> > + * published by the Free Software Foundation version 2.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + *
> > + */
> > +
> > +#include <linux/netdevice.h>
> > +#include <linux/can/platform/flexcan.h>
> > +
> > +struct flexcan_interface flexcan_ops;
> > +
> > +/**
> > + * flexcan_of_get_clk_rate - returns the rate, used for bit-timing
> > + *				calculations of FlexCAN
> > + */
> > +static unsigned long flexcan_of_get_clk_rate(struct clk *clock) {
> > +	return clock->rate;
> > +}
> > +
> > +static void flexcan_of_clk_put(struct clk *clk) {
> > +	kfree(clk);
> > +}
> > +
> > +/**
> > + * flexcan_of_clk_get - calculates the rate, used for bit-timing
> > + *			calculations of FlexCAN
> > + * @dev: the FlexCAN device to be used
> > + * @id: id used to differentiate among different clock nodes
> > + *
> > + * calculate the rate based on the clock-frequency
> > + * and clock-divider values from device tree.
> > + * It calculate the rate being "platform" as the clock source
> > + * Framework for "oscillator" as clock source is also provided.
> > + *
> > + * Return value
> > + *    - On Success
> > + *         the rate as part of clk struct, used to calculate the bit-
> timing
> > + *	   for FlexCAN
> > + *    - On Failure
> > + *	   error value
> > + */
> > +static struct clk *flexcan_of_clk_get(struct device *dev, const char
> > +*id) {
> > +	struct clk *clock;
> > +	u32 *clock_freq = NULL;
> > +	u32 *clock_divider = NULL;
> > +	const char *clk_source;
> > +	int err;
> > +	unsigned long rate;
> > +
> > +	clk_source = (char *)of_get_property(dev->of_node,
> > +			"fsl,flexcan-clock-source", NULL);
> > +	if (clk_source == NULL) {
> > +		dev_err(dev, "Cannot find fsl,flexcan-clock-source"
> > +				"property\n");
> > +		err = -EINVAL;
> > +		goto failed_clock;
> > +	}
> > +	if (!memcmp(clk_source, "platform", strlen(clk_source))) {
> > +		clock_divider = (u32 *)of_get_property(dev->of_node,
> > +				"fsl,flexcan-clock-divider", NULL);
> > +		if (*clock_divider) {
> > +			clock_freq = (u32 *) of_get_property(dev->of_node,
> > +					"clock-frequency", NULL);
> > +			if (clock_freq == NULL) {
> > +				dev_err(dev, "Cannot find clock-frequency"
> > +							"property\n");
> > +				err = -EINVAL;
> > +				goto failed_clock;
> > +			}
> > +			rate = DIV_ROUND_CLOSEST(*clock_freq / *clock_divider,
> > +						1000) * 1000;
> > +		} else {
> > +			dev_err(dev, "Cannot find valid fsl,"
> > +					"flexcan-clock-divider\n");
> > +			err = -EINVAL;
> > +			goto failed_clock;
> > +		}
> > +	} else if (!memcmp(clk_source, "oscillator", strlen(clk_source))) {
> > +		clock_divider = (u32 *)of_get_property(dev->of_node,
> > +				"fsl,flexcan-clock-divider", NULL);
> > +		clock_freq = (u32 *)of_get_property(dev->of_node,
> > +						"clock-frequency", NULL);
> > +		if (!(*clock_divider && *clock_freq)) {
> > +			dev_err(dev, "Cannot find valid"
> > +					"fsl,flexcan-clock-divider or"
> > +					"clock-frequency\n");
> > +			err = -EINVAL;
> > +			goto failed_clock;
> > +		} else { /*FIXME for keeping oscillator as clock-source*/
> > +				dev_err(dev, "oscillator as clock support is"
> > +						"not available\n");
> > +				err = -EINVAL;
> > +				goto failed_clock;
> > +		}
> > +	} else {
> > +		dev_err(dev, "Invalid flexcan-clock-source\n");
> > +		err = -EINVAL;
> > +		goto failed_clock;
> > +	}
> > +
> > +	clock = kmalloc(sizeof(struct clk), GFP_KERNEL);
> > +	if (!clock) {
> > +		dev_err(dev, "Cannot allocate memory\n");
> > +			err = -ENOMEM;
> > +		goto failed_clock;
> > +	}
> > +
> > +	clock->rate = rate;
> > +	dev_info(dev, "clock-frequency is  %lu in line %d in function
> %s\r\n",
> > +			clock->rate, __LINE__, __func__);
> > +	return clock;
> > +
> > + failed_clock:
> > +	return ERR_PTR(err);
> > +}
> > +
> > +/**
> > + * flexcan_of_resource_init - initialize the resources for
> > + *				"of" type platform like powerpc
> > + * @flexcan_res: input buffer filled with address for accessing h/w
> registers
> > + *		of FlexCAN
> > + * @pdev: the FlexCAN device to be used
> > + * @flexcan_ops: input buffer containing different utility functions
> > + *
> > + * fills the flexcan_res with the address detail
> > + * for accessing the h/w registers of FlexCAN block.
> > + * flexcan_ops is filled with different clock functions and normal
> > +read/write
> > + *
> > + * Return value
> > + *    - On Success
> > + *	       0
> > + *    - On Failure
> > + *	   error value
> > + */
> > +static int flexcan_of_resource_init(struct flexcan_resource
> *flexcan_res,
> > +					struct device *pdev,
> > +					struct flexcan_interface *flexcan_ops) {
> > +	u64 addr, size;
> > +	int err, irq;
> > +
> > +	addr = of_translate_address(pdev->of_node,
> > +			of_get_address(pdev->of_node, 0, &size, NULL));
> > +	flexcan_res->addr = addr;
> > +	flexcan_res->size = size;
> > +	flexcan_res->drv_name = pdev->driver->name;
> > +	irq = irq_of_parse_and_map(pdev->of_node, 0);
> > +	if (irq == NO_IRQ) {
> > +		dev_err(pdev, "cannot map to irq\n");
> > +		err = -EINVAL;
> > +		goto failed_req;
> > +	}
> > +
> > +	flexcan_res->irq = irq;
> > +
> > +	flexcan_ops->clk_enable = NULL;
> > +	flexcan_ops->clk_disable = NULL;
> > +	flexcan_ops->clk_get_rate = flexcan_of_get_clk_rate;
> > +	flexcan_ops->clk_get = flexcan_of_clk_get;
> > +	flexcan_ops->clk_put = flexcan_of_clk_put;
> > +	return 0;
> > +
> > +failed_req:
> > +	return err;
> > +}
> > +
> > +
> > +
> > +/**
> > + * flexcan_probe - performs the resource initialization
> > + *		   after detecting the architecture type like "of" or
> > + *		   "platform" type
> > + * @pdev: pointer to platform device
> > + *
> > + * initialises the resources based on "platform" or "of"
> > + * type architecture.It also registers the FlexCAN with netdev layer.
> > + *
> > + * Return value
> > + *    - On Success
> > + *	       0
> > + *    - On Failure
> > + *	   error value
> > + */
> > +static int flexcan_probe(struct platform_device *pdev) {
> > +	int err;
> > +	struct flexcan_resource flexcan_res;
> > +	struct device_node *np = pdev->dev.of_node;
> > +
> > +	if (np) {
> > +		err = flexcan_of_resource_init(&flexcan_res,
> > +					&pdev->dev, &flexcan_ops);
> > +		if (err) {
> > +			dev_err(&pdev->dev, "Flexcan Initialization"
> > +				 "failed with err (%d)\n", err);
> > +			err = -EINVAL;
> > +			goto failed_req;
> > +		}
> > +	}
> > +
> > +	err = flexcan_dev_init(&pdev->dev, flexcan_res, &flexcan_ops);
> > +	if (err) {
> > +		dev_err(&pdev->dev, "Flexcan Initialization failed with err"
> > +				"(%d)\n", err);
> > +		err = -EINVAL;
> > +		goto failed_req;
> > +	}
> > +
> > +	return 0;
> > + failed_req:
> > +	return err;
> > +}
> > +
> > +/**
> > + * flexcan_remove - performs the resource de-initialization
> > + *		    after detecting the architecture type like "of" or
> > + *		    "platform" type
> > + * @pdev: pointer to platform device
> > + *
> > + * de-initializez the resources based on "platform" or "of"
> > + * type architecture.It also unregister the FlexCAN with netdev layer.
> > + */
> > +static int flexcan_remove(struct platform_device *pdev) {
> > +	struct net_device *dev = platform_get_drvdata(pdev);
> > +	struct flexcan_priv *priv = netdev_priv(dev);
> > +	struct device_node *np = pdev->dev.of_node;
> > +	struct resource *mem;
> > +	u64 addr = 0, size;
> > +
> > +	unregister_flexcandev(dev);
> > +	iounmap(priv->base);
> > +
> > +	if (np) {
> > +		addr = of_translate_address(pdev->dev.of_node,
> > +		    of_get_address(pdev->dev.of_node, 0, &size, NULL));
> > +		release_mem_region(addr, size);
> > +	}	clk_put(priv->clk);
> > +
> > +	platform_set_drvdata(pdev, NULL);
> > +	free_candev(dev);
> > +
> > +	return 0;
> > +}
> > +
> 
> 
> --
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


