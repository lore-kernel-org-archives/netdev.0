From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH V2] net-next-2.6:can: add TI CAN (HECC) driver
Date: Thu, 03 Sep 2009 10:59:53 +0200
Message-ID: <4A9F8589.9050302@grandegger.com>
References: <1251958885-12257-1-git-send-email-anantgole@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Anant Gole <anantgole@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:46029 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbZICI74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 04:59:56 -0400
In-Reply-To: <1251958885-12257-1-git-send-email-anantgole@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anant Gole wrote:
> TI HECC (High End CAN Ctonroller) module is found on many TI devices.
> It has 32 hardware mailboxes with full implementation of CAN protocol
> version 2.0B with bus speeds up to 1Mbps. Specifications of the
> module are available at TI web <http://www.ti.com>
> 
> This driver is tested on a newer OMAP device EVM.
>
> Signed-off-by: Anant Gole <anantgole@ti.com>

Much better now :-). Still a few issues, though.

> ---
>  drivers/net/can/Kconfig              |    9 +
>  drivers/net/can/Makefile             |    2 +
>  drivers/net/can/ti_hecc.c            |  997 ++++++++++++++++++++++++++++++++++
>  include/linux/can/platform/ti_hecc.h |   40 ++
>  4 files changed, 1048 insertions(+), 0 deletions(-)
>  delete mode 100644 drivers/mtd/maps/sbc8240.c
>  create mode 100644 drivers/net/can/ti_hecc.c
>  create mode 100644 include/linux/can/platform/ti_hecc.h
> 
> diff --git a/drivers/mtd/maps/sbc8240.c b/drivers/mtd/maps/sbc8240.c
> deleted file mode 100644
> index e69de29..0000000
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 30ae55d..fae62df 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -75,6 +75,15 @@ config CAN_KVASER_PCI
>  	  This driver is for the the PCIcanx and PCIcan cards (1, 2 or
>  	  4 channel) from Kvaser (http://www.kvaser.com).
>  
> +config CAN_TI_HECC
> +        depends on CAN_DEV
> +        tristate "TI High End CAN Controller (HECC)"
> +        default N
> +        ---help---
> +	  This driver adds support for TI High End CAN Controller module
> +	  found on many TI devices. The specifications of this module are
> +	  are available from TI web (http://www.ti.com)
> +
>  config CAN_DEBUG_DEVICES
>  	bool "CAN devices debugging messages"
>  	depends on CAN
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 523a941..d923512 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -9,4 +9,6 @@ can-dev-y			:= dev.o
>  
>  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
>  
> +obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
> +
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> new file mode 100644
> index 0000000..e8c2763
> --- /dev/null
> +++ b/drivers/net/can/ti_hecc.c
> @@ -0,0 +1,997 @@
> +/*
> + * TI HECC (CAN) device driver
> + *
> + * This driver supports TI's HECC (High End CAN Controller module) and the
> + * specs for the same is available at <http://www.ti.com>
> + *
> + * Copyright (C) 2009 Texas Instruments Incorporated - http://www.ti.com/
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation version 2.
> + *
> + * This program is distributed as is WITHOUT ANY WARRANTY of any
> + * kind, whether express or implied; without even the implied warranty
> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + *
> + * Your platform definitions should specify module ram offsets and interrupt
> + * number to use as follows:
> + *
> + * static struct ti_hecc_platform_data omap3517_evm_hecc_pdata = {
> + *         .scc_hecc_offset        = 0,
> + *         .scc_ram_offset         = 0x3000,
> + *         .hecc_ram_offset        = 0x3000,
> + *         .mbox_offset            = 0x2000,
> + *         .int_line               = 0,
> + *         .revision               = 1,
> + * };
> + *
> + * Please see include/can/platform/ti_hecc.h for description of above fields

Nice.

[snip]
> +static int ti_hecc_set_bittiming(struct net_device *ndev)
> +{
> +	/* NOTE: TI HECC module requires bittimings to be programmed only in
> +	 * initialization mode - this is handled only in ti_hecc_reset() in
> +	 * this driver and hence this function is dummy. The can bittiming
> +	 * structure should be populated before hand (via ip utility)
> +	 */
> +	return 0;
> +}

OK, then it could be removed completely.

> +static int ti_hecc_set_btc(struct ti_hecc_priv *priv)
> +{
> +	struct can_bittiming *bit_timing = &priv->can.bittiming;
> +	u32 can_btc = 0;
> +
> +	can_btc = ((bit_timing->phase_seg2 - 1) & 0x7);
> +	can_btc |= (((bit_timing->phase_seg1 + bit_timing->prop_seg - 1)
> +			& 0xF) << 3);
> +	if ((bit_timing->brp > 4) &&
> +		(priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES))
> +			can_btc |= HECC_CANBTC_SAM;

Why must brp be greater than 4 to allow triple sampling?

> +	can_btc |= (((bit_timing->sjw - 1) & 0x3) << 8);
> +	can_btc |= (((bit_timing->brp - 1) & 0xFF) << 16);
> +
> +	/* ERM being set to 0 by default meaning resync at falling edge */
> +
> +	hecc_write(priv, HECC_CANBTC, can_btc);
> +	dev_info(priv->ndev->dev.parent, "setting CANBTC=%#x\n", can_btc);
> +
> +	return 0;
> +}
> +
> +static void ti_hecc_reset(struct net_device *ndev)
> +{
> +#define HECC_CCE_WAIT_COUNT     100

Nitpicking: I would move it up to the other HECC_* defines.

> +	u32 cnt;
> +	struct ti_hecc_priv *priv = netdev_priv(ndev);
> +
> +	dev_dbg(ndev->dev.parent, "resetting hecc ...\n");
> +	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_SRES);
> +
> +	/* Set change control request and wait till enabled */
> +	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
> +
> +	/* INFO: It has been observed that at times CCE bit may not be
> +	 * set and hw seems to be ok even if this bit is not set so
> +	 * timing out with a timing of 1ms to respect the specs
> +	 */
> +	cnt = HECC_CCE_WAIT_COUNT;
> +	while (!hecc_get_bit(priv, HECC_CANES, HECC_CANES_CCE) && (0 != cnt)) {
> +		--cnt;
> +		udelay(10);
> +	}
> +
> +	/* Note: On HECC, BTC can be programmed only in initialization mode, so
> +	 * it is expected that the can bittiming parameters are set via ip
> +	 * utility before the device is opened
> +	 */
> +	ti_hecc_set_btc(priv);
> +
> +	/* Clear CCR (and CANMC register) and wait for CCE = 0 enable */
> +	hecc_write(priv, HECC_CANMC, 0);
> +
> +	/* INFO: CAN net stack handles bus off and hence disabling auto-bus-on
> +	 * hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_ABO);
> +	 */
> +
> +	/* INFO: It has been observed that at times CCE bit may not be
> +	 * set and hw seems to be ok even if this bit is not set so
> +	 */
> +	cnt = HECC_CCE_WAIT_COUNT;
> +	while (hecc_get_bit(priv, HECC_CANES, HECC_CANES_CCE) && (0 != cnt)) {
> +		--cnt;
> +		udelay(10);
> +	}
> +
> +	/* Enable TX and RX I/O Control pins */
> +	hecc_write(priv, HECC_CANTIOC, HECC_CANTIOC_EN);
> +	hecc_write(priv, HECC_CANRIOC, HECC_CANRIOC_EN);
> +
> +	/* Clear registers for clean operation */
> +	hecc_write(priv, HECC_CANTA, HECC_SET_REG);
> +	hecc_write(priv, HECC_CANRMP, HECC_SET_REG);
> +	hecc_write(priv, HECC_CANGIF0, HECC_SET_REG);
> +	hecc_write(priv, HECC_CANGIF1, HECC_SET_REG);
> +	hecc_write(priv, HECC_CANME, 0);
> +	hecc_write(priv, HECC_CANMD, 0);
> +
> +	/* SCC compat mode NOT supported (and not needed too) */
> +	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_SCM);
> +}
> +
> +/**
> + * ti_hecc_start: Starts HECC module
> + *
> + * If CAN state is not stopped, reset the module, init bit timings
> + * and start the device for operation
> + */

