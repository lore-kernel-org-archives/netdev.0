From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH net-next 00/11] net: remove disable_irq() from
 ->ndo_poll_controller
Date: Thu, 5 Feb 2015 14:06:23 +0100
Message-ID: <20150205130623.GH5029@twins.programming.kicks-ass.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
 <20141209.214433.7463087833083181.davem@davemloft.net>
 <20141211214537.GA4159@kria>
 <alpine.DEB.2.11.1412122242180.16494@nanos>
 <20150105143126.GA22122@kria>
 <20150205002059.GA28282@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53274 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbbBENGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:06:32 -0500
Content-Disposition: inline
In-Reply-To: <20150205002059.GA28282@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2015 at 01:20:59AM +0100, Sabrina Dubroca wrote:
> Thomas, ping?
> 
> thread is over there if you need it:
> https://marc.info/?l=linux-netdev&m=141833435000554&w=2

It appears to me you have addressed most his issues and since it appears
to me the existing synchronze_hardirq() seems to be mostly what we need
I'll propose (and merge) the below and will take flames from tglx when
he returns :-)

---
Subject: genirq: Provide disable_hardirq()

For things like netpoll there is a need to disable an interrupt from
atomic context. Currently netpoll uses disable_irq() which will
sleep-wait on threaded handlers and thus forced_irqthreads breaks
things.

Provide disable_hardirq(), which uses synchronize_hardirq() to only wait
for active hardirq handlers; also change synchronize_hardirq() to
return the status of threaded handlers.

This will allow one to try-disable an interrupt from atomic context, or
in case of request_threaded_irq() to only wait for the hardirq part.

Suggested-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/linux/hardirq.h   |  2 +-
 include/linux/interrupt.h |  1 +
 kernel/irq/manage.c       | 36 ++++++++++++++++++++++++++++++++++--
 3 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/include/linux/hardirq.h b/include/linux/hardirq.h
index cba442ec3c66..f4af03404b97 100644
--- a/include/linux/hardirq.h
+++ b/include/linux/hardirq.h
@@ -9,7 +9,7 @@
 
 
 extern void synchronize_irq(unsigned int irq);
-extern void synchronize_hardirq(unsigned int irq);
+extern bool synchronize_hardirq(unsigned int irq);
 
 #if defined(CONFIG_TINY_RCU)
 
diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index d9b05b5bf8c7..3bb01b9a379c 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -184,6 +184,7 @@ extern void devm_free_irq(struct device *dev, unsigned int irq, void *dev_id);
 #endif
 
 extern void disable_irq_nosync(unsigned int irq);
+extern bool disable_hardirq(unsigned int irq);
 extern void disable_irq(unsigned int irq);
 extern void disable_percpu_irq(unsigned int irq);
 extern void enable_irq(unsigned int irq);
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index f038e586a4b9..1309cccd714f 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -68,14 +68,20 @@ static void __synchronize_hardirq(struct irq_desc *desc)
  *	Do not use this for shutdown scenarios where you must be sure
  *	that all parts (hardirq and threaded handler) have completed.
  *
+ *	Returns: false if a theaded handler is active.
+ *
  *	This function may be called - with care - from IRQ context.
  */
-void synchronize_hardirq(unsigned int irq)
+bool synchronize_hardirq(unsigned int irq)
 {
 	struct irq_desc *desc = irq_to_desc(irq);
 
-	if (desc)
+	if (desc) {
 		__synchronize_hardirq(desc);
+		return !atomic_read(&desc->threads_active);
+	}
+
+	return true;
 }
 EXPORT_SYMBOL(synchronize_hardirq);
 
@@ -439,6 +445,32 @@ void disable_irq(unsigned int irq)
 }
 EXPORT_SYMBOL(disable_irq);
 
+/**
+ *	disable_hardirq - disables an irq and waits for hardirq completion
+ *	@irq: Interrupt to disable
+ *
+ *	Disable the selected interrupt line.  Enables and Disables are
+ *	nested.
+ *	This function waits for any pending hard IRQ handlers for this
+ *	interrupt to complete before returning. If you use this function while
+ *	holding a resource the hard IRQ handler may need you will deadlock.
+ *
+ *	When used to optimistically disable an interrupt from atomic context
+ *	the return value must be checked.
+ *
+ *	Returns: false if a theaded handler is active.
+ *
+ *	This function may be called - with care - from IRQ context.
+ */
+bool disable_hardirq(unsigned int irq)
+{
+	if (!__disable_irq_nosync(irq))
+		return synchronize_hardirq(irq);
+
+	return false;
+}
+EXPORT_SYMBOL(disable_hardirq);
+
 void __enable_irq(struct irq_desc *desc, unsigned int irq)
 {
 	switch (desc->depth) {
