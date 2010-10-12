From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Tue, 12 Oct 2010 10:10:22 +0000
Message-ID: <20101012101022.GA8578@ff.dom.local>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com> <4CB1A22B.9090701@gmail.com> <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Steven Brudenell <steven.brudenell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38122 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126Ab0JLKLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 06:11:19 -0400
Received: by bwz15 with SMTP id 15so2278912bwz.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 03:10:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 11, 2010 at 06:27:25PM -0400, Steven Brudenell wrote:
> > I'm not sure you checked how the "burst" works, and doubt it could
> > help you here. Anyway, do you think: rate 2KB/s with burst 5GB
> > config would be useful for you?
> 
> i actually really do want something like 2KB/s with 5GB burst
> (modifying parameters such that burst + rate * 30 days <= 5GB, but you
> get the idea). but this isn't possible given the implementation:
> 
> i see that overall, virtual "tokens" map to "scheduler ticks", where a
> "scheduler tick" is 64ns. (net/sched/sch_{tbf,htb}.c,
> include/net/pkt_sched.h -- these 64ns units are called "ticks" despite
> being unrelated to HZ). the "burst" parameter is also stored and
> passed from userspace as a u32. so, the maximum configurable burst in
> both cases is rate * 275s, since we can only track 275s worth of
> "scheduler ticks" in a u32 ( (1<<32) / NSEC_PER_SEC * 64 =~ 275s ).

Right. It was a compromise to allow higher rates for "common" use
without u64 changes. It can be tuned with PSCHED_SHIFT yet to give you
more burst, but I doubt tbf/htb authors expected monthly values here.

> 
> > My proposal is you don't bother with 1) and 2), but first do the
> > hack in tbf or htb directly, using or omitting rate tables, how
> > you like, and test this idea.
> 
> i'll give it a shot, though given that i hate writing the same code
> twice, i would prefer to know the right way to change netlink before i
> write a functional test.
> 
> due to the implementation coupling i don't see any way to make any
> permanent change *without* changing the netlink interface -- even
> changing that u32 to a u64, which would only need to be a u64 in
> userspace because userspace does the munging today!
> 
> (what's worse, today userspace has to specify the full rate table over
> netlink, instead of just specifying the rate and having the kernel
> driver compute the table or whatever other data structure it deems
> necessary. i think decoupling interface from implementation is a
> worthy goal by itself. if they were decoupled, i could have just coded
> a patch and not bothered y'all in the first place....)
> 
> > But it seems the right way is to collect monthly stats with some
> > userspace tool and change qdisc config dynamically. You might
> > look at network admins' lists for small ISPs exemplary scripts
> > doing such nasty things to their users, or have a look at ppp
> > accounting tools.
> 
> <non technical sidetrack>
> i disagree outright that a userspace tool is the "right" way to solve
> my constraints.
> 
> my constraints are:
> 1) i need to guarantee i never ever go over the monthly transfer limit
> (bad experiences with Comcast... you can check out of Red Tape Hotel
> any time you like, but you can never leave).
> 2) i want to be able to transfer short bursts at top speed whenever
> possible (that's what i'm paying for in the first place).
> 3) i need to ration transfer usage so i am never stuck in a situation
> of being limited to snail speeds until the end of the month (on a
> Comcast connection in my area, i can reasonably sustain 2MB/sec
> downstream, which eats 250GB in ~36 hours, so this constraint becomes
> important).
> 
> tbf with a large burst size seems ideal for my constraints. i can't
> quantify this, but it seems like no simpler strategy satisfies the
> constraints well and no more complex strategy is necessary. i think
> any userspace solution i could write would end up trying to emulate
> tbf with large burst.
> 
> a userspace tool updating qdisc parameters, even if run in an infinite
> loop, would always have a big chunky time resolution compared to an
> inline packet shaper (which is important for #2, and for #1 to a
> degree). i could write a packet shaper in userspace, but this does not
> make sense to given that kernel qos already exists, and already has a
> tbf implementation that just needs a little love.
> </non technical sidetrack>
> 
> given all that, i'd just like to know
> 
> 1) whether it's forbidden or bad to do floating point math in a packet
> scheduler, and

Yes, it's not allowed according to Documentation/HOWTO. Btw, as you
can see e.g. in sch_hfsc comments, 64-bit division is avoided too.

> 
> 2) the best way to go about making breaking changes to netlink.

I can only say there is no versioning, but backward compatibility
is crucial, so you need to do some tricks or data duplication.
You could probably try to get opinions about it with an RFC on
moving tbf and htb schedulers to 64 bits if you're interested
(decoupling it from your specific burst problem).

Jarek P.
