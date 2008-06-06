From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Fri, 6 Jun 2008 21:19:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806062037240.9424@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi> <20080605142244.GA19216@elte.hu>
 <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi> <1212708571.19522.10.camel@tng>
 <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi> <1212772293.23706.22.camel@tng>
 <20080606173339.GA30894@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Patrick McManus <mcmanus@ducksong.com>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234AbYFFSTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 14:19:13 -0400
In-Reply-To: <20080606173339.GA30894@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

...I kind of fail to follow in general in this mail which patch have been 
tested and where and when... But I understand that it's just due to number 
of tests & hosts & kernels & what-else you use and know by heart (and we 
don't do all that well :-)). But I'll try to still sort it out below...

On Fri, 6 Jun 2008, Ingo Molnar wrote:

> 
> * Patrick McManus <mcmanus@ducksong.com> wrote:
> 
> > When I apply the locking patch you (Ilpo) wrote, I cannot reproduce 
> > the error at all in the first 90 minutes of testing. I'll let the test 
> > run and update the list.
> > 
> > I'm holding out hope that Ingo's report did not have the locking patch 
> > on the distcc server end - because it certainly makes a difference for 
> > me.
> 
> Hm, the distcc server had the full 3-patch-revert from Ilpo, was that 
> supposed to fix the problem too, indirectly?

Yes, the problematic outside of locking portion shouldn't be there
without those DA changes.

> The box is running that 3-patch revert right now as well:
> 
>  phoenix:~> uptime
>   19:20:28 up  9:58,  2 users,  load average: 7.75, 13.88, 30.95
>  phoenix:~> uname -a
>  Linux phoenix 2.6.26-rc4 #2352 SMP Fri Jun 6 09:18:07 CEST 2008 x86_64 x86_64 x86_64 GNU/Linux
> 
> ... and i never saw a single hang today in the 10 hours of uptime this 
> box has. (and it built a good 500 kernel today) Nor any hang yesterday, 
> and that was a good 500 kernels too.
> 
> You can see it that the box built more than two thousand kernels in the 
> past few days alone, so it's a rather busy little bee. The other 
> testboxes built even more kernels - a quad box built and booted 2500 
> kernels:
> 
>  #define UTS_VERSION "#2524 SMP PREEMPT Fri Jun 6 19:22:21 CEST 2008"
> 
> and i never saw a hang on that box either. 
> 
> a third box has:
> 
>  titan:~> uname -a
>  Linux titan 2.6.26-rc5-00002-g737697d-dirty #2557 SMP PREEMPT Fri Jun 6 
>  19:24:00 CEST 2008 x86_64 x86_64 x86_64 GNU/Linux
> 
> (this is the one that showed the hang for the first time)
> 
> The total count of kernel bootups i did this week for -tip QA was 
> somewhere between five and ten thousand random build+bootups - and the 
> only time i got a hang was when i removed the 3-patch-revert 
> intentionally, on one of the boxes.

...and you added the locking fix there instead? Or was this a removal?

> Maybe that 3-patch-revert just makes this locking bug a bit less likely 
> to trigger, by accident?

No, part of the DEFER_ACCEPT stuff was postponed in 2.6.25..2.6.26-rc1 
timeframe (ec3c0982a2dd1e671bad8e9d26c28dcba0039d87) so that one portion 
of it ended up being added outside of the socket lock of the listening 
socket, while touching its datastructures. Without 
ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 the deferred accept related 
things happen earlier, ie., while we still are under the lock of the 
listening socket. So that particular locking bug was _introduced_ by that 
ec3c change, not made more likely or so.

...Of course software is known to have bugs, so we might always be 
(un?)lucky and hit another one and confuse... :-)

> Out tip test-setup is specialized to find 
> arch/x86 and scheduler bugs, not primarily to find networking bugs. (but 
> at this test volume, and given that it makes use of distcc, it will 
> trigger them too.)

It seems to work quite well actually for this kind of networking related 
bugs too which hardly depend on network at all :-).

> i have a rather accurate timeline of when the hang first occured, do we 
> know the timeline of the introduction of the locking bug by any chance? 
> Which commit introduced it? (Ilpo's commit log does not say it)

Ah, sorry I forgot to add that one there, it was sent quite late in the 
night and I just couldn't get sleep until sending the fix... :-) It was 
one of the reverted ones that did it:
ec3c0982a2dd1e671bad8e9d26c28dcba0039d87.

> Your test results are compelling nevertheless so i'll do a retest in any 
> case, with all boxes either running an older kernel or a kernel with the 
> locking fix.

If you want an older kernel, you would have to go basically to 2.6.25 or 
so.

To summarize. Both 3changes+1fix revert (you refer to it only as 3-patch 
revert) _and_ the locking fix I made should fix the problem (obviously 
they exclude each other). ...And end which is significant is the one which 
has LISTENing sockets (please keep this in mind if you still get the hang
and provide some info).

-- 
 i.
