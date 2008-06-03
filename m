From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Wed, 4 Jun 2008 00:46:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
References: <20080529084524.GA24892@elte.hu> <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi>
 <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu>
 <20080531060947.GA26441@elte.hu> <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi> <20080531125428.GA22111@elte.hu>
 <Pine.LNX.4.64.0805311555570.2329@wrl-59.cs.helsinki.fi> <20080531163501.GB22607@elte.hu>
 <20080603094057.GA29480@elte.hu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-742855239-1212522473=:3474"
Cc: Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Patrick McManus <mcmanus@ducksong.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44550 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbYFCVq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 17:46:58 -0400
In-Reply-To: <20080603094057.GA29480@elte.hu>
Content-ID: <Pine.LNX.4.64.0806040045510.3474@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-742855239-1212522473=:3474
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806032248131.3474@wrl-59.cs.helsinki.fi>

On Tue, 3 Jun 2008, Ingo Molnar wrote:

> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > > ...setsockopt(listenfd, SOL_TCP, TCP_DEFER_ACCEPT, &val, 
> > > sizeof(val)) seems to be the magic trick that is interestion here.
> > 
> > seems to be used:
> > 
> >  22003 write(3, "distccd[22003] (dcc_listen_by_ad"..., 62) = 62
> >  22003 listen(4, 10)                     = 0
> >  22003 setsockopt(4, SOL_TCP, TCP_DEFER_ACCEPT, [1], 4) = 0
> > 
> > i'll queue up your reverts for testing in -tip.
> 
> update: your 3 reverts in tip/out-of-tree [commit dad98991c] definitely 
> fixed the hangs!

...It wasn't exactly out-of-tree, Evgeniy fixed a problem that was found
in "TCP_DEFER_ACCEPT updates - process as established", perhaps it just 
wasn't in your testing tree yet.

$ git-log -n 1 --pretty=full 9ae27e0adbf471c7a6b80102e38e1d5a346b3b38 | 
grep "Commit:"
Commit: David S. Miller <davem@davemloft.net>

> Here is the testing i did:
> 
> first i ran about 500+ successful iterations on the affected testboxes 
> with your revert patch applied, on multiple systems.

Are you sure this is enough to conclude the results? Seems quite small 
number to me to rule out luck. Especially considering that it was some 
amount of time in the tree already until you noticed it for the first 
time.

Anyway, nice that it seems to be helping. It was almost the only 
possibility on TCP side, I don't think there were any other state machine 
related changes. So it wasn't just "random revert" in that sense like you 
were implying :-), I just didn't have any theory how it would cause the 
problem... ...I even first disregarded DA that because of timeline 
in-exactness and because I wrongly assumed that distcc probably won't use 
it anyway, but then I checked later on and found out that it was present 
at least in the source I had lying around.

Anyway, it might be that the revert was a bit overkill, I'm not fully sure 
if 539fae and e4c7884 need to be reverted to fix it since main changes 
are in ec3c098. I just didn't want to take chances at first and put them 
all to the revert list.

> Then today, without 
> changing anything else on one of the testsystems i reverted your revert 
> on that single system. After about an hour of testing, in 20 iterations 
> i got a hang again over localhost:
> 
>  titan:~> netstat -nt
>  Active Internet connections (w/o servers)
>  Proto Recv-Q Send-Q Local Address               Foreign Address             State
>  tcp        0 174592 10.0.1.14:34710             10.0.1.14:3632              ESTABLISHED
>  tcp    72145      0 10.0.1.14:3632              10.0.1.14:34710             ESTABLISHED
> 
> so i hereby conclude that your revert works :) I've repeated the commit 
> below that resolves this nasty regression.

...I couldn't immediately find anything obviously wrong with those changes 
but the patch below might be worth of a try (without the revert of 
course). If it ever spits out that WARN_ON for you, we were playing with 
fire too much and it's better to return on the safe side there...

-- 
 i.

[PATCH] tcp DEFER_ACCEPT: see if header prediction got turned on

If header prediction is turned on under some circumstances,
DA can deadlock though I have great trouble in figuring out
how it could ever happen while ending up into that else
branch (but I've been wrong before as well :-)).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c9454f0..0d9a3fe 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4595,6 +4595,9 @@ static int tcp_defer_accept_check(struct sock *sk)
 			   tp->defer_tcp_accept.listen_sk->sk_state != TCP_LISTEN) {
 			tcp_reset(sk);
 			return -1;
+		} else {
+			WARN_ON(tp->pred_flags);
+			tp->pred_flags = 0;
 		}
 	}
 	return 0;
-- 
1.5.2.2
---696208474-742855239-1212522473=:3474--
