From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] NET: ethernet/netlogic: Netlogic XLR/XLS GMAC
 driver
Date: Wed, 06 Feb 2013 15:11:36 -0500 (EST)
Message-ID: <20130206.151136.28894146016087360.davem@davemloft.net>
References: <1360063819-17555-1-git-send-email-ganesanr@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: ganesanr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758168Ab3BFULi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:11:38 -0500
In-Reply-To: <1360063819-17555-1-git-send-email-ganesanr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ganesanr@broadcom.com
Date: Tue, 5 Feb 2013 17:00:19 +0530

> +config NETLOGIC_XLR_NET
> +	tristate "Netlogic XLR/XLS network device"
> +	default y
> +	select PHYLIB
> +	depends on CPU_XLR
> +	---help---
> +	This driver support Netlogic XLR/XLS on chip gigabit
> +	Ethernet.

No individual device driver should default to 'y'.   Vendor guards, yes, can
default to 'y', but not individual drivers.

> +/*
> + * The readl/writel implementation byteswaps on XLR/XLS, so
> + * we need to use __raw_ IO to read the NAE registers
> + * because they are in the big-endian MMIO area on the SoC.
> + */

Comments in the networking are to be formatted:

	/* Like
	 * this.
	 */

Please fix this up in your entire driver.

> +/*
> + * Table of net_device pointers indexed by port, this will be used to
> + * lookup the net_device corresponding to a port by the message ring handler.
> + *
> + * Maximum ports in XLR/XLS is 8(8 GMAC on XLS, 4 GMAC + 2 XGMAC on XLR)
> + */
> +static struct net_device *mac_to_ndev[8];

Make this a dynamic data structure, a parent device that the individual
netdevs are hung off of, it can still be an array.  That way you can have
a bonafide struct device instance and associated hierarchy of devices in
the kernel device list.

Also avoid this strange and non-standard usage of "MAC" as an integer
port index.  The canonical meaning of MAC is the link-layer address of
the device.

> +
> +static inline struct sk_buff *mac_get_skb_back_ptr(void *addr)
> +{
> +	struct sk_buff **back_ptr;
> +
> +	/* this function should be used only for newly allocated packets.
> +	 * It assumes the first cacheline is for the back pointer related
> +	 * book keeping info.
> +	 */
> +	back_ptr = (struct sk_buff **)(addr - MAC_SKB_BACK_PTR_SIZE);
> +	return *back_ptr;
> +}

Use the skb->cb[] control block rather than mis-using the skb data area
for storing internal driver state.

> +	paddr = virt_to_bus(addr);

virt_to_bus() is verboten, use the proper DMA APIs.  I don't care if
this is a specialized driver for a special platform.

> +		addr = bus_to_virt(msg->msg0 & 0xffffffffffULL);

bus_to_virt() is verbotten, use the proper DMA APIs and store correct
references to packets in a translation data structure in your per-netdev
software state.

> +static void __maybe_unused xlr_wakeup_queue(unsigned long dev)

This is really unused, just delete it.

That's enough for me, this driver needs a lot of work.
