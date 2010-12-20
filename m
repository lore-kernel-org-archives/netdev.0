From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2: remove cancel_work_sync() from
 remove_one
Date: Mon, 20 Dec 2010 13:11:46 -0800 (PST)
Message-ID: <20101220.131146.115941299.davem@davemloft.net>
References: <4D0796D7.3030309@kernel.org>
	<1292348880.7394.63.camel@nseg_linux_HP1.broadcom.com>
	<4D08C81D.8020606@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D08C81D.8020606@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Wed, 15 Dec 2010 14:52:29 +0100

> After looking through the code, I don't think this is necessarily
> correct.  ->ndo_close() doesn't guarantee that the watchdog timer has
> finished running (the timer is deleted with del_timer() not
> del_timer_sync()).  ie. the watchdog timer could still be running
> after ->ndo_close() and may schedule reset_task.  If remove_one
> doesn't flush the task, it may still be running when remove_one() is
> called.
> 
> David, am I missing something?  Wouldn't it cleaner to guarantee that
> ->ndo_close() is called with the guarantee that the watchdog timer is
> not running anymore?

It would but we can't just make the change over to del_timer_sync()
otherwise we'd deadlock on netif_tx_lock().

But I think things might be OK as-is.

The timer is deleted by dev_deactivate_many() which resets the qdisc
to the no-op qdisc.  Then it deletes the timer.

Any running timer will complete or see the no-op qdisc attached and
return immediately.

synchronize_rcu() is then executed which guarentees completion.

Since both the watchdog timer itself and the del_timer() call run
with netif_tx_lock() held, this makes sure the timer, once deleted,
will only see the no-op qdisc and return immediately if it is
amidst running, else it has already returned when the timer delete
completes.

So we might be OK here.
