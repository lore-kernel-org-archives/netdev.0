From: Patrick McHardy <kaber@trash.net>
Subject: [RFC E1000 02/02]: Secondary unicast address support
Date: Wed, 20 Jun 2007 20:00:25 +0200 (MEST)
Message-ID: <20070620180020.6685.38236.sendpatchset@localhost.localdomain>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55007 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755778AbXFTSA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 14:00:27 -0400
In-Reply-To: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[E1000]: Secondary unicast address support

Add support for configuring secondary unicast addresses. Unicast
addresses take precendece over multicast addresses when filling
the exact address filters to avoid going to promiscous mode.
When more unicast addresses are present than filter slots,
unicast filtering is disabled and all slots can be used for
multicast addresses.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7c1ab0a6f8db6b7f1b9ce6cdd72074e2cb0be8f6
tree f900bbe8894ecd15db22c37d5c60ff3f2acd9f9e
parent 3f3f6e18b902ee177ecf5a108ba6ecbf1b5c9ba3
author Patrick McHardy <kaber@trash.net> Wed, 20 Jun 2007 19:46:06 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 20 Jun 2007 19:46:06 +0200

 drivers/net/e1000/e1000_main.c |   39 +++++++++++++++++++++++++++------------
 1 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index cf8af92..b1f6724 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -149,7 +149,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
                                 struct e1000_tx_ring *tx_ring);
 static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
                                 struct e1000_rx_ring *rx_ring);
-static void e1000_set_multi(struct net_device *netdev);
+static void e1000_set_address_list(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
@@ -513,7 +513,7 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int i;
 
-	e1000_set_multi(netdev);
+	e1000_set_address_list(netdev);
 
 	e1000_restore_vlan(adapter);
 	e1000_init_manageability(adapter);
@@ -924,7 +924,7 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->stop = &e1000_close;
 	netdev->hard_start_xmit = &e1000_xmit_frame;
 	netdev->get_stats = &e1000_get_stats;
-	netdev->set_multicast_list = &e1000_set_multi;
+	netdev->set_address_list = &e1000_set_address_list;
 	netdev->set_mac_address = &e1000_set_mac;
 	netdev->change_mtu = &e1000_change_mtu;
 	netdev->do_ioctl = &e1000_ioctl;
@@ -2412,20 +2412,21 @@ e1000_set_mac(struct net_device *netdev, void *p)
 }
 
 /**
- * e1000_set_multi - Multicast and Promiscuous mode set
+ * e1000_set_address_list - Secondary Unicast, Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
- * The set_multi entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
+ * The set_address_list entry point is called whenever the unicast or multicast
+ * address lists or the network interface flags are updated.  This routine is
  * responsible for configuring the hardware for proper multicast,
  * promiscuous mode, and all-multi behavior.
  **/
 
 static void
-e1000_set_multi(struct net_device *netdev)
+e1000_set_address_list(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	struct dev_uc_list *uc_ptr;
 	struct dev_mc_list *mc_ptr;
 	uint32_t rctl;
 	uint32_t hash_value;
@@ -2449,9 +2450,16 @@ e1000_set_multi(struct net_device *netdev)
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
@@ -2461,7 +2469,10 @@ e1000_set_multi(struct net_device *netdev)
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
@@ -2469,7 +2480,10 @@ e1000_set_multi(struct net_device *netdev)
 	mc_ptr = netdev->mc_list;
 
 	for (i = 1; i < rar_entries; i++) {
-		if (mc_ptr) {
+		if (uc_ptr) {
+			e1000_rar_set(hw, uc_ptr->duci_addr, i);
+			uc_ptr = uc_ptr->next;
+		} else if (mc_ptr) {
 			e1000_rar_set(hw, mc_ptr->dmi_addr, i);
 			mc_ptr = mc_ptr->next;
 		} else {
@@ -2479,6 +2493,7 @@ e1000_set_multi(struct net_device *netdev)
 			E1000_WRITE_FLUSH(hw);
 		}
 	}
+	WARN_ON(uc_ptr != NULL);
 
 	/* clear the old settings from the multicast hash table */
 
@@ -5098,7 +5113,7 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	if (wufc) {
 		e1000_setup_rctl(adapter);
-		e1000_set_multi(netdev);
+		e1000_set_address_list(netdev);
 
 		/* turn on all-multi mode if wake on multicast is enabled */
 		if (wufc & E1000_WUFC_MC) {
