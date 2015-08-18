From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet: fix potential deadlock in reqsk_queue_unlink()
Date: Tue, 18 Aug 2015 06:36:43 -0700
Message-ID: <1439905003.6443.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150810.211821.2246516216165801977.davem@davemloft.net>
	 <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439505891.7960.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB7E6FA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33547 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbbHRNgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 09:36:46 -0400
Received: by pabyb7 with SMTP id yb7so133158232pab.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 06:36:45 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB7E6FA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-18 at 11:04 +0000, David Laight wrote:
> From: Eric Dumazet
> > Sent: 13 August 2015 23:45
> > When replacing del_timer() with del_timer_sync(), I introduced
> > a deadlock condition :
> > 
> > reqsk_queue_unlink() is called from inet_csk_reqsk_queue_drop()
> > 
> > inet_csk_reqsk_queue_drop() can be called from many contexts,
> > one being the timer handler itself (reqsk_timer_handler()).
> > 
> > In this case, del_timer_sync() loops forever.
> > 
> > Simple fix is to test if timer is pending.
> 
> Doesn't that mean you fail to wait for the timer function
> to finish if you are calling from a different context?

No, this is the purpose of del_timer_sync()

> 
> What you need to know is whether the current context
> is that running the timer itself.
> In which case you need to mark the timer 'to be deleted'
> and actually delete it when the timer function returns.
> (so other code can still wait for completion.)

Please read del_timer_sync() documentation and/or implementation if you
have doubts.

/**
 * del_timer_sync - deactivate a timer and wait for the handler to finish.
 * @timer: the timer to be deactivated
 *
 * This function only differs from del_timer() on SMP: besides deactivating
 * the timer it also makes sure the handler has finished executing on other
 * CPUs.
 *
 * Synchronization rules: Callers must prevent restarting of the timer,
 * otherwise this function is meaningless. It must not be called from
 * interrupt contexts unless the timer is an irqsafe one. The caller must
 * not hold locks which would prevent completion of the timer's
 * handler. The timer's handler must not call add_timer_on(). Upon exit the
 * timer is not queued and the handler is not running on any CPU.
 *
 * Note: For !irqsafe timers, you must not hold locks that are held in
 *   interrupt context while calling this function. Even if the lock has
 *   nothing to do with the timer in question.  Here's why:
 *
 *    CPU0                             CPU1
 *    ----                             ----
 *                                   <SOFTIRQ>
 *                                   call_timer_fn();
 *                                     base->running_timer = mytimer;
 *  spin_lock_irq(somelock);
 *                                     <IRQ>
 *                                        spin_lock(somelock);
 *  del_timer_sync(mytimer);
 *   while (base->running_timer == mytimer);
 *
 * Now del_timer_sync() will never return and never release somelock.
 * The interrupt on the other CPU is waiting to grab somelock but
 * it has interrupted the softirq that CPU0 is waiting to finish.
 *
 * The function returns whether it has deactivated a pending timer or not.
 */
