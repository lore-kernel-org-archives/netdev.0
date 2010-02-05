From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH 3/3] via-velocity: Fix races on shared interrupts
Date: Fri, 5 Feb 2010 16:55:45 +0100
Message-ID: <20100205165545.28832c53@marrow.netinsight.se>
References: <20100205165253.3f316b98@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, ben@decadent.org.uk
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:34084 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751252Ab0BEPzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 10:55:52 -0500
In-Reply-To: <20100205165253.3f316b98@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes two potential races in the velocity driver:

* Move the ACK and error handler to the interrupt handler. This fixes a
  potential race with shared interrupts when the other device interrupts
  before the NAPI poll handler has finished. As the velocity driver hasn't
  acked it's own interrupt, it will then steal the interrupt from the
  other device.

* Use spin_trylock in the interrupt handler. To avoid having the
  interrupt off for long periods of time, velocity_poll uses non-irqsave
  spinlocks. In the current code, the interrupt handler will deadlock if
  e.g., the NAPI poll handler is executing when an interrupt (for another
  device) comes in since it tries to take the already held lock.

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
Signed-off-by: Anders Grafstrom <anders.grafstrom@netinsight.net>
---
 drivers/net/via-velocity.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 5e213f7..6882e7c 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2148,16 +2148,8 @@ static int velocity_poll(struct napi_struct *napi, int budget)
 	struct velocity_info *vptr = container_of(napi,
 			struct velocity_info, napi);
 	unsigned int rx_done;
-	u32 isr_status;
 
 	spin_lock(&vptr->lock);
-	isr_status = mac_read_isr(vptr->mac_regs);
-
-	/* Ack the interrupt */
-	mac_write_isr(vptr->mac_regs, isr_status);
-	if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
-		velocity_error(vptr, isr_status);
-
 	/*
 	 * Do rx and tx twice for performance (taken from the VIA
 	 * out-of-tree driver).
@@ -2194,7 +2186,16 @@ static irqreturn_t velocity_intr(int irq, void *dev_instance)
 	struct velocity_info *vptr = netdev_priv(dev);
 	u32 isr_status;
 
-	spin_lock(&vptr->lock);
+	/* Check if the lock is taken, and if so ignore the interrupt. This
+	 * can happen with shared interrupts, where the other device can
+	 * interrupt during velocity_poll (where the lock is held).
+	 *
+	 * With spinlock debugging active on a uniprocessor, this will give
+	 * a warning which can safely be ignored.
+	 */
+	if (!spin_trylock(&vptr->lock))
+		return IRQ_NONE;
+
 	isr_status = mac_read_isr(vptr->mac_regs);
 
 	/* Not us ? */
@@ -2203,10 +2204,17 @@ static irqreturn_t velocity_intr(int irq, void *dev_instance)
 		return IRQ_NONE;
 	}
 
+	/* Ack the interrupt */
+	mac_write_isr(vptr->mac_regs, isr_status);
+
 	if (likely(napi_schedule_prep(&vptr->napi))) {
 		mac_disable_int(vptr->mac_regs);
 		__napi_schedule(&vptr->napi);
 	}
+
+	if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
+		velocity_error(vptr, isr_status);
+
 	spin_unlock(&vptr->lock);
 
 	return IRQ_HANDLED;
-- 
1.6.0.4

