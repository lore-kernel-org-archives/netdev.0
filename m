From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/5] igb: add pf side of VMDq support
Date: Thu, 19 Feb 2009 20:39:44 -0800
Message-ID: <20090220043944.29650.38934.stgit@lost.foo-projects.org>
References: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Yu Zhao <yu.zhao@intel.com>,
	LKML <linux-kernel@vger.kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:46443 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753112AbZBTEkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 23:40:06 -0500
In-Reply-To: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Add the pf portion of vmdq support.  This provides enough support so that
VMDq is enabled, and the pf is functional without enabling vfs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Yu Zhao <yu.zhao@intel.com>
CC: LKML <linux-kernel@vger.kernel.org>
---

 drivers/net/igb/e1000_82575.h   |   26 ++++++
 drivers/net/igb/e1000_defines.h |    2 
 drivers/net/igb/e1000_regs.h    |    7 +-
 drivers/net/igb/igb.h           |    3 -
 drivers/net/igb/igb_ethtool.c   |    2 
 drivers/net/igb/igb_main.c      |  174 ++++++++++++++++++++++++++++++++++++---
 6 files changed, 195 insertions(+), 19 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 49b41c9..116714f 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -40,8 +40,11 @@ extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
 #define E1000_SRRCTL_BSIZEHDRSIZE_SHIFT                 2  /* Shift _left_ */
 #define E1000_SRRCTL_DESCTYPE_ADV_ONEBUF                0x02000000
 #define E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS          0x0A000000
+#define E1000_SRRCTL_DROP_EN                            0x80000000
 
 #define E1000_MRQC_ENABLE_RSS_4Q            0x00000002
+#define E1000_MRQC_ENABLE_VMDQ              0x00000003
+#define E1000_MRQC_ENABLE_VMDQ_RSS_2Q       0x00000005
 #define E1000_MRQC_RSS_FIELD_IPV4_UDP       0x00400000
 #define E1000_MRQC_RSS_FIELD_IPV6_UDP       0x00800000
 #define E1000_MRQC_RSS_FIELD_IPV6_UDP_EX    0x01000000
