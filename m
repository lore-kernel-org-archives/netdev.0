From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 01/11] netpoll: introduce netpoll_irq_lock to protect netpoll controller against interrupts
Date: Tue,  9 Dec 2014 15:37:12 +0100
Message-ID: <1418135842-21389-2-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:51237 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693AbaLIOig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:38:36 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In many drivers' ->ndo_poll_controller implementation, we currently
have the following code:

static void poll_controller(struct net_device *dev)
{
        disable_irq(irq);
        intr_handler(irq, dev);
        enable_irq(irq);
}

Commit e22b886a8a43b ("sched/wait: Add might_sleep() checks") added a
might_sleep() check to synchronize_irq(). Thomas Gleixner and Peter
Zijlstra suggested the original idea and patch to replace disable_irq
in the poll controller with a spin_lock in the interrupt handler.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/netpoll.h | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index b25ee9ffdbe6..a171f1a50e0e 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -117,4 +117,35 @@ static inline bool netpoll_tx_running(struct net_device *dev)
 }
 #endif
 
+struct netpoll_irq_lock {
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	spinlock_t lock;
+#endif
+};
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static inline void netpoll_irq_lock_init(struct netpoll_irq_lock *np_lock)
+{
+	spin_lock_init(&np_lock->lock);
+}
+static inline void netpoll_irq_lock(struct netpoll_irq_lock *np_lock)
+{
+	spin_lock(&np_lock->lock);
+}
+static inline void netpoll_irq_unlock(struct netpoll_irq_lock *np_lock)
+{
+	spin_unlock(&np_lock->lock);
+}
+#else
+static inline void netpoll_irq_lock_init(struct netpoll_irq_lock *np_lock)
+{
+}
+static inline void netpoll_irq_lock(struct netpoll_irq_lock *np_lock)
+{
+}
+static inline void netpoll_irq_unlock(struct netpoll_irq_lock *np_lock)
+{
+}
+#endif
+
 #endif
-- 
2.1.3