Nitpicking: this comment is for doc book. Is it by intention? If yes,
you should problably document the arguments as well. Here and for the
other functions as well.

[snip]
> +static int ti_hecc_do_set_mode(struct net_device *ndev, enum can_mode mode)
> +{
> +	struct ti_hecc_priv *priv = netdev_priv(ndev);
> +	int ret = 0;
> +
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		dev_info(priv->ndev->dev.parent, "device (re)starting\n");

There is already a dev_dbg() in dev.c:can_restart(), please remove.

> +		++priv->can.can_stats.restarts;

Already incremented in dev.c:can_restart().

> +		ti_hecc_start(ndev);
> +		if (netif_queue_stopped(ndev))
> +			netif_wake_queue(ndev);
> +		break;
> +	default:
> +		ret = -EOPNOTSUPP;
> +		break;
> +	}
> +
> +	return ret;
> +}

BTW: did you test bus-off recovery? It usually also a source of trouble,
depending on the hardware.

> +/**
> + * ti_hecc_xmit: HECC Transmit
> + *
> + * The transmit mailboxes start from 0 to TI_HECC_MAX_TX_MBOX. In HECC the
> + * priority of the mailbox for tranmission depends upon the setting of priority
> + * field in mailbox registers. The mailbox with highest value in priority field
> + * is transmitted first. Only when two mailboxes have the same value in
> + * priority field the highest numbered mailbox is transmitted first.
> + *
> + * To utilize the HECC priority feature as described above we start with the
> + * highest numbered mailbox with highest priority level and move on to the next
> + * mailbox with the same priority level and so on. Once we loop through all the
> + * transmit mailboxes we choose the next priority level (lower) and so on
> + * untill we reach the lowest priority level on the lowest numbered mailbox
> + * when we stop transmission untill all mailboxes are transmitted and then
> + * restart at highest numbered mailbox with highest priority.
> + *
> + * To keep track of next transmit mailbox priv->tx_mbxno is used along with
> + * priv->prio for priority. priv->stop_xmit helps sync transmit complete
> + * interrupt when we re-start the queue if it was stopped after the mailbox
> + * priority roll-over.
> + */
> +static int ti_hecc_xmit(struct sk_buff *skb, struct net_device *ndev)

