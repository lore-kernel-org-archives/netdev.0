From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1)
 instead of yield() to wait for outstanding qdisc_run callsb
Date: Wed, 02 Apr 2014 04:17:39 -0700
Message-ID: <1396437459.3989.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>
	 <20140306.160622.59358366688518505.davem@davemloft.net>
	 <1394392160.15968.13.camel@deadeye.wl.decadent.org.uk>
	 <20140309.185338.2057082497431220324.davem@davemloft.net>
	 <alpine.DEB.2.02.1403312333100.14882@ionos.tec.linutronix.de>
	 <20140402110743.GG27965@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>, ben@decadent.org.uk,
	mkl@pengutronix.de,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:63236 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758184AbaDBLRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 07:17:42 -0400
In-Reply-To: <20140402110743.GG27965@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-02 at 13:07 +0200, Peter Zijlstra wrote:
> On Mon, Mar 31, 2014 at 11:49:16PM +0200, Thomas Gleixner wrote:
> > > >> The intent of a yield() call, like this one here, is unambiguously
> > > >> that the current thread cannot do anything until some other thread
> > > >> gets onto the cpu and makes forward progress.
> 
> Yeah; like Thomas said; that's not what yield() does -- or can do.
> 
> yield() only says 'I don't know what to do, you figure it out', but then
> fails to provide enough information to actually do something sensible.
> 
> It cannot put the task to sleep; because it doesn't pair with a wakeup;
> and therefore the task stays an eligible/runnable task from a scheduler
> pov.
> 
> The scheduler is therefore entirely in its right to pick this task
> again; and pretty much has to under many circumstances.
> 
> yield() does not, and can not, guarantee forward progress - ever.
> 
> Use wait_event() and assorted bits to wait for an actual event. That is
> a sleep paired with a wakeup and thus has progress guarantees.

Why wouldn't it be safe to redefine yield as msleep(1) ?

net/ipv4/tcp_output.c seems to also use yield().


                /* Socket is locked, keep trying until memory is available. */
                for (;;) {
                        skb = alloc_skb_fclone(MAX_TCP_HEADER,
                                               sk->sk_allocation);
                        if (skb)
                                break;
                        yield();
                }
