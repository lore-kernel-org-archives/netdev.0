From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Wed, 19 Jan 2005 15:08:04 +0100
Message-ID: <20050119140804.GZ26856@postel.suug.ch>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118120737.I15303@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Werner Almesberger <werner@almesberger.net>
Content-Disposition: inline
In-Reply-To: <20050118120737.I15303@almesberger.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Werner Almesberger <20050118120737.I15303@almesberger.net> 2005-01-18 12:07
> There's also the issue of classifier construction: while I think
> that the language for this is near-perfect, the internal
> processing is scary at best, and doesn't produce very nice
> results. I dream of a new classifier works on a state machine
> constructed from single-bit classification decisions, but the
> graph theory required for ordering them properly is a bit above
> me. (Construction of an unordered and redundant FSM is almost
> trivial - tcng can already do this.)

I did some experiments in this direction where one could write
code in c-like syntax which is transformed into an insturction
set understood by the state machine in the kernel. Similiar to
BPF but not focused on parsing but rather on classification.

The main disadvantage is speed, the idea isn't new and has been
implemented various times already. It didn't performen well
enough and everyone switched to the current way of packet
filtering. The mistake they did was to completely rely on the
state machine for even the most simple packet classification
problems. Now that we have specialized classifiers for often
used filtering problems we can pick up the idea again and add
it _additionaly_ for all these cases that the specialized
classifiers do not cover yet.

Basically to get a state machine capable solving almost every
problem the following parts must be provided:

 - a small instruction set for basic operations to implement
   arithmetic, branching, and loops.
 - some abstract way to access data from various sources, be it
   packet data, constant values, registers, or meta data.
 - an advanced instruction set to improve the performance
   of the state machine for often used patterns, e.g.
   find-byte, classify, byte order transformations, header
   length calculation shortcuts, find-next-ipv6-opt, etc.
 - a good optimizer able to transform multiple simple
   instructions into a larger instruction, because the main
   bottleneck in a software state machine is aver number of
   instructions needed to process to get to a result.
 - stack frames to allow building libraries for often used
   problem not worth making a single instruction out of it.

> I'm not so sure about interactive use of "tc". In general, a
> single configuration line has no meaning. You almost always
> need a lot more context to understand what it does.

I think the interactive mode is very useful for maintaince. I
agree with you that for the initial script a higher language at
the level of the big picture is more apppropriate. However, we're
moving slowly towards new aspects with the actionts bits and
also ematches, things get more complicated and less rules are
required. Therefore in my opinion it would be nice to have
an interactive shell assisting you with the initial construction.

It also heavly depends on the usage of tc et al, the normal
dscp, port, and address classification schemas perfectly fit
into tcng and the big picture is most important. OTOH, as
soon as we get to more complex classifiction and the more
classification possibilities we get the more important it is
to have some way to interactively construct single filters.

So in my opinion the whole problem needs be divided into
two parts, the logical big picture part best solved with
tcng were logic groupings count more than single bits in the
packet and the interactive shell with context help to assist
in creating complex filters and do the maintaince jobs.
Combined together the result is a more useable interface.

> Think of the interactive BASIC systems on ancient PCs. There,
> you would enter/edit/remove lines by their number. Now, would
> you want to use something like this for C ? Me, I prefer a
> free-format text editor :-)

Yes but I think you also like context based assistance tools
such as cscope where you can get help based on your current
context, e.g. symbols, types, references.

> An interactive help system that could be called from an
> editor, e.g. when editing tcng configurations, would certainly
> be a nice touch. But that's an orthogonal issue. A set of man,
> info, etc. pages would serve nicely, too.

To make it really useful the help system needs to parse your
current line to find out the context. Assuming we implement
a interactive shell like I described in a earlier post, we could
add a parameter to put iproute2 into explanation mode not
doing anything put parse the input and print a help text based
on it. It shouldn't be too hard to tell your editor to call
it.

Thoughts?
