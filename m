From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Thu, 1 May 2008 12:08:58 -0700
Message-ID: <20080501120858.207b6dd6.akpm@linux-foundation.org>
References: <200804301925.m3UJPc72001651@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55206 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755044AbYEATJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 15:09:05 -0400
In-Reply-To: <200804301925.m3UJPc72001651@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Apr 2008 19:25:38 GMT
Linux Kernel Mailing List <linux-kernel@vger.kernel.org> wrote:

> Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=8ceee660aacb29721e26f08e336c58dc4847d1bd
> Commit:     8ceee660aacb29721e26f08e336c58dc4847d1bd
> Parent:     358c12953b88c5a06a57c33eb27c753b2e7934d1
> Author:     Ben Hutchings <bhutchings@solarflare.com>
> AuthorDate: Sun Apr 27 12:55:59 2008 +0100
> Committer:  Jeff Garzik <jgarzik@redhat.com>
> CommitDate: Tue Apr 29 01:42:43 2008 -0400
> 
>     New driver "sfc" for Solarstorm SFC4000 controller.
>     
>     The driver supports the 10Xpress PHY and XFP modules on our reference
>     designs SFE4001 and SFE4002 and the SMC models SMC10GPCIe-XFP and
>     SMC10GPCIe-10BT.
>     
>     Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>
> ..
>
> --- /dev/null
> +++ b/drivers/net/sfc/bitfield.h
>

weep.

This entire (large, complex, undocumeted) header file contains quite
generally applicable code which could be used from many many other parts of
the kernel.  Yet here it all is, stuffed way down in drivers/net/sfc/.

What happens if all drivers do this?  Well, they do.  We get a mess.

btw, the implementation is riotously buggy if anyone passes any of these
macros an expression which has side-effects.

> ...
>
> --- /dev/null
> +++ b/drivers/net/sfc/boards.c
> @@ -0,0 +1,167 @@
> +/****************************************************************************
> + * Driver for Solarflare Solarstorm network controllers and boards
> + * Copyright 2007 Solarflare Communications Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published
> + * by the Free Software Foundation, incorporated herein by reference.
> + */
> +
> +#include "net_driver.h"
> +#include "phy.h"
> +#include "boards.h"
> +#include "efx.h"
> +
> +/* Macros for unpacking the board revision */
> +/* The revision info is in host byte order. */
> +#define BOARD_TYPE(_rev) (_rev >> 8)
> +#define BOARD_MAJOR(_rev) ((_rev >> 4) & 0xf)
> +#define BOARD_MINOR(_rev) (_rev & 0xf)
> +
> +/* Blink support. If the PHY has no auto-blink mode so we hang it off a timer */
> +#define BLINK_INTERVAL (HZ/2)
> +
> +static void blink_led_timer(unsigned long context)
> +{
> +	struct efx_nic *efx = (struct efx_nic *)context;
> +	struct efx_blinker *bl = &efx->board_info.blinker;
> +	efx->board_info.set_fault_led(efx, bl->state);
> +	bl->state = !bl->state;
> +	if (bl->resubmit) {
> +		bl->timer.expires = jiffies + BLINK_INTERVAL;
> +		add_timer(&bl->timer);

mod_timer()

> +	}
> +}
> +
> +static inline int efx_process_channel(struct efx_channel *channel, int rx_quota)
> +{
> +	int rxdmaqs;
> +	struct efx_rx_queue *rx_queue;
> +
> +	if (unlikely(channel->efx->reset_pending != RESET_TYPE_NONE ||
> +		     !channel->enabled))
> +		return rx_quota;
> +
> +	rxdmaqs = falcon_process_eventq(channel, &rx_quota);
> +
> +	/* Deliver last RX packet. */
> +	if (channel->rx_pkt) {
> +		__efx_rx_packet(channel, channel->rx_pkt,
> +				channel->rx_pkt_csummed);
> +		channel->rx_pkt = NULL;
> +	}
> +
> +	efx_flush_lro(channel);
> +	efx_rx_strategy(channel);
> +
> +	/* Refill descriptor rings as necessary */
> +	rx_queue = &channel->efx->rx_queue[0];
> +	while (rxdmaqs) {
> +		if (rxdmaqs & 0x01)
> +			efx_fast_push_rx_descriptors(rx_queue);
> +		rx_queue++;
> +		rxdmaqs >>= 1;
> +	}
> +
> +	return rx_quota;
> +}

This has two callsites and is far far too large to be inlined.

