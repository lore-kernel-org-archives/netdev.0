From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Fri, 26 Jun 2009 15:57:42 +0200
Message-ID: <20090626135742.GB3845@redhat.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <20090625122416.GA23613@redhat.com> <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com> <4A442B65.8040701@gmail.com> <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com> <4A443033.8060401@gmail.com> <alpine.DEB.1.10.0906251947530.9517@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758968AbZFZRMb@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906251947530.9517@makko.or.mcafeemobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/25, Davide Libenzi wrote:
>
> Not all the code that uses add_wait_queue() does need to have the MB,
> like code that does the most common pattern:
>
> xxx_poll(...) {
> 	poll_wait(...);
> 	lock();
> 	flags = calc_flags(->status);
> 	unlock();
> 	return flags;
> }
>
> xxx_update(...) {
> 	lock();
> 	->status = ...;
> 	unlock();
> 	if (waitqueue_active())
> 		wake_up();
> }
>
> It's the code that does the lockless flags calculation in ->poll that
> might need it.

And if we remove waitqueue_active() in xxx_update(), then lock/unlock is
not needed too.

If xxx_poll() takes q->lock first, it can safely miss the changes in ->status
and schedule(): xxx_update() will take q->lock, notice the sleeper and wake
it up (ok, it will set ->triggered but this doesn't matter).

If xxx_update() takes q->lock first, xxx_poll() must see the changes in
status after poll_wait()->unlock(&q->lock) (in fact, after lock, not unlock).

Oleg.
