From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Fri, 4 May 2007 10:10:24 -0400
Message-ID: <20070504141024.GB8753@csclub.uwaterloo.ca>
References: <20070503203143.GA8753@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Len Sorensen <lsorense@csclub.uwaterloo.ca>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:48769 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755329AbXEDOKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 10:10:25 -0400
Content-Disposition: inline
In-Reply-To: <20070503203143.GA8753@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 03, 2007 at 04:31:43PM -0400, Lennart Sorensen wrote:
> I have had this happen a few times recently and was wondering if anyone
> has an idea what could be going on:
> 
> BUG: soft lockup detected on CPU#0!
>  [<c0103fc4>] dump_stack+0x24/0x30
>  [<c013d71e>] softlockup_tick+0x7e/0xc0
>  [<c011eb23>] update_process_times+0x33/0x80
>  [<c01062c9>] timer_interrupt+0x39/0x80
>  [<c013daad>] handle_IRQ_event+0x3d/0x70
>  [<c013de09>] __do_IRQ+0xa9/0x150
>  [<c0104e55>] do_IRQ+0x25/0x60
>  [<c010313a>] common_interrupt+0x1a/0x20
>  [<d084e00c>] pcnet32_dwio_read_csr+0xc/0x20 [pcnet32]
>  [<d084e9d2>] pcnet32_interrupt+0x42/0x2b0 [pcnet32]
>  [<c013daad>] handle_IRQ_event+0x3d/0x70
>  [<c013de09>] __do_IRQ+0xa9/0x150
>  [<c0104e55>] do_IRQ+0x25/0x60
>  [<c010313a>] common_interrupt+0x1a/0x20
>  [<c013da88>] handle_IRQ_event+0x18/0x70
>  [<c013de09>] __do_IRQ+0xa9/0x150
>  [<c0104e55>] do_IRQ+0x25/0x60
>  [<c010313a>] common_interrupt+0x1a/0x20
>  [<00005791>] 0x5791
> 
> This is on a system running a Geode LX at 500MHz, using 2.6.18 based
> kernel (specifically a slightly modified debian 4.0 Etch kernel).
> 
> I am really wondering where do I go looking for the cause of this.  The
> same kernel running on a Geode SC1200 (GX1) does not appear to do this.
> 
> If I knew what the error meant I would have a better idea how to debug
> it and fix it.

I looked at the pcnet32_interrupt function and where it calls
pcnet32_dwio_read_csr and saw this:

2550 /* The PCNET32 interrupt handler. */
2551 static irqreturn_t
2552 pcnet32_interrupt(int irq, void *dev_id)
2553 {
2554         struct net_device *dev = dev_id;
2555         struct pcnet32_private *lp;
2556         unsigned long ioaddr;
2557         u16 csr0;
2558         int boguscnt = max_interrupt_work;
2559
2560         ioaddr = dev->base_addr;
2561         lp = netdev_priv(dev);
2562
2563         spin_lock(&lp->lock);
2564
2565         csr0 = lp->a.read_csr(ioaddr, CSR0);
2566         while ((csr0 & 0x8f00) && --boguscnt >= 0) {
2567                 if (csr0 == 0xffff) {
2568                         break;  /* PCMCIA remove happened */

So I wonder, what happens if an interrupt occours, and since one of the
devices on that interrupt is the pcnet32 so it grabs the port lock, goes
to read CSR0, and then another interrupt occours on the same IRQ line
(I run with PREEMPT enabled if that matters) and the pcnet32 interrupt
handler is called again but since the port is already locked it has to
wait, causing the cpu to be locked up.

Should line 2563 be a spin_lock_irqsave instead along with the
appropriate unluck later?

--
Len Sorensen