> +/* Mark channel as finished processing
> + *
> + * Note that since we will not receive further interrupts for this
> + * channel before we finish processing and call the eventq_read_ack()
> + * method, there is no need to use the interrupt hold-off timers.
> + */
> +static inline void efx_channel_processed(struct efx_channel *channel)
> +{
> +	/* Write to EVQ_RPTR_REG.  If a new event arrived in a race
> +	 * with finishing processing, a new interrupt will be raised.
> +	 */
> +	channel->work_pending = 0;
> +	smp_wmb(); /* Ensure channel updated before any new interrupt. */

Is smp_wmb() the right thing here?  I think you're trying to ensure that
the CPU has issued the store before we write the interrupt ack to the
hardware, yes?

If so, the problem which you're addressing can occur on non-SMP hardware
too?

> +	falcon_eventq_read_ack(channel);
> +}
> +
> +void efx_process_channel_now(struct efx_channel *channel)
> +{
> +	struct efx_nic *efx = channel->efx;
> +
> +	BUG_ON(!channel->used_flags);
> +	BUG_ON(!channel->enabled);
> +
> +	/* Disable interrupts and wait for ISRs to complete */
> +	falcon_disable_interrupts(efx);
> +	if (efx->legacy_irq)
> +		synchronize_irq(efx->legacy_irq);
> +	if (channel->has_interrupt && channel->irq)
> +		synchronize_irq(channel->irq);
> +
> +	/* Wait for any NAPI processing to complete */
> +	napi_disable(&channel->napi_str);
> +
> +	/* Poll the channel */
> +	(void) efx_process_channel(channel, efx->type->evq_size);

There's little point in the (void) thing ans we usually don't do it.

For a start: do all non-checked, non-void-returning functions in this
driver have the (void)?  We don't know, because there's no way to tell.  it
isn't maintainable.

> +	/* Ack the eventq. This may cause an interrupt to be generated
> +	 * when they are reenabled */
> +	efx_channel_processed(channel);
> +
> +	napi_enable(&channel->napi_str);
> +	falcon_enable_interrupts(efx);
> +}
> +
> +static void efx_calc_rx_buffer_params(struct efx_nic *efx)
> +{
> +	unsigned int order, len;
> +
> +	len = (max(EFX_PAGE_IP_ALIGN, NET_IP_ALIGN) +
> +	       EFX_MAX_FRAME_LEN(efx->net_dev->mtu) +
> +	       efx->type->rx_buffer_padding);
> +
> +	/* Calculate page-order */
> +	for (order = 0; ((1u << order) * PAGE_SIZE) < len; ++order)
> +		;

get_order()

> +	efx->rx_buffer_len = len;
> +	efx->rx_buffer_order = order;
> +}
> +
> +static void efx_start_channel(struct efx_channel *channel)
> +{
> +	struct efx_rx_queue *rx_queue;
> +
> +	EFX_LOG(channel->efx, "starting chan %d\n", channel->channel);
> +
> +	if (!(channel->efx->net_dev->flags & IFF_UP))
> +		netif_napi_add(channel->napi_dev, &channel->napi_str,
> +			       efx_poll, napi_weight);
> +
> +	channel->work_pending = 0;
> +	channel->enabled = 1;
> +	smp_wmb(); /* ensure channel updated before first interrupt */

etc.

> +	napi_enable(&channel->napi_str);
> +
> +	/* Load up RX descriptors */
> +	efx_for_each_channel_rx_queue(rx_queue, channel)
> +		efx_fast_push_rx_descriptors(rx_queue);
> +}
> +
> +/* This disables event queue processing and packet transmission.
> + * This function does not guarantee that all queue processing
> + * (e.g. RX refill) is complete.
> + */
> +static void efx_stop_channel(struct efx_channel *channel)
> +{
> +	struct efx_rx_queue *rx_queue;
> +
> +	if (!channel->enabled)
> +		return;
> +
> +	EFX_LOG(channel->efx, "stop chan %d\n", channel->channel);
> +
> +	channel->enabled = 0;
> +	napi_disable(&channel->napi_str);
> +
> +	/* Ensure that any worker threads have exited or will be no-ops */
> +	efx_for_each_channel_rx_queue(rx_queue, channel) {
> +		spin_lock_bh(&rx_queue->add_lock);
> +		spin_unlock_bh(&rx_queue->add_lock);

whee.  Does this work correctly on CONFIG_SMP=n builds?

> +	}
> +}
> +
> +static int efx_probe_port(struct efx_nic *efx)
> +{
> +	int rc;
> +
> +	EFX_LOG(efx, "create port\n");
> +
> +	/* Connect up MAC/PHY operations table and read MAC address */
> +	rc = falcon_probe_port(efx);
> +	if (rc)
> +		goto err;
> +
> +	/* Sanity check MAC address */
> +	if (is_valid_ether_addr(efx->mac_address)) {
> +		memcpy(efx->net_dev->dev_addr, efx->mac_address, ETH_ALEN);
> +	} else {
> +		DECLARE_MAC_BUF(mac);

whodidthat?  DECLARE_MAC_BUF() is a definition, not a declaration.

> +		EFX_ERR(efx, "invalid MAC address %s\n",
> +			print_mac(mac, efx->mac_address));
> +		if (!allow_bad_hwaddr) {
> +			rc = -EINVAL;
> +			goto err;
> +		}
> +		random_ether_addr(efx->net_dev->dev_addr);
> +		EFX_INFO(efx, "using locally-generated MAC %s\n",
> +			 print_mac(mac, efx->net_dev->dev_addr));
> +	}
> +
> +	return 0;
> +
> + err:
> +	efx_remove_port(efx);
> +	return rc;
> +}
>
> ...
>
> +static void efx_stop_port(struct efx_nic *efx)
> +{
> +	EFX_LOG(efx, "stop port\n");
> +
> +	mutex_lock(&efx->mac_lock);
> +	efx->port_enabled = 0;
> +	mutex_unlock(&efx->mac_lock);

A lock-around-a-single-atomic-write always get me going.  It's _sometimes_
legitimate: if the other code paths which access the storage are reading it
multiple times within the same locked region, and expect all acesses to
return the same vaule.

But often that isn't the case, and there's a buglet, or unneeded locking.

> +	/* Serialise against efx_set_multicast_list() */
> +	if (NET_DEV_REGISTERED(efx)) {
> +		netif_tx_lock_bh(efx->net_dev);
> +		netif_tx_unlock_bh(efx->net_dev);
> +	}
> +}
>
> ...
>
> +static int efx_init_io(struct efx_nic *efx)
> +{
> +	struct pci_dev *pci_dev = efx->pci_dev;
> +	dma_addr_t dma_mask = efx->type->max_dma_mask;
> +	int rc;
> +
> +	EFX_LOG(efx, "initialising I/O\n");
> +
> +	rc = pci_enable_device(pci_dev);
> +	if (rc) {
> +		EFX_ERR(efx, "failed to enable PCI device\n");
> +		goto fail1;
> +	}
> +
> +	pci_set_master(pci_dev);
> +
> +	/* Set the PCI DMA mask.  Try all possibilities from our
> +	 * genuine mask down to 32 bits, because some architectures
> +	 * (e.g. x86_64 with iommu_sac_force set) will allow 40 bit
> +	 * masks event though they reject 46 bit masks.
> +	 */
> +	while (dma_mask > 0x7fffffffUL) {
> +		if (pci_dma_supported(pci_dev, dma_mask) &&
> +		    ((rc = pci_set_dma_mask(pci_dev, dma_mask)) == 0))
> +			break;
> +		dma_mask >>= 1;
> +	}

ho hum, that kinda sucks, doesn't it.  We'll improve this one day.

> +	if (rc) {
> +		EFX_ERR(efx, "could not find a suitable DMA mask\n");
> +		goto fail2;
> +	}
> +	EFX_LOG(efx, "using DMA mask %llx\n", (unsigned long long) dma_mask);
> +	rc = pci_set_consistent_dma_mask(pci_dev, dma_mask);
> +	if (rc) {
> +		/* pci_set_consistent_dma_mask() is not *allowed* to
> +		 * fail with a mask that pci_set_dma_mask() accepted,
> +		 * but just in case...
> +		 */
> +		EFX_ERR(efx, "failed to set consistent DMA mask\n");
> +		goto fail2;
> +	}
> +
> +	efx->membase_phys = pci_resource_start(efx->pci_dev,
> +					       efx->type->mem_bar);
> +	rc = pci_request_region(pci_dev, efx->type->mem_bar, "sfc");
> +	if (rc) {
> +		EFX_ERR(efx, "request for memory BAR failed\n");
> +		rc = -EIO;
> +		goto fail3;
> +	}
> +	efx->membase = ioremap_nocache(efx->membase_phys,
> +				       efx->type->mem_map_size);
> +	if (!efx->membase) {
> +		EFX_ERR(efx, "could not map memory BAR %d at %lx+%x\n",
> +			efx->type->mem_bar, efx->membase_phys,
> +			efx->type->mem_map_size);
> +		rc = -ENOMEM;
> +		goto fail4;
> +	}
> +	EFX_LOG(efx, "memory BAR %u at %lx+%x (virtual %p)\n",
> +		efx->type->mem_bar, efx->membase_phys, efx->type->mem_map_size,
> +		efx->membase);
> +
> +	return 0;
> +
> + fail4:
> +	release_mem_region(efx->membase_phys, efx->type->mem_map_size);
> + fail3:
> +	efx->membase_phys = 0UL;

Code like this is more maintainable if you leave off the "UL".

> + fail2:
> +	pci_disable_device(efx->pci_dev);
> + fail1:
> +	return rc;
> +}
> +
> +static void efx_fini_io(struct efx_nic *efx)
> +{
> +	EFX_LOG(efx, "shutting down I/O\n");
> +
> +	if (efx->membase) {
> +		iounmap(efx->membase);
> +		efx->membase = NULL;
> +	}
> +
> +	if (efx->membase_phys) {
> +		pci_release_region(efx->pci_dev, efx->type->mem_bar);
> +		efx->membase_phys = 0UL;
> +	}
> +
> +	pci_disable_device(efx->pci_dev);
> +}
> +
> +/* Probe the number and type of interrupts we are able to obtain. */
> +static void efx_probe_interrupts(struct efx_nic *efx)
> +{
> +	int max_channel = efx->type->phys_addr_channels - 1;
> +	struct msix_entry xentries[EFX_MAX_CHANNELS];

hm, 256 bytes of stack.  Let's home nobody increases EFX_MAX_CHANNELS.

> +	int rc, i;
> +
> +	if (efx->interrupt_mode == EFX_INT_MODE_MSIX) {
> +		BUG_ON(!pci_find_capability(efx->pci_dev, PCI_CAP_ID_MSIX));

That's a bit rude.  BUG_ON is (mostly) for handling software errors.  Here
we nuke the box if the hardware is discovered to be bad.  It would be
better to blurt a message and then fail the initialisation.

> +		efx->rss_queues = rss_cpus ? rss_cpus : num_online_cpus();
> +		efx->rss_queues = min(efx->rss_queues, max_channel + 1);
> +		efx->rss_queues = min(efx->rss_queues, EFX_MAX_CHANNELS);
> +
> +		/* Request maximum number of MSI interrupts, and fill out
> +		 * the channel interrupt information the allowed allocation */
> +		for (i = 0; i < efx->rss_queues; i++)
> +			xentries[i].entry = i;
> +		rc = pci_enable_msix(efx->pci_dev, xentries, efx->rss_queues);
> +		if (rc > 0) {
> +			EFX_BUG_ON_PARANOID(rc >= efx->rss_queues);
> +			efx->rss_queues = rc;
> +			rc = pci_enable_msix(efx->pci_dev, xentries,
> +					     efx->rss_queues);
> +		}
> +
> +		if (rc == 0) {
> +			for (i = 0; i < efx->rss_queues; i++) {
> +				efx->channel[i].has_interrupt = 1;
> +				efx->channel[i].irq = xentries[i].vector;
> +			}
> +		} else {
> +			/* Fall back to single channel MSI */
> +			efx->interrupt_mode = EFX_INT_MODE_MSI;
> +			EFX_ERR(efx, "could not enable MSI-X\n");
> +		}
> +	}
> +
> +	/* Try single interrupt MSI */
> +	if (efx->interrupt_mode == EFX_INT_MODE_MSI) {
> +		efx->rss_queues = 1;
> +		rc = pci_enable_msi(efx->pci_dev);
> +		if (rc == 0) {
> +			efx->channel[0].irq = efx->pci_dev->irq;
> +			efx->channel[0].has_interrupt = 1;
> +		} else {
> +			EFX_ERR(efx, "could not enable MSI\n");
> +			efx->interrupt_mode = EFX_INT_MODE_LEGACY;
> +		}
> +	}
> +
> +	/* Assume legacy interrupts */
> +	if (efx->interrupt_mode == EFX_INT_MODE_LEGACY) {
> +		efx->rss_queues = 1;
> +		/* Every channel is interruptible */
> +		for (i = 0; i < EFX_MAX_CHANNELS; i++)
> +			efx->channel[i].has_interrupt = 1;
> +		efx->legacy_irq = efx->pci_dev->irq;
> +	}
> +}
>
> ...
>
> +static void efx_flush_all(struct efx_nic *efx)
> +{
> +	struct efx_rx_queue *rx_queue;
> +
> +	/* Make sure the hardware monitor is stopped */
> +	cancel_delayed_work_sync(&efx->monitor_work);
> +
> +	/* Ensure that all RX slow refills are complete. */
> +	efx_for_each_rx_queue(rx_queue, efx) {
> +		cancel_delayed_work_sync(&rx_queue->work);
> +	}

Normally we'd omit the braces here.  Once upon a time checkpatch.pl would
warn about this but it got broken.

Whee, checkpatch takes over half a minute to check this driver.

Oh dear, it found

#5617: FILE: drivers/net/sfc/falcon.c:1877:
+               if (*(volatile u32 *)dma_done == FALCON_STATS_DONE)

which was naughty of you.  Perhaps this was already discussed in review
with the people who actually know what they're talking about.

> +	/* Stop scheduled port reconfigurations */
> +	cancel_work_sync(&efx->reconfigure_work);
> +
> +}
> +
> +/* Quiesce hardware and software without bringing the link down.
> + * Safe to call multiple times, when the nic and interface is in any
> + * state. The caller is guaranteed to subsequently be in a position
> + * to modify any hardware and software state they see fit without
> + * taking locks. */
> +static void efx_stop_all(struct efx_nic *efx)
> +{
> +	struct efx_channel *channel;
> +
> +	EFX_ASSERT_RESET_SERIALISED(efx);
> +
> +	/* port_enabled can be read safely under the rtnl lock */
> +	if (!efx->port_enabled)
> +		return;
> +
> +	/* Disable interrupts and wait for ISR to complete */
> +	falcon_disable_interrupts(efx);
> +	if (efx->legacy_irq)
> +		synchronize_irq(efx->legacy_irq);
> +	efx_for_each_channel_with_interrupt(channel, efx)
> +		if (channel->irq)
> +			synchronize_irq(channel->irq);

Here we _would_ usually add the braces ;)

