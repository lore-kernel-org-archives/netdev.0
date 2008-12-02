From: Yu Zhao <yu.zhao@intel.com>
Subject: [SR-IOV driver example 1/3 resend] PF driver: hardware specific
	operations
Date: Tue, 2 Dec 2008 17:40:32 +0800
Message-ID: <20081202094032.GA1974@yzhao12-linux.sh.intel.com>
References: <20081121183605.GA7810@yzhao12-linux.sh.intel.com> <20081202092741.GA1859@yzhao12-linux.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "greg@kroah.com" <greg@kroah.com>,
	"matthew@wil.cx" <matthew@wil.cx>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Nakajima, Jun" <jun.nakajima@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34242 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750781AbYLBFgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 00:36:21 -0500
Content-Disposition: inline
In-Reply-To: <20081202092741.GA1859@yzhao12-linux.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the IGB driver allocate hardware resource (rx/tx queues)
for Virtual Functions. All operations in this patch are hardware specific.

From: Intel Corporation, LAN Access Division <e1000-devel@lists.sourceforge.net>
Signed-off-by: Yu Zhao <yu.zhao@intel.com>

---
 drivers/net/igb/Makefile        |    2 +-
 drivers/net/igb/e1000_82575.c   |    1 +
 drivers/net/igb/e1000_82575.h   |   61 +++++
 drivers/net/igb/e1000_defines.h |    7 +
 drivers/net/igb/e1000_hw.h      |    2 +
 drivers/net/igb/e1000_regs.h    |   13 +
 drivers/net/igb/igb.h           |    8 +
 drivers/net/igb/igb_main.c      |  567 +++++++++++++++++++++++++++++++++++++-
 drivers/pci/iov.c               |    6 +-
 9 files changed, 649 insertions(+), 18 deletions(-)

diff --git a/drivers/net/igb/Makefile b/drivers/net/igb/Makefile
index 1927b3f..ab3944c 100644
--- a/drivers/net/igb/Makefile
+++ b/drivers/net/igb/Makefile
@@ -33,5 +33,5 @@
 obj-$(CONFIG_IGB) += igb.o
 
 igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
-	    e1000_mac.o e1000_nvm.o e1000_phy.o
+	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_vf.o
 
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index f5e2e72..bb823ac 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -87,6 +87,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	case E1000_DEV_ID_82576:
 	case E1000_DEV_ID_82576_FIBER:
 	case E1000_DEV_ID_82576_SERDES:
