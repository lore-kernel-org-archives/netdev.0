From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH 6/6] tilegx network driver: initial support
Date: Mon, 9 Apr 2012 17:30:56 -0400
Message-ID: <4F835510.4060100@tilera.com>
References: <201204062059.q36KxjEO011317@farm-0027.internal.tilera.com> <201204062101.q36L1uCi011406@farm-0027.internal.tilera.com> <201204091349.54484.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([206.83.70.75]:25614 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551Ab2DIVbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 17:31:00 -0400
In-Reply-To: <201204091349.54484.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/9/2012 9:49 AM, Arnd Bergmann wrote:
> On Friday 06 April 2012, Chris Metcalf wrote:
>> This change adds support for the tilegx network driver based on the
>> GXIO IORPC support in the tilegx software stack, using the on-chip
>> mPIPE packet processing engine.
>>
>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
>> ---
>>  drivers/net/ethernet/tile/Kconfig  |    1 +
>>  drivers/net/ethernet/tile/Makefile |    4 +-
>>  drivers/net/ethernet/tile/tilegx.c | 2045 ++++++++++++++++++++++++++++++++++++
>>  3 files changed, 2048 insertions(+), 2 deletions(-)
>>  create mode 100644 drivers/net/ethernet/tile/tilegx.c
> I think the directory name should be the company, not the architecture here, so make
> it drivers/net/ethernet/tilera/tilegx.c instead.

This path was picked back when Jeff Kirsher did the initial move into
drivers/net/ethernet/ for the tilepro driver.  I don't have too strong an
opinion on this; at this point I'm mostly just concerned that it seems like
potentially not worth the churn to move the files for 3.2, then again for
3.5.  But if folks agree we should do it, it's fine with me.

We can put that in a separate change so it sweeps up the tilepro ethernet
support as well, which is otherwise not involved in this change series.

>> +MODULE_AUTHOR("Tilera");
>> +MODULE_LICENSE("GPL");
>> +
> MODULE_AUTHOR is normally a real person with an email address.

The actual author would rather not publish his name (I just double-checked
with him).  I didn't write this module, so it doesn't seem right to use my
name.  I did change it to "Tilera Corporation" just because that seems a
bit better.  I did a sweep and turned up a fair number of other similar
uses in our internal code and for now made them all "Tilera Corporation",
but I've encouraged our OS developers to consider using their names on
driver code they are writing, so some drivers coming from Tilera may carry
full names in the future.

>> +/* Statistics counters for a specific cpu and device. */
>> +struct tile_net_stats_t {
>> +	u32 rx_packets;
>> +	u32 rx_bytes;
>> +	u32 tx_packets;
>> +	u32 tx_bytes;
>> +};
> I think you need to drop the _t postfix here, which presumably comes
> from converting it from a typedef.

Fixed.

>> +/* The actual devices. */
>> +static struct net_device *tile_net_devs[TILE_NET_DEVS];
>> +
>> +/* The device for a given channel.  HACK: We use "32", not
>> + * TILE_NET_CHANNELS, because it is fairly subtle that the 5 bit
>> + * "idesc.channel" field never exceeds TILE_NET_CHANNELS.
>> + */
>> +static struct net_device *tile_net_devs_for_channel[32];
> When you need to keep a list or array of device structures in a driver, you're
> usually doing something very wrong. The convention is to just pass the pointer
> around to where you need it.

We need "tile_net_devs_for_channel" because we share a single hardware
queue for all devices, and each packet's metadata contains a "channel"
value which indicates the device.

>> +
>> +/* Convert a "buffer ptr" into a "buffer cpa". */
>> +static inline void *buf_to_cpa(void *buf)
>> +{
>> +	return (void *)__pa(buf);
>> +}
>> +
>> +
>> +/* Convert a "buffer cpa" into a "buffer ptr". */
>> +static inline void *cpa_to_buf(void *cpa)
>> +{
>> +	return (void *)__va(cpa);
>> +}
> This is almost certainly wrong: The type returned by __pa is a phys_addr_t,
> which cannot be dereferenced like a pointer. On normal drivers, you would
> use dma_map_single()/dma_unmap_single() to get a token that can get
> passed into a dma engine. From what I can tell, this device is directly mapped,
> while your PCI uses an IOMMU, so that would require two different
> implementations of dma mapping operations.

Well, it's right, but ridiculously confusing.  What I've done today is
eliminate these two functions, and add the following code in <asm/io.h>:

/*
 * The on-chip I/O hardware on tilegx is configured with VA=PA for the
 * kernel's PA range.  The low-level APIs and field names use "va" and
 * "void *" nomenclature, to be consistent with the general notion
 * that the addresses in question are virtualizable, but in the kernel
 * context we are actually manipulating PA values.  To allow readers
 * of the code to understand what's happening, we direct their
 * attention to this comment by using the following two no-op functions.
 */
static inline unsigned long pa_to_tile_io_addr(phys_addr_t pa)
{
        BUILD_BUG_ON(sizeof(phys_addr_t) != sizeof(unsigned long));
        return pa;
}
static inline phys_addr_t tile_io_addr_to_pa(unsigned long tile_io_addr)
{
        return tile_io_addr;
}

Then the individual uses in the network driver are just things like
"edesc_head.va = pa_to_tile_io_addr(__pa(va))" or "va =
__va(tile_io_addr_to_pa((unsigned long)gxio_mpipe_idesc_get_va(idesc)))"
which I think is a little clearer.

>> +/* Allocate and push a buffer. */
>> +static bool tile_net_provide_buffer(bool small)
>> +{
>> [...]
>> +
>> +	/* Save a back-pointer to 'skb'. */
>> +	*(struct sk_buff **)(skb->data - sizeof(struct sk_buff **)) = skb;
> This looks very wrong: why would you put the pointer to the skb into the
> skb itself?

Because we create skbuffs, and then feed the raw underlying buffer storage
to our hardware, and later, we get back this raw pointer from hardware,
from which we need to be able to extract the actual skbuff.

>> +	/* Make sure "skb" and the back-pointer have been flushed. */
>> +	__insn_mf();
> Try to use archicture independent names for flush operations like this
> to make it more readable. I assume this should be smp_wmb()?

Done, though it's just wmb() here, since we're fencing against the I/O
hardware, not against other cores.

>> +
>> +		/* Compute the "ip checksum". */
>> +		jsum = isum_hack + htons(s_len - eh_len) + htons(id);
>> +		jsum = __insn_v2sadu(jsum, 0);
>> +		jsum = __insn_v2sadu(jsum, 0);
>> +		jsum = (0xFFFF ^ jsum);
>> +		jh->check = jsum;
>> +
>> +		/* Update the tcp "seq". */
>> +		uh->seq = htonl(seq);
>> +
>> +		/* Update some flags. */
>> +		if (!final)
>> +			uh->fin = uh->psh = 0;
>> +
>> +		/* Compute the tcp pseudo-header checksum. */
>> +		usum = tsum_hack + htons(s_len);
>> +		usum = __insn_v2sadu(usum, 0);
>> +		usum = __insn_v2sadu(usum, 0);
>> +		uh->check = usum;
> Why to you open-code the ip checksum functions here? Normally the stack takes
> care of this by calling the functions you already provide in
> arch/tile/lib/checksum.c

If there is a way to do TSO without this, we'd be happy to hear it, but
it's not clear how it would be possible.  We are only computing a PARTIAL
checksum here, and letting the hardware compute the "full" checksum.

Thanks!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
