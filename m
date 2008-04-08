From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 10:20:34 +0200
Message-ID: <873apwrc4t.fsf@basil.nowhere.org>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Juliusz Chroboczek <jch@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:14312 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbYDHIUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 04:20:37 -0400
In-Reply-To: <87skxxb8br.fsf@pirx.pps.jussieu.fr> (Juliusz Chroboczek's message of "Tue, 08 Apr 2008 00:37:12 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Juliusz Chroboczek <jch@pps.jussieu.fr> writes:


Have not read everything. General comment you'll likely need to 
do some code style cleanups (read Documentation/CodingStyle) 
Especially indentation should be consistent (one easy way 
to get that would be to run it through Lindent, although you
might need to review it afterwards because Lindent sometimes does
weird things)

> +
> +static unsigned sfb_hash(struct sk_buff *skb, int hash, int filter,
> +                         struct sfb_sched_data *q)
> +{
> +	u32 h, h2;
> +        u8 hash_type = q->hash_type;
> +
> +	switch (skb->protocol) {
> +	case __constant_htons(ETH_P_IP):

I think we have multiple qdiscs now doing very similar such hashes.
Any chance this could be factored out into a common library function 
first?

The nice property of that is that it would make it much easier
to add new protocols later.

> +static int sfb_enqueue(struct sk_buff *skb, struct Qdisc* sch)
> +{
> +
> +	struct sfb_sched_data *q = qdisc_priv(sch);
> +        struct Qdisc *child = q->qdisc;
> +        psched_time_t now;
> +        int filter;
> +        u16 minprob = SFB_MAX_PROB;
> +        u16 minqlen = (u16)(~0);
> +        u32 r;
> +        int ret, i;
> +
> +        now = psched_get_time();

Getting high res time can be actually somewhat expensive on different
platforms. I would recommend to only use it if it's actually needed in
the inelastic flow case below and use jiffies to check for rehashing.

> +
> +        if(q->rehash_interval > 0) {
> +                psched_tdiff_t age;
> +                age = psched_tdiff_bounded(now, q->rehash_time,
> +                                           q->rehash_interval *
> +                                           PSCHED_TICKS_PER_SEC);
> +                if(unlikely(age >= q->rehash_interval * PSCHED_TICKS_PER_SEC)) {
> +                        swap_buffers(q);
> +                        q->rehash_time = now;
> +                }
> +                if(unlikely(!q->double_buffering && q->db_interval > 0 &&
> +                            age >= (q->rehash_interval - q->db_interval) *
> +                            PSCHED_TICKS_PER_SEC))
> +                        q->double_buffering = 1;


/dev/random is a precious resource (some systems have very little true entropy)
and getting that much data from it regularly is not a good idea because
you take it away from other users who really need it (like strong cryptography)

I'm not sure if the rehash is for security or not (some comments on that 
would be good). But in any case it is likely better you only get
the get_random_bytes() entropy once and then use that to init some kind
of RNG (either a secure one if it's for security or some random 
fast one if it's not) and then use that output for rehashing.

-Andi
