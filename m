From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10435] New: IRQ problem using PLIP installing
 linux on OLD IBM laptop
Date: Thu, 10 Apr 2008 09:46:39 -0700
Message-ID: <20080410094639.991b6372.akpm@linux-foundation.org>
References: <bug-10435-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, cijoml@volny.cz,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60026 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755966AbYDJQrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 12:47:35 -0400
In-Reply-To: <bug-10435-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 10 Apr 2008 02:27:07 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10435
> 
>            Summary: IRQ problem using PLIP installing linux on OLD IBM
>                     laptop
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24.4-vanilla, 2.6.18-debian-stable
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Parallel
>         AssignedTo: drivers_parallel@kernel-bugs.osdl.org
>         ReportedBy: cijoml@volny.cz
> 
> 
> Latest working kernel version:
> Earliest failing kernel version:
> Distribution:
> Hardware Environment: PLIP, LPT
> Software Environment: Debian stable, Debian testing
> Problem Description:
> 
> plip0: checksum error
> Unbalanced enable for IRQ 7
> WARNING: at kernel/irq/manage.c:174 enable_irq()
> Pid: 8, comm: events/1 Not tainted 2.6.24.4 #3
> 
> Call Trace:
>  [<ffffffff80264f11>] enable_irq+0x7a/0xba
>  [<ffffffff8817cac8>] :plip:plip_error+0x7b/0xaf
>  [<ffffffff8817c21b>] :plip:plip_bh+0x4e/0x274
>  [<ffffffff8817c1cd>] :plip:plip_bh+0x0/0x274
>  [<ffffffff8024227e>] run_workqueue+0x87/0x11a
>  [<ffffffff80242c96>] worker_thread+0xe1/0xf0
>  [<ffffffff80245de4>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff80242bb5>] worker_thread+0x0/0xf0
>  [<ffffffff80245cc2>] kthread+0x47/0x75
>  [<ffffffff8020c5e8>] child_rip+0xa/0x12
>  [<ffffffff80245c7b>] kthread+0x0/0x75
>  [<ffffffff8020c5de>] child_rip+0x0/0x12
> 
> I see little bit different stack trace also at old IBM laptop side. Will try
> post photo.
> There are also lot of plip0: transmit timeout(1,80) messages on both sides.
> 
> 
> Steps to reproduce:
> Connect computers using parallel laplink cable, try networking
> 

We did recently fix an interrupt-related bug in plip, but I doubt if it'll
fix this problem.  The patch is below.  I'll forward it to the -stable team
for consideration in 2.6.24.x.

I assume that the driver actually continues to work OK, and that this is
just an irritating warning?


commit cabce28ec0a0ae3d0ddfa4461f0e8be94ade9e46
Author: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Date:   Tue Apr 1 01:22:45 2008 +0200

    plip: replace spin_lock_irq with spin_lock_irqsave in irq context
    
    Plip uses spin_lock_irq/spin_unlock_irq in its IRQ handler (called from
    parport IRQ handler), the latter enables interrupts without parport
    subsystem IRQ handler expecting it.
    
    The bug can be seen if you compile kernel with lock dependency checking
    and use plip --- it produces a warning.
    
    This patch changes it to spin_lock_irqsave/spin_lock_irqrestore, so that
    it doesn't enable interrupts when already disabled.
    
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index fee3d7b..1e96542 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -903,17 +903,18 @@ plip_interrupt(void *dev_id)
 	struct net_local *nl;
 	struct plip_local *rcv;
 	unsigned char c0;
+	unsigned long flags;
 
 	nl = netdev_priv(dev);
 	rcv = &nl->rcv_data;
 
-	spin_lock_irq (&nl->lock);
+	spin_lock_irqsave (&nl->lock, flags);
 
 	c0 = read_status(dev);
 	if ((c0 & 0xf8) != 0xc0) {
 		if ((dev->irq != -1) && (net_debug > 1))
 			printk(KERN_DEBUG "%s: spurious interrupt\n", dev->name);
-		spin_unlock_irq (&nl->lock);
+		spin_unlock_irqrestore (&nl->lock, flags);
 		return;
 	}
 
@@ -942,7 +943,7 @@ plip_interrupt(void *dev_id)
 		break;
 	}
 
-	spin_unlock_irq(&nl->lock);
+	spin_unlock_irqrestore(&nl->lock, flags);
 }
 
 static int

