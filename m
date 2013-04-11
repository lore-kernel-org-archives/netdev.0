From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Thu, 11 Apr 2013 13:04:05 -0400
Message-ID: <20130411170404.GE8986@neilslaptop.think-freely.org>
References: <5166BDAA.3000603@acm.org>
 <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
 <2032636.RnfJ0d1BWA@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: g@neilslaptop.think-freely.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57034 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331Ab3DKREZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:04:25 -0400
Content-Disposition: inline
In-Reply-To: <2032636.RnfJ0d1BWA@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 05:54:28PM +0200, Christoph Paasch wrote:
> On Thursday 11 April 2013 11:18:06 Neil Horman wrote:
> > Bart, this patch should fix your problem.  Could you please test it and
> > confirm?
> > 
> > Bart Van Assche recently reported a warning to me:
> > 
> > <IRQ>  [<ffffffff8103d79f>] warn_slowpath_common+0x7f/0xc0
> >  [<ffffffff8103d7fa>] warn_slowpath_null+0x1a/0x20
> >  [<ffffffff814761dd>] mutex_trylock+0x16d/0x180
> >  [<ffffffff813968c9>] netpoll_poll_dev+0x49/0xc30
> >  [<ffffffff8136a2d2>] ? __alloc_skb+0x82/0x2a0
> >  [<ffffffff81397715>] netpoll_send_skb_on_dev+0x265/0x410
> >  [<ffffffff81397c5a>] netpoll_send_udp+0x28a/0x3a0
> >  [<ffffffffa0541843>] ? write_msg+0x53/0x110 [netconsole]
> >  [<ffffffffa05418bf>] write_msg+0xcf/0x110 [netconsole]
> >  [<ffffffff8103eba1>] call_console_drivers.constprop.17+0xa1/0x1c0
> >  [<ffffffff8103fb76>] console_unlock+0x2d6/0x450
> >  [<ffffffff8104011e>] vprintk_emit+0x1ee/0x510
> >  [<ffffffff8146f9f6>] printk+0x4d/0x4f
> >  [<ffffffffa0004f1d>] scsi_print_command+0x7d/0xe0 [scsi_mod]
> > 
> > This resulted from my commit ca99ca14c which introduced a mutex_trylock
> > operation in a path that could execute in interrupt context.  When mutex
> > debugging is enabled, the above warns the user when we are in fact
> > exectuting in interrupt context.
> > 
> > I think this is a false positive however.  The check is intended to catch
> > users who might be issuing sleeping calls in irq context, but the use of
> > mutex_trylock here is guaranteed not to sleep.
> 
> Even if he does not sleep, may we still hit a deadlock like the following:
> 
> netpoll_rx_disable() calls mutex_lock(), who ends up in __mutex_lock_common, 
> calling spin_lock_mutex().
> 
> Immediatly after that, on the same CPU, the interrupt comes and 
> netpoll_poll_dev calls mutex_trylock and ends up also calling 
> spin_lock_mutex(). Now, it seems to me that we are deadlocked - the interrupt 
> is spinning on the lock, because netpoll_rx_disable() already took it.
> 
> Or maybe I am missing something?
> 
I dont believe the deadlock you describe can happen.  The spin_lock_mutex
operation disables irqs on the local cpu with local_irq_save, so we won't loose
the cpu while we're holding the spinlock.  Likewise we don't restore the irq
flags until after we release said lock.  Once we have the mutex, if we're
preempted by another path that goes through the netpoll_poll_dev path, then we
hit the trylock api call.  The spinlock is either released or held on another
cpu (read: no deadlock), and if the mutex is held, then the trylock simply
fails.

Thanks
Neil

> 
> Cheers,
> Christoph
> 
> -- 
> IP Networking Lab --- http://inl.info.ucl.ac.be
> MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
> UCLouvain
> --
> 
