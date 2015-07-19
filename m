From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 -next] net: fib: use fib result when zero-length prefix
 aliases exist
Date: Sun, 19 Jul 2015 14:43:03 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507191327090.1658@ja.home.ssi.bg>
References: <1437154621-18180-1-git-send-email-fw@strlen.de> <alpine.LFD.2.11.1507180045330.2410@ja.home.ssi.bg> <20150718180546.GA7835@breakpoint.cc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52672 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751057AbbGSLnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2015 07:43:24 -0400
In-Reply-To: <20150718180546.GA7835@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 18 Jul 2015, Florian Westphal wrote:

> Julian Anastasov <ja@ssi.bg> wrote:
> 
> > 	The only difference I see is that NUD_NODE is
> > declared by fib_nud_is_unreach() as reachable. May be
> > it is better, for example, new route in NUD_NONE state
> > will be tried for a while, until its state is determined.
> 
> fib_detect_death considers neigh_lookup() returning NULL as unreach.

	I mean, NUD_NODE is possible state, for example,
if entry is created by user space for silly reasons.
For example:

ip neigh add $IP dev $DEV nud none
ip neigh list nud none

	It is present and not used yet. Even ip route get
can not trigger neigh resolving, state will remain same.
Only traffic can trigger resolving.

> I don't think its good idea and should rather only skip if NUD is
> failed or incomplete.

	OK, then we are back to NUD_VALID usage.

> > 	round-robin only among reachables? But original algorithm
> > can round-robin among unreachables. State will not change
> > without trying some packets to unreachable dests.
> 
> Hmm... thanks for pointing that out.
> 
> But thats confusing.  If thats true, why does fib_detect_death
> even exist?  If we skip unreachables, they cannot become
> reachable again...?

	No, we return them one by one. If we direct traffic
to some alternative GW its state may switch to reachable. If
this GW is unreachable, the next try will select next alternative
GW. The algorithm tries to probe the unreachable GWs until
the traffic causes successful ARP resolving and selecting
one GW as reachable.

> > 	1=unreac, 2=reach, 3=tb_default(reach), 4=reach.
> > We like 2 (fi == NULL), why we continue after 2, skip
> > default 3 (because order > tb->tb_default is false) and
> > finally select 4 (order=4 > tb->tb_default=3)?
> 
> Hmm.  Let me ask different question.
> What is the supposed behaviour in the case you describe?

	I think, GW 2 should be selected as first reachable,
it should not be skipped.

	I decode fib_detect_death and fib_select_default as follows:

1. only one fi? keep tb_default=-1 no matter the state

2. prefer the first NUD_REACHABLE or NUD_VALID that is not tb_default.
I see the following cases:

2.1. NUD_REACHABLE is before another NUD_VALID => use only the 
NUD_REACHABLE

2.2. NUD_VALID is before another NUD_VALID/NUD_REACHABLE => switch
between them. I don't know the reason for this logic, though.
Note that NUD_REACHABLE is part of the NUD_VALID mask.

3. if there are no other NUD_VALID and the current (tb_default) is
NUD_VALID use it again

4. try all (!NUD_VALID) GWs one by one in a round-robin fashion by
increasing tb_default from -1 to max and then back to -1.
Such round-robin is attempted if there are no NUD_VALID GWs.
This is used after idle periods or if new GWs are added to
direct traffic for ARP probing.

> Removing order > default
> test means we'll always pick first reachable in the list, no?

	First reachable is ok, why not? But fib_detect_death
tries some differentiation between NUD_REACHABLE and
NUD_VALID.

> I don't think thats bad, but, how/why is is that 'better'?
> 
> > > +	tb->tb_default = fi_idx;
> > 
> > 	And we do not round-robin if all look unreachable?
> 
> Right.  One possible solution might be this patch, but alter
> fib_nud_is_unreach() to also check timer_pending(n->timer), i.e.
> 
> if (state & (NUD_INCOMPLETE | NUD_FAILED))
> 	return timer_was_pending ? UNREACHABLE : REACHABLE;

	Such timer_was_pending check is not needed. State
