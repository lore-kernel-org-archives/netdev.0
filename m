From: Mika.Lansirinne@stonesoft.com
Subject: [PATCH 2.6.21.5] 8139cp: dev->tx_timeout
Date: Wed, 27 Jun 2007 13:27:16 +0300
Message-ID: <OF0C14C62A.671A9095-ONC2257307.0035124F-C2257307.00396C0B@stonesoft.com>
References: <46822182.5070002@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hki-smtp-2b.stonesoft.com ([84.34.144.172]:34462 "EHLO
	hki-smtp-2b.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbXF0K1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 06:27:21 -0400
In-Reply-To: <46822182.5070002@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the missing dev->tx_timeout for 8139cp driver

Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>
---

diff -ru linux-2.6.21.5/drivers/net/8139cp.c linux-2.6.21.5_8139cp-tx_timeout/drivers/net/8139cp.c
--- linux-2.6.21.5/drivers/net/8139cp.c   2007-06-11 21:37:06.000000000 +0300
+++ linux-2.6.21.5_8139cp-tx_timeout/drivers/net/8139cp.c   2007-06-26 15:48:23.000000000 +0300
@@ -26,7 +26,6 @@

      TODO:
      * Test Tx checksumming thoroughly
-     * Implement dev->tx_timeout

      Low priority TODO:
      * Complete reset on PciErr
@@ -1233,6 +1232,30 @@
      return 0;
 }

+static void cp_tx_timeout(struct net_device *dev)
+{
+     struct cp_private *cp = netdev_priv(dev);
+     int rc;
+     unsigned long flags;
+
+        printk (KERN_WARNING "%s: Transmit timeout, status %2x %4x %4x %4x\n",
+                dev->name, cpr8(Cmd), cpr16(CpCmd),
+                cpr16(IntrStatus), cpr16(IntrMask));
+
+     spin_lock_irqsave(&cp->lock, flags);
+
+     cp_stop_hw(cp);
+     cp_clean_rings(cp);
+     rc = cp_init_rings(cp);
+     cp_start_hw(cp);
+
+     netif_wake_queue(dev);
+
+     spin_unlock_irqrestore(&cp->lock, flags);
+
+     return;
+}
+
 #ifdef BROKEN
 static int cp_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -1938,10 +1961,8 @@
      dev->change_mtu = cp_change_mtu;
 #endif
      dev->ethtool_ops = &cp_ethtool_ops;
-#if 0
      dev->tx_timeout = cp_tx_timeout;
      dev->watchdog_timeo = TX_TIMEOUT;
-#endif

 #if CP_VLAN_TAG_USED
      dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;

