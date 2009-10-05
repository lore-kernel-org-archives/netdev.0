From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 06/15] igb: make use of the uta to allow for
	promiscous mode filter
Date: Mon, 05 Oct 2009 09:33:08 -0700
Message-ID: <20091005163307.32487.75656.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:46258 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753976AbZJEQex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:34:53 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In order to support functions such as vlan tag stripping when SR-IOV is
enabled any given packet must match at least one filter.  However in the
case of promiscous mode being enabled on the PF the traffic routed to it
may not match any filters and is just sent to the PF by default.  In order
to make certain that this traffic is processed we can set all bits in the
UTA registers to create a pseudo promiscous mode filter that accepts all
packets.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    5 +
 drivers/net/igb/e1000_hw.h    |    1 
 drivers/net/igb/e1000_regs.h  |    1 
 drivers/net/igb/igb_main.c    |  203 ++++++++++++++++++++++++++++++++---------
 4 files changed, 163 insertions(+), 47 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 7897181..b8a88a8 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -875,6 +875,11 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 	for (i = 0; i < mac->mta_reg_count; i++)
 		array_wr32(E1000_MTA, i, 0);
 
+	/* Zero out the Unicast HASH table */
+	hw_dbg("Zeroing the UTA\n");
+	for (i = 0; i < mac->uta_reg_count; i++)
+		array_wr32(E1000_UTA, i, 0);
+
 	/* Setup link and flow control */
 	ret_val = igb_setup_link(hw);
 
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index b1e0c06..7b7898b 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -340,6 +340,7 @@ struct e1000_mac_info {
 	u16 ifs_ratio;
 	u16 ifs_step_size;
 	u16 mta_reg_count;
+	u16 uta_reg_count;
 
 	/* Maximum size of the MTA register table in all supported adapters */
 	#define MAX_MTA_REG 128
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 345d144..76c3389 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -331,6 +331,7 @@ enum {
 #define E1000_QDE       0x02408 /* Queue Drop Enable - RW */
 #define E1000_DTXSWC    0x03500 /* DMA Tx Switch Control - RW */
 #define E1000_RPLOLR    0x05AF0 /* Replication Offload - RW */
+#define E1000_UTA       0x0A000 /* Unicast Table Array - RW */
 #define E1000_IOVTCL    0x05BBC /* IOV Control Register */
 /* These act per VF so an array friendly macro is used */
 #define E1000_P2VMAILBOX(_n)   (0x00C00 + (4 * (_n)))
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index bb0aacd..fdbe332 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -106,6 +106,7 @@ static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb,
 static struct net_device_stats *igb_get_stats(struct net_device *);
 static int igb_change_mtu(struct net_device *, int);
 static int igb_set_mac(struct net_device *, void *);
+static void igb_set_uta(struct igb_adapter *adapter);
 static irqreturn_t igb_intr(int irq, void *);
 static irqreturn_t igb_intr_msi(int irq, void *);
 static irqreturn_t igb_msix_other(int irq, void *);
@@ -141,7 +142,6 @@ static inline void igb_set_vmolr(struct e1000_hw *hw, int vfn)
 
 	reg_data = rd32(E1000_VMOLR(vfn));
 	reg_data |= E1000_VMOLR_BAM |	 /* Accept broadcast */
-	            E1000_VMOLR_ROPE |   /* Accept packets matched in UTA */
 	            E1000_VMOLR_ROMPE |  /* Accept packets matched in MTA */
 	            E1000_VMOLR_AUPE |   /* Accept untagged packets */
 	            E1000_VMOLR_STRVLAN; /* Strip vlan tags */
@@ -2286,6 +2286,9 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	/* Set the default pool for the PF's first queue */
 	igb_configure_vt_default_pool(adapter);
 
+	/* set UTA to appropriate mode */
+	igb_set_uta(adapter);
+
 	/* set the correct pool for the PF default MAC address in entry 0 */
 	igb_rar_set_qsel(adapter, adapter->hw.mac.addr, 0,
 	                 adapter->vfs_allocated_count);
@@ -2521,44 +2524,72 @@ static int igb_set_mac(struct net_device *netdev, void *p)
 }
 
 /**
- * igb_set_rx_mode - Secondary Unicast, Multicast and Promiscuous mode set
+ * igb_write_mc_addr_list - write multicast addresses to MTA
  * @netdev: network interface device structure
  *
- * The set_rx_mode entry point is called whenever the unicast or multicast
- * address lists or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper unicast, multicast,
- * promiscuous mode, and all-multi behavior.
+ * Writes multicast address list to the MTA hash table.
+ * Returns: -ENOMEM on failure
+ *                0 on no addresses written
+ *                X on writing X addresses to MTA
  **/
-static void igb_set_rx_mode(struct net_device *netdev)
+static int igb_write_mc_addr_list(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	unsigned int rar_entries = hw->mac.rar_entry_count -
-	                           (adapter->vfs_allocated_count + 1);
 	struct dev_mc_list *mc_ptr = netdev->mc_list;
-	u8  *mta_list = NULL;
-	u32 rctl;
+	u8  *mta_list;
+	u32 vmolr = 0;
 	int i;
 
-	/* Check for Promiscuous and All Multicast modes */
-	rctl = rd32(E1000_RCTL);
+	if (!netdev->mc_count) {
+		/* nothing to program, so clear mc list */
+		igb_update_mc_addr_list(hw, NULL, 0);
+		igb_restore_vf_multicasts(adapter);
+		return 0;
+	}
 
-	if (netdev->flags & IFF_PROMISC) {
-		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
-		rctl &= ~E1000_RCTL_VFE;
-	} else {
-		if (netdev->flags & IFF_ALLMULTI)
-			rctl |= E1000_RCTL_MPE;
-		else
-			rctl &= ~E1000_RCTL_MPE;
+	mta_list = kzalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	if (!mta_list)
+		return -ENOMEM;
 
-		if (netdev->uc.count > rar_entries)
-			rctl |= E1000_RCTL_UPE;
-		else
-			rctl &= ~E1000_RCTL_UPE;
-		rctl |= E1000_RCTL_VFE;
+	/* set vmolr receive overflow multicast bit */
+	vmolr |= E1000_VMOLR_ROMPE;
+
+	/* The shared function expects a packed array of only addresses. */
+	mc_ptr = netdev->mc_list;
+
+	for (i = 0; i < netdev->mc_count; i++) {
+		if (!mc_ptr)
+			break;
+		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
+		mc_ptr = mc_ptr->next;
 	}
-	wr32(E1000_RCTL, rctl);
+	igb_update_mc_addr_list(hw, mta_list, i);
+	kfree(mta_list);
+
+	return netdev->mc_count;
+}
+
+/**
+ * igb_write_uc_addr_list - write unicast addresses to RAR table
+ * @netdev: network interface device structure
+ *
+ * Writes unicast address list to the RAR table.
+ * Returns: -ENOMEM on failure/insufficient address space
+ *                0 on no addresses written
+ *                X on writing X addresses to the RAR table
+ **/
+static int igb_write_uc_addr_list(struct net_device *netdev)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	unsigned int vfn = adapter->vfs_allocated_count;
+	unsigned int rar_entries = hw->mac.rar_entry_count - (vfn + 1);
+	int count = 0;
+
+	/* return ENOMEM indicating insufficient memory for addresses */
+	if (netdev->uc.count > rar_entries)
+		return -ENOMEM;
 
 	if (netdev->uc.count && rar_entries) {
 		struct netdev_hw_addr *ha;
@@ -2567,7 +2598,8 @@ static void igb_set_rx_mode(struct net_device *netdev)
 				break;
 			igb_rar_set_qsel(adapter, ha->addr,
 			                 rar_entries--,
-			                 adapter->vfs_allocated_count);
+			                 vfn);
+			count++;
 		}
 	}
 	/* write the addresses in reverse order to avoid write combining */
