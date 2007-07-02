From: Mika.Lansirinne@stonesoft.com
Subject: [PATCH 2.6.22-rc7] 8139cp: dev->tx_timeout
Date: Mon, 2 Jul 2007 16:30:52 +0300
Message-ID: <OF60EF0345.A1609CC7-ONC225730C.0049023C-C225730C.004A3C15@stonesoft.com>
References: <4688F1F6.70803@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stonesoft.com ([192.89.38.171]:35357 "EHLO
	hki-smtp-2a.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbXGBOEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 10:04:37 -0400
In-Reply-To: <4688F1F6.70803@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Resending the patch against 2.6.22-rc7)

This patch implements the missing dev->tx_timeout for 8139cp driver

Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>

---

diff -uprN linux-2.6.22-rc7/drivers/net/8139cp.c linux-2.6.22-rc7_8139cp-tx_timeout/drivers/net/8139cp.c
--- linux-2.6.22-rc7/drivers/net/8139cp.c 2007-07-01 22:54:24.000000000 +0300
+++ linux-2.6.22-rc7_8139cp-tx_timeout/drivers/net/8139cp.c 2007-07-02 16:00:38.000000000 +0300
@@ -26,7 +26,6 @@

      TODO:
      * Test Tx checksumming thoroughly
-     * Implement dev->tx_timeout

      Low priority TODO:
      * Complete reset on PciErr
@@ -1223,6 +1222,30 @@ static int cp_close (struct net_device *
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
@@ -1928,10 +1951,8 @@ static int cp_init_one (struct pci_dev *
      dev->change_mtu = cp_change_mtu;
 #endif
      dev->ethtool_ops = &cp_ethtool_ops;
-#if 0
      dev->tx_timeout = cp_tx_timeout;
      dev->watchdog_timeo = TX_TIMEOUT;
-#endif

 #if CP_VLAN_TAG_USED
      dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;