Please use netdev_tx_t, which has been introduced recently. See "git
show 61357325" of the Dave's net-next-2.6 branch.

> +{
> +	struct ti_hecc_priv *priv = netdev_priv(ndev);
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	u32 mbxno = 0;
> +	u32 data;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->tx_lock, flags);
> +	mbxno = priv->tx_mbxno;
> +	set_bit(mbxno, priv->tx_free_mbx);
> +	spin_unlock_irqrestore(&priv->tx_lock, flags);
> +
> +	/* Prepare mailbox for transmission */
> +	hecc_clear_bit(priv, HECC_CANME, (1 << mbxno));
> +	data = cf->can_dlc & 0xF;
> +	if (cf->can_id & CAN_RTR_FLAG) /* Remote transmission request */
> +		data |= HECC_CANMCF_RTR;
> +	data |= ((priv->prio & 0x3F) << 8); /* set tx priority level */
> +	hecc_write(priv, HECC_CANMCF(mbxno), data);
> +
> +	if (cf->can_id & CAN_EFF_FLAG) /* Extended frame format */
> +		data = ((cf->can_id & CAN_EFF_MASK) | HECC_CANMID_IDE);
> +	else /* Standard frame format */
> +		data = ((cf->can_id & CAN_SFF_MASK) << 18);
> +
> +	hecc_write(priv, HECC_CANMID(mbxno), data);
> +	data = (cf->data[0] << 24) | (cf->data[1] << 16) |
> +			(cf->data[2] << 8) | cf->data[3];
> +	hecc_write(priv, HECC_CANMDL(mbxno), data);
> +	if (cf->can_dlc > 4) {
> +		data = (cf->data[4] << 24) | (cf->data[5] << 16) |
> +			(cf->data[6] << 8) | cf->data[7];
> +		hecc_write(priv, HECC_CANMDH(mbxno), data);
> +	}
> +	can_put_echo_skb(skb, ndev, mbxno);
> +
> +	/* check if next mailbox is free - if not hold queue */
> +	spin_lock_irqsave(&priv->tx_lock, flags);
> +	if (priv->tx_mbxno)
> +		--priv->tx_mbxno;
> +	else {
> +		priv->tx_mbxno = (TI_HECC_MAX_TX_MBOX - 1);
> +		if (priv->prio)
> +			--priv->prio;
> +		else {
> +			priv->stop_xmit = 1;
> +			priv->prio = MAX_TX_PRIO;
> +		}
> +	}
> +
> +	/* Stop the queue if next transmit mailbox is not free or if there
> +	 * is a wrap over in priority and queue should be stopped
> +	 */
> +	if (test_bit(priv->tx_mbxno, priv->tx_free_mbx) || priv->stop_xmit)
> +		netif_stop_queue(priv->ndev);
> +	spin_unlock_irqrestore(&priv->tx_lock, flags);
> +
> +	/* Enable interrupt for mbox and start transmission */
> +	hecc_clear_bit(priv, HECC_CANMD, (1 << mbxno));
> +	hecc_set_bit(priv, HECC_CANME, (1 << mbxno));
> +	hecc_set_bit(priv, HECC_CANMIM, (1 << mbxno));
> +	hecc_set_bit(priv, HECC_CANTRS, (1 << mbxno));
> +	ndev->trans_start = jiffies;
> +
> +	return NETDEV_TX_OK;
> +}

