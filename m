From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] kill 8139too kernel thread (sorta)
Date: Tue, 01 Nov 2005 07:50:52 +1100
Message-ID: <E1EWgcG-0001dZ-00@gondolin.me.apana.org.au>
References: <20051031130255.GA26626@havoc.gtf.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751278AbVJaUvI@vger.kernel.org>
To: jgarzik@pobox.com (Jeff Garzik)
In-Reply-To: <20051031130255.GA26626@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> +       if ((tp->time_to_die == 0) &&
> +           (rtnl_lock_interruptible() == 0)) {
>                rtl8139_thread_iter (dev, tp, tp->mmio_addr);
>                rtnl_unlock ();
>        }
> 
> -       complete_and_exit (&tp->thr_exited, 0);
> +       if (tp->time_to_die == 0)
> +               schedule_delayed_work(&tp->thread, next_tick);
> }

...

> +static void rtl8139_stop_thread(struct rtl8139_private *tp)
> +{
> +       if (tp->time_to_die < 0)
> +               return;
> +
> +       tp->time_to_die = 1;
> +       wmb();
> +
> +       if (cancel_delayed_work(&tp->thread) == 0)
> +               flush_scheduled_work();
> }

Race alert:

CPU0					CPU1
rtl8139_thread
	rtnl_lock
	rtl8139_thread_iter
	rtnl_unlock
	tp->time_to_die == 0
					rtl8139_stop_thread
						tp->time_to_die = 1
						cancel_delayed_work == 0
							flush_scheduled_work
		schedule_delayed_work

So by the time rtl8139_stop_thread returns, the work is still scheduled.

The standard way to solve this is to get rid of the time_to_die check
in rtl8139_thread before the rescheduling and then use the horrible
cancel_rearming_delayed_workqueue function.

However, in this case it's much easier than that.  Simply change
rtl8139_thread to do

	rtnl_lock();
	if (tp->time_to_die == 0) {
		rtl8139_thread_iter(dev, tp, tp->mmio_addr);
		schedule_delayed_work(&tp->thread, next_tick);
	}
	rtnl_unlock();

This is not racy because rtl8139_stop_thread is also run under the
RTNL.  Furthermore, you don't need the interruptible version anymore
since you are no longer using kill to kill the thread.

This also fixes the bug that if you fail to acquire RTNL the Work
is delayed by another next_tick ticks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
