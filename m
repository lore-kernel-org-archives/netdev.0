From: David Howells <dhowells@redhat.com>
Subject: Re: Getting the new RxRPC patches upstream
Date: Tue, 24 Apr 2007 14:37:04 +0100
Message-ID: <9767.1177421824@redhat.com>
References: <20070423171157.GA205@tv-sign.ru>  <20070420212835.GA863@tv-sign.ru> <20070420.015838.83621529.davem@davemloft.net> <29341.1176975158@redhat.com> <2969.1176992303@redhat.com> <1101.1177056127@redhat.com> <4713.1177065706@redhat.com> <20070420113805.c4877dc8.akpm@linux-foundation.org> <1355.1177317176@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	containers@lists.osdl.org, hch@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422651AbXDXNhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 09:37:38 -0400
In-Reply-To: <20070423171157.GA205@tv-sign.ru> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oleg Nesterov <oleg@tv-sign.ru> wrote:

> > > We only care when del_timer() returns true. In that case, if the timer
> > > function still runs (possible for single-threaded wqs), it has already
> > > passed __queue_work().
> > 
> > Why do you assume that?

Sorry, I should have been more clear.  I meant the assumption that we only
care about a true return from del_timer().

> If del_timer() returns true, the timer was pending. This means it was
> started by work->func() (note that __run_timers() clears timer_pending()
> before calling timer->function). This in turn means that
> delayed_work_timer_fn() has already called __queue_work(dwork), otherwise
> work->func() has no chance to run.

But if del_timer() returns 0, then there may be a problem.  We can't tell the
difference between the following two cases:

 (1) The timer hadn't been started.

 (2) The timer had been started, has expired and is no longer pending, but
     another CPU is running its handler routine.

try_to_del_timer_sync() _does_, however, distinguish between these cases: the
first is the 0 return, the second is the -1 return, and the case where it
dequeued the timer is the 1 return.

BTW, can a timer handler be preempted?  I assume not...  But it can be delayed
by interrupt processing.

David
