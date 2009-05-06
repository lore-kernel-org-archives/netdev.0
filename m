From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH,RFC] generic skb recycling
Date: Wed, 06 May 2009 16:25:13 +0200
Message-ID: <4A019DC9.7000307@cosmosbay.com>
References: <20090506141243.GK24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, afleming@freescale.com, bkostya@marvell.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58694 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbZEFO2c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 10:28:32 -0400
In-Reply-To: <20090506141243.GK24429@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek a =E9crit :
> This RFC patch removes the skb recycling that was added to mv643xx_et=
h
> a while ago and moves it into the stack, based on an earlier idea by
> Kostya Belezko <bkostya@marvell.com>.  There's a couple of reasons fo=
r
> doing this:
>=20
> - Make skb recycling available to all drivers, without needing driver
>   modifications.
>=20
> - Allow recycling skbuffs in more cases, by having the recycle check
>   in __kfree_skb() instead of in the ethernet driver transmit
>   completion routine.  This also allows for example recycling locally
>   destined skbuffs, instead of only recycling forwarded skbuffs as
>   the transmit completion-time check does.
>=20
> - Allow more consumers of skbuffs in the system use recycled skbuffs,
>   and not just the rx refill process in the driver.
>=20
> - Having a per-interface recycle list doesn't allow skb recycling whe=
n
>   you're e.g. unidirectionally routing from eth0 to eth1, as eth1 wil=
l
>   be producing a lot of recycled skbuffs but eth0 won't have any skbu=
ffs
>   to allocate from its recycle list.
>=20
>=20
> Generic skb recycling is slightly slower than doing it in the driver,
> e.g. in the case of mv643xx_eth about 70 cycles per packet.  Given th=
e
> benefits I think that's an OK price to pay.
>=20
>=20
> Open items:
>=20
> - I tried putting the recycle list in the per-CPU softnet state, but
>   the skb allocator is initialised before the softnet state is, and I
>   ended up with ugly tests in __{alloc,kfree}_skb() to check whether
>   softnet init is done yet.  (Maybe softnet state can be initialised
>   earlier?)
>=20
> - I picked SKB_DATA_ALIGN(ETH_FRAME_LEN + SMP_CACHE_BYTES) as the skb
>   size threshold for skb recycling, as with NET_SKB_PAD padding inclu=
ded
>   that's what I suppose most non-frag RX drivers will end up allocati=
ng
>   for their receive ring (which is the main source for recycled skbuf=
fs).
>   I haven't yet measured the effect on frag RX with LRO/GRO to see if
>   there's a benefit in recycling there as well.
>=20
> - Determine a sensible value for the recycle queue length.  For
>   in-driver recycling, I chose the rx queue length, as we'll never
>   allocate more than that in one go, but here it's a bit less clear
>   what a good value would be.
>=20
>=20
> Thoughts?

Interesting idea but :

1) Wont it break copybreak feature existing in some drivers ?

After your patch, an __alloc_skb(small size) can give a full size recyc=
led skb. Some UDP servers
might consume much more ram :(

2) It breaks NUMA properties of existing code, and may increase cache l=
ine ping-pongs on SMP

(On some setups, one CPU receives all incoming frames and TX completion=
,
while another CPU(s) send(s) frames)

3) Are you sure your uses of &__get_cpu_var(skbuff_recycle_list) are sa=
fe
vs preemption ? For example, __alloc_skb() can be called with preempt e=
nabled :)


So... we definitly want some numbers and benchmarks :)

