From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Wed, 19 Jan 2005 13:33:53 -0300
Message-ID: <20050119133353.H15303@almesberger.net>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118120737.I15303@almesberger.net> <20050119140804.GZ26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050119140804.GZ26856@postel.suug.ch>; from tgraf@suug.ch on Wed, Jan 19, 2005 at 03:08:04PM +0100
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> filtering. The mistake they did was to completely rely on the
> state machine for even the most simple packet classification
> problems.

I don't see much of a performance problem: once you have a nice
FSM with single-bit decisions, you can quite easily construct
various efficient matcher stages. You can even prepare (or
compile on the fly) suitable specialized matchers. If doing the
matching in hardware, you may even use just the FSM.

> Basically to get a state machine capable solving almost every
> problem the following parts must be provided:
> 
>  - a small instruction set for basic operations to implement
>    arithmetic, branching, and loops.

You need arithmetic only for pointers, and there it's basically
mask and shift. You can do surprisingly well without loops. E.g.
tcng doesn't have loops. (Although they would be a nice addition,
particularly if you move more in the direction of firewalls.)

>  - some abstract way to access data from various sources, be it
>    packet data, constant values, registers, or meta data.

You can just define some "magic" offsets, e.g. negative ones.

>  - an advanced instruction set to improve the performance
>    of the state machine for often used patterns, e.g.
>    find-byte, classify, byte order transformations, header
>    length calculation shortcuts, find-next-ipv6-opt, etc.

This can be nicely separated and put into post-processing stages.
Most of the time, you probably don't notice a difference anyway.

>  - a good optimizer able to transform multiple simple
>    instructions into a larger instruction, because the main
>    bottleneck in a software state machine is aver number of
>    instructions needed to process to get to a result.

Yes, that would be part of the post-processing: combine things,
detect patterns, and emit the right high-level construct.

>  - stack frames to allow building libraries for often used
>    problem not worth making a single instruction out of it.

Huh ? Probably too complex already. Also, if you're in software,
you may very well compile your own helper modules on the fly.
tcng has this as a proof-of-concept with the "C" target.

> I think the interactive mode is very useful for maintaince.

Hmm, I kind of doubt it. You're quicker with your editor, just
changing that line. What you need is a nice way for updating the
in-kernel configuration without loss of state.

You also need some "handles" where you can attach automated
rule generation and/or modification. That's something tcng doesn't
support very well.

> It also heavly depends on the usage of tc et al, the normal
> dscp, port, and address classification schemas perfectly fit
> into tcng and the big picture is most important.

Ah, but you know that that first thing tcng does when it sees an
"if" is that it rips the expression apart and then works on
"anonymous" fields or even single bits ?

> soon as we get to more complex classifiction and the more
> classification possibilities we get the more important it is
> to have some way to interactively construct single filters.

I think the contrary is the case :-) If things get complex
enough, you'll want to dry-run them in tcsim or such. It's
really not very different from programming - if I want to
change some complicated expression, I just edit it. It wouldn't
occur to me to tweak assembler instructions, no matter how
convenient the assembler is.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
