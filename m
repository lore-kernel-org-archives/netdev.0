From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next-2.6] net: introduce build_skb()
Date: Mon, 11 Jul 2011 12:53:24 +0200
Message-ID: <20110711105323.GB7532@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <ae7b531c89a01a21e4374907b69f4d997c9d5d1b.1310339688.git.mirq-linux@rere.qmqm.pl>
 <1310363206.2512.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:38595 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754222Ab1GKKx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 06:53:29 -0400
Content-Disposition: inline
In-Reply-To: <1310363206.2512.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 07:46:46AM +0200, Eric Dumazet wrote:
> Le lundi 11 juillet 2011 =C3=A0 02:52 +0200, Micha=C5=82 Miros=C5=82a=
w a =C3=A9crit :
> > Introduce __netdev_alloc_skb_aligned() to return skb with skb->data
> > aligned at specified 2^n multiple.
> >=20
> > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Hi Michal
>=20
> Could we synchronize our work to not introduce things that might
> disappear shortly ?

Sure. Are you saying that you'll convert all drivers to build_skb()? :-=
)

> Here is the RFC patch about build_skb() :
>=20
> [PATCH] net: introduce build_skb()
>=20
> One of the thing we discussed during netdev 2011 conference was the i=
dea
> to change network drivers to allocate/populate their skb at RX
> completion time, right before feeding the skb to network stack.
>=20
> Right now, we allocate skbs when populating the RX ring, and thats a
> waste of CPU cache, since allocating skb means a full memset() to cle=
ar
> the skb and its skb_shared_info portion. By the time NIC fills a fram=
e
> in data buffer and host can get it, cpu probably threw away the cache
> lines from its caches, because of huge RX ring sizes.
>=20
> So the deal would be to allocate only the data buffer for the NIC to
> populate its RX ring buffer. And use build_skb() at RX completion to
> attach a data buffer (now filled with an ethernet frame) to a new skb=
,
> initialize the skb_shared_info portion, and give the hot skb to netwo=
rk
> stack.
>=20
> build_skb() is the function to allocate an skb, caller providing the
> data buffer that should be attached to it. Drivers are expected to ca=
ll=20
> skb_reserve() right after build_skb() to let skb->data points to the
> Ethernet frame (usually skipping NET_SKB_PAD and NET_IP_ALIGN)
[...]
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -234,6 +234,54 @@ nodata:
[...]
>  /**
> + * build_skb - build a network buffer
> + * @data: data buffer provider by caller
> + * @size: size of data buffer, not including skb_shared_info
> + *
> + * Allocate a new &sk_buff. Caller provides space holding head and
> + * skb_shared_info. Mostly used in driver RX path.
> + * The return is the buffer. On a failure the return is %NULL.
> + * Notes :
> + *  Before IO, driver allocates only data buffer where NIC put incom=
ing frame
> + *  Driver SHOULD add room at head (NET_SKB_PAD) and
> + *  MUST add room tail (to hold skb_shared_info)
> + *  After IO, driver calls build_skb(), to get a hot skb instead of =
a cold one
> + *  before giving packet to stack. RX rings only contains data buffe=
rs, not
> + *  full skbs.
> + */
> +struct sk_buff *build_skb(void *data, unsigned int size)
> +{
> +	struct skb_shared_info *shinfo;
> +	struct sk_buff *skb;
> +
> +	skb =3D kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
> +	if (!skb)
> +		return NULL;
> +
> +	size =3D SKB_DATA_ALIGN(size);
> +
> +	memset(skb, 0, offsetof(struct sk_buff, tail));
> +	skb->truesize =3D size + sizeof(struct sk_buff);
> +	atomic_set(&skb->users, 1);
> +	skb->head =3D data;
> +	skb->data =3D data;
> +	skb_reset_tail_pointer(skb);
> +	skb->end =3D skb->tail + size;
> +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> +	skb->mac_header =3D ~0U;
> +#endif
> +
> +	/* make sure we initialize shinfo sequentially */
> +	shinfo =3D skb_shinfo(skb);
> +	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
> +	atomic_set(&shinfo->dataref, 1);
> +	kmemcheck_annotate_variable(shinfo->destructor_arg);
> +
> +	return skb;
> +}
> +EXPORT_SYMBOL(build_skb);

I like the idea. From driver writer perspective I would like to also
see a function that given max frame size and DMA aligment would allocat=
e
the buffer for me.

In short:

 * rx_refill:

	[ptr, size] =3D alloc_rx_buffer(size, alignment, offset);
	[dma_addr] =3D map_buffer(ptr, size);
	append to rx buffer list

 * rx_poll:

	unmap_buffer(dma_addr, size);
	[skb] =3D build_skb(ptr, size);
	if (!skb)
		reuse_buffer
		return
	skb_reserve(skb, rx_offset);
	skb_put(skb, pkt_len);
	(indicate offloads)
	rx_skb(skb);
	call rx_refill

 * rx_poll with copybreak:

	sync_buffer_to_cpu(dma_addr, data_len);
	[skb, copied] =3D build_or_copy_skb(ptr, size, hw_rx_offset, pkt_len);
	if (copied || !skb)
		append to rx buffer list
	else
		unmap_buffer(dma_addr, size);
	if (!skb)
		return;
	(indicate offloads)
	rx_skb(skb);
	if (!copied)
		call rx_refill


=46or even less driver code this could happen:

 * rx_refill(ptr, dma_addr)
	[size/alignment stored in queue or net_device struct]

	if (is_rx_free_list_full)
		return -EBUSY;
	append to rx buffer list [ptr, dma_addr, size]
	return !is_rx_free_list_full;

 * rx_poll with copybreak:
	[copy threshold stored in queue or net_device struct]

	[skb] =3D finish_rx(ptr, dma_addr, size, hw_rx_offset, pkt_len);
	if (!skb)
		return;
	(fill in offloads: checksum/etc)
	rx_skb(skb);


This could be extended to handle frames spanning multiple buffers.

BTW, napi_get_frags() + napi_gro_frags() use similar idea of allocating
skb late.

Best Regards,
Micha=C5=82 Miros=C5=82aw
