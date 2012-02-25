From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] ARM: LPC32xx: Ethernet driver
Date: Sat, 25 Feb 2012 12:41:25 -0800
Message-ID: <1330202485.18464.56.camel@joe2Laptop>
References: <1330201304-24037-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, eilong@broadcom.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	w.sang@pengutronix.de, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, linux-arm-kernel@lists.infradead.org
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330201304-24037-1-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-02-25 at 21:21 +0100, Roland Stigge wrote:
> This patch adds an ethernet driver for the LPC32xx ARM SoC.

Just some style notes:

> +++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c

[]

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/sched.h>
> +#include <linux/slab.h>
> +#include <linux/delay.h>
> +#include <linux/interrupt.h>
> +#include <linux/errno.h>
> +#include <linux/ioport.h>
> +#include <linux/crc32.h>
> +#include <linux/platform_device.h>
> +#include <linux/spinlock.h>
> +#include <linux/ethtool.h>
> +#include <linux/mii.h>
> +#include <linux/clk.h>
> +#include <linux/workqueue.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/phy.h>
> +#include <linux/dma-mapping.h>
> +
> +#include <linux/delay.h>
> +#include <linux/io.h>
> +#include <mach/board.h>
> +#include <mach/platform.h>
> +#include <mach/hardware.h>
> +#include "lpc_eth.h"
> +
> +#define MODNAME "lpc-net"

lpc-net or lpc_eth?
[]
> +/*
> + * MAC address is provided as a boot parameter (ethaddr)
> + */
> +static u8 mac_address[6] = {0, 0, 0, 0, 0, 0};
[]
> +static void __lpc_set_mac(struct netdata_local *pldat, u8 *mac)
[]
> +	pr_debug("Ethernet MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
> +		mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
> +}

	pr_debug("MAC address: %pM\n", mac)

[]
> +static int lpc_mii_probe(struct net_device *ndev)
> +{
[]
> +	if (!phydev) {
> +		pr_err("%s: no PHY found\n", ndev->name);

It looks like most of these pr_<level>(...) uses
should be netdev_<level>(ndev, ...)

[]
> +static void __lpc_handle_recv(struct net_device *ndev)
> +{
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +	struct sk_buff *skb;
> +	int rxconsidx, len, ethst;
> +	struct rx_status_t *prxstat;
> +	u8 *prdbuf;
> +
> +	/* Get the current RX buffer indexes */
> +	rxconsidx = (int) readl(LPC_ENET_RXCONSUMEINDEX(pldat->net_base));

Please try to be consistent with space or no space after cast.
I think no space is better.

> +	while (rxconsidx !=
> +			(int)readl(LPC_ENET_RXPRODUCEINDEX(pldat->net_base))) {

> +		/* Get pointer to receive status */
> +		prxstat = (struct rx_status_t *) pldat->rx_stat_v[rxconsidx];
> +		len = (prxstat->statusinfo & 0x7FF) + 1;
> +
> +		/* Status error? */
> +		ethst = prxstat->statusinfo;
> +		if ((ethst & 0xBF800000) == 0x84000000)
> +			ethst &= ~0x80000000;
> +
> +		if (ethst & 0x80000000) {
> +			/* Check statuses */
> +			if (prxstat->statusinfo & (1 << 28)) {

Might be better to use a temporary for prxstat->statusinfo

> +				/* Overrun error */
> +				ndev->stats.rx_fifo_errors++;
> +			} else if (prxstat->statusinfo & (1 << 23)) {
> +				/* CRC error */
> +				ndev->stats.rx_crc_errors++;
> +			} else if (prxstat->statusinfo & (1 << 25)) {
> +				/* Length error */
> +				ndev->stats.rx_length_errors++;
> +			} else if (prxstat->statusinfo & 0x80000000) {
> +				/* Other error */
> +				ndev->stats.rx_length_errors++;
> +			}
> +			ndev->stats.rx_errors++;
> +		} else {
> +			/* Packet is good */
> +			skb = dev_alloc_skb(len + 8);
> +			if (!skb)
> +				ndev->stats.rx_dropped++;
> +			else {
> +				skb_reserve(skb, 8);
> +				prdbuf = skb_put(skb, (len - 0));
> +
> +				/* Copy packer from buffer */
> +				memcpy(prdbuf,
> +					(void *)pldat->rx_buff_v[rxconsidx],

Probably don't need the cast to (void *)
> +					len);
> +
[]
> +static irqreturn_t __lpc_eth_interrupt(int irq, void *dev_id)
> +{
[]
> +	/* Get the interrupt status */
> +	tmp = readl(LPC_ENET_INTSTATUS(pldat->net_base));
> +
> +	while (tmp) {

probably better as

	while ((tmp = readl(...)) {
[...]

> +		/* Recheck the interrupt status */
> +		tmp = readl(LPC_ENET_INTSTATUS(pldat->net_base));
> +	}
[]
> +static int lpc_net_close(struct net_device *ndev)
> +{
> +	unsigned long flags;
> +	struct netdata_local *pldat = netdev_priv(ndev);
> +
> +	if (netif_msg_ifdown(pldat))
> +		dev_dbg(&pldat->pdev->dev, "shutting down %s\n", ndev->name);

	netif_dbg(pltdat, ifdown, ndev, ...)
[]
> +static int lpc_net_drv_probe(struct platform_device *pdev)
[]
> +	if (use_iram_for_net()) {
> +		dma_handle = (dma_addr_t) LPC32XX_IRAM_BASE;
> +		if (pldat->dma_buff_size <= lpc32xx_return_iram_size())
> +			pldat->dma_buff_base_v =
> +				(u32) io_p2v(LPC32XX_IRAM_BASE);
> +		else
> +			pr_err("%s: IRAM not big enough for net buffers, "
> +				"using SDRAM instead.\n", MODNAME);

Please coalesce formats and ignore 80 column limits
to make grep easier.
