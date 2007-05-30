From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/4] Make net watchdog timers 1 sec jiffy aligned
Date: Wed, 30 May 2007 13:30:39 -0700
Message-ID: <20070530133039.7feb2064@freepuppy>
References: <20070530105936.6c988da5.akpm@linux-foundation.org>
	<20070530112056.0aeb9498@freepuppy>
	<465DC598.5060407@trash.net>
	<20070530.125551.41636333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, akpm@linux-foundation.org,
	venkatesh.pallipadi@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:60713 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754084AbXE3UmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 16:42:09 -0400
In-Reply-To: <20070530.125551.41636333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 May 2007 12:55:51 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 30 May 2007 20:42:32 +0200
> 
> > Stephen Hemminger wrote:
> > >>>Index: linux-2.6.22-rc-mm/net/sched/sch_generic.c
> > >>>===================================================================
> > >>>--- linux-2.6.22-rc-mm.orig/net/sched/sch_generic.c	2007-05-24 11:16:03.000000000 -0700
> > >>>+++ linux-2.6.22-rc-mm/net/sched/sch_generic.c	2007-05-25 15:10:02.000000000 -0700
> > >>>@@ -224,7 +224,8 @@
> > >>> 	if (dev->tx_timeout) {
> > >>> 		if (dev->watchdog_timeo <= 0)
> > >>> 			dev->watchdog_timeo = 5*HZ;
> > >>>-		if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
> > >>>+		if (!mod_timer(&dev->watchdog_timer,
> > >>>+			       round_jiffies(jiffies + dev->watchdog_timeo)))
> > >>> 			dev_hold(dev);
> > >>> 	}
> > >>> }
> > >>
> > >>Please cc netdev on net patches.
> > >>
> > >>Again, I worry that if people set the watchdog timeout to, say, 0.1 seconds
> > >>then they will get one second, which is grossly different.
> > >>
> > >>And if they were to set it to 1.5 seconds, they'd get 2.0 which is pretty
> > >>significant, too.
> > > 
> > > 
> > > Alternatively, we could change to a timer that is pushed forward after each
> > > TX, maybe using hrtimer and hrtimer_forward().  That way the timer would
> > > never run in normal case.
> > 
> > 
> > It seems wasteful to add per-packet overhead for tx timeouts, which
> > should be an exception. Do drivers really care about the exact
> > timeout value? Compared to a packet transmission time its incredibly
> > long anyways ..
> 
> I agree, this change is absolutely rediculious and is just a blind
> cookie-cutter change made without consideration of what the code is
> doing and what it's requirements are.
> 

what about the obvious compromise:

--- a/net/sched/sch_generic.c	2007-05-30 11:42:18.000000000 -0700
+++ b/net/sched/sch_generic.c	2007-05-30 13:29:34.000000000 -0700
@@ -203,7 +203,11 @@ static void dev_watchdog(unsigned long a
 				       dev->name);
 				dev->tx_timeout(dev);
 			}
-			if (!mod_timer(&dev->watchdog_timer, round_jiffies(jiffies + dev->watchdog_timeo)))
+
+			if (!mod_timer(&dev->watchdog_timer,
+				       dev->watchdog_timeo > 2 * HZ
+				       ? round_jiffies(jiffies + dev->watchdog_timeo)
+				       : jiffies + dev->watchdog_timeo))
 				dev_hold(dev);
 		}
 	}




-- 
Stephen Hemminger <shemminger@linux-foundation.org>
