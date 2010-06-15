From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: update set_rx_mode to fix issues w/
	macvlan
Date: Tue, 15 Jun 2010 12:25:48 -0700
Message-ID: <20100615192432.3011.29215.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Shirley Ma <xma@us.ibm.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:59963 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754047Ab0FOT0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 15:26:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change corrects issues where macvlan was not correctly triggering
promiscuous mode on ixgbe due to the filters not being correctly set.  It
also corrects the fact that VF rar filters were being overwritten when the
PF was reset.

CC: Shirley Ma <xma@us.ibm.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h       |    1 
 drivers/net/ixgbe/ixgbe_main.c  |   88 +++++++++++++++++++++++++++++++++------
 drivers/net/ixgbe/ixgbe_sriov.c |   16 ++-----
 3 files changed, 79 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 9270089..9e15eb9 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -110,7 +110,6 @@ struct vf_data_storage {
 	u16 vlans_enabled;
 	bool clear_to_send;
 	bool pf_set_mac;
-	int rar;
 	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 	u16 pf_qos;
 };
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9cca737..ebc4b04 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2992,6 +2992,48 @@ static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
 }
 
 /**
+ * ixgbe_write_uc_addr_list - write unicast addresses to RAR table
+ * @netdev: network interface device structure
+ *
+ * Writes unicast address list to the RAR table.
+ * Returns: -ENOMEM on failure/insufficient address space
+ *                0 on no addresses written
+ *                X on writing X addresses to the RAR table
+ **/
+static int ixgbe_write_uc_addr_list(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	unsigned int vfn = adapter->num_vfs;
+	unsigned int rar_entries = hw->mac.num_rar_entries - (vfn + 1);
+	int count = 0;
+
+	/* return ENOMEM indicating insufficient memory for addresses */
+	if (netdev_uc_count(netdev) > rar_entries)
+		return -ENOMEM;
+
+	if (!netdev_uc_empty(netdev) && rar_entries) {
+		struct netdev_hw_addr *ha;
+		/* return error if we do not support writing to RAR table */
+		if (!hw->mac.ops.set_rar)
+			return -ENOMEM;
+
+		netdev_for_each_uc_addr(ha, netdev) {
+			if (!rar_entries)
+				break;
+			hw->mac.ops.set_rar(hw, rar_entries--, ha->addr,
+					    vfn, IXGBE_RAH_AV);
+			count++;
+		}
+	}
+	/* write the addresses in reverse order to avoid write combining */
+	for (; rar_entries > 0 ; rar_entries--)
+		hw->mac.ops.clear_rar(hw, rar_entries);
+
+	return count;
+}
+
+/**
  * ixgbe_set_rx_mode - Unicast, Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
@@ -3004,38 +3046,58 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 fctrl;
+	u32 fctrl, vmolr = IXGBE_VMOLR_BAM | IXGBE_VMOLR_AUPE;
+	int count;
 
 	/* Check for Promiscuous and All Multicast modes */
 
 	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 
+	/* clear the bits we are changing the status of */
+	fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
+
 	if (netdev->flags & IFF_PROMISC) {
 		hw->addr_ctrl.user_set_promisc = true;
 		fctrl |= (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
+		vmolr |= (IXGBE_VMOLR_ROPE | IXGBE_VMOLR_MPE);
 		/* don't hardware filter vlans in promisc mode */
 		ixgbe_vlan_filter_disable(adapter);
 	} else {
 		if (netdev->flags & IFF_ALLMULTI) {
 			fctrl |= IXGBE_FCTRL_MPE;
-			fctrl &= ~IXGBE_FCTRL_UPE;
-		} else if (!hw->addr_ctrl.uc_set_promisc) {
-			fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
+			vmolr |= IXGBE_VMOLR_MPE;
+		} else {
+			/*
+			 * Write addresses to the MTA, if the attempt fails
+			 * then we should just turn on promiscous mode so
+			 * that we can at least receive multicast traffic
+			 */
+			hw->mac.ops.update_mc_addr_list(hw, netdev);
+			vmolr |= IXGBE_VMOLR_ROMPE;
 		}
 		ixgbe_vlan_filter_enable(adapter);
 		hw->addr_ctrl.user_set_promisc = false;
+		/*
+		 * Write addresses to available RAR registers, if there is not
+		 * sufficient space to store all the addresses then enable
+		 * unicast promiscous mode
+		 */
+		count = ixgbe_write_uc_addr_list(netdev);
+		if (count < 0) {
+			fctrl |= IXGBE_FCTRL_UPE;
+			vmolr |= IXGBE_VMOLR_ROPE;
+		}
 	}
 
-	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
-
-	/* reprogram secondary unicast list */
-	hw->mac.ops.update_uc_addr_list(hw, netdev);
-
-	/* reprogram multicast list */
-	hw->mac.ops.update_mc_addr_list(hw, netdev);
-
-	if (adapter->num_vfs)
+	if (adapter->num_vfs) {
 		ixgbe_restore_vf_multicasts(adapter);
+		vmolr |= IXGBE_READ_REG(hw, IXGBE_VMOLR(adapter->num_vfs)) &
+			 ~(IXGBE_VMOLR_MPE | IXGBE_VMOLR_ROMPE |
+			   IXGBE_VMOLR_ROPE);
+		IXGBE_WRITE_REG(hw, IXGBE_VMOLR(adapter->num_vfs), vmolr);
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
 }
 
 static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 66f6e62..6e6dee0 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -137,6 +137,7 @@ static void ixgbe_set_vmvir(struct ixgbe_adapter *adapter, u32 vid, u32 vf)
 inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
 
 	/* reset offloads to defaults */
 	if (adapter->vfinfo[vf].pf_vlan) {
@@ -158,26 +159,17 @@ inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 	/* Flush and reset the mta with the new values */
 	ixgbe_set_rx_mode(adapter->netdev);
 
-	if (adapter->vfinfo[vf].rar > 0) {
-		adapter->hw.mac.ops.clear_rar(&adapter->hw,
-		                              adapter->vfinfo[vf].rar);
-		adapter->vfinfo[vf].rar = -1;
-	}
+	hw->mac.ops.clear_rar(hw, rar_entry);
 }
 
 int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
                           int vf, unsigned char *mac_addr)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-
-	adapter->vfinfo[vf].rar = hw->mac.ops.set_rar(hw, vf + 1, mac_addr,
-	                                              vf, IXGBE_RAH_AV);
-	if (adapter->vfinfo[vf].rar < 0) {
-		e_err("Could not set MAC Filter for VF %d\n", vf);
-		return -1;
-	}
+	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
 
 	memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr, 6);
+	hw->mac.ops.set_rar(hw, rar_entry, mac_addr, vf, IXGBE_RAH_AV);
 
 	return 0;
 }

