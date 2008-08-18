From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Linux Device Driver for Xilinx LL TEMAC 10/100/1000 Ethernet NIC
Date: Mon, 18 Aug 2008 13:30:58 +0100
Message-ID: <20080818123056.GA7908@solarflare.com>
References: <48A7B01C.2070403@dlasys.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-embedded <linuxppc-embedded@ozlabs.org>,
	netdev@vger.kernel.org
To: "David H. Lynch Jr." <dhlii@dlasys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:54494 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755027AbYHRMbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 08:31:10 -0400
Content-Disposition: inline
In-Reply-To: <48A7B01C.2070403@dlasys.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David H. Lynch Jr. wrote:
[...]
>  drivers/net/Kconfig            |    5
>  drivers/net/Makefile           |    1
>  drivers/net/xps_lltemac.c      | 1283
> ++++++++++++++++++++++++++++++++++++++++

You need to disable line-wrapping for posted patches.  If your mailer
always wraps the body of a message, send the patch as an attachment.

Some of the code appears to be indented wrongly but that may also have
been broken by your mailer.  Use scripts/checkpatch.pl to find the
formatting errors.

[...]
> diff --git a/drivers/net/xps_lltemac.c b/drivers/net/xps_lltemac.c
> new file mode 100644
> index 0000000..1f2c158
> --- /dev/null
> +++ b/drivers/net/xps_lltemac.c
> @@ -0,0 +1,1283 @@
> +/*======================================================================
> +
> + Driver for Xilinx temac ethernet NIC's
> +
> + Author: Yoshio Kashiwagi
> + Copyright (c) 2008 Nissin Systems Co.,Ltd.
> +
> + Revisons: David H. Lynch Jr. <dhlii@dlasys.net>
> + Copyright (C) 2005-2008 DLA Systems
> +
> +======================================================================*/
> +
> +#define DRV_NAME        "xilinx_lltemac"

Should be "xps_lltemac" to match the module name.

[...]
> +#include <asm/io.h>

Should be <linux/io.h>; <asm/io.h> doesn't define the same things on every
architecture.

> +/* register access modes */
> +typedef enum { REG_DCR = 1, REG_IND, REG_DIR} REG_MODE;

typedef'd names are deprecated, and enum/struct/union names should be
lower-case.

[...]
> +/* packet size info */
> +#define XTE_MTU                     1500        /* max MTU size of
> Ethernet frame */
> +#define XTE_HDR_SIZE                14          /* size of Ethernet
> header */
> +#define XTE_TRL_SIZE                4           /* size of Ethernet
> trailer (FCS) */
> +#define XTE_MAX_FRAME_SIZE          (XTE_MTU + XTE_HDR_SIZE + XTE_TRL_SIZE)

What about VLAN tags?

[...]
> This option defaults to enabled (set) */
> +#define XTE_OPTION_TXEN                         (1 << 11)   /**< Enable
> the transmitter.  This option defaults to enabled (set) */
> +#define XTE_OPTION_RXEN                         (1 << 12)   /**< Enable
> the receiver This option defaults to enabled (set) */
> +#define XTE_OPTION_DEFAULTS                     \
> +    (XTE_OPTION_TXEN |            \
> +     XTE_OPTION_FLOW_CONTROL |                  \
> +     XTE_OPTION_RXEN)                /**< Default options set when
> device is initialized or reset */

"/**<" looks like the start of a doxygen comment.  You should use kernel-
doc format for structured comments.

[...]
> +#define ALIGNMENT       32

That name is a bit generic and might result in a clash later.  How about
using XTE_ALIGNMENT instead?

[...]
> +static u32
> +_ior(u32 offset)
> +{
> +    u32 value;
> +    value = (*(volatile u32 *)(offset));
> +    __asm__ __volatile__("eieio");
> +    return value;
> +}
> +
> +static void
> +_iow(u32 offset, u32 value)
> +{
> +    (*(volatile u32 *)(offset) = value);
> +    __asm__ __volatile__("eieio");
> +}

Why aren't you using the generic I/O functions?

If this driver is PowerPC specific, you need to declare that dependency
in Kconfig.

[...]
> +/***************************************************************************
> + * Reads an MII register from the MII PHY attached to the Xilinx Temac.
> + *
> + * Parameters:
> + *   dev      - the temac device.
> + *   phy_addr - the address of the PHY [0..31]
> + *   reg_num  - the number of the register to read. 0-6 are defined by
> + *              the MII spec, but most PHYs have more.
> + *   reg_value - this is set to the specified register's value
> + *
> + * Returns:
> + *   Success or Failure
> + */

Again, use kernel-doc for structured comments.

The "Returns" description is wrong.

