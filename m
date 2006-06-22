From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 02/21] e1000: rework driver hardware reset locking
Date: Wed, 21 Jun 2006 22:20:09 -0700
Message-ID: <20060622052009.25497.46358.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:42248 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751637AbWFVFOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:12 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


After studying the driver mac reset code it was found that there
were multiple race conditions possible to reset the unit twice or
bring it e1000_up() double. This fixes all occurences where the
driver needs to reset the mac.

We also remove irq requesting/releasing into _open and _close so
that while the device is _up we will never touch the irq's. This fixes
the double free irq bug that people saw.

To make sure that the watchdog task doesn't cause another race we let
it run as a non-scheduled task.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |    8 ++
 drivers/net/e1000/e1000_ethtool.c |   46 ++++++++------
 drivers/net/e1000/e1000_main.c    |  126 +++++++++++++++++++++----------------
 3 files changed, 105 insertions(+), 75 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 2bc34fb..2b96ad0 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -69,7 +69,6 @@
 #ifdef NETIF_F_TSO
 #include <net/checksum.h>
 #endif
-#include <linux/workqueue.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
@@ -255,7 +254,6 @@ struct e1000_adapter {
 	spinlock_t tx_queue_lock;
 #endif
 	atomic_t irq_sem;
-	struct work_struct watchdog_task;
 	struct work_struct reset_task;
 	uint8_t fc_autoneg;
 
@@ -340,8 +338,13 @@ struct e1000_adapter {
 #ifdef NETIF_F_TSO
 	boolean_t tso_force;
 #endif
+	unsigned long flags;
 };
 
+enum e1000_state_t {
+	__E1000_DRIVER_TESTING,
+	__E1000_RESETTING,
+};
 
 /*  e1000_main.c  */
 extern char e1000_driver_name[];
@@ -349,6 +352,7 @@ extern char e1000_driver_version[];
 int e1000_up(struct e1000_adapter *adapter);
 void e1000_down(struct e1000_adapter *adapter);
 void e1000_reset(struct e1000_adapter *adapter);
+void e1000_reinit_locked(struct e1000_adapter *adapter);
 int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
 void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
 int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 845d293..cf5c5f4 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -203,11 +203,9 @@ e1000_set_settings(struct net_device *ne
 
 	/* reset the link */
 
-	if (netif_running(adapter->netdev)) {
-		e1000_down(adapter);
-		e1000_reset(adapter);
-		e1000_up(adapter);
-	} else
+	if (netif_running(adapter->netdev))
+		e1000_reinit_locked(adapter);
+	else
 		e1000_reset(adapter);
 
 	return 0;
@@ -254,10 +252,9 @@ e1000_set_pauseparam(struct net_device *
 	hw->original_fc = hw->fc;
 
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
-		if (netif_running(adapter->netdev)) {
-			e1000_down(adapter);
-			e1000_up(adapter);
-		} else
+		if (netif_running(adapter->netdev))
+			e1000_reinit_locked(adapter);
+		else
 			e1000_reset(adapter);
 	} else
 		return ((hw->media_type == e1000_media_type_fiber) ?
@@ -279,10 +276,9 @@ e1000_set_rx_csum(struct net_device *net
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	adapter->rx_csum = data;
 
-	if (netif_running(netdev)) {
-		e1000_down(adapter);
-		e1000_up(adapter);
-	} else
+	if (netif_running(netdev))
+		e1000_reinit_locked(adapter);
+	else
 		e1000_reset(adapter);
 	return 0;
 }
@@ -631,6 +627,9 @@ e1000_set_ringparam(struct net_device *n
 	tx_ring_size = sizeof(struct e1000_tx_ring) * adapter->num_tx_queues;
 	rx_ring_size = sizeof(struct e1000_rx_ring) * adapter->num_rx_queues;
 
+	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
+		msleep(1);
+
 	if (netif_running(adapter->netdev))
 		e1000_down(adapter);
 
@@ -691,9 +690,11 @@ e1000_set_ringparam(struct net_device *n
 		adapter->rx_ring = rx_new;
 		adapter->tx_ring = tx_new;
 		if ((err = e1000_up(adapter)))
-			return err;
+			goto err_setup;
 	}
 
+	clear_bit(__E1000_RESETTING, &adapter->flags);
+
 	return 0;
 err_setup_tx:
 	e1000_free_all_rx_resources(adapter);
@@ -701,6 +702,8 @@ err_setup_rx:
 	adapter->rx_ring = rx_old;
 	adapter->tx_ring = tx_old;
 	e1000_up(adapter);
+err_setup:
+	clear_bit(__E1000_RESETTING, &adapter->flags);
 	return err;
 }
 
@@ -1568,6 +1571,7 @@ e1000_diag_test(struct net_device *netde
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	boolean_t if_running = netif_running(netdev);
 
+	set_bit(__E1000_DRIVER_TESTING, &adapter->flags);
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
 		/* Offline tests */
 
@@ -1582,7 +1586,8 @@ e1000_diag_test(struct net_device *netde
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		if (if_running)
-			e1000_down(adapter);
+			/* indicate we're in test mode */
+			dev_close(netdev);
 		else
 			e1000_reset(adapter);
 
@@ -1607,8 +1612,9 @@ e1000_diag_test(struct net_device *netde
 		adapter->hw.autoneg = autoneg;
 
 		e1000_reset(adapter);
+		clear_bit(__E1000_DRIVER_TESTING, &adapter->flags);
 		if (if_running)
-			e1000_up(adapter);
+			dev_open(netdev);
 	} else {
 		/* Online tests */
 		if (e1000_link_test(adapter, &data[4]))
@@ -1619,6 +1625,8 @@ e1000_diag_test(struct net_device *netde
 		data[1] = 0;
 		data[2] = 0;
 		data[3] = 0;
+
+		clear_bit(__E1000_DRIVER_TESTING, &adapter->flags);
 	}
 	msleep_interruptible(4 * 1000);
 }
@@ -1807,10 +1815,8 @@ static int
 e1000_nway_reset(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	if (netif_running(netdev)) {
-		e1000_down(adapter);
-		e1000_up(adapter);
-	}
+	if (netif_running(netdev))
+		e1000_reinit_locked(adapter);
 	return 0;
 }
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index a373ccb..52d698b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -133,7 +133,6 @@ static void e1000_clean_rx_ring(struct e
 static void e1000_set_multi(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
-static void e1000_watchdog_task(struct e1000_adapter *adapter);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
@@ -261,6 +260,44 @@ e1000_exit_module(void)
 
 module_exit(e1000_exit_module);
 
+static int e1000_request_irq(struct e1000_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int flags, err = 0;
+
+	flags = SA_SHIRQ | SA_SAMPLE_RANDOM;
+#ifdef CONFIG_PCI_MSI
+	if (adapter->hw.mac_type > e1000_82547_rev_2) {
+		adapter->have_msi = TRUE;
+		if ((err = pci_enable_msi(adapter->pdev))) {
+			DPRINTK(PROBE, ERR,
+			 "Unable to allocate MSI interrupt Error: %d\n", err);
+			adapter->have_msi = FALSE;
+		}
+	}
+	if (adapter->have_msi)
+		flags &= ~SA_SHIRQ;
+#endif
+	if ((err = request_irq(adapter->pdev->irq, &e1000_intr, flags,
+	                       netdev->name, netdev)))
+		DPRINTK(PROBE, ERR,
+		        "Unable to allocate interrupt Error: %d\n", err);
+
+	return err;
+}
+
+static void e1000_free_irq(struct e1000_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	free_irq(adapter->pdev->irq, netdev);
+
+#ifdef CONFIG_PCI_MSI
+	if (adapter->have_msi)
+		pci_disable_msi(adapter->pdev);
+#endif
+}
+
 /**
  * e1000_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
@@ -387,7 +424,7 @@ int
 e1000_up(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int i, err;
+	int i;
 
 	/* hardware has been reset, we need to reload some things */
 
@@ -415,24 +452,6 @@ e1000_up(struct e1000_adapter *adapter)
 		                      E1000_DESC_UNUSED(ring));
 	}
 
-#ifdef CONFIG_PCI_MSI
-	if (adapter->hw.mac_type > e1000_82547_rev_2) {
-		adapter->have_msi = TRUE;
-		if ((err = pci_enable_msi(adapter->pdev))) {
-			DPRINTK(PROBE, ERR,
-			 "Unable to allocate MSI interrupt Error: %d\n", err);
-			adapter->have_msi = FALSE;
-		}
-	}
-#endif
-	if ((err = request_irq(adapter->pdev->irq, &e1000_intr,
-		              SA_SHIRQ | SA_SAMPLE_RANDOM,
-		              netdev->name, netdev))) {
-		DPRINTK(PROBE, ERR,
-		    "Unable to allocate interrupt Error: %d\n", err);
-		return err;
-	}
-
 	adapter->tx_queue_len = netdev->tx_queue_len;
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
@@ -450,16 +469,10 @@ e1000_down(struct e1000_adapter *adapter
 {
 	struct net_device *netdev = adapter->netdev;
 	boolean_t mng_mode_enabled = (adapter->hw.mac_type >= e1000_82571) &&
-				     e1000_check_mng_mode(&adapter->hw);
+	                              e1000_check_mng_mode(&adapter->hw);
 
 	e1000_irq_disable(adapter);
 
-	free_irq(adapter->pdev->irq, netdev);
-#ifdef CONFIG_PCI_MSI
-	if (adapter->hw.mac_type > e1000_82547_rev_2 &&
-	   adapter->have_msi == TRUE)
-		pci_disable_msi(adapter->pdev);
-#endif
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
@@ -496,6 +509,17 @@ e1000_down(struct e1000_adapter *adapter
 }
 
 void
+e1000_reinit_locked(struct e1000_adapter *adapter)
+{
+	WARN_ON(in_interrupt());
+	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
+		msleep(1);
+	e1000_down(adapter);
+	e1000_up(adapter);
+	clear_bit(__E1000_RESETTING, &adapter->flags);
+}
+
+void
 e1000_reset(struct e1000_adapter *adapter)
 {
 	uint32_t pba, manc;
@@ -758,9 +782,6 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->watchdog_timer.function = &e1000_watchdog;
 	adapter->watchdog_timer.data = (unsigned long) adapter;
 
-	INIT_WORK(&adapter->watchdog_task,
-		(void (*)(void *))e1000_watchdog_task, adapter);
-
 	init_timer(&adapter->phy_info_timer);
 	adapter->phy_info_timer.function = &e1000_update_phy_info;
 	adapter->phy_info_timer.data = (unsigned long) adapter;
@@ -1078,6 +1099,10 @@ e1000_open(struct net_device *netdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int err;
 
+	/* disallow open during test */
+	if (test_bit(__E1000_DRIVER_TESTING, &adapter->flags))
+		return -EBUSY;
+
 	/* allocate transmit descriptors */
 
 	if ((err = e1000_setup_all_tx_resources(adapter)))
@@ -1088,6 +1113,10 @@ e1000_open(struct net_device *netdev)
 	if ((err = e1000_setup_all_rx_resources(adapter)))
 		goto err_setup_rx;
 
+	err = e1000_request_irq(adapter);
+	if (err)
+		goto err_up;
+
 	if ((err = e1000_up(adapter)))
 		goto err_up;
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
@@ -1131,7 +1160,9 @@ e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
+	WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 	e1000_down(adapter);
+	e1000_free_irq(adapter);
 
 	e1000_free_all_tx_resources(adapter);
 	e1000_free_all_rx_resources(adapter);
@@ -2201,14 +2232,6 @@ static void
 e1000_watchdog(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
-
-	/* Do the rest outside of interrupt context */
-	schedule_work(&adapter->watchdog_task);
-}
-
-static void
-e1000_watchdog_task(struct e1000_adapter *adapter)
-{
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	uint32_t link, tctl;
@@ -2919,8 +2942,7 @@ e1000_reset_task(struct net_device *netd
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	e1000_down(adapter);
-	e1000_up(adapter);
+	e1000_reinit_locked(adapter);
 }
 
 /**
@@ -3026,10 +3048,8 @@ e1000_change_mtu(struct net_device *netd
 
 	netdev->mtu = new_mtu;
 
-	if (netif_running(netdev)) {
-		e1000_down(adapter);
-		e1000_up(adapter);
-	}
+	if (netif_running(netdev))
+		e1000_reinit_locked(adapter);
 
 	adapter->hw.max_frame_size = max_frame;
 
@@ -4180,10 +4200,9 @@ e1000_mii_ioctl(struct net_device *netde
 						return retval;
 					}
 				}
-				if (netif_running(adapter->netdev)) {
-					e1000_down(adapter);
-					e1000_up(adapter);
-				} else
+				if (netif_running(adapter->netdev))
+					e1000_reinit_locked(adapter);
+				else
 					e1000_reset(adapter);
 				break;
 			case M88E1000_PHY_SPEC_CTRL:
@@ -4200,10 +4219,9 @@ e1000_mii_ioctl(struct net_device *netde
 			case PHY_CTRL:
 				if (mii_reg & MII_CR_POWER_DOWN)
 					break;
-				if (netif_running(adapter->netdev)) {
-					e1000_down(adapter);
-					e1000_up(adapter);
-				} else
+				if (netif_running(adapter->netdev))
+					e1000_reinit_locked(adapter);
+				else
 					e1000_reset(adapter);
 				break;
 			}
@@ -4462,8 +4480,10 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 
 	netif_device_detach(netdev);
 
-	if (netif_running(netdev))
+	if (netif_running(netdev)) {
+		WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 		e1000_down(adapter);
+	}
 
 #ifdef CONFIG_PM
 	/* Implement our own version of pci_save_state(pdev) because pci-



--
Auke Kok <auke-jan.h.kok@intel.com>
