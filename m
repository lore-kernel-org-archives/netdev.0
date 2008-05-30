From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 00:11:32 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805302105170.1761@wrl-59.cs.helsinki.fi>
References: <48402BD7.2080705@madrabbit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ray Lee <ray-lk@madrabbit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59114 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231AbYE3VOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 17:14:55 -0400
In-Reply-To: <48402BD7.2080705@madrabbit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ray,

...I reorganized it a bit.

On Fri, 30 May 2008, Ray Lee wrote:

> (Oy, resending. Freakin' gmail; sorry for the base64 encoded noise.)
> 
> On Mon, May 26, 2008 at 6:28 AM, Ilpo <ilpo.jarvinen@helsinki.fi> wrote:
> > On Mon, 26 May 2008, Ingo Molnar wrote:

> > >
> > > on a previously reliable machine. That connection has been stuck for 9
> > > hours so it does not time out, etc. - and the distcc run that goes over
> > > that connection is stuck as well.
> > >
> > > kernel config is attached.
> > >
> > > in terms of debugging there's not much i can do i'm afraid. It's not
> > > possible to get a tcpdump of this incident, given the extreme amount of
> > > load these testboxes handle.
> >
> > ...but you can still tcpdump that particular flow once the situation is
> > discovered to see if TCP still tries to do something, no? One needs to
> > tcpdump couple of minutes at minimum. Also please get /proc/net/tcp for
> > that flow around the same time.
> >
> > > This problem started sometime around rc3
> > > and it occured on two boxes (on a laptop and on a desktop), both are SMP
> > > Core2Duo based systems. I never saw this problem before on thousands of
> > > similar bootups, so i'm 99.9% sure the bug is either new or became
> > > easier to trigger.
> > >
> > > It's not possible to bisect it as it needs up to 12 hours of heavy
> > > workload to trigger. The incident happened about 5 times since the first
> > > incident a couple of days ago - 4 times on one box and once on another
> > > box. The first failing head i became aware of was 78b58e549a3098. (-tip
> > > has other changes beyond -git but changes nothing in networking.)
> 
> Okay, but in some sense you've already bisected this somewhat. I'm
> assuming that your testing uses the latest tip and is refreshed daily.
> 
> If that's the case, then I would (possibly naively) expect the culprit
> to show up in a:
>  git log -p v2.6.26-rc1..78b58e549a3098
>  net/{compat.c,core,ipv4,netfilter,packet,sched,socket.c}
>
> There are only a few commits in there that appear to touch network behavior:
> 
>  79d44516b4b178ffb6e2159c75584cfcfc097914
>  a1c1f281b84a751fdb5ff919da3b09df7297619f
>  62ab22278308a40bcb7f4079e9719ab8b7fe11b5

I think you miss here a lot of clues. First I suspected my FRTO changes as 
well but later discoveries pointed elsewhere... Those fixes are for sender 
behavior, which is not the problem here. It's just that once you have flow 
control, the sending TCP obviously gets stuck once all "buffering" 
capacity downstream is used up, and that's _correct_ sender behavior 
rather than a bug in itself. Therefore both FRTO and Ingo's theory 
about Cubic (though his test with 2.6.25 will definately seems currently a 
useful result with or without Cubic :-)) completely fails to explain why 
receiver didn't read the portion that was sitting there waiting (see 
below).

Also, I think you missed one (though it's commit message seems to say 
that it isn't relevant here but who knows):

1ac06e0306d0192a7a4d9ea1c9e06d355ce7e7d3

...but still that hardly would explains why the receiver queue was not 
consumed.

> Reverting just those three and running overnight might provide a clue.

Of course Ingo could easily test without FRTO by playing with the sysctl, 
all those three patches are not in use if tcp_frto is set to zero (he 
probably didn't because I "cancelled" that request...?), but I find it 
very unlikely to help any.

> OTOH, I'm in no way a net/ expert,

Me neither, I just know some about TCP, so I probably have as much 
problems as you do in understanding this :-).

> so if you are already working a
> debugging strategy then feel free to ignore this. I'm only piping up
> as it appears that the troubleshooting has stalled.

...Thanks, I definately don't mind any help here. Though it probably 
partially seems completely "stalled" because figuring this out leads me 
more and more to a territory which is previously unknown to me (plus the 
time constraints I have), not that it's a bad thing to learn & read a lot 
of other code too but it just takes more time and I cannot do anything 
while off-line like I could with a code that I'm familiar with.

Would you perhaps have any clue about two clearly strange things I listed 
here:
  http://marc.info/?l=linux-kernel&m=121207001329497&w=2

...

> > > in an overnight -tip testruns that is based on recent -git i got two
> > > stuck TCP connections:

...i.e., one connection, two endpoints:

> > > Active Internet connections (w/o servers)
> > > Proto Recv-Q Send-Q Local Address               Foreign Address
> > > State
> > > tcp        0 174592 10.0.1.14:58015             10.0.1.14:3632  ESTABLISHED
> > > tcp    72134      0 10.0.1.14:3632              10.0.1.14:58015 ESTABLISHED

             ^^^^^

Can you perhaps find/guess/think some explanation for this _receiver 
queue_...? This was a trick question :-), as we already know that the 
receiving process is no longer there and therefore obviously won't be 
reading anything anymore. But that opened another question, why TCP is 
then still in ESTABLISHED as orphaned TCP shouldn't be in establised state 
anymore, tcp_close should have changed the state (either at close or at 
process exit). I guess once it becomes known why tcp_close either wasn't 
called at all or it didn't change the state of the flow (it's quite 
simple, see for yourself), the cause of the bug is found (it might even be 
that the process went away when it shouldn't have, either a bookkeeping 
bug somewhere or real death, or something along those lines).

I was thinking of storing some info about old owner while orphaning to 
struct sock and collecting that once one of the flows gets stuck but
this requires me to figure a lot unknowns out before I can just code
it.

-- 
 i.