specifies if timer is running.

> This way we would re-try gw not only if neigh doesn't exist but
> also if no retry is pending.

	You mean:

- NUD_FAILED/NUD_NONE: no timer is pending, no current probing,
we can direct traffic that will set NUD_INCOMPLETE and will
send ARP probe

- NUD_INCOMPLETE: GW is currently probed, do not use it for
round-robin, direct traffic to another NUD_FAILED/NUD_NONE GW

	Still, above states should be considered "unreachable",
the difference will be only for the round-robin algorithm
when all GWs are unreachable.

> What do you think?

	But what do you think about above fib_detect_death
logic? I think, your tests fail just because ip route get
does not trigger traffic that will cause ARP resolution and
because fib_select_default is buggy to not check slen and
especially the tos.

> > +		if (fa->tb_id != tb->tb_id)
> > +			continue;
> > +		if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
> > +			continue;
> 
> Hmm, this means we won't consider alternative if tos doesn't match,
> except 0.
> 
> So with
> ip route add tos 0x00 via 192.168.1.1
> ip route add tos 0x04 via 192.168.1.2
> ip route add tos 0x08 via 192.168.1.3
> ip route add tos 0x0c via 192.168.1.4
> ip route add tos 0x10 via 192.168.1.5
> 
> and ping -Q 1.2.3.4
> 
> if 1.5 is unreachable, we pick 1.1 (tos 0x0).
> 
> Others are not attempted.

	Yep

> Do you consider that 'correct'?  I don't see why
> we can use tos 0x00 but not e.g. 0x04 in that case.

	It is illegal to return alternative routes that should
be selected for another TOS, 192.168.1.2 should be selected
only for packets with TOS 0x04. And TOS 0x00 in packets can not
be matched by definition, it is used as 'match any TOS' value.

	Also, without TOS restriction the 'if (next_fi != res->fi)'
check will avoid alternatives for routes that have TOS with lower
value, for example:

ip route add tos 0x20 via 1.1.1.1
ip route add tos 0x20 via 2.2.2.2
ip route add tos 0x10 via 3.3.3.3
ip route add tos 0x10 via 4.4.4.4
ip route add tos 0x00 via 5.5.5.5

	fib_select_default from recent kernels always starts
from fa_head pointing to 1.1.1.1, so if res->fi points to the
same place the alternatives for TOS 0x20 will be considered.

	But if res->fi selects 3.3.3.3 for TOS 0x10 the
'if (next_fi != res->fi)' breaks and the 4.4.4.4 alternative
is ignored => tb_default=-1.

	In your example in first email, TOS 0x10 does
round-robin because it is the highest TOS and its alt
routes are considered. Due to the bug in fib_select_default
for lower TOS values no alt GWs are considered. That explains
the behaviour you see.

> If .5 becomes available, we won't attempt it and still use 1.1/tos 0.

	1.5 is before 1.1 in fa_head list, so it has priority
among the reachable/valid routes.

	The list with alternative routes should be:

- all routes with same TOS starting from the res->fi. The
TOS check in my patch will skip routes with higher TOS value
and then with lower TOS value that is not 0.

- if above TOS is not 0 we should consider all routes with TOS 0.
In above example, we have 3 possible lists of alt routes:

- IP.TOS 0x20: 1.1.1.1, 2.2.2.2, 5.5.5.5
- IP.TOS 0x10: 3.3.3.3, 4.4.4.4, 5.5.5.5
- other TOS: 5.5.5.5

	The funny part is that tb->tb_default is one
and can't remember the order for every list. May be
tb_default should be moved to fa (the first one for TOS).
In above example, the first fa is 1.1.1.1, 3.3.3.3
and 5.5.5.5.

	So, I think, there is no big reason to change
fib_detect_death. But fib_select_default needs to filter
by slen and TOS and may be to move tb_default to fa,
in case one wants to use TOS in alt routes.

Regards

--
Julian Anastasov <ja@ssi.bg>