@@ -159,4 +162,27 @@ struct e1000_adv_tx_context_desc {
 #define E1000_DCA_TXCTRL_CPUID_SHIFT 24 /* Tx CPUID now in the last byte */
 #define E1000_DCA_RXCTRL_CPUID_SHIFT 24 /* Rx CPUID now in the last byte */
 
+/* Easy defines for setting default pool, would normally be left a zero */
+#define E1000_VT_CTL_DEFAULT_POOL_SHIFT 7
+#define E1000_VT_CTL_DEFAULT_POOL_MASK  (0x7 << E1000_VT_CTL_DEFAULT_POOL_SHIFT)
+
+/* Other useful VMD_CTL register defines */
+#define E1000_VT_CTL_IGNORE_MAC         (1 << 28)
+#define E1000_VT_CTL_DISABLE_DEF_POOL   (1 << 29)
+#define E1000_VT_CTL_VM_REPL_EN         (1 << 30)
+
+/* Per VM Offload register setup */
+#define E1000_VMOLR_RLPML_MASK 0x00003FFF /* Long Packet Maximum Length mask */
+#define E1000_VMOLR_LPE        0x00010000 /* Accept Long packet */
+#define E1000_VMOLR_RSSE       0x00020000 /* Enable RSS */
+#define E1000_VMOLR_AUPE       0x01000000 /* Accept untagged packets */
+#define E1000_VMOLR_ROMPE      0x02000000 /* Accept overflow multicast */
+#define E1000_VMOLR_ROPE       0x04000000 /* Accept overflow unicast */
+#define E1000_VMOLR_BAM        0x08000000 /* Accept Broadcast packets */
+#define E1000_VMOLR_MPME       0x10000000 /* Multicast promiscuous mode */
+#define E1000_VMOLR_STRVLAN    0x40000000 /* Vlan stripping enable */
+
+#define ALL_QUEUES   0xFFFF
+
+
 #endif
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 5a32a70..d7613db 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -399,6 +399,8 @@
 #define E1000_RAH_AV  0x80000000        /* Receive descriptor valid */
 #define E1000_RAL_MAC_ADDR_LEN 4
 #define E1000_RAH_MAC_ADDR_LEN 2
+#define E1000_RAH_POOL_MASK 0x03FC0000
+#define E1000_RAH_POOL_1 0x00040000
 
 /* Error Codes */
 #define E1000_ERR_NVM      1
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 95ed8ec..5d00c86 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -292,7 +292,7 @@ enum {
 #define E1000_RAH(_i)  (((_i) <= 15) ? (0x05404 + ((_i) * 8)) : \
                                        (0x054E4 + ((_i - 16) * 8)))
 #define E1000_VFTA     0x05600  /* VLAN Filter Table Array - RW Array */
-#define E1000_VMD_CTL  0x0581C  /* VMDq Control - RW */
+#define E1000_VT_CTL   0x0581C  /* VMDq Control - RW */
 #define E1000_WUC      0x05800  /* Wakeup Control - RW */
 #define E1000_WUFC     0x05808  /* Wakeup Filter Control - RW */
 #define E1000_WUS      0x05810  /* Wakeup Status - RO */
@@ -320,6 +320,11 @@ enum {
 #define E1000_RETA(_i)  (0x05C00 + ((_i) * 4))
 #define E1000_RSSRK(_i) (0x05C80 + ((_i) * 4)) /* RSS Random Key - RW Array */
 
+/* VT Registers */
+#define E1000_QDE       0x02408 /* Queue Drop Enable - RW */
+/* These act per VF so an array friendly macro is used */
+#define E1000_VMOLR(_n)        (0x05AD0 + (4 * (_n)))
+
 #define wr32(reg, value) (writel(value, hw->hw_addr + reg))
 #define rd32(reg) (readl(hw->hw_addr + reg))
 #define wrfl() ((void)rd32(E1000_STATUS))
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 3d3e5f6..d925f7d 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -88,8 +88,7 @@ struct igb_adapter;
 #define IGB_RXBUFFER_2048  2048
 #define IGB_RXBUFFER_16384 16384
 
-/* Packet Buffer allocations */
-
+#define MAX_STD_JUMBO_FRAME_SIZE 9234
 
 /* How many Tx Descriptors do we need to call netif_wake_queue ? */
 #define IGB_TX_QUEUE_WAKE	16
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 31f9a64..34a8a0f 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -398,7 +398,7 @@ static void igb_get_regs(struct net_device *netdev,
 	regs_buff[34] = rd32(E1000_RLPML);
 	regs_buff[35] = rd32(E1000_RFCTL);
 	regs_buff[36] = rd32(E1000_MRQC);
-	regs_buff[37] = rd32(E1000_VMD_CTL);
+	regs_buff[37] = rd32(E1000_VT_CTL);
 
 	/* Transmit */
 	regs_buff[38] = rd32(E1000_TCTL);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 014570a..6ca3043 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -122,6 +122,10 @@ static void igb_vlan_rx_register(struct net_device *, struct vlan_group *);
 static void igb_vlan_rx_add_vid(struct net_device *, u16);
 static void igb_vlan_rx_kill_vid(struct net_device *, u16);
 static void igb_restore_vlan(struct igb_adapter *);
+static inline void igb_set_rah_pool(struct e1000_hw *, int , int);
+static void igb_set_mc_list_pools(struct igb_adapter *, int, u16);
+static inline void igb_set_vmolr(struct e1000_hw *, int);
+static inline void igb_set_vf_rlpml(struct igb_adapter *, int, int);
 
 static int igb_suspend(struct pci_dev *, pm_message_t);
 #ifdef CONFIG_PM
@@ -888,6 +892,9 @@ int igb_up(struct igb_adapter *adapter)
 	if (adapter->msix_entries)
 		igb_configure_msix(adapter);
 
+	igb_set_rah_pool(hw, adapter->vfs_allocated_count, 0);
+	igb_set_vmolr(hw, adapter->vfs_allocated_count);
+
 	/* Clear any pending interrupts. */
 	rd32(E1000_ICR);
 	igb_irq_enable(adapter);
@@ -1617,6 +1624,9 @@ static int igb_open(struct net_device *netdev)
 	 * clean_rx handler before we do so.  */
 	igb_configure(adapter);
 
+	igb_set_rah_pool(hw, adapter->vfs_allocated_count, 0);
+	igb_set_vmolr(hw, adapter->vfs_allocated_count);
+
 	err = igb_request_irq(adapter);
 	if (err)
 		goto err_req_irq;
@@ -1797,10 +1807,11 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 		wr32(E1000_DCA_TXCTRL(j), txctrl);
 	}
 
-	/* Use the default values for the Tx Inter Packet Gap (IPG) timer */
+	/* disable queue 0 to prevent tail bump w/o re-configuration */
+	if (adapter->vfs_allocated_count)
+		wr32(E1000_TXDCTL(0), 0);
 
 	/* Program the Transmit Control Register */
-
 	tctl = rd32(E1000_TCTL);
 	tctl &= ~E1000_TCTL_CT;
 	tctl |= E1000_TCTL_PSP | E1000_TCTL_RTLC |
@@ -1954,6 +1965,30 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 		srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
 	}
 
+	/* Attention!!!  For SR-IOV PF driver operations you must enable
+	 * queue drop for all VF and PF queues to prevent head of line blocking
+	 * if an un-trusted VF does not provide descriptors to hardware.
+	 */
+	if (adapter->vfs_allocated_count) {
+		u32 vmolr;
+
+		j = adapter->rx_ring[0].reg_idx;
+
+		/* set all queue drop enable bits */
+		wr32(E1000_QDE, ALL_QUEUES);
+		srrctl |= E1000_SRRCTL_DROP_EN;
+
+		/* disable queue 0 to prevent tail write w/o re-config */
+		wr32(E1000_RXDCTL(0), 0);
+
+		vmolr = rd32(E1000_VMOLR(j));
+		if (rctl & E1000_RCTL_LPE)
+			vmolr |= E1000_VMOLR_LPE;
+		if (adapter->num_rx_queues > 0)
+			vmolr |= E1000_VMOLR_RSSE;
+		wr32(E1000_VMOLR(j), vmolr);
+	}
+
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		j = adapter->rx_ring[i].reg_idx;
 		wr32(E1000_SRRCTL(j), srrctl);
@@ -1963,6 +1998,54 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 }
 
 /**
+ * igb_rlpml_set - set maximum receive packet size
+ * @adapter: board private structure
+ *
+ * Configure maximum receivable packet size.
+ **/
+static void igb_rlpml_set(struct igb_adapter *adapter)
+{
+	u32 max_frame_size = adapter->max_frame_size;
+	struct e1000_hw *hw = &adapter->hw;
+	u16 pf_id = adapter->vfs_allocated_count;
+
+	if (adapter->vlgrp)
+		max_frame_size += VLAN_TAG_SIZE;
+
+	/* if vfs are enabled we set RLPML to the largest possible request
+	 * size and set the VMOLR RLPML to the size we need */
+	if (pf_id) {
+		igb_set_vf_rlpml(adapter, max_frame_size, pf_id);
+		max_frame_size = MAX_STD_JUMBO_FRAME_SIZE + VLAN_TAG_SIZE;
+	}
+
+	wr32(E1000_RLPML, max_frame_size);
+}
+
+/**
+ * igb_configure_vt_default_pool - Configure VT default pool
+ * @adapter: board private structure
+ *
+ * Configure the default pool
+ **/
+static void igb_configure_vt_default_pool(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u16 pf_id = adapter->vfs_allocated_count;
+	u32 vtctl;
+
+	/* not in sr-iov mode - do nothing */
+	if (!pf_id)
+		return;
+
+	vtctl = rd32(E1000_VT_CTL);
+	vtctl &= ~(E1000_VT_CTL_DEFAULT_POOL_MASK |
+		   E1000_VT_CTL_DISABLE_DEF_POOL);
+	vtctl |= pf_id << E1000_VT_CTL_DEFAULT_POOL_SHIFT;
+	wr32(E1000_VT_CTL, vtctl);
+}
+
+/**
  * igb_configure_rx - Configure receive Unit after Reset
  * @adapter: board private structure
  *
@@ -2033,8 +2116,10 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 				writel(reta.dword,
 				       hw->hw_addr + E1000_RETA(0) + (j & ~3));
 		}
-
-		mrqc = E1000_MRQC_ENABLE_RSS_4Q;
+		if (adapter->vfs_allocated_count)
+			mrqc = E1000_MRQC_ENABLE_VMDQ_RSS_2Q;
+		else
+			mrqc = E1000_MRQC_ENABLE_RSS_4Q;
 
 		/* Fill out hash function seeds */
 		for (j = 0; j < 10; j++)