> +static unsigned int
> +mdio_read(struct net_device *ndev, int phy_id, int reg_num)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +    u32 timeout = PHY_TIMEOUT;
> +    u32 rv = 0;
> +    unsigned long flags;
> +
> +    if (lp->mii) {
> +        spin_lock_irqsave(&lp->lock, flags);
> +
> +        tiow(ndev, XTE_LSW0_OFFSET, ((phy_id << 5) | (reg_num)));

You need to range-check reg_num before this point.

> +        tiow(ndev, XTE_CTL0_OFFSET, XTE_MIIMAI_OFFSET | (lp->emac_num
> << 10));
> +        while(!(tior(ndev, XTE_RDY0_OFFSET) & XTE_RSE_MIIM_RR_MASK) &&
> timeout--);

You must not use a simple counter for timing loops.  Use udelay() to wait
between polling attempts.  Also, never put a semi-colon on the same line
as the while-statement.

> +        rv = tior(ndev, XTE_LSW0_OFFSET);
> +
> +        spin_unlock_irqrestore(&lp->lock, flags);
> +    }
> +    return rv;
> +}

The same problems apply to mdio_write(), emac_cfg_read() and
emac_cfg_write().

> +static u32
> +emac_cfg_setclr(struct net_device *ndev, u32 reg_num, u32 val, int flg)
> +{
> +        u32 Reg = emac_cfg_read(ndev, reg_num) & ~val;
> +        if (flg)
> +            Reg |= val;
> +        emac_cfg_write(ndev, reg_num, Reg);
> +        return 0;
> +}
> +
> +/*
> +Changes the mac address if the controller is not running.
> +
> +static int (*set_mac_address)(struct net_device *dev, void *addr);
> +Function that can be implemented if the interface supports the ability
> to change its
> +hardware address. Many interfaces don't support this ability at all.
> Others use the
> +default eth_mac_addr implementation (from drivers/net/net_init.c).
> eth_mac_addr
> +only copies the new address into dev->dev_addr, and it does so only if
> the interface
> +is not running. Drivers that use eth_mac_addr should set the hardware MAC
> +address from dev->dev_addr in their open method.
> +
> +*/

This comment and several others following it appear to be copied from some
tutorial documentation and are not very useful for this specific
implementation.  Please remove them.

[...]
> +static void
> +temac_set_multicast_list(struct net_device *ndev)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +    u32 multi_addr_msw, multi_addr_lsw;
> +    int i;
> +
> +    spin_lock(&lp->lock);
> +
> +    if(ndev->flags & IFF_PROMISC) {
> +        printk(KERN_NOTICE "%s: Promiscuos mode enabled.\n", ndev->name);

Typo: the word is "promiscuous".

> +        emac_cfg_write(ndev, XTE_AFM_OFFSET, 0x80000000);
> +    }  else {
> +        struct dev_mc_list *mclist;
> +        for(i = 0, mclist = ndev->mc_list; mclist && i <
> ndev->mc_count; i++, mclist = mclist->next) {
> +
> +            if(i >= MULTICAST_CAM_TABLE_NUM) break;

So you just ignore the remaining addresses?!

Surely you should add "|| ndev->mc_count > MULTICAST_CAM_TABLE_NUM" to the
condition for setting the MAC to be promiscuous?

> +            multi_addr_msw = ((mclist->dmi_addr[3] << 24) |
> (mclist->dmi_addr[2] << 16) | (mclist->dmi_addr[1] << 8) |
> mclist->dmi_addr[0]);
> +            emac_cfg_write(ndev, XTE_MAW0_OFFSET, multi_addr_msw);
> +            multi_addr_lsw = ((mclist->dmi_addr[5] << 8) |
> mclist->dmi_addr[4]);
> +            multi_addr_lsw |= (i << 16);
> +            emac_cfg_write(ndev, XTE_MAW1_OFFSET, multi_addr_lsw);
> +        }
> +    }
> +    spin_unlock(&lp->lock);
> +}
> +
> +static void
> +temac_phy_init(struct net_device *ndev)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +    unsigned int ret, Reg;
> +    int ii;
> +
> +    /* Set default MDIO divisor */
> +    /* Set up MII management registers to write to PHY  */
> +    emac_cfg_write(ndev, XTE_MC_OFFSET, XTE_MC_MDIO_MASK |
> XTE_MDIO_DIV_DFT);
> +
> +    /*
> +       Set A-N Advertisement Regs for Full Duplex modes ONLY
> +       address 4 = Autonegotiate Advertise Register
> +       Disable 1000 Mbps for negotiation if not built for GEth

There's no conditional here so this last line doesn't make sense.

> +     */
> +    mdio_write(ndev, PHY_NUM, MII_ADVERTISE, mdio_read(ndev, PHY_NUM,
> MII_ADVERTISE) | ADVERTISE_10FULL | ADVERTISE_100FULL | ADVERTISE_CSMA);
> +    mdio_write(ndev, PHY_NUM, MII_CTRL1000, ADVERTISE_1000FULL);
> +
> +    /*
> +       Soft reset the PHY
> +       address 0 = Basic Mode Control Register

You're using MII_BMCR so this line of the comment is unneeded.

> +     */
> +    mdio_write(ndev, PHY_NUM, MII_BMCR, mdio_read(ndev, PHY_NUM,
> MII_BMCR) | BMCR_RESET | BMCR_ANENABLE | BMCR_ANRESTART);
> +
> +    /* Wait for a PHY Link (auto-negotiation to complete)...  */