@@ -2577,29 +2609,79 @@ static void igb_set_rx_mode(struct net_device *netdev)
 	}
 	wrfl();
 
-	if (!netdev->mc_count) {
-		/* nothing to program, so clear mc list */
-		igb_update_mc_addr_list(hw, NULL, 0);
-		igb_restore_vf_multicasts(adapter);
-		return;
+	return count;
+}
+
+/**
+ * igb_set_rx_mode - Secondary Unicast, Multicast and Promiscuous mode set
+ * @netdev: network interface device structure
+ *
+ * The set_rx_mode entry point is called whenever the unicast or multicast
+ * address lists or the network interface flags are updated.  This routine is
+ * responsible for configuring the hardware for proper unicast, multicast,
+ * promiscuous mode, and all-multi behavior.
+ **/
+static void igb_set_rx_mode(struct net_device *netdev)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	unsigned int vfn = adapter->vfs_allocated_count;
+	u32 rctl, vmolr = 0;
+	int count;
+
+	/* Check for Promiscuous and All Multicast modes */
+	rctl = rd32(E1000_RCTL);
+
+	/* clear the effected bits */
+	rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE | E1000_RCTL_VFE);
+
+	if (netdev->flags & IFF_PROMISC) {
+		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
+		vmolr |= (E1000_VMOLR_ROPE | E1000_VMOLR_MPME);
+	} else {
+		if (netdev->flags & IFF_ALLMULTI) {
+			rctl |= E1000_RCTL_MPE;
+			vmolr |= E1000_VMOLR_MPME;
+		} else {
+			/*
+			 * Write addresses to the MTA, if the attempt fails
+			 * then we should just turn on promiscous mode so
+			 * that we can at least receive multicast traffic
+			 */
+			count = igb_write_mc_addr_list(netdev);
+			if (count < 0) {
+				rctl |= E1000_RCTL_MPE;
+				vmolr |= E1000_VMOLR_MPME;
+			} else if (count) {
+				vmolr |= E1000_VMOLR_ROMPE;
+			}
+		}
+		/*
+		 * Write addresses to available RAR registers, if there is not
+		 * sufficient space to store all the addresses then enable
+		 * unicast promiscous mode
+		 */
+		count = igb_write_uc_addr_list(netdev);
+		if (count < 0) {
+			rctl |= E1000_RCTL_UPE;
+			vmolr |= E1000_VMOLR_ROPE;
+		}
+		rctl |= E1000_RCTL_VFE;
 	}
