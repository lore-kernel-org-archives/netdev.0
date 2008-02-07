From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2] net: sh_eth: Add support for Renesas SuperH Ethernet
Date: Thu, 7 Feb 2008 01:05:29 -0800
Message-ID: <20080207010529.868e931b.akpm@linux-foundation.org>
References: <47AAC3BB.9090107@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	David Brownell <david-b@pacbell.net>
To: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45957 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755261AbYBGJFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 04:05:36 -0500
In-Reply-To: <47AAC3BB.9090107@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Feb 2008 17:39:23 +0900 Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com> wrote:

> Add support for Renesas SuperH Ethernet controller.
> This driver supported SH7710 and SH7712.
> 

Nice looking driver.

Quick comments:

> ...
>
> +/*
> + * Program the hardware MAC address from dev->dev_addr.
> + */
> +static void __init update_mac_address(struct net_device *ndev)
> +{
> +	u32 ioaddr = ndev->base_addr;
> +
> +	ctrl_outl((ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
> +		  (ndev->dev_addr[2] << 8) | (ndev->dev_addr[3]),
> +		  ioaddr + MAHR);
> +	ctrl_outl((ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]),
> +		  ioaddr + MALR);
> +}
> +
> +/*
> + * Get MAC address from SuperH MAC address register
> + *
> + * SuperH's Ethernet device doesn't have 'ROM' to MAC address.
> + * This driver get MAC address that use by bootloader(U-boot or sh-ipl+g).
> + * When you want use this device, you must set MAC address in bootloader.
> + *
> + */
> +static void __init read_mac_address(struct net_device *ndev)
> +{
> +	u32 ioaddr = ndev->base_addr;
> +
> +	ndev->dev_addr[0] = (ctrl_inl(ioaddr + MAHR) >> 24);
> +	ndev->dev_addr[1] = (ctrl_inl(ioaddr + MAHR) >> 16) & 0xFF;
> +	ndev->dev_addr[2] = (ctrl_inl(ioaddr + MAHR) >> 8) & 0xFF;
> +	ndev->dev_addr[3] = (ctrl_inl(ioaddr + MAHR) & 0xFF);
> +	ndev->dev_addr[4] = (ctrl_inl(ioaddr + MALR) >> 8) & 0xFF;
> +	ndev->dev_addr[5] = (ctrl_inl(ioaddr + MALR) & 0xFF);
> +}

Both the above functions are called from non-__init code and hence cannot
be __init.  sh_eth_tsu_init() is wrong too.  Please check all section
annotations in the driver.

> +struct bb_info {
> +	struct mdiobb_ctrl ctrl;
> +	u32 addr;
> +	u32 mmd_msk;/* MMD */
> +	u32 mdo_msk;
> +	u32 mdi_msk;
> +	u32 mdc_msk;
> +};

Please cc David Brownell on updates to this driver - perhaps he will find
time to review the bit-banging interface usage.

> +/* PHY bit set */
> +static void bb_set(u32 addr, u32 msk)
> +{
> +	ctrl_outl(ctrl_inl(addr) | msk, addr);
> +}
> +
> +/* PHY bit clear */
> +static void bb_clr(u32 addr, u32 msk)
> +{
> +	ctrl_outl((ctrl_inl(addr) & ~msk), addr);
> +}
> +
> +/* PHY bit read */
> +static int bb_read(u32 addr, u32 msk)
> +{
> +	return (ctrl_inl(addr) & msk) != 0;
> +}
> +
> +/* Data I/O pin control */
> +static inline void sh__mmd_ctrl(struct mdiobb_ctrl *ctrl, int bit)
> +{
> +	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
> +	if (bit)
> +		bb_set(bitbang->addr, bitbang->mmd_msk);
> +	else
> +		bb_clr(bitbang->addr, bitbang->mmd_msk);
> +}
> +
> +/* Set bit data*/
> +static inline void sh__set_mdio(struct mdiobb_ctrl *ctrl, int bit)
> +{
> +	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
> +
> +	if (bit)
> +		bb_set(bitbang->addr, bitbang->mdo_msk);
> +	else
> +		bb_clr(bitbang->addr, bitbang->mdo_msk);
> +}
> +
> +/* Get bit data*/
> +static inline int sh__get_mdio(struct mdiobb_ctrl *ctrl)
> +{
> +	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
> +	return bb_read(bitbang->addr, bitbang->mdi_msk);
> +}

There seems to be a fairly random mixture of inline and non-inline here. 
I'd suggest that you just remove all the `inline's.  The compiler does a
pretty good job of working doing this for you.

