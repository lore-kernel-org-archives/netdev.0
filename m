From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from spin_lock_mutex
Date: Thu, 11 Apr 2013 17:54:28 +0200
Message-ID: <2032636.RnfJ0d1BWA@cpaasch-mac>
References: <5166BDAA.3000603@acm.org> <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:53707 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587Ab3DKPyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 11:54:35 -0400
In-Reply-To: <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 April 2013 11:18:06 Neil Horman wrote:
> Bart, this patch should fix your problem.  Could you please test it and
> confirm?
> 
> Bart Van Assche recently reported a warning to me:
> 
> <IRQ>  [<ffffffff8103d79f>] warn_slowpath_common+0x7f/0xc0
>  [<ffffffff8103d7fa>] warn_slowpath_null+0x1a/0x20
>  [<ffffffff814761dd>] mutex_trylock+0x16d/0x180
>  [<ffffffff813968c9>] netpoll_poll_dev+0x49/0xc30
>  [<ffffffff8136a2d2>] ? __alloc_skb+0x82/0x2a0
>  [<ffffffff81397715>] netpoll_send_skb_on_dev+0x265/0x410
>  [<ffffffff81397c5a>] netpoll_send_udp+0x28a/0x3a0
>  [<ffffffffa0541843>] ? write_msg+0x53/0x110 [netconsole]
>  [<ffffffffa05418bf>] write_msg+0xcf/0x110 [netconsole]
>  [<ffffffff8103eba1>] call_console_drivers.constprop.17+0xa1/0x1c0
>  [<ffffffff8103fb76>] console_unlock+0x2d6/0x450
>  [<ffffffff8104011e>] vprintk_emit+0x1ee/0x510
>  [<ffffffff8146f9f6>] printk+0x4d/0x4f
>  [<ffffffffa0004f1d>] scsi_print_command+0x7d/0xe0 [scsi_mod]
> 
> This resulted from my commit ca99ca14c which introduced a mutex_trylock
> operation in a path that could execute in interrupt context.  When mutex
> debugging is enabled, the above warns the user when we are in fact
> exectuting in interrupt context.
> 
> I think this is a false positive however.  The check is intended to catch
> users who might be issuing sleeping calls in irq context, but the use of
> mutex_trylock here is guaranteed not to sleep.

Even if he does not sleep, may we still hit a deadlock like the following:

netpoll_rx_disable() calls mutex_lock(), who ends up in __mutex_lock_common, 
calling spin_lock_mutex().

Immediatly after that, on the same CPU, the interrupt comes and 
netpoll_poll_dev calls mutex_trylock and ends up also calling 
spin_lock_mutex(). Now, it seems to me that we are deadlocked - the interrupt 
is spinning on the lock, because netpoll_rx_disable() already took it.

Or maybe I am missing something?


Cheers,
Christoph

-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
UCLouvain
--
