From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Wed, 19 Jan 2005 18:22:22 +0100
Message-ID: <20050119172222.GC26856@postel.suug.ch>
References: <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118120737.I15303@almesberger.net> <20050119140804.GZ26856@postel.suug.ch> <20050119133353.H15303@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Werner Almesberger <werner@almesberger.net>
Content-Disposition: inline
In-Reply-To: <20050119133353.H15303@almesberger.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Werner Almesberger <20050119133353.H15303@almesberger.net> 2005-01-19 13:33
> Thomas Graf wrote:
> > filtering. The mistake they did was to completely rely on the
> > state machine for even the most simple packet classification
> > problems.
> 
> I don't see much of a performance problem: once you have a nice
> FSM with single-bit decisions, you can quite easily construct
> various efficient matcher stages. You can even prepare (or
> compile on the fly) suitable specialized matchers. If doing the
> matching in hardware, you may even use just the FSM.

I guess we're speaking of slightly different FSMs. I assume yours
is 100% hardcoded and only works for static patterns? Those you
could also implement in FPGAs quite easly.

Assuming one needs 2K rules for classyfing on top of some kind of
dynamic header, assuming IPv4 and IPv6 for now. The static FSMs
needs to parse the headers everytime which isn't much of a
problem with IPv4 but gets really expensive with IPv6 even with
specialized instructions to parse through the options. Sure,
one can put packets into classes and build filters on top of it,
but once splitted one can never merge them together again.

I've seen many static FSMs based on BPF, which I assume is
what you're talking about. _All_ of them break in practical
situations no longer matching the theory.

The only way I see to solve this is to put more logic into the
state machine. Give the state machine the chance to share
data, that's why you need local and global registers. To really
make use of it you want to be able to modify the data and thus
need arithmetic instructions. I know, I'm pretty lonely on this
path but I think this is the way to go.

> You need arithmetic only for pointers, and there it's basically
> mask and shift. You can do surprisingly well without loops. E.g.
> tcng doesn't have loops. (Although they would be a nice addition,
> particularly if you move more in the direction of firewalls.)

How do you parse IPv6 options? Specialized classifiers? mask and
shift might be enough to transform IHL but it won't be sufficent
for higher protocols.

> Huh ? Probably too complex already. Also, if you're in software,
> you may very well compile your own helper modules on the fly.
> tcng has this as a proof-of-concept with the "C" target.

Of course stack frames are only necessary if you introduce variables
and they may only exist in user space and then eliminated for
the kernel state machine.

> > I think the interactive mode is very useful for maintaince.
> 
> Hmm, I kind of doubt it. You're quicker with your editor, just
> changing that line. What you need is a nice way for updating the
> in-kernel configuration without loss of state.

I'm talking about maintaince stuff in terms of checking statistics,
inspecting your filter tree, etc. I fully aggree that the construction
of the configuration belongs into a text editor.

> You also need some "handles" where you can attach automated
> rule generation and/or modification. That's something tcng doesn't
> support very well.

I don't get this.

> Ah, but you know that that first thing tcng does when it sees an
> "if" is that it rips the expression apart and then works on
> "anonymous" fields or even single bits ?

Sure, this is the way to go.

> I think the contrary is the case :-) If things get complex
> enough, you'll want to dry-run them in tcsim or such. It's
> really not very different from programming - if I want to
> change some complicated expression, I just edit it. It wouldn't
> occur to me to tweak assembler instructions, no matter how
> convenient the assembler is.

I agreed, I'm solely and only talking about getting help while
constructing a filter. With all the new extensions comming in
the construction will get more complex with logic expressions,
various small classification tools and one needs to look up
their parameters etc. I think tcng will never be able to 100%
support all of them, because of their easy usage many will
write their own so we might see dozens of new ones like in
netfilter.
