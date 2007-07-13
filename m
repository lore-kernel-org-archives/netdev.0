From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] 8139cp: implement the missing dev->tx_timeout
Date: Fri, 13 Jul 2007 23:05:35 +0200
Message-ID: <20070713210535.GB18669@electric-eye.fr.zoreil.com>
References: <4693B6ED.5030102@garzik.org> <OF89ECFC4B.E1AA259B-ONC2257315.002C3B4B-C2257317.0054CDE1@stonesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Mika.Lansirinne@stonesoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39881 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488AbXGMVJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 17:09:12 -0400
Content-Disposition: inline
In-Reply-To: <OF89ECFC4B.E1AA259B-ONC2257315.002C3B4B-C2257317.0054CDE1@stonesoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>
---
 drivers/net/8139cp.c |   27 ++++++++++++++++++++++++---
 1 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 807e699..e970e64 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -26,7 +26,6 @@
 
 	TODO:
 	* Test Tx checksumming thoroughly
-	* Implement dev->tx_timeout
 
 	Low priority TODO:
 	* Complete reset on PciErr
@@ -1218,6 +1217,30 @@ static int cp_close (struct net_device *dev)
 	return 0;
 }
 
+static void cp_tx_timeout(struct net_device *dev)
+{
+	struct cp_private *cp = netdev_priv(dev);
+	unsigned long flags;
+	int rc;
+
+	printk(KERN_WARNING "%s: Transmit timeout, status %2x %4x %4x %4x\n",
+	       dev->name, cpr8(Cmd), cpr16(CpCmd),
+	       cpr16(IntrStatus), cpr16(IntrMask));
+
+	spin_lock_irqsave(&cp->lock, flags);
+
+	cp_stop_hw(cp);
+	cp_clean_rings(cp);
+	rc = cp_init_rings(cp);
+	cp_start_hw(cp);
+
+	netif_wake_queue(dev);
+
+	spin_unlock_irqrestore(&cp->lock, flags);
+
+	return;
+}
+
 #ifdef BROKEN
 static int cp_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -1920,10 +1943,8 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->change_mtu = cp_change_mtu;
 #endif
 	dev->ethtool_ops = &cp_ethtool_ops;
-#if 0
 	dev->tx_timeout = cp_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#endif
 
 #if CP_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-- 
1.5.2.1

