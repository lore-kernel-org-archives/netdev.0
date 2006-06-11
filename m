From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 7/8] lock validator: fix ns83820.c irq-flags bug
Date: Sun, 11 Jun 2006 10:55:42 -0400
Message-ID: <448C2EEE.1020405@garzik.org>
References: <200606090519.k595JmDG032032@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu, bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:7389 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751595AbWFKOzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 10:55:47 -0400
To: akpm@osdl.org, arjan@linux.intel.com
In-Reply-To: <200606090519.k595JmDG032032@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Ingo Molnar <mingo@elte.hu>
> 
> Barry K. Nathan reported the following lockdep warning:
> 
> [  197.343948] BUG: warning at kernel/lockdep.c:1856/trace_hardirqs_on()
> [  197.345928]  [<c010329b>] show_trace_log_lvl+0x5b/0x105
> [  197.346359]  [<c0103896>] show_trace+0x1b/0x20
> [  197.346759]  [<c01038ed>] dump_stack+0x1f/0x24
> [  197.347159]  [<c012efa2>] trace_hardirqs_on+0xfb/0x185
> [  197.348873]  [<c029b009>] _spin_unlock_irq+0x24/0x2d
> [  197.350620]  [<e09034e8>] do_tx_done+0x171/0x179 [ns83820]
> [  197.350895]  [<e090445c>] ns83820_irq+0x149/0x20b [ns83820]
> [  197.351166]  [<c013b4b8>] handle_IRQ_event+0x1d/0x52
> [  197.353216]  [<c013c6c2>] handle_level_irq+0x97/0xe1
> [  197.355157]  [<c01048c3>] do_IRQ+0x8b/0xac
> [  197.355612]  [<c0102d9d>] common_interrupt+0x25/0x2c

The driver's locking is definitely wrong, but I don't think this is the 
fix, because PCI drivers with a single interrupt should be using 
spin_lock() in the interrupt handler.  Anything more would be uncivilized :)

/me starts to do a better patch...

Jesus, the locking here is awful.  No wonder there are bugs.

Since this driver isn't seeing a ton of work these days, I think the 
best thing to do would be to _simplify_ the locking.  This driver is 
grabbing so many locks, turning interrupts off+on so often that any 
benefit the multiple locks had is probably long gone, particularly on 
modern machines.

Let me see what I can do with it...

	Jeff


