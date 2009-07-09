From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netpoll: Fix carrier detection for drivers that are
 using phylib
Date: Thu, 09 Jul 2009 07:52:45 -0500
Message-ID: <1247143965.21295.867.camel@calx>
References: <20090707235812.GA12824@oksana.dev.rtsoft.ru>
	 <20090708005000.GA12380@redhat.com> <1247034263.9777.24.camel@twins>
	 <alpine.LFD.2.01.0907080907210.3210@localhost.localdomain>
	 <20090708141024.f8b581c5.akpm@linux-foundation.org>
	 <20090708213331.GA9346@oksana.dev.rtsoft.ru>
	 <20090708144744.5555b88d.akpm@linux-foundation.org>
	 <20090708222003.GA12318@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, a.p.zijlstra@chello.nl,
	oleg@redhat.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:54575 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759600AbZGIMyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 08:54:23 -0400
In-Reply-To: <20090708222003.GA12318@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-09 at 02:20 +0400, Anton Vorontsov wrote:
> Using early netconsole and gianfar driver this error pops up:
> 
>   netconsole: timeout waiting for carrier
> 
> It appears that net/core/netpoll.c:netpoll_setup() is using
> cond_resched() in a loop waiting for a carrier.
> 
> The thing is that cond_resched() is a no-op when system_state !=
> SYSTEM_RUNNING, and so drivers/net/phy/phy.c's state_queue is never
> scheduled, therefore link detection doesn't work.
> 
> I belive that the main problem is in cond_resched()[1], but despite
> how the cond_resched() story ends, it might be a good idea to call
> msleep(1) instead of cond_resched(), as suggested by Andrew Morton.
> 
> [1] http://lkml.org/lkml/2009/7/7/463
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
> 
> On Wed, Jul 08, 2009 at 02:47:44PM -0700, Andrew Morton wrote:
> > (belatedly cc'ing netdev)
> > 
> > Original diagnosis:
> > 
> > : Using early netconsole and gianfar driver this error pops up:
> > : 
> > :   netconsole: timeout waiting for carrier
> > : 
> > : It appears that net/core/netpoll.c:netpoll_setup() is using
> > : cond_resched() in a loop waiting for a carrier.
> > : 
> > : The thing is that cond_resched() is a no-op when system_state !=
> > : SYSTEM_RUNNING, and so drivers/net/phy/phy.c's state_queue is never
> > : scheduled, therefore link detection doesn't work
> > 
> > > On Thu, 9 Jul 2009 01:33:31 +0400 Anton Vorontsov <avorontsov@ru.mvista.com> wrote:
> > > On Wed, Jul 08, 2009 at 02:10:24PM -0700, Andrew Morton wrote:
> > > > > On Wed, 8 Jul 2009 09:12:30 -0700 (PDT) Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > > > > That said, I do agree that maybe SYSTEM_RUNNING isn't the right check. 
> > > > > Testing that the scheduler is initialized may be the more correct one. I 
> > > > > think the SYSTEM_RUNNING one just comes from that being used for other 
> > > > > debug issues.
> > > > 
> > > > Agreed.  system_state is too general.
> > > > 
> > > > If we specifically want to know whether it is safe to call schedule() then
> > > > let's create a global boolean it_is_safe_to_call_schedule and test that,
> > > > rather than testing something which indirectly and unreliably implies "it
> > > > is safe to call schedule".  If that boolean already exists then no-brainer.
> > > > 
> > > > All that being said, I wonder if the netconsole code should be using
> > > > msleep(1) instead.  Spinning on cond_resched() is a bit rude.  But one
> > > > would have to verify that it is safe to call schedule() at this time, and
> > > > for the netconsole caller, this is dubious.
> > > 
> > > What do you mean by "verify that it is safe"? If it works,
> > > can I assume that it's safe? ;-) It works, fwiw.
> > > 
> > 
> > netconsole is supposed to be available as early as possible in boot for
> > obvious reasons.  I'd say there's a decent risk now and in the future that
> > netconsole will be initialised prior to the scheduler being available.
> > 
> > In fact, if "netconsole: timeout waiting for carrier" newly added to
> > netpoll_setup() a depedency on the scheduler being available then perhaps
> > that was an incorrect change.
> 
> 'git blame' says that carrier detection code didn't change since 2.6.12
> (where git history starts), PHYLIB is using workqueue since its
> submission (2.6.13). And SYSTEM_RUNNING check was added in 2.6.16.
> So it's not a new dependency.
> 
> The netpoll code is using msleep() just a few lines below cond_resched(),
> so we won't make things worse. ;-)

I think that's an improvement with or without the SYSTEM_RUNNING fix.

Signed-off-by: Matt Mackall <mpm@selenic.com>

> Thanks!
> 
>  net/core/netpoll.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 9675f31..df30feb 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -740,7 +740,7 @@ int netpoll_setup(struct netpoll *np)
>  				       np->name);
>  				break;
>  			}
> -			cond_resched();
> +			msleep(1);
>  		}
>  
>  		/* If carrier appears to come up instantly, we don't

-- 
http://selenic.com : development and support for Mercurial and Linux


