From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Mon, 27 Apr 2009 15:24:52 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904271506530.22156@localhost.localdomain>
References: <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu>
 <20090427120658.35a858bb@nehalam> <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain> <20090427203616.GB3836@ioremap.net> <alpine.LFD.2.00.0904271340400.22156@localhost.localdomain> <20090427144054.1fb9b7a6@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090427144054.1fb9b7a6@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 27 Apr 2009, Stephen Hemminger wrote:
>
> The part that concerns me is that the reader lock used in a nested manner on
> same cpu may still be broken on -rt.

I think that's a valid concern, and I don't actually object to not using a 
rwlock, but using the "explicit counting + spinlock" that we had at one 
point. It _might_ even be faster, since a spinlock can be faster than a 
rwlock, and the (rare) case where you recurse you can then avoid the 
atomic entirely.

But EVEN IF YOU DO THAT, it's still wrong to call it a "recursive lock". 
Because it still wouldn't be one.

That's kind of my point, and always has been. It was why I objected to the 
original patch description by Dumazet. It wasn't a recursive lock back 
then _either_. For all the reasons I tried to explain to you, and you seem 
to not care about.

Btw, if you do use the "explicit count" case, then please please please 
make sure it's documented and bug-free. And dammit, correct documentation 
in this case very much talks about how it is _not_ a "recursive lock", but 
a spinlock that then has an explicit counter that avoids taking the lock 
entirely in one very specific path (that happens to be recursive).

The thing is, using a rwlock kind of implicitly documents all of that, 
because you can tell somebody who doesn't even read the code that it's a 
"per-cpu rwlock", and they then know what the semantics are (given that 
they know the kernel semantics for locking in the first place).

But once you start doing your own locking rules, you really have to 
explain why it works, and what it does. And you do have to be very 
careful, because it's so easy to get locking wrong.

> I don't care. I don't care. Don't you get the point yet.

If you don't care about the naming, then use the right one. 

And if you don't care about the naming, why do you then say I'm deluding 
myself, when I'm _correct_, and I _do_ happen to care about correct 
naming.

Locking really is important.  Code that gets locking wrong breaks in
really subtle and nasty ways.  And it sadly tends to "work" in testing,
since the breakage cases require just the right timing.  So locking
should be robust and as "obviously correct" as possible.

And naming really is important.  Misnaming things makes people make
assumptions that aren't true.  If you talk about recursive locks, it
should be reasonable that people who know how recursive locks work would
then make assumptions about them.  If the code then doesn't actually
match those rules, that's bad. 

It's like having a comment in front of a piece of code that says something 
totally different than what the code actually does. It's _bad_. That's why 
naming matters so much - because naming is commentary.  If you mis-name 
things on purpose, it's simply a bug.

Do _you_ get the point?

You _do_ care about bugs, don't you?

			Linus
