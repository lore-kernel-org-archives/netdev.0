From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next-2.6] bnx2: remove cancel_work_sync() from
 remove_one
Date: Tue, 21 Dec 2010 11:51:04 +0100
Message-ID: <20101221105103.GA32744@htj.dyndns.org>
References: <4D0796D7.3030309@kernel.org>
 <1292348880.7394.63.camel@nseg_linux_HP1.broadcom.com>
 <4D08C81D.8020606@kernel.org>
 <20101220.131146.115941299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101220.131146.115941299.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, David.

On Mon, Dec 20, 2010 at 01:11:46PM -0800, David Miller wrote:
> It would but we can't just make the change over to del_timer_sync()
> otherwise we'd deadlock on netif_tx_lock().
> 
> But I think things might be OK as-is.
> 
> The timer is deleted by dev_deactivate_many() which resets the qdisc
> to the no-op qdisc.  Then it deletes the timer.
> 
> Any running timer will complete or see the no-op qdisc attached and
> return immediately.
> 
> synchronize_rcu() is then executed which guarentees completion.
> 
> Since both the watchdog timer itself and the del_timer() call run
> with netif_tx_lock() held, this makes sure the timer, once deleted,
> will only see the no-op qdisc and return immediately if it is
> amidst running, else it has already returned when the timer delete
> completes.
> 
> So we might be OK here.

Yeah, I agree the synchronize_rcu() there would guarantee the actual
timer completion but as it currently stands it looks a bit too subtle.
Maybe it's a good idea to add a big fat comment explaining that the
the timer is guaranteed to stop after close() and how it's guaranteed
through synchronize_rcu() at the moment?  Also, it might be better to
use synchronize_sched() there as timer synchronization through
synchronize_rcu() is more of a happy accident.

Thanks.

-- 
tejun
