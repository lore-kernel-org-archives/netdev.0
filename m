From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] Linux Device Driver for Xilinx LL TEMAC 10/100/1000 EthernetNIC
Date: Wed, 20 Aug 2008 11:39:06 -0600
Message-ID: <20080820173909.7344EB58071@mail95-dub.bigfish.com>
References: <48AA938C.4060309@dlasys.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Stephen Neuendorffer" <stephenn@xilinx.com>
To: <dhlii@dlasys.net>,
	"linuxppc-embedded" <linuxppc-embedded@ozlabs.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-dub.frontbridge.com ([213.199.154.16]:3060 "EHLO
	IE1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbYHTRjT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 13:39:19 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <48AA938C.4060309@dlasys.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not claiming to be a Linux driver expert as I'm still learning.
Some of the comments are nits.

Thanks for the effort you're putting in on this.

> Linux Device Driver for Xilinx LL TEMAC 10/100/1000 Ethernet NIC
> 
> Original Author Yoshio Kashiwagi
> Updated and Maintained by David Lynch
> 
> Signed-off-by: David H. Lynch Jr. <dhlii@dlasys.net>
> 
> ---
> 
>  drivers/net/Kconfig            |    5 
>  drivers/net/Makefile           |    1 
>  drivers/net/xps_lltemac.c      | 1562
++++++++++++++++++++++++++++++++++++++++
>  include/linux/xilinx_devices.h |    2 
>  4 files changed, 1569 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 033e13f..71b4c17 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2332,6 +2332,11 @@ config MV643XX_ETH
>  	  Some boards that use the Discovery chipset are the Momenco
>  	  Ocelot C and Jaguar ATX and Pegasos II.
>  
> +config XPS_LLTEMAC
> +	tristate "Xilinx LLTEMAC 10/100/1000 Ethernet MAC driver"
> +	help
> +	  This driver supports the Xilinx 10/100/1000 LLTEMAC found in
Virtex 4 FPGAs

It might be helpful to say only in DMA mode as our traditional drivers
support FIFO mode and DMA. 
Since the FPGA is pretty flexible people tend to do things different
than I sometimes expect.

> +
>  config QLA3XXX
>  	tristate "QLogic QLA3XXX Network Driver Support"
>  	depends on PCI
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 1f09934..9196bab 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -126,6 +126,7 @@ obj-$(CONFIG_AX88796) += ax88796.o
>  obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
>  obj-$(CONFIG_PICO_TEMAC) += pico_temac.o
>  obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
> +obj-$(CONFIG_XPS_LLTEMAC) += xps_lltemac.o
>  obj-$(CONFIG_QLA3XXX) += qla3xxx.o
>  
>  obj-$(CONFIG_PPP) += ppp_generic.o
> diff --git a/drivers/net/xps_lltemac.c b/drivers/net/xps_lltemac.c
> new file mode 100644
> index 0000000..8af4e7a
> --- /dev/null
> +++ b/drivers/net/xps_lltemac.c
> @@ -0,0 +1,1562 @@
>
+/*=====================================================================
=
> +
> + Driver for Xilinx temac ethernet NIC's

Saying LL TEMAC would be clearer as we having older TEMACs that are yet
different and not local link (LL).

It's definitely not a NIC in the traditional sense of a PCI card, but is
an SOC core.

> +
> + Author: Yoshio Kashiwagi
> + Copyright (c) 2008 Nissin Systems Co.,Ltd.
> +
> + Revisons: David H. Lynch Jr. <dhlii@dlasys.net>
> + Copyright (C) 2005-2008 DLA Systems
> +
>
+======================================================================*
/
> +/* DRV_NAME is for compatibility with existing xilinx ll temac driver
> + * also with  of/dtc object names */
> +#define DRV_NAME        "xilinx_lltemac"
> +#define DRV_AUTHOR      "Yoshio Kashiwagi"
> +#define DRV_EMAIL       ""
> +
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/init.h>
> +#include <linux/skbuff.h>
> +#include <linux/platform_device.h>
> +#include <linux/spinlock.h>
> +
> +#include <linux/mii.h>
> +#include <linux/in.h>
> +#include <linux/pci.h>
> +
> +#include <linux/ip.h>
> +#include <linux/tcp.h>      /* just needed for sizeof(tcphdr) */
> +#include <linux/udp.h>      /* needed for sizeof(udphdr) */
> +#include <linux/delay.h>
> +#include <linux/io.h>
> +
> +#define MII_ANI                     0x10
> +#define PHY_NUM                     0

This phy number, (phy address), won't work for a number of Xilinx
boards. It seems like this should be either pulled from the platform
data (and device tree), or the driver should try to find the PHY address
by trying each one.

Otherwise the users will have to edit the driver all the time when their
phy is not address 0.

> +#define PHY_TIMEOUT                 10000
> +

<snip>

> +static unsigned int
> +mdio_read(struct net_device *ndev, int phy_id, int reg_num)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	u32 timeout = PHY_TIMEOUT;
> +	u32 rv = 0;
> +	unsigned long flags;
> +
> +	if ((reg_num >  MII_REG_MAX) ||
> +		(phy_id == PHY_ADDR_INVALID)) {

The phy_id never gets set to PHY_ADDR_INVALID, is there something I'm
missing or should this be removed?  Maybe this is related to the PHY_NUM
hard coded value that could be set invalid.

> +		dev_err(&ndev->dev,
> +			"mdio_read(%x, %x) invalid reg_num or invalid
phy_id\n",
> +			reg_num, phy_id);
> +		return -1;

Returning a negative value for failure makes sense, but not when the
return type is unsigned int, should it be an int instead?

I put in nits about return types and I realize their nits, but should
make the driver better was my
hope.

> +	}
> +
> +	spin_lock_irqsave(&lp->lock, flags);
> +
> +	tiow(ndev, XTE_LSW0_OFFSET,
> +			((phy_id << 5) | (reg_num)));
> +	tiow(ndev, XTE_CTL0_OFFSET,
> +			XTE_MIIMAI_OFFSET | (lp->emac_num << 10));
> +	while (!(tior(ndev, XTE_RDY0_OFFSET) & XTE_RSE_MIIM_RR_MASK)) {
> +		udelay(1);
> +		if (--timeout == 0) {
> +			dev_err(&ndev->dev, "read_MII busy
timeout!!\n");
> +			return -1;
> +		}
> +	}
> +	rv = tior(ndev, XTE_LSW0_OFFSET);
> +
> +	spin_unlock_irqrestore(&lp->lock, flags);
> +	return rv;
> +}
> +
> +static void
> +mdio_write(struct net_device *ndev, int phy_id, int reg_num, int
reg_val)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	u32 timeout = PHY_TIMEOUT, status;
> +	unsigned long flags;
> +
> +	if ((reg_num >  MII_REG_MAX) ||
> +		(phy_id == PHY_ADDR_INVALID)) {
> +		dev_err(&ndev->dev,
> +			"mdio_write(%x, %x)invalid reg_num or invalid
phy_id\n",
> +			reg_num, phy_id);
> +		return -1;

The return type is void yet it tries to return -1, should it be int
return? 

> +	}
> +
> +	spin_lock_irqsave(&lp->lock, flags);
> +
> +	tiow(ndev, XTE_LSW0_OFFSET,
> +			reg_val);
> +	tiow(ndev, XTE_CTL0_OFFSET,
> +			CNTLREG_WRITE_ENABLE_MASK | XTE_MGTDR_OFFSET);
> +	tiow(ndev, XTE_LSW0_OFFSET,
> +			((phy_id << 5) | (reg_num)));
> +	tiow(ndev, XTE_CTL0_OFFSET,
> +			CNTLREG_WRITE_ENABLE_MASK
> +			| XTE_MIIMAI_OFFSET
> +			| (lp->emac_num << 10));
> +	while (!(status = tior(ndev, XTE_RDY0_OFFSET) &
XTE_RSE_MIIM_WR_MASK)) {
> +		udelay(1);
> +		if (--timeout == 0) {
> +			dev_err(&ndev->dev, "write_MII busy
timeout!!\n");
> +			return ;

Seems like this should return -1 as a failure and be consistent with
read().

> +		}
> +	}
> +
> +	spin_unlock_irqrestore(&lp->lock, flags);
> +}
> +
> +static u32
> +emac_cfg_read(struct net_device *ndev, u16 reg_num)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	u32 timeout = PHY_TIMEOUT;
> +
> +	if (reg_num > TEMAC_REG_MAX) {
> +		dev_err(&ndev->dev,
> +				"emac_cfg_read(%x) invalid reg_num\n",
> +				reg_num);
> +		return -1;
> +	}
> +

Can the register value read be -1 by accident such that a valid register
return
looks like a failure?

> +	tiow(ndev, XTE_CTL0_OFFSET, (lp->emac_num << 10) | reg_num);
> +	while (!(tior(ndev, XTE_RDY0_OFFSET) & XTE_RSE_CFG_RR_MASK)) {
> +		udelay(1);
> +		if (--timeout == 0) {
> +			dev_err(&ndev->dev, "read temac busy
timeout!!\n");
> +			return -1;
> +		}
> +	}
> +	return (u32) tior(ndev, XTE_LSW0_OFFSET);
> +
> +}
> +
> +static void
> +emac_cfg_write(struct net_device *ndev, u32 reg_num, u32 val)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	u32 timeout = PHY_TIMEOUT;
> +
> +	if (reg_num > TEMAC_REG_MAX) {
> +		dev_err(&ndev->dev,
> +				"emac_cfg_write(%x) invalid reg_num\n",
> +				reg_num);
> +		return -1;
> +	}
> +

Same thing returning a value when void return, and timeout below again
should 
return failure?  It would seem like these be compiler warnings?

> +	tiow(ndev, XTE_LSW0_OFFSET, val);
> +	tiow(ndev,
> +			XTE_CTL0_OFFSET,
> +			(CNTLREG_WRITE_ENABLE_MASK
> +			 | (lp->emac_num << 10)
> +			 | reg_num));
> +	while (!(tior(ndev, XTE_RDY0_OFFSET) & XTE_RSE_CFG_WR_MASK)) {
> +		udelay(1);
> +		if (--timeout == 0) {
> +			dev_err(&ndev->dev, "write temac busy
timeout!!\n");
> +			return ;
> +		}
> +	}
> +}
> +
> +static u32
> +emac_cfg_setclr(struct net_device *ndev, u32 reg_num, u32 val, int
flg)
> +{
> +	u32 Reg;
> +	if (reg_num > TEMAC_REG_MAX) {
> +		dev_err(&ndev->dev,
> +				"emac_cfg_setclr(%x) invalid reg_num\n",
> +				reg_num);
> +		return -1;
> +	}

Nit.

Sorry to pick on return values so much, but they seem real inconsistent.
seems like an int would be more appropriate here as there's no register
value
to be returned.

> +
> +	Reg = emac_cfg_read(ndev, reg_num) & ~val;
> +	if (flg)
> +		Reg |= val;
> +	emac_cfg_write(ndev, reg_num, Reg);
> +	return 0;
> +}
> +

<snip>

> +static int
> +temac_bd_init(struct net_device *ndev)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	struct sk_buff *skb;
> +	int ii;
> +
> +	lp->rx_skb = kzalloc(sizeof(struct sk_buff)*RX_BD_NUM,
GFP_KERNEL);
> +	/* allocate the tx and rx ring buffer descriptors. */
> +	/* returns a virtual addres and a physical address. */
> +	lp->tx_bd_v = dma_alloc_coherent(NULL,
> +			sizeof(struct cdmac_bd) * TX_BD_NUM,
> +			(dma_addr_t *)&lp->tx_bd_p,
> +			GFP_KERNEL);
> +	lp->rx_bd_v = dma_alloc_coherent(NULL,
> +			sizeof(struct cdmac_bd) * RX_BD_NUM,
> +			(dma_addr_t *)&lp->rx_bd_p,
> +			GFP_KERNEL);


Not sure this is a big deal, BDs have to be cacheline aligned, but since
there are 8 words for each, it's not a problem on 405 and 440 (32 byte
cacheline). Other powerpc processors might be a problem. A more specific
dependency on 4xx might be useful?

