From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/3] forcedeth: fix NAPI hang in IRQ.
Date: Thu, 27 Jul 2006 19:01:14 -0700
Message-ID: <20060727190114.68bfd817@localhost>
References: <20060728015007.625581647@localhost>
	<20060728015054.566221096@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39095 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932117AbWG1CBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 22:01:30 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060728015054.566221096@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix for NAPI hanging in interrupt. With NAPI, we only need one
iteration over the IRQ.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.orig/drivers/net/forcedeth.c	2006-07-27
18:58:21.000000000 -0700 +++ linux-2.6/drivers/net/forcedeth.c
2006-07-27 18:57:31.000000000 -0700 @@ -2422,10 +2422,11 @@
 						dev->name, events);
 		}
 #ifdef CONFIG_FORCEDETH_NAPI
-		if (netif_rx_schedule_prep(dev)) {
-			__netif_rx_schedule(dev);
+		if (events & NVREG_IRQ_RX_ALL) {
+			netif_rx_schedule(dev);
 			nv_disable_hw_interrupts(dev,
NVREG_IRQ_RX_ALL); }
+		return IRQ_HANDLED;
 #else
 		nv_rx_process(dev, dev->weight);
 		if (nv_alloc_rx(dev)) {
@@ -2434,7 +2435,6 @@
 				mod_timer(&np->oom_kick, jiffies +
OOM_REFILL); spin_unlock(&np->lock);
 		}
-#endif
 		if (i > max_interrupt_work) {
 			spin_lock(&np->lock);
 			/* disable interrupts on the nic */
@@ -2452,7 +2452,7 @@
 			spin_unlock(&np->lock);
 			break;
 		}
-
+#endif
 	}
 	dprintk(KERN_DEBUG "%s: nv_nic_irq completed\n", dev->name);
 
