From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 15/18] e1000: add dynamic generic MSI interrupt routine
Date: Wed, 01 Nov 2006 09:52:03 -0800
Message-ID: <20061101175203.2356.42891.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:24080 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946979AbWKARqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:46:19 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add a generic MSI interrupt routine that is IO read-free, speeding up
MSI interrupt handling.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   90 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 88 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index db933bf..b05871a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -157,6 +157,9 @@ static struct net_device_stats * e1000_g
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t e1000_intr(int irq, void *data);
+#ifdef CONFIG_PCI_MSI
+static irqreturn_t e1000_intr_msi(int irq, void *data);
+#endif
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter,
                                     struct e1000_tx_ring *tx_ring);
 #ifdef CONFIG_E1000_NAPI
@@ -288,7 +291,7 @@ static int e1000_request_irq(struct e100
 
 	flags = IRQF_SHARED;
 #ifdef CONFIG_PCI_MSI
-	if (adapter->hw.mac_type > e1000_82547_rev_2) {
+	if (adapter->hw.mac_type >= e1000_82571) {
 		adapter->have_msi = TRUE;
 		if ((err = pci_enable_msi(adapter->pdev))) {
 			DPRINTK(PROBE, ERR,
@@ -296,8 +299,14 @@ static int e1000_request_irq(struct e100
 			adapter->have_msi = FALSE;
 		}
 	}
-	if (adapter->have_msi)
+	if (adapter->have_msi) {
 		flags &= ~IRQF_SHARED;
+		err = request_irq(adapter->pdev->irq, &e1000_intr_msi, flags,
+		                  netdev->name, netdev);
+		if (err)
+			DPRINTK(PROBE, ERR,
+			       "Unable to allocate interrupt Error: %d\n", err);
+	} else
 #endif
 	if ((err = request_irq(adapter->pdev->irq, &e1000_intr, flags,
 	                       netdev->name, netdev)))
@@ -3466,6 +3475,83 @@ e1000_update_stats(struct e1000_adapter 
 
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
+#ifdef CONFIG_PCI_MSI
+
+/**
+ * e1000_intr_msi - Interrupt Handler
+ * @irq: interrupt number
+ * @data: pointer to a network interface device structure
+ **/
+
+static
+irqreturn_t e1000_intr_msi(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+#ifndef CONFIG_E1000_NAPI
+	int i;
+#endif
+
+	/* this code avoids the read of ICR but has to get 1000 interrupts
+	 * at every link change event before it will notice the change */
+	if (++adapter->detect_link >= 1000) {
+		uint32_t icr = E1000_READ_REG(hw, ICR);
+#ifdef CONFIG_E1000_NAPI
+		/* read ICR disables interrupts using IAM, so keep up with our
+		 * enable/disable accounting */
+		atomic_inc(&adapter->irq_sem);
+#endif
+		adapter->detect_link = 0;
+		if ((icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) &&
+		    (icr & E1000_ICR_INT_ASSERTED)) {
+			hw->get_link_status = 1;
+			/* 80003ES2LAN workaround--
+			* For packet buffer work-around on link down event;
+			* disable receives here in the ISR and
+			* reset adapter in watchdog
+			*/
+			if (netif_carrier_ok(netdev) &&
+			    (adapter->hw.mac_type == e1000_80003es2lan)) {
+				/* disable receives */
+				uint32_t rctl = E1000_READ_REG(hw, RCTL);
+				E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
+			}
+			/* guard against interrupt when we're going down */
+			if (!test_bit(__E1000_DOWN, &adapter->flags))
+				mod_timer(&adapter->watchdog_timer,
+				          jiffies + 1);
+		}
+	} else {
+		E1000_WRITE_REG(hw, ICR, (0xffffffff & ~(E1000_ICR_RXSEQ |
+		                                         E1000_ICR_LSC)));
+		/* bummer we have to flush here, but things break otherwise as
+		 * some event appears to be lost or delayed and throughput
+		 * drops.  In almost all tests this flush is un-necessary */
+		E1000_WRITE_FLUSH(hw);
+#ifdef CONFIG_E1000_NAPI
+		/* Interrupt Auto-Mask (IAM)...upon writing ICR, interrupts are
+		 * masked.  No need for the IMC write, but it does mean we
+		 * should account for it ASAP. */
+		atomic_inc(&adapter->irq_sem);
+#endif
+	}
+
+#ifdef CONFIG_E1000_NAPI
+	if (likely(netif_rx_schedule_prep(netdev)))
+		__netif_rx_schedule(netdev);
+	else
+		e1000_irq_enable(adapter);
+#else
+	for (i = 0; i < E1000_MAX_INTR; i++)
+		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
+		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
+			break;
+#endif
+
+	return IRQ_HANDLED;
+}
+#endif
 
 /**
  * e1000_intr - Interrupt Handler



---
Auke Kok <auke-jan.h.kok@intel.com>
