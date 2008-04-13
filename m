From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] Stochastic Fair Blue queue discipline, take two
Date: Sun, 13 Apr 2008 09:25:40 +0200
Message-ID: <4801B574.3050406@trash.net>
References: <87iqyqajtp.fsf@pirx.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Juliusz Chroboczek <jch@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35461 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbYDMH3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 03:29:06 -0400
In-Reply-To: <87iqyqajtp.fsf@pirx.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Juliusz Chroboczek wrote:
> Hi,
>
> The following is a second take on the sfb qdisc.  I've integrated most
> of the changes suggested by Patrick McHardy and Andi Kleen, most notably:
>
>   - now submitted as a patch against the netdev tree;
>   - updated to use nlattr instead of rtattr;
>   - uses jiffies instead of psched_get_time for low-resolution time;
>   - avoids using get_random_bytes;
>   - hopefully fits the kernel coding standards.
>   

Thanks for the update.

> Another change is that I no longer hash NUMHASHES time, but just hash
> once and extract bit slices to produce multiple hashes.  Hopefully the
> jhash functions are well-behaved enough to produce uncorrelated bit slices.
>
> There are two suggestions of theirs that I did not implement:
>
>  - I'm still using kernel_random;
>  - I did not switch to using the classifiers, as in sfq.
>
> Unfortunately, classifiers cannot be used by sfb without some
> modifications.  The main reason is that sfb occasionally performs
> ``double-buffering'' in order to prime a new Bloom filter before it
> starts being used; this means that we need to have two uncorrelated
> hash functions at the same time.
>   

That hash_type stuff should really go. Is there a reason why
using the classifier result and doing perturbation inside
SFB wouldn't work?

> diff --git a/include/net/sfb.h b/include/net/sfb.h
> new file mode 100644
> index 0000000..d822ce8
> --- /dev/null
> +++ b/include/net/sfb.h
>   

This belongs in include/linux/pkt_sched.h.

> @@ -0,0 +1,44 @@
> +/*
> + * sfb.h	Stochastic Fair Blue
> + *
> + *		This program is free software; you can redistribute it and/or
> + *		modify it under the terms of the GNU General Public License
> + *		as published by the Free Software Foundation; either version
> + *		2 of the License, or (at your option) any later version.
> + *
> + * Authors:	Juliusz Chroboczek <jch@pps.jussieu.fr>
> + */
> +
> +#include <linux/types.h>
> +
> +enum {
> +	TCA_SFB_UNSPEC,
> +	TCA_SFB_PARMS,
> +	__TCA_SFB_MAX,
> +};
>   

Please add

#define TCA_SFB_MAX (__TCA_SFB_MAX - 1)

> +
> +enum {
> +	SFB_HASH_FLOW,
> +	SFB_HASH_SOURCE,
> +	SFB_HASH_DEST,
> +	SFB_HASH_SOURCE_DEST,
> +	__SFB_HASH_MAX,
> +};
> +
> +#define TCA_SFB_MAX (__TCA_SFB_MAX - 1)
> +
> +struct tc_sfb_qopt {
> +	__u8 hash_type, pad;
> +	__u16 rehash_interval, db_interval;
> +	__u16 max, target;
> +	__u16 increment, decrement;
> +	__u32 limit;
> +	__u32 penalty_rate, penalty_burst;
> +};
>   

One member per line would increase readability (everywhere else
of course too). A few comments for the non-obvious members like
max and target would also help.

I'd suggest to use nested attributes, even if you currently don't
have plans to add new members. The uglyness necessary to do this
later on is not really worth the small saving in netlink bandwidth.

> +config NET_SCH_SFB
> +	tristate "Stochastic Fair Blue (SFB)"
> +	---help---
> +	  Say Y here if you want to use the Stochastic Fair Blue (SFB)
> +	  packet scheduling algorithm.
> +
> +	  See the top of <file:net/sched/sch_sfb.c> for more details.
>   
Would be better to include the necessary information here or in
Documentation/.

> diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
> new file mode 100644
> index 0000000..b17d35f
> --- /dev/null
> +++ b/net/sched/sch_sfb.c
> @@ -0,0 +1,709 @@
> +/*
> + * sch_sfb.c	Stochastic Fair Blue
> + *
> + *		This program is free software; you can redistribute it and/or
> + *		modify it under the terms of the GNU General Public License
> + *		as published by the Free Software Foundation; either version
> + *		2 of the License, or (at your option) any later version.
> + *
> + * Authors:	Juliusz Chroboczek <jch@pps.jussieu.fr>
> + */
> +
> +#include <linux/module.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/errno.h>
> +#include <linux/jiffies.h>
> +#include <linux/skbuff.h>
> +#include <linux/random.h>
> +#include <linux/jhash.h>
> +#include <net/ip.h>
> +#include <net/pkt_sched.h>
> +#include <net/inet_ecn.h>
> +
> +#include <net/sfb.h>
> +
> +#define BUCKET_SHIFT 4
> +#define NUMBUCKETS (1 << BUCKET_SHIFT)
> +#define BUCKET_MASK (NUMBUCKETS - 1)
> +#define NUMHASHES (32 / BUCKET_SHIFT)
> +
> +struct bucket {
> +	u16 qlen;
> +	u16 pm;
>   

A more descriptive name or a comment would ease reading the code.
> +};
> +
> +struct sfb_sched_data {
> +	u16 rehash_interval, db_interval;
> +	u16 max, target;
> +	u16 increment, decrement;
> +	u32 limit;
> +	u32 penalty_rate, penalty_burst;
> +	u32 tokens_avail;
> +	unsigned long rehash_time, token_time;
> +
> +	u8 hash_type;
> +	u8 filter;
>   

"filter" already has a different meaning in the qdisc context,
how about "hashsel" or something like that?

> +	u8 double_buffering;
> +	u32 perturbation[2];
> +	struct bucket buckets[2][NUMHASHES][NUMBUCKETS];
> +	struct Qdisc *qdisc;
> +
> +	u32 earlydrop, penaltydrop, bucketdrop, queuedrop, marked;
> +};
> +
> +static u32 sfb_hash(struct sk_buff *skb, int filter, struct sfb_sched_data *q)
> +{
> +	u32 h, h2;
> +	u8 hash_type = q->hash_type;
> +
> +	switch (skb->protocol) {
> +	case __constant_htons(ETH_P_IP):
> +	{
> +		const struct iphdr *iph = ip_hdr(skb);
> +		h = hash_type == SFB_HASH_SOURCE ? 0 : iph->daddr;
> +		h2 = hash_type == SFB_HASH_DEST ? 0 : iph->saddr;
> +		if (hash_type == SFB_HASH_FLOW) {
> +			h2 ^= iph->protocol;
> +			if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
> +			    (iph->protocol == IPPROTO_TCP ||
> +			     iph->protocol == IPPROTO_UDP ||
> +			     iph->protocol == IPPROTO_UDPLITE ||
> +			     iph->protocol == IPPROTO_SCTP ||
> +			     iph->protocol == IPPROTO_DCCP ||
> +			     iph->protocol == IPPROTO_ESP)) {
> +				h2 ^= *(((u32*)iph) + iph->ihl);
> +			}
> +		}
> +		break;
> +	}
> +	case __constant_htons(ETH_P_IPV6):
> +	{
> +		struct ipv6hdr *iph = ipv6_hdr(skb);
> +		h = hash_type == SFB_HASH_SOURCE ? 0 :
> +			iph->daddr.s6_addr32[1] ^ iph->daddr.s6_addr32[3];
> +		h2 = hash_type == SFB_HASH_DEST ? 0 :
> +			iph->saddr.s6_addr32[1] ^ iph->saddr.s6_addr32[3];
> +		if (hash_type == SFB_HASH_FLOW) {
> +			h2 ^= iph->nexthdr;
> +			if (iph->nexthdr == IPPROTO_TCP ||
> +			    iph->nexthdr == IPPROTO_UDP ||
> +			    iph->nexthdr == IPPROTO_UDPLITE ||
> +			    iph->nexthdr == IPPROTO_SCTP ||
> +			    iph->nexthdr == IPPROTO_DCCP ||
> +			    iph->nexthdr == IPPROTO_ESP)
> +				h2 ^= *(u32*)&iph[1];
> +		}
> +		break;
> +	}
> +	default:
> +		h = skb->protocol;
> +		if (hash_type != SFB_HASH_SOURCE)
> +			h ^= (u32)(unsigned long)skb->dst;
> +		h2 = hash_type == SFB_HASH_FLOW ?
> +			(u32)(unsigned long)skb->sk : 0;
> +	}
> +
> +	return jhash_2words(h, h2, q->perturbation[filter]);
> +}
> +
> +/* We're treating a single 32-bit hash value as NUMHASHES values of
> + * BUCKET_SHIFT bits each.  This extracts the nth hash value. */
> +static inline u32 nth_hash(u32 hash, int n)
> +{
> +	return (hash >> (n * BUCKET_SHIFT)) & BUCKET_MASK;
> +}
> +
> +/* Probabilities are coded as u16, with 0xFFFF representing 1.
> + * Addition and subtraction are saturating. */
> +
> +static inline u16 prob_plus(u16 p1, u16 p2)
> +{
> +	return p1 < SFB_MAX_PROB - p2 ? p1 + p2 : SFB_MAX_PROB;
> +}
> +
> +static inline u16 prob_minus(u16 p1, u16 p2)
> +{
> +	return p1 > p2 ? p1 - p2 : 0;
> +}
> +
> +/* Virtual queue lengths are coded as u16, operations are saturating. */
> +
> +static void increment_one_qlen(struct sk_buff *skb, u32 hashes,
> +			       int filter, struct sfb_sched_data *q)
> +{
> +	int i;
>   
Please use unsigned types where possible.

> +	for (i = 0; i < NUMHASHES; i++) {
> +		unsigned hash = nth_hash(hashes, i);
> +		if (q->buckets[filter][i][hash].qlen < 0xFFFF)
> +			q->buckets[filter][i][hash].qlen++;
> +	}
> +}
> +
> +static void increment_qlen(struct sk_buff *skb, u32 hashes[2],
> +			   struct sfb_sched_data *q)
> +{
> +	increment_one_qlen(skb, hashes[q->filter], q->filter, q);
> +	if (q->double_buffering)
> +		increment_one_qlen(skb, hashes[!q->filter], !q->filter, q);
> +}
> +
> +static void decrement_one_qlen(struct sk_buff *skb, u32 hashes,
> +			       int filter, struct sfb_sched_data *q)
> +{
> +	int i;
> +	for (i = 0; i < NUMHASHES; i++) {
> +		unsigned hash = nth_hash(hashes, i);
> +		if (q->buckets[filter][i][hash].qlen > 0)
> +			q->buckets[filter][i][hash].qlen--;
> +	}
> +}
> +
> +static void decrement_qlen(struct sk_buff *skb, u32 hashes[2],
> +			   struct sfb_sched_data *q)
> +{
> +	decrement_one_qlen(skb, hashes[q->filter], q->filter, q);
> +	if (q->double_buffering)
> +		decrement_one_qlen(skb, hashes[!q->filter], !q->filter, q);
> +}
> +
> +static inline void decrement_prob(int filter, int bucket, u32 hash,
> +				  struct sfb_sched_data *q)
> +{
> +	q->buckets[filter][bucket][hash].pm =
> +		prob_minus(q->buckets[filter][bucket][hash].pm,
> +			   q->decrement);
> +}
> +
> +static inline void increment_prob(int filter, int bucket, u32 hash,
> +				  struct sfb_sched_data *q)
> +{
> +	q->buckets[filter][bucket][hash].pm =
> +		prob_plus(q->buckets[filter][bucket][hash].pm,
> +			   q->increment);
> +}
> +
> +static void zero_all_buckets(int filter, struct sfb_sched_data *q)
> +{
> +	int i, j;
> +	for (i = 0; i < NUMHASHES; i++) {
> +		for (j = 0; j < NUMBUCKETS; j++) {
> +			q->buckets[filter][i][j].pm = 0;
> +			q->buckets[filter][i][j].qlen = 0;
> +		}
> +	}
>   

Simply memset'ing the bucket array is probably faster.

> +}
> +
> +static void compute_qlen(u16 *qlen_r, u16 *prob_r, struct sfb_sched_data *q)
> +{
> +	int i, j, filter = q->filter;
> +	u16 qlen = 0, prob = 0;
> +	for (i = 0; i < NUMHASHES; i++) {
> +		for (j = 0; j < NUMBUCKETS; j++) {
> +			if (qlen < q->buckets[filter][i][j].qlen)
> +				qlen = q->buckets[filter][i][j].qlen;
> +			if (qlen < q->buckets[filter][i][j].pm)
> +				prob = q->buckets[filter][i][j].pm;
> +		}
> +	}
> +	*qlen_r = qlen;
> +	*prob_r = prob;
> +}
> +
> +static void init_perturbation(int filter, struct sfb_sched_data *q)
> +{
> +	q->perturbation[filter] = net_random();
> +}
> +
> +static void swap_buffers(struct sfb_sched_data *q)
> +{
> +	zero_all_buckets(q->filter, q);
> +	init_perturbation(q->filter, q);
> +	q->filter = !q->filter;
> +	q->double_buffering = 0;
> +}
> +
> +static int rate_limit(struct sk_buff *skb, struct sfb_sched_data *q)
> +{
> +	if (q->penalty_rate == 0 || q->penalty_burst == 0)
> +		return 1;
> +
> +	if (q->tokens_avail < 1) {
> +		psched_time_t now;
> +		psched_tdiff_t age;
> +
> +		now = psched_get_time();
> +		age = psched_tdiff_bounded(now, q->token_time,
> +					   256 * PSCHED_TICKS_PER_SEC);
>   

No (non-obvious) magic values please.

> +		q->tokens_avail =
> +			(age * q->penalty_rate / PSCHED_TICKS_PER_SEC);
> +		if (q->tokens_avail > q->penalty_burst)
> +			q->tokens_avail = q->penalty_burst;
> +		q->token_time = now;
> +		if (q->tokens_avail < 1)
> +			return 1;
> +	}
> +
> +	q->tokens_avail--;
> +	return 0;
> +}
> +
> +static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> +{
> +
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +	struct Qdisc *child = q->qdisc;
> +	u32 hashes[2];
> +	int filter;
> +	u16 minprob = SFB_MAX_PROB;
> +	u16 minqlen = (u16)(~0);
>   
Unnecessary cast and unnecessary parens.

> +	u32 r;
> +	int ret, i;
> +
> +	if (q->rehash_interval > 0) {
> +		unsigned long now = jiffies;
> +		long interval = (unsigned long)q->rehash_interval * HZ;
> +		if (unlikely(time_after(now, q->rehash_time + interval))) {
> +			swap_buffers(q);
> +			q->rehash_time = now;
> +		}
> +		if (unlikely(!q->double_buffering && q->db_interval > 0 &&
> +			     time_after(now,
> +					q->rehash_time + interval -
> +					((long)q->db_interval * HZ))))
>   

Is that cast to long really necessary?

> +			q->double_buffering = 1;
> +	}
> +
> +	filter = q->filter;
> +
> +	hashes[filter] = sfb_hash(skb, filter, q);
> +	for (i = 0; i < NUMHASHES; i++) {
> +		u32 hash = nth_hash(hashes[filter], i);
> +		if (q->buckets[filter][i][hash].qlen == 0)
> +			decrement_prob(filter, i, hash, q);
> +		else if (q->buckets[filter][i][hash].qlen >= q->target)
> +			increment_prob(filter, i, hash, q);
> +		if (minqlen > q->buckets[filter][i][hash].qlen)
> +			minqlen = q->buckets[filter][i][hash].qlen;
> +		if (minprob > q->buckets[filter][i][hash].pm)
> +			minprob = q->buckets[filter][i][hash].pm;
> +	}
> +
> +	if (q->double_buffering) {
> +		hashes[!filter] = sfb_hash(skb, filter, q);
> +		for (i = 0; i < NUMHASHES; i++) {
> +			unsigned hash = nth_hash(hashes[!filter], i);
> +			if (q->buckets[!filter][i][hash].qlen == 0)
> +				decrement_prob(!filter, i, hash, q);
> +			else if (q->buckets[!filter][i][hash].qlen >=
> +				 q->target)
> +				increment_prob(!filter, i, hash, q);
> +		}
> +	}
> +
> +	if (minqlen >= q->max || sch->q.qlen >= q->limit) {
>   

I don't believe you should check the limit here, the inner
qdisc already does that itself.

> +		sch->qstats.overlimits++;
> +		if (likely(minqlen >= q->max))
> +			q->bucketdrop++;
> +		else
> +			q->queuedrop++;
> +		goto drop;
> +	}
> +
> +	if (minprob >= SFB_MAX_PROB) {
> +		/* Inelastic flow */
> +		if (rate_limit(skb, q)) {
> +			sch->qstats.overlimits++;
> +			q->penaltydrop++;
> +			goto drop;
> +		}
> +		goto enqueue;
> +	}
> +
> +	r = net_random() & SFB_MAX_PROB;
> +
> +	if (unlikely(r < minprob)) {
> +		if (unlikely(minprob > SFB_MAX_PROB / 2)) {
> +			/* If we're marking that many packets, then either
> +			 * this flow is unresponsive, or we're badly congested.
> +			 * In either case, we want to start dropping. */
> +			if (r < (minprob - SFB_MAX_PROB / 2) * 2) {
> +				q->earlydrop++;
> +				goto drop;
> +			}
> +		}
> +		if (INET_ECN_set_ce(skb)) {
> +			q->marked++;
> +		} else {
> +			q->earlydrop++;
> +			goto drop;
> +		}
> +	}
> +
> + enqueue:
> +	ret = child->enqueue(skb, child);
> +	if (likely(ret == NET_XMIT_SUCCESS)) {
> +		sch->q.qlen++;
> +		increment_qlen(skb, hashes, q);
> +		sch->bstats.packets++;
> +		sch->bstats.bytes += skb->len;
> +		sch->qstats.backlog += skb->len;
> +	} else {
> +		q->queuedrop++;
> +	}
> +	return ret;
> +
> + drop:
> +	qdisc_drop(skb, sch);
> +	return NET_XMIT_CN;
> +}
> +
> +static int sfb_requeue(struct sk_buff *skb, struct Qdisc* sch)
> +{
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +	struct Qdisc *child = q->qdisc;
> +	u32 hashes[2];
> +	int ret;
> +
> +	ret = child->ops->requeue(skb, child);
> +	if (unlikely(ret != NET_XMIT_SUCCESS)) {
> +		sch->qstats.drops++;
> +		return ret;
> +	}
> +
> +	hashes[q->filter] = sfb_hash(skb, q->filter, q);
> +	if (q->double_buffering)
> +		hashes[!q->filter] = sfb_hash(skb, !q->filter, q);
> +
> +	sch->q.qlen++;
> +	increment_qlen(skb, hashes, q);
> +	sch->qstats.backlog += skb->len;
> +	sch->qstats.requeues++;
> +	return ret;
> +}
> +
> +static struct sk_buff *sfb_dequeue(struct Qdisc* sch)
> +{
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +	struct Qdisc *child = q->qdisc;
> +	struct sk_buff *skb;
> +
> +	skb = child->dequeue(q->qdisc);
> +
> +	if (skb) {
> +		u32 hashes[2];
> +		hashes[q->filter] = sfb_hash(skb, q->filter, q);
> +		if (q->double_buffering)
> +			hashes[!q->filter] = sfb_hash(skb, !q->filter, q);
> +		sch->q.qlen--;
> +		sch->qstats.backlog -= skb->len;
> +		decrement_qlen(skb, hashes, q);
> +	}
> +
> +	return skb;
> +}
> +
> +static void sfb_reset(struct Qdisc* sch)
> +{
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +
> +	qdisc_reset(q->qdisc);
> +	sch->q.qlen = 0;
> +	sch->qstats.backlog = 0;
> +	q->filter = 0;
> +	q->double_buffering = 0;
> +	zero_all_buckets(0, q);
> +	zero_all_buckets(1, q);
> +	init_perturbation(q->filter, q);
> +	init_perturbation(!q->filter, q);
> +}
> +
> +static void sfb_destroy(struct Qdisc *sch)
> +{
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +	qdisc_destroy(q->qdisc);
> +	q->qdisc = NULL;
>   

The NULL assignment is not necessary.

> +}
> +
> +static struct Qdisc *sfb_create_dflt(struct Qdisc *sch, u32 limit)
> +{
> +	struct Qdisc *q;
> +	struct nlattr *nla;
> +	int ret;
> +
> +	q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
> +			      TC_H_MAKE(sch->handle, 1));
> +	if (q) {
> +		nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)),
> +			      GFP_KERNEL);
> +		if (nla) {
> +			nla->nla_type = RTM_NEWQDISC;
> +			nla->nla_len =
> +				nla_attr_size(sizeof(struct tc_fifo_qopt));
> +			((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
> +
> +			ret = q->ops->change(q, nla);
> +			kfree(nla);
> +
> +			if (ret == 0)
> +				return q;
> +		}
> +		qdisc_destroy(q);
> +	}
> +	return NULL;
> +}
> +
> +static const struct nla_policy sfb_policy[__TCA_SFB_MAX] = {
> +	[TCA_SFB_PARMS]	= { .len = sizeof(struct tc_sfb_qopt) },
> +};
> +
> +static int sfb_change(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +	struct Qdisc *child = NULL;
> +	struct nlattr *tb[TCA_SFB_MAX];
> +	struct tc_sfb_qopt *ctl;
> +	u16 rehash_interval, db_interval;
> +	u8 hash_type;
> +	u32 limit;
> +	u16 max, target;
> +	u16 increment, decrement;
> +	u32 penalty_rate, penalty_burst;
> +
> +	if (opt == NULL) {
> +		hash_type = SFB_HASH_FLOW;
> +		rehash_interval = 600;
> +		db_interval = 60;
> +		limit = 0;
> +		max = 22;
> +		target = 20;
> +		increment = (SFB_MAX_PROB + 500) / 1000;
> +		decrement = (SFB_MAX_PROB + 3000) / 6000;
> +		penalty_rate = 10;
> +		penalty_burst = 20;
>   

Too many magic values. Please use symbolic constants with
some explanation of the values chosen.

> +	} else {
> +		int err;
> +		err = nla_parse_nested(tb, __TCA_SFB_MAX - 1, opt, sfb_policy);
> +		if (err < 0)
> +			return err;
> +
> +		if (tb[TCA_SFB_PARMS] == NULL)
> +			return -EINVAL;
> +
> +		ctl = nla_data(tb[TCA_SFB_PARMS]);
> +
> +		rehash_interval = ctl->rehash_interval;
> +		db_interval = ctl->db_interval;
> +		hash_type = ctl->hash_type;
> +		limit = ctl->limit;
> +		max = ctl->max;
> +		target = ctl->target;
> +		increment = ctl->increment;
> +		decrement = ctl->decrement;
> +		penalty_rate = ctl->penalty_rate;
> +		penalty_burst = ctl->penalty_burst;
> +	}
> +
> +	if (hash_type >= __SFB_HASH_MAX)
> +		hash_type = SFB_HASH_FLOW;
> +	if (limit == 0)
> +		limit = sch->dev->tx_queue_len ? sch->dev->tx_queue_len : 1;
> +
> +	child = sfb_create_dflt(sch, limit);
> +	if (child == NULL)
> +		return -ENOMEM;
> +
> +	sch_tree_lock(sch);
> +	if (child) {
>   
child == NULL is impossible ehere since its checked above. Replacing
the inner qdisc shouldn't be done unconditionally though, the default
should only be a default for the initial qdisc.

> +		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
> +		qdisc_destroy(xchg(&q->qdisc, child));
> +	}
> +
> +	q->rehash_interval = rehash_interval;
> +	q->db_interval = db_interval;
> +	q->hash_type = hash_type;
> +	q->limit = limit;
> +	q->increment = increment;
> +	q->decrement = decrement;
> +	q->max = max;
> +	q->target = target;
> +	q->penalty_rate = penalty_rate;
> +	q->penalty_burst = penalty_burst;
> +
> +	q->filter = 0;
> +	q->double_buffering = 0;
> +	zero_all_buckets(0, q);
> +	zero_all_buckets(1, q);
> +	init_perturbation(q->filter, q);
> +	init_perturbation(!q->filter, q);
> +
> +	sch_tree_unlock(sch);
> +
> +	return 0;
> +}
> +
> +static int sfb_init(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +
> +	q->qdisc = &noop_qdisc;
>   

The noop_qdisc assignment looks unnecessary, its replaced unconditionally.
> +	return sfb_change(sch, opt);
> +}
> +
> +static int sfb_dump(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +	struct nlattr *opts = NULL;
>   
Unnecessary initialization to NULL

> +	struct tc_sfb_qopt opt = { .rehash_interval = q->rehash_interval,
> +				   .db_interval = q->db_interval,
> +				   .hash_type = q->hash_type,
> +				   .limit = q->limit,
> +				   .max = q->max,
> +				   .target = q->target,
> +				   .increment = q->increment,
> +				   .decrement = q->decrement,
> +				   .penalty_rate = q->penalty_rate,
> +				   .penalty_burst = q->penalty_burst,
> +	};
>   

Please reindent this correctly by using two tabs (same for other
C99 initializers).

> +
> +	opts = nla_nest_start(skb, TCA_OPTIONS);
> +	if (opts == NULL)
> +		goto nla_put_failure;
> +	NLA_PUT(skb, TCA_SFB_PARMS, sizeof(opt), &opt);
> +	return nla_nest_end(skb, opts);
> +
> +nla_put_failure:
> +	return nla_nest_cancel(skb, opts);
> +}
> +
> +static int sfb_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
> +{
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +	struct tc_sfb_xstats st = { .earlydrop = q->earlydrop,
> +				    .penaltydrop = q->penaltydrop,
> +				    .bucketdrop = q->bucketdrop,
> +				    .marked = q->marked};
> +
> +	compute_qlen(&st.maxqlen, &st.maxprob, q);
> +
> +	return gnet_stats_copy_app(d, &st, sizeof(st));
> +}
> +static struct Qdisc_class_ops sfb_class_ops =
>   
const please.