>=20
>=20
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index d583852..738b5c3 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -403,7 +403,6 @@ struct mv643xx_eth_private {
>  	u8 work_rx_refill;
> =20
>  	int skb_size;
> -	struct sk_buff_head rx_recycle;
> =20
>  	/*
>  	 * RX state.
> @@ -656,10 +655,7 @@ static int rxq_refill(struct rx_queue *rxq, int =
budget)
>  		int rx;
>  		struct rx_desc *rx_desc;
> =20
> -		skb =3D __skb_dequeue(&mp->rx_recycle);
> -		if (skb =3D=3D NULL)
> -			skb =3D dev_alloc_skb(mp->skb_size);
> -
> +		skb =3D dev_alloc_skb(mp->skb_size);
>  		if (skb =3D=3D NULL) {
>  			mp->oom =3D 1;
>  			goto oom;
> @@ -962,14 +958,8 @@ static int txq_reclaim(struct tx_queue *txq, int=
 budget, int force)
>  				       desc->byte_cnt, DMA_TO_DEVICE);
>  		}
> =20
> -		if (skb !=3D NULL) {
> -			if (skb_queue_len(&mp->rx_recycle) <
> -					mp->rx_ring_size &&
> -			    skb_recycle_check(skb, mp->skb_size))
> -				__skb_queue_head(&mp->rx_recycle, skb);
> -			else
> -				dev_kfree_skb(skb);
> -		}
> +		if (skb !=3D NULL)
> +			dev_kfree_skb(skb);
>  	}
> =20
>  	__netif_tx_unlock(nq);
> @@ -2368,8 +2358,6 @@ static int mv643xx_eth_open(struct net_device *=
dev)
> =20
>  	napi_enable(&mp->napi);
> =20
> -	skb_queue_head_init(&mp->rx_recycle);
> -
>  	mp->int_mask =3D INT_EXT;
> =20
>  	for (i =3D 0; i < mp->rxq_count; i++) {
> @@ -2464,8 +2452,6 @@ static int mv643xx_eth_stop(struct net_device *=
dev)
>  	mib_counters_update(mp);
>  	del_timer_sync(&mp->mib_counters_timer);
> =20
> -	skb_queue_purge(&mp->rx_recycle);
> -
>  	for (i =3D 0; i < mp->rxq_count; i++)
>  		rxq_deinit(mp->rxq + i);
>  	for (i =3D 0; i < mp->txq_count; i++)
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d152394..c9c111f 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -56,6 +56,7 @@
>  #include <linux/init.h>
>  #include <linux/scatterlist.h>
>  #include <linux/errqueue.h>
> +#include <linux/cpu.h>
> =20
>  #include <net/protocol.h>
>  #include <net/dst.h>
> @@ -71,6 +72,9 @@
> =20
>  static struct kmem_cache *skbuff_head_cache __read_mostly;
>  static struct kmem_cache *skbuff_fclone_cache __read_mostly;
> +static DEFINE_PER_CPU(struct sk_buff_head, skbuff_recycle_list);
> +
> +#define SKB_MIN_RECYCLE_SIZE	SKB_DATA_ALIGN(ETH_FRAME_LEN + SMP_CACH=
E_BYTES)
> =20
>  static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
>  				  struct pipe_buffer *buf)
> @@ -176,6 +180,14 @@ struct sk_buff *__alloc_skb(unsigned int size, g=
fp_t gfp_mask,
>  	struct sk_buff *skb;
>  	u8 *data;
> =20
> +	if (size <=3D SKB_MIN_RECYCLE_SIZE && !fclone) {
> +		struct sk_buff_head *h =3D &__get_cpu_var(skbuff_recycle_list);
> +
> +		skb =3D skb_dequeue(h);
> +		if (skb !=3D NULL)
> +			return skb;
> +	}
> +
>  	cache =3D fclone ? skbuff_fclone_cache : skbuff_head_cache;
> =20
>  	/* Get the HEAD */
> @@ -423,7 +435,37 @@ static void skb_release_all(struct sk_buff *skb)
> =20
>  void __kfree_skb(struct sk_buff *skb)
>  {
> -	skb_release_all(skb);
> +	struct sk_buff_head *h =3D &__get_cpu_var(skbuff_recycle_list);
> +
> +	skb_release_head_state(skb);
> +
> +	if (skb_queue_len(h) < 256 &&
> +	    !skb_cloned(skb) && !skb_is_nonlinear(skb) &&
> +	    skb->fclone =3D=3D SKB_FCLONE_UNAVAILABLE &&
> +	    skb_end_pointer(skb) - skb->head >=3D SKB_MIN_RECYCLE_SIZE) {
> +		struct skb_shared_info *shinfo;
> +
> +		shinfo =3D skb_shinfo(skb);
> +		atomic_set(&shinfo->dataref, 1);
> +		shinfo->nr_frags =3D 0;
> +		shinfo->gso_size =3D 0;
> +		shinfo->gso_segs =3D 0;
> +		shinfo->gso_type =3D 0;
> +		shinfo->ip6_frag_id =3D 0;
> +		shinfo->tx_flags.flags =3D 0;
> +		shinfo->frag_list =3D NULL;
> +		memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
> +
> +		memset(skb, 0, offsetof(struct sk_buff, tail));
> +		skb->data =3D skb->head;
> +		skb_reset_tail_pointer(skb);
> +
> +		skb_queue_head(h, skb);
> +
> +		return;
> +	}
> +
> +	skb_release_data(skb);
>  	kfree_skbmem(skb);
>  }
>  EXPORT_SYMBOL(__kfree_skb);
> @@ -2756,8 +2798,24 @@ done:
>  }
>  EXPORT_SYMBOL_GPL(skb_gro_receive);
> =20
> +static int
> +skb_cpu_callback(struct notifier_block *nfb,
> +		 unsigned long action, void *ocpu)
> +{
> +	unsigned long oldcpu =3D (unsigned long)ocpu;
> +
> +	if (action =3D=3D CPU_DEAD || action =3D=3D CPU_DEAD_FROZEN) {
> +		struct sk_buff_head *h =3D &per_cpu(skbuff_recycle_list, oldcpu);
> +		skb_queue_purge(h);
> +	}
> +
> +	return NOTIFY_OK;
> +}
> +
>  void __init skb_init(void)
>  {
> +	int i;
> +
>  	skbuff_head_cache =3D kmem_cache_create("skbuff_head_cache",
>  					      sizeof(struct sk_buff),
>  					      0,
> @@ -2769,6 +2827,13 @@ void __init skb_init(void)
>  						0,
>  						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
>  						NULL);
> +
> +	for_each_possible_cpu(i) {
> +		struct sk_buff_head *h =3D &per_cpu(skbuff_recycle_list, i);
> +		skb_queue_head_init(h);
> +	}
> +
> +	hotcpu_notifier(skb_cpu_callback, 0);
>  }
> =20
>  /**


