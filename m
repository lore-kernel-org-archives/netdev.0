From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH] RFC: have tcp_recvmsg() check kthread_should_stop() and treat it as if it were signalled
Date: Wed, 27 Jun 2007 16:24:37 +0400
Message-ID: <20070627122437.GA158@tv-sign.ru>
References: <20070608123527.9b4cdafe.jlayton@redhat.com> <E1HwpmG-0008LW-00@gondolin.me.apana.org.au> <20070609070826.7bd3480c.jlayton@redhat.com> <a781481a0706251241n36126456x7f4b445a86d1a68f@mail.gmail.com> <20070626115449.GA92@tv-sign.ru> <a781481a0706261553i1e65e620o884708d0b068b0f8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-cifs-client@lists.samba.org
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.screens.ru ([213.234.233.54]:44206 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755916AbXF0MXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 08:23:51 -0400
Content-Disposition: inline
In-Reply-To: <a781481a0706261553i1e65e620o884708d0b068b0f8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/27, Satyam Sharma wrote:
>
> Thanks for your comments, I'm still not convinced, however.

An perhaps you are right. I don't have a very strong opinion on that.
Still I can't understand why it is better if kthread_stop() sends a
signal as well. Contrary, I believe we should avoid signals when it
comes to kernel threads.

One can always use force_sig() or allow_signal() + send_sig() when
it is really needed, like cifs does.

> On 6/26/07, Oleg Nesterov <oleg@tv-sign.ru> wrote:
> >
> >Personally, I don't think we should do this.
> >
> >kthread_stop() doesn't always mean "kill this thread asap". Suppose that
> >CPU_DOWN does kthread_stop(workqueue->thread) but doesn't flush the queue
> >before that (we did so before 2.6.22 and perhaps we will do again). Now
> >work_struct->func() doing tcp_recvmsg() or wait_event_interruptible()
> >fails,
> >but this is probably not that we want.
>
> Anyway, I think _all_ usages of kthread_stop() in the kernel *do* want
> the thread to stop *right then*. After all, kthread_stop() doesn't even
> return (gets blocked on wait_for_completion()) till it knows the target
> kthread *has* exited completely.

Yes, kthread_stop(k) means that k should exit eventually, but I don't
think that kthread_stop() should try to force the exit.

> And if a workqueue is blocked on tcp_recvmsg() or skb_recv_datagram()
> or some such, I don't see how that flush_workqueue (if that is what you
> meant) would succeed anyway (unless you do send the signal too),

timeout, but this was just a silly example. I am talking about the case
when wait_event_interruptible() should not fail (unless something bad
happens) inside the "while (!kthread_should_stop())" loop.

Note also that kthread could use TASK_INTERRUPTIBLE sleep because it
doesn't want to contribute to loadavg, and because it knows that all
signals are ignored.

> Note that the exact scenario you're talking about wouldn't mean the
> kthread getting killed before it's supposed to be stopped anyway.

Yes sure, we can't kill the kernel thread via signal. I meant we can have
some unexpected failure.

> >(offtopic)
> >
> >        cifs_mount:
> >
> >                send_sig(SIGKILL,srvTcp->tsk,1);
> >                tsk = srvTcp->tsk;
> >                if(tsk)
> >                        kthread_stop(tsk);
> >
> >This "if(tsk)" looks wrong to me.
>
> I think it's bogus myself. [ Added linux-cifs-client@lists.samba.org to Cc:
> ]
>
> >Can srvTcp->tsk be NULL? If yes, send_sig()
> >is not safe. Can srvTcp->tsk become NULL after send_sig() ? If yes, this
> >check is racy, and kthread_stop() is not safe.
>
> That's again something the atomicity I proposed above could avoid?

I think this "if(tsk)" is just bogus, and should be killed.

Oleg.