> +	/* Stop all NAPI processing and synchronous rx refills */
> +	efx_for_each_channel(channel, efx)
> +		efx_stop_channel(channel);
> +
> +	/* Stop all asynchronous port reconfigurations. Since all
> +	 * event processing has already been stopped, there is no
> +	 * window to loose phy events */
> +	efx_stop_port(efx);
> +
> +	/* Flush reconfigure_work, refill_workqueue, monitor_work */
> +	efx_flush_all(efx);
> +
> +	/* Isolate the MAC from the TX and RX engines, so that queue
> +	 * flushes will complete in a timely fashion. */
> +	falcon_deconfigure_mac_wrapper(efx);
> +	falcon_drain_tx_fifo(efx);
> +
> +	/* Stop the kernel transmit interface late, so the watchdog
> +	 * timer isn't ticking over the flush */
> +	efx_stop_queue(efx);
> +	if (NET_DEV_REGISTERED(efx)) {
> +		netif_tx_lock_bh(efx->net_dev);
> +		netif_tx_unlock_bh(efx->net_dev);
> +	}
> +}

hm, I expected NET_DEV_REGISTERED to be defined in
include/linux/netdevice.h, but it turns out to be an sfc-specific thing.

a) it's poorly named

b) please only implement in cpp that which cannot be implemented in C. 
   (aka: macros suck)

>
> ...
>
> +static void efx_monitor(struct work_struct *data)
> +{
> +	struct efx_nic *efx = container_of(data, struct efx_nic,
> +					   monitor_work.work);
> +	int rc = 0;
> +
> +	EFX_TRACE(efx, "hardware monitor executing on CPU %d\n",
> +		  raw_smp_processor_id());
> +
> +
> +	/* If the mac_lock is already held then it is likely a port
> +	 * reconfiguration is already in place, which will likely do
> +	 * most of the work of check_hw() anyway. */
> +	if (!mutex_trylock(&efx->mac_lock)) {
> +		queue_delayed_work(efx->workqueue, &efx->monitor_work,
> +				   efx_monitor_interval);
> +		return;
> +	}
> +
> +	if (efx->port_enabled)
> +		rc = falcon_check_xmac(efx);
> +	mutex_unlock(&efx->mac_lock);
> +
> +	if (rc) {
> +		if (monitor_reset) {
> +			EFX_ERR(efx, "hardware monitor detected a fault: "
> +				"triggering reset\n");
> +			efx_schedule_reset(efx, RESET_TYPE_MONITOR);
> +		} else {
> +			EFX_ERR(efx, "hardware monitor detected a fault, "
> +				"skipping reset\n");
> +		}
> +	}
> +
> +	queue_delayed_work(efx->workqueue, &efx->monitor_work,
> +			   efx_monitor_interval);
> +}

I don't see anywhere in this driver where the delayed works get flushed. 
You have a flush_workqueue() but that will only remove delayed work items
whose timer has already expired.

I might have missed it - please check for missed cancel_delayed_work()s.


> +/**************************************************************************
> + *
> + * ioctls
> + *
> + *************************************************************************/
> +
>
> ...
>
> +static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
> +{
> +	struct efx_nic *efx = net_dev->priv;
> +	struct efx_mac_stats *mac_stats = &efx->mac_stats;
> +	struct net_device_stats *stats = &net_dev->stats;
> +
> +	if (!spin_trylock(&efx->stats_lock))
> +		return stats;

I'm wondering if this is correct on uniprocessor, but to determine that I'd
need to know why it's here and I cannot determine that from just the
implementation.

IOW: needs a comment.

> +	if (efx->state == STATE_RUNNING) {
> +		falcon_update_stats_xmac(efx);
> +		falcon_update_nic_stats(efx);
> +	}
> +	spin_unlock(&efx->stats_lock);
> +
> +	stats->rx_packets = mac_stats->rx_packets;
> +	stats->tx_packets = mac_stats->tx_packets;
> +	stats->rx_bytes = mac_stats->rx_bytes;
> +	stats->tx_bytes = mac_stats->tx_bytes;
> +	stats->multicast = mac_stats->rx_multicast;
> +	stats->collisions = mac_stats->tx_collision;
> +	stats->rx_length_errors = (mac_stats->rx_gtjumbo +
> +				   mac_stats->rx_length_error);
> +	stats->rx_over_errors = efx->n_rx_nodesc_drop_cnt;
> +	stats->rx_crc_errors = mac_stats->rx_bad;
> +	stats->rx_frame_errors = mac_stats->rx_align_error;
> +	stats->rx_fifo_errors = mac_stats->rx_overflow;
> +	stats->rx_missed_errors = mac_stats->rx_missed;
> +	stats->tx_window_errors = mac_stats->tx_late_collision;
> +
> +	stats->rx_errors = (stats->rx_length_errors +
> +			    stats->rx_over_errors +
> +			    stats->rx_crc_errors +
> +			    stats->rx_frame_errors +
> +			    stats->rx_fifo_errors +
> +			    stats->rx_missed_errors +
> +			    mac_stats->rx_symbol_error);
> +	stats->tx_errors = (stats->tx_window_errors +
> +			    mac_stats->tx_bad);
> +
> +	return stats;
> +}
> +
> +/* Context: netif_tx_lock held, BHs disabled. */
> +static void efx_watchdog(struct net_device *net_dev)
> +{
> +	struct efx_nic *efx = net_dev->priv;
> +
> +	EFX_ERR(efx, "TX stuck with stop_count=%d port_enabled=%d: %s\n",
> +		atomic_read(&efx->netif_stop_count), efx->port_enabled,
> +		monitor_reset ? "resetting channels" : "skipping reset");
> +
> +	if (monitor_reset)
> +		efx_schedule_reset(efx, RESET_TYPE_MONITOR);
> +}
> +
> +
> +/* Context: process, rtnl_lock() held. */

ASSERT_RTNL() beats a comment every time ;)

> +static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
> +{
> +	struct efx_nic *efx = net_dev->priv;
> +	int rc = 0;
> +
> +	EFX_ASSERT_RESET_SERIALISED(efx);
> +
> +	if (new_mtu > EFX_MAX_MTU)
> +		return -EINVAL;
> +
> +	efx_stop_all(efx);
> +
> +	EFX_LOG(efx, "changing MTU to %d\n", new_mtu);
> +
> +	efx_fini_channels(efx);
> +	net_dev->mtu = new_mtu;
> +	rc = efx_init_channels(efx);
> +	if (rc)
> +		goto fail;
> +
> +	efx_start_all(efx);
> +	return rc;
> +
> + fail:
> +	efx_schedule_reset(efx, RESET_TYPE_DISABLE);
> +	return rc;
> +}
> +
>
> ...
>
> +static int efx_reset(struct efx_nic *efx)
> +{
> +	struct ethtool_cmd ecmd;
> +	enum reset_type method = efx->reset_pending;
> +	int rc;
> +
> +	/* Serialise with kernel interfaces */
> +	rtnl_lock();
> +
> +	/* If we're not RUNNING then don't reset. Leave the reset_pending
> +	 * flag set so that efx_pci_probe_main will be retried */
> +	if (efx->state != STATE_RUNNING) {
> +		EFX_INFO(efx, "scheduled reset quenched. NIC not RUNNING\n");
> +		goto unlock_rtnl;
> +	}
> +
> +	efx->state = STATE_RESETTING;
> +	EFX_INFO(efx, "resetting (%d)\n", method);
> +
> +	/* The net_dev->get_stats handler is quite slow, and will fail
> +	 * if a fetch is pending over reset. Serialise against it. */
> +	spin_lock(&efx->stats_lock);
> +	spin_unlock(&efx->stats_lock);

but but but...  efx_net_stats() can start to run immediately after the
spin_unlock()?

> +	efx_stop_all(efx);
> +	mutex_lock(&efx->mac_lock);
> +
> +	rc = efx_reset_down(efx, &ecmd);
> +	if (rc)
> +		goto fail1;
> +
> +	rc = falcon_reset_hw(efx, method);
> +	if (rc) {
> +		EFX_ERR(efx, "failed to reset hardware\n");
> +		goto fail2;
> +	}
> +
> +	/* Allow resets to be rescheduled. */
> +	efx->reset_pending = RESET_TYPE_NONE;
> +
> +	/* Reinitialise bus-mastering, which may have been turned off before
> +	 * the reset was scheduled. This is still appropriate, even in the
> +	 * RESET_TYPE_DISABLE since this driver generally assumes the hardware
> +	 * can respond to requests. */
> +	pci_set_master(efx->pci_dev);
> +
> +	/* Reinitialise device. This is appropriate in the RESET_TYPE_DISABLE
> +	 * case so the driver can talk to external SRAM */
> +	rc = falcon_init_nic(efx);
> +	if (rc) {
> +		EFX_ERR(efx, "failed to initialise NIC\n");
> +		goto fail3;
> +	}
> +
> +	/* Leave device stopped if necessary */
> +	if (method == RESET_TYPE_DISABLE) {
> +		/* Reinitialise the device anyway so the driver unload sequence
> +		 * can talk to the external SRAM */
> +		(void) falcon_init_nic(efx);
> +		rc = -EIO;
> +		goto fail4;
> +	}
> +
> +	rc = efx_reset_up(efx, &ecmd);
> +	if (rc)
> +		goto fail5;
> +
> +	mutex_unlock(&efx->mac_lock);
> +	EFX_LOG(efx, "reset complete\n");
> +
> +	efx->state = STATE_RUNNING;
> +	efx_start_all(efx);
> +
> + unlock_rtnl:
> +	rtnl_unlock();
> +	return 0;
> +
> + fail5:
> + fail4:
> + fail3:
> + fail2:
> + fail1:
> +	EFX_ERR(efx, "has been disabled\n");
> +	efx->state = STATE_DISABLED;
> +
> +	mutex_unlock(&efx->mac_lock);
> +	rtnl_unlock();
> +	efx_unregister_netdev(efx);
> +	efx_fini_port(efx);
> +	return rc;
> +}
> +
>
> ...
>
> +static void efx_pci_remove(struct pci_dev *pci_dev)
> +{
> +	struct efx_nic *efx;
> +
> +	efx = pci_get_drvdata(pci_dev);
> +	if (!efx)
> +		return;
> +
> +	/* Mark the NIC as fini, then stop the interface */
> +	rtnl_lock();
> +	efx->state = STATE_FINI;
> +	dev_close(efx->net_dev);
> +
> +	/* Allow any queued efx_resets() to complete */
> +	rtnl_unlock();

Is dev_close() supposed to be called under rtnl_lock()?  It _looks_ that
way, but it doesn't say so and it has no ASSERT_RTNL().

If "no" then therre might be deadlocks lurking here.

> +	if (efx->membase == NULL)
> +		goto out;
> +
> +	efx_unregister_netdev(efx);
> +
> +	/* Wait for any scheduled resets to complete. No more will be
> +	 * scheduled from this point because efx_stop_all() has been
> +	 * called, we are no longer registered with driverlink, and
> +	 * the net_device's have been removed. */
> +	flush_workqueue(efx->workqueue);
> +
> +	efx_pci_remove_main(efx);
> +
> +out:
> +	efx_fini_io(efx);
> +	EFX_LOG(efx, "shutdown successful\n");
> +
> +	pci_set_drvdata(pci_dev, NULL);
> +	efx_fini_struct(efx);
> +	free_netdev(efx->net_dev);
> +};
>
> ...
>
> +	rc = efx_probe_all(efx);
> +	if (rc)
> +		goto fail1;
> +
> +	rc = efx_init_napi(efx);
> +	if (rc)
> +		goto fail2;
> +
> +	/* Initialise the board */
> +	rc = efx->board_info.init(efx);
> +	if (rc) {
> +		EFX_ERR(efx, "failed to initialise board\n");
> +		goto fail3;
> +	}
> +
> +	rc = falcon_init_nic(efx);
> +	if (rc) {
> +		EFX_ERR(efx, "failed to initialise NIC\n");
> +		goto fail4;
> +	}
> +
> +	rc = efx_init_port(efx);
> +	if (rc) {
> +		EFX_ERR(efx, "failed to initialise port\n");
> +		goto fail5;
> +	}
> +
> +	rc = efx_init_channels(efx);
> +	if (rc)
> +		goto fail6;
> +
> +	rc = falcon_init_interrupt(efx);
> +	if (rc)
> +		goto fail7;
> +
> +	return 0;
> +
> + fail7:
> +	efx_fini_channels(efx);
> + fail6:
> +	efx_fini_port(efx);
> + fail5:
> + fail4:
> + fail3:
> +	efx_fini_napi(efx);
> + fail2:
> +	efx_remove_all(efx);
> + fail1:
> +	return rc;
> +}
> +
>
> ...
>
> --- /dev/null
> +++ b/drivers/net/sfc/ethtool.c
> @@ -0,0 +1,460 @@
> +/****************************************************************************
> + * Driver for Solarflare Solarstorm network controllers and boards
> + * Copyright 2005-2006 Fen Systems Ltd.
> + * Copyright 2006-2008 Solarflare Communications Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published
> + * by the Free Software Foundation, incorporated herein by reference.
> + */
> +
> +#include <linux/netdevice.h>
> +#include <linux/ethtool.h>
> +#include <linux/rtnetlink.h>
> +#include "net_driver.h"
> +#include "efx.h"
> +#include "ethtool.h"
> +#include "falcon.h"
> +#include "gmii.h"
> +#include "mac.h"
> +
> +static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable);

Unneeded declaration.

>
> ...
>
> +static int efx_ethtool_phys_id(struct net_device *net_dev, u32 seconds)
> +{
> +	struct efx_nic *efx = net_dev->priv;
> +
> +	efx->board_info.blink(efx, 1);
> +	schedule_timeout_interruptible(seconds * HZ);
> +	efx->board_info.blink(efx, 0);
> +	return 0;
> +}

You probably have a bug here.

If the calling process has signal_pending() then
schedule_timeout_interruptible() will return immediately.  If this function
is only ever called from a kernel thread then you'll be OK.  Otherwise,
you'll need to use _uninterruptible.

>
> ...
>
> +#if BITS_PER_LONG == 64
> +#define FALCON_DMA_MASK EFX_DMA_MASK(0x00003fffffffffffUL)
> +#else
> +#define FALCON_DMA_MASK EFX_DMA_MASK(0x00003fffffffffffULL)
> +#endif

You just reinvented DMA_47BIT_MASK.

>
> ...
>
> +void falcon_push_buffers(struct efx_tx_queue *tx_queue)
> +{
> +
> +	struct efx_tx_buffer *buffer;
> +	efx_qword_t *txd;
> +	unsigned write_ptr;
> +
> +	BUG_ON(tx_queue->write_count == tx_queue->insert_count);
> +
> +	do {
> +		write_ptr = tx_queue->write_count & FALCON_TXD_RING_MASK;
> +		buffer = &tx_queue->buffer[write_ptr];
> +		txd = falcon_tx_desc(tx_queue, write_ptr);
> +		++tx_queue->write_count;
> +
> +		/* Create TX descriptor ring entry */
> +		EFX_POPULATE_QWORD_5(*txd,
> +				     TX_KER_PORT, 0,
> +				     TX_KER_CONT, buffer->continuation,
> +				     TX_KER_BYTE_CNT, buffer->len,
> +				     TX_KER_BUF_REGION, 0,
> +				     TX_KER_BUF_ADR, buffer->dma_addr);
> +	} while (tx_queue->write_count != tx_queue->insert_count);
> +
> +	wmb(); /* Ensure descriptors are written before they are fetched */

Other places used smb_wmb() for this sort of thing (fishily).

> +	falcon_notify_tx_desc(tx_queue);
> +}
> +
>
> ...
>
> +void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue)
> +{
> +	efx_dword_t reg;
> +	unsigned write_ptr;
> +
> +	while (rx_queue->notified_count != rx_queue->added_count) {
> +		falcon_build_rx_desc(rx_queue,
> +				     rx_queue->notified_count &
> +				     FALCON_RXD_RING_MASK);
> +		++rx_queue->notified_count;
> +	}
> +
> +	wmb();

ditto

> +	write_ptr = rx_queue->added_count & FALCON_RXD_RING_MASK;
> +	EFX_POPULATE_DWORD_1(reg, RX_DESC_WPTR_DWORD, write_ptr);
> +	falcon_writel_page(rx_queue->efx, &reg,
> +			   RX_DESC_UPD_REG_KER_DWORD, rx_queue->queue);
> +}
> +
>
> ...
>
> +static inline void falcon_handle_tx_event(struct efx_channel *channel,
> +					  efx_qword_t *event)

Unneeded "inline".

