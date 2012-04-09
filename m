From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/6] tilegx network driver: initial support
Date: Mon, 9 Apr 2012 13:49:54 +0000
Message-ID: <201204091349.54484.arnd@arndb.de>
References: <201204062059.q36KxjEO011317@farm-0027.internal.tilera.com> <201204062101.q36L1uCi011406@farm-0027.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204062101.q36L1uCi011406@farm-0027.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 06 April 2012, Chris Metcalf wrote:
> This change adds support for the tilegx network driver based on the
> GXIO IORPC support in the tilegx software stack, using the on-chip
> mPIPE packet processing engine.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
>  drivers/net/ethernet/tile/Kconfig  |    1 +
>  drivers/net/ethernet/tile/Makefile |    4 +-
>  drivers/net/ethernet/tile/tilegx.c | 2045 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 2048 insertions(+), 2 deletions(-)
>  create mode 100644 drivers/net/ethernet/tile/tilegx.c

I think the directory name should be the company, not the architecture here, so make
it drivers/net/ethernet/tilera/tilegx.c instead.

> +
> +MODULE_AUTHOR("Tilera");
> +MODULE_LICENSE("GPL");
> +

MODULE_AUTHOR is normally a real person with an email address.

> +/* Statistics counters for a specific cpu and device. */
> +struct tile_net_stats_t {
> +	u32 rx_packets;
> +	u32 rx_bytes;
> +	u32 tx_packets;
> +	u32 tx_bytes;
> +};

I think you need to drop the _t postfix here, which presumably comes
from converting it from a typedef.

> +
> +/* The actual devices. */
> +static struct net_device *tile_net_devs[TILE_NET_DEVS];
> +
> +/* The device for a given channel.  HACK: We use "32", not
> + * TILE_NET_CHANNELS, because it is fairly subtle that the 5 bit
> + * "idesc.channel" field never exceeds TILE_NET_CHANNELS.
> + */
> +static struct net_device *tile_net_devs_for_channel[32];

When you need to keep a list or array of device structures in a driver, you're
usually doing something very wrong. The convention is to just pass the pointer
around to where you need it.

> +
> +/* Convert a "buffer ptr" into a "buffer cpa". */
> +static inline void *buf_to_cpa(void *buf)
> +{
> +	return (void *)__pa(buf);
> +}
> +
> +
> +/* Convert a "buffer cpa" into a "buffer ptr". */
> +static inline void *cpa_to_buf(void *cpa)
> +{
> +	return (void *)__va(cpa);
> +}

This is almost certainly wrong: The type returned by __pa is a phys_addr_t,
which cannot be dereferenced like a pointer. On normal drivers, you would
use dma_map_single()/dma_unmap_single() to get a token that can get
passed into a dma engine. From what I can tell, this device is directly mapped,
while your PCI uses an IOMMU, so that would require two different
implementations of dma mapping operations.

> +/* Allocate and push a buffer. */
> +static bool tile_net_provide_buffer(bool small)
> +{
> +	int stack = small ? small_buffer_stack : large_buffer_stack;
> +
> +	/* Buffers must be aligned. */
> +	const unsigned long align = 128;
> +
> +	/* Note that "dev_alloc_skb()" adds NET_SKB_PAD more bytes,
> +	 * and also "reserves" that many bytes.
> +	 */
> +	int len = sizeof(struct sk_buff **) + align + (small ? 128 : 1664);
> +
> +	/* Allocate (or fail). */
> +	struct sk_buff *skb = dev_alloc_skb(len);
> +	if (skb == NULL)
> +		return false;
> +
> +	/* Make room for a back-pointer to 'skb'. */
> +	skb_reserve(skb, sizeof(struct sk_buff **));
> +
> +	/* Make sure we are aligned. */
> +	skb_reserve(skb, -(long)skb->data & (align - 1));
> +
> +	/* Save a back-pointer to 'skb'. */
> +	*(struct sk_buff **)(skb->data - sizeof(struct sk_buff **)) = skb;

This looks very wrong: why would you put the pointer to the skb into the
skb itself?

> +	/* Make sure "skb" and the back-pointer have been flushed. */
> +	__insn_mf();

Try to use archicture independent names for flush operations like this
to make it more readable. I assume this should be smp_wmb()?

> +
> +		/* Compute the "ip checksum". */
> +		jsum = isum_hack + htons(s_len - eh_len) + htons(id);
> +		jsum = __insn_v2sadu(jsum, 0);
> +		jsum = __insn_v2sadu(jsum, 0);
> +		jsum = (0xFFFF ^ jsum);
> +		jh->check = jsum;
> +
> +		/* Update the tcp "seq". */
> +		uh->seq = htonl(seq);
> +
> +		/* Update some flags. */
> +		if (!final)
> +			uh->fin = uh->psh = 0;
> +
> +		/* Compute the tcp pseudo-header checksum. */
> +		usum = tsum_hack + htons(s_len);
> +		usum = __insn_v2sadu(usum, 0);
> +		usum = __insn_v2sadu(usum, 0);
> +		uh->check = usum;

Why to you open-code the ip checksum functions here? Normally the stack takes
care of this by calling the functions you already provide in
arch/tile/lib/checksum.c

	Arnd
