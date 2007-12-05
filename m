From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP event tracking via netlink...
Date: Thu, 6 Dec 2007 01:18:28 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712051533050.3119@kivilampi-30.cs.helsinki.fi>
References: <20071205.053031.87154402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59903 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846AbXLEXSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 18:18:31 -0500
In-Reply-To: <20071205.053031.87154402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Dec 2007, David Miller wrote:

> Ilpo, I was pondering the kind of debugging one does to find
> congestion control issues and even SACK bugs and it's currently too
> painful because there is no standard way to track state changes.

That's definately true.

> I assume you're using something like carefully crafted printk's,
> kprobes, or even ad-hoc statistic counters.  That's what I used to do
> :-)

No, that's not at all what I do :-). I usually look time-seq graphs 
expect for the cases when I just find things out by reading code (or
by just thinking of it). I'm so used to all things in the graphs that
I can quite easily spot any inconsistencies & TCP events and then look 
interesting parts in greater detail, very rarely something remains 
uncertain... However, instead of directly going to printks, etc. I almost 
always read the code first (usually it's not just couple of lines but tens 
of potential TCP execution paths involving more than a handful of 
functions to check what the end result would be). This has a nice 
side-effect that other things tend to show up as well. Only when things 
get nasty and I cannot figure out what it does wrong, only then I add 
specially placed ad-hoc printks.

One trick I also use, is to get the vars of the relevant flow from 
/proc/net/tcp in a while loop but it only works for my case because
I use links that are slow (even a small value sleep in the loop does
not hide much).

For other people reports, I occasionally have to write a validator patches 
like you might have notice because in a typical miscount case our 
BUG_TRAPs are too late because they occur only after outstanding window 
becomes zero that might be very distant point in time already from the 
cause.

Also, I'm planning an experiment with those markers thing to see if 
they are of any use when trying to gather some latency data about 
SACK processing because they seem light weight enough to not be 
disturbing.

> With that in mind it occurred to me that we might want to do something
> like a state change event generator.
> 
> Basically some application or even a daemon listens on this generic
> netlink socket family we create.  The header of each event packet
> indicates what socket the event is for and then there is some state
> information.
> 
> Then you can look at a tcpdump and this state dump side by side and
> see what the kernel decided to do.

Much of the info is available in tcpdump already, it's just hard to read 
without graphing it first because there are some many overlapping things 
to track in two-dimensional space.

...But yes, I have to admit that couple of problems come to my mind
where having some variable from tcp_sock would have made the problem
more obvious.

> Now there is the question of granularity.
> 
> A very important consideration in this is that we want this thing to
> be enabled in the distributions, therefore it must be cheap.  Perhaps
> one test at the end of the packet input processing.

Not sure what is the benefit of having distributions with it because 
those people hardly report problems anyway to here, they're just too 
happy with TCP performance unless we print something to their logs,
which implies that we must setup a *_ON() condition :-(.

Yes, often negleted problem is that most people are just too happy even 
something like TCP Tahoe or something as prehistoric. I've been surprised 
how badly TCP can break without nobody complaining as long as it doesn't 
crash (even any of the devs). Two key things seems to surface the most of 
the TCP related bugs: research people really staring at strange packet 
patterns (or code) and automatic WARN/BUG_ON checks triggered reports.
The latter reports include also corner cases which nobody would otherwise 
ever noticed (or at least before Linus releases 3.0 :-/).

IMHO, those invariant WARN/BUG_ON are the only alternative that scales to 
normal users well enough. The checks are simple enough so that it can be 
always on and then we just happen to print something to their log, and 
that's offensive enough for somebody to come up with a report... ;-)

> So I say we pick some state to track (perhaps start with tcp_info)
> and just push that at the end of every packet input run.  Also,
> we add some minimal filtering capability (match on specific IP
> address and/or port, for example).
>
> Maybe if we want to get really fancy we can have some more-expensive
> debug mode where detailed specific events get generated via some
> macros we can scatter all over the place.
>
> This won't be useful for general user problem analysis, but it will be 
> excellent for developers.

I would say that it to be generic enough, most function entrys and exits
should have to be covered because the need varies a lot, the processing in 
general is so complex that things would get too easily shadowed otherwise! 
In addition we need expensive mode++ which goes all the way down to the 
dirty details of the write queue, they're now dirtier than ever because 
the queue is split I dared to do.

Some problems are simply such that things cannot be accurately verified 
without high processing overhead until it's far too late (eg skb bits vs 
*_out counters). Maybe we should start to build an expensive state 
validator as well which would automatically check invariants of the write 
queue and tcp_sock in a straight forward, unoptimized manner? That would 
definately do a lot of work for us, just ask people to turn it on and it 
spits out everything that went wrong :-) (unless they really depend on 
very high-speed things and are therefore unhappy if we scan thousands of 
packets unnecessarily per ACK :-)). ...Early enough! ...That would work 
also for distros but there's always human judgement needed to decide 
whether the bug reporter will be happy when his TCP processing does no 
longer scale ;-).

For the simpler thing, why not just taking all TCP functions and doing 
some automated tool using kprobes to collect the information we need 
through the sk/tp available on almost every function call, some TCP 
specific code could then easily produce what we want from it? Ah, this is 
almost done already as noted by Stephen, would just need some 
generalization to be pluggable to other functions as well and more 
variables.

> Let me know if you think this is useful enough and I'll work on
> an implementation we can start playing with.

...Hopefully you found any of my comments useful.


-- 
 i.
