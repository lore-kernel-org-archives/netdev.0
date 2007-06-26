From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH] RFC: have tcp_recvmsg() check kthread_should_stop() and treat it as if it were signalled
Date: Wed, 27 Jun 2007 04:23:39 +0530
Message-ID: <a781481a0706261553i1e65e620o884708d0b068b0f8@mail.gmail.com>
References: <20070608123527.9b4cdafe.jlayton@redhat.com>
	 <E1HwpmG-0008LW-00@gondolin.me.apana.org.au>
	 <20070609070826.7bd3480c.jlayton@redhat.com>
	 <a781481a0706251241n36126456x7f4b445a86d1a68f@mail.gmail.com>
	 <20070626115449.GA92@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Layton" <jlayton@redhat.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-cifs-client@lists.samba.org
To: "Oleg Nesterov" <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.232]:7418 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbXFZWxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 18:53:41 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1870867nzf
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2007 15:53:40 -0700 (PDT)
In-Reply-To: <20070626115449.GA92@tv-sign.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oleg,

Thanks for your comments, I'm still not convinced, however.

On 6/26/07, Oleg Nesterov <oleg@tv-sign.ru> wrote:
> On 06/26, Satyam Sharma wrote:
> >
> > Yes, why not embed a send_sig(SIGKILL) just before the wake_up_process()
> > in kthread_stop() itself?
>
> Personally, I don't think we should do this.
>
> kthread_stop() doesn't always mean "kill this thread asap". Suppose that
> CPU_DOWN does kthread_stop(workqueue->thread) but doesn't flush the queue
> before that (we did so before 2.6.22 and perhaps we will do again). Now
> work_struct->func() doing tcp_recvmsg() or wait_event_interruptible() fails,
> but this is probably not that we want.

[ Well, first of all, anybody who sends a possibly-blocking-forever
function like tcp_recvmsg() to a *workqueue* needs to get his head
checked. ]

Anyway, I think _all_ usages of kthread_stop() in the kernel *do* want
the thread to stop *right then*. After all, kthread_stop() doesn't even
return (gets blocked on wait_for_completion()) till it knows the target
kthread *has* exited completely.

And if a workqueue is blocked on tcp_recvmsg() or skb_recv_datagram()
or some such, I don't see how that flush_workqueue (if that is what you
meant) would succeed anyway (unless you do send the signal too),
and we'll actually end up having a nice little situation on our hands if
we make the mistake of calling flush_workqueue on such a wq.

Note that the exact scenario you're talking about wouldn't mean the
kthread getting killed before it's supposed to be stopped anyway.
force_sig is not a synchronous wakeup, and also note that tcp_recvmsg()
or skb_recv_datagram() etc will exit (and are supposed to exit) cleanly on
seeing a signal.

> > So could we have signals in _addition_ to kthread_stop_info and change
> > kthread_should_stop() to check for both:
> >
> > kthread_stop_info.k == current && signal_pending(current)
>
> No, this can't work in general. Some kthreads do flush_signals/dequeue_signal,
> so TIF_SIGPENDING can be lost anyway.

Yup, I had thought of precisely this issue yesterday as well. The mental note
I made to myself was that the force_sig(SIGKILL) and wake_up_process() in
kthread_stop() must be atomic so that the following race is not possible:

Say:
#1 -> thread that invokes kthread_stop()
#2 -> kthread to be stopped, (may be) currently in wait_event_interruptible(),
      such that there is a bigger loop over the wait_event_interruptible()
      itself, which puts task back to sleep if this was a spurious wake up
      (if _not_ due to a signal).

Thread #1				Thread #2
=========				=========

					skb_recv_datagram() ->
					wait_for_packet()
					<sleeping>

...
force_sig(SIGKILL)
<scheduled out>

					<wakes up, sees the pending signal,
					breaks out of wait_for_packet()
					and skb_recv_datagram() back out to
					our kthread code itself, but there
					we see that kthread_should_stop() is
					NOT yet true, we also see this
					spurious signal, flush it, and call
					skb_recv_datagram() all over again>
					...
					skb_recv_datagram() ->
					wait_for_packet()
					<sleeping>

<scheduled in>
kthread_stop() -> wake_up_process()

					<this time we don't even break out of
					the skb_recv_datagram() either, as
					no signals are pending any more>

i.e. thread #2 still does not exit cleanly. The root of the problem is that
functions such as skb_recv_datagram() -> wait_for_packet() handle spurious
wakeups *internally* by themselves, so our kthread does not get a chance to
check for kthread_should_stop().

Of course, above race is true only for kthreads that do flush signals on
seeing spurious ones periodically. If it did not, then skb_recv_datagram()
called second time above would again have broken out because of
signal_pending() and we wouldn't have gone back to sleep. But we have to
be on safer side and avoid races *irrespective* of what the kthread might
or might not do, so let's _not_ depend on _assumed kthread behaviour_.

I suspect the above race be avoided by making force_sig() and
wake_up_process() atomic in kthread_stop() itself, please correct me
if I'm horribly wrong.

> I personally think Jeff's idea to use force_sig() is right. kthread_create()
> doesn't use CLONE_SIGHAND, so it is safe to change ->sighand->actionp[].
>
> (offtopic)
>
>         cifs_mount:
>
>                 send_sig(SIGKILL,srvTcp->tsk,1);
>                 tsk = srvTcp->tsk;
>                 if(tsk)
>                         kthread_stop(tsk);
>
> This "if(tsk)" looks wrong to me.

I think it's bogus myself. [ Added linux-cifs-client@lists.samba.org to Cc: ]

> Can srvTcp->tsk be NULL? If yes, send_sig()
> is not safe. Can srvTcp->tsk become NULL after send_sig() ? If yes, this
> check is racy, and kthread_stop() is not safe.

That's again something the atomicity I proposed above could avoid?

Please comment.

Satyam
