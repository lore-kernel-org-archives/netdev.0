From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] net: allocate skbs on local node
Date: Mon, 11 Oct 2010 22:35:01 -0700
Message-ID: <AANLkTinxDYEd=WkSyZpU7f5kye+tbC08XC2zngAjU_Pn@mail.gmail.com>
References: <1286838210.30423.128.camel@edumazet-laptop>
	<1286839363.30423.130.camel@edumazet-laptop>
	<1286859925.30423.184.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:15045 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab0JLFfG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 01:35:06 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o9C5Z409010569
	for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 22:35:04 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by hpaq7.eem.corp.google.com with ESMTP id o9C5Z1bm027723
	for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 22:35:02 -0700
Received: by pvg7 with SMTP id 7so85969pvg.41
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 22:35:01 -0700 (PDT)
In-Reply-To: <1286859925.30423.184.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Tom Herbert <therbert@google.com>

On Mon, Oct 11, 2010 at 10:05 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 12 octobre 2010 =E0 01:22 +0200, Eric Dumazet a =E9crit :
>> Le mardi 12 octobre 2010 =E0 01:03 +0200, Eric Dumazet a =E9crit :
>> >
>> > For multi queue devices, it makes more sense to allocate skb on lo=
cal
>> > node of the cpu handling RX interrupts. This allow each cpu to
>> > manipulate its own slub/slab queues/structures without doing expen=
sive
>> > cross-node business.
>> >
>> > For non multi queue devices, IRQ affinity should be set so that a =
cpu
>> > close to the device services interrupts. Even if not set, using
>> > dev_alloc_skb() is faster.
>> >
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>
>> Or maybe revert :
>>
>> commit b30973f877fea1a3fb84e05599890fcc082a88e5
>> Author: Christoph Hellwig <hch@lst.de>
>> Date: =A0 Wed Dec 6 20:32:36 2006 -0800
>>
>> =A0 =A0 [PATCH] node-aware skb allocation
>>
>> =A0 =A0 Node-aware allocation of skbs for the receive path.
>>
>> =A0 =A0 Details:
>>
>> =A0 =A0 =A0 - __alloc_skb gets a new node argument and cals the node=
-aware
>> =A0 =A0 =A0 =A0 slab functions with it.
>> =A0 =A0 =A0 - netdev_alloc_skb passed the node number it gets from d=
ev_to_node
>> =A0 =A0 =A0 =A0 to it, everyone else passes -1 (any node)
>>
>> =A0 =A0 Signed-off-by: Christoph Hellwig <hch@lst.de>
>> =A0 =A0 Cc: Christoph Lameter <clameter@engr.sgi.com>
>> =A0 =A0 Cc: "David S. Miller" <davem@davemloft.net>
>> =A0 =A0 Signed-off-by: Andrew Morton <akpm@osdl.org>
>>
>>
>> Apparently, only Christoph and Andrew signed it.
>>
>>
>
> [PATCH net-next] net: allocate skbs on local node
>
> commit b30973f877 (node-aware skb allocation) spread a wrong habit of
> allocating net drivers skbs on a given memory node : The one closest =
to
> the NIC hardware. This is wrong because as soon as we try to scale
> network stack, we need to use many cpus to handle traffic and hit
> slub/slab management on cross-node allocations/frees when these cpus
> have to alloc/free skbs bound to a central node.
>
> skb allocated in RX path are ephemeral, they have a very short
> lifetime : Extra cost to maintain NUMA affinity is too expensive. Wha=
t
> appeared as a nice idea four years ago is in fact a bad one.
>
> In 2010, NIC hardwares are multiqueue, or we use RPS to spread the lo=
ad,
> and two 10Gb NIC might deliver more than 28 million packets per secon=
d,
> needing all the available cpus.
>
> Cost of cross-node handling in network and vm stacks outperforms the
> small benefit hardware had when doing its DMA transfert in its 'local=
'
> memory node at RX time. Even trying to differentiate the two allocati=
ons
> done for one skb (the sk_buff on local node, the data part on NIC
> hardware node) is not enough to bring good performance.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =A0include/linux/skbuff.h | =A0 20 ++++++++++++++++----
> =A0net/core/skbuff.c =A0 =A0 =A0| =A0 13 +------------
> =A02 files changed, 17 insertions(+), 16 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 0b53c43..05a358f 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -496,13 +496,13 @@ extern struct sk_buff *__alloc_skb(unsigned int=
 size,
> =A0static inline struct sk_buff *alloc_skb(unsigned int size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0gfp_t priority)
> =A0{
> - =A0 =A0 =A0 return __alloc_skb(size, priority, 0, -1);
> + =A0 =A0 =A0 return __alloc_skb(size, priority, 0, NUMA_NO_NODE);
> =A0}
>
> =A0static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t priority)
> =A0{
> - =A0 =A0 =A0 return __alloc_skb(size, priority, 1, -1);
> + =A0 =A0 =A0 return __alloc_skb(size, priority, 1, NUMA_NO_NODE);
> =A0}
>
> =A0extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
> @@ -1563,13 +1563,25 @@ static inline struct sk_buff *netdev_alloc_sk=
b_ip_align(struct net_device *dev,
> =A0 =A0 =A0 =A0return skb;
> =A0}
>
> -extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_=
t gfp_mask);
> +/**
> + * =A0 =A0 __netdev_alloc_page - allocate a page for ps-rx on a spec=
ific device
> + * =A0 =A0 @dev: network device to receive on
> + * =A0 =A0 @gfp_mask: alloc_pages_node mask
> + *
> + * =A0 =A0 Allocate a new page. dev currently unused.
> + *
> + * =A0 =A0 %NULL is returned if there is no free memory.
> + */
> +static inline struct page *__netdev_alloc_page(struct net_device *de=
v, gfp_t gfp_mask)
> +{
> + =A0 =A0 =A0 return alloc_pages_node(NUMA_NO_NODE, gfp_mask, 0);
> +}
>
> =A0/**
> =A0* =A0 =A0 netdev_alloc_page - allocate a page for ps-rx on a speci=
fic device
> =A0* =A0 =A0 @dev: network device to receive on
> =A0*
> - * =A0 =A0 Allocate a new page node local to the specified device.
> + * =A0 =A0 Allocate a new page. dev currently unused.
> =A0*
> =A0* =A0 =A0 %NULL is returned if there is no free memory.
> =A0*/
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 752c197..4e8b82e 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -247,10 +247,9 @@ EXPORT_SYMBOL(__alloc_skb);
> =A0struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int length, gfp_t gfp_mask)
> =A0{
> - =A0 =A0 =A0 int node =3D dev->dev.parent ? dev_to_node(dev->dev.par=
ent) : -1;
> =A0 =A0 =A0 =A0struct sk_buff *skb;
>
> - =A0 =A0 =A0 skb =3D __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, =
node);
> + =A0 =A0 =A0 skb =3D __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, =
NUMA_NO_NODE);
> =A0 =A0 =A0 =A0if (likely(skb)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_reserve(skb, NET_SKB_PAD);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->dev =3D dev;
> @@ -259,16 +258,6 @@ struct sk_buff *__netdev_alloc_skb(struct net_de=
vice *dev,
> =A0}
> =A0EXPORT_SYMBOL(__netdev_alloc_skb);
>
> -struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_m=
ask)
> -{
> - =A0 =A0 =A0 int node =3D dev->dev.parent ? dev_to_node(dev->dev.par=
ent) : -1;
> - =A0 =A0 =A0 struct page *page;
> -
> - =A0 =A0 =A0 page =3D alloc_pages_node(node, gfp_mask, 0);
> - =A0 =A0 =A0 return page;
> -}
> -EXPORT_SYMBOL(__netdev_alloc_page);
> -
> =A0void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page=
, int off,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int size)
> =A0{
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
