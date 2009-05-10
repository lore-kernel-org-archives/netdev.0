From: Kostya Belezko <bkostya@marvell.com>
Subject: RE: [PATCH,RFC] generic skb recycling
Date: Sun, 10 May 2009 15:26:20 +0300
Message-ID: <29206AF176EE094F8FDEE2F29BB1674C8E0508BFD0@IL-MB01.marvell.com>
References: <20090506141243.GK24429@mail.wantstofly.org>
 <4A019DC9.7000307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>
To: Eric Dumazet <dada1@cosmosbay.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:22929 "EHLO
	il.marvell.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751245AbZEJMiJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 08:38:09 -0400
In-Reply-To: <4A019DC9.7000307@cosmosbay.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The idea was of having extended recycle and allowing locally destined (=
or any) skbuffs to return to their driver's home. The driver should rec=
ognize skb by somekind skb->hw_cookie. The field could contain the adap=
ter, queue, physical address translation, etc. which makes refill proce=
ss much faster.

Definitely, having one global cpu pool improves performance and could b=
e usefull for other consumers, but not fully fits network drivers i.e.
it is hard to work with non-1500 MTU. In order to support different MTU=
s, there is a need to maintain recycle queue per network interface.

Let's the recycle mechanism to be generic, but the recycle queue is dri=
ver private. By examining hw_cookie the mechanism would decide which qu=
eue to put skb in.

-----Original Message-----
=46rom: Eric Dumazet [mailto:dada1@cosmosbay.com]
Sent: Wednesday, May 06, 2009 5:25 PM
To: Lennert Buytenhek
Cc: netdev@vger.kernel.org; afleming@freescale.com; Kostya Belezko
Subject: Re: [PATCH,RFC] generic skb recycling

Lennert Buytenhek a =E9crit :
> This RFC patch removes the skb recycling that was added to mv643xx_et=
h
> a while ago and moves it into the stack, based on an earlier idea by
> Kostya Belezko <bkostya@marvell.com>.  There's a couple of reasons fo=
r
> doing this:
>
> - Make skb recycling available to all drivers, without needing driver
>   modifications.
>
> - Allow recycling skbuffs in more cases, by having the recycle check
>   in __kfree_skb() instead of in the ethernet driver transmit
>   completion routine.  This also allows for example recycling locally
>   destined skbuffs, instead of only recycling forwarded skbuffs as
>   the transmit completion-time check does.
>
> - Allow more consumers of skbuffs in the system use recycled skbuffs,
>   and not just the rx refill process in the driver.
>
> - Having a per-interface recycle list doesn't allow skb recycling whe=
n
>   you're e.g. unidirectionally routing from eth0 to eth1, as eth1 wil=
l
>   be producing a lot of recycled skbuffs but eth0 won't have any skbu=
ffs
>   to allocate from its recycle list.
>
>
> Generic skb recycling is slightly slower than doing it in the driver,
> e.g. in the case of mv643xx_eth about 70 cycles per packet.  Given th=
e
> benefits I think that's an OK price to pay.
>
>
> Open items:
>
> - I tried putting the recycle list in the per-CPU softnet state, but
>   the skb allocator is initialised before the softnet state is, and I
>   ended up with ugly tests in __{alloc,kfree}_skb() to check whether
>   softnet init is done yet.  (Maybe softnet state can be initialised
>   earlier?)
>
> - I picked SKB_DATA_ALIGN(ETH_FRAME_LEN + SMP_CACHE_BYTES) as the skb
>   size threshold for skb recycling, as with NET_SKB_PAD padding inclu=
ded
>   that's what I suppose most non-frag RX drivers will end up allocati=
ng
>   for their receive ring (which is the main source for recycled skbuf=
fs).
>   I haven't yet measured the effect on frag RX with LRO/GRO to see if
>   there's a benefit in recycling there as well.
>
> - Determine a sensible value for the recycle queue length.  For
>   in-driver recycling, I chose the rx queue length, as we'll never
>   allocate more than that in one go, but here it's a bit less clear
>   what a good value would be.
>
>
> Thoughts?

