From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v2 3/3] via-velocity: Fix races on shared interrupts
Date: Wed, 10 Feb 2010 10:38:25 +0100
Message-ID: <20100210103825.6e9f6e09@marrow.netinsight.se>
References: <20100205165253.3f316b98@marrow.netinsight.se>
	<20100209.163133.38216503.davem@davemloft.net>
	<20100210103358.41a45851@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, ben@decadent.org.uk
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:57937 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753739Ab0BJJid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 04:38:33 -0500
In-Reply-To: <20100210103358.41a45851@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes two potential races in the velocity driver:

* Move the ACK and error handler to the interrupt handler. This fixes a
  potential race with shared interrupts when the other device interrupts
  before the NAPI poll handler has finished. As the velocity driver hasn't
  acked it's own interrupt, it will then steal the interrupt from the
  other device.

* Use spin_lock_irqsave in velocity_poll. In the current code, the
  interrupt handler will deadlock if e.g., the NAPI poll handler is
  executing when an interrupt (for another device) comes in since it
  tries to take the already held lock.

  Also unlock the spinlock only after enabling the interrupt in
  velocity_poll.

The error path is moved to the interrupt handler since this is where the
ISR is checked now.

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
Signed-off-by: Anders Grafstrom <anders.grafstrom@netinsight.net>
---
ChangeLog:
	* (David Miller): Remove spin_trylock from the interrupt handler
	* (David Miller): Use spin_lock_irqsave in velocity_poll
	* Move spin_unlock_irqrestore below mac_enable_int in velocity_poll

 drivers/net/via-velocity.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 5e213f7..18770ac 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2148,16 +2148,9 @@ static int velocity_poll(struct napi_struct *napi, int budget)
 	struct velocity_info *vptr = container_of(napi,
 			struct velocity_info, napi);
 	unsigned int rx_done;
-	u32 isr_status;
-
-	spin_lock(&vptr->lock);
-	isr_status = mac_read_isr(vptr->mac_regs);
-
-	/* Ack the interrupt */
-	mac_write_isr(vptr->mac_regs, isr_status);
-	if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
-		velocity_error(vptr, isr_status);
+	unsigned long flags;
 
+	spin_lock_irqsave(&vptr->lock, flags);
 	/*
 	 * Do rx and tx twice for performance (taken from the VIA
 	 * out-of-tree driver).
@@ -2167,13 +2160,12 @@ static int velocity_poll(struct napi_struct *napi, int budget)
 	rx_done += velocity_rx_srv(vptr, budget - rx_done);
 	velocity_tx_srv(vptr);
 
-	spin_unlock(&vptr->lock);
-
 	/* If budget not fully consumed, exit the polling mode */
 	if (rx_done < budget) {
 		napi_complete(napi);
 		mac_enable_int(vptr->mac_regs);
 	}
+	spin_unlock_irqrestore(&vptr->lock, flags);
 
 	return rx_done;
 }
@@ -2203,10 +2195,17 @@ static irqreturn_t velocity_intr(int irq, void *dev_instance)
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

