From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Fri, 26 Jun 2009 16:50:27 +0200
Message-ID: <20090626145027.GA6534@redhat.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <20090625122416.GA23613@redhat.com> <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com> <4A442B65.8040701@gmail.com> <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com> <4A443033.8060401@gmail.com> <alpine.DEB.1.10.0906251947530.9517@makko.or.mcafeemobile.com> <20090626135742.GB3845@redhat.com> <alpine.DEB.1.10.0906261018580.16400@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56892 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbZFZSFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 14:05:05 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906261018580.16400@makko.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26, Davide Libenzi wrote:
>
> On Fri, 26 Jun 2009, Oleg Nesterov wrote:
>
> > And if we remove waitqueue_active() in xxx_update(), then lock/unlock is
> > not needed too.
> >
> > If xxx_poll() takes q->lock first, it can safely miss the changes in ->status
> > and schedule(): xxx_update() will take q->lock, notice the sleeper and wake
> > it up (ok, it will set ->triggered but this doesn't matter).
> >
> > If xxx_update() takes q->lock first, xxx_poll() must see the changes in
> > status after poll_wait()->unlock(&q->lock) (in fact, after lock, not unlock).
>
> Sure. The snippet above was just to show what typically the code does, not
> a suggestion on how to solve the socket case.

Yes, yes. I just meant you are right imho, we shouldn't add mb() into
add_wait_queue().

> But yeah, the problem in this case is the waitqueue_active() call. Without
> that, the wait queue lock/unlock in poll_wait() and the one in wake_up()
> guarantees the necessary barriers.
> Some might argue the costs of the lock/unlock of q->lock, and wonder if
> MBs are a more efficient solution. This is something I'm not going into.
> To me, it just looked not right having cross-matching MB in different
> subsystems.

This is subjective and thus up to maintainers, but personally I think you
are very, very right.

Perhaps we can add

	void sock_poll_wait(struct file *file, struct sock *sk, poll_table *pt)
	{
		if (pt) {
			poll_wait(file, sk->sk_sleep, pt);
			/*
			 * fat comment
			 */
			smp_mb(); // or smp_mb__after_unlock();
		}
	}

Oleg.

