From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire X4150(x86)
 and e1000e
Date: Wed, 30 May 2012 19:43:55 +0900
Message-ID: <20120530194355.92bf5d51.shimoda.hiroaki@gmail.com>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	<20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
	<CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
	<20120530090602.6204d857.shimoda.hiroaki@gmail.com>
	<1338367231.2760.125.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48455 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389Ab2E3KoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 06:44:05 -0400
Received: by pbbrp8 with SMTP id rp8so7288445pbb.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 03:44:05 -0700 (PDT)
In-Reply-To: <1338367231.2760.125.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 May 2012 10:40:31 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2012-05-30 at 09:06 +0900, Hiroaki SHIMODA wrote:
> > While reading the bql code, I have some questions.
> > 
> > 1) dql_completed() and dql_queued() can be called concurrently,
> >    so dql->num_queued could change while processing
> >    dql_completed().
> >    Is it intentional to refer num_queued from "dql->" each time ?
> > 
> 
> not sure it can have problems, but doing the read once is indeed a good
> plan.
> 
> > 2) From the comment in the code
> >    *   - The queue was over-limit in the previous interval and
> >    *     when enqueuing it was possible that all queued data
> >    *     had been consumed.
> > 
> >    and
> > 
> >    * Queue was not starved, check if the limit can be decreased.
> >    * A decrease is only considered if the queue has been busy in
> >    * the whole interval (the check above). 
> > 
> >    the calculation of all_prev_completed should take into account
> >    completed == dql->prev_num_queued case ?
> >    On current implementation, limit shrinks easily and some NIC
> >    hit TX stalls.
> >    To mitigate TX stalls, should we fix all_prev_completed rather
> >    than individual driver ?
> > 
> 
> Not sure what you mean

While examining ping problem, below pattern is often observed.

                                               TIME
       dql_queued()         dql_completed()     |
      a) initial state                          |
                                                |
      b) X bytes queued                         V

      c) Y bytes queued
                           d) X bytes completed
      e) Z bytes queued
                           f) Y bytes completed

a) dql->limit has already some value and there is no in-flight packet.
b) X bytes queued.
c) Y bytes queued and excess limit.
d) X bytes completed and dql->prev_ovlimit is set and also
   dql->prev_num_queued is set Y.
e) Z bytes queued.
f) Y bytes completed. inprogress and prev_inprogress are true.

At f), if I read the comment correctly, all_prev_completed becomes
true and limit should be increased. But POSDIFF() ignores
(A == B) case, so limit is decreased.

I thought excess limit decrement induces the TX stalls.

> 
> > 3) limit calculation fails to consider integer wrap around in
> >    one place ?
> > 
> 
> Yes
> 
> > Here is the patch what I meant.
> > 
> > diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
> > @@ -11,22 +11,27 @@
> >  #include <linux/dynamic_queue_limits.h>
> >  
> >  #define POSDIFF(A, B) ((A) > (B) ? (A) - (B) : 0)
> > +#define POSDIFFI(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
> > +#define AFTER_EQ(A, B) ((int)((A) - (B)) >= 0)
> >  
> >  /* Records completed count and recalculates the queue limit */
> >  void dql_completed(struct dql *dql, unsigned int count)
> >  {
> >  	unsigned int inprogress, prev_inprogress, limit;
> > -	unsigned int ovlimit, all_prev_completed, completed;
> > +	unsigned int ovlimit, completed, num_queued;
> > +	bool all_prev_completed;
> > +
> > +	num_queued = dql->num_queued;
> 
> 
> I suggest :
> 
> 	num_queued = ACCESS_ONCE(dql->num_queued);
> 	
> Or else compiler is free to do whatever he wants.

Thank you for your suggestion.
