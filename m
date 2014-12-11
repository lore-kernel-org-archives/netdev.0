From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [RFC PATCH net-next 00/11] net: remove disable_irq() from
 ->ndo_poll_controller
Date: Thu, 11 Dec 2014 22:45:37 +0100
Message-ID: <20141211214537.GA4159@kria>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
 <20141209.214433.7463087833083181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, peterz@infradead.org, tglx@linutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:34702 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934205AbaLKVpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 16:45:44 -0500
Content-Disposition: inline
In-Reply-To: <20141209.214433.7463087833083181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-12-09, 21:44:33 -0500, David Miller wrote:
> 
> Adding a new spinlock to every interrupt service routine is
> simply a non-starter.
> 
> You will certainly have to find a way to fix this in a way
> that doesn't involve adding any new overhead to the normal
> operational paths of these drivers.
> 
> Thanks.

Okay. Here is another idea.

Since the issue is with the wait_event() part of synchronize_irq(),
and it only takes care of threaded handlers, maybe we could try not
waiting for threaded handlers.

Introduce disable_irq_nosleep() that returns true if it successfully
synchronized against all handlers (there was no threaded handler
running), false if it left some threads running.  And in
->ndo_poll_controller, only call the interrupt handler if
synchronization was successful.

Both users of the poll controllers retry their action (alloc/xmit an
skb) several times, with calls to the device's poll controller between
attempts.  And hopefully, if the first attempt fails, we will still
manage to get through?



diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 83140cbb5f01..d967937aca3c 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -5216,8 +5216,8 @@ static void e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	disable_irq(adapter->pdev->irq);
-	e1000_intr(adapter->pdev->irq, netdev);
+	if (disable_irq_nosleep(adapter->pdev->irq))
+		e1000_intr(adapter->pdev->irq, netdev);
 	enable_irq(adapter->pdev->irq);
 }
 #endif
diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 69517a24bc50..f2e4125ac963 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -184,6 +184,7 @@ extern void devm_free_irq(struct device *dev, unsigned int irq, void *dev_id);
 #endif
 
 extern void disable_irq_nosync(unsigned int irq);
+extern bool disable_irq_nosleep(unsigned int irq);
 extern void disable_irq(unsigned int irq);
 extern void disable_percpu_irq(unsigned int irq);
 extern void enable_irq(unsigned int irq);
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 0a9104b4608b..58199b023845 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -106,6 +106,23 @@ void synchronize_irq(unsigned int irq)
 }
 EXPORT_SYMBOL(synchronize_irq);
 
+static bool synchronize_irq_nosleep(unsigned int irq)
+{
+	struct irq_desc *desc = irq_to_desc(irq);
+
+	if (desc) {
+		__synchronize_hardirq(desc);
+		/*
+		 * We made sure that no hardirq handler is
+		 * running. Now check if some threaded handlers are
+		 * active.
+		 */
+		return !atomic_read(&desc->threads_active);
+	}
+
+	return true;
+}
+
 #ifdef CONFIG_SMP
 cpumask_var_t irq_default_affinity;
 
@@ -418,6 +435,31 @@ void disable_irq_nosync(unsigned int irq)
 EXPORT_SYMBOL(disable_irq_nosync);
 
 /**
+ *	disable_irq_nosleep - disable an irq and wait for completion of hard IRQ handlers
+ *	@irq: Interrupt to disable
+ *
+ *	Disable the selected interrupt line.  Enables and Disables are
+ *	nested.
+ *	This function waits for any pending hard IRQ handlers for this
+ *	interrupt to complete before returning. If you use this
+ *	function while holding a resource the IRQ handler may need you
+ *	will deadlock.
+ *	This function does not wait for threaded IRQ handlers.
+ *
+ *      Returns true if synchronized, false if there are threaded
+ *      handlers pending.
+ *
+ *	This function may be called - with care - from IRQ context.
+ */
+bool disable_irq_nosleep(unsigned int irq)
+{
+	if (!__disable_irq_nosync(irq))
+		return synchronize_irq_nosleep(irq);
+	return true;
+}
+EXPORT_SYMBOL(disable_irq_nosleep);
+
+/**
  *	disable_irq - disable an irq and wait for completion
  *	@irq: Interrupt to disable
  *


-- 
Sabrina
