From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH 6/6] tilegx network driver: initial support
Date: Thu, 12 Apr 2012 19:23:13 -0400
Message-ID: <4F8763E1.1020605@tilera.com>
References: <201204062059.q36KxjEO011317@farm-0027.internal.tilera.com> <201204091349.54484.arnd@arndb.de> <4F835510.4060100@tilera.com> <201204101042.39877.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204101042.39877.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/10/2012 6:42 AM, Arnd Bergmann wrote:
> On Monday 09 April 2012, Chris Metcalf wrote:
>> On 4/9/2012 9:49 AM, Arnd Bergmann wrote:
>>> On Friday 06 April 2012, Chris Metcalf wrote:
>>>> This change adds support for the tilegx network driver based on the
>>>> GXIO IORPC support in the tilegx software stack, using the on-chip
>>>> mPIPE packet processing engine.
>>>>
>>>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
>>>> ---
>>>>  drivers/net/ethernet/tile/Kconfig  |    1 +
>>>>  drivers/net/ethernet/tile/Makefile |    4 +-
>>>>  drivers/net/ethernet/tile/tilegx.c | 2045 ++++++++++++++++++++++++++++++++++++
>>>>  3 files changed, 2048 insertions(+), 2 deletions(-)
>>>>  create mode 100644 drivers/net/ethernet/tile/tilegx.c
>>>
>> The actual author would rather not publish his name (I just double-checked
>> with him). 
> Hmm, it doesn't look all that bad actually, the comments I had are just for
> small details.

FWIW, the author's preference doesn't have to do with the code quality, but
for his own reasons.

>>>> +/* The actual devices. */
>>>> +static struct net_device *tile_net_devs[TILE_NET_DEVS];
>>>> +
>>>> +/* The device for a given channel.  HACK: We use "32", not
>>>> + * TILE_NET_CHANNELS, because it is fairly subtle that the 5 bit
>>>> + * "idesc.channel" field never exceeds TILE_NET_CHANNELS.
>>>> + */
>>>> +static struct net_device *tile_net_devs_for_channel[32];
>>> When you need to keep a list or array of device structures in a driver, you're
>>> usually doing something very wrong. The convention is to just pass the pointer
>>> around to where you need it.
>> We need "tile_net_devs_for_channel" because we share a single hardware
>> queue for all devices, and each packet's metadata contains a "channel"
>> value which indicates the device.
>  
> Ok, but please remove tile_net_devs then.
> I think a better abstraction for tile_net_devs_for_channel would be
> some interface that lets you add private data to a channel so when
> you get data from a channel, you can extract that pointer from the driver
> using the channel.


I think what would be clearer is to document how and why we are using this
additional data structure.  We do access via both arrays where it is
efficient to do so, so getting rid of either of them doesn't seem right. 
Let's keep the "normal" tile_net_devs[] as is, indexed by devno, and make
the tile_net_devs_for_channel[] more abstracted by using the following code:

/*
 * Provide support for efficiently mapping a channel to the device
 * that is using that channel, or NULL if none.  The pointers in this
 * array are only non-NULL when pointing to active tilegx net_device
 * structures, and they are cleared before the struture itself is
 * released.
 *
 * HACK: We use "32", not TILE_NET_CHANNELS, because it is fairly
 * subtle that the 5 bit "idesc.channel" field never exceeds
 * TILE_NET_CHANNELS.
 */
static struct net_device *channel_to_dev[32];

static void bychannel_add(struct net_device *dev)
{
	struct tile_net_priv *priv = netdev_priv(dev);
	BUG_ON(channel_to_dev[priv->channel] != NULL);
	channel_to_dev[priv->channel] = dev;
}

static void bychannel_delete(struct net_device *dev)
{
	struct tile_net_priv *priv = netdev_priv(dev);
	channel_to_dev[priv->channel] = NULL;
}

static inline struct net_device *bychannel_lookup(int channel)
{
	return channel_to_dev[channel];
}


