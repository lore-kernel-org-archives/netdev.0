From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH (take 2)] request_irq fix DEBUG_SHIRQ handling Re: 2.6.23-rc2-mm1: rtl8139 inconsistent lock state
Date: Thu, 23 Aug 2007 10:44:30 +0200
Message-ID: <20070823084430.GB1980@ff.dom.local>
References: <200708100149.14446.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mariusz Kozlowski <m.kozlowski@tuxland.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:58777 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751039AbXHWInZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 04:43:25 -0400
Content-Disposition: inline
In-Reply-To: <200708100149.14446.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton pointed out that my changelog was unusable. Sorry!
Here is a second try with the changelog and kernel version changed.

Regards,
Jarek P.

------------>(take 2)

Subject: request_irq() - fix DEBUG_SHIRQ handling

Mariusz Kozlowski reported lockdep's warning:

> =================================
> [ INFO: inconsistent lock state ]
> 2.6.23-rc2-mm1 #7
> ---------------------------------
> inconsistent {in-hardirq-W} -> {hardirq-on-W} usage.
> ifconfig/5492 [HC0[0]:SC0[0]:HE1:SE1] takes:
>  (&tp->lock){+...}, at: [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
> {in-hardirq-W} state was registered at:
>   [<c0138eeb>] __lock_acquire+0x949/0x11ac
>   [<c01397e7>] lock_acquire+0x99/0xb2
>   [<c0452ff3>] _spin_lock+0x35/0x42
>   [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
>   [<c0147a5d>] handle_IRQ_event+0x28/0x59
>   [<c01493ca>] handle_level_irq+0xad/0x10b
>   [<c0105a13>] do_IRQ+0x93/0xd0
>   [<c010441e>] common_interrupt+0x2e/0x34
...
> other info that might help us debug this:
> 1 lock held by ifconfig/5492:
>  #0:  (rtnl_mutex){--..}, at: [<c0451778>] mutex_lock+0x1c/0x1f
> 
> stack backtrace:
...
>  [<c0452ff3>] _spin_lock+0x35/0x42
>  [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
>  [<c01480fd>] free_irq+0x11b/0x146
>  [<de871d59>] rtl8139_close+0x8a/0x14a [8139too]
>  [<c03bde63>] dev_close+0x57/0x74
...

This shows that a driver's irq handler was running both in hard interrupt
and process contexts with irqs enabled. The latter was done during
free_irq() call and was possible only with CONFIG_DEBUG_SHIRQ enabled.
This was fixed by another patch.

But similar problem is possible with request_irq(): any locks taken from
irq handler could be vulnerable - especially with soft interrupts. This
patch fixes it by disabling local interrupts during handler's run. (It
seems, disabling softirqs should be enough, but it needs more checking
on possible races or other special cases).

This patch is recommended to all stable versions since 2.6.21, too.

Reported-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp 2.6.23-rc3-git6-/kernel/irq/manage.c 2.6.23-rc3-git6/kernel/irq/manage.c
--- 2.6.23-rc3-git6-/kernel/irq/manage.c	2007-08-23 10:11:35.000000000 +0200
+++ 2.6.23-rc3-git6/kernel/irq/manage.c	2007-08-23 10:16:29.000000000 +0200
@@ -555,14 +555,11 @@ int request_irq(unsigned int irq, irq_ha
 		 * We do this before actually registering it, to make sure that
 		 * a 'real' IRQ doesn't run in parallel with our fake
 		 */
-		if (irqflags & IRQF_DISABLED) {
-			unsigned long flags;
+		unsigned long flags;
 
-			local_irq_save(flags);
-			handler(irq, dev_id);
-			local_irq_restore(flags);
-		} else
-			handler(irq, dev_id);
+		local_irq_save(flags);
+		handler(irq, dev_id);
+		local_irq_restore(flags);
 	}
 #endif
 
