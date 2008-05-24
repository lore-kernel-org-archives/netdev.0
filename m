From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] Stochastic Fair Blue queue discipline, take two
Date: Sat, 24 May 2008 21:37:44 +0200
Message-ID: <48386E88.2010104@trash.net>
References: <87iqyqajtp.fsf@pirx.pps.jussieu.fr> <4801B574.3050406@trash.net> <87tzgojx0o.fsf@pirx.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Juliusz Chroboczek <jch@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43141 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387AbYEXThu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2008 15:37:50 -0400
In-Reply-To: <87tzgojx0o.fsf@pirx.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Juliusz Chroboczek wrote:
> On 9 April 2008, I wrote
> 
>>> The following is a second take on the sfb qdisc...

Great.

> There are quite a few things in Patrick's message that I don't understand.
> 
>>> +struct tc_sfb_qopt {
> ...
>> I'd suggest to use nested attributes, even if you currently don't
>> have plans to add new members. The uglyness necessary to do this
>> later on is not really worth the small saving in netlink bandwidth.
> 
> Could you please clarify what you mean?  Perhaps by pointing me to
> some code?

You can either use put a struct inside the netlink attribute,
as you did, or nest other attributes below it and put the
data there. Look at hfsc_change_class() for one of many examples.

>>> +	int i;
> 
>> Please use unsigned types where possible.
> 
> Is that a hard requirement?  (I happen to prefer int, which I find
> more readable.)

unsigned has some advantages. You know it will never be negative
just by looking at the type, its more logical for things like a packet
length and in some cases the compiler can generate better code.
Hard requirement - sounds too extreme, I hope these arguments are
enough to convince you.

>>> +	u16 minqlen = (u16)(~0);
> 
>> Unnecessary cast and unnecessary parens.
> 
> I realise that, but I dislike having non-trivial operations
> (truncation) being done by the assignment operation.  Is that a hard
> requirement?

No, but I bet someone will send a cleanup patch to change
it anyways.

>>> +	child = sfb_create_dflt(sch, limit);
>>> +	if (child == NULL)
>>> +		return -ENOMEM;
>>> +
>>> +	sch_tree_lock(sch);
>>> +	if (child) {
> 
>> child == NULL is impossible ehere since its checked above. Replacing
>> the inner qdisc shouldn't be done unconditionally though, the default
>> should only be a default for the initial qdisc.
> 
> Please clarify.  This is code that was copied verbatim from sch_red,
> and I do not understand it.

You return -ENOMEM when child == NULL just three lines above.
So the check is obviously superfluous.

> Perhaps it'd be better if you made the needed changes to sch_red first?

red needs the check because the child may be NULL.

>>> +	q->qdisc = &noop_qdisc;
> 
>> The noop_qdisc assignment looks unnecessary, its replaced unconditionally.
> 
> Again, this is code copied verbatim from sch_red.  Please make the
> changes there first, I'm a little nervous about modifying code I don't
> understand.

You should be nervous about copying code you don't understand :)
red doesn't unconditionally assign q->qdisc in red_change(),
so it really needs this assigment.

>>> +	struct tc_sfb_qopt opt = { .rehash_interval = q->rehash_interval,
>>> +				   .db_interval = q->db_interval,
>>> +				   .hash_type = q->hash_type,
>>> +				   .limit = q->limit,
>>> +				   .max = q->max,
>>> +				   .target = q->target,
>>> +				   .increment = q->increment,
>>> +				   .decrement = q->decrement,
>>> +				   .penalty_rate = q->penalty_rate,
>>> +				   .penalty_burst = q->penalty_burst,
>>> +	};
> 
>> Please reindent this correctly by using two tabs (same for other
>> C99 initializers).
> 
> Please clarify, and point me to a suitable example.  I'm just
> following the style in sch_red.

You don't, red uses proper intendation, which would look like this:

	struct tc_sfb_qopt opt = {
		.rehash_interval = ...,
		.hash_type = ...
		^ one level deeper than struct