@@ -2059,6 +2144,9 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 		rxcsum |= E1000_RXCSUM_PCSD;
 		wr32(E1000_RXCSUM, rxcsum);
 	} else {
+		/* Enable multi-queue for sr-iov */
+		if (adapter->vfs_allocated_count)
+			wr32(E1000_MRQC, E1000_MRQC_ENABLE_VMDQ);
 		/* Enable Receive Checksum Offload for TCP and UDP */
 		rxcsum = rd32(E1000_RXCSUM);
 		if (adapter->rx_csum)
@@ -2069,11 +2157,10 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 		wr32(E1000_RXCSUM, rxcsum);
 	}
 
-	if (adapter->vlgrp)
-		wr32(E1000_RLPML,
-				adapter->max_frame_size + VLAN_TAG_SIZE);
-	else
-		wr32(E1000_RLPML, adapter->max_frame_size);
+	/* Set the default pool for the PF's first queue */
+	igb_configure_vt_default_pool(adapter);
+
+	igb_rlpml_set(adapter);
 
 	/* Enable Receives */
 	wr32(E1000_RCTL, rctl);
@@ -2303,6 +2390,8 @@ static int igb_set_mac(struct net_device *netdev, void *p)
 
 	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
 
+	igb_set_rah_pool(hw, adapter->vfs_allocated_count, 0);
+
 	return 0;
 }
 
