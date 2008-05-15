From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/15] BE NIC driver - header and initialization functions
Date: Thu, 15 May 2008 12:49:40 +0100
Message-ID: <20080515114938.GI28241@solarflare.com>
References: <20080515090613.03bf6fa6@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:47656 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753772AbYEOLty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 07:49:54 -0400
Content-Disposition: inline
In-Reply-To: <20080515090240.5ecbd2e3@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subbu Seetharaman <subbus@serverengines.com> wrote:
> --- /dev/null
> +++ b/drivers/net/benet/be.h
> @@ -0,0 +1,329 @@
> +/*
> + * Copyright (C) 2005 - 2008 ServerEngines
> + * All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or at your option any later version.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> + * See the GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, 5th Floor
> + * Boston, MA 02110-1301 USA
> + *
> + *
> + * The full GNU General Public License is included in this distribution
> + * in the file called GPL.

Actually it's called COPYING.

> + * Contact Information:
> + * linux-drivers@serverengines.com
> + *
> + * ServerEngines
> + * 209 N. Fair Oaks Ave
> + * Sunnyvale, CA 94085
> + *
> + */

And this is a ridiculously long comment to put at the top of every source
file.

> +#ifndef _BE_H
> +#define _BE_H

I think the header guards need a prefix, as _BE_H may well clash with a
future generic header.

> +/*
> + * timer to prevent system shutdown hang for ever if h/w stops responding
> + */
> +struct be_timer_ctxt {
> +	atomic_t get_stat_flag;
> +	struct timer_list get_stats_timer;
> +	unsigned long get_stat_sem;	/* semaphore to wait  */
> +} ;

That's not a sempahore.  What is it really?

