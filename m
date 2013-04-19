From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Fri, 19 Apr 2013 08:52:44 -0400
Message-ID: <20130419125244.GB19017@hmsreliant.think-freely.org>
References: <5166BDAA.3000603@acm.org>
 <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
 <5166F35B.1040200@acm.org>
 <20130411191409.GA9790@hmsreliant.think-freely.org>
 <5167A953.1020900@acm.org>
 <20130412113232.GA19966@hmsreliant.think-freely.org>
 <516813A0.1040300@acm.org>
 <20130419083802.GA27023@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57596 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968346Ab3DSMw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:52:58 -0400
Content-Disposition: inline
In-Reply-To: <20130419083802.GA27023@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 10:38:02AM +0200, Ingo Molnar wrote:
> 
> * Bart Van Assche <bvanassche@acm.org> wrote:
> 
> > WARNING: at kernel/mutex.c:313 __mutex_unlock_slowpath+0x157/0x160()
> > Pid: 181, comm: kworker/0:1H Tainted: G           O 3.9.0-rc6-debug+ #1
> > Call Trace:
> > <IRQ>  [<ffffffff8103c3ef>] warn_slowpath_common+0x7f/0xc0
> > [<ffffffff8103c44a>] warn_slowpath_null+0x1a/0x20
> > [<ffffffff81432047>] __mutex_unlock_slowpath+0x157/0x160
> > [<ffffffff8143205e>] mutex_unlock+0xe/0x10
> > [<ffffffff8136d031>] netpoll_poll_dev+0x111/0x9a0
> > [<ffffffff81345f32>] ? __alloc_skb+0x82/0x2a0
> > [<ffffffff8136dac5>] netpoll_send_skb_on_dev+0x205/0x3b0
> > [<ffffffff8136e00a>] netpoll_send_udp+0x28a/0x3a0
> > [<ffffffffa0524843>] ? write_msg+0x53/0x110 [netconsole]
> > [<ffffffffa05248bf>] write_msg+0xcf/0x110 [netconsole]
> > [<ffffffff8103d7f1>] call_console_drivers.constprop.16+0xa1/0x120
> > [<ffffffff8103e848>] console_unlock+0x3f8/0x450
> > [<ffffffff8103ecce>] vprintk_emit+0x1ee/0x510
> > [<ffffffff812d1f2c>] dev_vprintk_emit+0x5c/0x70
> > [<ffffffff810ff047>] ? mempool_free_slab+0x17/0x20
> 
> I *really* think that using a mutex from a low level debug interface like netpoll 
> is a mistake. We want such interfaces to be as atomic and as self-contained as 
> possible: using spinlocks, which could possibly be converted to raw spinlocks, 
> etc.
> 
> mutexes should be used when there's an expectation of possibly long blocking time. 
> That's not really the case for netpoll, we either are able to generate the skb 
> right then and send it off, or we are in trouble, right?
> 
> Thanks,
> 
> 	Ingo
> 


Well, this is a very seldom used path.  The idea behind the use of a mutex was
simply to allow the close/open paths to sleep during those periods when they
occured in parallel with a netpoll operation. The only reason spinlocks weren't
used was because we're not supposed to enter the drivers ndo_open/close paths in
atomic context, as subsequents sleeps are possible.  Thats why the
netpoll_poll_napi path had a mutex_trylock operation.  As it turns out though,
thats unsafe for this use case because the mutex implementation uses a spin_lock
without disabling interrupts (leading to the possibility of deadlocks), which in
turn led to our discussion of weather or not converting the mutex internal
implementation to use spin_lock_irqsave, as that would make mutex_trylock safe
to use in irq/softirq context.

Its all a bit moot at this point though, as I've come up with an alternate
solution that I think satifies our needs just as well.  Using a wait_queue_head,
with some atomic flags, we can block dev_open and close while netpoll is
executing, and retain the ability to wake those processes up safely from irq
context.  Please take a look at my new patch and let me know what you think.

Thanks!
Neil
