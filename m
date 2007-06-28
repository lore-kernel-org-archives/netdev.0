From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH] RFC: have tcp_recvmsg() check kthread_should_stop() and treat it as if it were signalled
Date: Thu, 28 Jun 2007 06:14:04 +0530
Message-ID: <a781481a0706271744i9181641sff43e2053dde0f9@mail.gmail.com>
References: <20070608123527.9b4cdafe.jlayton@redhat.com>
	 <E1HwpmG-0008LW-00@gondolin.me.apana.org.au>
	 <20070609070826.7bd3480c.jlayton@redhat.com>
	 <a781481a0706251241n36126456x7f4b445a86d1a68f@mail.gmail.com>
	 <20070626115449.GA92@tv-sign.ru>
	 <a781481a0706261553i1e65e620o884708d0b068b0f8@mail.gmail.com>
	 <20070627122437.GA158@tv-sign.ru>
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
Received: from an-out-0708.google.com ([209.85.132.248]:59463 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758732AbXF1AoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 20:44:06 -0400
Received: by an-out-0708.google.com with SMTP id d31so80735and
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 17:44:05 -0700 (PDT)
In-Reply-To: <20070627122437.GA158@tv-sign.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oleg,

On 6/27/07, Oleg Nesterov <oleg@tv-sign.ru> wrote:
> On 06/27, Satyam Sharma wrote:
> >
> > Thanks for your comments, I'm still not convinced, however.
>
> An perhaps you are right. I don't have a very strong opinion on that.
> Still I can't understand why it is better if kthread_stop() sends a
> signal as well.
> [...]
> One can always use force_sig() or allow_signal() + send_sig() when
> it is really needed, like cifs does.

The way I look at it, this is about an API being the one with "least surprise".
So when one writes a kthread using its API, one would expect
kthread_stop() to dtrt and just work, which it will not, if the kthread has one
of such functions (which are just like any other, after all). Also, imagine
such a function being added to a kthread that didn't have it previously ...
the solution to which (sending a signal before kthread_stop) is un-intuitive.
Hence, why not make it part of the API itself ... It's not like the signal
would do any harm to other kthreads (that don't use such function) either.

> Contrary, I believe we should avoid signals when it
> comes to kernel threads.

And I agree, but there's quite a subtle difference between signals being
used like they normally are, and this case here. Fact is, there is simply
no other way to break out of certain functions (if there was, I would've
preferred that myself).

In fact, what I'm proposing is that kthreads should *not* be tinkering
with (flushing, handling, dequeueing, whatever) signals at all, because
like you mentioned, if they do that, it's possible that the TIF_SIGPENDING
could get lost.

> > Anyway, I think _all_ usages of kthread_stop() in the kernel *do* want
> > the thread to stop *right then*. After all, kthread_stop() doesn't even
> > return (gets blocked on wait_for_completion()) till it knows the target
> > kthread *has* exited completely.
>
> Yes, kthread_stop(k) means that k should exit eventually, but I don't
> think that kthread_stop() should try to force the exit.

Well, it's just an additional notice (apart from setting kthread_stop_info)
sent to the target kthread that its time has come ... I'm not sure how a
kthread would have exit "forced" upon it just by sending it a signal.
Also, note that _not_ using a signal would in fact mean that the kthread
_never_ exits at all (forget asap).

> I am talking about the case
> when wait_event_interruptible() should not fail (unless something bad
> happens) inside the "while (!kthread_should_stop())" loop.
> Note also that kthread could use TASK_INTERRUPTIBLE sleep
> [...] and because it knows that all signals are ignored.

Ok, I think you're saying that if a kthread used wait_event_interruptible
(and was not expecting signals, because it ignores them), then bad
things (say exit in inconsistent state, etc) will happen if we break that
wait_event_interruptible unexpectedly.

First, such an error ought to be handled gracefully by kthread itself
anyway -- anybody who doesn't check the return of _interruptible()
functions is just asking for trouble.

Second, the kthread must expect that the stop notification _could_
have come during that sleep (in fact all good kthreads I've seen do
always put a kthread_should_stop() after all such blocking functions,
and not only in the while loop's condition) -- but even if it doesn't check
explicitly, what do we lose? If the kthread code _after_ the
wait_event_interruptible is written such that it assumes that the wait
condition has become true (as I mentioned above), then that code is
inherently buggy.

And thirdly, what I'm proposing is putting the check for checking the
SIGKILL in kthread_should_stop itself, in /addition/ to the
kthread_stop_info.k == current check. So the kthread will check
should_stop(), and if true, then exiting cleanly -- this is something that
all existing kthreads would do already (if some kthread out there exits
_uncleanly_ even after seeing seeing kthread_should_stop == true,
then it needs fixing anyway).

Satyam
