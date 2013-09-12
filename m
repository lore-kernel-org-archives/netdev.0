From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set
 was called
Date: Thu, 12 Sep 2013 21:37:42 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1309122057020.4089@ionos.tec.linutronix.de>
References: <alpine.DEB.2.02.1309121441420.4089@ionos.tec.linutronix.de> <20130912134409.GB21212@gondor.apana.org.au> <alpine.DEB.2.02.1309121636010.4089@ionos.tec.linutronix.de> <20130912.133252.425268707009916773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, fan.du@windriver.com,
	steffen.klassert@secunet.com, dborkman@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130912.133252.425268707009916773.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Sep 2013, David Miller wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Thu, 12 Sep 2013 16:43:37 +0200 (CEST)
> 
> > So what about going back to timer_list timers and simply utilize
> > register_pm_notifier(), which will tell you that the system resumed?
> 
> The thing to understand is that there are two timeouts for an IPSEC
> rule, a soft and a hard timeout.
> 
> There is a gap between these two exactly so that we can negotiate a
> new encapsulation with the IPSEC gateway before communication ceases
> to be possible over the IPSEC protected path.
> 
> So the idea is that the soft timeout triggers the re-negotiation,
> and after a hard timeout the IPSEC path is no longer usable and
> all communication will fail.
> 
> Simply triggering a re-negoation after every suspend/resume makes
> no sense at all.  Spurious re-negotiations are undesirable.
> 
> What we want are real timers.  We want that rather than a "we
> suspended so just assume all timers expired" event which is not very
> useful for this kind of application.

Your argumentation makes no sense at all. Where is the difference
between the "real timer" plus a clock was set notification and a timer
list timer and a resume notification?

In both cases you need to walk through the timers and reevaluate
them. Just in the clock was set notification case you need to deal
with NTP/settimeofday/PPS and whatever cases which are completely
irrelevant to the life time management.

So what's wrong with:

   now = get_seconds();
   x->timeout = now + x->soft_timeout;
   x->timeout_active = SOFT;
   start_timer(x->timer, jiffies + sec_to_jiffies(x->soft_timeout));

In the timer handler:

   switch (x->timeout_active) {
      case SOFT:
            trigger_renegotiation();
	    hts = x->hard_timeout - x->soft_timeout;
	    x->timeout += hts;
	    x->timeout_active = HARD;
      	    start_timer(x->timer, jiffies + sec_to_jiffies(hts));
	    break;
      case HARD:
      	   stop_connection();
	   break:
   }
   
If the negotiation succeeds:

   now = get_seconds();
   x->t_timeout = now + x->soft_timeout;
   x->timeout_active = SOFT;
   mod_timer(x->timer, jiffies + sec_to_jiffies(x->soft_timeout));

Now in the resume notification you walk the active timers and do for
each timer:

    now = get_seconds();

    switch (x->timeout_active) {
    case SOFT:
    	 if (now >= x->timeout) {
	    hts = x->hard_timeout - x->soft_timeout;
	    x->timeout += hts;
	    if (now >= x->timeout) {
	       del_timer(x->timeout);
	       stop_connection();
	       break:
	    }
	    trigger_renegotiation();
	    x->timeout_active = HARD;
      	    mod_timer(x->timer, jiffies + sec_to_jiffies(hts));
	    break;
   	 }
	 delta = x->timeout - now;
      	 mod_timer(x->timer, jiffies + sec_to_jiffies(delta));
	 break;

    case HARD:	    
    	 if (now >= x->timeout) {
	       del_timer(x->timeout);
	       stop_connection();
	 }    	 
	 delta = x->timeout - now;
      	 mod_timer(x->timer, jiffies + sec_to_jiffies(delta));
	 break;
    }

That's what you have to do with a clock was set notification as
well. And what's worse is that you need to figure out whether the
clock change was due to a suspend/resume cycle or just because
NTP/settimeofday/PPS or whatever decided to fiddle with the wall
time. And you need to do that to avoid the spurious renegotiations
which you are afraid of.


Thanks,

	tglx
