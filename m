From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/6] e1000: Secondary unicast address support
Date: Tue, 13 Nov 2007 15:11:33 -0800
Message-ID: <20071113231133.13177.84769.stgit@localhost.localdomain>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756739AbXKMXLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 18:11:34 -0500
In-Reply-To: <20071113231110.13177.27339.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Add support for configuring secondary unicast addresses. Unicast
addresses take precendece over multicast addresses when filling
the exact address filters to avoid going to promiscous mode.
When more unicast addresses are present than filter slots,
unicast filtering is disabled and all slots can be used for
multicast addresses.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   47 ++++++++++++++++++++++++++--------------
 1 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index e1ba705..dc4934d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -126,7 +126,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
                                 struct e1000_tx_ring *tx_ring);
 static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
                                 struct e1000_rx_ring *rx_ring);
-static void e1000_set_multi(struct net_device *netdev);
+static void e1000_set_rx_mode(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
@@ -487,7 +487,7 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int i;
 
-	e1000_set_multi(netdev);
+	e1000_set_rx_mode(netdev);
 
 	e1000_restore_vlan(adapter);
 	e1000_init_manageability(adapter);
@@ -899,7 +899,7 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->stop = &e1000_close;
 	netdev->hard_start_xmit = &e1000_xmit_frame;
 	netdev->get_stats = &e1000_get_stats;
-	netdev->set_multicast_list = &e1000_set_multi;
+	netdev->set_rx_mode = &e1000_set_rx_mode;
 	netdev->set_mac_address = &e1000_set_mac;
 	netdev->change_mtu = &e1000_change_mtu;
 	netdev->do_ioctl = &e1000_ioctl;
@@ -2382,21 +2382,22 @@ e1000_set_mac(struct net_device *netdev, void *p)
 }
 
 /**
- * e1000_set_multi - Multicast and Promiscuous mode set
+ * e1000_set_rx_mode - Secondary Unicast, Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
- * The set_multi entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper multicast,
+ * The set_rx_mode entry point is called whenever the unicast or multicast
+ * address lists or the network interface flags are updated. This routine is
+ * responsible for configuring the hardware for proper unicast, multicast,
  * promiscuous mode, and all-multi behavior.
  **/
 
 static void
-e1000_set_multi(struct net_device *netdev)
+e1000_set_rx_mode(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct dev_addr_list *uc_ptr;
+	struct dev_addr_list *mc_ptr;
 	uint32_t rctl;
 	uint32_t hash_value;
 	int i, rar_entries = E1000_RAR_ENTRIES;
@@ -2419,9 +2420,16 @@ e1000_set_multi(struct net_device *netdev)
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
 	} else if (netdev->flags & IFF_ALLMULTI) {
 		rctl |= E1000_RCTL_MPE;
-		rctl &= ~E1000_RCTL_UPE;
 	} else {
-		rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
+		rctl &= ~E1000_RCTL_MPE;
+	}
+
+	uc_ptr = NULL;
+	if (netdev->uc_count > rar_entries - 1) {
+		rctl |= E1000_RCTL_UPE;
+	} else if (!(netdev->flags & IFF_PROMISC)) {
+		rctl &= ~E1000_RCTL_UPE;
+		uc_ptr = netdev->uc_list;
 	}
 
 	E1000_WRITE_REG(hw, RCTL, rctl);
@@ -2431,7 +2439,10 @@ e1000_set_multi(struct net_device *netdev)
 	if (hw->mac_type == e1000_82542_rev2_0)
 		e1000_enter_82542_rst(adapter);
 
-	/* load the first 14 multicast address into the exact filters 1-14
+	/* load the first 14 addresses into the exact filters 1-14. Unicast
+	 * addresses take precedence to avoid disabling unicast filtering
+	 * when possible.
+	 *
 	 * RAR 0 is used for the station MAC adddress
 	 * if there are not 14 addresses, go ahead and clear the filters
 	 * -- with 82571 controllers only 0-13 entries are filled here
@@ -2439,8 +2450,11 @@ e1000_set_multi(struct net_device *netdev)
 	mc_ptr = netdev->mc_list;
 
 	for (i = 1; i < rar_entries; i++) {
-		if (mc_ptr) {
-			e1000_rar_set(hw, mc_ptr->dmi_addr, i);
+		if (uc_ptr) {
+			e1000_rar_set(hw, uc_ptr->da_addr, i);
+			uc_ptr = uc_ptr->next;
+		} else if (mc_ptr) {
+			e1000_rar_set(hw, mc_ptr->da_addr, i);
 			mc_ptr = mc_ptr->next;
 		} else {
 			E1000_WRITE_REG_ARRAY(hw, RA, i << 1, 0);
@@ -2449,6 +2463,7 @@ e1000_set_multi(struct net_device *netdev)
 			E1000_WRITE_FLUSH(hw);
 		}
 	}
+	WARN_ON(uc_ptr != NULL);
 
 	/* clear the old settings from the multicast hash table */
 
@@ -2460,7 +2475,7 @@ e1000_set_multi(struct net_device *netdev)
 	/* load any remaining addresses into the hash table */
 
 	for (; mc_ptr; mc_ptr = mc_ptr->next) {
-		hash_value = e1000_hash_mc_addr(hw, mc_ptr->dmi_addr);
+		hash_value = e1000_hash_mc_addr(hw, mc_ptr->da_addr);
 		e1000_mta_set(hw, hash_value);
 	}
 
@@ -5079,7 +5094,7 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	if (wufc) {
 		e1000_setup_rctl(adapter);
-		e1000_set_multi(netdev);
+		e1000_set_rx_mode(netdev);
 
 		/* turn on all-multi mode if wake on multicast is enabled */
 		if (wufc & E1000_WUFC_MC) {
