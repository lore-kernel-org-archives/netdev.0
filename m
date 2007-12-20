From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 09:51:21 -0800
Message-ID: <20071220095121.7859c023@deepthought>
References: <Pine.LNX.4.64.0712182008160.3616@mini.warudkars.net>
	<20071220091603.0d69b045@deepthought>
	<823114761-1198171803-cardhu_decombobulator_blackberry.rim.net-937108990-@bxe019.bisx.prod.on.blackberry>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: parag.warudkar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58976 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbXLTRwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 12:52:19 -0500
In-Reply-To: <823114761-1198171803-cardhu_decombobulator_blackberry.rim.net-937108990-@bxe019.bisx.prod.on.blackberry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2007 17:29:23 +0000

> 
> -----Original Message-----
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Date: Thu, 20 Dec 2007 09:16:03 
> To:parag.warudkar@gmail.com
> Cc:netdev@vger.kernel.org, akpm@linux-foundation.org,       linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] sky2: Use deferrable timer for watchdog
> 
> 
> On Tue, 18 Dec 2007 20:13:28 -0500 (EST)
> Parag Warudkar <parag.warudkar@gmail.com> wrote:
> 
> > 
> > sky2 can use deferrable timer for watchdog - reduces wakeups from idle per 
> > second.
> > 
> > Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>
> > 
> > --- linux-2.6/drivers/net/sky2.c	2007-12-07 10:04:39.000000000 -0500
> > +++ linux-2.6-work/drivers/net/sky2.c	2007-12-18 20:07:58.000000000 -0500
> > @@ -4230,7 +4230,10 @@
> >   			sky2_show_addr(dev1);
> >   	}
> > 
> > -	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
> > +	hw->watchdog_timer.function = sky2_watchdog;
> > +	hw->watchdog_timer.data = (unsigned long) hw;
> > +	init_timer_deferrable(&hw->watchdog_timer);
> > +
> >   	INIT_WORK(&hw->restart_work, sky2_restart);
> > 
> >   	pci_set_drvdata(pdev, hw);
> 
> Does it really reduce the wakeup's or only change who gets charged by powertop?
> The system is going to wakeup once a second anyway. Looks to me that if the
> timer is using round_jiffies(), that setting deferrable just changes the accounting.
> 
> My interpretation of the api is:
>    * round_jiffies()  - timer wants to wakeup but isn't precise about when so schedule
>                         on next second when system will wake up anyway;
>                         e.g why meetings are usually scheduled on the hour
> 
>    * deferrable       - timer doesn't have to really wakeup but wants to happen near
>                         a particular time. e.g. "I'll meet you at the pub around 8pm"
> 
> Therefore doing deferrable is unnecessary for timers using round_jiffies unless system
> is so good at doing timers that it is going to skip doing timer once per second.
> 

parag.warudkar@gmail.com wrote:

> NO_HZ kernels don't do timers every second - if you do round_jiffies() the kernel will wakeup and run the timer at that time no matter what. 
> 
> The reason deferrable was introduced is to avoid waking up the kernel just for this one timer that can be called when the CPU is not idle for some reason other than this timer.
> 
> In other words let's say there were two timers - one non-deferrable expiring in 3 seconds and other deferrable, expiring in 1.5 seconds. The kernel will not wake up twice - once for 1.5 second and other for 3 second - it will wake up once at expiry of 3 second timer and execute both the 1.5 second and 3 second timers.
> 
> And this is not just powertop accounting thing - like I said the total num of wakeups per second go down with this patch.
> 
> Parag
> 
> Sent via BlackBerry from T-Mobile


Quit top-posting!

If this is the case then the whole usage of round_jiffies() is bogus. All users of round_jiffies()
should just be converted to deferrable??  I am a bit concerned that if deferrable gets used everywhere
then a strange situation would occur where all timers were waiting for some other timer to finally
happen, kind of a wierd timelock situation. Like the old chip/dale cartoon:
 "you first, no you first, after you mister chip, no after you mister dale,..."

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