Ensuring proper ordering of out-going messages is tricky. I suggest
using Vladislav's test programs posted recently for validation:

https://lists.berlios.de/pipermail/socketcan-core/2009-August/002871.html

[snip]
> +static int
> +ti_hecc_error(struct net_device *ndev, int int_status, int err_status)
> +{
> +	struct ti_hecc_priv *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +
> +	/* propogate the error condition to the can stack */
> +	skb = dev_alloc_skb(sizeof(struct can_frame));
> +	if (!skb) {
> +		if (printk_ratelimit())
> +			dev_err(priv->ndev->dev.parent,
> +				"dev_alloc_skb() failed in err processing\n");
> +		return -ENOMEM;
> +	}
> +	skb->dev = ndev;
> +	skb->protocol = htons(ETH_P_CAN);
> +	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
> +	memset(cf, 0, sizeof(struct can_frame));
> +	cf->can_id = CAN_ERR_FLAG;
> +	cf->can_dlc = CAN_ERR_DLC;
> +
> +	if (int_status & HECC_CANGIF_WLIF) { /* warning level int */
> +		if (0 == (int_status & HECC_CANGIF_BOIF)) {
> +			priv->can.state = CAN_STATE_ERROR_WARNING;
> +			++priv->can.can_stats.error_warning;
> +			cf->can_id |= CAN_ERR_CRTL;
> +			if (hecc_read(priv, HECC_CANTEC) > 96)
> +				cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
> +			if (hecc_read(priv, HECC_CANREC) > 96)
> +				cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
> +		}
> +		hecc_set_bit(priv, HECC_CANES, HECC_CANES_EW);
> +		dev_dbg(priv->ndev->dev.parent, "Error Warning interrupt\n");
> +		hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
> +	}
> +
> +	if (int_status & HECC_CANGIF_EPIF) { /* error passive int */
> +		if (0 == (int_status & HECC_CANGIF_BOIF)) {
> +			priv->can.state = CAN_STATE_ERROR_PASSIVE;
> +			++priv->can.can_stats.error_passive;
> +			cf->can_id |= CAN_ERR_CRTL;
> +			if (hecc_read(priv, HECC_CANTEC) > 127)
> +				cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
> +			if (hecc_read(priv, HECC_CANREC) > 127)
> +				cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;

Currently we set the flag as show:

			cf->data[1] = (txerr > rxerr) ?
				CAN_ERR_CRTL_TX_PASSIVE :
				CAN_ERR_CRTL_RX_PASSIVE;

Making clear that the state change was triggered by TX or RX. If this is
the best choice for the user is debatable, though.

> +		}
> +		hecc_set_bit(priv, HECC_CANES, HECC_CANES_EP);
> +		dev_dbg(priv->ndev->dev.parent, "Error passive interrupt\n");
> +		hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
> +	}
> +
> +	/* Need to check busoff condition in error status register too to
> +	 * ensure warning interrupts don't hog the system
> +	 */
> +	if ((int_status & HECC_CANGIF_BOIF) || (err_status & HECC_CANES_BO)) {
> +		priv->can.state = CAN_STATE_BUS_OFF;
> +		cf->can_id |= CAN_ERR_BUSOFF;
> +		hecc_set_bit(priv, HECC_CANES, HECC_CANES_BO);
> +		hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_CCR);
> +		can_bus_off(ndev);
> +		/* Disable all interrupts in bus-off to avoid int hog */
> +		hecc_write(priv, HECC_CANGIM, 0);
> +	}
> +
> +	if (err_status & HECC_BUS_ERROR) {
> +		++priv->can.can_stats.bus_error;
> +		cf->can_id |= (CAN_ERR_BUSERROR | CAN_ERR_PROT);
> +		cf->data[2] |= CAN_ERR_PROT_UNSPEC;
> +		if (err_status & HECC_CANES_FE) {
> +			hecc_set_bit(priv, HECC_CANES, HECC_CANES_FE);
> +			cf->data[2] |= CAN_ERR_PROT_FORM;
> +		}
> +		if (err_status & HECC_CANES_BE) {
> +			hecc_set_bit(priv, HECC_CANES, HECC_CANES_BE);
> +			cf->data[2] |= CAN_ERR_PROT_BIT;
> +		}
> +		if (err_status & HECC_CANES_SE) {
> +			hecc_set_bit(priv, HECC_CANES, HECC_CANES_SE);
> +			cf->data[2] |= CAN_ERR_PROT_STUFF;
> +		}
> +		if (err_status & HECC_CANES_CRCE) {
> +			hecc_set_bit(priv, HECC_CANES, HECC_CANES_CRCE);
> +			cf->data[2] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> +					CAN_ERR_PROT_LOC_CRC_DEL);
> +		}
> +		if (err_status & HECC_CANES_ACKE) {
> +			hecc_set_bit(priv, HECC_CANES, HECC_CANES_ACKE);
> +			cf->data[2] |= (CAN_ERR_PROT_LOC_ACK |
> +					CAN_ERR_PROT_LOC_ACK_DEL);
> +		}
> +	}
> +
> +	netif_receive_skb(skb);
> +	ndev->last_rx = jiffies;
> +	stats->rx_packets++;
> +	stats->rx_bytes += cf->can_dlc;
> +	return 0;
> +}
> +
> +

