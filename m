From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/13] forcedeth: fix missing napi enable/disable calls
Date: Thu, 05 Mar 2009 13:01:55 -0500
Message-ID: <49B01393.2010606@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000600050701000800010809"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8434 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755561AbZCEVBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000600050701000800010809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds missing napi enable/disable calls.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------000600050701000800010809
Content-Type: text/plain;
 name="patch-forcedeth-napi-enable-disable"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-napi-enable-disable"

--- old/drivers/net/forcedeth.c	2009-03-04 21:56:30.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-04 21:57:03.000000000 -0800
@@ -1069,6 +1069,24 @@
 	}
 }
 
+static void nv_napi_enable(struct net_device *dev)
+{
+#ifdef CONFIG_FORCEDETH_NAPI
+	struct fe_priv *np = get_nvpriv(dev);
+
+	napi_enable(&np->napi);
+#endif
+}
+
+static void nv_napi_disable(struct net_device *dev)
+{
+#ifdef CONFIG_FORCEDETH_NAPI
+	struct fe_priv *np = get_nvpriv(dev);
+
+	napi_disable(&np->napi);
+#endif
+}
+
 #define MII_READ	(-1)
 /* mii_rw: read/write a register on the PHY.
  *
@@ -2924,6 +2942,7 @@
 		 * Changing the MTU is a rare event, it shouldn't matter.
 		 */
 		nv_disable_irq(dev);
+		nv_napi_disable(dev);
 		netif_tx_lock_bh(dev);
 		netif_addr_lock(dev);
 		spin_lock(&np->lock);
@@ -2952,6 +2971,7 @@
 		spin_unlock(&np->lock);
 		netif_addr_unlock(dev);
 		netif_tx_unlock_bh(dev);
+		nv_napi_enable(dev);
 		nv_enable_irq(dev);
 	}
 	return 0;
@@ -4592,6 +4612,7 @@
 
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
+		nv_napi_disable(dev);
 		netif_tx_lock_bh(dev);
 		netif_addr_lock(dev);
 		spin_lock(&np->lock);
@@ -4644,6 +4665,7 @@
 		spin_unlock(&np->lock);
 		netif_addr_unlock(dev);
 		netif_tx_unlock_bh(dev);
+		nv_napi_enable(dev);
 		nv_enable_irq(dev);
 	}
 	return 0;
@@ -5070,9 +5092,7 @@
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
 		if (netif_running(dev)) {
 			netif_stop_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
-			napi_disable(&np->napi);
-#endif
+			nv_napi_disable(dev);
 			netif_tx_lock_bh(dev);
 			netif_addr_lock(dev);
 			spin_lock_irq(&np->lock);
@@ -5130,9 +5150,7 @@
 			/* restart rx engine */
 			nv_start_rxtx(dev);
 			netif_start_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
-			napi_enable(&np->napi);
-#endif
+			nv_napi_enable(dev);
 			nv_enable_hw_interrupts(dev, np->irqmask);
 		}
 	}
@@ -5424,9 +5442,7 @@
 	ret = nv_update_linkspeed(dev);
 	nv_start_rxtx(dev);
 	netif_start_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
-	napi_enable(&np->napi);
-#endif
+	nv_napi_enable(dev);
 
 	if (ret) {
 		netif_carrier_on(dev);
@@ -5458,9 +5474,7 @@
 	spin_lock_irq(&np->lock);
 	np->in_shutdown = 1;
 	spin_unlock_irq(&np->lock);
-#ifdef CONFIG_FORCEDETH_NAPI
-	napi_disable(&np->napi);
-#endif
+	nv_napi_disable(dev);
 	synchronize_irq(np->pci_dev->irq);
 
 	del_timer_sync(&np->oom_kick);

--------------000600050701000800010809--