+	wr32(E1000_RCTL, rctl);
 
-	mta_list = kzalloc(netdev->mc_count * 6, GFP_ATOMIC);
-	if (!mta_list) {
-		dev_err(&adapter->pdev->dev,
-		        "failed to allocate multicast filter list\n");
+	/*
+	 * In order to support SR-IOV and eventually VMDq it is necessary to set
+	 * the VMOLR to enable the appropriate modes.  Without this workaround
+	 * we will have issues with VLAN tag stripping not being done for frames
+	 * that are only arriving because we are the default pool
+	 */
+	if (hw->mac.type < e1000_82576)
 		return;
-	}
 
-	/* The shared function expects a packed array of only addresses. */
-	for (i = 0; i < netdev->mc_count; i++) {
-		if (!mc_ptr)
-			break;
-		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
-		mc_ptr = mc_ptr->next;
-	}
-	igb_update_mc_addr_list(hw, mta_list, i);
-	kfree(mta_list);
+	vmolr |= rd32(E1000_VMOLR(vfn)) &
+	         ~(E1000_VMOLR_ROPE | E1000_VMOLR_MPME | E1000_VMOLR_ROMPE);
+	wr32(E1000_VMOLR(vfn), vmolr);
 	igb_restore_vf_multicasts(adapter);
 }
 
@@ -4264,6 +4346,33 @@ static int igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 }
 
 /**
+ *  igb_set_uta - Set unicast filter table address
+ *  @adapter: board private structure
+ *
+ *  The unicast table address is a register array of 32-bit registers.
+ *  The table is meant to be used in a way similar to how the MTA is used
+ *  however due to certain limitations in the hardware it is necessary to
+ *  set all the hash bits to 1 and use the VMOLR ROPE bit as a promiscous
+ *  enable bit to allow vlan tag stripping when promiscous mode is enabled
+ **/
+static void igb_set_uta(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int i;
+
+	/* The UTA table only exists on 82576 hardware and newer */
+	if (hw->mac.type < e1000_82576)
+		return;
+
+	/* we only need to do this if VMDq is enabled */
+	if (!adapter->vfs_allocated_count)
+		return;
+
+	for (i = 0; i < hw->mac.uta_reg_count; i++)
+		array_wr32(E1000_UTA, i, ~0);
+}
+
+/**
  * igb_intr_msi - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure

