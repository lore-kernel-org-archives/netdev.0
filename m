From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Fri, 2 May 2008 17:05:35 +0100
Message-ID: <20080502160530.GN14219@solarflare.com>
References: <200804301925.m3UJPc72001651@hera.kernel.org> <20080501120858.207b6dd6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:43091 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757724AbYEBQFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 12:05:52 -0400
Content-Disposition: inline
In-Reply-To: <20080501120858.207b6dd6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Wed, 30 Apr 2008 19:25:38 GMT
> Linux Kernel Mailing List <linux-kernel@vger.kernel.org> wrote:
<snip>
> > --- /dev/null
> > +++ b/drivers/net/sfc/bitfield.h
> >
> 
> weep.
> 
> This entire (large, complex, undocumeted) header file contains quite
> generally applicable code which could be used from many many other parts of
> the kernel.  Yet here it all is, stuffed way down in drivers/net/sfc/.
>
> What happens if all drivers do this?  Well, they do.  We get a mess.

You're right, this does get reinvented quite a bit.  Please don't wait
for driver writers to implement common code.  We're generally less
experienced in kernel development, and are disinclined to make driver
changes become dependent on changes to common code that are more likely
to provoke objections.
 
> btw, the implementation is riotously buggy if anyone passes any of these
> macros an expression which has side-effects.
 
This is sadly true.

<snip>
> > +static void blink_led_timer(unsigned long context)
> > +{
> > +	struct efx_nic *efx = (struct efx_nic *)context;
> > +	struct efx_blinker *bl = &efx->board_info.blinker;
> > +	efx->board_info.set_fault_led(efx, bl->state);
> > +	bl->state = !bl->state;
> > +	if (bl->resubmit) {
> > +		bl->timer.expires = jiffies + BLINK_INTERVAL;
> > +		add_timer(&bl->timer);
> 
> mod_timer()
 
I'll have a look at that.

<snip>
> > +static inline int efx_process_channel(struct efx_channel *channel, int rx_quota)
<snip>
> This has two callsites and is far far too large to be inlined.

Right.  We'll do an internal review of all the inlines.

> > +/* Mark channel as finished processing
> > + *
> > + * Note that since we will not receive further interrupts for this
> > + * channel before we finish processing and call the eventq_read_ack()
> > + * method, there is no need to use the interrupt hold-off timers.
> > + */
> > +static inline void efx_channel_processed(struct efx_channel *channel)
> > +{
> > +	/* Write to EVQ_RPTR_REG.  If a new event arrived in a race
> > +	 * with finishing processing, a new interrupt will be raised.
> > +	 */
> > +	channel->work_pending = 0;
> > +	smp_wmb(); /* Ensure channel updated before any new interrupt. */
> 
> Is smp_wmb() the right thing here?  I think you're trying to ensure that
> the CPU has issued the store before we write the interrupt ack to the
> hardware, yes?
 
The comment about EVQ_RPTR_REG is really in the wrong place.  That's done
by falcon_eventq_read_ack(), not by the assignment in this function.
The memory barrier is there to synchronise with the interrupt handler,
not the hardware, so we believe it is correct.

<snip>
> > +	/* Calculate page-order */
> > +	for (order = 0; ((1u << order) * PAGE_SIZE) < len; ++order)
> > +		;
> 
> get_order()

Wonderful!

> > +	channel->work_pending = 0;
> > +	channel->enabled = 1;
> > +	smp_wmb(); /* ensure channel updated before first interrupt */
> 
> etc.
 
Again, this is synchronising with the interrupt handler not the hardware.
All hardware access is (or should be) in the falcon* source files.

<snip>
> > +	/* Ensure that any worker threads have exited or will be no-ops */
> > +	efx_for_each_channel_rx_queue(rx_queue, channel) {
> > +		spin_lock_bh(&rx_queue->add_lock);
> > +		spin_unlock_bh(&rx_queue->add_lock);
> 
> whee.  Does this work correctly on CONFIG_SMP=n builds?
 
This is supposed to synchronise with __efx_fast_push_rx_descriptors()
which will never be called after channel->enabled is false.  It might
not be correct in a non-SMP build with preemption enabled.  I must
admit we rarely test non-SMP builds as it's extremely unlikely that
anyone would use a 10G NIC in a single-processor system.

> > +	mutex_lock(&efx->mac_lock);
> > +	efx->port_enabled = 0;
> > +	mutex_unlock(&efx->mac_lock);
> 
> A lock-around-a-single-atomic-write always get me going.  It's _sometimes_
> legitimate: if the other code paths which access the storage are reading it
> multiple times within the same locked region, and expect all acesses to
> return the same vaule.

Actually a compiler may generate repeated loads even if there's only one
read in the code.  I don't know whether gcc ever does this.

> But often that isn't the case, and there's a buglet, or unneeded locking.
 
The intent is that no MAC operations will occur after this.  Obviously
just changing the enabled flag doesn't achieve that; the locking is
necessary to synchronise with MAC operations that are already running.

<snip>
> > +	int rc, i;
> > +
> > +	if (efx->interrupt_mode == EFX_INT_MODE_MSIX) {
> > +		BUG_ON(!pci_find_capability(efx->pci_dev, PCI_CAP_ID_MSIX));
> 
> That's a bit rude.  BUG_ON is (mostly) for handling software errors.  Here
> we nuke the box if the hardware is discovered to be bad.  It would be
> better to blurt a message and then fail the initialisation.
 
This is meant to check that the initialisation of efx->interrupt_mode
was sane, not that the hardware is OK.

<snip>
> > +	/* Ensure that all RX slow refills are complete. */
> > +	efx_for_each_rx_queue(rx_queue, efx) {
> > +		cancel_delayed_work_sync(&rx_queue->work);
> > +	}
> 
> Normally we'd omit the braces here.  Once upon a time checkpatch.pl would
> warn about this but it got broken.

Sorry, we're taking a while to adjust to strict kernel style.

> Whee, checkpatch takes over half a minute to check this driver.
> 
> Oh dear, it found
> 
> #5617: FILE: drivers/net/sfc/falcon.c:1877:
> +               if (*(volatile u32 *)dma_done == FALCON_STATS_DONE)
> 
> which was naughty of you.  Perhaps this was already discussed in review
> with the people who actually know what they're talking about.

There wasn't any specific discussion of this.  Is it wrong?  We want to
prevent the compiler from caching *dma_done, which is itself written by DMA.

<snip>
> I don't see anywhere in this driver where the delayed works get flushed. 
> You have a flush_workqueue() but that will only remove delayed work items
> whose timer has already expired.
> 
> I might have missed it - please check for missed cancel_delayed_work()s.
 
We use cancel_delayed_work_sync() in efx_flush_all().

<snip>
> > +static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
> > +{
> > +	struct efx_nic *efx = net_dev->priv;
> > +	struct efx_mac_stats *mac_stats = &efx->mac_stats;
> > +	struct net_device_stats *stats = &net_dev->stats;
> > +
> > +	if (!spin_trylock(&efx->stats_lock))
> > +		return stats;
> 
> I'm wondering if this is correct on uniprocessor, but to determine that I'd
> need to know why it's here and I cannot determine that from just the
> implementation.
>
> IOW: needs a comment.

The function comment is not quite correct - this may be called under either
dev_base_lock (if called via /proc/net/dev) or RTNL (if called via ethtool), so
we need our own lock to serialise stats requests.  At the same time, we don't
actually want to spin waiting for new stats if an update is already in progress
- stale stats are generally acceptable as long as they will get updated soon.
I'm not sure whether this is correct on uniprocessor, so we'll review this
internally.
 
<snip>
> > +	/* The net_dev->get_stats handler is quite slow, and will fail
> > +	 * if a fetch is pending over reset. Serialise against it. */
> > +	spin_lock(&efx->stats_lock);
> > +	spin_unlock(&efx->stats_lock);
> 
> but but but...  efx_net_stats() can start to run immediately after the
> spin_unlock()?

But it will then find efx->state == STATE_RESETTING, and will return the old
stats rather than trying to update them.

> > +static void efx_pci_remove(struct pci_dev *pci_dev)
> > +{
> > +	struct efx_nic *efx;
> > +
> > +	efx = pci_get_drvdata(pci_dev);
> > +	if (!efx)
> > +		return;
> > +
> > +	/* Mark the NIC as fini, then stop the interface */
> > +	rtnl_lock();
> > +	efx->state = STATE_FINI;
> > +	dev_close(efx->net_dev);
> > +
> > +	/* Allow any queued efx_resets() to complete */
> > +	rtnl_unlock();
> 
> Is dev_close() supposed to be called under rtnl_lock()?  It _looks_ that
> way, but it doesn't say so and it has no ASSERT_RTNL().
 
Yes, see dev_change_flags().

<snip>
> > +static int efx_ethtool_phys_id(struct net_device *net_dev, u32 seconds)
> > +{
> > +	struct efx_nic *efx = net_dev->priv;
> > +
> > +	efx->board_info.blink(efx, 1);
> > +	schedule_timeout_interruptible(seconds * HZ);
> > +	efx->board_info.blink(efx, 0);
> > +	return 0;
> > +}
> 
> You probably have a bug here.
> 
> If the calling process has signal_pending() then
> schedule_timeout_interruptible() will return immediately.  If this function
> is only ever called from a kernel thread then you'll be OK.  Otherwise,
> you'll need to use _uninterruptible.

This is intentional.  The user runs ethtool -p <device> to find the port
that <device> corresponds to, then can hit control-C when they've spotted
it.

> > ...
> >
> > +#if BITS_PER_LONG == 64
> > +#define FALCON_DMA_MASK EFX_DMA_MASK(0x00003fffffffffffUL)
> > +#else
> > +#define FALCON_DMA_MASK EFX_DMA_MASK(0x00003fffffffffffULL)
> > +#endif
> 
> You just reinvented DMA_47BIT_MASK.
 
Or even 46?  I think this predates that; obviously it should be changed.

<snip>
> > +	/* Allocate storage for hardware specific data */
> > +	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
> > +	efx->nic_data = (void *) nic_data;
> 
> Maybe efx_nic.nic_data should have type `struct falcon_nic_data*'?  It
> never holds anything else, does it?

Not at present.

<snip>
> > +	/* Allocate memory for INT_KER */
> > +	rc = falcon_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t));
> > +	if (rc)
> > +		goto fail4;
> > +	BUG_ON(efx->irq_status.dma_addr & 0x0f);
> 
> Are we going BUG on an error in the hardware, or on a software error?
 
Software error.

<snip>
> > +#define _falcon_writeq(efx, value, reg) \
> > +	__raw_writeq((__force u64) (value), (efx)->membase + (reg))
> > +#define _falcon_writel(efx, value, reg) \
> > +	__raw_writel((__force u32) (value), (efx)->membase + (reg))
> > +#define _falcon_readq(efx, reg) \
> > +	((__force __le64) __raw_readq((efx)->membase + (reg)))
> > +#define _falcon_readl(efx, reg) \
> > +	((__force __le32) __raw_readl((efx)->membase + (reg)))
> 
> I don't think these needed to be implemented as macros.
> 
> I suspect that if they were implemented in C, those mysterious casts
> wouldn't be needed?

The casts are there to keep sparse happy - we're writing/reading little-
endian values, but the raw MMIO functions don't specify endian-ness.

> > +/* Writes to a normal 16-byte Falcon register, locking as appropriate. */
> > +static inline void falcon_write(struct efx_nic *efx, efx_oword_t *value,
> > +				unsigned int reg)
> > +{
> > +	unsigned long flags;
> > +
> > +	EFX_REGDUMP(efx, "writing register %x with " EFX_OWORD_FMT "\n", reg,
> > +		    EFX_OWORD_VAL(*value));
> > +
> > +	spin_lock_irqsave(&efx->biu_lock, flags);
> > +#ifdef FALCON_USE_QWORD_IO
> > +	_falcon_writeq(efx, value->u64[0], reg + 0);
> > +	wmb();
> > +	_falcon_writeq(efx, value->u64[1], reg + 8);
> > +#else
> > +	_falcon_writel(efx, value->u32[0], reg + 0);
> > +	_falcon_writel(efx, value->u32[1], reg + 4);
> > +	_falcon_writel(efx, value->u32[2], reg + 8);
> > +	wmb();
> > +	_falcon_writel(efx, value->u32[3], reg + 12);
> > +#endif
> > +	mmiowb();
> > +	spin_unlock_irqrestore(&efx->biu_lock, flags);
> > +}
> 
> hoo boy.  Did you _really_ want to inline this?  It has many many
> callsites.
 
Maybe not, as I don't think this is speed-critical (some registers are
special-cased as allowing 32-bit writes).  We'll check the impact on code
size and speed.

> >
> > ...
> >
> > --- /dev/null
> > +++ b/drivers/net/sfc/i2c-direct.h
> 
> There is no linkage with the kernel's own i2c layer?  Should there be?

I started trying to do that, but it looked like it would result in a net
addition of code.

<snip>
> > +#define EFX_DRIVER_VERSION	"2.2.0136"
> 
> I would suggest that you remove this.  It's just not a useful way of
> establishing what version of the driver your users are running.  We use the
> kernel version information for this.
 
This is common practice for net drivers.  Maybe we are in our own little
world on netdev?

> For sure when other people patch your code they will forget to update this.
> 
> > +#ifdef EFX_ENABLE_DEBUG
> 
> I can't find anywhere which defines this.
> 
> It should be a Kconfig option?
 
Maybe we should just remove the code that's conditional on this.

> >
> > ...
> >
> > +/* Kernel headers may redefine inline anyway */
> > +#ifndef inline
> > +#define inline inline __attribute__ ((always_inline))
> > +#endif
> 
> whoa.  What are we doing here and why?
 
I think this is a remnant of kernel backward-compatibility code, which we
have generally excluded from our submission using unifdef.

<snip>
> > +/*
> > + * Alignment of page-allocated RX buffers
> > + *
> > + * Controls the number of bytes inserted at the start of an RX buffer.
> > + * This is the equivalent of NET_IP_ALIGN [which controls the alignment
> > + * of the skb->head for hardware DMA].
> > + */
> > +#if defined(__i386__) || defined(__x86_64__)
> > +#define EFX_PAGE_IP_ALIGN 0
> > +#else
> > +#define EFX_PAGE_IP_ALIGN NET_IP_ALIGN
> > +#endif
> 
> Now what's going on here?  We're taking advantage of x86's unaligned-access
> capabilities, I assume.
 
Correct.

> Well...  if that is a legitimate thing to do in this driver then it is
> legitimate to do in _other_ drivers.  Hence the logic should not be
> open-coded in a private place such as this.
> 
> Added bonus: there might be other CPU types which are good at unaligned
> access, and they will also set CONFIG_ARCH_IS_GOOD_AT_UNALIGNED_ACCESSES
> and your driver will run better on those archtectures.
>
> No?

I seem to remember a proposal for such a config macro.  We'll be happy to
use that once it's there.
 
> >
> > ...
> >
> > +/* Set bit in a little-endian bitfield */
> > +static inline void set_bit_le(int nr, unsigned char *addr)
> > +{
> > +	addr[nr / 8] |= (1 << (nr % 8));
> > +}
> > +
> > +/* Clear bit in a little-endian bitfield */
> > +static inline void clear_bit_le(int nr, unsigned char *addr)
> > +{
> > +	addr[nr / 8] &= ~(1 << (nr % 8));
> > +}
> 
> a) please stop implementing non-driver-specific infrastructure within a
>    driver!  You've identified shortcomings in Linux - let's fix Linux.
> 
> b) this duplicates stuff from include/asm-generic/bitops/le.h
 
I'm not clear whether you think <asm-generic/bitops/le.h> is sufficient.
It looks like it is.

<snip>
> > +	struct ethhdr *eh;
> > +	struct iphdr *iph;
> > +
> > +	/* We support EtherII and VLAN encapsulated IPv4 */
> > +	eh = (struct ethhdr *)(page_address(frag->page) + frag->page_offset);
> 
> page_address() returns void*...

Yes, and arithmetic on void * is commonly used in the kernel.  Just for fun,
try make KCFLAGS=-Wpointer-arith.

> > +static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
> > +					  struct efx_rx_buffer *rx_buf)
> > +{
> > +	struct efx_nic *efx = rx_queue->efx;
> > +	int bytes, space, offset;
> > +
> > +	bytes = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
> > +
> > +	/* If there is space left in the previously allocated page,
> > +	 * then use it. Otherwise allocate a new one */
> > +	rx_buf->page = rx_queue->buf_page;
> > +	if (rx_buf->page == NULL) {
> > +		dma_addr_t dma_addr;
> > +
> > +		rx_buf->page = alloc_pages(__GFP_COLD | __GFP_COMP | GFP_ATOMIC,
> > +					   efx->rx_buffer_order);
> 
> I don't think we should be using the open-coded __GFP_COMP here.  That's
> more an mm-internal thing.

What's the alternative?

> atomic allocations of higher-order pages are unreliable.  Sometimes very
> unreliable.  I guess there's not much we can do about that.
 
I know.  We will switch to allocating single pages some time soon for
Falcon rev B0 and later NICs.  Unfortunately Falcon rev A1 didn't include
scattering for physically-addressed buffers, so we would still need to
allocate compound pages for it when using jumbo frames.

<snip>
> Well, it's a nice-looking driver, albeit somewhat on the small side.
 
:-)

> Apart from drivers/net/sfc/bitfield.h and other such shouldnt-be-private
> things, which are little tragedies.

Thanks for taking the time to review this code.  We'll get to work on
clearing up the issues you've raised.  Also, I acknowledge the several
points I didn't respond to individually.
 
Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