Why?  You should handle AN using a delayed work item or PHY interrupts.

[...]
> +/* this is how to get skb's aligned !!! */

We know.

> +        align = BUFFER_ALIGN(skb->data);
> +        if(align)
> +            skb_reserve(skb, align);

There's no harm in passing 0 to skb_reserve; remove the test and combine
the remaining two lines.

[...]
> +    sd_iow(ndev, TX_CHNL_CTRL, 0x10220400 | CHNL_CTRL_IRQ_EN |
> CHNL_CTRL_IRQ_DLY_EN | CHNL_CTRL_IRQ_COAL_EN);
> +    /* sd_iow(ndev, TX_CHNL_CTRL, 0x10220483); */
> +    /*sd_iow(ndev, TX_CHNL_CTRL, 0x00100483); */
> +    sd_iow(ndev, RX_CHNL_CTRL, 0xff010000 | CHNL_CTRL_IRQ_EN |
> CHNL_CTRL_IRQ_DLY_EN | CHNL_CTRL_IRQ_COAL_EN | CHNL_CTRL_IRQ_IOE);
> +    /* sd_iow(ndev, RX_CHNL_CTRL, 0xff010283); */

Don't comment-out code.  If it's wrong, delete it.

[...]
> +/*****************************************************************************/
> +/**
> + * Set options for the driver/device. The driver should be stopped with
> + * XTemac_Stop() before changing options.
> + *
> + * @param InstancePtr is a pointer to the instance to be worked on.
> + * @param Options are the options to set. Multiple options can be set
> by OR'ing
> + *        XTE_*_OPTIONS constants together. Options not specified are not
> + *        affected.
> + *
> + * @return
> + * - 0 if the options were set successfully
> + * - XST_DEVICE_IS_STARTED if the device has not yet been stopped
> + * - XST_NO_FEATURE if setting an option requires HW support not present
> + *
> + * @note
> + * See xtemac.h for a description of the available options.
> +
> ******************************************************************************/

Kill this comment; it's in the wrong format and full of misinformation.

> +static void
> +temac_hard_start_xmit_done(struct net_device *ndev)
> +{
[...]
> +    if(netif_queue_stopped(ndev)) {
> +        netif_wake_queue(ndev);

Remove the test; netif_wake_queue() does that itself.

> +    }
> +}
> +
> +static int
> +temac_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +    struct cdmac_bd *cur_p, *start_p, *tail_p;
> +    int i;
> +    unsigned long num_frag;
> +    skb_frag_t *frag;
> +
> +    spin_lock(&lp->tx_lock);

The kernel has its own TX lock so you shouldn't need this.  Use
netif_tx_lock() to synchronise TX reconfiguration with this.

> +    num_frag = skb_shinfo(skb)->nr_frags;
> +    frag = &skb_shinfo(skb)->frags[0];
> +    start_p = &lp->tx_bd_p[lp->tx_bd_tail];
> +    cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
> +
> +    if(cur_p->app0 & STS_CTRL_APP0_CMPLT) {
> +        if(!netif_queue_stopped(ndev)) {
> +            netif_stop_queue(ndev);
> +            spin_unlock(&lp->tx_lock);
> +            return NETDEV_TX_BUSY;
> +        }
> +        return NETDEV_TX_BUSY;

Here tx_lock is left locked if you stop the queue.  What are you trying
to do here?

[...]
> +/*
> +Stop the interface.
> +Stops the interface. The interface is stopped when it is brought down.
> +This function should reverse operations performed at open time.
> +*/
> +static int
> +temac_stop(struct net_device *ndev)
> +{
> +    return 0;

You are missing some code here...

[...]
> +static struct net_device_stats *
> +temac_get_stats(struct net_device *ndev)
> +{
> +    return netdev_priv(ndev);

Not even the right type.  Do you read your compiler warnings?

> +}
> +
> +static int
> +temac_open(struct net_device *ndev)
> +{
> +
> +    return 0;

You have got to be kidding.

[...]
> +static int
> +temac_change_mtu(struct net_device *ndev, int newmtu)
> +{
> +    dev_info(ndev, "new MTU %d\n", newmtu);
> +    ndev->mtu = newmtu; /* change mtu in net_device structure */

Needs range-checking.  Or you can just use the default implementation.

> +    return 0;
> +}
[...]

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