+	case E1000_DEV_ID_82576_QUAD_COPPER:
 		mac->type = e1000_82576;
 		break;
 	default:
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index c1928b5..8c488ab 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -170,4 +170,65 @@ struct e1000_adv_tx_context_desc {
 #define E1000_DCA_TXCTRL_CPUID_SHIFT 24 /* Tx CPUID now in the last byte */
 #define E1000_DCA_RXCTRL_CPUID_SHIFT 24 /* Rx CPUID now in the last byte */
 
+#define MAX_NUM_VFS                   8
+
+#define E1000_DTXSWC_VMDQ_LOOPBACK_EN (1 << 31)  /* global VF LB enable */
+
+/* Easy defines for setting default pool, would normally be left a zero */
+#define E1000_VT_CTL_DEFAULT_POOL_SHIFT 7
+#define E1000_VT_CTL_DEFAULT_POOL_MASK  (0x7 << E1000_VT_CTL_DEFAULT_POOL_SHIFT)
+
+/* Other useful VMD_CTL register defines */
+#define E1000_VT_CTL_DISABLE_DEF_POOL   (1 << 29)
+#define E1000_VT_CTL_VM_REPL_EN         (1 << 30)
+
+/* Per VM Offload register setup */
+#define E1000_VMOLR_LPE        0x00010000 /* Accept Long packet */
+#define E1000_VMOLR_AUPE       0x01000000 /* Accept untagged packets */
+#define E1000_VMOLR_BAM        0x08000000 /* Accept Broadcast packets */
+#define E1000_VMOLR_MPME       0x10000000 /* Multicast promiscuous mode */
+#define E1000_VMOLR_STRVLAN    0x40000000 /* Vlan stripping enable */
+
+#define E1000_P2VMAILBOX_STS   0x00000001 /* Initiate message send to VF */
+#define E1000_P2VMAILBOX_ACK   0x00000002 /* Ack message recv'd from VF */
+#define E1000_P2VMAILBOX_VFU   0x00000004 /* VF owns the mailbox buffer */
+#define E1000_P2VMAILBOX_PFU   0x00000008 /* PF owns the mailbox buffer */
+
+#define E1000_VLVF_ARRAY_SIZE     32
+#define E1000_VLVF_VLANID_MASK    0x00000FFF
+#define E1000_VLVF_POOLSEL_SHIFT  12
+#define E1000_VLVF_POOLSEL_MASK   (0xFF << E1000_VLVF_POOLSEL_SHIFT)
+#define E1000_VLVF_VLANID_ENABLE  0x80000000
+
+#define E1000_VFMAILBOX_SIZE   16 /* 16 32 bit words - 64 bytes */
+
+/* If it's a E1000_VF_* msg then it originates in the VF and is sent to the
+ * PF.  The reverse is true if it is E1000_PF_*.
+ * Message ACK's are the value or'd with 0xF0000000
+ */
+#define E1000_VT_MSGTYPE_ACK      0xF0000000  /* Messages below or'd with
+                                               * this are the ACK */
+#define E1000_VT_MSGTYPE_NACK     0xFF000000  /* Messages below or'd with
+                                               * this are the NACK */
+#define E1000_VT_MSGINFO_SHIFT    16
+/* bits 23:16 are used for exra info for certain messages */
+#define E1000_VT_MSGINFO_MASK     (0xFF << E1000_VT_MSGINFO_SHIFT)
+
+#define E1000_VF_MSGTYPE_REQ_MAC  1 /* VF needs to know its MAC */
+#define E1000_VF_MSGTYPE_VFLR     2 /* VF notifies VFLR to PF */
+#define E1000_VF_SET_MULTICAST    3 /* VF requests PF to set MC addr */
+#define E1000_VF_SET_VLAN         4 /* VF requests PF to set VLAN */
+#define E1000_VF_SET_LPE          5 /* VF requests PF to set VMOLR.LPE */
+
+s32  e1000_send_mail_to_vf(struct e1000_hw *hw, u32 *msg,
+                           u32 vf_number, s16 size);
+s32  e1000_receive_mail_from_vf(struct e1000_hw *hw, u32 *msg,
+                                u32 vf_number, s16 size);
+void e1000_vmdq_loopback_enable_vf(struct e1000_hw *hw);
+void e1000_vmdq_loopback_disable_vf(struct e1000_hw *hw);
+void e1000_vmdq_replication_enable_vf(struct e1000_hw *hw, u32 enables);
+void e1000_vmdq_replication_disable_vf(struct e1000_hw *hw);
+bool e1000_check_for_pf_ack_vf(struct e1000_hw *hw);
+bool e1000_check_for_pf_mail_vf(struct e1000_hw *hw, u32*);
+
 #endif
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index ce70068..08f9db0 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -389,6 +389,7 @@
 #define E1000_ICR_RXDMT0        0x00000010 /* rx desc min. threshold (0) */
 #define E1000_ICR_RXO           0x00000040 /* rx overrun */
 #define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */
+#define E1000_ICR_VMMB          0x00000100 /* VM MB event */
 #define E1000_ICR_MDAC          0x00000200 /* MDIO access complete */
 #define E1000_ICR_RXCFG         0x00000400 /* Rx /c/ ordered set */
 #define E1000_ICR_GPI_EN0       0x00000800 /* GP Int 0 */
@@ -451,6 +452,7 @@
 /* Interrupt Mask Set */
 #define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
 #define E1000_IMS_LSC       E1000_ICR_LSC       /* Link Status Change */
+#define E1000_IMS_VMMB      E1000_ICR_VMMB      /* Mail box activity */
 #define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
 #define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
 #define E1000_IMS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
@@ -768,4 +770,9 @@
 #define E1000_GEN_CTL_ADDRESS_SHIFT     8
 #define E1000_GEN_POLL_TIMEOUT          640
 
+#define E1000_WRITE_FLUSH(a)	(readl((a)->hw_addr + E1000_STATUS))
+#define E1000_MRQC_ENABLE_MASK	0x00000007
+#define E1000_MRQC_ENABLE_VMDQ	0x00000003
+#define E1000_CTRL_EXT_PFRSTD	0x00004000
+
 #endif
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 99504a6..b57ecfd 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -41,6 +41,7 @@ struct e1000_hw;
 #define E1000_DEV_ID_82576                    0x10C9
 #define E1000_DEV_ID_82576_FIBER              0x10E6
 #define E1000_DEV_ID_82576_SERDES             0x10E7
+#define E1000_DEV_ID_82576_QUAD_COPPER        0x10E8
 #define E1000_DEV_ID_82575EB_COPPER           0x10A7
 #define E1000_DEV_ID_82575EB_FIBER_SERDES     0x10A9
 #define E1000_DEV_ID_82575GB_QUAD_COPPER      0x10D6
@@ -91,6 +92,7 @@ enum e1000_phy_type {
 	e1000_phy_gg82563,
 	e1000_phy_igp_3,
 	e1000_phy_ife,
+	e1000_phy_vf,
 };
 
 enum e1000_bus_type {
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 95523af..8a39bbc 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -262,6 +262,19 @@
 #define E1000_RETA(_i)  (0x05C00 + ((_i) * 4))
 #define E1000_RSSRK(_i) (0x05C80 + ((_i) * 4)) /* RSS Random Key - RW Array */
 
+/* VT Registers */
+#define E1000_MBVFICR   0x00C80 /* Mailbox VF Cause - RWC */
+#define E1000_MBVFIMR   0x00C84 /* Mailbox VF int Mask - RW */
+#define E1000_VFLRE     0x00C88 /* VF Register Events - RWC */
+#define E1000_VFRE      0x00C8C /* VF Receive Enables */
+#define E1000_VFTE      0x00C90 /* VF Transmit Enables */
+#define E1000_DTXSWC    0x03500 /* DMA Tx Switch Control - RW */
+/* These act per VF so an array friendly macro is used */
+#define E1000_P2VMAILBOX(_n)   (0x00C00 + (4 * (_n)))
+#define E1000_VMBMEM(_n)       (0x00800 + (64 * (_n)))
+#define E1000_VMOLR(_n)        (0x05AD0 + (4 * (_n)))
+#define E1000_VLVF(_n)         (0x05D00 + (4 * (_n))) /* VLAN Virtual Machine */
+
 #define wr32(reg, value) (writel(value, hw->hw_addr + reg))
 #define rd32(reg) (readl(hw->hw_addr + reg))
 #define wrfl() ((void)rd32(E1000_STATUS))
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 4ff6f05..47d474e 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -294,6 +294,14 @@ struct igb_adapter {
 	unsigned int lro_flushed;
 	unsigned int lro_no_desc;
 #endif
+	unsigned int vfs_allocated_count;
+	struct work_struct msg_task;
+	u32 vf_icr;
+	u32 vflre;
+	unsigned char vf_mac_addresses[8][6];
+	u8 vfta_tracking_entry[128];
+	int int0counter;
+	int int1counter;
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1cbae85..f0361ef 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -62,6 +62,7 @@ static struct pci_device_id igb_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_FIBER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_SERDES), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_QUAD_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_FIBER_SERDES), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575GB_QUAD_COPPER), board_82575 },
@@ -126,6 +127,17 @@ static void igb_vlan_rx_register(struct net_device *, struct vlan_group *);
 static void igb_vlan_rx_add_vid(struct net_device *, u16);
 static void igb_vlan_rx_kill_vid(struct net_device *, u16);
 static void igb_restore_vlan(struct igb_adapter *);
