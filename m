From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v6 3/3] skb_array: array based FIFO for skbs
Date: Thu, 2 Jun 2016 16:17:02 +0800
Message-ID: <574FEB7E.8060902@redhat.com>
References: <1464785601-3074-1-git-send-email-mst@redhat.com>
 <1464785601-3074-4-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464785601-3074-4-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016=E5=B9=B406=E6=9C=8801=E6=97=A5 20:54, Michael S. Tsirkin wrote:
> A simple array based FIFO of pointers.  Intended for net stack so use=
s
> skbs for type safety. Implemented as a set of wrappers around ptr_arr=
ay.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>   include/linux/skb_array.h | 129 +++++++++++++++++++++++++++++++++++=
+++++++++++
>   1 file changed, 129 insertions(+)
>   create mode 100644 include/linux/skb_array.h
>
> diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
> new file mode 100644
> index 0000000..cb67076
> --- /dev/null
> +++ b/include/linux/skb_array.h
> @@ -0,0 +1,129 @@
> +/*
> + *	Definitions for the 'struct skb_array' datastructure.
> + *
> + *	Author:
> + *		Michael S. Tsirkin <mst@redhat.com>
> + *
> + *	Copyright (C) 2016 Red Hat, Inc.
> + *
> + *	This program is free software; you can redistribute it and/or mod=
ify it
> + *	under the terms of the GNU General Public License as published by=
 the
> + *	Free Software Foundation; either version 2 of the License, or (at=
 your
> + *	option) any later version.
> + *
> + *	Limited-size FIFO of skbs. Can be used more or less whenever
> + *	sk_buff_head can be used, except you need to know the queue size =
in
> + *	advance.
> + *	Implemented as a type-safe wrapper around ptr_ring.
> + */
> +
> +#ifndef _LINUX_SKB_ARRAY_H
> +#define _LINUX_SKB_ARRAY_H 1
> +
> +#ifdef __KERNEL__
> +#include <linux/ptr_ring.h>
> +#include <linux/skbuff.h>
> +#endif
> +
> +struct skb_array {
> +	struct ptr_ring ring;
> +};
> +
> +/* Might be slightly faster than skb_array_full below, but callers i=
nvoking
> + * this in a loop must use a compiler barrier, for example cpu_relax=
().
> + */
> +static inline bool __skb_array_full(struct skb_array *a)
> +{
> +	return __ptr_ring_full(&a->ring);
> +}
> +
> +static inline bool skb_array_full(struct skb_array *a)
> +{
> +	return ptr_ring_full(&a->ring);
> +}
> +
> +static inline int skb_array_produce(struct skb_array *a, struct sk_b=
uff *skb)
> +{
> +	return ptr_ring_produce(&a->ring, skb);
> +}
> +
> +static inline int skb_array_produce_irq(struct skb_array *a, struct =
sk_buff *skb)
> +{
> +	return ptr_ring_produce_irq(&a->ring, skb);
> +}
> +
> +static inline int skb_array_produce_bh(struct skb_array *a, struct s=
k_buff *skb)
> +{
> +	return ptr_ring_produce_bh(&a->ring, skb);
> +}
> +
> +static inline int skb_array_produce_any(struct skb_array *a, struct =
sk_buff *skb)
> +{
> +	return ptr_ring_produce_any(&a->ring, skb);
> +}
> +
> +/* Might be slightly faster than skb_array_empty below, but callers =
invoking
> + * this in a loop must take care to use a compiler barrier, for exam=
ple
> + * cpu_relax().
> + */
> +static inline bool __skb_array_empty(struct skb_array *a)
> +{
> +	return !__ptr_ring_peek(&a->ring);
> +}
> +
> +static inline bool skb_array_empty(struct skb_array *a)
> +{
> +	return ptr_ring_empty(&a->ring);
> +}
> +
> +static inline struct sk_buff *skb_array_consume(struct skb_array *a)
> +{
> +	return ptr_ring_consume(&a->ring);
> +}
> +
> +static inline struct sk_buff *skb_array_consume_irq(struct skb_array=
 *a)
> +{
> +	return ptr_ring_consume_irq(&a->ring);
> +}
> +
> +static inline struct sk_buff *skb_array_consume_any(struct skb_array=
 *a)
> +{
> +	return ptr_ring_consume_any(&a->ring);
> +}
> +
> +static inline struct sk_buff *skb_array_consume_bh(struct skb_array =
*a)
> +{
> +	return ptr_ring_consume_bh(&a->ring);
> +}
> +
> +static inline int skb_array_peek_len(struct skb_array *a)
> +{
> +	return PTR_RING_PEEK_FIELD(&a->ring, struct sk_buff, len, 0);
> +}

An interesting case for tun is peek the length of a tagged packet. In=20
this case, len should be increased accordingly. So this simple filed=20
peeking won't work.

Do we need a callback here?

> +
> +static inline int skb_array_peek_len_irq(struct skb_array *a)
> +{
> +	return PTR_RING_PEEK_FIELD_IRQ(&a->ring, struct sk_buff, len, 0);
> +}
> +
> +static inline int skb_array_peek_len_bh(struct skb_array *a)
> +{
> +	return PTR_RING_PEEK_FIELD_BH(&a->ring, struct sk_buff, len, 0);
> +}
> +
> +static inline int skb_array_peek_len_any(struct skb_array *a)
> +{
> +	return PTR_RING_PEEK_FIELD_ANY(&a->ring, struct sk_buff, len, 0);
> +}
> +
> +static inline int skb_array_init(struct skb_array *a, int size, gfp_=
t gfp)
> +{
> +	return ptr_ring_init(&a->ring, size, gfp);
> +}
> +
> +static inline void skb_array_cleanup(struct skb_array *a)
> +{
> +	ptr_ring_cleanup(&a->ring);
> +}
> +
> +#endif /* _LINUX_SKB_ARRAY_H  */
