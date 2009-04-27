From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Mon, 27 Apr 2009 12:46:48 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain>
References: <20090423210938.1501507b@nehalam> <49F146FF.5050200@cosmosbay.com> <20090424091839.6e13ebec@nehalam> <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal>
 <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu> <20090427120658.35a858bb@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090427120658.35a858bb@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 27 Apr 2009, Stephen Hemminger wrote:
>
> All those references support my argument that the lock is being
> used recursively in this case.

What's so hard between understanding the difference between "used 
recursively" and "recursive lock"?

THEY MEAN TWO TOTALLY DIFFERENT THINGS!

The fact that you don't seem to understand that is one of the things I've 
been complaining about all along.

So here's a final set of clue-bat:

Clue bat #1:

 - "can be used in a recursive context" is not the same as "is recursive".

   Analogy time: Look at "strtok_r()", and the difference between that and 
   "strtok()". "strtok_r()" can be used in a threaded environment. Does 
   that mean that 'strtok_r()' is threaded? No. When you call 
   'strtok_r()', it's still signle-threaded - it's just that it _can_ be 
   called in a threaded environment and then still has sane semantics.

   Now, replace "threaded" with "recursive". Do you get it?

Clue bat #2:

 - a lock that can count does not mean that it is recursive. 

   Counting and recursion are TWO TOTALLY DIFFERENT ISSUES. The 
   "countingness" means that there can be multiple users inside of it, and 
   that, in turn, implies that maybe it can be used in a recursive 
   context. But again, counting and recursion are not about the same thing 
   at all.

   Put another way: a read-write lock is not a "recursive lock" despite 
   the fact that you can recursively take the lock for reading. It just 
   happens to count readers, and allow more than one (from _any_ context, 
   not just from the "same context").

Clue bat #3:

 - A recursive lock is very much _about_ recursion. It is explicitly about 
   the fact that the _same_ thread re-enters the lock, not about another 
   thread being in the locked region at the same time.

   See the difference? Big, big difference. A recursive lock will lock out 
   other thread contexts, even if it allows the current one to recurse. 
   Notice how the _only_ thing a recursive lock allows is that recursive 
   behavior, and nothing else.

   IOW, a "recursive lock" is explicitly designed for recursion. But that 
   doesn't mean that recursive algorithms cannot use functions that 
   aren't.

   Can you use "memcpy()" in a recursive algorithm? Yes. Does that mean 
   that "memcpy()" is suddenly a "recursive memory copy"? No.

   See the difference?

Clue bat #3:

 - if you do not understand the difference between these two things, don't 
   then try to claim that somebody _else_ who does understand it is 
   "deluding himself".

   Analogy time: Ethernet and a modem line can both get you on the
   internet. Now, let's say that Mr Peter Paste-Eater has heard of 
   ethernet, and knows you can get on the internet with an ethernet 
   connection, but he happens to use a modem line to do it.

   Now, Peter Paste-Eater talks to you, and tells you he is connecting to 
   the internet with ethernet, and proudly shows you his serial line and 
   modem, and tells you how he uses ethernet to get onto the internet. You 
   correct him, and tell him it's not ethernet.  He argues for several 
   days about how he gets on the internet, and that it must thus be 
   ethernet, and that you're obviously just "deluding yourself".

Now, can you see why people react badly to you talking about "recursive 
locks"? You're acting like Peter Paste-Eater calling his serial line 
ethernet. The fact that two _different_ things can be used for the same 
end result DOES NOT MAKE THEM THE SAME THING.

In other words:

 - "Recursive locks" are different from reader-writer locks.

 - The ability to count is different from recursion, although in a lock it 
   can obviously be _related_ to whether it can be used in a recursive 
   environment or not. If you don't have a counter, you probably cannot 
   recurse, but it's also not true that a counter implies that you always 
   can.

   A traditional counting lock is the old-fasioned 'semaphore' we have, 
   where the count allows for more than just simple mutual exclusion, and 
   is used when you might want to allow concurrency, but need to limit it
   to some number 'n' (although, almost always, n==1)

 - What the netfilter code wants is simply not a recursive lock. It wants 
   a form of locking that allows recursive _use_, but as mentioned, that 
   is totally and utterly irrelevant from what we call it.

   You _could_ use a recursive lock for it. BUT NONE OF THE PATCHES THAT 
   HAVE EVER BEEN POSTED HAVE BEEN RECURSIVE LOCKS! Nada. None. Zero. 
   Zilch.

So don't talk about recursive locks.

Get it? Finally? Or are you going to continue to be that Paste-Eater guy 
who refuses to understand that he is talking about something else than 
ethernet?

			Linus
