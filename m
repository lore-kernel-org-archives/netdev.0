From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 -next] net: fib: use fib result when zero-length
 prefix aliases exist
Date: Mon, 20 Jul 2015 01:03:45 +0200
Message-ID: <20150719230345.GA11985@breakpoint.cc>
References: <1437154621-18180-1-git-send-email-fw@strlen.de>
 <alpine.LFD.2.11.1507180045330.2410@ja.home.ssi.bg>
 <20150718180546.GA7835@breakpoint.cc>
 <alpine.LFD.2.11.1507191327090.1658@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33525 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753873AbbGSXDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2015 19:03:49 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1507191327090.1658@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> wrote:
> ip neigh add $IP dev $DEV nud none
> ip neigh list nud none
> 
> 	It is present and not used yet. Even ip route get
> can not trigger neigh resolving, state will remain same.
> Only traffic can trigger resolving.

Right.

> > > 	round-robin only among reachables? But original algorithm
> > > can round-robin among unreachables. State will not change
> > > without trying some packets to unreachable dests.
> > 
> > Hmm... thanks for pointing that out.
> > 
> > But thats confusing.  If thats true, why does fib_detect_death
> > even exist?  If we skip unreachables, they cannot become
> > reachable again...?
> 
> 	No, we return them one by one. If we direct traffic
> to some alternative GW its state may switch to reachable. If
> this GW is unreachable, the next try will select next alternative
> GW. The algorithm tries to probe the unreachable GWs until
> the traffic causes successful ARP resolving and selecting
> one GW as reachable.

Doesn't work for me (or I misunderstand). See below.

> 	I decode fib_detect_death and fib_select_default as follows:

[Description of algorithm]

> 2. prefer the first NUD_REACHABLE or NUD_VALID that is not tb_default.
> I see the following cases:
> 
> 2.1. NUD_REACHABLE is before another NUD_VALID => use only the 
> NUD_REACHABLE

Yes, and thats what I don't understand.

> 	You mean:
> 
> - NUD_FAILED/NUD_NONE: no timer is pending, no current probing,
> we can direct traffic that will set NUD_INCOMPLETE and will
> send ARP probe
> 
> - NUD_INCOMPLETE: GW is currently probed, do not use it for
> round-robin, direct traffic to another NUD_FAILED/NUD_NONE GW

Yes, thats what I meant.

> 	Still, above states should be considered "unreachable",
> the difference will be only for the round-robin algorithm
> when all GWs are unreachable.

> 	But what do you think about above fib_detect_death
> logic? I think, your tests fail just because ip route get
> does not trigger traffic that will cause ARP resolution and
> because fib_select_default is buggy to not check slen and
> especially the tos.

Mostly, yes.

> > So with
> > ip route add tos 0x00 via 192.168.1.1
> > ip route add tos 0x04 via 192.168.1.2
> > ip route add tos 0x08 via 192.168.1.3
> > ip route add tos 0x0c via 192.168.1.4
> > ip route add tos 0x10 via 192.168.1.5
> > 
> > and ping -Q 1.2.3.4
> > 
> > if 1.5 is unreachable, we pick 1.1 (tos 0x0).
> > 
> > Others are not attempted.
> 
> 	Yep
> 
> > Do you consider that 'correct'?  I don't see why
> > we can use tos 0x00 but not e.g. 0x04 in that case.
> 
> 	It is illegal to return alternative routes that should
> be selected for another TOS, 192.168.1.2 should be selected
> only for packets with TOS 0x04. And TOS 0x00 in packets can not
> be matched by definition, it is used as 'match any TOS' value.

Ok.

> 	Also, without TOS restriction the 'if (next_fi != res->fi)'
> check will avoid alternatives for routes that have TOS with lower
> value, for example:
> 
> ip route add tos 0x20 via 1.1.1.1
> ip route add tos 0x20 via 2.2.2.2
> ip route add tos 0x10 via 3.3.3.3
> ip route add tos 0x10 via 4.4.4.4
> ip route add tos 0x00 via 5.5.5.5
> 
> 	fib_select_default from recent kernels always starts
> from fa_head pointing to 1.1.1.1, so if res->fi points to the
> same place the alternatives for TOS 0x20 will be considered.
> 
> 	But if res->fi selects 3.3.3.3 for TOS 0x10 the
> 'if (next_fi != res->fi)' breaks and the 4.4.4.4 alternative
> is ignored => tb_default=-1.
> 
> 	In your example in first email, TOS 0x10 does
> round-robin because it is the highest TOS and its alt
> routes are considered. Due to the bug in fib_select_default
> for lower TOS values no alt GWs are considered. That explains
> the behaviour you see.

Yes.

> > If .5 becomes available, we won't attempt it and still use 1.1/tos 0.
> 
> 	1.5 is before 1.1 in fa_head list, so it has priority
> among the reachable/valid routes.
> 
> 	The list with alternative routes should be:
> 
> - all routes with same TOS starting from the res->fi. The
> TOS check in my patch will skip routes with higher TOS value
> and then with lower TOS value that is not 0.
> 
> - if above TOS is not 0 we should consider all routes with TOS 0.
> In above example, we have 3 possible lists of alt routes:
> 
> - IP.TOS 0x20: 1.1.1.1, 2.2.2.2, 5.5.5.5
> - IP.TOS 0x10: 3.3.3.3, 4.4.4.4, 5.5.5.5
> - other TOS: 5.5.5.5
> 
> 	The funny part is that tb->tb_default is one
> and can't remember the order for every list. May be
> tb_default should be moved to fa (the first one for TOS).
> In above example, the first fa is 1.1.1.1, 3.3.3.3
> and 5.5.5.5.
> 
> 	So, I think, there is no big reason to change
> fib_detect_death. But fib_select_default needs to filter
> by slen and TOS and may be to move tb_default to fa,
> in case one wants to use TOS in alt routes.

Let me give you an example why I still think that fib_detect_death
is not optimal.

Test VM is running net-next with your proposed patch on top.

Its much better, the weird round-robin behaviour reported is gone.

The VM has two interfaces,
eth0, 192.168.7.10
eth1, 192.168.8.10

ip route del default
ip route add tos 0x0 via 192.168.7.1
ip route add tos 0x10 via 192.168.8.2

7.1 is reachable via eth0 (7.10/24)
8.2 *should* be rechable via eth1 (8.10/24)

I say *should* because I deliberately deleted this address from gateway
connected to that interface.

Now, I run

ping -Q 0x10 192.168.0.7

Packets get sent via tos 0x0.  So far, so good.

Now I add back 192.168.8.2.

But no probe takes place so packets continue to be sent via tos 0 route.

neigh_lookup returns NULL -> state is NUD_NONE -> gw is deemed unreachable

If I ping in the other direction from 192.168.8.2 packets are steered to
the 8.2/tos 0x10 gateway.

ip neigh flush nud reachable
on the test vm also makes packets take the tos 0x10 gateway.

The reverse (.8.2 available, packets sent via tos 0x10 use it, 8.2
address is removed) works: after a few seconds entry moves to STALE,
then FAILED, packets get sent via tos 0x0 gateway.

In any case, I don't want to hold this up, your proposed patch fixes
the TOS-0x10-always-round-robins issue.

Thanks for your detailed analysis & help with this.