Interesting idea but :

1) Wont it break copybreak feature existing in some drivers ?

After your patch, an __alloc_skb(small size) can give a full size recyc=
led skb. Some UDP servers might consume much more ram :(

2) It breaks NUMA properties of existing code, and may increase cache l=
ine ping-pongs on SMP

(On some setups, one CPU receives all incoming frames and TX completion=
, while another CPU(s) send(s) frames)

3) Are you sure your uses of &__get_cpu_var(skbuff_recycle_list) are sa=
fe vs preemption ? For example, __alloc_skb() can be called with preemp=
t enabled :)


So... we definitly want some numbers and benchmarks :)

>
>
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index d583852..738b5c3 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -403,7 +403,6 @@ struct mv643xx_eth_private {
>       u8 work_rx_refill;
>
>       int skb_size;
> -     struct sk_buff_head rx_recycle;
>
>       /*
>        * RX state.
> @@ -656,10 +655,7 @@ static int rxq_refill(struct rx_queue *rxq, int =
budget)
>               int rx;
>               struct rx_desc *rx_desc;
>
> -             skb =3D __skb_dequeue(&mp->rx_recycle);
> -             if (skb =3D=3D NULL)
> -                     skb =3D dev_alloc_skb(mp->skb_size);
> -
> +             skb =3D dev_alloc_skb(mp->skb_size);
>               if (skb =3D=3D NULL) {
>                       mp->oom =3D 1;
>                       goto oom;
> @@ -962,14 +958,8 @@ static int txq_reclaim(struct tx_queue *txq, int=
 budget, int force)
>                                      desc->byte_cnt, DMA_TO_DEVICE);
>               }
>
> -             if (skb !=3D NULL) {
> -                     if (skb_queue_len(&mp->rx_recycle) <
> -                                     mp->rx_ring_size &&
> -                         skb_recycle_check(skb, mp->skb_size))
> -                             __skb_queue_head(&mp->rx_recycle, skb);
> -                     else
> -                             dev_kfree_skb(skb);
> -             }
> +             if (skb !=3D NULL)
> +                     dev_kfree_skb(skb);
>       }
>
>       __netif_tx_unlock(nq);
> @@ -2368,8 +2358,6 @@ static int mv643xx_eth_open(struct net_device
> *dev)
>
>       napi_enable(&mp->napi);
>
> -     skb_queue_head_init(&mp->rx_recycle);
> -
>       mp->int_mask =3D INT_EXT;
>
>       for (i =3D 0; i < mp->rxq_count; i++) { @@ -2464,8 +2452,6 @@
> static int mv643xx_eth_stop(struct net_device *dev)
>       mib_counters_update(mp);
>       del_timer_sync(&mp->mib_counters_timer);
>
> -     skb_queue_purge(&mp->rx_recycle);
> -
>       for (i =3D 0; i < mp->rxq_count; i++)
>               rxq_deinit(mp->rxq + i);
>       for (i =3D 0; i < mp->txq_count; i++) diff --git
> a/net/core/skbuff.c b/net/core/skbuff.c index d152394..c9c111f 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -56,6 +56,7 @@
>  #include <linux/init.h>
>  #include <linux/scatterlist.h>
>  #include <linux/errqueue.h>
> +#include <linux/cpu.h>
>
>  #include <net/protocol.h>
>  #include <net/dst.h>
> @@ -71,6 +72,9 @@
>
>  static struct kmem_cache *skbuff_head_cache __read_mostly;  static
> struct kmem_cache *skbuff_fclone_cache __read_mostly;
> +static DEFINE_PER_CPU(struct sk_buff_head, skbuff_recycle_list);
> +
> +#define SKB_MIN_RECYCLE_SIZE SKB_DATA_ALIGN(ETH_FRAME_LEN +
> +SMP_CACHE_BYTES)
>
>  static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
>                                 struct pipe_buffer *buf) @@ -176,6
> +180,14 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_m=
ask,
>       struct sk_buff *skb;
>       u8 *data;
>
> +     if (size <=3D SKB_MIN_RECYCLE_SIZE && !fclone) {
> +             struct sk_buff_head *h =3D
> + &__get_cpu_var(skbuff_recycle_list);
> +
> +             skb =3D skb_dequeue(h);
> +             if (skb !=3D NULL)
> +                     return skb;
> +     }
> +
>       cache =3D fclone ? skbuff_fclone_cache : skbuff_head_cache;
>
>       /* Get the HEAD */
> @@ -423,7 +435,37 @@ static void skb_release_all(struct sk_buff *skb)
>
>  void __kfree_skb(struct sk_buff *skb)  {
> -     skb_release_all(skb);
> +     struct sk_buff_head *h =3D &__get_cpu_var(skbuff_recycle_list);
> +
> +     skb_release_head_state(skb);
> +
> +     if (skb_queue_len(h) < 256 &&
> +         !skb_cloned(skb) && !skb_is_nonlinear(skb) &&
> +         skb->fclone =3D=3D SKB_FCLONE_UNAVAILABLE &&
> +         skb_end_pointer(skb) - skb->head >=3D SKB_MIN_RECYCLE_SIZE)=
 {
> +             struct skb_shared_info *shinfo;
> +
> +             shinfo =3D skb_shinfo(skb);
> +             atomic_set(&shinfo->dataref, 1);
> +             shinfo->nr_frags =3D 0;
> +             shinfo->gso_size =3D 0;
> +             shinfo->gso_segs =3D 0;
> +             shinfo->gso_type =3D 0;
> +             shinfo->ip6_frag_id =3D 0;
> +             shinfo->tx_flags.flags =3D 0;
> +             shinfo->frag_list =3D NULL;
> +             memset(&shinfo->hwtstamps, 0,
> + sizeof(shinfo->hwtstamps));
> +
> +             memset(skb, 0, offsetof(struct sk_buff, tail));
> +             skb->data =3D skb->head;
> +             skb_reset_tail_pointer(skb);
> +
> +             skb_queue_head(h, skb);
> +
> +             return;
> +     }
> +
> +     skb_release_data(skb);
>       kfree_skbmem(skb);
>  }
>  EXPORT_SYMBOL(__kfree_skb);
> @@ -2756,8 +2798,24 @@ done:
>  }
>  EXPORT_SYMBOL_GPL(skb_gro_receive);
>
> +static int
> +skb_cpu_callback(struct notifier_block *nfb,
> +              unsigned long action, void *ocpu) {
> +     unsigned long oldcpu =3D (unsigned long)ocpu;
> +
> +     if (action =3D=3D CPU_DEAD || action =3D=3D CPU_DEAD_FROZEN) {
> +             struct sk_buff_head *h =3D &per_cpu(skbuff_recycle_list=
, oldcpu);
> +             skb_queue_purge(h);
> +     }
> +
> +     return NOTIFY_OK;
> +}
> +
>  void __init skb_init(void)
>  {
> +     int i;
> +
>       skbuff_head_cache =3D kmem_cache_create("skbuff_head_cache",
>                                             sizeof(struct sk_buff),
>                                             0, @@ -2769,6 +2827,13 @@
> void __init skb_init(void)
>                                               0,
>                                               SLAB_HWCACHE_ALIGN|SLAB=
_PANIC,
>                                               NULL);
> +
> +     for_each_possible_cpu(i) {
> +             struct sk_buff_head *h =3D &per_cpu(skbuff_recycle_list=
, i);
> +             skb_queue_head_init(h);
> +     }
> +
> +     hotcpu_notifier(skb_cpu_callback, 0);
>  }
>
>  /**


