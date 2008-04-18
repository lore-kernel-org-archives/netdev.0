From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 14/15] Canonicalize several irq handlers.
Date: Fri, 18 Apr 2008 19:23:04 -0400 (EDT)
Message-ID: <4e2ec1b6d54fae7c49007b8debf839c5cd24cb84.1208559659.git.jgarzik@redhat.com>
References: <d7afbccda111e535bb14ad8082b208c7a2cd9833.1208559659.git.jgarzik@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org, khali@linux-fr.org, dtor@mail.ru,
	lethal@linux-sh.org, linux-serial@vger.kernel.org
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <d7afbccda111e535bb14ad8082b208c7a2cd9833.1208559659.git.jgarzik@redhat.com>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* prefer passing data to irq handler using 'void *dev_id' argument

* remove references to 'irq' function arg that either duplicate
  a member of our private struct, or are always [true|false].

* add linux/interrupt.h include where needed

This change's main purpose is to prepare for the patchset in
jgarzik/misc-2.6.git#irq-remove, that explores removal of the
never-used 'irq' argument in each interrupt handler.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 drivers/atm/ambassador.c               |    7 ++++---
 drivers/i2c/chips/tps65010.c           |    4 ++--
 drivers/input/touchscreen/ucb1400_ts.c |   11 ++++-------
 drivers/serial/8250.c                  |    5 +++--
 include/asm-sh/push-switch.h           |    2 +-
 5 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 7b44a59..da41d26 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -862,8 +862,9 @@ static inline void interrupts_off (amb_dev * dev) {
 
 /********** interrupt handling **********/
 
-static irqreturn_t interrupt_handler(int irq, void *dev_id) {
-  amb_dev * dev = dev_id;
+static irqreturn_t interrupt_handler(int irq, void *dev_id)
+{
+  amb_dev *dev = dev_id;
   
   PRINTD (DBG_IRQ|DBG_FLOW, "interrupt_handler: %p", dev_id);
   
@@ -872,7 +873,7 @@ static irqreturn_t interrupt_handler(int irq, void *dev_id) {
   
     // for us or someone else sharing the same interrupt
     if (!interrupt) {
-      PRINTD (DBG_IRQ, "irq not for me: %d", irq);
+      PRINTD (DBG_IRQ, "no irq events pending");
       return IRQ_NONE;
     }
     
diff --git a/drivers/i2c/chips/tps65010.c b/drivers/i2c/chips/tps65010.c
index 4154a91..78b365c 100644
--- a/drivers/i2c/chips/tps65010.c
+++ b/drivers/i2c/chips/tps65010.c
@@ -437,11 +437,11 @@ static void tps65010_work(struct work_struct *work)
 	mutex_unlock(&tps->lock);
 }
 
-static irqreturn_t tps65010_irq(int irq, void *_tps)
+static irqreturn_t tps65010_irq(int dummy, void *_tps)
 {
 	struct tps65010		*tps = _tps;
 
-	disable_irq_nosync(irq);
+	disable_irq_nosync(tps->client->irq);
 	set_bit(FLAG_IRQ_ENABLE, &tps->flags);
 	(void) schedule_work(&tps->work.work);
 	return IRQ_HANDLED;
diff --git a/drivers/input/touchscreen/ucb1400_ts.c b/drivers/input/touchscreen/ucb1400_ts.c
index 607f993..079cddc 100644
--- a/drivers/input/touchscreen/ucb1400_ts.c
+++ b/drivers/input/touchscreen/ucb1400_ts.c
@@ -358,13 +358,10 @@ static irqreturn_t ucb1400_hard_irq(int irqnr, void *devid)
 {
 	struct ucb1400 *ucb = devid;
 
-	if (irqnr == ucb->irq) {
-		disable_irq(ucb->irq);
-		ucb->irq_pending = 1;
-		wake_up(&ucb->ts_wait);
-		return IRQ_HANDLED;
-	}
-	return IRQ_NONE;
+	disable_irq(ucb->irq);
+	ucb->irq_pending = 1;
+	wake_up(&ucb->ts_wait);
+	return IRQ_HANDLED;
 }
 
 static int ucb1400_ts_open(struct input_dev *idev)
diff --git a/drivers/serial/8250.c b/drivers/serial/8250.c
index 96a585e..109921e 100644
--- a/drivers/serial/8250.c
+++ b/drivers/serial/8250.c
@@ -40,6 +40,7 @@
 #include <linux/serial_8250.h>
 #include <linux/nmi.h>
 #include <linux/mutex.h>
+#include <linux/interrupt.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -1457,7 +1458,7 @@ static irqreturn_t serial8250_interrupt(int irq, void *dev_id)
 	struct list_head *l, *end = NULL;
 	int pass_counter = 0, handled = 0;
 
-	DEBUG_INTR("serial8250_interrupt(%d)...", irq);
+	DEBUG_INTR("serial8250_interrupt...");
 
 	spin_lock(&i->lock);
 
@@ -1496,7 +1497,7 @@ static irqreturn_t serial8250_interrupt(int irq, void *dev_id)
 		if (l == i->head && pass_counter++ > PASS_LIMIT) {
 			/* If we hit this, we're dead. */
 			printk(KERN_ERR "serial8250: too much work for "
-				"irq%d\n", irq);
+				"irq%d\n", up->port.irq);
 			break;
 		}
 	} while (l != end);
diff --git a/include/asm-sh/push-switch.h b/include/asm-sh/push-switch.h
index 4903f9e..73ecaf2 100644
--- a/include/asm-sh/push-switch.h
+++ b/include/asm-sh/push-switch.h
@@ -19,7 +19,7 @@ struct push_switch {
 
 struct push_switch_platform_info {
 	/* IRQ handler */
-	irqreturn_t		(*irq_handler)(int irq, void *data);
+	irq_handler_t		irq_handler;
 	/* Special IRQ flags */
 	unsigned int		irq_flags;
 	/* Bit location of switch */
-- 
1.5.4.1

