From: akpm@osdl.org
Subject: [patch 01/11] e1000: memory leak in e1000_set_ringparam()
Date: Mon, 25 Sep 2006 16:39:15 -0700
Message-ID: <200609252339.k8PNdFO1002622@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, vvs@sw.ru,
	auke-jan.h.kok@intel.com, cramerj@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16564 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751716AbWIYXjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:39:32 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasily Averin <vvs@sw.ru>

Memory leak was found in 2.6.18-rc4 and e1000 7.2.7 from sourceforge:
Memory allocated for new tx_ring and rx_ring leaks if
e1000_setup_XX_resources() fails.c Also this patch reduces stack usage
(removed tx_new and rx_new) and uses kzalloc instead kmalloc+memset(0)

Signed-off-by: Vasily Averin <vvs@sw.ru>
Cc: Jeb Cramer <cramerj@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e1000/e1000_ethtool.c |   40 ++++++++++++----------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff -puN drivers/net/e1000/e1000_ethtool.c~e1000-memory-leak-in-e1000_set_ringparam drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c~e1000-memory-leak-in-e1000_set_ringparam
+++ a/drivers/net/e1000/e1000_ethtool.c
@@ -632,8 +632,8 @@ e1000_set_ringparam(struct net_device *n
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	e1000_mac_type mac_type = adapter->hw.mac_type;
-	struct e1000_tx_ring *txdr, *tx_old, *tx_new;
-	struct e1000_rx_ring *rxdr, *rx_old, *rx_new;
+	struct e1000_tx_ring *txdr, *tx_old;
+	struct e1000_rx_ring *rxdr, *rx_old;
 	int i, err, tx_ring_size, rx_ring_size;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
@@ -651,23 +651,17 @@ e1000_set_ringparam(struct net_device *n
 	tx_old = adapter->tx_ring;
 	rx_old = adapter->rx_ring;
 
-	adapter->tx_ring = kmalloc(tx_ring_size, GFP_KERNEL);
-	if (!adapter->tx_ring) {
-		err = -ENOMEM;
-		goto err_setup_rx;
-	}
-	memset(adapter->tx_ring, 0, tx_ring_size);
-
-	adapter->rx_ring = kmalloc(rx_ring_size, GFP_KERNEL);
-	if (!adapter->rx_ring) {
-		kfree(adapter->tx_ring);
-		err = -ENOMEM;
-		goto err_setup_rx;
-	}
-	memset(adapter->rx_ring, 0, rx_ring_size);
+	err = -ENOMEM;
+	txdr = kzalloc(tx_ring_size, GFP_KERNEL);
+	if (!txdr)
+		goto err_alloc_tx;
+
+	rxdr = kzalloc(rx_ring_size, GFP_KERNEL);
+	if (!rxdr)
+		goto err_alloc_rx;
 
-	txdr = adapter->tx_ring;
-	rxdr = adapter->rx_ring;
+	adapter->tx_ring = txdr;
+	adapter->rx_ring = rxdr;
 
 	rxdr->count = max(ring->rx_pending,(uint32_t)E1000_MIN_RXD);
 	rxdr->count = min(rxdr->count,(uint32_t)(mac_type < e1000_82544 ?
@@ -694,16 +688,14 @@ e1000_set_ringparam(struct net_device *n
 		/* save the new, restore the old in order to free it,
 		 * then restore the new back again */
 
-		rx_new = adapter->rx_ring;
-		tx_new = adapter->tx_ring;
 		adapter->rx_ring = rx_old;
 		adapter->tx_ring = tx_old;
 		e1000_free_all_rx_resources(adapter);
 		e1000_free_all_tx_resources(adapter);
 		kfree(tx_old);
 		kfree(rx_old);
-		adapter->rx_ring = rx_new;
-		adapter->tx_ring = tx_new;
+		adapter->rx_ring = rxdr;
+		adapter->tx_ring = txdr;
 		if ((err = e1000_up(adapter)))
 			goto err_setup;
 	}
@@ -715,6 +707,10 @@ err_setup_tx:
 err_setup_rx:
 	adapter->rx_ring = rx_old;
 	adapter->tx_ring = tx_old;
+	kfree(rxdr);
+err_alloc_rx:
+	kfree(txdr);
+err_alloc_tx:
 	e1000_up(adapter);
 err_setup:
 	clear_bit(__E1000_RESETTING, &adapter->flags);
_