`inline' is almost always either wrong or unneeded.  I'd suggest a general
inline audit.

> +	unsigned int tx_ev_desc_ptr;
> +	unsigned int tx_ev_q_label;
> +	struct efx_tx_queue *tx_queue;
> +	struct efx_nic *efx = channel->efx;
> +
> +	if (likely(EFX_QWORD_FIELD(*event, TX_EV_COMP))) {
> +		/* Transmit completion */
> +		tx_ev_desc_ptr = EFX_QWORD_FIELD(*event, TX_EV_DESC_PTR);
> +		tx_ev_q_label = EFX_QWORD_FIELD(*event, TX_EV_Q_LABEL);
> +		tx_queue = &efx->tx_queue[tx_ev_q_label];
> +		efx_xmit_done(tx_queue, tx_ev_desc_ptr);
> +	} else if (EFX_QWORD_FIELD(*event, TX_EV_WQ_FF_FULL)) {
> +		/* Rewrite the FIFO write pointer */
> +		tx_ev_q_label = EFX_QWORD_FIELD(*event, TX_EV_Q_LABEL);
> +		tx_queue = &efx->tx_queue[tx_ev_q_label];
> +
> +		if (NET_DEV_REGISTERED(efx))
> +			netif_tx_lock(efx->net_dev);
> +		falcon_notify_tx_desc(tx_queue);
> +		if (NET_DEV_REGISTERED(efx))
> +			netif_tx_unlock(efx->net_dev);
> +	} else if (EFX_QWORD_FIELD(*event, TX_EV_PKT_ERR) &&
> +		   EFX_WORKAROUND_10727(efx)) {
> +		efx_schedule_reset(efx, RESET_TYPE_TX_DESC_FETCH);
> +	} else {
> +		EFX_ERR(efx, "channel %d unexpected TX event "
> +			EFX_QWORD_FMT"\n", channel->channel,
> +			EFX_QWORD_VAL(*event));
> +	}
> +}
> +
>
> ...
>
> +int falcon_probe_nic(struct efx_nic *efx)
> +{
> +	struct falcon_nic_data *nic_data;
> +	int rc;
> +
> +	/* Initialise I2C interface state */
> +	efx->i2c.efx = efx;
> +	efx->i2c.op = &falcon_i2c_bit_operations;
> +	efx->i2c.sda = 1;
> +	efx->i2c.scl = 1;
> +
> +	/* Allocate storage for hardware specific data */
> +	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
> +	efx->nic_data = (void *) nic_data;

Maybe efx_nic.nic_data should have type `struct falcon_nic_data*'?  It
never holds anything else, does it?

> +	/* Determine number of ports etc. */
> +	rc = falcon_probe_nic_variant(efx);
> +	if (rc)
> +		goto fail1;
> +
> +	/* Probe secondary function if expected */
> +	if (FALCON_IS_DUAL_FUNC(efx)) {
> +		struct pci_dev *dev = pci_dev_get(efx->pci_dev);
> +
> +		while ((dev = pci_get_device(EFX_VENDID_SFC, FALCON_A_S_DEVID,
> +					     dev))) {
> +			if (dev->bus == efx->pci_dev->bus &&
> +			    dev->devfn == efx->pci_dev->devfn + 1) {
> +				nic_data->pci_dev2 = dev;
> +				break;
> +			}
> +		}
> +		if (!nic_data->pci_dev2) {
> +			EFX_ERR(efx, "failed to find secondary function\n");
> +			rc = -ENODEV;
> +			goto fail2;
> +		}
> +	}
> +
> +	/* Now we can reset the NIC */
> +	rc = falcon_reset_hw(efx, RESET_TYPE_ALL);
> +	if (rc) {
> +		EFX_ERR(efx, "failed to reset NIC\n");
> +		goto fail3;
> +	}
> +
> +	/* Allocate memory for INT_KER */
> +	rc = falcon_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t));
> +	if (rc)
> +		goto fail4;
> +	BUG_ON(efx->irq_status.dma_addr & 0x0f);

Are we going BUG on an error in the hardware, or on a software error?

> +	EFX_LOG(efx, "INT_KER at %llx (virt %p phys %lx)\n",
> +		(unsigned long long)efx->irq_status.dma_addr,
> +		efx->irq_status.addr, virt_to_phys(efx->irq_status.addr));
> +
> +	/* Read in the non-volatile configuration */
> +	rc = falcon_probe_nvconfig(efx);
> +	if (rc)
> +		goto fail5;
> +
> +	return 0;
> +
> + fail5:
> +	falcon_free_buffer(efx, &efx->irq_status);
> + fail4:
> +	/* fall-thru */
> + fail3:
> +	if (nic_data->pci_dev2) {
> +		pci_dev_put(nic_data->pci_dev2);
> +		nic_data->pci_dev2 = NULL;
> +	}
> + fail2:
> +	/* fall-thru */
> + fail1:
> +	kfree(efx->nic_data);
> +	return rc;
> +}
> +
> +/* This call performs hardware-specific global initialisation, such as
> + * defining the descriptor cache sizes and number of RSS channels.
> + * It does not set up any buffers, descriptor rings or event queues.
> + */
> +int falcon_init_nic(struct efx_nic *efx)
> +{
> +	struct falcon_nic_data *data;
> +	efx_oword_t temp;
> +	unsigned thresh;
> +	int rc;
> +
> +	data = (struct falcon_nic_data *)efx->nic_data;

Unneeded and undesirable cast.

> +	/* Set up the address region register. This is only needed
> +	 * for the B0 FPGA, but since we are just pushing in the
> +	 * reset defaults this may as well be unconditional. */
> +	EFX_POPULATE_OWORD_4(temp, ADR_REGION0, 0,
> +				   ADR_REGION1, (1 << 16),
> +				   ADR_REGION2, (2 << 16),
> +				   ADR_REGION3, (3 << 16));
> +	falcon_write(efx, &temp, ADR_REGION_REG_KER);
> +
> +	/* Use on-chip SRAM */
> +	falcon_read(efx, &temp, NIC_STAT_REG);
> +	EFX_SET_OWORD_FIELD(temp, ONCHIP_SRAM, 1);
> +	falcon_write(efx, &temp, NIC_STAT_REG);
> +
>
> ...
>
> +#define FALCON_REV(efx) ((efx)->pci_dev->revision)

Implement not in cpp that which .... ;)

>
> ...
>
> +struct falcon_nvconfig {
> +	efx_oword_t ee_vpd_cfg_reg;			/* 0x300 */
> +	u8 mac_address[2][8];			/* 0x310 */
> +	efx_oword_t pcie_sd_ctl0123_reg;		/* 0x320 */
> +	efx_oword_t pcie_sd_ctl45_reg;			/* 0x330 */
> +	efx_oword_t pcie_pcs_ctl_stat_reg;		/* 0x340 */
> +	efx_oword_t hw_init_reg;			/* 0x350 */
> +	efx_oword_t nic_stat_reg;			/* 0x360 */
> +	efx_oword_t glb_ctl_reg;			/* 0x370 */
> +	efx_oword_t srm_cfg_reg;			/* 0x380 */
> +	efx_oword_t spare_reg;				/* 0x390 */
> +	__le16 board_magic_num;			/* 0x3A0 */
> +	__le16 board_struct_ver;
> +	__le16 board_checksum;
> +	struct falcon_nvconfig_board_v2 board_v2;
> +} __attribute__ ((packed));

Linux has a little "__packed" helper macro.

> +#endif /* EFX_FALCON_HWDEFS_H */
> diff --git a/drivers/net/sfc/falcon_io.h b/drivers/net/sfc/falcon_io.h
> new file mode 100644
> index 0000000..ea08184
> --- /dev/null
> +++ b/drivers/net/sfc/falcon_io.h
>
> ...
>
> +
> +#define _falcon_writeq(efx, value, reg) \
> +	__raw_writeq((__force u64) (value), (efx)->membase + (reg))
> +#define _falcon_writel(efx, value, reg) \
> +	__raw_writel((__force u32) (value), (efx)->membase + (reg))
> +#define _falcon_readq(efx, reg) \
> +	((__force __le64) __raw_readq((efx)->membase + (reg)))
> +#define _falcon_readl(efx, reg) \
> +	((__force __le32) __raw_readl((efx)->membase + (reg)))

I don't think these needed to be implemented as macros.

I suspect that if they were implemented in C, those mysterious casts
wouldn't be needed?

