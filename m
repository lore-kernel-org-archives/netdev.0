From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: Re: [PATCH 1/2] Stochastic Fair Blue queue discipline, take two
Date: Wed, 16 Apr 2008 18:04:35 +0200
Message-ID: <7i3aplbxbg.fsf@lanthane.pps.jussieu.fr>
References: <87iqyqajtp.fsf@pirx.pps.jussieu.fr> <4801B574.3050406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:49958 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756412AbYDPQF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 12:05:29 -0400
In-Reply-To: <4801B574.3050406@trash.net> (Patrick McHardy's message of "Sun\, 13 Apr 2008 09\:25\:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot for your review, Patrick.

>> Unfortunately, classifiers cannot be used by sfb without some
>> modifications.  The main reason is that sfb occasionally performs
>> ``double-buffering'' in order to prime a new Bloom filter before it
>> starts being used; this means that we need to have two uncorrelated
>> hash functions at the same time.
>>   
>
> That hash_type stuff should really go. Is there a reason why
> using the classifier result and doing perturbation inside
> SFB wouldn't work?

I don't see how that can be done.  We need to perturbate before we
hash, not afterwards.  The goal is that hash functions with different
perturbations must not be correlated.

Additionally, sfb is using all of the 32 bits of entropy given by the
hash; using just 16 bits won't do.  Let me explain.

>From my point of view, the main desirable property of SFB is that it
will reliably recognise ill-behaved (non-reactive) flows, and put them
in a ``penalty box''.  As far as I know, SFB is the only queuing
discipline for Linux that will do that.

Now the fact that the discrimination between well- and ill-behaved
flows is reliable is essential; it means that we can severely penalise
ill-behaved flows without running the risk of locking out well-behaved
ones.  The Bloom filter implementation in sfb, which takes 512 bytes,
has the same probability of pairwise hash collision as a 4 billion
bucket hash table.  In other words, it is using the full 32 bits of
entropy given by the hash.

(If that sounds too good to be true, it is.  The probability of n-way
hash collision is much higher.  However, if you assume that most flows
are well-behaved, then n-way hash collisions are not an issue.)

I'm using sfb in production; if it switches to using just 16 bits of
entropy, it will no longer be useful for me.

> Would be better to include the necessary information here or in
> Documentation/.

Yep, will do.

>> +struct bucket {
>> +	u16 qlen;
>> +	u16 pm;
>>   

> A more descriptive name or a comment would ease reading the code.

I cannot change the names -- I'm following the notations in the paper,
but I will add a comment.

> "filter" already has a different meaning in the qdisc context,
> how about "hashsel" or something like that?

Hmm...  I'll try to think up a better name.

>> +	int i;
>> +	for (i = 0; i < NUMHASHES; i++) {

> Please use unsigned types where possible.

For a loop counter?  Why's that?

>> +	for (i = 0; i < NUMHASHES; i++) {
>> +		for (j = 0; j < NUMBUCKETS; j++) {
>> +			q->buckets[filter][i][j].pm = 0;
>> +			q->buckets[filter][i][j].qlen = 0;
>> +		}
>> +	}
>>   

Will do.

> Simply memset'ing the bucket array is probably faster.

>> +		age = psched_tdiff_bounded(now, q->token_time,
>> +					   256 * PSCHED_TICKS_PER_SEC);
>>   

> No (non-obvious) magic values please.

I'll add a comment.

>> +		if (unlikely(!q->double_buffering && q->db_interval > 0 &&
>> +			     time_after(now,
>> +					q->rehash_time + interval -
>> +					((long)q->db_interval * HZ))))
>>   

> Is that cast to long really necessary?

db_interval is a short, I want to make sure that the computation
doesn't overflow at 2^16.  I believe that C's contagion rules
guarantee that 32-bit computation will happen even without the cast,
but the cast cannot harm and it makes me more comfortable.

>> +	if (minqlen >= q->max || sch->q.qlen >= q->limit) {
>>   
>
> I don't believe you should check the limit here, the inner
> qdisc already does that itself.

I'm not sure:

  tc qdisc add dev eth0 root handle 1: sfb limit 50
  tc qdisc add dev eth0 parent 1: prio

Won't in this case the child qdisc have prio's default limit?  If
I don't check the limit in sfb, the resulting behaviour would be
somewhat surprising.

> The NULL assignment is not necessary.
[...]
> Replacing the inner qdisc shouldn't be done unconditionally though,
> the default should only be a default for the initial qdisc.
[...]
> The noop_qdisc assignment looks unnecessary, its replaced unconditionally.
[...]
> Unnecessary initialization to NULL
[...]
> const please.

All of these comments are about code that's copied verbatim from
sch_red, and which I don't understand.  I'm a little nervous about
modifying stuff that I don't understand, so please make sure you
review these bits carefully.

Thanks again for your review, Patrick.  I'll try to send an updated
patch this week-end.

                                        Juliusz