Only one empty line please.

[snip]
> +static int ti_hecc_open(struct net_device *ndev)
> +{
> +	struct ti_hecc_priv *priv = netdev_priv(ndev);
> +	int err;
> +
> +	err = request_irq(ndev->irq, ti_hecc_interrupt, IRQF_DISABLED,
> +				ndev->name, ndev);
> +	if (err) {
> +		dev_err(ndev->dev.parent, "error requesting interrupt\n");
> +		return err;
> +	}
> +
> +	/* Open common can device */
> +	err = open_candev(ndev);
> +	if (err) {
> +		dev_err(ndev->dev.parent, "open_candev() failed %08X\n", err);
> +		free_irq(ndev->irq, ndev);
> +		return err;
> +	}
> +
> +	/* Initialize device and start net queue */
> +	spin_lock_init(&priv->tx_lock);
> +
> +	clk_enable(priv->clk);
> +	ti_hecc_start(ndev);
> +	napi_enable(&priv->napi);
> +	netif_start_queue(ndev);
> +
> +	dev_info(ndev->dev.parent, "device open\n");

Debugging!? Please remove.

> +	return 0;
> +}
> +
> +static int ti_hecc_close(struct net_device *ndev)
> +{
> +	struct ti_hecc_priv *priv = netdev_priv(ndev);
> +
> +	netif_stop_queue(ndev);
> +	napi_disable(&priv->napi);
> +	ti_hecc_stop(ndev);
> +	free_irq(ndev->irq, ndev);
> +	clk_disable(priv->clk);
> +	close_candev(ndev);
> +	dev_info(ndev->dev.parent, "device stopped\n");

Debugging!? Please remove.

> +
> +	return 0;
> +}
> +
> +static const struct net_device_ops ti_hecc_netdev_ops = {
> +	.ndo_open		= ti_hecc_open,
> +	.ndo_stop		= ti_hecc_close,
> +	.ndo_start_xmit		= ti_hecc_xmit,
> +};
> +
> +static int ti_hecc_probe(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = (struct net_device *)0;
> +	struct ti_hecc_priv *priv;
> +	struct ti_hecc_platform_data *pdata;
> +	struct resource *mem, *irq;
> +	void __iomem *addr;
> +	int err;
> +
> +	dev_dbg(&pdev->dev, " probing devices...\n");

Debugging!? Please remove.

> +	pdata = pdev->dev.platform_data;
> +	if (!pdata) {
> +		dev_err(&pdev->dev, "No platform data - exiting\n");
> +		return -ENODEV;
> +	}
> +
> +	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!mem) {
> +		dev_err(&pdev->dev, "no mem resources???\n");
> +		err = -ENODEV;
> +		goto probe_exit;
> +	}
> +	irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +	if (!irq) {
> +		dev_err(&pdev->dev, "no irq resourc???\n");
> +		err = -ENODEV;
> +		goto probe_exit;
> +	}
> +	if (!request_mem_region(mem->start, resource_size(mem), pdev->name)) {
> +		dev_err(&pdev->dev, "HECC region already claimed\n");
> +		err = -EBUSY;
> +		goto probe_exit;
> +	}
> +	addr = ioremap(mem->start, resource_size(mem));
> +	if (!addr) {
> +		dev_err(&pdev->dev, "ioremap failed\n");
> +		err = -ENOMEM;
> +		goto probe_exit_free_region;
> +	}
> +
> +	ndev = alloc_candev(sizeof(struct ti_hecc_priv));
> +	if (!ndev) {
> +		dev_err(&pdev->dev, "alloc_candev failed\n");
> +		err = -ENOMEM;
> +		goto probe_exit_iounmap;
> +	}
> +
> +	priv = netdev_priv(ndev);
> +	priv->ndev = ndev;
> +	priv->base = addr;
> +	priv->scc_ram_offset = pdata->scc_ram_offset;
> +	priv->hecc_ram_offset = pdata->hecc_ram_offset;
> +	priv->mbox_offset = pdata->mbox_offset;
> +	priv->int_line = pdata->int_line;
> +
> +	priv->can.bittiming_const = &ti_hecc_bittiming_const;
> +	priv->can.do_set_bittiming = ti_hecc_set_bittiming;
> +	priv->can.do_set_mode = ti_hecc_do_set_mode;
> +	priv->can.do_get_state = ti_hecc_get_state;
> +
> +	ndev->irq = irq->start;
> +	ndev->flags |= IFF_ECHO;
> +	platform_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +	ndev->netdev_ops = &ti_hecc_netdev_ops;
> +
> +	/* Note: clk name would change using hecc_vbusp_ck temporarily */
> +	priv->clk = clk_get(&pdev->dev, "hecc_vbusp_ck");
> +	if (IS_ERR(priv->clk)) {
> +		dev_err(&pdev->dev, "no clock available\n");
> +		err = PTR_ERR(priv->clk);
> +		priv->clk = NULL;
> +		goto probe_exit_candev;
> +	}
> +	priv->can.clock.freq = clk_get_rate(priv->clk);
> +	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
> +			TI_HECC_DEF_NAPI_WEIGHT);
> +
> +	err = register_candev(ndev);
> +	if (err) {
> +		dev_err(&pdev->dev, "register_candev() failed\n");
> +		err = -ENODEV;
> +		goto probe_exit_clk;
> +	}
> +	dev_info(&pdev->dev, "device registered (reg_base=%p, irq=%u)\n",
> +		priv->base, (u32) ndev->irq);

> +
> +	return 0;
> +
> +probe_exit_clk:
> +	clk_put(priv->clk);
> +probe_exit_candev:
> +	free_candev(ndev);
> +probe_exit_iounmap:
> +	iounmap(addr);
> +probe_exit_free_region:
> +	release_mem_region(mem->start, resource_size(mem));
> +probe_exit:
> +	dev_err(ndev->dev.parent, "probe error = %08X\n", err);
> +	return err;

You already printed an error message above.

[snip]

> +static void __exit ti_hecc_exit_driver(void)
> +{
> +	printk(KERN_INFO DRV_DESC " :Exit\n");
> +	platform_driver_unregister(&ti_hecc_driver);

This will only be called if the driver is unloaded, therefore:

	printk(KERN_INFO DRV_DESC " unloaded\n");

Apart from that, the patch looks good.

Wolfgang.
