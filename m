From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: Getting the new RxRPC patches upstream
Date: Tue, 24 Apr 2007 21:33:29 +0400
Message-ID: <20070424173329.GA364@tv-sign.ru>
References: <20070420.015838.83621529.davem@davemloft.net> <29341.1176975158@redhat.com> <2969.1176992303@redhat.com> <1101.1177056127@redhat.com> <4713.1177065706@redhat.com> <20070420113805.c4877dc8.akpm@linux-foundation.org> <1355.1177317176@redhat.com> <9767.1177421824@redhat.com> <15160.1177429867@redhat.com> <16575.1177433907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	containers@lists.osdl.org, hch@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.screens.ru ([213.234.233.54]:44235 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754338AbXDXRdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 13:33:49 -0400
Content-Disposition: inline
In-Reply-To: <16575.1177433907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/24, David Howells wrote:
>
> Oleg Nesterov <oleg@tv-sign.ru> wrote:
> 
> > Great. I'll send the s/del_timer_sync/del_timer/ patch.
> 
> I didn't say I necessarily agreed that this was a good idea.  I just meant that
> I agree that it will waste CPU.  You must still audit all uses of
> cancel_delayed_work().

Sure, I'll grep for cancel_delayed_work(). But unless I missed something,
this change should be completely transparent for all users. Otherwise, it
is buggy.

> > Aha, now I see what you mean. However. Why the code above is better then
> > 
> > 	cancel_delayed_work(&afs_server_reaper);
> > 	schedule_delayed_work(&afs_server_reaper, 0);
> > 
> > ? (I assume we already changed cancel_delayed_work() to use del_timer).
> 
> Because calling schedule_delayed_work() is a waste of CPU if the timer expiry
> handler is currently running at this time as *that* is going to also schedule
> the delayed work item.

Yes. But otoh, try_to_del_timer_sync() is a waste of CPU compared to del_timer(),
when the timer is not pending.

> > 	1: lock_timer_base(), return -1, skip schedule_delayed_work().
> >
> > 	2: check timer_pending(), return 0, call schedule_delayed_work(),
> > 	   return immediately because test_and_set_bit(WORK_STRUCT_PENDING)
> > 	   fails.
> 
> I don't see what you're illustrating here.  Are these meant to be two steps in
> a single process?  Or are they two alternate steps?

two alternate steps.

1 means
	if (try_to_cancel_delayed_work())
		schedule_delayed_work();

2 means
	cancel_delayed_work();
	schedule_delayed_work();

> > So I still don't think try_to_del_timer_sync() can help in this particular
> > case.
> 
> It permits us to avoid the test_and_set_bit() under some circumstances.

Yes. But lock_timer_base() is more costly.

> > To some extent, try_to_cancel_delayed_work is
> > 
> > 	int try_to_cancel_delayed_work(dwork)
> > 	{
> > 		ret = cancel_delayed_work(dwork);
> > 		if (!ret && work_pending(&dwork->work))
> > 			ret = -1;
> > 		return ret;
> > 	}
> > 
> > iow, work_pending() looks like a more "precise" indication that work->func()
> > is going to run soon.
> 
> Ah, but the timer routine may try to set the work item pending flag *after* the
> work_pending() check you have here.

No, delayed_work_timer_fn() doesn't set the _PENDING flag.

>                                      Furthermore, it would be better to avoid
> the work_pending() check entirely because that check involves interacting with
> atomic ops done on other CPUs.

Sure, the implementation of try_to_cancel_delayed_work() above is just for
illustration. I don't think we need try_to_cancel_delayed_work() at all.

>                                try_to_del_timer_sync() returning -1 tells us
> without a shadow of a doubt that the work item is either scheduled now or will
> be scheduled very shortly, thus allowing us to avoid having to do it ourself.

First, this is very unlikely event, delayed_work_timer_fn() is very fast unless
interrupted.

_PENDING flag won't be cleared until this work is executed by run_workqueue().
In generak, work_pending() after del_timer() is imho better way to avoid the
unneeded schedule_delayed_work().

But again, I can't undertand the win for that particular case.

Oleg.

