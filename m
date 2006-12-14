From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/4] net: make dev_kfree_skb_irq not inline
Date: Thu, 14 Dec 2006 12:48:15 -0800
Message-ID: <20061214204900.799953000@osdl.org>
References: <20061214204814.631279000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:56878 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932898AbWLNUwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 15:52:44 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=kfree_skb_any.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the dev_kfree_skb_irq function from netdevice.h to dev.c
for a couple of reasons. Primarily, I want to make softnet_data
local to dev.c; also this function is called 300+ places already.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.20-rc1.orig/include/linux/netdevice.h
+++ linux-2.6.20-rc1/include/linux/netdevice.h
@@ -676,20 +676,7 @@ static inline int netif_running(const st
 /* Use this variant when it is known for sure that it
  * is executing from interrupt context.
  */
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
+extern void dev_kfree_skb_irq(struct sk_buff *skb);
 
 /* Use this variant in places where it could be invoked
  * either from interrupt or non-interrupt context.
--- linux-2.6.20-rc1.orig/net/core/dev.c
+++ linux-2.6.20-rc1/net/core/dev.c
@@ -1141,6 +1141,21 @@ void dev_kfree_skb_any(struct sk_buff *s
 }
 EXPORT_SYMBOL(dev_kfree_skb_any);
 
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
 
 /* Hot-plugging. */
 void netif_device_detach(struct net_device *dev)

-- 

