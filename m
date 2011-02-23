From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 v3] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 17:24:35 +0100
Message-ID: <4D6534C3.1080305@trash.net>
References: <20110221160306.GA9650@tuxdriver.com>	 <1298308283.2849.5.camel@edumazet-laptop>	 <1298390536.2861.9.camel@edumazet-laptop> <1298474091.3301.364.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54988 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab1BWQYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 11:24:37 -0500
In-Reply-To: <1298474091.3301.364.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 23.02.2011 16:14, schrieb Eric Dumazet:
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 16626a0..f40d32e 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -218,6 +218,7 @@ struct tcf_proto {
>  
>  struct qdisc_skb_cb {
>  	unsigned int		pkt_len;
> +	unsigned int		sfb_classid;
>  	char			data[];
>  };

This could be moved into a SFB specific cb, similar to what netem
does.

> diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
> new file mode 100644
> index 0000000..b7f1c6e
> --- /dev/null
> +++ b/net/sched/sch_sfb.c
> @@ -0,0 +1,696 @@
> +/*
> + * net/sched/sch_sfb.c	  Stochastic Fair Blue
> + *
> + * Copyright (c) 2008-2011 Juliusz Chroboczek <jch@pps.jussieu.fr>
> + * Copyright (c) 2011 Eric Dumazet <eric.dumazet@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + *
> + * W. Feng, D. Kandlur, D. Saha, K. Shin. Blue: 
> + * A New Class of Active Queue Management Algorithms. 
> + * U. Michigan CSE-TR-387-99, April 1999.
> + *
> + * http://www.thefengs.com/wuchang/blue/CSE-TR-387-99.pdf
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <linux/random.h>
> +#include <linux/jhash.h>
> +#include <net/ip.h>
> +#include <net/pkt_sched.h>
> +#include <net/inet_ecn.h>
> +
> +/*
> + * SFB uses two B[l][n] : L x N arrays of bins (L levels, N bins per level)
> + * This implementation uses L = 8 and N = 16
> + * This permits us to split one 32bit hash (provided per packet by rxhash or
> + * external classifier) into 8 subhashes of 4 bits.
> + */
> +#define SFB_BUCKET_SHIFT 4

If you want to make this dynamic, there are a couple of papers analyzing
combined hash functions for bloom filters, f.i.
"Less Hashing, Same Performance: Building a Better Bloom Filter".

> +/*
> + * If using 'internal' SFB flow classifier, sfb_classid is skb rxhash
> + * If using external classifier, sfb_classid contains the classid.
> + */
> +static u32 sfb_hash(const struct sk_buff *skb, u32 slot,
> +		    struct sfb_sched_data *q)
> +{
> +	return jhash_1word(qdisc_skb_cb(skb)->sfb_classid,
> +			   q->bins[slot].perturbation);
> +}
> +
> +/* Probabilities are coded as Q0.16 fixed-point values,
> + * with 0xFFFF representing 65535/65536 (almost 1.0)
> + * Addition and subtraction are saturating in [0, 65535]
> + */
> +static u32 prob_plus(u32 p1, u32 p2)
> +{
> +	u32 res = p1 + p2;
> +
> +	return min_t(u32, res, SFB_MAX_PROB);
> +}
> +
> +static u32 prob_minus(u32 p1, u32 p2)
> +{
> +	return p1 > p2 ? p1 - p2 : 0;
> +}
> +
> +static void increment_one_qlen(u32 sfbhash, u32 slot, struct sfb_sched_data *q)
> +{
> +	int i;
> +	struct sfb_bucket *b = &q->bins[slot].bins[0][0];
> +
> +	for (i = 0; i < SFB_LEVELS; i++) {
> +		u32 hash = sfbhash & SFB_BUCKET_MASK;
> +
> +		sfbhash >>= SFB_BUCKET_SHIFT;
> +		if (b[hash].qlen < 0xFFFF)
> +			b[hash].qlen++;
> +		b += SFB_NUMBUCKETS; /* next level */
> +	}
> +}
> +
> +static void increment_qlen(u32 hashes[2], struct sfb_sched_data *q)
> +{
> +	u32 slot = q->slot;
> +
> +	increment_one_qlen(hashes[slot], slot, q);
> +	if (q->double_buffering) {
> +		slot ^= 1;
> +		increment_one_qlen(hashes[slot], slot, q);
> +	}
> +}
> +
> +static void decrement_one_qlen(u32 sfbhash, u32 slot,
> +			       struct sfb_sched_data *q)
> +{
> +	int i;
> +	struct sfb_bucket *b = &q->bins[slot].bins[0][0];
> +
> +	for (i = 0; i < SFB_LEVELS; i++) {
> +		u32 hash = sfbhash & SFB_BUCKET_MASK;
> +
> +		sfbhash >>= SFB_BUCKET_SHIFT;
> +		if (b[hash].qlen > 0)
> +			b[hash].qlen--;
> +		b += SFB_NUMBUCKETS; /* next level */
> +	}
> +}
> +
> +static void decrement_qlen(struct sk_buff *skb, struct sfb_sched_data *q)
> +{
> +	u32 slot = q->slot;
> +	u32 sfbhash = sfb_hash(skb, slot, q);
> +
> +	decrement_one_qlen(sfbhash, slot, q);
> +	if (q->double_buffering) {

This needs to be a per-skb property, otherwise you could have the
situation:

- enqueue skb, double_buffering=0, increment buffer 0
- enable double buffering
- swap buffers
- dequeue same skb, decrement buffer 1

after which the qlen values of buffer 1 will be incorrect.


> +		slot ^= 1;
> +		sfbhash = sfb_hash(skb, slot, q);

Isn't there room in the cb to store both hash values?

> +		decrement_one_qlen(sfbhash, slot, q);
> +	}
> +}
> +