> +/* MDC pin control */
> +static inline void sh__mdc_ctrl(struct mdiobb_ctrl *ctrl, int bit)
> +{
> +	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
> +
> +	if (bit)
> +		bb_set(bitbang->addr, bitbang->mdc_msk);
> +	else
> +		bb_clr(bitbang->addr, bitbang->mdc_msk);
> +}
> +
> +/* mdio bus control struct */
> +static struct mdiobb_ops bb_ops = {
> +	.owner = THIS_MODULE,
> +	.set_mdc = sh__mdc_ctrl,
> +	.set_mdio_dir = sh__mmd_ctrl,
> +	.set_mdio_data = sh__set_mdio,
> +	.get_mdio_data = sh__get_mdio,
> +};

It's particularly inappropriate that sh__mdc_ctrl() was inlined - it is
only ever called via a function pointer and hence will never be inlined!

> ...
>
> +static void sh_eth_timer(unsigned long data)
> +{
> +	struct net_device *ndev = (struct net_device *)data;
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +	int next_tick = 10 * HZ;
> +
> +	/* We could do something here... nah. */
> +	mdp->timer.expires = jiffies + next_tick;
> +	add_timer(&mdp->timer);

mod_timer() would be neater here.

> +}
>
> ...
>
> +
> +/* network device open function */
> +static int sh_eth_open(struct net_device *ndev)
> +{
> +	int ret = 0;
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +
> +	ret = request_irq(ndev->irq, &sh_eth_interrupt, 0, ndev->name, ndev);
> +	if (ret) {
> +		printk(KERN_ERR "Can not assign IRQ number to %s\n", CARDNAME);
> +		return ret;
> +	}
> +
> +	/* Descriptor set */
> +	ret = sh_eth_ring_init(ndev);
> +	if (ret)
> +		goto out_free_irq;
> +
> +	/* device init */
> +	ret = sh_eth_dev_init(ndev);
> +	if (ret)
> +		goto out_free_irq;
> +
> +	/* PHY control start*/
> +	ret = sh_eth_phy_start(ndev);
> +	if (ret)
> +		goto out_free_irq;
> +
> +	/* Set the timer to check for link beat. */
> +	init_timer(&mdp->timer);
> +	mdp->timer.expires = (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
> +	mdp->timer.data = (u32) ndev;
> +	mdp->timer.function = sh_eth_timer;	/* timer handler */

setup_timer()

> +	add_timer(&mdp->timer);
> +
> +	return ret;
> +
> +out_free_irq:
> +	free_irq(ndev->irq, ndev);
> +	return ret;
> +}
> +
> +/* Timeout function */
> +static void sh_eth_tx_timeout(struct net_device *ndev)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +	u32 ioaddr = ndev->base_addr;
> +	struct sh_eth_rxdesc *rxdesc;
> +	int i;
> +
> +	netif_stop_queue(ndev);
> +
> +	/* worning message out. */
> +	printk(KERN_WARNING "%s: transmit timed out, status %8.8x,"
> +	       " resetting...\n", ndev->name, (int)ctrl_inl(ioaddr + EESR));
> +
> +	/* tx_errors count up */
> +	mdp->stats.tx_errors++;
> +
> +	/* timer off */
> +	del_timer_sync(&mdp->timer);
> +
> +	/* Free all the skbuffs in the Rx queue. */
> +	for (i = 0; i < RX_RING_SIZE; i++) {
> +		rxdesc = &mdp->rx_ring[i];
> +		rxdesc->status = 0;
> +		rxdesc->addr = 0xBADF00D0;
> +		if (mdp->rx_skbuff[i])
> +			dev_kfree_skb(mdp->rx_skbuff[i]);
> +		mdp->rx_skbuff[i] = NULL;
> +	}
> +	for (i = 0; i < TX_RING_SIZE; i++) {
> +		if (mdp->tx_skbuff[i])
> +			dev_kfree_skb(mdp->tx_skbuff[i]);
> +		mdp->tx_skbuff[i] = NULL;
> +	}
> +
> +	/* device init */
> +	sh_eth_dev_init(ndev);
> +
> +	/* timer on */
> +	mdp->timer.expires = (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
> +	add_timer(&mdp->timer);

mod_timer()

> +}
> +
>
> +#ifdef __LITTLE_ENDIAN__
> +static inline void swaps(char *src, int len)
> +{
> +	u32 *p = (u32 *)src;
> +	u32 *maxp;
> +	maxp = p + ((len + sizeof(u32) - 1) / sizeof(u32));
> +
> +	for (; p < maxp; p++)
> +		*p = swab32(*p);
> +}
> +#else
> +#define swaps(x, y)
> +#endif
> +

I'd say that the big-endian version of swaps() should be a C function
rather than a macro.  It's nicer to look at, consistent, provides typechecking,
can help avoid unused-variable warnings (an inline function provides a
reference to the arguments whereas a macro does not).

The little-endian version of this function is too large to be inlined.

This function looks fairly generic.  Are we sure there isn't some library
function which does this?

