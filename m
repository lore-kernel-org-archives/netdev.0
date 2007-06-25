From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH] RFC: have tcp_recvmsg() check kthread_should_stop() and treat it as if it were signalled
Date: Tue, 26 Jun 2007 01:11:20 +0530
Message-ID: <a781481a0706251241n36126456x7f4b445a86d1a68f@mail.gmail.com>
References: <20070608123527.9b4cdafe.jlayton@redhat.com>
	 <E1HwpmG-0008LW-00@gondolin.me.apana.org.au>
	 <20070609070826.7bd3480c.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Oleg Nesterov" <oleg@tv-sign.ru>
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:44602 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039AbXFYTlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 15:41:21 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1471254nzf
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 12:41:20 -0700 (PDT)
In-Reply-To: <20070609070826.7bd3480c.jlayton@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 6/9/07, Jeff Layton <jlayton@redhat.com> wrote:
> On Sat, 09 Jun 2007 11:30:04 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> > Please cc networking patches to netdev@vger.kernel.org.
> >
> > Jeff Layton <jlayton@redhat.com> wrote:
> > >
> > > The following patch is a first stab at removing this need. It makes it
> > > so that in tcp_recvmsg() we also check kthread_should_stop() at any
> > > point where we currently check to see if the task was signalled. If
> > > that returns true, then it acts as if it were signalled and returns to
> > > the calling function.

I got bit by the same thing when I was implementing a kthread that sleeps
on skb_recv_datagram() (=> wait_for_packet) with noblock = 0 over a netlink
socket. I need to use the same SIGKILL hack before kthread_stop() to ensure
the kthread does wake up *and* unblock from skb_recv_datagram() when the
module is being unloaded. Searched hard, but just couldn't find a prettier
solution (if someone knows, please let me know).

> > This just doesn't seem to fit.  Why should networking care about kthreads?

I agree.

> > Perhaps you can get kthread_stop to send a signal instead?

Yes, why not embed a send_sig(SIGKILL) just before the wake_up_process()
in kthread_stop() itself?

Looking at some happily out-of-date comments in the kthread code, I can
guess that at some point of time (perhaps very early drafts) Rusty actually
*did* implement the whole kthread_stop() functionality using signals, but
I suspect it might've been discarded and the kthread_stop_info approach
used instead to protect from spurious signals from userspace. (?)

So could we have signals in _addition_ to kthread_stop_info and change
kthread_should_stop() to check for both:

kthread_stop_info.k == current && signal_pending(current)

If !kthread_should_stop() && signal_pending(current) => spurious signal,
so just flush and discard (in the kthread).

> The problem there is that we still have to make the kthread let signals
> through. The nice thing about this approach is that we can make the
> kthread ignore signals, but still allow it to break out of kernel_recvmsg
> when a kthread_stop is done.

Why is it wrong for kthreads to let signals through? We can ignore out
all signals we're not interested in, and flush the spurious ones ...
otherwise there really isn't much those kthreads can do that get blocked
in such functions, is there?

Satyam
