From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 05/15] igb: add combined function for setting rar
	and pool bits
Date: Mon, 05 Oct 2009 09:32:49 -0700
Message-ID: <20091005163248.32487.51010.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:52447 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753716AbZJEQe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:34:59 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds igb_rar_qsel which sets the mac address and pool bits for a
given mac address in the receive address register table.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   63 ++++++++++++++++++++++++++++----------------
 1 files changed, 40 insertions(+), 23 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 714c3a4..bb0aacd 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -127,10 +127,10 @@ static void igb_vlan_rx_register(struct net_device *, struct vlan_group *);
 static void igb_vlan_rx_add_vid(struct net_device *, u16);
 static void igb_vlan_rx_kill_vid(struct net_device *, u16);
 static void igb_restore_vlan(struct igb_adapter *);
+static void igb_rar_set_qsel(struct igb_adapter *, u8 *, u32 , u8);
 static void igb_ping_all_vfs(struct igb_adapter *);
 static void igb_msg_task(struct igb_adapter *);
 static int igb_rcv_msg_from_vf(struct igb_adapter *, u32);
-static inline void igb_set_rah_pool(struct e1000_hw *, int , int);
 static void igb_vmm_control(struct igb_adapter *);
 static int igb_set_vf_mac(struct igb_adapter *adapter, int, unsigned char *);
 static void igb_restore_vf_multicasts(struct igb_adapter *adapter);
@@ -168,16 +168,6 @@ static inline int igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
 	return 0;
 }
 
-static inline void igb_set_rah_pool(struct e1000_hw *hw, int pool, int entry)
-{
-	u32 reg_data;
-
-	reg_data = rd32(E1000_RAH(entry));
-	reg_data &= ~E1000_RAH_POOL_MASK;
-	reg_data |= E1000_RAH_POOL_1 << pool;;
-	wr32(E1000_RAH(entry), reg_data);
-}
-
 #ifdef CONFIG_PM
 static int igb_suspend(struct pci_dev *, pm_message_t);
 static int igb_resume(struct pci_dev *);
@@ -982,7 +972,6 @@ int igb_up(struct igb_adapter *adapter)
 		igb_configure_msix(adapter);
 
 	igb_vmm_control(adapter);
-	igb_set_rah_pool(hw, adapter->vfs_allocated_count, 0);
 	igb_set_vmolr(hw, adapter->vfs_allocated_count);
 
 	/* Clear any pending interrupts. */
@@ -1769,7 +1758,6 @@ static int igb_open(struct net_device *netdev)
 	igb_configure(adapter);
 
 	igb_vmm_control(adapter);
-	igb_set_rah_pool(hw, adapter->vfs_allocated_count, 0);
 	igb_set_vmolr(hw, adapter->vfs_allocated_count);
 
 	err = igb_request_irq(adapter);
@@ -2298,6 +2286,10 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	/* Set the default pool for the PF's first queue */
 	igb_configure_vt_default_pool(adapter);
 
+	/* set the correct pool for the PF default MAC address in entry 0 */
+	igb_rar_set_qsel(adapter, adapter->hw.mac.addr, 0,
+	                 adapter->vfs_allocated_count);
+
 	igb_rlpml_set(adapter);
 
 	/* Enable Receives */
@@ -2521,8 +2513,9 @@ static int igb_set_mac(struct net_device *netdev, void *p)
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
-	igb_rar_set(hw, hw->mac.addr, 0);
-	igb_set_rah_pool(hw, adapter->vfs_allocated_count, 0);
+	/* set the correct pool for the new PF MAC address in entry 0 */
+	igb_rar_set_qsel(adapter, hw->mac.addr, 0,
+	                 adapter->vfs_allocated_count);
 
 	return 0;
 }
@@ -2572,10 +2565,9 @@ static void igb_set_rx_mode(struct net_device *netdev)
 		list_for_each_entry(ha, &netdev->uc.list, list) {
 			if (!rar_entries)
 				break;
-			igb_rar_set(hw, ha->addr, rar_entries);
-			igb_set_rah_pool(hw, adapter->vfs_allocated_count,
-			                 rar_entries);
-			rar_entries--;
+			igb_rar_set_qsel(adapter, ha->addr,
+			                 rar_entries--,
+			                 adapter->vfs_allocated_count);
 		}
 	}
 	/* write the addresses in reverse order to avoid write combining */
@@ -4142,8 +4134,7 @@ static inline void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
 	igb_vf_reset_event(adapter, vf);
 
 	/* set vf mac address */
-	igb_rar_set(hw, vf_mac, rar_entry);
-	igb_set_rah_pool(hw, vf, rar_entry);
+	igb_rar_set_qsel(adapter, vf_mac, rar_entry, vf);
 
 	/* enable transmit and receive for vf */
 	reg = rd32(E1000_VFTE);
@@ -5532,6 +5523,33 @@ static void igb_io_resume(struct pci_dev *pdev)
 	igb_get_hw_control(adapter);
 }
 
+static void igb_rar_set_qsel(struct igb_adapter *adapter, u8 *addr, u32 index,
+                             u8 qsel)
+{
+	u32 rar_low, rar_high;
+	struct e1000_hw *hw = &adapter->hw;
+
+	/* HW expects these in little endian so we reverse the byte order
+	 * from network order (big endian) to little endian
+	 */
+	rar_low = ((u32) addr[0] | ((u32) addr[1] << 8) |
+	          ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
+	rar_high = ((u32) addr[4] | ((u32) addr[5] << 8));
+
+	/* Indicate to hardware the Address is Valid. */
+	rar_high |= E1000_RAH_AV;
+
+	if (hw->mac.type == e1000_82575)
+		rar_high |= E1000_RAH_POOL_1 * qsel;
+	else
+		rar_high |= E1000_RAH_POOL_1 << qsel;
+
+	wr32(E1000_RAL(index), rar_low);
+	wrfl();
+	wr32(E1000_RAH(index), rar_high);
+	wrfl();
+}
+
 static int igb_set_vf_mac(struct igb_adapter *adapter,
                           int vf, unsigned char *mac_addr)
 {
@@ -5542,8 +5560,7 @@ static int igb_set_vf_mac(struct igb_adapter *adapter,
 
 	memcpy(adapter->vf_data[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
 
-	igb_rar_set(hw, mac_addr, rar_entry);
-	igb_set_rah_pool(hw, vf, rar_entry);
+	igb_rar_set_qsel(adapter, mac_addr, rar_entry, vf);
 
 	return 0;
 }