> +
> +/* This structure is the main BladeEngine driver context.  */
> +struct be_adapter {
> +	struct net_device *netdevp;
> +	struct be_drvr_stat be_stat;
> +	struct net_device_stats benet_stats;
> +	u32 num_bars;
> +	struct SA_DEV_BAR_LOCATIONS pci_bars[3];	/* PCI BAR details */
> +	struct SA_DEV sa_device;	/* device object owned by beclib */
> +	struct BE_CHIP_OBJECT chip_object;	/* BEClib chip object  */

These structure names really don't fit Linux naming conventions...

[...]
> +#define BE_MAX_MSIX_VECTORS             32
> +#define BE_MAX_REQ_MSIX_VECTORS         1 /* only one EQ in Linux driver */
> +	struct msix_entry msix_entries[BE_MAX_MSIX_VECTORS];
> +	bool msix_enabled;	/* MSI has been enabled */

Is this for MSI or for MSI-X?  The comment and name disagree.

> +/*
> + * linux_net_object is an extension to BNI's NetObject structure.
> + * NetObject has a pointer to this structure
> + */
> +struct linux_net_object {
> +	void *os_handle;	/* Context info for VMM */

Sure you can't be more specific about what that points to?

> +static inline void
> +update_eqd(struct be_adapter *adapter, struct bni_net_object *pnob)
> +{
> +	/* update once a second */
> +	if ((jiffies - adapter->ips_jiffies) > 1*(HZ)) {
> +		/* One second elapsed since last update	 */
> +		u32 r, new_eqd = -1;
> +		if (adapter->be_stat.bes_prev_ints >
> +				adapter->be_stat.bes_ints) {
> +			/* interrupt counter wrapped aroud */
> +			r = (0xFFFFFFFF - adapter->be_stat.bes_prev_ints) +
> +				adapter->be_stat.bes_ints;
> +		} else
> +			r = adapter->be_stat.bes_ints -
> +				adapter->be_stat.bes_prev_ints;

The branching here is redundant; unsigned subtraction will wrap around in
exactly the way you want (unless 0xFFFFFFFF really is skipped somehow).

> +void post_eth_rx_buffs(struct bni_net_object *);
> +void get_stat_cb(void *, BESTATUS, struct MCC_WRB_AMAP *);
> +
> +void get_stats_timer_handler(unsigned long);
> +
> +void enable_eq_intr(struct bni_net_object *);
> +void disable_eq_intr(struct bni_net_object *);
> +
> +void wait_nic_tx_cmpl(struct bni_net_object *);

These all need a be_ or benet_ prefix - an in-tree driver might not be
compiled as a module so its external symbols need to be unique within
the kernel.

> +static unsigned int msix; /* default - msix disabled */
> +module_param(msix, uint, (0 | 1));
> +MODULE_PARM_DESC(msix, "Use MSI-x interrupts");
> +
> +static unsigned int rxbuf_size = 2048;	/* Size of RX buffers */
> +module_param(rxbuf_size, uint, 0);
> +MODULE_PARM_DESC(rxbuf_size, "Size of buffers to hold Rx data");

The third parameter to module_param() is a permission mask, and should normally
be 0444 (read-only) or 0644 (read-write to root, read-only to others).

> +/*
> + * Intialize and register a network device for the pnob.
> + */
> +static int
> +init_be_netdev(struct be_adapter *adapter, struct bni_net_object *pnob)
> +{
> +	struct net_device *netdev;
> +	int ret = 0;
> +	unsigned char *p;
> +
> +#ifdef CONFIG_PM
> +	if (adapter->pm_resume) {
> +		bni_set_uc_mac_adr(pnob, 0, 0, 0,
> +				   (struct SA_MAC_ADDRESS *) pnob->mac_address,
> +				   NULL, NULL);
> +		return 0;
> +	}
> +#endif

Why is this function doing something completely different depending on this
flag?

> +	/*
> +	 * Allocate netdev. No private data structure is
> +	 * allocated with netdev
> +	 */

Why not?

> +	memcpy(netdev->dev_addr, pnob->mac_address, 6);

Should use ETH_ALEN instead of a literal 6.

> +	netdev->priv = pnob;	/* We use the Net Object as private data */
> +	netdev->init = &benet_probe;
> +	/*
> +	 * Initialize to No Link.  Link will be enabled during
> +	 * benet_open() or when physical Link is up
> +	 */
> +	netif_carrier_off(netdev);
> +	netif_stop_queue(netdev);
> +
> +	strcpy(netdev->name, "eth%d");

alloc_etherdev() does this for you.

> +/*
> + * Registers ISR for BE. Uses MSIx interrupt if configured and requested.
> + * If not, uses INTx interrupt. Returns 0 for success and -1 for filure.
> + */
> +static int
> +be_register_isr(struct be_adapter *adapter, struct bni_net_object *pnob)
> +{
> +	int msix_intr, r;
> +	struct net_device *netdev = OSM_NOB(pnob)->os_handle;
> +	u32 msix_ret = 0;
> +
> +	netdev->irq = adapter->pdev->irq;
> +
> +	msix_intr = 0;
> +	msix_ret = be_enable_msix(adapter);
> +	if (msix_ret) {

You could do without the msix_ret variable.

> +		/* Register MSIx Interrupt handler */
> +		r = request_irq(adapter->msix_entries[0].vector,
> +				(void *)be_int, IRQF_SHARED,

Why are you casting a function pointer here?

> +				netdev->name, netdev);
> +		if (r) {
> +			printk(KERN_WARNING
> +			       "MSIX Request IRQ failed - Errno %d\n", r);
> +		} else {
> +			msix_intr = 1;
> +		}
> +	}
> +	if (msix_intr == 0) {
> +		/* request legacy INTx interrupt */
> +		r = request_irq(netdev->irq, (void *)be_int,
> +				IRQF_SHARED, netdev->name, netdev);

Again you're casting a function pointer.

> +	if ((adapter->isr_registered) & (adapter->msix_enabled))
> +		free_irq(adapter->msix_entries[0].vector, netdev);
> +	else if ((adapter->isr_registered) & !(adapter->msix_enabled))
> +		free_irq(netdev->irq, netdev);

I think these are booleans, not bitmasks, so you should use && not &.

> +	unregister_netdev(netdev);
> +	/* memory associted with netdev is freed by OS  */

Not by unregister_netdev(), it's not.

> +/*
> + * this function creates a pnob with a set of Eth rings.
> + */
> +static int
> +be_prepare_interface(struct be_adapter *adapter)
> +{
[...]
> +		/* Mailbox pointer needs to be 16 byte aligned */
> +		pnob->mb_ptr = p;
> +		p = (void *) ((unsigned long)(p + 15) & ~0xf);

You can use PTR_ALIGN() for this.

> +		pnob->mb_sgl.va = (void *)p;

Redundant cast.

> +err_ret1:
> +	printk(KERN_ERR "Interface initialization failed\n");
> +	return -1;

This leaks all the pages that were successfully allocated.

> +}
> +
> +/* This function handles async callback for link status */
> +static void
> +be_link_status_async_callback(void *context, u32 event_code, void *event)
> +{
> +	struct ASYNC_EVENT_LINK_STATE_AMAP *link_status =
> +				(struct ASYNC_EVENT_LINK_STATE_AMAP *) event;
> +	struct be_adapter *adapter = (struct be_adapter *) context;

Redundant casts.

[...]
> +	if (async_event_type == NTWK_LINK_TYPE_VIRTUAL) {
> +		adapter->be_stat.bes_link_change_virtual++;
> +		if (adapter->be_link_sts->active_port != active_port) {
> +			printk(KERN_NOTICE
> +				"Active port changed due to VLD on switch\n");
> +		} else {
> +			/* Link of atleast one of the ports changed */
> +			printk(KERN_NOTICE "Link status update\n");
> +		}
> +
> +	} else {
> +		adapter->be_stat.bes_link_change_physical++;
> +		if (adapter->be_link_sts->active_port != active_port) {
> +			printk(KERN_NOTICE
> +				"Active port changed due to port link status"
> +				" change\n");
> +		} else {
> +			/* Link of atleast one of the ports changed */
> +			printk(KERN_NOTICE "Link status update\n");
> +		}
> +	}

None of these printk()s are going to say which device they're referring
to.  You should be using the dev_*() logging macros.

[...]
> +	/* if this netdevice's carrier is not down, then indicate to stack */

I think "not" should be "now"?

> +	if (netif_carrier_ok(netdev)) {
> +		netif_carrier_off(netdev);
> +		netif_stop_queue(netdev);
> +	}
> +	return;
> +}
> +
> +/* Function to initialize MCC rings */
> +static int
> +be_mcc_init(struct be_adapter *adapter)
> +{
[...]
> +cleanup:
> +	return -ENOMEM;

Also leaks pages.

> +
> +}
> +
> +static void
> +be_remove(struct pci_dev *pdev)
> +{
> +	struct bni_net_object *pnob = NULL;
> +	struct be_adapter *adapter = NULL;

Redundant initialisation.

> +	int status;
> +	int i;
> +
> +	adapter = pci_get_drvdata(pdev);
> +	pnob = (struct bni_net_object *) adapter->net_obj;
> +
> +	SA_ASSERT(adapter);
> +
> +	flush_scheduled_work();
> +
> +	/* Unregister async call back function for link status updates */
> +	status = be_mcc_add_async_event_callback(&pnob->mcc_q_obj, NULL, NULL);
> +	if (status != BE_SUCCESS)
> +		printk(KERN_WARNING "Unregister async callback for link "
> +		       "status updates failed.\n");

This might call for a BUG_ON() if this callback may still be called with the
adapter context gone.

> +/*
> + * This function is called by the PCI sub-system when it finds a PCI
> + * device with dev/vendor IDs that match with one of our devices.
> + * All of the driver initialization is done in this function.
> + */
> +static int
> +be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
> +{
> +	int status = 0;
> +	struct be_adapter *adapter = NULL;
> +	u32 r;
> +	u32 adapt_num = 0;
> +	struct IOCTL_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD ioctl_pload;
> +	struct bni_net_object *pnob = NULL;
> +
> +	status = pci_enable_device(pdev);
> +	if (status) {
> +		printk(KERN_ERR "pci_enable_device() for BE adapter %d failed",
> +		       adapt_num);

adapt_num is always 0.  You should use pci_name() to identify the device
(and the dev_*() logging macros will do this for you).

> +		return status;
> +	}
> +
> +	status = pci_request_regions(pdev, be_driver_name);
> +	if (status)
> +		return status;

The device is still enabled in this case (and in the later error cases).

[...]
> +	(void)sa_trace_set_level((DL_ALWAYS | DL_ERR));

Don't bother casting to void.

> +/*
> +
> +@file
> +    bni.h
> +
> +@brief
> +    Definitions and macros that are required for all .c files
> +    that use the BNI API and implement the BNI API functions
> +*/

Use kernel-doc format for structured comments rather than Doxygen -
see Documentation/kernel-doc-nano-HOWTO.txt.

> +/*
> + * Functions to advance the head and tail in various rings.
> + */
> +static INLINE void bni_adv_eq_tl(struct bni_net_object *pnob)
> +{
> +	pnob->event_q_tl = (pnob->event_q_tl + 1) % pnob->event_q_len;
> +}

INLINE is presumably defined as inline, which is a bit pointless.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