@@ -2362,7 +2451,11 @@ static void igb_set_multi(struct net_device *netdev)
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
 		mc_ptr = mc_ptr->next;
 	}
-	igb_update_mc_addr_list(hw, mta_list, i, 1, mac->rar_entry_count);
+	igb_update_mc_addr_list(hw, mta_list, i,
+	                        adapter->vfs_allocated_count + 1,
+	                        mac->rar_entry_count);
+
+	igb_set_mc_list_pools(adapter, i, mac->rar_entry_count);
 	kfree(mta_list);
 }
 
@@ -3222,7 +3315,6 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
-#define MAX_STD_JUMBO_FRAME_SIZE 9234
 	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
 		dev_err(&adapter->pdev->dev, "MTU > 9216 not supported.\n");
 		return -EINVAL;
@@ -3256,6 +3348,12 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 #else
 		adapter->rx_buffer_len = PAGE_SIZE / 2;
 #endif
+
+	/* if sr-iov is enabled we need to force buffer size to 1K or larger */
+	if (adapter->vfs_allocated_count &&
+	    (adapter->rx_buffer_len < IGB_RXBUFFER_1024))
+		adapter->rx_buffer_len = IGB_RXBUFFER_1024;
+
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
 	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN) ||
 	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE))
@@ -4462,8 +4560,6 @@ static void igb_vlan_rx_register(struct net_device *netdev,
 		rctl &= ~E1000_RCTL_CFIEN;
 		wr32(E1000_RCTL, rctl);
 		igb_update_mng_vlan(adapter);
-		wr32(E1000_RLPML,
-				adapter->max_frame_size + VLAN_TAG_SIZE);
 	} else {
 		/* disable VLAN tag insert/strip */
 		ctrl = rd32(E1000_CTRL);
@@ -4474,10 +4570,10 @@ static void igb_vlan_rx_register(struct net_device *netdev,
 			igb_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 			adapter->mng_vlan_id = IGB_MNG_VLAN_NONE;
 		}
-		wr32(E1000_RLPML,
-				adapter->max_frame_size);
 	}
 
+	igb_rlpml_set(adapter);
+
 	if (!test_bit(__IGB_DOWN, &adapter->state))
 		igb_irq_enable(adapter);
 }
@@ -4841,4 +4937,52 @@ static void igb_io_resume(struct pci_dev *pdev)
 	igb_get_hw_control(adapter);
 }
 
+static inline void igb_set_vmolr(struct e1000_hw *hw, int vfn)
+{
+	u32 reg_data;
+
+	reg_data = rd32(E1000_VMOLR(vfn));
+	reg_data |= E1000_VMOLR_BAM |	 /* Accept broadcast */
+	            E1000_VMOLR_ROPE |   /* Accept packets matched in UTA */
+	            E1000_VMOLR_ROMPE |  /* Accept packets matched in MTA */
+	            E1000_VMOLR_AUPE |   /* Accept untagged packets */
+	            E1000_VMOLR_STRVLAN; /* Strip vlan tags */
+	wr32(E1000_VMOLR(vfn), reg_data);
+}
+
+static inline void igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
+                                    int vfn)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 vmolr;
+
+	vmolr = rd32(E1000_VMOLR(vfn));
+	vmolr &= ~E1000_VMOLR_RLPML_MASK;
+	vmolr |= size | E1000_VMOLR_LPE;
+	wr32(E1000_VMOLR(vfn), vmolr);
+}
+
+static inline void igb_set_rah_pool(struct e1000_hw *hw, int pool, int entry)
+{
+	u32 reg_data;
+
+	reg_data = rd32(E1000_RAH(entry));
+	reg_data &= ~E1000_RAH_POOL_MASK;
+	reg_data |= E1000_RAH_POOL_1 << pool;;
+	wr32(E1000_RAH(entry), reg_data);
+}
+
+static void igb_set_mc_list_pools(struct igb_adapter *adapter,
+				  int entry_count, u16 total_rar_filters)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int i = adapter->vfs_allocated_count + 1;
+
+	if ((i + entry_count) < total_rar_filters)
+		total_rar_filters = i + entry_count;
+
+	for (; i < total_rar_filters; i++)
+		igb_set_rah_pool(hw, adapter->vfs_allocated_count, i);
+}
+
 /* igb_main.c */

