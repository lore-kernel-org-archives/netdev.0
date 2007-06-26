From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH] RFC: have tcp_recvmsg() check kthread_should_stop() and treat it as if it were signalled
Date: Tue, 26 Jun 2007 15:54:49 +0400
Message-ID: <20070626115449.GA92@tv-sign.ru>
References: <20070608123527.9b4cdafe.jlayton@redhat.com> <E1HwpmG-0008LW-00@gondolin.me.apana.org.au> <20070609070826.7bd3480c.jlayton@redhat.com> <a781481a0706251241n36126456x7f4b445a86d1a68f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.screens.ru ([213.234.233.54]:33350 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042AbXFZLyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2007 07:54:09 -0400
Content-Disposition: inline
In-Reply-To: <a781481a0706251241n36126456x7f4b445a86d1a68f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/26, Satyam Sharma wrote:
> 
> Yes, why not embed a send_sig(SIGKILL) just before the wake_up_process()
> in kthread_stop() itself?

Personally, I don't think we should do this.

kthread_stop() doesn't always mean "kill this thread asap". Suppose that
CPU_DOWN does kthread_stop(workqueue->thread) but doesn't flush the queue
before that (we did so before 2.6.22 and perhaps we will do again). Now
work_struct->func() doing tcp_recvmsg() or wait_event_interruptible() fails,
but this is probably not that we want.

> So could we have signals in _addition_ to kthread_stop_info and change
> kthread_should_stop() to check for both:
> 
> kthread_stop_info.k == current && signal_pending(current)

No, this can't work in general. Some kthreads do flush_signals/dequeue_signal,
so TIF_SIGPENDING can be lost anyway.

I personally think Jeff's idea to use force_sig() is right. kthread_create()
doesn't use CLONE_SIGHAND, so it is safe to change ->sighand->actionp[].


(offtopic)

	cifs_mount:

		send_sig(SIGKILL,srvTcp->tsk,1);
		tsk = srvTcp->tsk;
		if(tsk)
			kthread_stop(tsk);

This "if(tsk)" looks wrong to me. Can srvTcp->tsk be NULL? If yes, send_sig()
is not safe. Can srvTcp->tsk become NULL after send_sig() ? If yes, this
check is racy, and kthread_stop() is not safe.

Oleg.

