From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] napi: Call __netif_rx_complete in netif_rx_complete
Date: Sun, 20 May 2007 20:39:10 +1000
Message-ID: <20070520103910.GA25808@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1147 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755865AbXETKjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2007 06:39:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[NET] napi: Call __netif_rx_complete in netif_rx_complete

This patch kills a little bit of code duplication between the two
variants of netif_rx_complete.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f671cd2..3a70f55 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -910,6 +910,17 @@ static inline int netif_rx_reschedule(struct net_device *dev, int undo)
 	return 0;
 }
 
+/* same as netif_rx_complete, except that local_irq_save(flags)
+ * has already been issued
+ */
+static inline void __netif_rx_complete(struct net_device *dev)
+{
+	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
+	list_del(&dev->poll_list);
+	smp_mb__before_clear_bit();
+	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+}
+
 /* Remove interface from poll list: it must be in the poll list
  * on current cpu. This primitive is called by dev->poll(), when
  * it completes the work. The device cannot be out of poll list at this
@@ -920,10 +931,7 @@ static inline void netif_rx_complete(struct net_device *dev)
 	unsigned long flags;
 
 	local_irq_save(flags);
-	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
-	list_del(&dev->poll_list);
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	__netif_rx_complete(dev);
 	local_irq_restore(flags);
 }
 
@@ -940,17 +948,6 @@ static inline void netif_poll_enable(struct net_device *dev)
 	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
 }
 
-/* same as netif_rx_complete, except that local_irq_save(flags)
- * has already been issued
- */
-static inline void __netif_rx_complete(struct net_device *dev)
-{
-	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
-	list_del(&dev->poll_list);
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
-}
-
 static inline void netif_tx_lock(struct net_device *dev)
 {
 	spin_lock(&dev->_xmit_lock);