> +
> +	for (ii = 0; ii < TX_BD_NUM; ii++) {
> +		memset((char *)&lp->tx_bd_v[ii], 0, sizeof(struct
cdmac_bd));
> +		if (ii == (TX_BD_NUM - 1))
> +			lp->tx_bd_v[ii].next = &lp->tx_bd_p[0];
> +		else
> +			lp->tx_bd_v[ii].next = &lp->tx_bd_p[ii + 1];
> +
> +	}

<snip>

> +
> +/* Initilize temac */
> +static void
> +temac_device_reset(struct net_device *ndev)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	u32 timeout = 1000;
> +
> +	/* Perform a software reset */
> +
> +	/* 0x300 host enable bit ? */
> +	/* reset PHY through control register ?:1 */
> +

Seems like the above comments should be removed.

> +	/* Reset the device */
> +	emac_cfg_write(ndev, XTE_RXC1_OFFSET, XTE_RXC1_RXRST_MASK);
> +	/* Wait for the receiver to finish reset */
> +	while (emac_cfg_read(ndev, XTE_RXC1_OFFSET) &
XTE_RXC1_RXRST_MASK) {
> +		udelay(1);
> +		if (--timeout == 0) {
> +			dev_err(&ndev->dev,
> +				"temac_device_reset RX reset
timeout!!\n");
> +			break;
> +		}
> +	}
> +
> +	emac_cfg_write(ndev, XTE_TXC_OFFSET, XTE_TXC_TXRST_MASK);
> +	/* Wait for the transmitter to finish reset */
> +	timeout = 1000;
> +	while (emac_cfg_read(ndev, XTE_TXC_OFFSET) & XTE_TXC_TXRST_MASK)
{
> +		udelay(1);
> +		if (--timeout == 0) {
> +			dev_err(&ndev->dev,
> +				"temac_device_reset TX reset
timeout!!\n");
> +			break;
> +		}
> +	}
> +
> +	/* Disable the receiver */
> +	emac_cfg_write(ndev,
> +			XTE_RXC1_OFFSET,
> +			emac_cfg_read(ndev, XTE_RXC1_OFFSET)
> +			& ~XTE_RXC1_RXEN_MASK);
> +
> +	/* reset */
> +	tiow(ndev, XTE_RAF0_OFFSET, 1);
> +	/* wait for reset */
> +	timeout = 1000;
> +	while (tior(ndev, XTE_RAF0_OFFSET) & 1) {
> +		udelay(1);
> +		if (--timeout == 0) {
> +			dev_err(&ndev->dev,
> +				"temac_device_reset RAF reset
timeout!!\n");
> +			break;
> +		}
> +	}
> +
> +	/* ISR0/IER0/IPR0 bits */
> +	/* b1         autoneg complete */
> +	/* b2         receive complete */
> +	/* b5         transmit complete */
> +	/* b0       = interrupts from TIS/TIE registers */
> +
> +
> +	/* Reset */
> +	sd_iow(ndev, DMA_CONTROL_REG, DMA_CONTROL_RST);
> +	timeout = 1000;
> +	while (sd_ior(ndev, DMA_CONTROL_REG) & DMA_CONTROL_RST) {
> +		udelay(1);
> +		if (--timeout == 0) {
> +			dev_err(&ndev->dev,
> +				"temac_device_reset DMA reset
timeout!!\n");
> +			break;
> +		}
> +	}
> +
> +	dev_info(&ndev->dev,
> +			"%s: Xilinx Embedded Tri-Mode Ethernet MAC %s
%s\n",
> +			ndev->name,
> +			__DATE__,
> +			__TIME__);
> +	dev_info(&ndev->dev, "temac %08x sdma %08x\n",
> +			lp->regs.addr,
> +			lp->sdma.addr);
> +
> +	temac_bd_init(ndev);
> +
> +	emac_cfg_write(ndev, XTE_RXC0_OFFSET, 0);
> +	emac_cfg_write(ndev, XTE_RXC1_OFFSET, 0);
> +	emac_cfg_write(ndev, XTE_TXC_OFFSET, 0);
> +	emac_cfg_write(ndev, XTE_FCC_OFFSET, XTE_FCC_RXFLO_MASK);
> +
> +	/* Sync default options with HW
> +	 * but leave receiver and transmitter disabled.  */
> +	temac_setoptions(ndev,
> +			lp->options & ~(XTE_OPTION_TXEN |
XTE_OPTION_RXEN));
> +
> +	temac_phy_init(ndev);
> +
> +	temac_set_mac_address(ndev, 0);
> +	/* Set address filter table */
> +	temac_set_multicast_list(ndev);
> +	if (temac_setoptions(ndev, lp->options))
> +		dev_err(&ndev->dev, "Error setting TEMAC options\n");
> +
> +	/* Init Driver variable */
> +	ndev->trans_start = 0;
> +	spin_lock_init(&lp->lock);
> +	spin_lock_init(&lp->rx_lock);
> +}
> +
> +static void
> +temac_hard_start_xmit_done(struct net_device *ndev)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	struct cdmac_bd *cur_p;
> +	unsigned int stat = 0;
> +
> +	cur_p = &lp->tx_bd_v[lp->tx_bd_ci];
> +	stat = cur_p->app0;
> +
> +	while (stat & STS_CTRL_APP0_CMPLT) {
> +		pci_unmap_single(NULL,
> +				(unsigned long)cur_p->phys,
> +				cur_p->len,
> +				PCI_DMA_TODEVICE);

It seems like the PCI calls would be better replaced with
dma_unmap_single() 
and dma_map_single to be more accurate and probably less overhead?

The dma functions, not sure on the pci, should handle when we change the
driver
to cache the BDs as that will be needed eventually for good performance.

> +		if (cur_p->app4)
> +			dev_kfree_skb_irq((struct sk_buff
*)cur_p->app4);
> +		cur_p->app0 = 0;
> +
> +		lp->stats.tx_packets++;
> +		lp->stats.tx_bytes += cur_p->len;
> +
> +		lp->tx_bd_ci++;
> +		if (lp->tx_bd_ci >= TX_BD_NUM)
> +			lp->tx_bd_ci = 0;
> +
> +		cur_p = &lp->tx_bd_v[lp->tx_bd_ci];
> +		stat = cur_p->app0;
> +	}
> +
> +	netif_wake_queue(ndev);
> +}
> +

<snip>

> +static int __init
> +temac_device_map(struct platform_device *pdev, struct net_device
*ndev,
> +		int num, struct temac_region *reg)
> +{
> +	struct resource *res;
> +	int erC = 0;
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, num);
> +	if (res == 0) {
> +		erC = -ENODEV;
> +		goto fail;
> +	}
> +	if (request_mem_region(res->start, res->end - res->start,
> +				pdev->name) == 0) {
> +		dev_err(&pdev->dev,
> +				"%s: failed to request registers\n",
> +				pdev->name);
> +		erC = -ENXIO;
> +		goto fail;
> +	}
> +
> +	reg->base = (uintptr_t)res->start;
> +	reg->len  = res->end - res->start;

Should this really be res->end - res->start + 1 to include the 
memory region?  It's also used up above in the mem_region call.

> +	reg->addr = ioremap_nocache((uintptr_t)reg->base, reg->len);
> +	if (reg->addr == 0) {
> +		dev_err(&pdev->dev,
> +			"%s: failed to remap registers\n", pdev->name);
> +		erC = -ENXIO;
> +		goto fail_remap;
> +	}
> +	return 0;
> +fail_remap:
> +	release_region((u32)reg->addr, reg->len);
> +fail:
> +	return erC;
> +}

<snip>

> -----Original Message-----
> From: linuxppc-embedded-bounces+john.linn=xilinx.com@ozlabs.org
[mailto:linuxppc-embedded-
> bounces+john.linn=xilinx.com@ozlabs.org] On Behalf Of David H. Lynch
Jr.
> Sent: Tuesday, August 19, 2008 3:34 AM
> To: linuxppc-embedded; netdev@vger.kernel.org
> Subject: [PATCH] Linux Device Driver for Xilinx LL TEMAC 10/100/1000
EthernetNIC
> 
> Pass II

This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