> +/* Writes to a normal 16-byte Falcon register, locking as appropriate. */
> +static inline void falcon_write(struct efx_nic *efx, efx_oword_t *value,
> +				unsigned int reg)
> +{
> +	unsigned long flags;
> +
> +	EFX_REGDUMP(efx, "writing register %x with " EFX_OWORD_FMT "\n", reg,
> +		    EFX_OWORD_VAL(*value));
> +
> +	spin_lock_irqsave(&efx->biu_lock, flags);
> +#ifdef FALCON_USE_QWORD_IO
> +	_falcon_writeq(efx, value->u64[0], reg + 0);
> +	wmb();
> +	_falcon_writeq(efx, value->u64[1], reg + 8);
> +#else
> +	_falcon_writel(efx, value->u32[0], reg + 0);
> +	_falcon_writel(efx, value->u32[1], reg + 4);
> +	_falcon_writel(efx, value->u32[2], reg + 8);
> +	wmb();
> +	_falcon_writel(efx, value->u32[3], reg + 12);
> +#endif
> +	mmiowb();
> +	spin_unlock_irqrestore(&efx->biu_lock, flags);
> +}

hoo boy.  Did you _really_ want to inline this?  It has many many
callsites.

>
> ...
>
> --- /dev/null
> +++ b/drivers/net/sfc/i2c-direct.h

There is no linkage with the kernel's own i2c layer?  Should there be?

>
> ...
>
> +struct efx_i2c_bit_operations {
> +	void (*setsda) (struct efx_i2c_interface *i2c);
> +	void (*setscl) (struct efx_i2c_interface *i2c);
> +	int (*getsda) (struct efx_i2c_interface *i2c);
> +	int (*getscl) (struct efx_i2c_interface *i2c);
> +	unsigned int udelay;
> +	unsigned int mdelay;

whoa, namespace clash.  Some architectures like to do #define udelay(x)
zot(x).  Fortunately the preprocessor considers `foo()' to be different
from `foo'.  So I guess it'll be OK.

> +};
> +
>
> ...
>
> +static inline int mdio_clause45_phyxgxs_lane_sync(struct efx_nic *efx)
> +{
> +	int i, sync, lane_status;
> +
> +	for (i = 0; i < 2; ++i)
> +		lane_status = mdio_clause45_read(efx, efx->mii.phy_id,
> +						 MDIO_MMD_PHYXS,
> +						 MDIO_PHYXS_LANE_STATE);
> +
> +	sync = (lane_status & (1 << MDIO_PHYXS_LANE_ALIGNED_LBN)) != 0;
> +	if (!sync)
> +		EFX_INFO(efx, "XGXS lane status: %x\n", lane_status);
> +	return sync;
> +}

I think this function will expand to about a terabyte of code.

Please do revisit the inlining decisions - it will end up quite a bit
tighter and, as a result, we think, faster.

>
> ...
>
> +/**************************************************************************
> + *
> + * Build definitions
> + *
> + **************************************************************************/
> +#ifndef EFX_DRIVER_NAME
> +#define EFX_DRIVER_NAME	"sfc"
> +#endif
> +#define EFX_DRIVER_VERSION	"2.2.0136"

I would suggest that you remove this.  It's just not a useful way of
establishing what version of the driver your users are running.  We use the
kernel version information for this.

For sure when other people patch your code they will forget to update this.

> +#ifdef EFX_ENABLE_DEBUG

I can't find anywhere which defines this.

It should be a Kconfig option?

> +#define EFX_BUG_ON_PARANOID(x) BUG_ON(x)
> +#define EFX_WARN_ON_PARANOID(x) WARN_ON(x)
> +#else
> +#define EFX_BUG_ON_PARANOID(x) do {} while (0)
> +#define EFX_WARN_ON_PARANOID(x) do {} while (0)
> +#endif
> +
> +#define NET_DEV_REGISTERED(efx)					\
> +	((efx)->net_dev->reg_state == NETREG_REGISTERED)
> +
> +/* Include net device name in log messages if it has been registered.
> + * Use efx->name not efx->net_dev->name so that races with (un)registration
> + * are harmless.
> + */
> +#define NET_DEV_NAME(efx) (NET_DEV_REGISTERED(efx) ? (efx)->name : "")

could be written in C ;)

>
> ...
>
> +/* Kernel headers may redefine inline anyway */
> +#ifndef inline
> +#define inline inline __attribute__ ((always_inline))
> +#endif

whoa.  What are we doing here and why?

>
> ...
>
> +/**
> + * struct efx_rx_queue - An Efx RX queue
> + * @efx: The associated Efx NIC
> + * @queue: DMA queue number
> + * @used: Queue is used by net driver
> + * @channel: The associated channel
> + * @buffer: The software buffer ring
> + * @rxd: The hardware descriptor ring
> + * @added_count: Number of buffers added to the receive queue.
> + * @notified_count: Number of buffers given to NIC (<= @added_count).
> + * @removed_count: Number of buffers removed from the receive queue.
> + * @add_lock: Receive queue descriptor add spin lock.
> + *	This lock must be held in order to add buffers to the RX
> + *	descriptor ring (rxd and buffer) and to update added_count (but
> + *	not removed_count).
> + * @max_fill: RX descriptor maximum fill level (<= ring size)
> + * @fast_fill_trigger: RX descriptor fill level that will trigger a fast fill
> + *	(<= @max_fill)
> + * @fast_fill_limit: The level to which a fast fill will fill
> + *	(@fast_fill_trigger <= @fast_fill_limit <= @max_fill)
> + * @min_fill: RX descriptor minimum non-zero fill level.
> + *	This records the minimum fill level observed when a ring
> + *	refill was triggered.
> + * @min_overfill: RX descriptor minimum overflow fill level.
> + *	This records the minimum fill level at which RX queue
> + *	overflow was observed.  It should never be set.
> + * @alloc_page_count: RX allocation strategy counter.
> + * @alloc_skb_count: RX allocation strategy counter.
> + * @work: Descriptor push work thread
> + * @buf_page: Page for next RX buffer.
> + *	We can use a single page for multiple RX buffers. This tracks
> + *	the remaining space in the allocation.
> + * @buf_dma_addr: Page's DMA address.
> + * @buf_data: Page's host address.
> + */

nice effort, but gee I dislike this.  It's better to thumb your nose at
kerneldoc and document the fields down at their definition sites, I reckon.
People will forget to update the description otherwise.

> +struct efx_rx_queue {
> +	struct efx_nic *efx;
> +	int queue;
> +	int used;
> +	struct efx_channel *channel;
> +	struct efx_rx_buffer *buffer;
> +	struct efx_special_buffer rxd;
> +
> +	int added_count;
> +	int notified_count;
> +	int removed_count;
> +	spinlock_t add_lock;
> +	unsigned int max_fill;
> +	unsigned int fast_fill_trigger;
> +	unsigned int fast_fill_limit;
> +	unsigned int min_fill;
> +	unsigned int min_overfill;
> +	unsigned int alloc_page_count;
> +	unsigned int alloc_skb_count;
> +	struct delayed_work work;
> +	unsigned int slow_fill_count;
> +
> +	struct page *buf_page;
> +	dma_addr_t buf_dma_addr;
> +	char *buf_data;
> +};
> +
>
> ...
>
> +/*
> + * Alignment of page-allocated RX buffers
> + *
> + * Controls the number of bytes inserted at the start of an RX buffer.
> + * This is the equivalent of NET_IP_ALIGN [which controls the alignment
> + * of the skb->head for hardware DMA].
> + */
> +#if defined(__i386__) || defined(__x86_64__)
> +#define EFX_PAGE_IP_ALIGN 0
> +#else
> +#define EFX_PAGE_IP_ALIGN NET_IP_ALIGN
> +#endif

Now what's going on here?  We're taking advantage of x86's unaligned-access
capabilities, I assume.

Well...  if that is a legitimate thing to do in this driver then it is
legitimate to do in _other_ drivers.  Hence the logic should not be
open-coded in a private place such as this.

Added bonus: there might be other CPU types which are good at unaligned
access, and they will also set CONFIG_ARCH_IS_GOOD_AT_UNALIGNED_ACCESSES
and your driver will run better on those archtectures.

No?

>
> ...
>
> +/* Set bit in a little-endian bitfield */
> +static inline void set_bit_le(int nr, unsigned char *addr)
> +{
> +	addr[nr / 8] |= (1 << (nr % 8));
> +}
> +
> +/* Clear bit in a little-endian bitfield */
> +static inline void clear_bit_le(int nr, unsigned char *addr)
> +{
> +	addr[nr / 8] &= ~(1 << (nr % 8));
> +}

a) please stop implementing non-driver-specific infrastructure within a
   driver!  You've identified shortcomings in Linux - let's fix Linux.

b) this duplicates stuff from include/asm-generic/bitops/le.h

>
> ...
>
> +#define RX_DATA_OFFSET(_data)				\
> +	(((unsigned long) (_data)) & (PAGE_SIZE-1))
> +#define RX_BUF_OFFSET(_rx_buf)				\
> +	RX_DATA_OFFSET((_rx_buf)->data)
> +
> +#define RX_PAGE_SIZE(_efx)				\
> +	(PAGE_SIZE * (1u << (_efx)->rx_buffer_order))

implement not in cpp...

>
> ...
>
> +static int efx_get_frag_hdr(struct skb_frag_struct *frag, void **mac_hdr,
> +			    void **ip_hdr, void **tcpudp_hdr, u64 *hdr_flags,
> +			    void *priv)
> +{
> +	struct efx_channel *channel = (struct efx_channel *)priv;

unneeded and undesirable cast of void*

> +	struct ethhdr *eh;
> +	struct iphdr *iph;
> +
> +	/* We support EtherII and VLAN encapsulated IPv4 */
> +	eh = (struct ethhdr *)(page_address(frag->page) + frag->page_offset);

page_address() returns void*...

> +	*mac_hdr = eh;
> +
> +	if (eh->h_proto == htons(ETH_P_IP)) {
> +		iph = (struct iphdr *)(eh + 1);
> +	} else {
> +		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)eh;
> +		if (veh->h_vlan_encapsulated_proto != htons(ETH_P_IP))
> +			goto fail;
> +
> +		iph = (struct iphdr *)(veh + 1);
> +	}
> +	*ip_hdr = iph;
> +
> +	/* We can only do LRO over TCP */
> +	if (iph->protocol != IPPROTO_TCP)
> +		goto fail;
> +
> +	*hdr_flags = LRO_IPV4 | LRO_TCP;
> +	*tcpudp_hdr = (struct tcphdr *)((u8 *) iph + iph->ihl * 4);
> +
> +	channel->rx_alloc_level += RX_ALLOC_FACTOR_LRO;
> +	return 0;
> + fail:
> +	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
> +	return -1;
> +}
> +
>
> ...
>
> +static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
> +					  struct efx_rx_buffer *rx_buf)
> +{
> +	struct efx_nic *efx = rx_queue->efx;
> +	int bytes, space, offset;
> +
> +	bytes = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
> +
> +	/* If there is space left in the previously allocated page,
> +	 * then use it. Otherwise allocate a new one */
> +	rx_buf->page = rx_queue->buf_page;
> +	if (rx_buf->page == NULL) {
> +		dma_addr_t dma_addr;
> +
> +		rx_buf->page = alloc_pages(__GFP_COLD | __GFP_COMP | GFP_ATOMIC,
> +					   efx->rx_buffer_order);

I don't think we should be using the open-coded __GFP_COMP here.  That's
more an mm-internal thing.

atomic allocations of higher-order pages are unreliable.  Sometimes very
unreliable.  I guess there's not much we can do about that.

> +		if (unlikely(rx_buf->page == NULL))
> +			return -ENOMEM;
> +
> +		dma_addr = pci_map_page(efx->pci_dev, rx_buf->page,
> +					0, RX_PAGE_SIZE(efx),
> +					PCI_DMA_FROMDEVICE);
> +
> +		if (unlikely(pci_dma_mapping_error(dma_addr))) {
> +			__free_pages(rx_buf->page, efx->rx_buffer_order);
> +			rx_buf->page = NULL;
> +			return -EIO;
> +		}
> +
> +		rx_queue->buf_page = rx_buf->page;
> +		rx_queue->buf_dma_addr = dma_addr;
> +		rx_queue->buf_data = ((char *) page_address(rx_buf->page) +
> +				      EFX_PAGE_IP_ALIGN);
> +	}
> +
> +	offset = RX_DATA_OFFSET(rx_queue->buf_data);
> +	rx_buf->len = bytes;
> +	rx_buf->dma_addr = rx_queue->buf_dma_addr + offset;
> +	rx_buf->data = rx_queue->buf_data;
> +
> +	/* Try to pack multiple buffers per page */
> +	if (efx->rx_buffer_order == 0) {
> +		/* The next buffer starts on the next 512 byte boundary */
> +		rx_queue->buf_data += ((bytes + 0x1ff) & ~0x1ff);
> +		offset += ((bytes + 0x1ff) & ~0x1ff);
> +
> +		space = RX_PAGE_SIZE(efx) - offset;
> +		if (space >= bytes) {
> +			/* Refs dropped on kernel releasing each skb */
> +			get_page(rx_queue->buf_page);
> +			goto out;
> +		}
> +	}
> +
> +	/* This is the final RX buffer for this page, so mark it for
> +	 * unmapping */
> +	rx_queue->buf_page = NULL;
> +	rx_buf->unmap_addr = rx_queue->buf_dma_addr;
> +
> + out:
> +	return 0;
> +}
> +
>
> ...
>
> +static int tenxpress_phy_init(struct efx_nic *efx)
> +{
> +	struct tenxpress_phy_data *phy_data;
> +	int rc = 0;
> +
> +	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);

shouldn't we do something if this fails?

> +	efx->phy_data = phy_data;
> +
> +	tenxpress_set_state(efx, TENXPRESS_STATUS_NORMAL);
> +
> +	rc = mdio_clause45_wait_reset_mmds(efx,
> +					   TENXPRESS_REQUIRED_DEVS);
> +	if (rc < 0)
> +		goto fail;
> +
> +	rc = mdio_clause45_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
> +	if (rc < 0)
> +		goto fail;
> +
> +	rc = tenxpress_init(efx);
> +	if (rc < 0)
> +		goto fail;
> +
> +	schedule_timeout_uninterruptible(HZ / 5); /* 200ms */
> +
> +	/* Let XGXS and SerDes out of reset and resets 10XPress */
> +	falcon_reset_xaui(efx);
> +
> +	return 0;
> +
> + fail:
> +	kfree(efx->phy_data);
> +	efx->phy_data = NULL;
> +	return rc;
> +}
> +
>
> ...
>


Well, it's a nice-looking driver, albeit somewhat on the small side.

Apart from drivers/net/sfc/bitfield.h and other such shouldnt-be-private
things, which are little tragedies.