+static void igb_msg_task(struct work_struct *);
+int igb_send_msg_to_vf(struct igb_adapter *, u32 *, u32);
+static int igb_get_vf_msg_ack(struct igb_adapter *, u32);
+static int igb_rcv_msg_from_vf(struct igb_adapter *, u32);
+static int igb_set_pf_mac(struct net_device *, int, u8*);
+static void igb_enable_pf_queues(struct igb_adapter *adapter);
+static void igb_set_vf_vmolr(struct igb_adapter *adapter, int vfn);
+void igb_set_mc_list_pools(struct igb_adapter *, struct e1000_hw *, int, u16);
+static int igb_vmm_control(struct igb_adapter *, bool);
+static int igb_set_vf_mac(struct net_device *, int, u8*);
+static void igb_mbox_handler(struct igb_adapter *);
 
 static int igb_suspend(struct pci_dev *, pm_message_t);
 #ifdef CONFIG_PM
@@ -169,7 +181,7 @@ static struct pci_driver igb_driver = {
 	.resume   = igb_resume,
 #endif
 	.shutdown = igb_shutdown,
-	.err_handler = &igb_err_handler
+	.err_handler = &igb_err_handler,
 };
 
 static int global_quad_port_a; /* global quad port a indication */
@@ -292,6 +304,7 @@ static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 	u32 msixbm = 0;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ivar, index;
+	u32 rbase_offset = adapter->vfs_allocated_count;
 
 	switch (hw->mac.type) {
 	case e1000_82575:
@@ -316,9 +329,9 @@ static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 		   a vector number along with a "valid" bit.  Sadly, the layout
 		   of the table is somewhat counterintuitive. */
 		if (rx_queue > IGB_N0_QUEUE) {
-			index = (rx_queue & 0x7);
+			index = ((rx_queue + rbase_offset) & 0x7);
 			ivar = array_rd32(E1000_IVAR0, index);
-			if (rx_queue < 8) {
+			if ((rx_queue + rbase_offset) < 8) {
 				/* vector goes into low byte of register */
 				ivar = ivar & 0xFFFFFF00;
 				ivar |= msix_vector | E1000_IVAR_VALID;
@@ -331,9 +344,9 @@ static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 			array_wr32(E1000_IVAR0, index, ivar);
 		}
 		if (tx_queue > IGB_N0_QUEUE) {
-			index = (tx_queue & 0x7);
+			index = ((tx_queue + rbase_offset) & 0x7);
 			ivar = array_rd32(E1000_IVAR0, index);
-			if (tx_queue < 8) {
+			if ((tx_queue + rbase_offset) < 8) {
 				/* vector goes into second byte of register */
 				ivar = ivar & 0xFFFF00FF;
 				ivar |= (msix_vector | E1000_IVAR_VALID) << 8;
@@ -419,6 +432,8 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 	case e1000_82576:
 		tmp = (vector++ | E1000_IVAR_VALID) << 8;
 		wr32(E1000_IVAR_MISC, tmp);
+		if (adapter->vfs_allocated_count > 0)
+			wr32(E1000_MBVFIMR, 0xFF);
 
 		adapter->eims_enable_mask = (1 << (vector)) - 1;
 		adapter->eims_other = 1 << (vector - 1);
@@ -440,6 +455,7 @@ static int igb_request_msix(struct igb_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int i, err = 0, vector = 0;
+	u32 rbase_offset = adapter->vfs_allocated_count;
 
 	vector = 0;
 
@@ -451,7 +467,7 @@ static int igb_request_msix(struct igb_adapter *adapter)
 				  &(adapter->tx_ring[i]));
 		if (err)
 			goto out;
-		ring->itr_register = E1000_EITR(0) + (vector << 2);
+		ring->itr_register = E1000_EITR(0 + rbase_offset) + (vector << 2);
 		ring->itr_val = 976; /* ~4000 ints/sec */
 		vector++;
 	}
@@ -466,7 +482,7 @@ static int igb_request_msix(struct igb_adapter *adapter)
 				  &(adapter->rx_ring[i]));
 		if (err)
 			goto out;
-		ring->itr_register = E1000_EITR(0) + (vector << 2);
+		ring->itr_register = E1000_EITR(0 + rbase_offset) + (vector << 2);
 		ring->itr_val = adapter->itr;
 		/* overwrite the poll routine for MSIX, we've already done
 		 * netif_napi_add */
@@ -649,7 +665,11 @@ static void igb_irq_enable(struct igb_adapter *adapter)
 		wr32(E1000_EIAC, adapter->eims_enable_mask);
 		wr32(E1000_EIAM, adapter->eims_enable_mask);
 		wr32(E1000_EIMS, adapter->eims_enable_mask);
+#ifdef CONFIG_PCI_IOV
+		wr32(E1000_IMS, (E1000_IMS_LSC | E1000_IMS_VMMB));
+#else
 		wr32(E1000_IMS, E1000_IMS_LSC);
+#endif
 	} else {
 		wr32(E1000_IMS, IMS_ENABLE_MASK);
 		wr32(E1000_IAM, IMS_ENABLE_MASK);
@@ -773,6 +793,14 @@ int igb_up(struct igb_adapter *adapter)
 	if (adapter->msix_entries)
 		igb_configure_msix(adapter);
 
+	if (adapter->vfs_allocated_count > 0) {
+		igb_vmm_control(adapter, true);
+		igb_set_pf_mac(adapter->netdev,
+			       adapter->vfs_allocated_count,
+			       hw->mac.addr);
+		igb_enable_pf_queues(adapter);
+	}
+
 	/* Clear any pending interrupts. */
 	rd32(E1000_ICR);
 	igb_irq_enable(adapter);
@@ -1189,6 +1217,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	INIT_WORK(&adapter->reset_task, igb_reset_task);
 	INIT_WORK(&adapter->watchdog_task, igb_watchdog_task);
+	INIT_WORK(&adapter->msg_task, igb_msg_task);
 
 	/* Initialize link & ring properties that are user-changeable */
 	adapter->tx_ring->count = 256;
@@ -1404,8 +1433,13 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 
 	/* Number of supported queues. */
 	/* Having more queues than CPUs doesn't make sense. */
+#ifdef CONFIG_PCI_IOV
+	adapter->num_rx_queues = 1;
+	adapter->num_tx_queues = 1;
+#else
 	adapter->num_rx_queues = min((u32)IGB_MAX_RX_QUEUES, (u32)num_online_cpus());
 	adapter->num_tx_queues = min(IGB_MAX_TX_QUEUES, num_online_cpus());
+#endif
 
 	/* This call may decrease the number of queues depending on
 	 * interrupt mode. */
@@ -1469,6 +1503,14 @@ static int igb_open(struct net_device *netdev)
 	 * clean_rx handler before we do so.  */
 	igb_configure(adapter);
 
+	if (adapter->vfs_allocated_count > 0) {
+		igb_vmm_control(adapter, true);
+		igb_set_pf_mac(netdev,
+			       adapter->vfs_allocated_count,
+			       hw->mac.addr);
+		igb_enable_pf_queues(adapter);
+	}
+
 	err = igb_request_irq(adapter);
 	if (err)
 		goto err_req_irq;
@@ -1623,9 +1665,10 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 	u32 tctl;
 	u32 txdctl, txctrl;
 	int i;
+	u32 rbase_offset = adapter->vfs_allocated_count;
 
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		struct igb_ring *ring = &(adapter->tx_ring[i]);
+	for (i = rbase_offset; i < (adapter->num_tx_queues + rbase_offset); i++) {
+		struct igb_ring *ring = &(adapter->tx_ring[i - rbase_offset]);
 
 		wr32(E1000_TDLEN(i),
 				ring->count * sizeof(struct e1000_tx_desc));
@@ -1772,6 +1815,8 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	u32 rctl;
 	u32 srrctl = 0;
 	int i;
+	u32 rbase_offset = adapter->vfs_allocated_count;
+	u32 vmolr;
 
 	rctl = rd32(E1000_RCTL);
 
@@ -1794,6 +1839,7 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 		rctl &= ~E1000_RCTL_LPE;
 	else
 		rctl |= E1000_RCTL_LPE;
+#ifndef CONFIG_PCI_IOV
 	if (adapter->rx_buffer_len <= IGB_RXBUFFER_2048) {
 		/* Setup buffer sizes */
 		rctl &= ~E1000_RCTL_SZ_4096;
@@ -1818,9 +1864,12 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 			break;
 		}
 	} else {
+#endif
 		rctl &= ~E1000_RCTL_BSEX;
 		srrctl = adapter->rx_buffer_len >> E1000_SRRCTL_BSIZEPKT_SHIFT;
+#ifndef CONFIG_PCI_IOV
 	}
+#endif
 
 	/* 82575 and greater support packet-split where the protocol
 	 * header is placed in skb->data and the packet data is
@@ -1836,13 +1885,32 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 		srrctl |= adapter->rx_ps_hdr_size <<
 			 E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
 		srrctl |= E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
+#ifdef CONFIG_PCI_IOV
+		srrctl |= 0x80000000;
+#endif
 	} else {
 		adapter->rx_ps_hdr_size = 0;
 		srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
 	}
 
-	for (i = 0; i < adapter->num_rx_queues; i++)
+	for (i = rbase_offset; i < (adapter->num_rx_queues + rbase_offset); i++) {
 		wr32(E1000_SRRCTL(i), srrctl);
+		if ((rctl & E1000_RCTL_LPE) && adapter->vfs_allocated_count > 0 ) {
+			vmolr = rd32(E1000_VMOLR(i));
+			vmolr |= E1000_VMOLR_LPE;
+			wr32(E1000_VMOLR(i), vmolr);
+		}
+	}
+
+	/* Attention!!!  For SR-IOV PF driver operations you must enable
+	 * queue drop for the queue 0 or the PF driver will *never* receive
+	 * any traffic on it's own default queue, which will be equal to the
+	 * number of VFs enabled.
+	 */
+	if (adapter->vfs_allocated_count > 0) {
+		srrctl = rd32(E1000_SRRCTL(0));
+		wr32(E1000_SRRCTL(0), (srrctl | 0x80000000));
+	}
 
 	wr32(E1000_RCTL, rctl);
 }
@@ -1860,6 +1928,7 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 	u32 rctl, rxcsum;
 	u32 rxdctl;
 	int i;
+	u32 rbase_offset = adapter->vfs_allocated_count;
 
 	/* disable receives while setting up the descriptors */
 	rctl = rd32(E1000_RCTL);
@@ -1872,8 +1941,8 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct igb_ring *ring = &(adapter->rx_ring[i]);
+	for (i = rbase_offset; i < (adapter->num_rx_queues + rbase_offset); i++) {
+		struct igb_ring *ring = &(adapter->rx_ring[i - rbase_offset]);
 		rdba = ring->dma;
 		wr32(E1000_RDBAL(i),
 				rdba & 0x00000000ffffffffULL);
@@ -2268,8 +2337,20 @@ static void igb_set_multi(struct net_device *netdev)
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
 		mc_ptr = mc_ptr->next;
 	}
-	igb_update_mc_addr_list_82575(hw, mta_list, i, 1,
-	                              mac->rar_entry_count);
+	if (adapter->vfs_allocated_count > 0) {
+		igb_update_mc_addr_list_82575(hw, mta_list, i,
+					  adapter->vfs_allocated_count + 1,
+					  mac->rar_entry_count);
+		igb_set_mc_list_pools(adapter, hw, i, mac->rar_entry_count);
+	/* TODO - if this is done after VF's are loaded and have their MC
+	 * addresses set then we need to restore their entries in the MTA.
+	 * This means we have to save them in the adapter structure somewhere
+	 * so that we can retrieve them when this particular event occurs
+	 */
+	} else
+		igb_update_mc_addr_list_82575(hw, mta_list, i, 1,
+					  mac->rar_entry_count);
+
 	kfree(mta_list);
 }
 
@@ -3274,6 +3355,22 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 icr = rd32(E1000_ICR);
 
+#ifdef CONFIG_PCI_IOV
+	adapter->int0counter++;
+
+	/* Check for a mailbox event */
+	if (icr & E1000_ICR_VMMB) {
+		adapter->vf_icr = rd32(E1000_MBVFICR);
+		/* Clear the bits */
+		wr32(E1000_MBVFICR, adapter->vf_icr);
+		E1000_WRITE_FLUSH(hw);
+		adapter->vflre = rd32(E1000_VFLRE);
+		wr32(E1000_VFLRE, adapter->vflre);
+		E1000_WRITE_FLUSH(hw);
+		igb_mbox_handler(adapter);
+	}
+#endif
+
 	/* reading ICR causes bit 31 of EICR to be cleared */
 	if (!(icr & E1000_ICR_LSC))
 		goto no_link_interrupt;
@@ -3283,7 +3380,10 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 		mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	
 no_link_interrupt:
-	wr32(E1000_IMS, E1000_IMS_LSC);
+	if (adapter->vfs_allocated_count)
+		wr32(E1000_IMS, E1000_IMS_LSC | E1000_IMS_VMMB);
+	else
+		wr32(E1000_IMS, E1000_IMS_LSC);
 	wr32(E1000_EIMS, adapter->eims_other);
 
 	return IRQ_HANDLED;
@@ -3342,6 +3442,10 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 	 * previous interrupt.
 	 */
 
+#ifdef CONFIG_PCI_IOV
+	adapter->int1counter++;
+#endif
+
 	igb_write_itr(rx_ring);
 
 	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
@@ -4192,6 +4296,9 @@ static void igb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	vfta = array_rd32(E1000_VFTA, index);
 	vfta |= (1 << (vid & 0x1F));
 	igb_write_vfta(&adapter->hw, index, vfta);
+#ifdef CONFIG_PCI_IOV
+	adapter->vfta_tracking_entry[index] = (u8)vfta;
+#endif
 }
 
 static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -4219,6 +4326,9 @@ static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	vfta = array_rd32(E1000_VFTA, index);
 	vfta &= ~(1 << (vid & 0x1F));
 	igb_write_vfta(&adapter->hw, index, vfta);
+#ifdef CONFIG_PCI_IOV
+	adapter->vfta_tracking_entry[index] = (u8)vfta;
+#endif
 }
 
 static void igb_restore_vlan(struct igb_adapter *adapter)
