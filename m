From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: Getting the new RxRPC patches upstream
Date: Tue, 24 Apr 2007 23:34:04 +0400
Message-ID: <20070424193404.GA5042@tv-sign.ru>
References: <29341.1176975158@redhat.com> <2969.1176992303@redhat.com> <1101.1177056127@redhat.com> <4713.1177065706@redhat.com> <20070420113805.c4877dc8.akpm@linux-foundation.org> <1355.1177317176@redhat.com> <9767.1177421824@redhat.com> <15160.1177429867@redhat.com> <16575.1177433907@redhat.com> <17966.1177438970@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	containers@lists.osdl.org, hch@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.screens.ru ([213.234.233.54]:59600 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423056AbXDXTe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 15:34:28 -0400
Content-Disposition: inline
In-Reply-To: <17966.1177438970@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/24, David Howells wrote:
>
> Oleg Nesterov <oleg@tv-sign.ru> wrote:
> 
> > Sure, I'll grep for cancel_delayed_work(). But unless I missed something,
> > this change should be completely transparent for all users. Otherwise, it
> > is buggy.
> 
> I guess you will have to make sure that cancel_delayed_work() is always
> followed by a flush of the workqueue, otherwise you might get this situation:
> 
> 	CPU 0				CPU 1
> 	===============================	=======================
> 					<timer expires>
> 	cancel_delayed_work(x) == 0	-->delayed_work_timer_fn(x)
> 	kfree(x);			-->do_IRQ()
> 	y = kmalloc(); // reuses x
> 					<--do_IRQ()
> 					__queue_work(x)
> 	--- OOPS ---
> 
> That's my main concern.  If you are certain that can't happen, then fair
> enough.

Yes sure. Note that this is documented:

	/*
	 * Kill off a pending schedule_delayed_work().  Note that the work callback
	 * function may still be running on return from cancel_delayed_work().  Run
	 * flush_workqueue() or cancel_work_sync() to wait on it.
	 */

This comment is not very precise though. If the work doesn't re-arm itself,
we need cancel_work_sync() only if cancel_delayed_work() returns 0.

So there is no difference with the proposed change. Except, return value == 0
means:

	currently (del_timer_sync): callback may still be running or scheduled

	with del_timer: may still be running, or scheduled, or will be scheduled
	right now.

However, this is the same from the caller POV.

> Can you show me a patch illustrating exactly how you want to change
> cancel_delayed_work()?  I can't remember whether you've done so already, but
> if you have, I can't find it.  Is it basically this?:
> 
>  static inline int cancel_delayed_work(struct delayed_work *work)
>  {
>  	int ret;
> 
> -	ret = del_timer_sync(&work->timer);
> +	ret = del_timer(&work->timer);
>  	if (ret)
>  		work_release(&work->work);
>  	return ret;
>  }

Yes, exactly. The patch is trivial, but I need some time to write the
understandable changelog...

> I was thinking this situation might be a problem:
> 
> 	CPU 0				CPU 1
> 	===============================	=======================
> 					<timer expires>
> 	cancel_delayed_work(x) == 0	-->delayed_work_timer_fn(x)
> 	schedule_delayed_work(x,0)	-->do_IRQ()
> 	<keventd scheduled>
> 	x->work()
> 					<--do_IRQ()
> 					__queue_work(x)
> 
> But it won't, will it?

Yes, I think this should be OK. schedule_delayed_work() will notice
_PENDING and abort, so the last "x->work()" doesn't happen.

What can happen is

					<timer expires>
	cancel_delayed_work(x) == 0
					-->delayed_work_timer_fn(x)
					__queue_work(x)
					<keventd scheduled>
					x->work()
	schedule_delayed_work(x,0)
	<the work is scheduled again>

, so we can have an "unneeded schedule", but this is very unlikely.

Oleg.

