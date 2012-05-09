From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] pch_gbe: Adding read memory barriers
Date: Wed, 9 May 2012 15:44:47 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F602CD848A@saturn3.aculab.com>
References: <4FA822C4.60809@gmail.com><AE90C24D6B3A694183C094C60CF0A2F602CD83CB@saturn3.aculab.com><1336569510.8274.360.camel@deadeye> <CAL2JzuxirjAnmbcV+R=MJFAi1+ayrRnM6i0Dz5poqMuG7Cxwxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<tshimizu818@gmail.com>
To: "Erwan Velu" <erwanaliasr1@gmail.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <CAL2JzuxirjAnmbcV+R=MJFAi1+ayrRnM6i0Dz5poqMuG7Cxwxg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> So I've been reading how does others drivers are working regarding
this type of message.
> While reading many drivers, I found that many does rmb() calls at this
points.
> As I'm not a linux kernel expert, I did mimic them to the result
> and it was good since the errors disappeared.

> So do you mean the patch is wrong or shall I rework only the comments
?

The problem is that barriers are not understood at all well
by most driver writers - so a lot of code is sub-optimal.

It isn't helped by the readability of the cpu documentation,
never mind some old docs that described something that an
engineer thought they might want to allow - rather than
describing what any cpus actually did/do.

For x86 cpus (amd and intel at least) reads and writes to
uncached memory and io are guaranteed to happen in instruction
order. For other cpus (sparc and ppc) such reads can
overtake writes - requiring something to force the write to
complete (eg a synchronising instruction, or maybe a readeback).

One problem is that the barrier instructions are generally
slow - so you don't want to use them where unnecessary,
however whether you need them is somewhat hardware specific
and the typical OS lists of barriers doesn't cover all the
cases - even for things that are actually compile time knowable.
Eg: what you need between a write to 'dma coherent' memory
and a write to a control register depends on whether 'dma
coherency' is implemented by disabling the cache.

For SMP there may be additional synchronisation, especially
for cached data, but for most drivers that is handled by
mutex/lock operations.

The other, and separate, issue is making sure that the compiler
itself doesn't reorder of optimise away memory cycles.
By far the best way is to mark the data (not the pointer to the
data) 'volatile', this forces the compiler to generate object
code for every variable reference in the source, and in the right
order.
Sometimes that is inappropiate, gcc's asm volatile (:::"memory")
tells the compiler that this asm statement might modify all
of memory (even though there are actually no instructions!).
This forces it to avoid having anything in a register that is
a copy of something in memory - thus enforcing the order of
memory accesses.
It can also be used to reduce register pressure within the
compiler.

In your case I suspect that the compiler has re-ordered the
reads - adding almost anything between them will change the
order.

	David
