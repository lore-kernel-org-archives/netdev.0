From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] irda: donauboe fixes, cleanups
Date: Tue, 10 Oct 2006 01:40:55 -0400
Message-ID: <20061010054055.GA17697@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:7052 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S964996AbWJJFk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 01:40:57 -0400
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- fix: toshoboe_invalid_dev() was recently removed, but not all callers
  were updated, causing the obvious linker error.  Remove caller,
  because the check (like the one removed) isn't used.

- fix: propagate request_irq() return value

- cleanup: remove void* casts

- cleanup: remove impossible ASSERTs

Signed-off-by: Jeff Garzik <jeff@garzik.org>

---

 drivers/net/irda/donauboe.c |   20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 636d063..16620bd 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1154,13 +1154,10 @@ #endif
 static irqreturn_t
 toshoboe_interrupt (int irq, void *dev_id)
 {
-  struct toshoboe_cb *self = (struct toshoboe_cb *) dev_id;
+  struct toshoboe_cb *self = dev_id;
   __u8 irqstat;
   struct sk_buff *skb = NULL;
 
-  if (self == NULL && toshoboe_invalid_dev(irq))
-    return IRQ_NONE;
-
   irqstat = INB (OBOE_ISR);
 
 /* was it us */
@@ -1348,13 +1345,11 @@ toshoboe_net_open (struct net_device *de
 {
   struct toshoboe_cb *self;
   unsigned long flags;
+  int rc;
 
   IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
 
-  IRDA_ASSERT (dev != NULL, return -1; );
-  self = (struct toshoboe_cb *) dev->priv;
-
-  IRDA_ASSERT (self != NULL, return 0; );
+  self = netdev_priv(dev);
 
   if (self->async)
     return -EBUSY;
@@ -1362,11 +1357,10 @@ toshoboe_net_open (struct net_device *de
   if (self->stopped)
     return 0;
 
-  if (request_irq (self->io.irq, toshoboe_interrupt,
-                   IRQF_SHARED | IRQF_DISABLED, dev->name, (void *) self))
-    {
-      return -EAGAIN;
-    }
+  rc = request_irq (self->io.irq, toshoboe_interrupt,
+                    IRQF_SHARED | IRQF_DISABLED, dev->name, self);
+  if (rc)
+  	return rc;
 
   spin_lock_irqsave(&self->spinlock, flags);
   toshoboe_startchip (self);
