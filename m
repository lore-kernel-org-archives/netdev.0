From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] net: deinline dev_kfree_skb_irq
Date: Thu, 16 Aug 2007 09:25:25 -0400
Message-ID: <20070816132622.186254140@linux-foundation.org>
References: <20070816132523.201766718@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45486 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758223AbXHPNez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 09:34:55 -0400
Content-Disposition: inline; filename=dev_kfree_skb_irq.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Deinline dev_kfree_skb_irq. This saves about 100bytes per call
site on UP, probably more on SMP.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
--- a/include/linux/netdevice.h	2007-08-06 09:26:41.000000000 +0100
+++ b/include/linux/netdevice.h	2007-08-15 14:12:32.000000000 +0100
@@ -793,29 +793,6 @@ static inline int netif_is_multiqueue(co
 #endif
 }
 
-/* Use this variant when it is known for sure that it
- * is executing from interrupt context.
- */
-static inline void dev_kfree_skb_irq(struct sk_buff *skb)
-{
-	if (atomic_dec_and_test(&skb->users)) {
-		struct softnet_data *sd;
-		unsigned long flags;
-
-		local_irq_save(flags);
-		sd = &__get_cpu_var(softnet_data);
-		skb->next = sd->completion_queue;
-		sd->completion_queue = skb;
-		raise_softirq_irqoff(NET_TX_SOFTIRQ);
-		local_irq_restore(flags);
-	}
-}
-
-/* Use this variant in places where it could be invoked
- * either from interrupt or non-interrupt context.
- */
-extern void dev_kfree_skb_any(struct sk_buff *skb);
-
 #define HAVE_NETIF_RX 1
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
--- a/include/linux/skbuff.h	2007-08-06 09:26:43.000000000 +0100
+++ b/include/linux/skbuff.h	2007-08-15 14:09:04.000000000 +0100
@@ -378,6 +378,8 @@ extern int	       skb_cow_data(struct sk
 				    struct sk_buff **trailer);
 extern int	       skb_pad(struct sk_buff *skb, int pad);
 #define dev_kfree_skb(a)	kfree_skb(a)
+extern void 	      dev_kfree_skb_any(struct sk_buff *skb);
+extern void 	      dev_kfree_skb_irq(struct sk_buff *skb);
 extern void	      skb_over_panic(struct sk_buff *skb, int len,
 				     void *here);
 extern void	      skb_under_panic(struct sk_buff *skb, int len,
--- a/net/core/dev.c	2007-08-06 09:26:48.000000000 +0100
+++ b/net/core/dev.c	2007-08-15 14:12:16.000000000 +0100
@@ -1249,6 +1249,36 @@ void __netif_rx_schedule(struct net_devi
 }
 EXPORT_SYMBOL(__netif_rx_schedule);
 
+/**
+ *	dev_kfree_skb_irq - free skb from IRQ context
+ *	@skb: skb to free
+ *
+ * Queue skb for later release. Used when skb needs to be
+ * free but executing in IRQ context.
+ */
+void dev_kfree_skb_irq(struct sk_buff *skb)
+{
+	if (atomic_dec_and_test(&skb->users)) {
+		struct softnet_data *sd;
+		unsigned long flags;
+
+		local_irq_save(flags);
+		sd = &__get_cpu_var(softnet_data);
+		skb->next = sd->completion_queue;
+		sd->completion_queue = skb;
+		raise_softirq_irqoff(NET_TX_SOFTIRQ);
+		local_irq_restore(flags);
+	}
+}
+EXPORT_SYMBOL(dev_kfree_skb_irq);
+
+/**
+ *	dev_kfree_skb_any - free skb from any context
+ *	@skb: skb to free
+ *
+ * Free skb from interrupt or non-interrupt context.
+ * Use this variant in places where context is not easily determined.
+ */
 void dev_kfree_skb_any(struct sk_buff *skb)
 {
 	if (in_irq() || irqs_disabled())

-- 