We then call bychannel_add() in the open method, and bychannel_delete() in
the close method, so it's clear that the pointers have appropriate lifetimes.

> Don't you already have a per-channel data structure?

Nope.

>> /*
>>  * The on-chip I/O hardware on tilegx is configured with VA=PA for the
>>  * kernel's PA range.  The low-level APIs and field names use "va" and
>>  * "void *" nomenclature, to be consistent with the general notion
>>  * that the addresses in question are virtualizable, but in the kernel
>>  * context we are actually manipulating PA values.  To allow readers
>>  * of the code to understand what's happening, we direct their
>>  * attention to this comment by using the following two no-op functions.
>>  */
>> static inline unsigned long pa_to_tile_io_addr(phys_addr_t pa)
>> {
>>         BUILD_BUG_ON(sizeof(phys_addr_t) != sizeof(unsigned long));
>>         return pa;
>> }
>> static inline phys_addr_t tile_io_addr_to_pa(unsigned long tile_io_addr)
>> {
>>         return tile_io_addr;
>> }
>>
>> Then the individual uses in the network driver are just things like
>> "edesc_head.va = pa_to_tile_io_addr(__pa(va))" or "va =
>> __va(tile_io_addr_to_pa((unsigned long)gxio_mpipe_idesc_get_va(idesc)))"
>> which I think is a little clearer.
> Yes, although I would probably add a typedef for tile_io_addr and pass
> the virtual address in and out these helper functions.

Good ideas, done.

> For added clarity, you could make the interface look like dma_map_single(),
> which requires adding an empty unmap() function as well -- that would
> make it obvious where that data is actually used. Why do you require
> the reverse map anyway? Normally you only need to pass a bus address to
> the device but don't need to translate that back into a virtual address
> because you already had that in the beginning.

We need the reverse map since the hardware hands us an "idesc" which has
just the tile_io_addr value in it, so we need to map it back to a va to
deal with it.

I don't think the map/unmap abstraction is too helpful here, since we're
assuming that memory is all fully-mapped, as it always is on GX.

>>>> +		/* Compute the "ip checksum". */
>>>> +		jsum = isum_hack + htons(s_len - eh_len) + htons(id);
>>>> +		jsum = __insn_v2sadu(jsum, 0);
>>>> +		jsum = __insn_v2sadu(jsum, 0);
>>>> +		jsum = (0xFFFF ^ jsum);
>>>> +		jh->check = jsum;
>>>> +
>>>> +		/* Update the tcp "seq". */
>>>> +		uh->seq = htonl(seq);
>>>> +
>>>> +		/* Update some flags. */
>>>> +		if (!final)
>>>> +			uh->fin = uh->psh = 0;
>>>> +
>>>> +		/* Compute the tcp pseudo-header checksum. */
>>>> +		usum = tsum_hack + htons(s_len);
>>>> +		usum = __insn_v2sadu(usum, 0);
>>>> +		usum = __insn_v2sadu(usum, 0);
>>>> +		uh->check = usum;
>>> Why to you open-code the ip checksum functions here? Normally the stack takes
>>> care of this by calling the functions you already provide in
>>> arch/tile/lib/checksum.c
>> If there is a way to do TSO without this, we'd be happy to hear it, but
>> it's not clear how it would be possible.  We are only computing a PARTIAL
>> checksum here, and letting the hardware compute the "full" checksum.
> Sounds like you're looking for csum_partial() ;-)

Well, that's a pretty heavy-weight operation on memory.  Here we're just
updating from a few values held in registers, more or less.  csum_partial()
didn't seem like a good fit.  What I've done is move the longto16() routine
from checksum.c to <asm/checksum.h> and rename it csum_long(), then use it
like this, e.g. for the "usum" block above:

		/* Compute the tcp pseudo-header checksum. */
		uh->check = csum_long(tsum_hack + htons(s_len));


-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
