From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 4/7] netpoll: fix ->poll() locking
Date: Thu, 03 Mar 2005 14:46:32 -0600
Message-ID: <5.454130102@selenic.com>
References: <4.454130102@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4.454130102@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Introduce a per-client poll lock and flag. The lock assures we never
have more than one caller in dev->poll(). The flag provides recursion
avoidance on UP where the lock disappears.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: rc4/net/core/netpoll.c
===================================================================
--- rc4.orig/net/core/netpoll.c	2005-02-17 22:39:59.000000000 -0600
+++ rc4/net/core/netpoll.c	2005-02-17 22:40:02.000000000 -0600
@@ -36,7 +36,6 @@
 static struct sk_buff *skbs;
 
 static atomic_t trapped;
-static DEFINE_SPINLOCK(netpoll_poll_lock);
 
 #define NETPOLL_RX_ENABLED  1
 #define NETPOLL_RX_DROP     2
@@ -63,8 +62,15 @@
 }
 
 /*
- * Check whether delayed processing was scheduled for our current CPU,
- * and then manually invoke NAPI polling to pump data off the card.
+ * Check whether delayed processing was scheduled for our NIC. If so,
+ * we attempt to grab the poll lock and use ->poll() to pump the card.
+ * If this fails, either we've recursed in ->poll() or it's already
+ * running on another CPU.
+ *
+ * Note: we don't mask interrupts with this lock because we're using
+ * trylock here and interrupts are already disabled in the softirq
+ * case. Further, we test the poll_owner to avoid recursion on UP
+ * systems where the lock doesn't exist.
  *
  * In cases where there is bi-directional communications, reading only
  * one message at a time can lead to packets being dropped by the
@@ -74,13 +80,10 @@
 static void poll_napi(struct netpoll *np)
 {
 	int budget = 16;
-	unsigned long flags;
-	struct softnet_data *queue;
 
-	spin_lock_irqsave(&netpoll_poll_lock, flags);
-	queue = &__get_cpu_var(softnet_data);
 	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
-	    !list_empty(&queue->poll_list)) {
+	    np->poll_owner != __smp_processor_id() &&
+	    spin_trylock(&np->poll_lock)) {
 		np->rx_flags |= NETPOLL_RX_DROP;
 		atomic_inc(&trapped);
 
@@ -88,8 +91,8 @@
 
 		atomic_dec(&trapped);
 		np->rx_flags &= ~NETPOLL_RX_DROP;
+		spin_unlock(&np->poll_lock);
 	}
-	spin_unlock_irqrestore(&netpoll_poll_lock, flags);
 }
 
 void netpoll_poll(struct netpoll *np)
@@ -194,6 +197,12 @@
 		return;
 	}
 
+	/* avoid ->poll recursion */
+	if(np->poll_owner == __smp_processor_id()) {
+		__kfree_skb(skb);
+		return;
+	}
+
 	spin_lock(&np->dev->xmit_lock);
 	np->dev->xmit_lock_owner = smp_processor_id();
 
@@ -542,6 +551,9 @@
 	struct net_device *ndev = NULL;
 	struct in_device *in_dev;
 
+	np->poll_lock = SPIN_LOCK_UNLOCKED;
+	np->poll_owner = -1;
+
 	if (np->dev_name)
 		ndev = dev_get_by_name(np->dev_name);
 	if (!ndev) {
Index: rc4/include/linux/netpoll.h
===================================================================
--- rc4.orig/include/linux/netpoll.h	2005-02-17 22:39:59.000000000 -0600
+++ rc4/include/linux/netpoll.h	2005-02-17 22:40:02.000000000 -0600
@@ -21,6 +21,8 @@
 	u32 local_ip, remote_ip;
 	u16 local_port, remote_port;
 	unsigned char local_mac[6], remote_mac[6];
+	spinlock_t poll_lock;
+	int poll_owner;
 };
 
 void netpoll_poll(struct netpoll *np);
@@ -37,8 +39,27 @@
 {
 	return skb->dev->np && skb->dev->np->rx_flags && __netpoll_rx(skb);
 }
+
+static inline void netpoll_poll_lock(struct net_device *dev)
+{
+	if (dev->np) {
+		spin_lock(&dev->np->poll_lock);
+		dev->np->poll_owner = __smp_processor_id();
+	}
+}
+
+static inline void netpoll_poll_unlock(struct net_device *dev)
+{
+	if (dev->np) {
+		spin_unlock(&dev->np->poll_lock);
+		dev->np->poll_owner = -1;
+	}
+}
+
 #else
 #define netpoll_rx(a) 0
+#define netpoll_poll_lock(a)
+#define netpoll_poll_unlock(a)
 #endif
 
 #endif
Index: rc4/net/core/dev.c
===================================================================
--- rc4.orig/net/core/dev.c	2005-02-17 22:39:59.000000000 -0600
+++ rc4/net/core/dev.c	2005-02-17 22:40:02.000000000 -0600
@@ -1775,8 +1775,10 @@
 
 		dev = list_entry(queue->poll_list.next,
 				 struct net_device, poll_list);
+		netpoll_poll_lock(dev);
 
 		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
+			netpoll_poll_unlock(dev);
 			local_irq_disable();
 			list_del(&dev->poll_list);
 			list_add_tail(&dev->poll_list, &queue->poll_list);
@@ -1785,6 +1787,7 @@
 			else
 				dev->quota = dev->weight;
 		} else {
+			netpoll_poll_unlock(dev);
 			dev_put(dev);
 			local_irq_disable();
 		}