@@ -4529,4 +4639,431 @@ static void igb_io_resume(struct pci_dev *pdev)
 
 }
 
+static void igb_set_vf_multicasts(struct igb_adapter *adapter,
+				  u32 *msgbuf, u32 vf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int n = (msgbuf[0] & E1000_VT_MSGINFO_MASK) >> E1000_VT_MSGINFO_SHIFT;
+	int i;
+	u32 hash_value;
+	u8 *p = (u8 *)&msgbuf[1];
+
+	/* VFs are limited to using the MTA hash table for their multicast
+	 * addresses */
+	for (i = 0; i < n; i++) {
+		hash_value = igb_hash_mc_addr(hw, p);
+		printk("Adding MC Addr: %2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X\n"
+		       "for VF %d\n",
+		       p[0],
+		       p[1],
+		       p[2],
+		       p[3],
+		       p[4],
+		       p[5],
+		       vf);
+		printk("Hash value = 0x%03X\n", hash_value);
+		igb_mta_set(hw, hash_value);
+		p += ETH_ALEN;
+	}
+}
+
+static void igb_set_vf_vlan(struct igb_adapter *adapter,
+			    u32 *msgbuf, u32 vf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int add = (msgbuf[0] & E1000_VT_MSGINFO_MASK) >> E1000_VT_MSGINFO_SHIFT;
+	int vid = (msgbuf[1] & E1000_VLVF_VLANID_MASK);
+	u32 reg, index, vfta;
+	int i;
+
+	if (add) {
+		/* See if a vlan filter for this id is already
+		 * set and enabled */
+		for(i = 0; i < E1000_VLVF_ARRAY_SIZE; i++) {
+			reg = rd32(E1000_VLVF(i));
+			if ((reg & E1000_VLVF_VLANID_ENABLE) &&
+			    vid == (reg & E1000_VLVF_VLANID_MASK))
+				break;
+		}
+		if (i < E1000_VLVF_ARRAY_SIZE) {
+			/* Found an enabled entry with the same VLAN
+			 * ID.  Just enable the pool select bit for
+			 * this requesting VF
+			 */
+			reg |= 1 << (E1000_VLVF_POOLSEL_SHIFT + vf);
+			wr32(E1000_VLVF(i), reg);
+			msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
+		} else {
+			/* Did not find a matching VLAN ID filter entry
+			 * that was also enabled.  Search for a free
+			 * filter entry, i.e. one without the enable
+			 * bit set
+			 */
+			for(i = 0; i < E1000_VLVF_ARRAY_SIZE; i++) {
+				reg = rd32(E1000_VLVF(i));
+				if (!(reg & E1000_VLVF_VLANID_ENABLE))
+					break;
+			}
+			if (i == E1000_VLVF_ARRAY_SIZE) {
+				/* oops, no free entry, send nack */
+				msgbuf[0] |= E1000_VT_MSGTYPE_NACK;
+			} else {
+				/* add VID to filter table */
+				index = (vid >> 5) & 0x7F;
+				vfta = array_rd32(E1000_VFTA, index);
+				vfta |= (1 << (vid & 0x1F));
+				igb_write_vfta(hw, index, vfta);
+				reg |= vid;
+				reg |= 1 << (E1000_VLVF_POOLSEL_SHIFT + vf);
+				reg |= E1000_VLVF_VLANID_ENABLE;
+				wr32(E1000_VLVF(i), reg);
+				msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
+			}
+		}
+	} else {
+		/* Find the vlan filter for this id */
+		for(i = 0; i < E1000_VLVF_ARRAY_SIZE; i++) {
+			reg = rd32(E1000_VLVF(i));
+			if ((reg & E1000_VLVF_VLANID_ENABLE) &&
+			    vid == (reg & E1000_VLVF_VLANID_MASK))
+				break;
+		}
+		if (i == E1000_VLVF_ARRAY_SIZE) {
+			/* oops, not found. send nack */
+			msgbuf[0] |= E1000_VT_MSGTYPE_NACK;
+		} else {
+			u32 pool_sel;
+			/* Check to see if the entry belongs to more than one
+			 * pool.  If so just reset this VF's pool select bit
+			 */
+			/* mask off the pool select bits */
+			pool_sel = (reg & E1000_VLVF_POOLSEL_MASK) >>
+				E1000_VLVF_POOLSEL_SHIFT;
+			/* reset this VF's pool select bit */
+			pool_sel &= ~(1 << vf);
+			/* check if other pools are set */
+			if (pool_sel != 0) {
+				reg &= ~(E1000_VLVF_POOLSEL_MASK);
+				reg |= pool_sel;
+			} else {
+				/* just disable the whole entry */
+				reg = 0;
+				/* remove VID from filter table *IF AND
+				 * ONLY IF!!!* this entry was enabled for
+				 * VFs only through a write to the VFTA
+				 * table a few lines above here in this
+				 * function.  If this VFTA entry was added
+				 * through the rx_add_vid function then
+				 * we can't delete it here. */
+				index = (vid >> 5) & 0x7F;
+				if (adapter->vfta_tracking_entry[index] == 0) {
+					vfta = array_rd32(E1000_VFTA, index);
+					vfta &= ~(1 << (vid & 0x1F));
+					igb_write_vfta(hw, index, vfta);
+				}
+			}
+			wr32(E1000_VLVF(i), reg);
+			msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
+		}
+	}
+}
+
+static void igb_msg_task(struct work_struct *work)
+{
+	struct igb_adapter *adapter;
+	struct e1000_hw *hw;
+	u32 bit, vf, vfr;
+	u32 vflre;
+	u32 vf_icr;
+
+	adapter = container_of(work, struct igb_adapter, msg_task);
+	hw = &adapter->hw;
+
+	vflre = adapter->vflre;
+	vf_icr = adapter->vf_icr;
+
+	/* Now that we have salted away local values of these events
+	 * for processing we can enable the interrupt so more events
+	 * can be captured
+	 */
+
+	wr32(E1000_IMS, E1000_IMS_VMMB);
+
+	if (vflre & 0xFF) {
+		printk("VFLR Event %2.2X\n", vflre);
+		vfr = rd32(E1000_VFRE);
+		wr32(E1000_VFRE, vfr | vflre);
+		E1000_WRITE_FLUSH(hw);
+		vfr = rd32(E1000_VFTE);
+		wr32(E1000_VFTE, vfr | vflre);
+		E1000_WRITE_FLUSH(hw);
+	}
+
+	if (!vf_icr)
+		return;
+
+	/* Check for message acks from VF first as that may affect
+	 * pending messages to the VF
+	 */
+	for (bit = 1, vf = 0; bit < 0x100; bit <<= 1, vf++) {
+		if ((bit << 16) & vf_icr)
+			igb_get_vf_msg_ack(adapter, vf);
+	}
+
+	/* Check for message sent from a VF */
+	for (bit = 1, vf = 0; bit < 0x100; bit <<= 1, vf++) {
+		if (bit & vf_icr)
+			igb_rcv_msg_from_vf(adapter, vf);
+	}
+}
+
+int igb_send_msg_to_vf(struct igb_adapter *adapter, u32 *msg, u32 vfn)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	return e1000_send_mail_to_vf(hw, msg, vfn, 16);
+}
+
+static int igb_get_vf_msg_ack(struct igb_adapter *adapter, u32 vf)
+{
+	return 0;
+}
+
+static int igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
+{
+	u32 msgbuf[E1000_VFMAILBOX_SIZE];
+	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
+	u32 reg;
+	s32 retval;
+	int err = 0;
+
+	retval = e1000_receive_mail_from_vf(hw, msgbuf, vf, 16);
+
+	switch ((msgbuf[0] & 0xFFFF)) {
+	case E1000_VF_MSGTYPE_REQ_MAC:
+		{
+			unsigned char *p;
+			msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
+			p = (char *)&msgbuf[1];
+			memcpy(p, adapter->vf_mac_addresses[vf], ETH_ALEN);
+			if ((err = igb_send_msg_to_vf(adapter, msgbuf, vf)
+			     == 0)) {
+				printk(KERN_INFO "Sending MAC Address %2.2x:%2.2x:"
+				       "%2.2x:%2.2x:%2.2x:%2.2x to VF %d\n",
+				       p[0], p[1], p[2], p[3], p[4], p[5], vf);
+				igb_set_vf_mac(netdev,
+					       vf,
+					       adapter->vf_mac_addresses[vf]);
+				igb_set_vf_vmolr(adapter, vf);
+			}
+			else {
+				printk(KERN_ERR "Error %d Sending MAC Address to VF\n",
+				       err);
+			}
+		}
+		break;
+	case E1000_VF_MSGTYPE_VFLR:
+		{
+			u32 vfe = rd32(E1000_VFTE);
+			vfe |= (1 << vf);
+			wr32(E1000_VFTE, vfe);
+			vfe = rd32(E1000_VFRE);
+			vfe |= (1 << vf);
+			wr32(E1000_VFRE, vfe);
+			printk(KERN_INFO "Enabling VFTE and VFRE for vf %d\n",
+			       vf);
+			msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
+			if ((err = igb_send_msg_to_vf(adapter, msgbuf, vf)
+			     != 0))
+				printk(KERN_ERR "Error %d Sending VFLR Ack"
+				       "to VF\n", err);
+		}
+		break;
+	case E1000_VF_SET_MULTICAST:
+		igb_set_vf_multicasts(adapter, msgbuf, vf);
+		break;
+	case E1000_VF_SET_LPE:
+		/* Make sure global LPE is set */
+		reg = rd32(E1000_RCTL);
+		reg |= E1000_RCTL_LPE;
+		wr32(E1000_RCTL, reg);
+		/* Set per VM LPE */
+		reg = rd32(E1000_VMOLR(vf));
+		reg |= E1000_VMOLR_LPE;
+		wr32(E1000_VMOLR(vf), reg);
+		msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
+		if ((err = igb_send_msg_to_vf(adapter, msgbuf, vf) != 0))
+			printk(KERN_ERR "Error %d Sending set VMOLR LPE Ack"
+			       "to VF\n", err);
+		break;
+	case E1000_VF_SET_VLAN:
+		igb_set_vf_vlan(adapter, msgbuf, vf);
+		if ((err = igb_send_msg_to_vf(adapter, msgbuf, vf) != 0))
+			printk(KERN_ERR "Error %d Sending set VLAN ID Ack"
+			       "to VF\n", err);
+		break;
+	default:
+		if ((msgbuf[0] & 0xFF000000) != E1000_VT_MSGTYPE_ACK &&
+		    (msgbuf[0] & 0xFF000000) != E1000_VT_MSGTYPE_NACK)
+			printk(KERN_ERR "Unhandled Msg %8.8x\n", msgbuf[0]);
+		break;
+	}
+
+	return retval;
+}
+
+static void igb_mbox_handler(struct igb_adapter *adapter)
+{
+	schedule_work(&adapter->msg_task);
+}
+
+#define E1000_RAH(_i)	(((_i) <= 15) ? (0x05404 + ((_i) * 8)) : (0x054E4 + ((_i - 16) * 8)))
+
+static int igb_set_pf_mac(struct net_device *netdev, int queue, u8*mac_addr)
+{
+	struct igb_adapter *adapter;
+	struct e1000_hw *hw;
+	u32 reg_data;
+
+	adapter = netdev_priv(netdev);
+	hw = &adapter->hw;
+
+	/* point the pool selector for our default MAC entry to
+	 * the right pool, which is equal to the number of vfs enabled.
+	 */
+	reg_data = rd32(E1000_RAH(0));
+	reg_data |= (1 << (18 + queue));
+	wr32(E1000_RAH(0), reg_data);
+
+	return 0;
+}
+
+static void igb_set_vf_vmolr(struct igb_adapter *adapter, int vfn)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 reg_data;
+
+	reg_data = rd32(E1000_VMOLR(vfn));
+	reg_data |= 0xF << 24; /* aupe, rompe, rope, bam */
+	reg_data |= E1000_VMOLR_STRVLAN; /* Strip vlan tags */
+	wr32(E1000_VMOLR(vfn), reg_data);
+}
+
+static int igb_set_vf_mac(struct net_device *netdev,
+						 int vf,
+						 unsigned char *mac_addr)
+{
+	struct igb_adapter *adapter;
+	struct e1000_hw *hw;
+	u32 reg_data;
+	int rar_entry = vf + 1; /* VF MAC addresses start at entry 1 */
+
+	adapter = netdev_priv(netdev);
+	hw = &adapter->hw;
+
+	igb_rar_set(hw, mac_addr, rar_entry);
+
+	memcpy(adapter->vf_mac_addresses[vf], mac_addr, 6);
+
+	reg_data = rd32(E1000_RAH(rar_entry));
+	reg_data |= (1 << (18 + vf));
+	wr32(E1000_RAH(rar_entry), reg_data);
+
+	return 0;
+}
+
+static int igb_vmm_control(struct igb_adapter *adapter, bool enable)
+{
+	struct e1000_hw *hw;
+	u32 reg_data;
+
+	hw = &adapter->hw;
+
+	if (enable) {
+		/* Enable multi-queue */
+		reg_data = rd32(E1000_MRQC);
+		reg_data &= E1000_MRQC_ENABLE_MASK;
+		reg_data |= E1000_MRQC_ENABLE_VMDQ;
+		wr32(E1000_MRQC, reg_data);
+		/* VF's need PF reset indication before they
+		 * can send/receive mail */
+		reg_data = rd32(E1000_CTRL_EXT);
+		reg_data |= E1000_CTRL_EXT_PFRSTD;
+		wr32(E1000_CTRL_EXT, reg_data);
+
+		/* Set the default pool for the PF's first queue */
+		reg_data = rd32(E1000_VMD_CTL);
+		reg_data &= ~(E1000_VMD_CTL | E1000_VT_CTL_DISABLE_DEF_POOL);
+		reg_data |= adapter->vfs_allocated_count <<
+			E1000_VT_CTL_DEFAULT_POOL_SHIFT;
+		wr32(E1000_VMD_CTL, reg_data);
+
+		e1000_vmdq_loopback_enable_vf(hw);
+		e1000_vmdq_replication_enable_vf(hw, 0xFF);
+	} else {
+		e1000_vmdq_loopback_disable_vf(hw);
+		e1000_vmdq_replication_disable_vf(hw);
+	}
+
+	return 0;
+}
+
+static void igb_enable_pf_queues(struct igb_adapter *adapter)
+{
+	u64 rdba;
+	int i;
+	u32 rbase_offset = adapter->vfs_allocated_count;
+	struct e1000_hw *hw = &adapter->hw;
+	u32 rxdctl;
+
+	for (i = rbase_offset;
+	     i < (adapter->num_rx_queues + rbase_offset); i++) {
+		struct igb_ring *ring = &adapter->rx_ring[i - rbase_offset];
+		rdba = ring->dma;
+
+		rxdctl = rd32(E1000_RXDCTL(i));
+		rxdctl |= E1000_RXDCTL_QUEUE_ENABLE;
+		rxdctl &= 0xFFF00000;
+		rxdctl |= IGB_RX_PTHRESH;
+		rxdctl |= IGB_RX_HTHRESH << 8;
+		rxdctl |= IGB_RX_WTHRESH << 16;
+		wr32(E1000_RXDCTL(i), rxdctl);
+		printk("RXDCTL%d == %8.8x\n", i, rxdctl);
+
+		wr32(E1000_RDBAL(i),
+		                rdba & 0x00000000ffffffffULL);
+		wr32(E1000_RDBAH(i), rdba >> 32);
+		wr32(E1000_RDLEN(i),
+		               ring->count * sizeof(union e1000_adv_rx_desc));
+
+		writel(ring->next_to_use, adapter->hw.hw_addr + ring->tail);
+		writel(ring->next_to_clean, adapter->hw.hw_addr + ring->head);
+	}
+}
+
+void igb_set_mc_list_pools(struct igb_adapter *adapter,
+			   struct e1000_hw *hw,
+			   int entry_count, u16 total_rar_filters)
+{
+	u32 reg_data;
+	int i;
+	int pool = adapter->vfs_allocated_count;
+
+	for (i = adapter->vfs_allocated_count + 1; i < total_rar_filters; i++) {
+		reg_data = rd32(E1000_RAH(i));
+		reg_data |= (1 << (18 + pool));
+		wr32(E1000_RAH(i), reg_data);
+		entry_count--;
+		if (!entry_count)
+			break;
+	}
+
+	reg_data = rd32(E1000_VMOLR(pool));
+	/* Set bit 25 for this pool in the VM Offload register so that
+	 * it can accept packets that match the MTA table */
+	reg_data |= (1 << 25);
+	wr32(E1000_VMOLR(pool), reg_data);
+}
+
 /* igb_main.c */
diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index b4c1b5a..79b49e5 100644
--- a/drivers/pci/iov.c
+++ b/drivers/pci/iov.c
@@ -487,9 +487,11 @@ void pci_iov_unregister(struct pci_dev *dev)
 
 	sysfs_remove_group(&dev->dev.kobj, &iov_attr_group);
 
-	mutex_lock(&pdev->iov->physfn->iov->lock);
+	mutex_lock(&dev->iov->physfn->iov->lock);
+
 	iov_disable(dev);
-	mutex_unlock(&pdev->iov->physfn->iov->lock);
+
+	mutex_unlock(&dev->iov->physfn->iov->lock);
 
 	kobject_uevent(&dev->dev.kobj, KOBJ_CHANGE);
 }
-- 
1.5.6.4

