From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] 2.6.26 net driver updates
Date: Wed, 26 Mar 2008 01:32:43 -0400
Message-ID: <20080326053243.GA29480@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:56823 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297AbYCZFcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 01:32:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'upstream-net26' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-net26

to receive the following updates:

 drivers/net/8139too.c             |   10 +-
 drivers/net/Kconfig               |    7 +
 drivers/net/Makefile              |    1 +
 drivers/net/atp.c                 |    4 +-
 drivers/net/cxgb3/cxgb3_offload.c |   22 +-
 drivers/net/defxx.c               |    3 +-
 drivers/net/e1000/e1000.h         |   27 +-
 drivers/net/e1000/e1000_ethtool.c |   17 +-
 drivers/net/e1000/e1000_hw.c      |  223 ++++----
 drivers/net/e1000/e1000_hw.h      |   62 +-
 drivers/net/e1000/e1000_main.c    |  131 ++---
 drivers/net/e1000/e1000_osdep.h   |    7 -
 drivers/net/e1000e/e1000.h        |    4 -
 drivers/net/e1000e/lib.c          |   56 --
 drivers/net/e1000e/netdev.c       |   37 +-
 drivers/net/forcedeth.c           |    6 +-
 drivers/net/gianfar.c             |   24 +-
 drivers/net/gianfar.h             |    9 +-
 drivers/net/ibmveth.c             |   42 +--
 drivers/net/ixgb/ixgb.h           |   28 +-
 drivers/net/ixgb/ixgb_ee.c        |   50 +-
 drivers/net/ixgb/ixgb_ee.h        |    2 +-
 drivers/net/ixgb/ixgb_ethtool.c   |   17 +-
 drivers/net/ixgb/ixgb_hw.c        |   57 +-
 drivers/net/ixgb/ixgb_hw.h        |   18 +-
 drivers/net/ixgb/ixgb_main.c      |   96 ++--
 drivers/net/ixgb/ixgb_osdep.h     |    7 -
 drivers/net/korina.c              | 1233 +++++++++++++++++++++++++++++++++++++
 drivers/net/mv643xx_eth.c         |    2 +-
 drivers/net/natsemi.c             |   10 +-
 drivers/net/ni52.c                |  255 ++++----
 drivers/net/ni52.h                |    4 +-
 drivers/net/phy/broadcom.c        |   57 ++-
 drivers/net/qla3xxx.c             |    6 +-
 drivers/net/s2io.c                |   17 +-
 drivers/net/skfp/fplustm.c        |   12 +-
 drivers/net/skfp/h/fplustm.h      |   20 +-
 drivers/net/skfp/hwmtm.c          |   86 ++--
 drivers/net/skfp/skfddi.c         |    4 +-
 drivers/net/usb/dm9601.c          |   10 +-
 drivers/net/usb/rndis_host.c      |    5 +-
 41 files changed, 1948 insertions(+), 740 deletions(-)
 create mode 100644 drivers/net/korina.c

Al Viro (13):
      ni52 trivial iomem annotations
      ni52: unbreak scp_struct
      ni52: kill the second argument of check586(), get rid of bogus pointer
      ni52: make ->base char __iomem *
      ni52: clean up initialization of priv
      ni52: clean up check586()
      ni52: switch to ioremap()
      ni52: more unbreaking
      misc drivers/net annotations
      skfp annotations
      annotate cxgb3 (ab)uses of skb->priority/skb->csum
      endianness annotations: rndis
      s2io annotations

Andy Fleming (2):
      gianfar: Only process completed frames
      gianfar: Fix Rx/Tx HW interrupt coalescing counter reset procedure.

Anton Vorontsov (1):
      phy/broadcom: add support for BCM5481 PHY

Auke Kok (2):
      ixgb: move externs out of .c files
      e1000e: remove no longer used e1000e_read_nvm_spi

Dai Haruki (2):
      gianfar: Fix the data buffer stashing amount
      gianfar: Fix frame size calculation when hardware VLAN acceleration is on

Daniel Drake (1):
      forcedeth: Use round_jiffies for stats timer

Florian Fainelli (1):
      Add support the Korina (IDT RC32434) Ethernet MAC

Jesse Brandeburg (4):
      ixgb: add explicit state checking
      e1000e: remove irq_sem
      e1000: remove irq_sem
      ixgb: remove irq_sem

Joe Perches (2):
      e1000: Convert boolean_t to bool
      ixgb: convert boolean_t to bool

Julia Lawall (1):
      drivers/net/mv643xx_eth.c: Use FIELD_SIZEOF

Marcin Slusarz (1):
      qla3xxx: convert byte order of constant instead of variable

Pavel Emelyanov (1):
      Use single_open instead of manual manipulations.

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index be6e918..53bd903 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -966,8 +966,8 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 
 	addr_len = read_eeprom (ioaddr, 0, 8) == 0x8129 ? 8 : 6;
 	for (i = 0; i < 3; i++)
-		((u16 *) (dev->dev_addr))[i] =
-		    le16_to_cpu (read_eeprom (ioaddr, i + 7, addr_len));
+		((__le16 *) (dev->dev_addr))[i] =
+		    cpu_to_le16(read_eeprom (ioaddr, i + 7, addr_len));
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	/* The Rtl8139-specific entries in the device structure. */
@@ -1373,8 +1373,8 @@ static void rtl8139_hw_start (struct net_device *dev)
 	/* unlock Config[01234] and BMCR register writes */
 	RTL_W8_F (Cfg9346, Cfg9346_Unlock);
 	/* Restore our idea of the MAC address. */
-	RTL_W32_F (MAC0 + 0, cpu_to_le32 (*(u32 *) (dev->dev_addr + 0)));
-	RTL_W32_F (MAC0 + 4, cpu_to_le32 (*(u32 *) (dev->dev_addr + 4)));
+	RTL_W32_F (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
+	RTL_W32_F (MAC0 + 4, le16_to_cpu (*(__le16 *) (dev->dev_addr + 4)));
 
 	/* Must enable Tx/Rx before setting transfer thresholds! */
 	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
@@ -1945,7 +1945,7 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		rmb();
 
 		/* read size+status of next frame from DMA ring buffer */
-		rx_status = le32_to_cpu (*(u32 *) (rx_ring + ring_offset));
+		rx_status = le32_to_cpu (*(__le32 *) (rx_ring + ring_offset));
 		rx_size = rx_status >> 16;
 		pkt_size = rx_size - 4;
 
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 978e72a..95d1b61 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -467,6 +467,13 @@ config SNI_82596
 	  Say Y here to support the on-board Intel 82596 ethernet controller
 	  built into SNI RM machines.
 
+config KORINA
+	tristate "Korina (IDT RC32434) Ethernet support"
+	depends on NET_ETHERNET && MIKROTIK_RB500
+	help
+	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
+	  based system say Y. Otherwise say N.
+
 config MIPS_JAZZ_SONIC
 	tristate "MIPS JAZZ onboard SONIC Ethernet support"
 	depends on MACH_JAZZ
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 960999c..4d71729 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -190,6 +190,7 @@ obj-$(CONFIG_ZORRO8390) += zorro8390.o
 obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
 obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
 obj-$(CONFIG_EQUALIZER) += eql.o
+obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 62f09e5..3d44333 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -378,8 +378,8 @@ static void __init get_node_ID(struct net_device *dev)
 		sa_offset = 15;
 
 	for (i = 0; i < 3; i++)
-		((u16 *)dev->dev_addr)[i] =
-			be16_to_cpu(eeprom_op(ioaddr, EE_READ(sa_offset + i)));
+		((__be16 *)dev->dev_addr)[i] =
+			cpu_to_be16(eeprom_op(ioaddr, EE_READ(sa_offset + i)));
 
 	write_reg(ioaddr, CMR2, CMR2_NULL);
 }
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 901c824..ff9c013 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -833,10 +833,26 @@ static int do_trace(struct t3cdev *dev, struct sk_buff *skb)
 	return 0;
 }
 
+/*
+ * That skb would better have come from process_responses() where we abuse
+ * ->priority and ->csum to carry our data.  NB: if we get to per-arch
+ * ->csum, the things might get really interesting here.
+ */
+
+static inline u32 get_hwtid(struct sk_buff *skb)
+{
+	return ntohl((__force __be32)skb->priority) >> 8 & 0xfffff;
+}
+
+static inline u32 get_opcode(struct sk_buff *skb)
+{
+	return G_OPCODE(ntohl((__force __be32)skb->csum));
+}
+
 static int do_term(struct t3cdev *dev, struct sk_buff *skb)
 {
-	unsigned int hwtid = ntohl(skb->priority) >> 8 & 0xfffff;
-	unsigned int opcode = G_OPCODE(ntohl(skb->csum));
+	unsigned int hwtid = get_hwtid(skb);
+	unsigned int opcode = get_opcode(skb);
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_tid(&(T3C_DATA(dev))->tid_maps, hwtid);
@@ -914,7 +930,7 @@ int process_rx(struct t3cdev *dev, struct sk_buff **skbs, int n)
 {
 	while (n--) {
 		struct sk_buff *skb = *skbs++;
-		unsigned int opcode = G_OPCODE(ntohl(skb->csum));
+		unsigned int opcode = get_opcode(skb);
 		int ret = cpl_handlers[opcode] (dev, skb);
 
 #if VALIDATE_TID
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index ddc30c4..c062aac 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -971,7 +971,8 @@ static int __devinit dfx_driver_init(struct net_device *dev,
 	int alloc_size;			/* total buffer size needed */
 	char *top_v, *curr_v;		/* virtual addrs into memory block */
 	dma_addr_t top_p, curr_p;	/* physical addrs into memory block */
-	u32 data, le32;			/* host data register value */
+	u32 data;			/* host data register value */
+	__le32 le32;
 	char *board_name = NULL;
 
 	DBG_printk("In dfx_driver_init...\n");
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 3b84028..a05aa51 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -188,7 +188,7 @@ struct e1000_tx_ring {
 	spinlock_t tx_lock;
 	uint16_t tdh;
 	uint16_t tdt;
-	boolean_t last_tx_tso;
+	bool last_tx_tso;
 };
 
 struct e1000_rx_ring {
@@ -249,7 +249,6 @@ struct e1000_adapter {
 #ifdef CONFIG_E1000_NAPI
 	spinlock_t tx_queue_lock;
 #endif
-	atomic_t irq_sem;
 	unsigned int total_tx_bytes;
 	unsigned int total_tx_packets;
 	unsigned int total_rx_bytes;
@@ -283,17 +282,17 @@ struct e1000_adapter {
 	uint32_t tx_fifo_size;
 	uint8_t  tx_timeout_factor;
 	atomic_t tx_fifo_stall;
-	boolean_t pcix_82544;
-	boolean_t detect_tx_hung;
+	bool pcix_82544;
+	bool detect_tx_hung;
 
 	/* RX */
 #ifdef CONFIG_E1000_NAPI
-	boolean_t (*clean_rx) (struct e1000_adapter *adapter,
-			       struct e1000_rx_ring *rx_ring,
-			       int *work_done, int work_to_do);
+	bool (*clean_rx) (struct e1000_adapter *adapter,
+			  struct e1000_rx_ring *rx_ring,
+			  int *work_done, int work_to_do);
 #else
-	boolean_t (*clean_rx) (struct e1000_adapter *adapter,
-			       struct e1000_rx_ring *rx_ring);
+	bool (*clean_rx) (struct e1000_adapter *adapter,
+			  struct e1000_rx_ring *rx_ring);
 #endif
 	void (*alloc_rx_buf) (struct e1000_adapter *adapter,
 			      struct e1000_rx_ring *rx_ring,
@@ -312,7 +311,7 @@ struct e1000_adapter {
 	uint32_t alloc_rx_buff_failed;
 	uint32_t rx_int_delay;
 	uint32_t rx_abs_int_delay;
-	boolean_t rx_csum;
+	bool rx_csum;
 	unsigned int rx_ps_pages;
 	uint32_t gorcl;
 	uint64_t gorcl_old;
@@ -335,12 +334,12 @@ struct e1000_adapter {
 	struct e1000_rx_ring test_rx_ring;
 
 	int msg_enable;
-	boolean_t have_msi;
+	bool have_msi;
 
 	/* to not mess up cache alignment, always add to the bottom */
-	boolean_t tso_force;
-	boolean_t smart_power_down;	/* phy smart power down */
-	boolean_t quad_port_a;
+	bool tso_force;
+	bool smart_power_down;	/* phy smart power down */
+	bool quad_port_a;
 	unsigned long flags;
 	uint32_t eeprom_wol;
 };
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 85e66f4..05e1fb3 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -353,7 +353,7 @@ e1000_set_tso(struct net_device *netdev, uint32_t data)
 		netdev->features &= ~NETIF_F_TSO6;
 
 	DPRINTK(PROBE, INFO, "TSO is %s\n", data ? "Enabled" : "Disabled");
-	adapter->tso_force = TRUE;
+	adapter->tso_force = true;
 	return 0;
 }
 
@@ -922,7 +922,8 @@ static int
 e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint32_t mask, i=0, shared_int = TRUE;
+	uint32_t mask, i = 0;
+	bool shared_int = true;
 	uint32_t irq = adapter->pdev->irq;
 
 	*data = 0;
@@ -931,7 +932,7 @@ e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 	/* Hook up test interrupt handler just for this test */
 	if (!request_irq(irq, &e1000_test_intr, IRQF_PROBE_SHARED, netdev->name,
 	                 netdev))
-		shared_int = FALSE;
+		shared_int = false;
 	else if (request_irq(irq, &e1000_test_intr, IRQF_SHARED,
 	         netdev->name, netdev)) {
 		*data = 1;
@@ -1295,7 +1296,7 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	uint32_t ctrl_reg = 0;
 	uint32_t stat_reg = 0;
 
-	adapter->hw.autoneg = FALSE;
+	adapter->hw.autoneg = false;
 
 	if (adapter->hw.phy_type == e1000_phy_m88) {
 		/* Auto-MDI/MDIX Off */
@@ -1473,7 +1474,7 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	case e1000_82545_rev_3:
 	case e1000_82546_rev_3:
 	default:
-		hw->autoneg = TRUE;
+		hw->autoneg = true;
 		if (hw->phy_type == e1000_phy_gg82563)
 			e1000_write_phy_reg(hw,
 					    GG82563_PHY_KMRN_MODE_CTRL,
@@ -1607,13 +1608,13 @@ e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
 	*data = 0;
 	if (adapter->hw.media_type == e1000_media_type_internal_serdes) {
 		int i = 0;
-		adapter->hw.serdes_link_down = TRUE;
+		adapter->hw.serdes_link_down = true;
 
 		/* On some blade server designs, link establishment
 		 * could take as long as 2-3 minutes */
 		do {
 			e1000_check_for_link(&adapter->hw);
-			if (adapter->hw.serdes_link_down == FALSE)
+			if (!adapter->hw.serdes_link_down)
 				return *data;
 			msleep(20);
 		} while (i++ < 3750);
@@ -1649,7 +1650,7 @@ e1000_diag_test(struct net_device *netdev,
 		   struct ethtool_test *eth_test, uint64_t *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	boolean_t if_running = netif_running(netdev);
+	bool if_running = netif_running(netdev);
 
 	set_bit(__E1000_TESTING, &adapter->flags);
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 7c6888c..b642034 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -46,7 +46,8 @@ static int32_t e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *pol
 static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
 static void e1000_clear_vfta(struct e1000_hw *hw);
 static int32_t e1000_commit_shadow_ram(struct e1000_hw *hw);
-static int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw, boolean_t link_up);
+static int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw,
+						  bool link_up);
 static int32_t e1000_config_fc_after_link_up(struct e1000_hw *hw);
 static int32_t e1000_detect_gig_phy(struct e1000_hw *hw);
 static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank);
@@ -62,7 +63,7 @@ static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32
 static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
 static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
-static boolean_t e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
+static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
 static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
 static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
 static int32_t e1000_mng_host_if_write(struct e1000_hw *hw, uint8_t *buffer, uint16_t length, uint16_t offset, uint8_t *sum);
@@ -84,8 +85,8 @@ static int32_t e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32
 static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
 static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
 static void e1000_release_software_flag(struct e1000_hw *hw);
-static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, boolean_t active);
-static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, boolean_t active);
+static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
+static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
 static int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop);
 static void e1000_set_pci_express_master_disable(struct e1000_hw *hw);
 static int32_t e1000_wait_autoneg(struct e1000_hw *hw);
@@ -425,22 +426,22 @@ e1000_set_mac_type(struct e1000_hw *hw)
 
 	switch (hw->mac_type) {
 	case e1000_ich8lan:
-		hw->swfwhw_semaphore_present = TRUE;
-		hw->asf_firmware_present = TRUE;
+		hw->swfwhw_semaphore_present = true;
+		hw->asf_firmware_present = true;
 		break;
 	case e1000_80003es2lan:
-		hw->swfw_sync_present = TRUE;
+		hw->swfw_sync_present = true;
 		/* fall through */
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_82573:
-		hw->eeprom_semaphore_present = TRUE;
+		hw->eeprom_semaphore_present = true;
 		/* fall through */
 	case e1000_82541:
 	case e1000_82547:
 	case e1000_82541_rev_2:
 	case e1000_82547_rev_2:
-		hw->asf_firmware_present = TRUE;
+		hw->asf_firmware_present = true;
 		break;
 	default:
 		break;
@@ -450,20 +451,20 @@ e1000_set_mac_type(struct e1000_hw *hw)
 	 * FD mode
 	 */
 	if (hw->mac_type == e1000_82543)
-		hw->bad_tx_carr_stats_fd = TRUE;
+		hw->bad_tx_carr_stats_fd = true;
 
 	/* capable of receiving management packets to the host */
 	if (hw->mac_type >= e1000_82571)
-		hw->has_manc2h = TRUE;
+		hw->has_manc2h = true;
 
 	/* In rare occasions, ESB2 systems would end up started without
 	 * the RX unit being turned on.
 	 */
 	if (hw->mac_type == e1000_80003es2lan)
-		hw->rx_needs_kicking = TRUE;
+		hw->rx_needs_kicking = true;
 
 	if (hw->mac_type > e1000_82544)
-		hw->has_smbus = TRUE;
+		hw->has_smbus = true;
 
 	return E1000_SUCCESS;
 }
@@ -482,7 +483,7 @@ e1000_set_media_type(struct e1000_hw *hw)
 
     if (hw->mac_type != e1000_82543) {
         /* tbi_compatibility is only valid on 82543 */
-        hw->tbi_compatibility_en = FALSE;
+        hw->tbi_compatibility_en = false;
     }
 
     switch (hw->device_id) {
@@ -513,7 +514,7 @@ e1000_set_media_type(struct e1000_hw *hw)
             if (status & E1000_STATUS_TBIMODE) {
                 hw->media_type = e1000_media_type_fiber;
                 /* tbi_compatibility not valid on fiber */
-                hw->tbi_compatibility_en = FALSE;
+                hw->tbi_compatibility_en = false;
             } else {
                 hw->media_type = e1000_media_type_copper;
             }
@@ -569,7 +570,7 @@ e1000_reset_hw(struct e1000_hw *hw)
     E1000_WRITE_FLUSH(hw);
 
     /* The tbi_compatibility_on Flag must be cleared when Rctl is cleared. */
-    hw->tbi_compatibility_on = FALSE;
+    hw->tbi_compatibility_on = false;
 
     /* Delay to allow any outstanding PCI transactions to complete before
      * resetting the device
@@ -682,7 +683,7 @@ e1000_reset_hw(struct e1000_hw *hw)
             msleep(20);
             break;
         case e1000_82573:
-            if (e1000_is_onboard_nvm_eeprom(hw) == FALSE) {
+            if (!e1000_is_onboard_nvm_eeprom(hw)) {
                 udelay(10);
                 ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
                 ctrl_ext |= E1000_CTRL_EXT_EE_RST;
@@ -1428,7 +1429,7 @@ e1000_copper_link_preconfig(struct e1000_hw *hw)
     if (hw->mac_type <= e1000_82543 ||
         hw->mac_type == e1000_82541 || hw->mac_type == e1000_82547 ||
         hw->mac_type == e1000_82541_rev_2 || hw->mac_type == e1000_82547_rev_2)
-        hw->phy_reset_disable = FALSE;
+        hw->phy_reset_disable = false;
 
    return E1000_SUCCESS;
 }
@@ -1470,7 +1471,7 @@ e1000_copper_link_igp_setup(struct e1000_hw *hw)
     /* The NVM settings will configure LPLU in D3 for IGP2 and IGP3 PHYs */
     if (hw->phy_type == e1000_phy_igp) {
         /* disable lplu d3 during driver init */
-        ret_val = e1000_set_d3_lplu_state(hw, FALSE);
+        ret_val = e1000_set_d3_lplu_state(hw, false);
         if (ret_val) {
             DEBUGOUT("Error Disabling LPLU D3\n");
             return ret_val;
@@ -1478,7 +1479,7 @@ e1000_copper_link_igp_setup(struct e1000_hw *hw)
     }
 
     /* disable lplu d0 during driver init */
-    ret_val = e1000_set_d0_lplu_state(hw, FALSE);
+    ret_val = e1000_set_d0_lplu_state(hw, false);
     if (ret_val) {
         DEBUGOUT("Error Disabling LPLU D0\n");
         return ret_val;
@@ -1691,7 +1692,7 @@ e1000_copper_link_ggp_setup(struct e1000_hw *hw)
          * firmware will have already initialized them.  We only initialize
          * them if the HW is not in IAMT mode.
          */
-        if (e1000_check_mng_mode(hw) == FALSE) {
+        if (!e1000_check_mng_mode(hw)) {
             /* Enable Electrical Idle on the PHY */
             phy_data |= GG82563_PMCR_ENABLE_ELECTRICAL_IDLE;
             ret_val = e1000_write_phy_reg(hw, GG82563_PHY_PWR_MGMT_CTRL,
@@ -1892,7 +1893,7 @@ e1000_copper_link_autoneg(struct e1000_hw *hw)
         }
     }
 
-    hw->get_link_status = TRUE;
+    hw->get_link_status = true;
 
     return E1000_SUCCESS;
 }
@@ -1932,7 +1933,7 @@ e1000_copper_link_postconfig(struct e1000_hw *hw)
 
     /* Config DSP to improve Giga link quality */
     if (hw->phy_type == e1000_phy_igp) {
-        ret_val = e1000_config_dsp_after_link_change(hw, TRUE);
+        ret_val = e1000_config_dsp_after_link_change(hw, true);
         if (ret_val) {
             DEBUGOUT("Error Configuring DSP after link up\n");
             return ret_val;
@@ -2923,7 +2924,7 @@ e1000_check_for_link(struct e1000_hw *hw)
         if (hw->media_type == e1000_media_type_fiber) {
             signal = (hw->mac_type > e1000_82544) ? E1000_CTRL_SWDPIN1 : 0;
             if (status & E1000_STATUS_LU)
-                hw->get_link_status = FALSE;
+                hw->get_link_status = false;
         }
     }
 
@@ -2947,7 +2948,7 @@ e1000_check_for_link(struct e1000_hw *hw)
             return ret_val;
 
         if (phy_data & MII_SR_LINK_STATUS) {
-            hw->get_link_status = FALSE;
+            hw->get_link_status = false;
             /* Check if there was DownShift, must be checked immediately after
              * link-up */
             e1000_check_downshift(hw);
@@ -2973,7 +2974,7 @@ e1000_check_for_link(struct e1000_hw *hw)
 
         } else {
             /* No link detected */
-            e1000_config_dsp_after_link_change(hw, FALSE);
+            e1000_config_dsp_after_link_change(hw, false);
             return 0;
         }
 
@@ -2983,7 +2984,7 @@ e1000_check_for_link(struct e1000_hw *hw)
         if (!hw->autoneg) return -E1000_ERR_CONFIG;
 
         /* optimize the dsp settings for the igp phy */
-        e1000_config_dsp_after_link_change(hw, TRUE);
+        e1000_config_dsp_after_link_change(hw, true);
 
         /* We have a M88E1000 PHY and Auto-Neg is enabled.  If we
          * have Si on board that is 82544 or newer, Auto
@@ -3036,7 +3037,7 @@ e1000_check_for_link(struct e1000_hw *hw)
                     rctl = E1000_READ_REG(hw, RCTL);
                     rctl &= ~E1000_RCTL_SBP;
                     E1000_WRITE_REG(hw, RCTL, rctl);
-                    hw->tbi_compatibility_on = FALSE;
+                    hw->tbi_compatibility_on = false;
                 }
             } else {
                 /* If TBI compatibility is was previously off, turn it on. For
@@ -3045,7 +3046,7 @@ e1000_check_for_link(struct e1000_hw *hw)
                  * will look like CRC errors to to the hardware.
                  */
                 if (!hw->tbi_compatibility_on) {
-                    hw->tbi_compatibility_on = TRUE;
+                    hw->tbi_compatibility_on = true;
                     rctl = E1000_READ_REG(hw, RCTL);
                     rctl |= E1000_RCTL_SBP;
                     E1000_WRITE_REG(hw, RCTL, rctl);
@@ -3098,7 +3099,7 @@ e1000_check_for_link(struct e1000_hw *hw)
         E1000_WRITE_REG(hw, TXCW, hw->txcw);
         E1000_WRITE_REG(hw, CTRL, (ctrl & ~E1000_CTRL_SLU));
 
-        hw->serdes_link_down = FALSE;
+        hw->serdes_link_down = false;
     }
     /* If we force link for non-auto-negotiation switch, check link status
      * based on MAC synchronization for internal serdes media type.
@@ -3109,11 +3110,11 @@ e1000_check_for_link(struct e1000_hw *hw)
         udelay(10);
         if (E1000_RXCW_SYNCH & E1000_READ_REG(hw, RXCW)) {
             if (!(rxcw & E1000_RXCW_IV)) {
-                hw->serdes_link_down = FALSE;
+                hw->serdes_link_down = false;
                 DEBUGOUT("SERDES: Link is up.\n");
             }
         } else {
-            hw->serdes_link_down = TRUE;
+            hw->serdes_link_down = true;
             DEBUGOUT("SERDES: Link is down.\n");
         }
     }
@@ -4044,7 +4045,7 @@ e1000_detect_gig_phy(struct e1000_hw *hw)
 {
     int32_t phy_init_status, ret_val;
     uint16_t phy_id_high, phy_id_low;
-    boolean_t match = FALSE;
+    bool match = false;
 
     DEBUGFUNC("e1000_detect_gig_phy");
 
@@ -4086,35 +4087,35 @@ e1000_detect_gig_phy(struct e1000_hw *hw)
 
     switch (hw->mac_type) {
     case e1000_82543:
-        if (hw->phy_id == M88E1000_E_PHY_ID) match = TRUE;
+        if (hw->phy_id == M88E1000_E_PHY_ID) match = true;
         break;
     case e1000_82544:
-        if (hw->phy_id == M88E1000_I_PHY_ID) match = TRUE;
+        if (hw->phy_id == M88E1000_I_PHY_ID) match = true;
         break;
     case e1000_82540:
     case e1000_82545:
     case e1000_82545_rev_3:
     case e1000_82546:
     case e1000_82546_rev_3:
-        if (hw->phy_id == M88E1011_I_PHY_ID) match = TRUE;
+        if (hw->phy_id == M88E1011_I_PHY_ID) match = true;
         break;
     case e1000_82541:
     case e1000_82541_rev_2:
     case e1000_82547:
     case e1000_82547_rev_2:
-        if (hw->phy_id == IGP01E1000_I_PHY_ID) match = TRUE;
+        if (hw->phy_id == IGP01E1000_I_PHY_ID) match = true;
         break;
     case e1000_82573:
-        if (hw->phy_id == M88E1111_I_PHY_ID) match = TRUE;
+        if (hw->phy_id == M88E1111_I_PHY_ID) match = true;
         break;
     case e1000_80003es2lan:
-        if (hw->phy_id == GG82563_E_PHY_ID) match = TRUE;
+        if (hw->phy_id == GG82563_E_PHY_ID) match = true;
         break;
     case e1000_ich8lan:
-        if (hw->phy_id == IGP03E1000_E_PHY_ID) match = TRUE;
-        if (hw->phy_id == IFE_E_PHY_ID) match = TRUE;
-        if (hw->phy_id == IFE_PLUS_E_PHY_ID) match = TRUE;
-        if (hw->phy_id == IFE_C_E_PHY_ID) match = TRUE;
+        if (hw->phy_id == IGP03E1000_E_PHY_ID) match = true;
+        if (hw->phy_id == IFE_E_PHY_ID) match = true;
+        if (hw->phy_id == IFE_PLUS_E_PHY_ID) match = true;
+        if (hw->phy_id == IFE_C_E_PHY_ID) match = true;
         break;
     default:
         DEBUGOUT1("Invalid MAC type %d\n", hw->mac_type);
@@ -4455,8 +4456,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
         eeprom->opcode_bits = 3;
         eeprom->address_bits = 6;
         eeprom->delay_usec = 50;
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         break;
     case e1000_82540:
     case e1000_82545:
@@ -4473,8 +4474,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             eeprom->word_size = 64;
             eeprom->address_bits = 6;
         }
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         break;
     case e1000_82541:
     case e1000_82541_rev_2:
@@ -4503,8 +4504,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
                 eeprom->address_bits = 6;
             }
         }
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         break;
     case e1000_82571:
     case e1000_82572:
@@ -4518,8 +4519,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             eeprom->page_size = 8;
             eeprom->address_bits = 8;
         }
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         break;
     case e1000_82573:
         eeprom->type = e1000_eeprom_spi;
@@ -4532,9 +4533,9 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             eeprom->page_size = 8;
             eeprom->address_bits = 8;
         }
-        eeprom->use_eerd = TRUE;
-        eeprom->use_eewr = TRUE;
-        if (e1000_is_onboard_nvm_eeprom(hw) == FALSE) {
+        eeprom->use_eerd = true;
+        eeprom->use_eewr = true;
+        if (!e1000_is_onboard_nvm_eeprom(hw)) {
             eeprom->type = e1000_eeprom_flash;
             eeprom->word_size = 2048;
 
@@ -4555,8 +4556,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             eeprom->page_size = 8;
             eeprom->address_bits = 8;
         }
-        eeprom->use_eerd = TRUE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = true;
+        eeprom->use_eewr = false;
         break;
     case e1000_ich8lan:
         {
@@ -4564,15 +4565,15 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
         uint32_t flash_size = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_GFPREG);
 
         eeprom->type = e1000_eeprom_ich8;
-        eeprom->use_eerd = FALSE;
-        eeprom->use_eewr = FALSE;
+        eeprom->use_eerd = false;
+        eeprom->use_eewr = false;
         eeprom->word_size = E1000_SHADOW_RAM_WORDS;
 
         /* Zero the shadow RAM structure. But don't load it from NVM
          * so as to save time for driver init */
         if (hw->eeprom_shadow_ram != NULL) {
             for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
-                hw->eeprom_shadow_ram[i].modified = FALSE;
+                hw->eeprom_shadow_ram[i].modified = false;
                 hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
             }
         }
@@ -4994,15 +4995,14 @@ e1000_read_eeprom(struct e1000_hw *hw,
      * directly. In this case, we need to acquire the EEPROM so that
      * FW or other port software does not interrupt.
      */
-    if (e1000_is_onboard_nvm_eeprom(hw) == TRUE &&
-        hw->eeprom.use_eerd == FALSE) {
+    if (e1000_is_onboard_nvm_eeprom(hw) && !hw->eeprom.use_eerd) {
         /* Prepare the EEPROM for bit-bang reading */
         if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
             return -E1000_ERR_EEPROM;
     }
 
     /* Eerd register EEPROM access requires no eeprom aquire/release */
-    if (eeprom->use_eerd == TRUE)
+    if (eeprom->use_eerd)
         return e1000_read_eeprom_eerd(hw, offset, words, data);
 
     /* ICH EEPROM access is done via the ICH flash controller */
@@ -5171,7 +5171,7 @@ e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 *
 * hw - Struct containing variables accessed by shared code
 ****************************************************************************/
-static boolean_t
+static bool
 e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
 {
     uint32_t eecd = 0;
@@ -5179,7 +5179,7 @@ e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
     DEBUGFUNC("e1000_is_onboard_nvm_eeprom");
 
     if (hw->mac_type == e1000_ich8lan)
-        return FALSE;
+        return false;
 
     if (hw->mac_type == e1000_82573) {
         eecd = E1000_READ_REG(hw, EECD);
@@ -5189,10 +5189,10 @@ e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
 
         /* If both bits are set, device is Flash type */
         if (eecd == 0x03) {
-            return FALSE;
+            return false;
         }
     }
-    return TRUE;
+    return true;
 }
 
 /******************************************************************************
@@ -5212,8 +5212,7 @@ e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_validate_eeprom_checksum");
 
-    if ((hw->mac_type == e1000_82573) &&
-        (e1000_is_onboard_nvm_eeprom(hw) == FALSE)) {
+    if ((hw->mac_type == e1000_82573) && !e1000_is_onboard_nvm_eeprom(hw)) {
         /* Check bit 4 of word 10h.  If it is 0, firmware is done updating
          * 10h-12h.  Checksum may need to be fixed. */
         e1000_read_eeprom(hw, 0x10, 1, &eeprom_data);
@@ -5339,7 +5338,7 @@ e1000_write_eeprom(struct e1000_hw *hw,
     }
 
     /* 82573 writes only through eewr */
-    if (eeprom->use_eewr == TRUE)
+    if (eeprom->use_eewr)
         return e1000_write_eeprom_eewr(hw, offset, words, data);
 
     if (eeprom->type == e1000_eeprom_ich8)
@@ -5536,7 +5535,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
     uint32_t new_bank_offset = 0;
     uint8_t low_byte = 0;
     uint8_t high_byte = 0;
-    boolean_t sector_write_failed = FALSE;
+    bool sector_write_failed = false;
 
     if (hw->mac_type == e1000_82573) {
         /* The flop register will be used to determine if flash type is STM */
@@ -5588,21 +5587,21 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
             e1000_erase_ich8_4k_segment(hw, 0);
         }
 
-        sector_write_failed = FALSE;
+        sector_write_failed = false;
         /* Loop for every byte in the shadow RAM,
          * which is in units of words. */
         for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
             /* Determine whether to write the value stored
              * in the other NVM bank or a modified value stored
              * in the shadow RAM */
-            if (hw->eeprom_shadow_ram[i].modified == TRUE) {
+            if (hw->eeprom_shadow_ram[i].modified) {
                 low_byte = (uint8_t)hw->eeprom_shadow_ram[i].eeprom_word;
                 udelay(100);
                 error = e1000_verify_write_ich8_byte(hw,
                             (i << 1) + new_bank_offset, low_byte);
 
                 if (error != E1000_SUCCESS)
-                    sector_write_failed = TRUE;
+                    sector_write_failed = true;
                 else {
                     high_byte =
                         (uint8_t)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
@@ -5616,7 +5615,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
                             (i << 1) + new_bank_offset, low_byte);
 
                 if (error != E1000_SUCCESS)
-                    sector_write_failed = TRUE;
+                    sector_write_failed = true;
                 else {
                     e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset + 1,
                                          &high_byte);
@@ -5624,10 +5623,10 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
                 }
             }
 
-            /* If the write of the low byte was successful, go ahread and
+            /* If the write of the low byte was successful, go ahead and
              * write the high byte while checking to make sure that if it
              * is the signature byte, then it is handled properly */
-            if (sector_write_failed == FALSE) {
+            if (!sector_write_failed) {
                 /* If the word is 0x13, then make sure the signature bits
                  * (15:14) are 11b until the commit has completed.
                  * This will allow us to write 10b which indicates the
@@ -5640,7 +5639,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
                 error = e1000_verify_write_ich8_byte(hw,
                             (i << 1) + new_bank_offset + 1, high_byte);
                 if (error != E1000_SUCCESS)
-                    sector_write_failed = TRUE;
+                    sector_write_failed = true;
 
             } else {
                 /* If the write failed then break from the loop and
@@ -5651,7 +5650,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
 
         /* Don't bother writing the segment valid bits if sector
          * programming failed. */
-        if (sector_write_failed == FALSE) {
+        if (!sector_write_failed) {
             /* Finally validate the new segment by setting bit 15:14
              * to 10b in word 0x13 , this can be done without an
              * erase as well since these bits are 11 to start with
@@ -5673,7 +5672,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
 
             /* Clear the now not used entry in the cache */
             for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
-                hw->eeprom_shadow_ram[i].modified = FALSE;
+                hw->eeprom_shadow_ram[i].modified = false;
                 hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
             }
         }
@@ -5750,7 +5749,7 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
     /* Reserve a spot for the Locally Administered Address to work around
      * an 82571 issue in which a reset on one port will reload the MAC on
      * the other port. */
-    if ((hw->mac_type == e1000_82571) && (hw->laa_is_present == TRUE))
+    if ((hw->mac_type == e1000_82571) && (hw->laa_is_present))
         rar_num -= 1;
     if (hw->mac_type == e1000_ich8lan)
         rar_num = E1000_RAR_ENTRIES_ICH8LAN;
@@ -5922,7 +5921,7 @@ e1000_rar_set(struct e1000_hw *hw,
     case e1000_82571:
     case e1000_82572:
     case e1000_80003es2lan:
-        if (hw->leave_av_bit_off == TRUE)
+        if (hw->leave_av_bit_off)
             break;
     default:
         /* Indicate to hardware the Address is Valid. */
@@ -6425,7 +6424,7 @@ e1000_clear_hw_cntrs(struct e1000_hw *hw)
  * hw - Struct containing variables accessed by shared code
  *
  * Call this after e1000_init_hw. You may override the IFS defaults by setting
- * hw->ifs_params_forced to TRUE. However, you must initialize hw->
+ * hw->ifs_params_forced to true. However, you must initialize hw->
  * current_ifs_val, ifs_min_val, ifs_max_val, ifs_step_size, and ifs_ratio
  * before calling this function.
  *****************************************************************************/
@@ -6442,7 +6441,7 @@ e1000_reset_adaptive(struct e1000_hw *hw)
             hw->ifs_step_size = IFS_STEP;
             hw->ifs_ratio = IFS_RATIO;
         }
-        hw->in_ifs_mode = FALSE;
+        hw->in_ifs_mode = false;
         E1000_WRITE_REG(hw, AIT, 0);
     } else {
         DEBUGOUT("Not in Adaptive IFS mode!\n");
@@ -6465,7 +6464,7 @@ e1000_update_adaptive(struct e1000_hw *hw)
     if (hw->adaptive_ifs) {
         if ((hw->collision_delta * hw->ifs_ratio) > hw->tx_packet_delta) {
             if (hw->tx_packet_delta > MIN_NUM_XMITS) {
-                hw->in_ifs_mode = TRUE;
+                hw->in_ifs_mode = true;
                 if (hw->current_ifs_val < hw->ifs_max_val) {
                     if (hw->current_ifs_val == 0)
                         hw->current_ifs_val = hw->ifs_min_val;
@@ -6477,7 +6476,7 @@ e1000_update_adaptive(struct e1000_hw *hw)
         } else {
             if (hw->in_ifs_mode && (hw->tx_packet_delta <= MIN_NUM_XMITS)) {
                 hw->current_ifs_val = 0;
-                hw->in_ifs_mode = FALSE;
+                hw->in_ifs_mode = false;
                 E1000_WRITE_REG(hw, AIT, 0);
             }
         }
@@ -6968,7 +6967,7 @@ e1000_check_downshift(struct e1000_hw *hw)
                                M88E1000_PSSR_DOWNSHIFT_SHIFT;
     } else if (hw->phy_type == e1000_phy_ife) {
         /* e1000_phy_ife supports 10/100 speed only */
-        hw->speed_downgraded = FALSE;
+        hw->speed_downgraded = false;
     }
 
     return E1000_SUCCESS;
@@ -6988,7 +6987,7 @@ e1000_check_downshift(struct e1000_hw *hw)
 
 static int32_t
 e1000_config_dsp_after_link_change(struct e1000_hw *hw,
-                                   boolean_t link_up)
+                                   bool link_up)
 {
     int32_t ret_val;
     uint16_t phy_data, phy_saved_data, speed, duplex, i;
@@ -7198,7 +7197,7 @@ e1000_set_phy_mode(struct e1000_hw *hw)
             if (ret_val)
                 return ret_val;
 
-            hw->phy_reset_disable = FALSE;
+            hw->phy_reset_disable = false;
         }
     }
 
@@ -7221,7 +7220,7 @@ e1000_set_phy_mode(struct e1000_hw *hw)
 
 static int32_t
 e1000_set_d3_lplu_state(struct e1000_hw *hw,
-                        boolean_t active)
+                        bool active)
 {
     uint32_t phy_ctrl = 0;
     int32_t ret_val;
@@ -7351,7 +7350,7 @@ e1000_set_d3_lplu_state(struct e1000_hw *hw,
 
 static int32_t
 e1000_set_d0_lplu_state(struct e1000_hw *hw,
-                        boolean_t active)
+                        bool active)
 {
     uint32_t phy_ctrl = 0;
     int32_t ret_val;
@@ -7689,9 +7688,9 @@ e1000_mng_write_commit(struct e1000_hw * hw)
 /*****************************************************************************
  * This function checks the mode of the firmware.
  *
- * returns  - TRUE when the mode is IAMT or FALSE.
+ * returns  - true when the mode is IAMT or false.
  ****************************************************************************/
-boolean_t
+bool
 e1000_check_mng_mode(struct e1000_hw *hw)
 {
     uint32_t fwsm;
@@ -7701,12 +7700,12 @@ e1000_check_mng_mode(struct e1000_hw *hw)
     if (hw->mac_type == e1000_ich8lan) {
         if ((fwsm & E1000_FWSM_MODE_MASK) ==
             (E1000_MNG_ICH_IAMT_MODE << E1000_FWSM_MODE_SHIFT))
-            return TRUE;
+            return true;
     } else if ((fwsm & E1000_FWSM_MODE_MASK) ==
                (E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT))
-        return TRUE;
+        return true;
 
-    return FALSE;
+    return false;
 }
 
 
@@ -7763,15 +7762,15 @@ e1000_calculate_mng_checksum(char *buffer, uint32_t length)
 /*****************************************************************************
  * This function checks whether tx pkt filtering needs to be enabled or not.
  *
- * returns  - TRUE for packet filtering or FALSE.
+ * returns  - true for packet filtering or false.
  ****************************************************************************/
-boolean_t
+bool
 e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
 {
     /* called in init as well as watchdog timer functions */
 
     int32_t ret_val, checksum;
-    boolean_t tx_filter = FALSE;
+    bool tx_filter = false;
     struct e1000_host_mng_dhcp_cookie *hdr = &(hw->mng_cookie);
     uint8_t *buffer = (uint8_t *) &(hw->mng_cookie);
 
@@ -7787,11 +7786,11 @@ e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
                                                E1000_MNG_DHCP_COOKIE_LENGTH)) {
                     if (hdr->status &
                         E1000_MNG_DHCP_COOKIE_STATUS_PARSING_SUPPORT)
-                        tx_filter = TRUE;
+                        tx_filter = true;
                 } else
-                    tx_filter = TRUE;
+                    tx_filter = true;
             } else
-                tx_filter = TRUE;
+                tx_filter = true;
         }
     }
 
@@ -7804,7 +7803,7 @@ e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *
- * returns: - TRUE/FALSE
+ * returns: - true/false
  *
  *****************************************************************************/
 uint32_t
@@ -7818,19 +7817,19 @@ e1000_enable_mng_pass_thru(struct e1000_hw *hw)
 
         if (!(manc & E1000_MANC_RCV_TCO_EN) ||
             !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
-            return FALSE;
-        if (e1000_arc_subsystem_valid(hw) == TRUE) {
+            return false;
+        if (e1000_arc_subsystem_valid(hw)) {
             fwsm = E1000_READ_REG(hw, FWSM);
             factps = E1000_READ_REG(hw, FACTPS);
 
             if ((((fwsm & E1000_FWSM_MODE_MASK) >> E1000_FWSM_MODE_SHIFT) ==
                    e1000_mng_mode_pt) && !(factps & E1000_FACTPS_MNGCG))
-                return TRUE;
+                return true;
         } else
             if ((manc & E1000_MANC_SMBUS_EN) && !(manc & E1000_MANC_ASF_EN))
-                return TRUE;
+                return true;
     }
-    return FALSE;
+    return false;
 }
 
 static int32_t
@@ -8264,14 +8263,14 @@ e1000_arc_subsystem_valid(struct e1000_hw *hw)
     case e1000_80003es2lan:
         fwsm = E1000_READ_REG(hw, FWSM);
         if ((fwsm & E1000_FWSM_MODE_MASK) != 0)
-            return TRUE;
+            return true;
         break;
     case e1000_ich8lan:
-        return TRUE;
+        return true;
     default:
         break;
     }
-    return FALSE;
+    return false;
 }
 
 
@@ -8417,7 +8416,7 @@ e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
 
     for (i = 0; i < words; i++) {
         if (hw->eeprom_shadow_ram != NULL &&
-            hw->eeprom_shadow_ram[offset+i].modified == TRUE) {
+            hw->eeprom_shadow_ram[offset+i].modified) {
             data[i] = hw->eeprom_shadow_ram[offset+i].eeprom_word;
         } else {
             /* The NVM part needs a byte offset, hence * 2 */
@@ -8466,7 +8465,7 @@ e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
     if (hw->eeprom_shadow_ram != NULL) {
         for (i = 0; i < words; i++) {
             if ((offset + i) < E1000_SHADOW_RAM_WORDS) {
-                hw->eeprom_shadow_ram[offset+i].modified = TRUE;
+                hw->eeprom_shadow_ram[offset+i].modified = true;
                 hw->eeprom_shadow_ram[offset+i].eeprom_word = data[i];
             } else {
                 error = -E1000_ERR_EEPROM;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index a6c3c34..572a7b6 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -100,8 +100,8 @@ typedef enum {
 } e1000_fc_type;
 
 struct e1000_shadow_ram {
-    uint16_t    eeprom_word;
-    boolean_t   modified;
+    uint16_t eeprom_word;
+    bool modified;
 };
 
 /* PCI bus types */
@@ -274,8 +274,8 @@ struct e1000_eeprom_info {
     uint16_t address_bits;
     uint16_t delay_usec;
     uint16_t page_size;
-    boolean_t use_eerd;
-    boolean_t use_eewr;
+    bool use_eerd;
+    bool use_eewr;
 };
 
 /* Flex ASF Information */
@@ -391,8 +391,8 @@ struct e1000_host_mng_dhcp_cookie{
 
 int32_t e1000_mng_write_dhcp_info(struct e1000_hw *hw, uint8_t *buffer,
                                   uint16_t length);
-boolean_t e1000_check_mng_mode(struct e1000_hw *hw);
-boolean_t e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
+bool e1000_check_mng_mode(struct e1000_hw *hw);
+bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
 int32_t e1000_read_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, uint16_t *data);
 int32_t e1000_validate_eeprom_checksum(struct e1000_hw *hw);
 int32_t e1000_update_eeprom_checksum(struct e1000_hw *hw);
@@ -1420,7 +1420,7 @@ struct e1000_hw {
 	uint32_t		ledctl_default;
 	uint32_t		ledctl_mode1;
 	uint32_t		ledctl_mode2;
-	boolean_t		tx_pkt_filtering;
+	bool			tx_pkt_filtering;
 	struct e1000_host_mng_dhcp_cookie mng_cookie;
 	uint16_t		phy_spd_default;
 	uint16_t		autoneg_advertised;
@@ -1445,30 +1445,30 @@ struct e1000_hw {
 	uint8_t			dma_fairness;
 	uint8_t			mac_addr[NODE_ADDRESS_SIZE];
 	uint8_t			perm_mac_addr[NODE_ADDRESS_SIZE];
-	boolean_t		disable_polarity_correction;
-	boolean_t		speed_downgraded;
+	bool			disable_polarity_correction;
+	bool			speed_downgraded;
 	e1000_smart_speed	smart_speed;
 	e1000_dsp_config	dsp_config_state;
-	boolean_t		get_link_status;
-	boolean_t		serdes_link_down;
-	boolean_t		tbi_compatibility_en;
-	boolean_t		tbi_compatibility_on;
-	boolean_t		laa_is_present;
-	boolean_t		phy_reset_disable;
-	boolean_t		initialize_hw_bits_disable;
-	boolean_t		fc_send_xon;
-	boolean_t		fc_strict_ieee;
-	boolean_t		report_tx_early;
-	boolean_t		adaptive_ifs;
-	boolean_t		ifs_params_forced;
-	boolean_t		in_ifs_mode;
-	boolean_t		mng_reg_access_disabled;
-	boolean_t		leave_av_bit_off;
-	boolean_t		kmrn_lock_loss_workaround_disabled;
-	boolean_t		bad_tx_carr_stats_fd;
-	boolean_t		has_manc2h;
-	boolean_t		rx_needs_kicking;
-	boolean_t		has_smbus;
+	bool			get_link_status;
+	bool			serdes_link_down;
+	bool			tbi_compatibility_en;
+	bool			tbi_compatibility_on;
+	bool			laa_is_present;
+	bool			phy_reset_disable;
+	bool			initialize_hw_bits_disable;
+	bool			fc_send_xon;
+	bool			fc_strict_ieee;
+	bool			report_tx_early;
+	bool			adaptive_ifs;
+	bool			ifs_params_forced;
+	bool			in_ifs_mode;
+	bool			mng_reg_access_disabled;
+	bool			leave_av_bit_off;
+	bool			kmrn_lock_loss_workaround_disabled;
+	bool			bad_tx_carr_stats_fd;
+	bool			has_manc2h;
+	bool			rx_needs_kicking;
+	bool			has_smbus;
 };
 
 
@@ -2518,11 +2518,11 @@ struct e1000_host_command_info {
  * Typical use:
  *  ...
  *  if (TBI_ACCEPT) {
- *      accept_frame = TRUE;
+ *      accept_frame = true;
  *      e1000_tbi_adjust_stats(adapter, MacAddress);
  *      frame_length--;
  *  } else {
- *      accept_frame = FALSE;
+ *      accept_frame = false;
  *  }
  *  ...
  */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0991648..757d02f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -169,21 +169,21 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t e1000_intr(int irq, void *data);
 static irqreturn_t e1000_intr_msi(int irq, void *data);
-static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter,
-                                    struct e1000_tx_ring *tx_ring);
+static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
+			       struct e1000_tx_ring *tx_ring);
 #ifdef CONFIG_E1000_NAPI
 static int e1000_clean(struct napi_struct *napi, int budget);
-static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
-                                    struct e1000_rx_ring *rx_ring,
-                                    int *work_done, int work_to_do);
-static boolean_t e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-                                       struct e1000_rx_ring *rx_ring,
-                                       int *work_done, int work_to_do);
+static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
+			       struct e1000_rx_ring *rx_ring,
+			       int *work_done, int work_to_do);
+static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
+				  struct e1000_rx_ring *rx_ring,
+				  int *work_done, int work_to_do);
 #else
-static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
-                                    struct e1000_rx_ring *rx_ring);
-static boolean_t e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-                                       struct e1000_rx_ring *rx_ring);
+static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
+			       struct e1000_rx_ring *rx_ring);
+static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
+				  struct e1000_rx_ring *rx_ring);
 #endif
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
                                    struct e1000_rx_ring *rx_ring,
@@ -347,7 +347,6 @@ static void e1000_free_irq(struct e1000_adapter *adapter)
 static void
 e1000_irq_disable(struct e1000_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
 	E1000_WRITE_FLUSH(&adapter->hw);
 	synchronize_irq(adapter->pdev->irq);
@@ -361,10 +360,8 @@ e1000_irq_disable(struct e1000_adapter *adapter)
 static void
 e1000_irq_enable(struct e1000_adapter *adapter)
 {
-	if (likely(atomic_dec_and_test(&adapter->irq_sem))) {
-		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
-		E1000_WRITE_FLUSH(&adapter->hw);
-	}
+	E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
+	E1000_WRITE_FLUSH(&adapter->hw);
 }
 
 static void
@@ -584,7 +581,7 @@ void e1000_power_up_phy(struct e1000_adapter *adapter)
 static void e1000_power_down_phy(struct e1000_adapter *adapter)
 {
 	/* Power down the PHY so no link is implied when interface is down *
-	 * The PHY cannot be powered down if any of the following is TRUE *
+	 * The PHY cannot be powered down if any of the following is true *
 	 * (a) WoL is enabled
 	 * (b) AMT is active
 	 * (c) SoL/IDER session is active */
@@ -638,7 +635,6 @@ e1000_down(struct e1000_adapter *adapter)
 
 #ifdef CONFIG_E1000_NAPI
 	napi_disable(&adapter->napi);
-	atomic_set(&adapter->irq_sem, 0);
 #endif
 	e1000_irq_disable(adapter);
 
@@ -673,7 +669,7 @@ e1000_reset(struct e1000_adapter *adapter)
 {
 	uint32_t pba = 0, tx_space, min_tx_space, min_rx_space;
 	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
-	boolean_t legacy_pba_adjust = FALSE;
+	bool legacy_pba_adjust = false;
 
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
@@ -687,7 +683,7 @@ e1000_reset(struct e1000_adapter *adapter)
 	case e1000_82540:
 	case e1000_82541:
 	case e1000_82541_rev_2:
-		legacy_pba_adjust = TRUE;
+		legacy_pba_adjust = true;
 		pba = E1000_PBA_48K;
 		break;
 	case e1000_82545:
@@ -698,7 +694,7 @@ e1000_reset(struct e1000_adapter *adapter)
 		break;
 	case e1000_82547:
 	case e1000_82547_rev_2:
-		legacy_pba_adjust = TRUE;
+		legacy_pba_adjust = true;
 		pba = E1000_PBA_30K;
 		break;
 	case e1000_82571:
@@ -716,7 +712,7 @@ e1000_reset(struct e1000_adapter *adapter)
 		break;
 	}
 
-	if (legacy_pba_adjust == TRUE) {
+	if (legacy_pba_adjust) {
 		if (adapter->netdev->mtu > E1000_RXBUFFER_8192)
 			pba -= 8; /* allocate more FIFO for Tx */
 
@@ -1366,15 +1362,15 @@ e1000_sw_init(struct e1000_adapter *adapter)
 
 	e1000_set_media_type(hw);
 
-	hw->wait_autoneg_complete = FALSE;
-	hw->tbi_compatibility_en = TRUE;
-	hw->adaptive_ifs = TRUE;
+	hw->wait_autoneg_complete = false;
+	hw->tbi_compatibility_en = true;
+	hw->adaptive_ifs = true;
 
 	/* Copper options */
 
 	if (hw->media_type == e1000_media_type_copper) {
 		hw->mdix = AUTO_ALL_MODES;
-		hw->disable_polarity_correction = FALSE;
+		hw->disable_polarity_correction = false;
 		hw->master_slave = E1000_MASTER_SLAVE;
 	}
 
@@ -1396,7 +1392,6 @@ e1000_sw_init(struct e1000_adapter *adapter)
 #endif
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */
-	atomic_set(&adapter->irq_sem, 0);
 	e1000_irq_disable(adapter);
 
 	spin_lock_init(&adapter->stats_lock);
@@ -1576,7 +1571,7 @@ e1000_close(struct net_device *netdev)
  * @start: address of beginning of memory
  * @len: length of memory
  **/
-static boolean_t
+static bool
 e1000_check_64k_bound(struct e1000_adapter *adapter,
 		      void *start, unsigned long len)
 {
@@ -1587,10 +1582,10 @@ e1000_check_64k_bound(struct e1000_adapter *adapter,
 	 * write location to cross 64k boundary due to errata 23 */
 	if (adapter->hw.mac_type == e1000_82545 ||
 	    adapter->hw.mac_type == e1000_82546) {
-		return ((begin ^ (end - 1)) >> 16) != 0 ? FALSE : TRUE;
+		return ((begin ^ (end - 1)) >> 16) != 0 ? false : true;
 	}
 
-	return TRUE;
+	return true;
 }
 
 /**
@@ -2133,7 +2128,7 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 	/* Enable 82543 Receive Checksum Offload for TCP and UDP */
 	if (hw->mac_type >= e1000_82543) {
 		rxcsum = E1000_READ_REG(hw, RXCSUM);
-		if (adapter->rx_csum == TRUE) {
+		if (adapter->rx_csum) {
 			rxcsum |= E1000_RXCSUM_TUOFL;
 
 			/* Enable 82571 IPv4 payload checksum for UDP fragments
@@ -2669,7 +2664,7 @@ e1000_watchdog(unsigned long data)
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
 			uint32_t ctrl;
-			boolean_t txb2b = 1;
+			bool txb2b = true;
 			e1000_get_speed_and_duplex(&adapter->hw,
 			                           &adapter->link_speed,
 			                           &adapter->link_duplex);
@@ -2691,12 +2686,12 @@ e1000_watchdog(unsigned long data)
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
-				txb2b = 0;
+				txb2b = false;
 				netdev->tx_queue_len = 10;
 				adapter->tx_timeout_factor = 8;
 				break;
 			case SPEED_100:
-				txb2b = 0;
+				txb2b = false;
 				netdev->tx_queue_len = 100;
 				/* maybe add some timeout factor ? */
 				break;
@@ -2704,7 +2699,7 @@ e1000_watchdog(unsigned long data)
 
 			if ((adapter->hw.mac_type == e1000_82571 ||
 			     adapter->hw.mac_type == e1000_82572) &&
-			    txb2b == 0) {
+			    !txb2b) {
 				uint32_t tarc0;
 				tarc0 = E1000_READ_REG(&adapter->hw, TARC0);
 				tarc0 &= ~(1 << 21);
@@ -2802,7 +2797,7 @@ e1000_watchdog(unsigned long data)
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_RXDMT0);
 
 	/* Force detection of hung controller every watchdog period */
-	adapter->detect_tx_hung = TRUE;
+	adapter->detect_tx_hung = true;
 
 	/* With 82571 controllers, LAA may be overwritten due to controller
 	 * reset from the other port. Set the appropriate LAA in RAR[0] */
@@ -3025,12 +3020,12 @@ e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 		if (++i == tx_ring->count) i = 0;
 		tx_ring->next_to_use = i;
 
-		return TRUE;
+		return true;
 	}
-	return FALSE;
+	return false;
 }
 
-static boolean_t
+static bool
 e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
               struct sk_buff *skb)
 {
@@ -3060,10 +3055,10 @@ e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 		if (unlikely(++i == tx_ring->count)) i = 0;
 		tx_ring->next_to_use = i;
 
-		return TRUE;
+		return true;
 	}
 
-	return FALSE;
+	return false;
 }
 
 #define E1000_MAX_TXD_PWR	12
@@ -3836,11 +3831,8 @@ e1000_intr_msi(int irq, void *data)
 #endif
 	uint32_t icr = E1000_READ_REG(hw, ICR);
 
-#ifdef CONFIG_E1000_NAPI
-	/* read ICR disables interrupts using IAM, so keep up with our
-	 * enable/disable accounting */
-	atomic_inc(&adapter->irq_sem);
-#endif
+	/* in NAPI mode read ICR disables interrupts using IAM */
+
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->get_link_status = 1;
 		/* 80003ES2LAN workaround-- For packet buffer work-around on
@@ -3910,12 +3902,8 @@ e1000_intr(int irq, void *data)
 	             !(icr & E1000_ICR_INT_ASSERTED)))
 		return IRQ_NONE;
 
-	/* Interrupt Auto-Mask...upon reading ICR,
-	 * interrupts are masked.  No need for the
-	 * IMC write, but it does mean we should
-	 * account for it ASAP. */
-	if (likely(hw->mac_type >= e1000_82571))
-		atomic_inc(&adapter->irq_sem);
+	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
+	 * need for the IMC write */
 #endif
 
 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
@@ -3939,7 +3927,6 @@ e1000_intr(int irq, void *data)
 #ifdef CONFIG_E1000_NAPI
 	if (unlikely(hw->mac_type < e1000_82571)) {
 		/* disable interrupts, without the synchronize_irq bit */
-		atomic_inc(&adapter->irq_sem);
 		E1000_WRITE_REG(hw, IMC, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
@@ -3964,10 +3951,8 @@ e1000_intr(int irq, void *data)
 	 * in dead lock. Writing IMC forces 82547 into
 	 * de-assertion state.
 	 */
-	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2) {
-		atomic_inc(&adapter->irq_sem);
+	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
 		E1000_WRITE_REG(hw, IMC, ~0);
-	}
 
 	adapter->total_tx_bytes = 0;
 	adapter->total_rx_bytes = 0;
@@ -4038,7 +4023,7 @@ e1000_clean(struct napi_struct *napi, int budget)
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 e1000_clean_tx_irq(struct e1000_adapter *adapter,
                    struct e1000_tx_ring *tx_ring)
 {
@@ -4049,7 +4034,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 #ifdef CONFIG_E1000_NAPI
 	unsigned int count = 0;
 #endif
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
 
 	i = tx_ring->next_to_clean;
@@ -4057,7 +4042,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
 
 	while (eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) {
-		for (cleaned = FALSE; !cleaned; ) {
+		for (cleaned = false; !cleaned; ) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
@@ -4105,7 +4090,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	if (adapter->detect_tx_hung) {
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
-		adapter->detect_tx_hung = FALSE;
+		adapter->detect_tx_hung = false;
 		if (tx_ring->buffer_info[eop].dma &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
 		               (adapter->tx_timeout_factor * HZ))
@@ -4200,7 +4185,7 @@ e1000_rx_checksum(struct e1000_adapter *adapter,
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 #ifdef CONFIG_E1000_NAPI
 e1000_clean_rx_irq(struct e1000_adapter *adapter,
                    struct e1000_rx_ring *rx_ring,
@@ -4219,7 +4204,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 	uint8_t last_byte;
 	unsigned int i;
 	int cleaned_count = 0;
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 	unsigned int total_rx_bytes=0, total_rx_packets=0;
 
 	i = rx_ring->next_to_clean;
@@ -4247,7 +4232,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		next_buffer = &rx_ring->buffer_info[i];
 
-		cleaned = TRUE;
+		cleaned = true;
 		cleaned_count++;
 		pci_unmap_single(pdev,
 		                 buffer_info->dma,
@@ -4373,7 +4358,7 @@ next_desc:
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 #ifdef CONFIG_E1000_NAPI
 e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
                       struct e1000_rx_ring *rx_ring,
@@ -4393,7 +4378,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 	unsigned int i, j;
 	uint32_t length, staterr;
 	int cleaned_count = 0;
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 	unsigned int total_rx_bytes=0, total_rx_packets=0;
 
 	i = rx_ring->next_to_clean;
@@ -4420,7 +4405,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 
 		next_buffer = &rx_ring->buffer_info[i];
 
-		cleaned = TRUE;
+		cleaned = true;
 		cleaned_count++;
 		pci_unmap_single(pdev, buffer_info->dma,
 				 buffer_info->length,
@@ -5001,7 +4986,8 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t ctrl, rctl;
 
-	e1000_irq_disable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_disable(adapter);
 	adapter->vlgrp = grp;
 
 	if (grp) {
@@ -5038,7 +5024,8 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		}
 	}
 
-	e1000_irq_enable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_enable(adapter);
 }
 
 static void
@@ -5064,9 +5051,11 @@ e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t vfta, index;
 
-	e1000_irq_disable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_disable(adapter);
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-	e1000_irq_enable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_enable(adapter);
 
 	if ((adapter->hw.mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 10af742..365626d 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -41,13 +41,6 @@
 #include <linux/interrupt.h>
 #include <linux/sched.h>
 
-typedef enum {
-#undef FALSE
-    FALSE = 0,
-#undef TRUE
-    TRUE = 1
-} boolean_t;
-
 #ifdef DBG
 #define DEBUGOUT(S)		printk(KERN_DEBUG S "\n")
 #define DEBUGOUT1(S, A...)	printk(KERN_DEBUG S "\n", A)
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 327c062..4bf0c6c 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -167,9 +167,6 @@ struct e1000_adapter {
 
 	spinlock_t tx_queue_lock; /* prevent concurrent tail updates */
 
-	/* this is still needed for 82571 and above */
-	atomic_t irq_sem;
-
 	/* track device up/down/testing state */
 	unsigned long state;
 
@@ -462,7 +459,6 @@ extern s32 e1000e_acquire_nvm(struct e1000_hw *hw);
 extern s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 extern s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw);
 extern s32 e1000e_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg);
-extern s32 e1000e_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 extern s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 extern s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw);
 extern void e1000e_release_nvm(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 95f75a4..073934c 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1852,62 +1852,6 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_read_nvm_spi - Reads EEPROM using SPI
- *  @hw: pointer to the HW structure
- *  @offset: offset of word in the EEPROM to read
- *  @words: number of words to read
- *  @data: word read from the EEPROM
- *
- *  Reads a 16 bit word from the EEPROM.
- **/
-s32 e1000e_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
-{
-	struct e1000_nvm_info *nvm = &hw->nvm;
-	u32 i = 0;
-	s32 ret_val;
-	u16 word_in;
-	u8 read_opcode = NVM_READ_OPCODE_SPI;
-
-	/* A check for invalid values:  offset too large, too many words,
-	 * and not enough words. */
-	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
-	    (words == 0)) {
-		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
-		return -E1000_ERR_NVM;
-	}
-
-	ret_val = nvm->ops.acquire_nvm(hw);
-	if (ret_val)
-		return ret_val;
-
-	ret_val = e1000_ready_nvm_eeprom(hw);
-	if (ret_val) {
-		nvm->ops.release_nvm(hw);
-		return ret_val;
-	}
-
-	e1000_standby_nvm(hw);
-
-	if ((nvm->address_bits == 8) && (offset >= 128))
-		read_opcode |= NVM_A8_OPCODE_SPI;
-
-	/* Send the READ command (opcode + addr) */
-	e1000_shift_out_eec_bits(hw, read_opcode, nvm->opcode_bits);
-	e1000_shift_out_eec_bits(hw, (u16)(offset*2), nvm->address_bits);
-
-	/* Read the data.  SPI NVMs increment the address with each byte
-	 * read and will roll over if reading beyond the end.  This allows
-	 * us to read the whole NVM from any offset */
-	for (i = 0; i < words; i++) {
-		word_in = e1000_shift_in_eec_bits(hw, 16);
-		data[i] = (word_in >> 8) | (word_in << 8);
-	}
-
-	nvm->ops.release_nvm(hw);
-	return 0;
-}
-
-/**
  *  e1000e_read_nvm_eerd - Reads EEPROM using EERD register
  *  @hw: pointer to the HW structure
  *  @offset: offset of word in the EEPROM to read
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index fc5c63f..f501dd5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -836,9 +836,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 icr = er32(ICR);
 
-	/* read ICR disables interrupts using IAM, so keep up with our
-	 * enable/disable accounting */
-	atomic_inc(&adapter->irq_sem);
+	/* read ICR disables interrupts using IAM */
 
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
@@ -868,8 +866,6 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
 		__netif_rx_schedule(netdev, &adapter->napi);
-	} else {
-		atomic_dec(&adapter->irq_sem);
 	}
 
 	return IRQ_HANDLED;
@@ -895,11 +891,8 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	if (!(icr & E1000_ICR_INT_ASSERTED))
 		return IRQ_NONE;
 
-	/* Interrupt Auto-Mask...upon reading ICR,
-	 * interrupts are masked.  No need for the
-	 * IMC write, but it does mean we should
-	 * account for it ASAP. */
-	atomic_inc(&adapter->irq_sem);
+	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
+	 * need for the IMC write */
 
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
@@ -931,8 +924,6 @@ static irqreturn_t e1000_intr(int irq, void *data)
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
 		__netif_rx_schedule(netdev, &adapter->napi);
-	} else {
-		atomic_dec(&adapter->irq_sem);
 	}
 
 	return IRQ_HANDLED;
@@ -983,7 +974,6 @@ static void e1000_irq_disable(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 
-	atomic_inc(&adapter->irq_sem);
 	ew32(IMC, ~0);
 	e1e_flush();
 	synchronize_irq(adapter->pdev->irq);
@@ -996,10 +986,8 @@ static void e1000_irq_enable(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (atomic_dec_and_test(&adapter->irq_sem)) {
-		ew32(IMS, IMS_ENABLE_MASK);
-		e1e_flush();
-	}
+	ew32(IMS, IMS_ENABLE_MASK);
+	e1e_flush();
 }
 
 /**
@@ -1427,9 +1415,12 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 vfta, index;
 
-	e1000_irq_disable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->state))
+		e1000_irq_disable(adapter);
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-	e1000_irq_enable(adapter);
+
+	if (!test_bit(__E1000_DOWN, &adapter->state))
+		e1000_irq_enable(adapter);
 
 	if ((adapter->hw.mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
@@ -1480,7 +1471,8 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl, rctl;
 
-	e1000_irq_disable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->state))
+		e1000_irq_disable(adapter);
 	adapter->vlgrp = grp;
 
 	if (grp) {
@@ -1517,7 +1509,8 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 		}
 	}
 
-	e1000_irq_enable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->state))
+		e1000_irq_enable(adapter);
 }
 
 static void e1000_restore_vlan(struct e1000_adapter *adapter)
@@ -2167,7 +2160,6 @@ void e1000e_down(struct e1000_adapter *adapter)
 	msleep(10);
 
 	napi_disable(&adapter->napi);
-	atomic_set(&adapter->irq_sem, 0);
 	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->watchdog_timer);
@@ -2227,7 +2219,6 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	spin_lock_init(&adapter->tx_queue_lock);
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */
-	atomic_set(&adapter->irq_sem, 0);
 	e1000_irq_disable(adapter);
 
 	spin_lock_init(&adapter->stats_lock);
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 6f7e3fd..0272afb 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3859,7 +3859,8 @@ static void nv_do_stats_poll(unsigned long data)
 	nv_get_hw_stats(dev);
 
 	if (!np->in_shutdown)
-		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
+		mod_timer(&np->stats_poll,
+			round_jiffies(jiffies + STATS_INTERVAL));
 }
 
 static void nv_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -5063,7 +5064,8 @@ static int nv_open(struct net_device *dev)
 
 	/* start statistics timer */
 	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2))
-		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
+		mod_timer(&np->stats_poll,
+			round_jiffies(jiffies + STATS_INTERVAL));
 
 	spin_unlock_irq(&np->lock);
 
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 718cf77..601f93e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1185,7 +1185,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	int frame_size = new_mtu + ETH_HLEN;
 
 	if (priv->vlan_enable)
-		frame_size += VLAN_ETH_HLEN;
+		frame_size += VLAN_HLEN;
 
 	if (gfar_uses_fcb(priv))
 		frame_size += GMAC_FCB_LEN;
@@ -1299,11 +1299,11 @@ static irqreturn_t gfar_transmit(int irq, void *dev_id)
 
 	/* If we are coalescing the interrupts, reset the timer */
 	/* Otherwise, clear it */
-	if (priv->txcoalescing)
+	if (likely(priv->txcoalescing)) {
+		gfar_write(&priv->regs->txic, 0);
 		gfar_write(&priv->regs->txic,
 			   mk_ic_value(priv->txcount, priv->txtime));
-	else
-		gfar_write(&priv->regs->txic, 0);
+	}
 
 	spin_unlock(&priv->txlock);
 
@@ -1417,11 +1417,11 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 
 	/* If we are coalescing interrupts, update the timer */
 	/* Otherwise, clear it */
-	if (priv->rxcoalescing)
+	if (likely(priv->rxcoalescing)) {
+		gfar_write(&priv->regs->rxic, 0);
 		gfar_write(&priv->regs->rxic,
 			   mk_ic_value(priv->rxcount, priv->rxtime));
-	else
-		gfar_write(&priv->regs->rxic, 0);
+	}
 
 	spin_unlock_irqrestore(&priv->rxlock, flags);
 #endif
@@ -1526,9 +1526,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 		rmb();
 		skb = priv->rx_skbuff[priv->skb_currx];
 
-		if (!(bdp->status &
-		      (RXBD_LARGE | RXBD_SHORT | RXBD_NONOCTET
-		       | RXBD_CRCERR | RXBD_OVERRUN | RXBD_TRUNCATED))) {
+		if ((bdp->status & RXBD_LAST) && !(bdp->status & RXBD_ERR)) {
 			/* Increment the number of packets */
 			dev->stats.rx_packets++;
 			howmany++;
@@ -1595,11 +1593,11 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
 		/* If we are coalescing interrupts, update the timer */
 		/* Otherwise, clear it */
-		if (priv->rxcoalescing)
+		if (likely(priv->rxcoalescing)) {
+			gfar_write(&priv->regs->rxic, 0);
 			gfar_write(&priv->regs->rxic,
 				   mk_ic_value(priv->rxcount, priv->rxtime));
-		else
-			gfar_write(&priv->regs->rxic, 0);
+		}
 	}
 
 	return howmany;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 46cd773..ea8671f 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -102,7 +102,7 @@ extern const char gfar_driver_version[];
 #define DEFAULT_FIFO_TX_STARVE 0x40
 #define DEFAULT_FIFO_TX_STARVE_OFF 0x80
 #define DEFAULT_BD_STASH 1
-#define DEFAULT_STASH_LENGTH	64
+#define DEFAULT_STASH_LENGTH	96
 #define DEFAULT_STASH_INDEX	0
 
 /* The number of Exact Match registers */
@@ -124,11 +124,11 @@ extern const char gfar_driver_version[];
 
 #define DEFAULT_TX_COALESCE 1
 #define DEFAULT_TXCOUNT	16
-#define DEFAULT_TXTIME	4
+#define DEFAULT_TXTIME	21
 
 #define DEFAULT_RX_COALESCE 1
 #define DEFAULT_RXCOUNT	16
-#define DEFAULT_RXTIME	4
+#define DEFAULT_RXTIME	21
 
 #define TBIPA_VALUE		0x1f
 #define MIIMCFG_INIT_VALUE	0x00000007
@@ -340,6 +340,9 @@ extern const char gfar_driver_version[];
 #define RXBD_OVERRUN		0x0002
 #define RXBD_TRUNCATED		0x0001
 #define RXBD_STATS		0x01ff
+#define RXBD_ERR		(RXBD_LARGE | RXBD_SHORT | RXBD_NONOCTET 	\
+				| RXBD_CRCERR | RXBD_OVERRUN			\
+				| RXBD_TRUNCATED)
 
 /* Rx FCB status field bits */
 #define RXFCB_VLN		0x8000
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 57772be..bb31e09 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1259,26 +1259,7 @@ static void ibmveth_proc_unregister_driver(void)
 	remove_proc_entry(IBMVETH_PROC_DIR, init_net.proc_net);
 }
 
-static void *ibmveth_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	if (*pos == 0) {
-		return (void *)1;
-	} else {
-		return NULL;
-	}
-}
-
-static void *ibmveth_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	++*pos;
-	return NULL;
-}
-
-static void ibmveth_seq_stop(struct seq_file *seq, void *v)
-{
-}
-
-static int ibmveth_seq_show(struct seq_file *seq, void *v)
+static int ibmveth_show(struct seq_file *seq, void *v)
 {
 	struct ibmveth_adapter *adapter = seq->private;
 	char *current_mac = ((char*) &adapter->netdev->dev_addr);
@@ -1302,27 +1283,10 @@ static int ibmveth_seq_show(struct seq_file *seq, void *v)
 
 	return 0;
 }
-static struct seq_operations ibmveth_seq_ops = {
-	.start = ibmveth_seq_start,
-	.next  = ibmveth_seq_next,
-	.stop  = ibmveth_seq_stop,
-	.show  = ibmveth_seq_show,
-};
 
 static int ibmveth_proc_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	struct proc_dir_entry *proc;
-	int rc;
-
-	rc = seq_open(file, &ibmveth_seq_ops);
-	if (!rc) {
-		/* recover the pointer buried in proc_dir_entry data */
-		seq = file->private_data;
-		proc = PDE(inode);
-		seq->private = proc->data;
-	}
-	return rc;
+	return single_open(file, ibmveth_show, PDE(inode)->data);
 }
 
 static const struct file_operations ibmveth_proc_fops = {
@@ -1330,7 +1294,7 @@ static const struct file_operations ibmveth_proc_fops = {
 	.open    = ibmveth_proc_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = single_release,
 };
 
 static void ibmveth_proc_register_adapter(struct ibmveth_adapter *adapter)
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 3d2e721..f2fff90 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -158,7 +158,6 @@ struct ixgb_adapter {
 	uint16_t link_speed;
 	uint16_t link_duplex;
 	spinlock_t tx_lock;
-	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;
 
 	struct timer_list blink_timer;
@@ -173,15 +172,15 @@ struct ixgb_adapter {
 	uint64_t hw_csum_tx_error;
 	uint32_t tx_int_delay;
 	uint32_t tx_timeout_count;
-	boolean_t tx_int_delay_enable;
-	boolean_t detect_tx_hung;
+	bool tx_int_delay_enable;
+	bool detect_tx_hung;
 
 	/* RX */
 	struct ixgb_desc_ring rx_ring;
 	uint64_t hw_csum_rx_error;
 	uint64_t hw_csum_rx_good;
 	uint32_t rx_int_delay;
-	boolean_t rx_csum;
+	bool rx_csum;
 
 	/* OS defined structs */
 	struct napi_struct napi;
@@ -194,7 +193,16 @@ struct ixgb_adapter {
 	u16 msg_enable;
 	struct ixgb_hw_stats stats;
 	uint32_t alloc_rx_buff_failed;
-	boolean_t have_msi;
+	bool have_msi;
+	unsigned long flags;
+};
+
+enum ixgb_state_t {
+	/* TBD
+	__IXGB_TESTING,
+	__IXGB_RESETTING,
+	*/
+	__IXGB_DOWN
 };
 
 /* Exported from other modules */
@@ -203,4 +211,14 @@ extern void ixgb_set_ethtool_ops(struct net_device *netdev);
 extern char ixgb_driver_name[];
 extern const char ixgb_driver_version[];
 
+extern int ixgb_up(struct ixgb_adapter *adapter);
+extern void ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog);
+extern void ixgb_reset(struct ixgb_adapter *adapter);
+extern int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
+extern int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_update_stats(struct ixgb_adapter *adapter);
+
+
 #endif /* _IXGB_H_ */
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index e8eb0fd..8e9302f 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -36,7 +36,7 @@ static void ixgb_shift_out_bits(struct ixgb_hw *hw,
 				uint16_t count);
 static void ixgb_standby_eeprom(struct ixgb_hw *hw);
 
-static boolean_t ixgb_wait_eeprom_command(struct ixgb_hw *hw);
+static bool ixgb_wait_eeprom_command(struct ixgb_hw *hw);
 
 static void ixgb_cleanup_eeprom(struct ixgb_hw *hw);
 
@@ -279,10 +279,10 @@ ixgb_cleanup_eeprom(struct ixgb_hw *hw)
  * The command is done when the EEPROM's data out pin goes high.
  *
  * Returns:
- *      TRUE: EEPROM data pin is high before timeout.
- *      FALSE:  Time expired.
+ *      true: EEPROM data pin is high before timeout.
+ *      false:  Time expired.
  *****************************************************************************/
-static boolean_t
+static bool
 ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
@@ -301,12 +301,12 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
 		if(eecd_reg & IXGB_EECD_DO)
-			return (TRUE);
+			return (true);
 
 		udelay(50);
 	}
 	ASSERT(0);
-	return (FALSE);
+	return (false);
 }
 
 /******************************************************************************
@@ -319,10 +319,10 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
  * valid.
  *
  * Returns:
- *  TRUE: Checksum is valid
- *  FALSE: Checksum is not valid.
+ *  true: Checksum is valid
+ *  false: Checksum is not valid.
  *****************************************************************************/
-boolean_t
+bool
 ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 {
 	uint16_t checksum = 0;
@@ -332,9 +332,9 @@ ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 		checksum += ixgb_read_eeprom(hw, i);
 
 	if(checksum == (uint16_t) EEPROM_SUM)
-		return (TRUE);
+		return (true);
 	else
-		return (FALSE);
+		return (false);
 }
 
 /******************************************************************************
@@ -457,10 +457,10 @@ ixgb_read_eeprom(struct ixgb_hw *hw,
  * hw - Struct containing variables accessed by shared code
  *
  * Returns:
- *      TRUE: if eeprom read is successful
- *      FALSE: otherwise.
+ *      true: if eeprom read is successful
+ *      false: otherwise.
  *****************************************************************************/
-boolean_t
+bool
 ixgb_get_eeprom_data(struct ixgb_hw *hw)
 {
 	uint16_t i;
@@ -484,16 +484,16 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 		/* clear the init_ctrl_reg_1 to signify that the cache is
 		 * invalidated */
 		ee_map->init_ctrl_reg_1 = cpu_to_le16(EEPROM_ICW1_SIGNATURE_CLEAR);
-		return (FALSE);
+		return (false);
 	}
 
 	if ((ee_map->init_ctrl_reg_1 & cpu_to_le16(EEPROM_ICW1_SIGNATURE_MASK))
 		 != cpu_to_le16(EEPROM_ICW1_SIGNATURE_VALID)) {
 		DEBUGOUT("ixgb_ee: Signature invalid.\n");
-		return(FALSE);
+		return(false);
 	}
 
-	return(TRUE);
+	return(true);
 }
 
 /******************************************************************************
@@ -503,17 +503,17 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
  * hw - Struct containing variables accessed by shared code
  *
  * Returns:
- *      TRUE: eeprom signature was good and the eeprom read was successful
- *      FALSE: otherwise.
+ *      true: eeprom signature was good and the eeprom read was successful
+ *      false: otherwise.
  ******************************************************************************/
-static boolean_t
+static bool
 ixgb_check_and_get_eeprom_data (struct ixgb_hw* hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if ((ee_map->init_ctrl_reg_1 & cpu_to_le16(EEPROM_ICW1_SIGNATURE_MASK))
 	    == cpu_to_le16(EEPROM_ICW1_SIGNATURE_VALID)) {
-		return (TRUE);
+		return (true);
 	} else {
 		return ixgb_get_eeprom_data(hw);
 	}
@@ -533,7 +533,7 @@ ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index)
 {
 
 	if ((index < IXGB_EEPROM_SIZE) &&
-		(ixgb_check_and_get_eeprom_data(hw) == TRUE)) {
+		(ixgb_check_and_get_eeprom_data(hw) == true)) {
 	   return(hw->eeprom[index]);
 	}
 
@@ -557,7 +557,7 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
 
 	DEBUGFUNC("ixgb_get_ee_mac_addr");
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE) {
+	if (ixgb_check_and_get_eeprom_data(hw) == true) {
 		for (i = 0; i < IXGB_ETH_LENGTH_OF_ADDRESS; i++) {
 			mac_addr[i] = ee_map->mac_addr[i];
 			DEBUGOUT2("mac(%d) = %.2X\n", i, mac_addr[i]);
@@ -577,7 +577,7 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
 uint32_t
 ixgb_get_ee_pba_number(struct ixgb_hw *hw)
 {
-	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+	if (ixgb_check_and_get_eeprom_data(hw) == true)
 		return (le16_to_cpu(hw->eeprom[EEPROM_PBA_1_2_REG])
 			| (le16_to_cpu(hw->eeprom[EEPROM_PBA_3_4_REG])<<16));
 
@@ -598,7 +598,7 @@ ixgb_get_ee_device_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+	if (ixgb_check_and_get_eeprom_data(hw) == true)
 		return (le16_to_cpu(ee_map->device_id));
 
 	return (0);
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ixgb/ixgb_ee.h
index 7908bf3..da62f58 100644
--- a/drivers/net/ixgb/ixgb_ee.h
+++ b/drivers/net/ixgb/ixgb_ee.h
@@ -97,7 +97,7 @@ struct ixgb_ee_map_type {
 /* EEPROM Functions */
 uint16_t ixgb_read_eeprom(struct ixgb_hw *hw, uint16_t reg);
 
-boolean_t ixgb_validate_eeprom_checksum(struct ixgb_hw *hw);
+bool ixgb_validate_eeprom_checksum(struct ixgb_hw *hw);
 
 void ixgb_update_eeprom_checksum(struct ixgb_hw *hw);
 
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 75f3a68..45ddf80 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -32,15 +32,6 @@
 
 #include <asm/uaccess.h>
 
-extern int ixgb_up(struct ixgb_adapter *adapter);
-extern void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
-extern void ixgb_reset(struct ixgb_adapter *adapter);
-extern int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
-extern int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
-extern void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
-extern void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
-extern void ixgb_update_stats(struct ixgb_adapter *adapter);
-
 #define IXGB_ALL_RAR_ENTRIES 16
 
 struct ixgb_stats {
@@ -136,7 +127,7 @@ ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		return -EINVAL;
 	
 	if(netif_running(adapter->netdev)) {
-		ixgb_down(adapter, TRUE);
+		ixgb_down(adapter, true);
 		ixgb_reset(adapter);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
@@ -185,7 +176,7 @@ ixgb_set_pauseparam(struct net_device *netdev,
 		hw->fc.type = ixgb_fc_none;
 
 	if(netif_running(adapter->netdev)) {
-		ixgb_down(adapter, TRUE);
+		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
 	} else
@@ -210,7 +201,7 @@ ixgb_set_rx_csum(struct net_device *netdev, uint32_t data)
 	adapter->rx_csum = data;
 
 	if(netif_running(netdev)) {
-		ixgb_down(adapter,TRUE);
+		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 		ixgb_set_speed_duplex(netdev);
 	} else
@@ -570,7 +561,7 @@ ixgb_set_ringparam(struct net_device *netdev,
 		return -EINVAL;
 
 	if(netif_running(adapter->netdev))
-		ixgb_down(adapter,TRUE);
+		ixgb_down(adapter, true);
 
 	rxdr->count = max(ring->rx_pending,(uint32_t)MIN_RXD);
 	rxdr->count = min(rxdr->count,(uint32_t)MAX_RXD);
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 80a8b98..8a04bbd 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -41,7 +41,7 @@ static void ixgb_mta_set(struct ixgb_hw *hw, uint32_t hash_value);
 
 static void ixgb_get_bus_info(struct ixgb_hw *hw);
 
-static boolean_t ixgb_link_reset(struct ixgb_hw *hw);
+static bool ixgb_link_reset(struct ixgb_hw *hw);
 
 static void ixgb_optics_reset(struct ixgb_hw *hw);
 
@@ -60,9 +60,9 @@ static uint16_t ixgb_read_phy_reg(struct ixgb_hw *hw,
 				  uint32_t phy_address,
 				  uint32_t device_type);
 
-static boolean_t ixgb_setup_fc(struct ixgb_hw *hw);
+static bool ixgb_setup_fc(struct ixgb_hw *hw);
 
-static boolean_t mac_addr_valid(uint8_t *mac_addr);
+static bool mac_addr_valid(uint8_t *mac_addr);
 
 static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
 {
@@ -114,7 +114,7 @@ static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-boolean_t
+bool
 ixgb_adapter_stop(struct ixgb_hw *hw)
 {
 	uint32_t ctrl_reg;
@@ -127,13 +127,13 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	 */
 	if(hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is already stopped!!!\n");
-		return FALSE;
+		return false;
 	}
 
 	/* Set the Adapter Stopped flag so other driver functions stop
 	 * touching the Hardware.
 	 */
-	hw->adapter_stopped = TRUE;
+	hw->adapter_stopped = true;
 
 	/* Clear interrupt mask to stop board from generating interrupts */
 	DEBUGOUT("Masking off all interrupts\n");
@@ -286,15 +286,15 @@ ixgb_identify_phy(struct ixgb_hw *hw)
  * Leaves the transmit and receive units disabled and uninitialized.
  *
  * Returns:
- *      TRUE if successful,
- *      FALSE if unrecoverable problems were encountered.
+ *      true if successful,
+ *      false if unrecoverable problems were encountered.
  *****************************************************************************/
-boolean_t
+bool
 ixgb_init_hw(struct ixgb_hw *hw)
 {
 	uint32_t i;
 	uint32_t ctrl_reg;
-	boolean_t status;
+	bool status;
 
 	DEBUGFUNC("ixgb_init_hw");
 
@@ -318,9 +318,8 @@ ixgb_init_hw(struct ixgb_hw *hw)
 	/* Delay a few ms just to allow the reset to complete */
 	msleep(IXGB_DELAY_AFTER_EE_RESET);
 
-	if (ixgb_get_eeprom_data(hw) == FALSE) {
-		return(FALSE);
-	}
+	if (!ixgb_get_eeprom_data(hw))
+		return false;
 
 	/* Use the device id to determine the type of phy/transceiver. */
 	hw->device_id = ixgb_get_ee_device_id(hw);
@@ -337,11 +336,11 @@ ixgb_init_hw(struct ixgb_hw *hw)
 	 */
 	if (!mac_addr_valid(hw->curr_mac_addr)) {
 		DEBUGOUT("MAC address invalid after ixgb_init_rx_addrs\n");
-		return(FALSE);
+		return(false);
 	}
 
 	/* tell the routines in this file they can access hardware again */
-	hw->adapter_stopped = FALSE;
+	hw->adapter_stopped = false;
 
 	/* Fill in the bus_info structure */
 	ixgb_get_bus_info(hw);
@@ -661,12 +660,12 @@ ixgb_clear_vfta(struct ixgb_hw *hw)
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
 
-static boolean_t
+static bool
 ixgb_setup_fc(struct ixgb_hw *hw)
 {
 	uint32_t ctrl_reg;
 	uint32_t pap_reg = 0;   /* by default, assume no pause time */
-	boolean_t status = TRUE;
+	bool status = true;
 
 	DEBUGFUNC("ixgb_setup_fc");
 
@@ -950,7 +949,7 @@ ixgb_check_for_link(struct ixgb_hw *hw)
 
 	if ((xpcss_reg & IXGB_XPCSS_ALIGN_STATUS) &&
 	    (status_reg & IXGB_STATUS_LU)) {
-		hw->link_up = TRUE;
+		hw->link_up = true;
 	} else if (!(xpcss_reg & IXGB_XPCSS_ALIGN_STATUS) &&
 		   (status_reg & IXGB_STATUS_LU)) {
 		DEBUGOUT("XPCSS Not Aligned while Status:LU is set.\n");
@@ -974,10 +973,10 @@ ixgb_check_for_link(struct ixgb_hw *hw)
  *
  * Called by any function that needs to check the link status of the adapter.
  *****************************************************************************/
-boolean_t ixgb_check_for_bad_link(struct ixgb_hw *hw)
+bool ixgb_check_for_bad_link(struct ixgb_hw *hw)
 {
 	uint32_t newLFC, newRFC;
-	boolean_t bad_link_returncode = FALSE;
+	bool bad_link_returncode = false;
 
 	if (hw->phy_type == ixgb_phy_type_txn17401) {
 		newLFC = IXGB_READ_REG(hw, LFC);
@@ -986,7 +985,7 @@ boolean_t ixgb_check_for_bad_link(struct ixgb_hw *hw)
 		    || (hw->lastRFC + 250 < newRFC)) {
 			DEBUGOUT
 			    ("BAD LINK! too many LFC/RFC since last check\n");
-			bad_link_returncode = TRUE;
+			bad_link_returncode = true;
 		}
 		hw->lastLFC = newLFC;
 		hw->lastRFC = newRFC;
@@ -1155,21 +1154,21 @@ ixgb_get_bus_info(struct ixgb_hw *hw)
  * mac_addr - pointer to MAC address.
  *
  *****************************************************************************/
-static boolean_t
+static bool
 mac_addr_valid(uint8_t *mac_addr)
 {
-	boolean_t is_valid = TRUE;
+	bool is_valid = true;
 	DEBUGFUNC("mac_addr_valid");
 
 	/* Make sure it is not a multicast address */
 	if (IS_MULTICAST(mac_addr)) {
 		DEBUGOUT("MAC address is multicast\n");
-		is_valid = FALSE;
+		is_valid = false;
 	}
 	/* Not a broadcast address */
 	else if (IS_BROADCAST(mac_addr)) {
 		DEBUGOUT("MAC address is broadcast\n");
-		is_valid = FALSE;
+		is_valid = false;
 	}
 	/* Reject the zero address */
 	else if (mac_addr[0] == 0 &&
@@ -1179,7 +1178,7 @@ mac_addr_valid(uint8_t *mac_addr)
 			 mac_addr[4] == 0 &&
 			 mac_addr[5] == 0) {
 		DEBUGOUT("MAC address is all zeros\n");
-		is_valid = FALSE;
+		is_valid = false;
 	}
 	return (is_valid);
 }
@@ -1190,10 +1189,10 @@ mac_addr_valid(uint8_t *mac_addr)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static boolean_t
+static bool
 ixgb_link_reset(struct ixgb_hw *hw)
 {
-	boolean_t link_status = FALSE;
+	bool link_status = false;
 	uint8_t wait_retries = MAX_RESET_ITERATIONS;
 	uint8_t lrst_retries = MAX_RESET_ITERATIONS;
 
@@ -1208,7 +1207,7 @@ ixgb_link_reset(struct ixgb_hw *hw)
 			link_status =
 			    ((IXGB_READ_REG(hw, STATUS) & IXGB_STATUS_LU)
 			     && (IXGB_READ_REG(hw, XPCSS) &
-				 IXGB_XPCSS_ALIGN_STATUS)) ? TRUE : FALSE;
+				 IXGB_XPCSS_ALIGN_STATUS)) ? true : false;
 		} while (!link_status && --wait_retries);
 
 	} while (!link_status && --lrst_retries);
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index 4f176ff..d4e9566 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -650,7 +650,7 @@ struct ixgb_flash_buffer {
  * This is a little-endian specific check.
  */
 #define IS_MULTICAST(Address) \
-    (boolean_t)(((uint8_t *)(Address))[0] & ((uint8_t)0x01))
+    (bool)(((uint8_t *)(Address))[0] & ((uint8_t)0x01))
 
 /*
  * Check whether an address is broadcast.
@@ -663,7 +663,7 @@ struct ixgb_fc {
 	uint32_t high_water;	/* Flow Control High-water          */
 	uint32_t low_water;	/* Flow Control Low-water           */
 	uint16_t pause_time;	/* Flow Control Pause timer         */
-	boolean_t send_xon;	/* Flow control send XON            */
+	bool send_xon;		/* Flow control send XON            */
 	ixgb_fc_type type;	/* Type of flow control             */
 };
 
@@ -700,8 +700,8 @@ struct ixgb_hw {
 	uint32_t num_tx_desc;	/* Number of Transmit descriptors   */
 	uint32_t num_rx_desc;	/* Number of Receive descriptors    */
 	uint32_t rx_buffer_size;	/* Size of Receive buffer           */
-	boolean_t link_up;	/* TRUE if link is valid            */
-	boolean_t adapter_stopped;	/* State of adapter                 */
+	bool link_up;		/* true if link is valid            */
+	bool adapter_stopped;	/* State of adapter                 */
 	uint16_t device_id;	/* device id from PCI configuration space */
 	uint16_t vendor_id;	/* vendor id from PCI configuration space */
 	uint8_t revision_id;	/* revision id from PCI configuration space */
@@ -783,11 +783,11 @@ struct ixgb_hw_stats {
 };
 
 /* Function Prototypes */
-extern boolean_t ixgb_adapter_stop(struct ixgb_hw *hw);
-extern boolean_t ixgb_init_hw(struct ixgb_hw *hw);
-extern boolean_t ixgb_adapter_start(struct ixgb_hw *hw);
+extern bool ixgb_adapter_stop(struct ixgb_hw *hw);
+extern bool ixgb_init_hw(struct ixgb_hw *hw);
+extern bool ixgb_adapter_start(struct ixgb_hw *hw);
 extern void ixgb_check_for_link(struct ixgb_hw *hw);
-extern boolean_t ixgb_check_for_bad_link(struct ixgb_hw *hw);
+extern bool ixgb_check_for_bad_link(struct ixgb_hw *hw);
 
 extern void ixgb_rar_set(struct ixgb_hw *hw,
 				uint8_t *addr,
@@ -809,7 +809,7 @@ extern void ixgb_write_vfta(struct ixgb_hw *hw,
 void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t *mac_addr);
 uint32_t ixgb_get_ee_pba_number(struct ixgb_hw *hw);
 uint16_t ixgb_get_ee_device_id(struct ixgb_hw *hw);
-boolean_t ixgb_get_eeprom_data(struct ixgb_hw *hw);
+bool ixgb_get_eeprom_data(struct ixgb_hw *hw);
 __le16 ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index);
 
 /* Everything else */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 269e6f8..9c9bf31 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -67,7 +67,7 @@ MODULE_DEVICE_TABLE(pci, ixgb_pci_tbl);
 /* Local Function Prototypes */
 
 int ixgb_up(struct ixgb_adapter *adapter);
-void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
+void ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog);
 void ixgb_reset(struct ixgb_adapter *adapter);
 int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
 int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
@@ -94,14 +94,14 @@ static struct net_device_stats *ixgb_get_stats(struct net_device *netdev);
 static int ixgb_change_mtu(struct net_device *netdev, int new_mtu);
 static int ixgb_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t ixgb_intr(int irq, void *data);
-static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
+static bool ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
 
 #ifdef CONFIG_IXGB_NAPI
 static int ixgb_clean(struct napi_struct *napi, int budget);
-static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
-				   int *work_done, int work_to_do);
+static bool ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
+			      int *work_done, int work_to_do);
 #else
-static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
+static bool ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
 #endif
 static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter);
 static void ixgb_tx_timeout(struct net_device *dev);
@@ -197,7 +197,6 @@ module_exit(ixgb_exit_module);
 static void
 ixgb_irq_disable(struct ixgb_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 	IXGB_WRITE_FLUSH(&adapter->hw);
 	synchronize_irq(adapter->pdev->irq);
@@ -211,14 +210,12 @@ ixgb_irq_disable(struct ixgb_adapter *adapter)
 static void
 ixgb_irq_enable(struct ixgb_adapter *adapter)
 {
-	if(atomic_dec_and_test(&adapter->irq_sem)) {
-		u32 val = IXGB_INT_RXT0 | IXGB_INT_RXDMT0 |
-			  IXGB_INT_TXDW | IXGB_INT_LSC;
-		if (adapter->hw.subsystem_vendor_id == SUN_SUBVENDOR_ID)
-			val |= IXGB_INT_GPI0;
-		IXGB_WRITE_REG(&adapter->hw, IMS, val);
-		IXGB_WRITE_FLUSH(&adapter->hw);
-	}
+	u32 val = IXGB_INT_RXT0 | IXGB_INT_RXDMT0 |
+		  IXGB_INT_TXDW | IXGB_INT_LSC;
+	if (adapter->hw.subsystem_vendor_id == SUN_SUBVENDOR_ID)
+		val |= IXGB_INT_GPI0;
+	IXGB_WRITE_REG(&adapter->hw, IMS, val);
+	IXGB_WRITE_FLUSH(&adapter->hw);
 }
 
 int
@@ -283,26 +280,30 @@ ixgb_up(struct ixgb_adapter *adapter)
 		}
 	}
 
-	mod_timer(&adapter->watchdog_timer, jiffies);
+	clear_bit(__IXGB_DOWN, &adapter->flags);
 
 #ifdef CONFIG_IXGB_NAPI
 	napi_enable(&adapter->napi);
 #endif
 	ixgb_irq_enable(adapter);
 
+	mod_timer(&adapter->watchdog_timer, jiffies);
+
 	return 0;
 }
 
 void
-ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
+ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog)
 {
 	struct net_device *netdev = adapter->netdev;
 
+	/* prevent the interrupt handler from restarting watchdog */
+	set_bit(__IXGB_DOWN, &adapter->flags);
+
 #ifdef CONFIG_IXGB_NAPI
 	napi_disable(&adapter->napi);
-	atomic_set(&adapter->irq_sem, 0);
 #endif
-
+	/* waiting for NAPI to complete can re-enable interrupts */
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
 
@@ -589,9 +590,9 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	/* enable flow control to be programmed */
 	hw->fc.send_xon = 1;
 
-	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->tx_lock);
 
+	set_bit(__IXGB_DOWN, &adapter->flags);
 	return 0;
 }
 
@@ -656,7 +657,7 @@ ixgb_close(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	ixgb_down(adapter, TRUE);
+	ixgb_down(adapter, true);
 
 	ixgb_free_tx_resources(adapter);
 	ixgb_free_rx_resources(adapter);
@@ -881,7 +882,7 @@ ixgb_configure_rx(struct ixgb_adapter *adapter)
 	IXGB_WRITE_REG(hw, RXDCTL, rxdctl);
 
 	/* Enable Receive Checksum Offload for TCP and UDP */
-	if(adapter->rx_csum == TRUE) {
+	if (adapter->rx_csum) {
 		rxcsum = IXGB_READ_REG(hw, RXCSUM);
 		rxcsum |= IXGB_RXCSUM_TUOFL;
 		IXGB_WRITE_REG(hw, RXCSUM, rxcsum);
@@ -1164,7 +1165,7 @@ ixgb_watchdog(unsigned long data)
 	}
 
 	/* Force detection of hung controller every watchdog period */
-	adapter->detect_tx_hung = TRUE;
+	adapter->detect_tx_hung = true;
 
 	/* generate an interrupt to force clean up of any stragglers */
 	IXGB_WRITE_REG(&adapter->hw, ICS, IXGB_INT_TXDW);
@@ -1243,7 +1244,7 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 	return 0;
 }
 
-static boolean_t
+static bool
 ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
 	struct ixgb_context_desc *context_desc;
@@ -1275,10 +1276,10 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
-		return TRUE;
+		return true;
 	}
 
-	return FALSE;
+	return false;
 }
 
 #define IXGB_MAX_TXD_PWR	14
@@ -1464,14 +1465,18 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	int vlan_id = 0;
 	int tso;
 
+	if (test_bit(__IXGB_DOWN, &adapter->flags)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
 	if(skb->len <= 0) {
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
 
 #ifdef NETIF_F_LLTX
-	local_irq_save(flags);
-	if (!spin_trylock(&adapter->tx_lock)) {
+	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
 		/* Collision - tell upper layer to requeue */
 		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
@@ -1548,7 +1553,7 @@ ixgb_tx_timeout_task(struct work_struct *work)
 		container_of(work, struct ixgb_adapter, tx_timeout_task);
 
 	adapter->tx_timeout_count++;
-	ixgb_down(adapter, TRUE);
+	ixgb_down(adapter, true);
 	ixgb_up(adapter);
 }
 
@@ -1595,7 +1600,7 @@ ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 	netdev->mtu = new_mtu;
 
 	if ((old_max_frame != max_frame) && netif_running(netdev)) {
-		ixgb_down(adapter, TRUE);
+		ixgb_down(adapter, true);
 		ixgb_up(adapter);
 	}
 
@@ -1753,9 +1758,9 @@ ixgb_intr(int irq, void *data)
 	if(unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
 
-	if(unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC))) {
-		mod_timer(&adapter->watchdog_timer, jiffies);
-	}
+	if (unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC)))
+		if (!test_bit(__IXGB_DOWN, &adapter->flags))
+			mod_timer(&adapter->watchdog_timer, jiffies);
 
 #ifdef CONFIG_IXGB_NAPI
 	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
@@ -1764,7 +1769,6 @@ ixgb_intr(int irq, void *data)
 		  of the posted write is intentionally left out.
 		*/
 
-		atomic_inc(&adapter->irq_sem);
 		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 		__netif_rx_schedule(netdev, &adapter->napi);
 	}
@@ -1812,7 +1816,7 @@ ixgb_clean(struct napi_struct *napi, int budget)
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
@@ -1820,7 +1824,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 	struct ixgb_tx_desc *tx_desc, *eop_desc;
 	struct ixgb_buffer *buffer_info;
 	unsigned int i, eop;
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
@@ -1828,7 +1832,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 
 	while(eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
-		for(cleaned = FALSE; !cleaned; ) {
+		for (cleaned = false; !cleaned; ) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 
@@ -1862,7 +1866,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 	if(adapter->detect_tx_hung) {
 		/* detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
-		adapter->detect_tx_hung = FALSE;
+		adapter->detect_tx_hung = false;
 		if (tx_ring->buffer_info[eop].dma &&
 		   time_after(jiffies, tx_ring->buffer_info[eop].time_stamp + HZ)
 		   && !(IXGB_READ_REG(&adapter->hw, STATUS) &
@@ -1932,7 +1936,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
  * @adapter: board private structure
  **/
 
-static boolean_t
+static bool
 #ifdef CONFIG_IXGB_NAPI
 ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 #else
@@ -1946,7 +1950,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 	struct ixgb_buffer *buffer_info, *next_buffer, *next2_buffer;
 	uint32_t length;
 	unsigned int i, j;
-	boolean_t cleaned = FALSE;
+	bool cleaned = false;
 
 	i = rx_ring->next_to_clean;
 	rx_desc = IXGB_RX_DESC(*rx_ring, i);
@@ -1980,7 +1984,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		next_skb = next_buffer->skb;
 		prefetch(next_skb);
 
-		cleaned = TRUE;
+		cleaned = true;
 
 		pci_unmap_single(pdev,
 				 buffer_info->dma,
@@ -2195,7 +2199,9 @@ ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
 	}
 
-	ixgb_irq_enable(adapter);
+	/* don't enable interrupts unless we are UP */
+	if (adapter->netdev->flags & IFF_UP)
+		ixgb_irq_enable(adapter);
 }
 
 static void
@@ -2222,9 +2228,11 @@ ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
 
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
 
-	ixgb_irq_enable(adapter);
+	/* don't enable interrupts unless we are UP */
+	if (adapter->netdev->flags & IFF_UP)
+		ixgb_irq_enable(adapter);
 
-	/* remove VID from filter table*/
+	/* remove VID from filter table */
 
 	index = (vid >> 5) & 0x7F;
 	vfta = IXGB_READ_REG_ARRAY(&adapter->hw, VFTA, index);
@@ -2279,7 +2287,7 @@ static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
 	if(netif_running(netdev))
-		ixgb_down(adapter, TRUE);
+		ixgb_down(adapter, true);
 
 	pci_disable_device(pdev);
 
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
index 9e04a6b..4be1b27 100644
--- a/drivers/net/ixgb/ixgb_osdep.h
+++ b/drivers/net/ixgb/ixgb_osdep.h
@@ -39,13 +39,6 @@
 #include <linux/interrupt.h>
 #include <linux/sched.h>
 
-typedef enum {
-#undef FALSE
-	FALSE = 0,
-#undef TRUE
-	TRUE = 1
-} boolean_t;
-
 #undef ASSERT
 #define ASSERT(x)	if(!(x)) BUG()
 #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
new file mode 100644
index 0000000..1d24a73
--- /dev/null
+++ b/drivers/net/korina.c
@@ -0,0 +1,1233 @@
+/*
+ *  Driver for the IDT RC32434 (Korina) on-chip ethernet controller.
+ *
+ *  Copyright 2004 IDT Inc. (rischelp@idt.com)
+ *  Copyright 2006 Felix Fietkau <nbd@openwrt.org>
+ *  Copyright 2008 Florian Fainelli <florian@openwrt.org>
+ *
+ *  This program is free software; you can redistribute  it and/or modify it
+ *  under  the terms of  the GNU General  Public License as published by the
+ *  Free Software Foundation;  either version 2 of the  License, or (at your
+ *  option) any later version.
+ *
+ *  THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' AND   ANY  EXPRESS OR IMPLIED
+ *  WARRANTIES,   INCLUDING, BUT NOT  LIMITED  TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN
+ *  NO  EVENT  SHALL   THE AUTHOR  BE    LIABLE FOR ANY   DIRECT, INDIRECT,
+ *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ *  NOT LIMITED   TO, PROCUREMENT OF  SUBSTITUTE GOODS  OR SERVICES; LOSS OF
+ *  USE, DATA,  OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
+ *  ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT
+ *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *  You should have received a copy of the  GNU General Public License along
+ *  with this program; if not, write  to the Free Software Foundation, Inc.,
+ *  675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ *  Writing to a DMA status register:
+ *
+ *  When writing to the status register, you should mask the bit you have
+ *  been testing the status register with. Both Tx and Rx DMA registers
+ *  should stick to this procedure.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/moduleparam.h>
+#include <linux/sched.h>
+#include <linux/ctype.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/ioport.h>
+#include <linux/in.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/errno.h>
+#include <linux/platform_device.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/crc32.h>
+
+#include <asm/bootinfo.h>
+#include <asm/system.h>
+#include <asm/bitops.h>
+#include <asm/pgtable.h>
+#include <asm/segment.h>
+#include <asm/io.h>
+#include <asm/dma.h>
+
+#include <asm/mach-rc32434/rb.h>
+#include <asm/mach-rc32434/rc32434.h>
+#include <asm/mach-rc32434/eth.h>
+#include <asm/mach-rc32434/dma_v.h>
+
+#define DRV_NAME        "korina"
+#define DRV_VERSION     "0.10"
+#define DRV_RELDATE     "04Mar2008"
+
+#define STATION_ADDRESS_HIGH(dev) (((dev)->dev_addr[0] << 8) | \
+				   ((dev)->dev_addr[1]))
+#define STATION_ADDRESS_LOW(dev)  (((dev)->dev_addr[2] << 24) | \
+				   ((dev)->dev_addr[3] << 16) | \
+				   ((dev)->dev_addr[4] << 8)  | \
+				   ((dev)->dev_addr[5]))
+
+#define MII_CLOCK 1250000 	/* no more than 2.5MHz */
+
+/* the following must be powers of two */
+#define KORINA_NUM_RDS	64  /* number of receive descriptors */
+#define KORINA_NUM_TDS	64  /* number of transmit descriptors */
+
+#define KORINA_RBSIZE	536 /* size of one resource buffer = Ether MTU */
+#define KORINA_RDS_MASK	(KORINA_NUM_RDS - 1)
+#define KORINA_TDS_MASK	(KORINA_NUM_TDS - 1)
+#define RD_RING_SIZE 	(KORINA_NUM_RDS * sizeof(struct dma_desc))
+#define TD_RING_SIZE	(KORINA_NUM_TDS * sizeof(struct dma_desc))
+
+#define TX_TIMEOUT 	(6000 * HZ / 1000)
+
+enum chain_status { desc_filled, desc_empty };
+#define IS_DMA_FINISHED(X)   (((X) & (DMA_DESC_FINI)) != 0)
+#define IS_DMA_DONE(X)   (((X) & (DMA_DESC_DONE)) != 0)
+#define RCVPKT_LENGTH(X)     (((X) & ETH_RX_LEN) >> ETH_RX_LEN_BIT)
+
+/* Information that need to be kept for each board. */
+struct korina_private {
+	struct eth_regs *eth_regs;
+	struct dma_reg *rx_dma_regs;
+	struct dma_reg *tx_dma_regs;
+	struct dma_desc *td_ring; /* transmit descriptor ring */
+	struct dma_desc *rd_ring; /* receive descriptor ring  */
+
+	struct sk_buff *tx_skb[KORINA_NUM_TDS];
+	struct sk_buff *rx_skb[KORINA_NUM_RDS];
+
+	int rx_next_done;
+	int rx_chain_head;
+	int rx_chain_tail;
+	enum chain_status rx_chain_status;
+
+	int tx_next_done;
+	int tx_chain_head;
+	int tx_chain_tail;
+	enum chain_status tx_chain_status;
+	int tx_count;
+	int tx_full;
+
+	int rx_irq;
+	int tx_irq;
+	int ovr_irq;
+	int und_irq;
+
+	spinlock_t lock;        /* NIC xmit lock */
+
+	int dma_halt_cnt;
+	int dma_run_cnt;
+	struct napi_struct napi;
+	struct mii_if_info mii_if;
+	struct net_device *dev;
+	int phy_addr;
+};
+
+extern unsigned int idt_cpu_freq;
+
+static inline void korina_start_dma(struct dma_reg *ch, u32 dma_addr)
+{
+	writel(0, &ch->dmandptr);
+	writel(dma_addr, &ch->dmadptr);
+}
+
+static inline void korina_abort_dma(struct net_device *dev,
+					struct dma_reg *ch)
+{
+       if (readl(&ch->dmac) & DMA_CHAN_RUN_BIT) {
+	       writel(0x10, &ch->dmac);
+
+	       while (!(readl(&ch->dmas) & DMA_STAT_HALT))
+		       dev->trans_start = jiffies;
+
+	       writel(0, &ch->dmas);
+       }
+
+       writel(0, &ch->dmadptr);
+       writel(0, &ch->dmandptr);
+}
+
+static inline void korina_chain_dma(struct dma_reg *ch, u32 dma_addr)
+{
+	writel(dma_addr, &ch->dmandptr);
+}
+
+static void korina_abort_tx(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+
+	korina_abort_dma(dev, lp->tx_dma_regs);
+}
+
+static void korina_abort_rx(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+
+	korina_abort_dma(dev, lp->rx_dma_regs);
+}
+
+static void korina_start_rx(struct korina_private *lp,
+					struct dma_desc *rd)
+{
+	korina_start_dma(lp->rx_dma_regs, CPHYSADDR(rd));
+}
+
+static void korina_chain_rx(struct korina_private *lp,
+					struct dma_desc *rd)
+{
+	korina_chain_dma(lp->rx_dma_regs, CPHYSADDR(rd));
+}
+
+/* transmit packet */
+static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	unsigned long flags;
+	u32 length;
+	u32 chain_index;
+	struct dma_desc *td;
+
+	spin_lock_irqsave(&lp->lock, flags);
+
+	td = &lp->td_ring[lp->tx_chain_tail];
+
+	/* stop queue when full, drop pkts if queue already full */
+	if (lp->tx_count >= (KORINA_NUM_TDS - 2)) {
+		lp->tx_full = 1;
+
+		if (lp->tx_count == (KORINA_NUM_TDS - 2))
+			netif_stop_queue(dev);
+		else {
+			dev->stats.tx_dropped++;
+			dev_kfree_skb_any(skb);
+			spin_unlock_irqrestore(&lp->lock, flags);
+
+			return NETDEV_TX_BUSY;
+		}
+	}
+
+	lp->tx_count++;
+
+	lp->tx_skb[lp->tx_chain_tail] = skb;
+
+	length = skb->len;
+	dma_cache_wback((u32)skb->data, skb->len);
+
+	/* Setup the transmit descriptor. */
+	dma_cache_inv((u32) td, sizeof(*td));
+	td->ca = CPHYSADDR(skb->data);
+	chain_index = (lp->tx_chain_tail - 1) &
+			KORINA_TDS_MASK;
+
+	if (readl(&(lp->tx_dma_regs->dmandptr)) == 0) {
+		if (lp->tx_chain_status == desc_empty) {
+			/* Update tail */
+			td->control = DMA_COUNT(length) |
+					DMA_DESC_COF | DMA_DESC_IOF;
+			/* Move tail */
+			lp->tx_chain_tail = chain_index;
+			/* Write to NDPTR */
+			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
+					&lp->tx_dma_regs->dmandptr);
+			/* Move head to tail */
+			lp->tx_chain_head = lp->tx_chain_tail;
+		} else {
+			/* Update tail */
+			td->control = DMA_COUNT(length) |
+					DMA_DESC_COF | DMA_DESC_IOF;
+			/* Link to prev */
+			lp->td_ring[chain_index].control &=
+					~DMA_DESC_COF;
+			/* Link to prev */
+			lp->td_ring[chain_index].link =  CPHYSADDR(td);
+			/* Move tail */
+			lp->tx_chain_tail = chain_index;
+			/* Write to NDPTR */
+			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
+					&(lp->tx_dma_regs->dmandptr));
+			/* Move head to tail */
+			lp->tx_chain_head = lp->tx_chain_tail;
+			lp->tx_chain_status = desc_empty;
+		}
+	} else {
+		if (lp->tx_chain_status == desc_empty) {
+			/* Update tail */
+			td->control = DMA_COUNT(length) |
+					DMA_DESC_COF | DMA_DESC_IOF;
+			/* Move tail */
+			lp->tx_chain_tail = chain_index;
+			lp->tx_chain_status = desc_filled;
+			netif_stop_queue(dev);
+		} else {
+			/* Update tail */
+			td->control = DMA_COUNT(length) |
+					DMA_DESC_COF | DMA_DESC_IOF;
+			lp->td_ring[chain_index].control &=
+					~DMA_DESC_COF;
+			lp->td_ring[chain_index].link =  CPHYSADDR(td);
+			lp->tx_chain_tail = chain_index;
+		}
+	}
+	dma_cache_wback((u32) td, sizeof(*td));
+
+	dev->trans_start = jiffies;
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	return NETDEV_TX_OK;
+}
+
+static int mdio_read(struct net_device *dev, int mii_id, int reg)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	int ret;
+
+	mii_id = ((lp->rx_irq == 0x2c ? 1 : 0) << 8);
+
+	writel(0, &lp->eth_regs->miimcfg);
+	writel(0, &lp->eth_regs->miimcmd);
+	writel(mii_id | reg, &lp->eth_regs->miimaddr);
+	writel(ETH_MII_CMD_SCN, &lp->eth_regs->miimcmd);
+
+	ret = (int)(readl(&lp->eth_regs->miimrdd));
+	return ret;
+}
+
+static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
+{
+	struct korina_private *lp = netdev_priv(dev);
+
+	mii_id = ((lp->rx_irq == 0x2c ? 1 : 0) << 8);
+
+	writel(0, &lp->eth_regs->miimcfg);
+	writel(1, &lp->eth_regs->miimcmd);
+	writel(mii_id | reg, &lp->eth_regs->miimaddr);
+	writel(ETH_MII_CMD_SCN, &lp->eth_regs->miimcmd);
+	writel(val, &lp->eth_regs->miimwtd);
+}
+
+/* Ethernet Rx DMA interrupt */
+static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct korina_private *lp = netdev_priv(dev);
+	u32 dmas, dmasm;
+	irqreturn_t retval;
+
+	dmas = readl(&lp->rx_dma_regs->dmas);
+	if (dmas & (DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)) {
+		netif_rx_schedule_prep(dev, &lp->napi);
+
+		dmasm = readl(&lp->rx_dma_regs->dmasm);
+		writel(dmasm | (DMA_STAT_DONE |
+				DMA_STAT_HALT | DMA_STAT_ERR),
+				&lp->rx_dma_regs->dmasm);
+
+		if (dmas & DMA_STAT_ERR)
+			printk(KERN_ERR DRV_NAME "%s: DMA error\n", dev->name);
+
+		retval = IRQ_HANDLED;
+	} else
+		retval = IRQ_NONE;
+
+	return retval;
+}
+
+static int korina_rx(struct net_device *dev, int limit)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	struct dma_desc *rd = &lp->rd_ring[lp->rx_next_done];
+	struct sk_buff *skb, *skb_new;
+	u8 *pkt_buf;
+	u32 devcs, pkt_len, dmas, rx_free_desc;
+	int count;
+
+	dma_cache_inv((u32)rd, sizeof(*rd));
+
+	for (count = 0; count < limit; count++) {
+
+		devcs = rd->devcs;
+
+		/* Update statistics counters */
+		if (devcs & ETH_RX_CRC)
+			dev->stats.rx_crc_errors++;
+		if (devcs & ETH_RX_LOR)
+			dev->stats.rx_length_errors++;
+		if (devcs & ETH_RX_LE)
+			dev->stats.rx_length_errors++;
+		if (devcs & ETH_RX_OVR)
+			dev->stats.rx_over_errors++;
+		if (devcs & ETH_RX_CV)
+			dev->stats.rx_frame_errors++;
+		if (devcs & ETH_RX_CES)
+			dev->stats.rx_length_errors++;
+		if (devcs & ETH_RX_MP)
+			dev->stats.multicast++;
+
+		if ((devcs & ETH_RX_LD) != ETH_RX_LD) {
+			/* check that this is a whole packet
+			 * WARNING: DMA_FD bit incorrectly set
+			 * in Rc32434 (errata ref #077) */
+			dev->stats.rx_errors++;
+			dev->stats.rx_dropped++;
+		}
+
+		while ((rx_free_desc = KORINA_RBSIZE - (u32)DMA_COUNT(rd->control)) != 0) {
+			/* init the var. used for the later
+			 * operations within the while loop */
+			skb_new = NULL;
+			pkt_len = RCVPKT_LENGTH(devcs);
+			skb = lp->rx_skb[lp->rx_next_done];
+
+			if ((devcs & ETH_RX_ROK)) {
+				/* must be the (first and) last
+				 * descriptor then */
+				pkt_buf = (u8 *)lp->rx_skb[lp->rx_next_done]->data;
+
+				/* invalidate the cache */
+				dma_cache_inv((unsigned long)pkt_buf, pkt_len - 4);
+
+				/* Malloc up new buffer. */
+				skb_new = netdev_alloc_skb(dev, KORINA_RBSIZE + 2);
+
+				if (!skb_new)
+					break;
+				/* Do not count the CRC */
+				skb_put(skb, pkt_len - 4);
+				skb->protocol = eth_type_trans(skb, dev);
+
+				/* Pass the packet to upper layers */
+				netif_receive_skb(skb);
+				dev->last_rx = jiffies;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
+
+				/* Update the mcast stats */
+				if (devcs & ETH_RX_MP)
+					dev->stats.multicast++;
+
+				lp->rx_skb[lp->rx_next_done] = skb_new;
+			}
+
+			rd->devcs = 0;
+
+			/* Restore descriptor's curr_addr */
+			if (skb_new)
+				rd->ca = CPHYSADDR(skb_new->data);
+			else
+				rd->ca = CPHYSADDR(skb->data);
+
+			rd->control = DMA_COUNT(KORINA_RBSIZE) |
+				DMA_DESC_COD | DMA_DESC_IOD;
+			lp->rd_ring[(lp->rx_next_done - 1) &
+				KORINA_RDS_MASK].control &=
+				~DMA_DESC_COD;
+
+			lp->rx_next_done = (lp->rx_next_done + 1) & KORINA_RDS_MASK;
+			dma_cache_wback((u32)rd, sizeof(*rd));
+			rd = &lp->rd_ring[lp->rx_next_done];
+			writel(~DMA_STAT_DONE, &lp->rx_dma_regs->dmas);
+		}
+	}
+
+	dmas = readl(&lp->rx_dma_regs->dmas);
+
+	if (dmas & DMA_STAT_HALT) {
+		writel(~(DMA_STAT_HALT | DMA_STAT_ERR),
+				&lp->rx_dma_regs->dmas);
+
+		lp->dma_halt_cnt++;
+		rd->devcs = 0;
+		skb = lp->rx_skb[lp->rx_next_done];
+		rd->ca = CPHYSADDR(skb->data);
+		dma_cache_wback((u32)rd, sizeof(*rd));
+		korina_chain_rx(lp, rd);
+	}
+
+	return count;
+}
+
+static int korina_poll(struct napi_struct *napi, int budget)
+{
+	struct korina_private *lp =
+		container_of(napi, struct korina_private, napi);
+	struct net_device *dev = lp->dev;
+	int work_done;
+
+	work_done = korina_rx(dev, budget);
+	if (work_done < budget) {
+		netif_rx_complete(dev, napi);
+
+		writel(readl(&lp->rx_dma_regs->dmasm) &
+			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
+			&lp->rx_dma_regs->dmasm);
+	}
+	return work_done;
+}
+
+/*
+ * Set or clear the multicast filter for this adaptor.
+ */
+static void korina_multicast_list(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	unsigned long flags;
+	struct dev_mc_list *dmi = dev->mc_list;
+	u32 recognise = ETH_ARC_AB;	/* always accept broadcasts */
+	int i;
+
+	/* Set promiscuous mode */
+	if (dev->flags & IFF_PROMISC)
+		recognise |= ETH_ARC_PRO;
+
+	else if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 4))
+		/* All multicast and broadcast */
+		recognise |= ETH_ARC_AM;
+
+	/* Build the hash table */
+	if (dev->mc_count > 4) {
+		u16 hash_table[4];
+		u32 crc;
+
+		for (i = 0; i < 4; i++)
+			hash_table[i] = 0;
+
+		for (i = 0; i < dev->mc_count; i++) {
+			char *addrs = dmi->dmi_addr;
+
+			dmi = dmi->next;
+
+			if (!(*addrs & 1))
+				continue;
+
+			crc = ether_crc_le(6, addrs);
+			crc >>= 26;
+			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
+		}
+		/* Accept filtered multicast */
+		recognise |= ETH_ARC_AFM;
+
+		/* Fill the MAC hash tables with their values */
+		writel((u32)(hash_table[1] << 16 | hash_table[0]),
+					&lp->eth_regs->ethhash0);
+		writel((u32)(hash_table[3] << 16 | hash_table[2]),
+					&lp->eth_regs->ethhash1);
+	}
+
+	spin_lock_irqsave(&lp->lock, flags);
+	writel(recognise, &lp->eth_regs->etharc);
+	spin_unlock_irqrestore(&lp->lock, flags);
+}
+
+static void korina_tx(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	struct dma_desc *td = &lp->td_ring[lp->tx_next_done];
+	u32 devcs;
+	u32 dmas;
+
+	spin_lock(&lp->lock);
+
+	/* Process all desc that are done */
+	while (IS_DMA_FINISHED(td->control)) {
+		if (lp->tx_full == 1) {
+			netif_wake_queue(dev);
+			lp->tx_full = 0;
+		}
+
+		devcs = lp->td_ring[lp->tx_next_done].devcs;
+		if ((devcs & (ETH_TX_FD | ETH_TX_LD)) !=
+				(ETH_TX_FD | ETH_TX_LD)) {
+			dev->stats.tx_errors++;
+			dev->stats.tx_dropped++;
+
+			/* Should never happen */
+			printk(KERN_ERR DRV_NAME "%s: split tx ignored\n",
+							dev->name);
+		} else if (devcs & ETH_TX_TOK) {
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes +=
+					lp->tx_skb[lp->tx_next_done]->len;
+		} else {
+			dev->stats.tx_errors++;
+			dev->stats.tx_dropped++;
+
+			/* Underflow */
+			if (devcs & ETH_TX_UND)
+				dev->stats.tx_fifo_errors++;
+
+			/* Oversized frame */
+			if (devcs & ETH_TX_OF)
+				dev->stats.tx_aborted_errors++;
+
+			/* Excessive deferrals */
+			if (devcs & ETH_TX_ED)
+				dev->stats.tx_carrier_errors++;
+
+			/* Collisions: medium busy */
+			if (devcs & ETH_TX_EC)
+				dev->stats.collisions++;
+
+			/* Late collision */
+			if (devcs & ETH_TX_LC)
+				dev->stats.tx_window_errors++;
+		}
+
+		/* We must always free the original skb */
+		if (lp->tx_skb[lp->tx_next_done]) {
+			dev_kfree_skb_any(lp->tx_skb[lp->tx_next_done]);
+			lp->tx_skb[lp->tx_next_done] = NULL;
+		}
+
+		lp->td_ring[lp->tx_next_done].control = DMA_DESC_IOF;
+		lp->td_ring[lp->tx_next_done].devcs = ETH_TX_FD | ETH_TX_LD;
+		lp->td_ring[lp->tx_next_done].link = 0;
+		lp->td_ring[lp->tx_next_done].ca = 0;
+		lp->tx_count--;
+
+		/* Go on to next transmission */
+		lp->tx_next_done = (lp->tx_next_done + 1) & KORINA_TDS_MASK;
+		td = &lp->td_ring[lp->tx_next_done];
+
+	}
+
+	/* Clear the DMA status register */
+	dmas = readl(&lp->tx_dma_regs->dmas);
+	writel(~dmas, &lp->tx_dma_regs->dmas);
+
+	writel(readl(&lp->tx_dma_regs->dmasm) &
+			~(DMA_STAT_FINI | DMA_STAT_ERR),
+			&lp->tx_dma_regs->dmasm);
+
+	spin_unlock(&lp->lock);
+}
+
+static irqreturn_t
+korina_tx_dma_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct korina_private *lp = netdev_priv(dev);
+	u32 dmas, dmasm;
+	irqreturn_t retval;
+
+	dmas = readl(&lp->tx_dma_regs->dmas);
+
+	if (dmas & (DMA_STAT_FINI | DMA_STAT_ERR)) {
+		korina_tx(dev);
+
+		dmasm = readl(&lp->tx_dma_regs->dmasm);
+		writel(dmasm | (DMA_STAT_FINI | DMA_STAT_ERR),
+				&lp->tx_dma_regs->dmasm);
+
+		if (lp->tx_chain_status == desc_filled &&
+			(readl(&(lp->tx_dma_regs->dmandptr)) == 0)) {
+			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
+				&(lp->tx_dma_regs->dmandptr));
+			lp->tx_chain_status = desc_empty;
+			lp->tx_chain_head = lp->tx_chain_tail;
+			dev->trans_start = jiffies;
+		}
+		if (dmas & DMA_STAT_ERR)
+			printk(KERN_ERR DRV_NAME "%s: DMA error\n", dev->name);
+
+		retval = IRQ_HANDLED;
+	} else
+		retval = IRQ_NONE;
+
+	return retval;
+}
+
+
+static void korina_check_media(struct net_device *dev, unsigned int init_media)
+{
+	struct korina_private *lp = netdev_priv(dev);
+
+	mii_check_media(&lp->mii_if, 0, init_media);
+
+	if (lp->mii_if.full_duplex)
+		writel(readl(&lp->eth_regs->ethmac2) | ETH_MAC2_FD,
+						&lp->eth_regs->ethmac2);
+	else
+		writel(readl(&lp->eth_regs->ethmac2) & ~ETH_MAC2_FD,
+						&lp->eth_regs->ethmac2);
+}
+
+static void korina_set_carrier(struct mii_if_info *mii)
+{
+	if (mii->force_media) {
+		/* autoneg is off: Link is always assumed to be up */
+		if (!netif_carrier_ok(mii->dev))
+			netif_carrier_on(mii->dev);
+	} else  /* Let MMI library update carrier status */
+		korina_check_media(mii->dev, 0);
+}
+
+static int korina_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	struct mii_ioctl_data *data = if_mii(rq);
+	int rc;
+
+	if (!netif_running(dev))
+		return -EINVAL;
+	spin_lock_irq(&lp->lock);
+	rc = generic_mii_ioctl(&lp->mii_if, data, cmd, NULL);
+	spin_unlock_irq(&lp->lock);
+	korina_set_carrier(&lp->mii_if);
+
+	return rc;
+}
+
+/* ethtool helpers */
+static void netdev_get_drvinfo(struct net_device *dev,
+			struct ethtool_drvinfo *info)
+{
+	struct korina_private *lp = netdev_priv(dev);
+
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->bus_info, lp->dev->name);
+}
+
+static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	int rc;
+
+	spin_lock_irq(&lp->lock);
+	rc = mii_ethtool_gset(&lp->mii_if, cmd);
+	spin_unlock_irq(&lp->lock);
+
+	return rc;
+}
+
+static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	int rc;
+
+	spin_lock_irq(&lp->lock);
+	rc = mii_ethtool_sset(&lp->mii_if, cmd);
+	spin_unlock_irq(&lp->lock);
+	korina_set_carrier(&lp->mii_if);
+
+	return rc;
+}
+
+static u32 netdev_get_link(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+
+	return mii_link_ok(&lp->mii_if);
+}
+
+static struct ethtool_ops netdev_ethtool_ops = {
+	.get_drvinfo            = netdev_get_drvinfo,
+	.get_settings           = netdev_get_settings,
+	.set_settings           = netdev_set_settings,
+	.get_link               = netdev_get_link,
+};
+
+static void korina_alloc_ring(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	int i;
+
+	/* Initialize the transmit descriptors */
+	for (i = 0; i < KORINA_NUM_TDS; i++) {
+		lp->td_ring[i].control = DMA_DESC_IOF;
+		lp->td_ring[i].devcs = ETH_TX_FD | ETH_TX_LD;
+		lp->td_ring[i].ca = 0;
+		lp->td_ring[i].link = 0;
+	}
+	lp->tx_next_done = lp->tx_chain_head = lp->tx_chain_tail =
+			lp->tx_full = lp->tx_count = 0;
+	lp->tx_chain_status = desc_empty;
+
+	/* Initialize the receive descriptors */
+	for (i = 0; i < KORINA_NUM_RDS; i++) {
+		struct sk_buff *skb = lp->rx_skb[i];
+
+		skb = dev_alloc_skb(KORINA_RBSIZE + 2);
+		if (!skb)
+			break;
+		skb_reserve(skb, 2);
+		lp->rx_skb[i] = skb;
+		lp->rd_ring[i].control = DMA_DESC_IOD |
+				DMA_COUNT(KORINA_RBSIZE);
+		lp->rd_ring[i].devcs = 0;
+		lp->rd_ring[i].ca = CPHYSADDR(skb->data);
+		lp->rd_ring[i].link = CPHYSADDR(&lp->rd_ring[i+1]);
+	}
+
+	/* loop back */
+	lp->rd_ring[i].link = CPHYSADDR(&lp->rd_ring[0]);
+	lp->rx_next_done  = 0;
+
+	lp->rd_ring[i].control |= DMA_DESC_COD;
+	lp->rx_chain_head = 0;
+	lp->rx_chain_tail = 0;
+	lp->rx_chain_status = desc_empty;
+}
+
+static void korina_free_ring(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < KORINA_NUM_RDS; i++) {
+		lp->rd_ring[i].control = 0;
+		if (lp->rx_skb[i])
+			dev_kfree_skb_any(lp->rx_skb[i]);
+		lp->rx_skb[i] = NULL;
+	}
+
+	for (i = 0; i < KORINA_NUM_TDS; i++) {
+		lp->td_ring[i].control = 0;
+		if (lp->tx_skb[i])
+			dev_kfree_skb_any(lp->tx_skb[i]);
+		lp->tx_skb[i] = NULL;
+	}
+}
+
+/*
+ * Initialize the RC32434 ethernet controller.
+ */
+static int korina_init(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+
+	/* Disable DMA */
+	korina_abort_tx(dev);
+	korina_abort_rx(dev);
+
+	/* reset ethernet logic */
+	writel(0, &lp->eth_regs->ethintfc);
+	while ((readl(&lp->eth_regs->ethintfc) & ETH_INT_FC_RIP))
+		dev->trans_start = jiffies;
+
+	/* Enable Ethernet Interface */
+	writel(ETH_INT_FC_EN, &lp->eth_regs->ethintfc);
+
+	/* Allocate rings */
+	korina_alloc_ring(dev);
+
+	writel(0, &lp->rx_dma_regs->dmas);
+	/* Start Rx DMA */
+	korina_start_rx(lp, &lp->rd_ring[0]);
+
+	writel(readl(&lp->tx_dma_regs->dmasm) &
+			~(DMA_STAT_FINI | DMA_STAT_ERR),
+			&lp->tx_dma_regs->dmasm);
+	writel(readl(&lp->rx_dma_regs->dmasm) &
+			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
+			&lp->rx_dma_regs->dmasm);
+
+	/* Accept only packets destined for this Ethernet device address */
+	writel(ETH_ARC_AB, &lp->eth_regs->etharc);
+
+	/* Set all Ether station address registers to their initial values */
+	writel(STATION_ADDRESS_LOW(dev), &lp->eth_regs->ethsal0);
+	writel(STATION_ADDRESS_HIGH(dev), &lp->eth_regs->ethsah0);
+
+	writel(STATION_ADDRESS_LOW(dev), &lp->eth_regs->ethsal1);
+	writel(STATION_ADDRESS_HIGH(dev), &lp->eth_regs->ethsah1);
+
+	writel(STATION_ADDRESS_LOW(dev), &lp->eth_regs->ethsal2);
+	writel(STATION_ADDRESS_HIGH(dev), &lp->eth_regs->ethsah2);
+
+	writel(STATION_ADDRESS_LOW(dev), &lp->eth_regs->ethsal3);
+	writel(STATION_ADDRESS_HIGH(dev), &lp->eth_regs->ethsah3);
+
+
+	/* Frame Length Checking, Pad Enable, CRC Enable, Full Duplex set */
+	writel(ETH_MAC2_PE | ETH_MAC2_CEN | ETH_MAC2_FD,
+			&lp->eth_regs->ethmac2);
+
+	/* Back to back inter-packet-gap */
+	writel(0x15, &lp->eth_regs->ethipgt);
+	/* Non - Back to back inter-packet-gap */
+	writel(0x12, &lp->eth_regs->ethipgr);
+
+	/* Management Clock Prescaler Divisor
+	 * Clock independent setting */
+	writel(((idt_cpu_freq) / MII_CLOCK + 1) & ~1,
+		       &lp->eth_regs->ethmcp);
+
+	/* don't transmit until fifo contains 48b */
+	writel(48, &lp->eth_regs->ethfifott);
+
+	writel(ETH_MAC1_RE, &lp->eth_regs->ethmac1);
+
+	napi_enable(&lp->napi);
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+/*
+ * Restart the RC32434 ethernet controller.
+ * FIXME: check the return status where we call it
+ */
+static int korina_restart(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	int ret = 0;
+
+	/*
+	 * Disable interrupts
+	 */
+	disable_irq(lp->rx_irq);
+	disable_irq(lp->tx_irq);
+	disable_irq(lp->ovr_irq);
+	disable_irq(lp->und_irq);
+
+	writel(readl(&lp->tx_dma_regs->dmasm) |
+				DMA_STAT_FINI | DMA_STAT_ERR,
+				&lp->tx_dma_regs->dmasm);
+	writel(readl(&lp->rx_dma_regs->dmasm) |
+				DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR,
+				&lp->rx_dma_regs->dmasm);
+
+	korina_free_ring(dev);
+
+	ret = korina_init(dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: cannot restart device\n",
+								dev->name);
+		return ret;
+	}
+	korina_multicast_list(dev);
+
+	enable_irq(lp->und_irq);
+	enable_irq(lp->ovr_irq);
+	enable_irq(lp->tx_irq);
+	enable_irq(lp->rx_irq);
+
+	return ret;
+}
+
+static void korina_clear_and_restart(struct net_device *dev, u32 value)
+{
+	struct korina_private *lp = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	writel(value, &lp->eth_regs->ethintfc);
+	korina_restart(dev);
+}
+
+/* Ethernet Tx Underflow interrupt */
+static irqreturn_t korina_und_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct korina_private *lp = netdev_priv(dev);
+	unsigned int und;
+
+	spin_lock(&lp->lock);
+
+	und = readl(&lp->eth_regs->ethintfc);
+
+	if (und & ETH_INT_FC_UND)
+		korina_clear_and_restart(dev, und & ~ETH_INT_FC_UND);
+
+	spin_unlock(&lp->lock);
+
+	return IRQ_HANDLED;
+}
+
+static void korina_tx_timeout(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	korina_restart(dev);
+	spin_unlock_irqrestore(&lp->lock, flags);
+}
+
+/* Ethernet Rx Overflow interrupt */
+static irqreturn_t
+korina_ovr_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct korina_private *lp = netdev_priv(dev);
+	unsigned int ovr;
+
+	spin_lock(&lp->lock);
+	ovr = readl(&lp->eth_regs->ethintfc);
+
+	if (ovr & ETH_INT_FC_OVR)
+		korina_clear_and_restart(dev, ovr & ~ETH_INT_FC_OVR);
+
+	spin_unlock(&lp->lock);
+
+	return IRQ_HANDLED;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void korina_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	korina_tx_dma_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+#endif
+
+static int korina_open(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	int ret = 0;
+
+	/* Initialize */
+	ret = korina_init(dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: cannot open device\n", dev->name);
+		goto out;
+	}
+
+	/* Install the interrupt handler
+	 * that handles the Done Finished
+	 * Ovr and Und Events */
+	ret = request_irq(lp->rx_irq, &korina_rx_dma_interrupt,
+		IRQF_SHARED | IRQF_DISABLED, "Korina ethernet Rx", dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: unable to get Rx DMA IRQ %d\n",
+		    dev->name, lp->rx_irq);
+		goto err_release;
+	}
+	ret = request_irq(lp->tx_irq, &korina_tx_dma_interrupt,
+		IRQF_SHARED | IRQF_DISABLED, "Korina ethernet Tx", dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: unable to get Tx DMA IRQ %d\n",
+		    dev->name, lp->tx_irq);
+		goto err_free_rx_irq;
+	}
+
+	/* Install handler for overrun error. */
+	ret = request_irq(lp->ovr_irq, &korina_ovr_interrupt,
+			IRQF_SHARED | IRQF_DISABLED, "Ethernet Overflow", dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME"%s: unable to get OVR IRQ %d\n",
+		    dev->name, lp->ovr_irq);
+		goto err_free_tx_irq;
+	}
+
+	/* Install handler for underflow error. */
+	ret = request_irq(lp->und_irq, &korina_und_interrupt,
+			IRQF_SHARED | IRQF_DISABLED, "Ethernet Underflow", dev);
+	if (ret < 0) {
+		printk(KERN_ERR DRV_NAME "%s: unable to get UND IRQ %d\n",
+		    dev->name, lp->und_irq);
+		goto err_free_ovr_irq;
+	}
+
+err_free_ovr_irq:
+	free_irq(lp->ovr_irq, dev);
+err_free_tx_irq:
+	free_irq(lp->tx_irq, dev);
+err_free_rx_irq:
+	free_irq(lp->rx_irq, dev);
+err_release:
+	korina_free_ring(dev);
+	goto out;
+out:
+	return ret;
+}
+
+static int korina_close(struct net_device *dev)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	u32 tmp;
+
+	/* Disable interrupts */
+	disable_irq(lp->rx_irq);
+	disable_irq(lp->tx_irq);
+	disable_irq(lp->ovr_irq);
+	disable_irq(lp->und_irq);
+
+	korina_abort_tx(dev);
+	tmp = readl(&lp->tx_dma_regs->dmasm);
+	tmp = tmp | DMA_STAT_FINI | DMA_STAT_ERR;
+	writel(tmp, &lp->tx_dma_regs->dmasm);
+
+	korina_abort_rx(dev);
+	tmp = readl(&lp->rx_dma_regs->dmasm);
+	tmp = tmp | DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR;
+	writel(tmp, &lp->rx_dma_regs->dmasm);
+
+	korina_free_ring(dev);
+
+	free_irq(lp->rx_irq, dev);
+	free_irq(lp->tx_irq, dev);
+	free_irq(lp->ovr_irq, dev);
+	free_irq(lp->und_irq, dev);
+
+	return 0;
+}
+
+static int korina_probe(struct platform_device *pdev)
+{
+	struct korina_device *bif = platform_get_drvdata(pdev);
+	struct korina_private *lp;
+	struct net_device *dev;
+	struct resource *r;
+	int retval, err;
+
+	dev = alloc_etherdev(sizeof(struct korina_private));
+	if (!dev) {
+		printk(KERN_ERR DRV_NAME ": alloc_etherdev failed\n");
+		return -ENOMEM;
+	}
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	platform_set_drvdata(pdev, dev);
+	lp = netdev_priv(dev);
+
+	bif->dev = dev;
+	memcpy(dev->dev_addr, bif->mac, 6);
+
+	lp->rx_irq = platform_get_irq_byname(pdev, "korina_rx");
+	lp->tx_irq = platform_get_irq_byname(pdev, "korina_tx");
+	lp->ovr_irq = platform_get_irq_byname(pdev, "korina_ovr");
+	lp->und_irq = platform_get_irq_byname(pdev, "korina_und");
+
+	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_regs");
+	dev->base_addr = r->start;
+	lp->eth_regs = ioremap_nocache(r->start, r->end - r->start);
+	if (!lp->eth_regs) {
+		printk(KERN_ERR DRV_NAME "cannot remap registers\n");
+		retval = -ENXIO;
+		goto probe_err_out;
+	}
+
+	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_rx");
+	lp->rx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
+	if (!lp->rx_dma_regs) {
+		printk(KERN_ERR DRV_NAME "cannot remap Rx DMA registers\n");
+		retval = -ENXIO;
+		goto probe_err_dma_rx;
+	}
+
+	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_tx");
+	lp->tx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
+	if (!lp->tx_dma_regs) {
+		printk(KERN_ERR DRV_NAME "cannot remap Tx DMA registers\n");
+		retval = -ENXIO;
+		goto probe_err_dma_tx;
+	}
+
+	lp->td_ring = kmalloc(TD_RING_SIZE + RD_RING_SIZE, GFP_KERNEL);
+	if (!lp->td_ring) {
+		printk(KERN_ERR DRV_NAME "cannot allocate descriptors\n");
+		retval = -ENOMEM;
+		goto probe_err_td_ring;
+	}
+
+	dma_cache_inv((unsigned long)(lp->td_ring),
+			TD_RING_SIZE + RD_RING_SIZE);
+
+	/* now convert TD_RING pointer to KSEG1 */
+	lp->td_ring = (struct dma_desc *)KSEG1ADDR(lp->td_ring);
+	lp->rd_ring = &lp->td_ring[KORINA_NUM_TDS];
+
+	spin_lock_init(&lp->lock);
+	/* just use the rx dma irq */
+	dev->irq = lp->rx_irq;
+	lp->dev = dev;
+
+	dev->open = korina_open;
+	dev->stop = korina_close;
+	dev->hard_start_xmit = korina_send_packet;
+	dev->set_multicast_list = &korina_multicast_list;
+	dev->ethtool_ops = &netdev_ethtool_ops;
+	dev->tx_timeout = korina_tx_timeout;
+	dev->watchdog_timeo = TX_TIMEOUT;
+	dev->do_ioctl = &korina_ioctl;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = korina_poll_controller;
+#endif
+	netif_napi_add(dev, &lp->napi, korina_poll, 64);
+
+	lp->phy_addr = (((lp->rx_irq == 0x2c? 1:0) << 8) | 0x05);
+	lp->mii_if.dev = dev;
+	lp->mii_if.mdio_read = mdio_read;
+	lp->mii_if.mdio_write = mdio_write;
+	lp->mii_if.phy_id = lp->phy_addr;
+	lp->mii_if.phy_id_mask = 0x1f;
+	lp->mii_if.reg_num_mask = 0x1f;
+
+	err = register_netdev(dev);
+	if (err) {
+		printk(KERN_ERR DRV_NAME
+			": cannot register net device %d\n", err);
+		retval = -EINVAL;
+		goto probe_err_register;
+	}
+	return 0;
+
+probe_err_register:
+	kfree(lp->td_ring);
+probe_err_td_ring:
+	iounmap(lp->tx_dma_regs);
+probe_err_dma_tx:
+	iounmap(lp->rx_dma_regs);
+probe_err_dma_rx:
+	iounmap(lp->eth_regs);
+probe_err_out:
+	free_netdev(dev);
+	return retval;
+}
+
+static int korina_remove(struct platform_device *pdev)
+{
+	struct korina_device *bif = platform_get_drvdata(pdev);
+	struct korina_private *lp = netdev_priv(bif->dev);
+
+	if (lp->eth_regs)
+		iounmap(lp->eth_regs);
+	if (lp->rx_dma_regs)
+		iounmap(lp->rx_dma_regs);
+	if (lp->tx_dma_regs)
+		iounmap(lp->tx_dma_regs);
+
+	platform_set_drvdata(pdev, NULL);
+	unregister_netdev(bif->dev);
+	free_netdev(bif->dev);
+
+	return 0;
+}
+
+static struct platform_driver korina_driver = {
+	.driver.name = "korina",
+	.probe = korina_probe,
+	.remove = korina_remove,
+};
+
+static int __init korina_init_module(void)
+{
+	return platform_driver_register(&korina_driver);
+}
+
+static void korina_cleanup_module(void)
+{
+	return platform_driver_unregister(&korina_driver);
+}
+
+module_init(korina_init_module);
+module_exit(korina_cleanup_module);
+
+MODULE_AUTHOR("Philip Rischel <rischelp@idt.com>");
+MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
+MODULE_AUTHOR("Florian Fainelli <florian@openwrt.org>");
+MODULE_DESCRIPTION("IDT RC32434 (Korina) Ethernet driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 771139e..d65cade 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -3156,7 +3156,7 @@ struct mv643xx_stats {
 	int stat_offset;
 };
 
-#define MV643XX_STAT(m) sizeof(((struct mv643xx_private *)0)->m), \
+#define MV643XX_STAT(m) FIELD_SIZEOF(struct mv643xx_private, m), \
 					offsetof(struct mv643xx_private, m)
 
 static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 385f69c..900ab5d 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -511,10 +511,10 @@ enum PhyCtrl_bits {
 /* Note that using only 32 bit fields simplifies conversion to big-endian
    architectures. */
 struct netdev_desc {
-	u32 next_desc;
-	s32 cmd_status;
-	u32 addr;
-	u32 software_use;
+	__le32 next_desc;
+	__le32 cmd_status;
+	__le32 addr;
+	__le32 software_use;
 };
 
 /* Bits in network_desc.status */
@@ -2018,7 +2018,7 @@ static void drain_rx(struct net_device *dev)
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		np->rx_ring[i].cmd_status = 0;
-		np->rx_ring[i].addr = 0xBADF00D0; /* An invalid address. */
+		np->rx_ring[i].addr = cpu_to_le32(0xBADF00D0); /* An invalid address. */
 		if (np->rx_skbuff[i]) {
 			pci_unmap_single(np->pci_dev,
 				np->rx_dma[i], buflen,
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 26aa8fe..a316dcc 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -134,10 +134,10 @@ static int fifo = 0x8;	/* don't change */
 #define ni_disint()   { outb(0, dev->base_addr + NI52_INTDIS); }
 #define ni_enaint()   { outb(0, dev->base_addr + NI52_INTENA); }
 
-#define make32(ptr16) (p->memtop + (short) (ptr16))
-#define make24(ptr32) ((unsigned long)(ptr32)) - p->base
-#define make16(ptr32) ((unsigned short) ((unsigned long)(ptr32)\
-					- (unsigned long) p->memtop))
+#define make32(ptr16) ((void __iomem *)(p->memtop + (short) (ptr16)))
+#define make24(ptr32) ((char __iomem *)(ptr32)) - p->base
+#define make16(ptr32) ((unsigned short) ((char __iomem *)(ptr32)\
+					- p->memtop))
 
 /******************* how to calculate the buffers *****************************
 
@@ -179,34 +179,35 @@ static void    ni52_timeout(struct net_device *dev);
 
 /* helper-functions */
 static int     init586(struct net_device *dev);
-static int     check586(struct net_device *dev, char *where, unsigned size);
+static int     check586(struct net_device *dev, unsigned size);
 static void    alloc586(struct net_device *dev);
 static void    startrecv586(struct net_device *dev);
-static void   *alloc_rfa(struct net_device *dev, void *ptr);
+static void   __iomem *alloc_rfa(struct net_device *dev, void __iomem *ptr);
 static void    ni52_rcv_int(struct net_device *dev);
 static void    ni52_xmt_int(struct net_device *dev);
 static void    ni52_rnr_int(struct net_device *dev);
 
 struct priv {
 	struct net_device_stats stats;
-	unsigned long base;
-	char *memtop;
+	char __iomem *base;
+	char __iomem *mapped;
+	char __iomem *memtop;
 	spinlock_t spinlock;
 	int reset;
-	struct rfd_struct *rfd_last, *rfd_top, *rfd_first;
-	struct scp_struct *scp;
-	struct iscp_struct *iscp;
-	struct scb_struct *scb;
-	struct tbd_struct *xmit_buffs[NUM_XMIT_BUFFS];
+	struct rfd_struct __iomem *rfd_last, *rfd_top, *rfd_first;
+	struct scp_struct __iomem *scp;
+	struct iscp_struct __iomem *iscp;
+	struct scb_struct __iomem *scb;
+	struct tbd_struct __iomem *xmit_buffs[NUM_XMIT_BUFFS];
 #if (NUM_XMIT_BUFFS == 1)
-	struct transmit_cmd_struct *xmit_cmds[2];
-	struct nop_cmd_struct *nop_cmds[2];
+	struct transmit_cmd_struct __iomem *xmit_cmds[2];
+	struct nop_cmd_struct __iomem *nop_cmds[2];
 #else
-	struct transmit_cmd_struct *xmit_cmds[NUM_XMIT_BUFFS];
-	struct nop_cmd_struct *nop_cmds[NUM_XMIT_BUFFS];
+	struct transmit_cmd_struct __iomem *xmit_cmds[NUM_XMIT_BUFFS];
+	struct nop_cmd_struct __iomem *nop_cmds[NUM_XMIT_BUFFS];
 #endif
 	int nop_point, num_recv_buffs;
-	char *xmit_cbuffs[NUM_XMIT_BUFFS];
+	char __iomem *xmit_cbuffs[NUM_XMIT_BUFFS];
 	int xmit_count, xmit_last;
 };
 
@@ -240,7 +241,8 @@ static void wait_for_scb_cmd_ruc(struct net_device *dev)
 		udelay(4);
 		if (i == 16383) {
 			printk(KERN_ERR "%s: scb_cmd (ruc) timed out: %04x,%04x .. disabling i82586!!\n",
-				dev->name, p->scb->cmd_ruc, p->scb->rus);
+				dev->name, readb(&p->scb->cmd_ruc),
+				readb(&p->scb->rus));
 			if (!p->reset) {
 				p->reset = 1;
 				ni_reset586();
@@ -249,9 +251,9 @@ static void wait_for_scb_cmd_ruc(struct net_device *dev)
 	}
 }
 
-static void wait_for_stat_compl(void *p)
+static void wait_for_stat_compl(void __iomem *p)
 {
-	struct nop_cmd_struct *addr = p;
+	struct nop_cmd_struct __iomem *addr = p;
 	int i;
 	for (i = 0; i < 32767; i++) {
 		if (readw(&((addr)->cmd_status)) & STAT_COMPL)
@@ -293,47 +295,58 @@ static int ni52_open(struct net_device *dev)
 	return 0; /* most done by init */
 }
 
+static int check_iscp(struct net_device *dev, void __iomem *addr)
+{
+	struct iscp_struct __iomem *iscp = addr;
+	struct priv *p = dev->priv;
+	memset_io(iscp, 0, sizeof(struct iscp_struct));
+
+	writel(make24(iscp), &p->scp->iscp);
+	writeb(1, &iscp->busy);
+
+	ni_reset586();
+	ni_attn586();
+	mdelay(32);	/* wait a while... */
+	/* i82586 clears 'busy' after successful init */
+	if (readb(&iscp->busy))
+		return 0;
+	return 1;
+}
+
 /**********************************************
  * Check to see if there's an 82586 out there.
  */
-static int check586(struct net_device *dev, char *where, unsigned size)
+static int check586(struct net_device *dev, unsigned size)
 {
-	struct priv pb;
-	struct priv *p = /* (struct priv *) dev->priv*/ &pb;
-	char *iscp_addrs[2];
+	struct priv *p = dev->priv;
 	int i;
 
-	p->base = (unsigned long) isa_bus_to_virt((unsigned long)where)
-							+ size - 0x01000000;
-	p->memtop = isa_bus_to_virt((unsigned long)where) + size;
-	p->scp = (struct scp_struct *)(p->base + SCP_DEFAULT_ADDRESS);
-	memset_io((char *)p->scp, 0, sizeof(struct scp_struct));
+	p->mapped = ioremap(dev->mem_start, size);
+	if (!p->mapped)
+		return 0;
+
+	p->base = p->mapped + size - 0x01000000;
+	p->memtop = p->mapped + size;
+	p->scp = (struct scp_struct __iomem *)(p->base + SCP_DEFAULT_ADDRESS);
+	p->scb	= (struct scb_struct __iomem *)	p->mapped;
+	p->iscp = (struct iscp_struct __iomem *)p->scp - 1;
+	memset_io(p->scp, 0, sizeof(struct scp_struct));
 	for (i = 0; i < sizeof(struct scp_struct); i++)
 		/* memory was writeable? */
-		if (readb((char *)p->scp + i))
-			return 0;
+		if (readb((char __iomem *)p->scp + i))
+			goto Enodev;
 	writeb(SYSBUSVAL, &p->scp->sysbus);	/* 1 = 8Bit-Bus, 0 = 16 Bit */
 	if (readb(&p->scp->sysbus) != SYSBUSVAL)
-		return 0;
-
-	iscp_addrs[0] = isa_bus_to_virt((unsigned long)where);
-	iscp_addrs[1] = (char *) p->scp - sizeof(struct iscp_struct);
+		goto Enodev;
 
-	for (i = 0; i < 2; i++) {
-		p->iscp = (struct iscp_struct *) iscp_addrs[i];
-		memset_io((char *)p->iscp, 0, sizeof(struct iscp_struct));
-
-		writel(make24(p->iscp), &p->scp->iscp);
-		writeb(1, &p->iscp->busy);
-
-		ni_reset586();
-		ni_attn586();
-		mdelay(32);	/* wait a while... */
-		/* i82586 clears 'busy' after successful init */
-		if (readb(&p->iscp->busy))
-			return 0;
-	}
+	if (!check_iscp(dev, p->mapped))
+		goto Enodev;
+	if (!check_iscp(dev, p->iscp))
+		goto Enodev;
 	return 1;
+Enodev:
+	iounmap(p->mapped);
+	return 0;
 }
 
 /******************************************************************
@@ -346,13 +359,6 @@ static void alloc586(struct net_device *dev)
 	ni_reset586();
 	mdelay(32);
 
-	spin_lock_init(&p->spinlock);
-
-	p->scp	= (struct scp_struct *)	(p->base + SCP_DEFAULT_ADDRESS);
-	p->scb	= (struct scb_struct *)	isa_bus_to_virt(dev->mem_start);
-	p->iscp = (struct iscp_struct *)
-			((char *)p->scp - sizeof(struct iscp_struct));
-
 	memset_io(p->iscp, 0, sizeof(struct iscp_struct));
 	memset_io(p->scp , 0, sizeof(struct scp_struct));
 
@@ -371,7 +377,7 @@ static void alloc586(struct net_device *dev)
 
 	p->reset = 0;
 
-	memset_io((char *)p->scb, 0, sizeof(struct scb_struct));
+	memset_io(p->scb, 0, sizeof(struct scb_struct));
 }
 
 /* set: io,irq,memstart,memend or set it when calling insmod */
@@ -387,12 +393,15 @@ struct net_device * __init ni52_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct priv));
 	static int ports[] = {0x300, 0x280, 0x360 , 0x320 , 0x340, 0};
+	struct priv *p;
 	int *port;
 	int err = 0;
 
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
+	p = dev->priv;
+
 	if (unit >= 0) {
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
@@ -427,6 +436,7 @@ got_it:
 		goto out1;
 	return dev;
 out1:
+	iounmap(p->mapped);
 	release_region(dev->base_addr, NI52_TOTAL_SIZE);
 out:
 	free_netdev(dev);
@@ -436,12 +446,15 @@ out:
 static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, size, retval;
+	struct priv *priv = dev->priv;
 
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
 	dev->mem_start = memstart;
 	dev->mem_end = memend;
 
+	spin_lock_init(&priv->spinlock);
+
 	if (!request_region(ioaddr, NI52_TOTAL_SIZE, DRV_NAME))
 		return -EBUSY;
 
@@ -474,7 +487,7 @@ static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 		retval = -ENODEV;
 		goto out;
 	}
-	if (!check586(dev, (char *)dev->mem_start, size)) {
+	if (!check586(dev, size)) {
 		printk(KERN_ERR "?memcheck, Can't find memory at 0x%lx with size %d!\n", dev->mem_start, size);
 		retval = -ENODEV;
 		goto out;
@@ -483,9 +496,9 @@ static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 	if (dev->mem_start != 0) {
 		/* no auto-mem-probe */
 		size = 0x4000; /* check for 16K mem */
-		if (!check586(dev, (char *) dev->mem_start, size)) {
+		if (!check586(dev, size)) {
 			size = 0x2000; /* check for 8K mem */
-			if (!check586(dev, (char *)dev->mem_start, size)) {
+			if (!check586(dev, size)) {
 				printk(KERN_ERR "?memprobe, Can't find memory at 0x%lx!\n", dev->mem_start);
 				retval = -ENODEV;
 				goto out;
@@ -504,11 +517,11 @@ static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 			}
 			dev->mem_start = memaddrs[i];
 			size = 0x2000; /* check for 8K mem */
-			if (check586(dev, (char *)dev->mem_start, size))
+			if (check586(dev, size))
 				/* 8K-check */
 				break;
 			size = 0x4000; /* check for 16K mem */
-			if (check586(dev, (char *)dev->mem_start, size))
+			if (check586(dev, size))
 				/* 16K-check */
 				break;
 		}
@@ -517,19 +530,13 @@ static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 	dev->mem_end = dev->mem_start + size;
 #endif
 
-	memset((char *)dev->priv, 0, sizeof(struct priv));
-
-	((struct priv *)(dev->priv))->memtop =
-				isa_bus_to_virt(dev->mem_start) + size;
-	((struct priv *)(dev->priv))->base =  (unsigned long)
-			isa_bus_to_virt(dev->mem_start) + size - 0x01000000;
 	alloc586(dev);
 
 	/* set number of receive-buffs according to memsize */
 	if (size == 0x2000)
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_8;
+		priv->num_recv_buffs = NUM_RECV_BUFFS_8;
 	else
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_16;
+		priv->num_recv_buffs = NUM_RECV_BUFFS_16;
 
 	printk(KERN_DEBUG "Memaddr: 0x%lx, Memsize: %d, ",
 				dev->mem_start, size);
@@ -546,6 +553,7 @@ static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 		if (!dev->irq) {
 			printk("?autoirq, Failed to detect IRQ line!\n");
 			retval = -EAGAIN;
+			iounmap(priv->mapped);
 			goto out;
 		}
 		printk("IRQ %d (autodetected).\n", dev->irq);
@@ -578,19 +586,19 @@ out:
 
 static int init586(struct net_device *dev)
 {
-	void *ptr;
+	void __iomem *ptr;
 	int i, result = 0;
 	struct priv *p = (struct priv *)dev->priv;
-	struct configure_cmd_struct *cfg_cmd;
-	struct iasetup_cmd_struct *ias_cmd;
-	struct tdr_cmd_struct *tdr_cmd;
-	struct mcsetup_cmd_struct *mc_cmd;
+	struct configure_cmd_struct __iomem *cfg_cmd;
+	struct iasetup_cmd_struct __iomem *ias_cmd;
+	struct tdr_cmd_struct __iomem *tdr_cmd;
+	struct mcsetup_cmd_struct __iomem *mc_cmd;
 	struct dev_mc_list *dmi = dev->mc_list;
 	int num_addrs = dev->mc_count;
 
-	ptr = (void *) ((char *)p->scb + sizeof(struct scb_struct));
+	ptr = p->scb + 1;
 
-	cfg_cmd = (struct configure_cmd_struct *)ptr; /* configure-command */
+	cfg_cmd = ptr; /* configure-command */
 	writew(0, &cfg_cmd->cmd_status);
 	writew(CMD_CONFIGURE | CMD_LAST, &cfg_cmd->cmd_cmd);
 	writew(0xFFFF, &cfg_cmd->cmd_link);
@@ -609,7 +617,7 @@ static int init586(struct net_device *dev)
 	writeb(0xf2, &cfg_cmd->time_high);
 	writeb(0x00, &cfg_cmd->promisc);;
 	if (dev->flags & IFF_ALLMULTI) {
-		int len = ((char *) p->iscp - (char *) ptr - 8) / 6;
+		int len = ((char __iomem *)p->iscp - (char __iomem *)ptr - 8) / 6;
 		if (num_addrs > len) {
 			printk(KERN_ERR "%s: switching to promisc. mode\n",
 				dev->name);
@@ -620,7 +628,7 @@ static int init586(struct net_device *dev)
 		writeb(0x01, &cfg_cmd->promisc);
 	writeb(0x00, &cfg_cmd->carr_coll);
 	writew(make16(cfg_cmd), &p->scb->cbl_offset);
-	writew(0, &p->scb->cmd_ruc);
+	writeb(0, &p->scb->cmd_ruc);
 
 	writeb(CUC_START, &p->scb->cmd_cuc); /* cmd.-unit start */
 	ni_attn586();
@@ -638,13 +646,13 @@ static int init586(struct net_device *dev)
 	 * individual address setup
 	 */
 
-	ias_cmd = (struct iasetup_cmd_struct *)ptr;
+	ias_cmd = ptr;
 
 	writew(0, &ias_cmd->cmd_status);
 	writew(CMD_IASETUP | CMD_LAST, &ias_cmd->cmd_cmd);
 	writew(0xffff, &ias_cmd->cmd_link);
 
-	memcpy_toio((char *)&ias_cmd->iaddr, (char *)dev->dev_addr, ETH_ALEN);
+	memcpy_toio(&ias_cmd->iaddr, (char *)dev->dev_addr, ETH_ALEN);
 
 	writew(make16(ias_cmd), &p->scb->cbl_offset);
 
@@ -663,7 +671,7 @@ static int init586(struct net_device *dev)
 	 * TDR, wire check .. e.g. no resistor e.t.c
 	 */
 
-	tdr_cmd = (struct tdr_cmd_struct *)ptr;
+	tdr_cmd = ptr;
 
 	writew(0, &tdr_cmd->cmd_status);
 	writew(CMD_TDR | CMD_LAST, &tdr_cmd->cmd_cmd);
@@ -707,14 +715,14 @@ static int init586(struct net_device *dev)
 	 * Multicast setup
 	 */
 	if (num_addrs && !(dev->flags & IFF_PROMISC)) {
-		mc_cmd = (struct mcsetup_cmd_struct *) ptr;
+		mc_cmd = ptr;
 		writew(0, &mc_cmd->cmd_status);
 		writew(CMD_MCSETUP | CMD_LAST, &mc_cmd->cmd_cmd);
 		writew(0xffff, &mc_cmd->cmd_link);
 		writew(num_addrs * 6, &mc_cmd->mc_cnt);
 
 		for (i = 0; i < num_addrs; i++, dmi = dmi->next)
-			memcpy_toio((char *) mc_cmd->mc_list[i],
+			memcpy_toio(mc_cmd->mc_list[i],
 							dmi->dmi_addr, 6);
 
 		writew(make16(mc_cmd), &p->scb->cbl_offset);
@@ -733,43 +741,43 @@ static int init586(struct net_device *dev)
 	 */
 #if (NUM_XMIT_BUFFS == 1)
 	for (i = 0; i < 2; i++) {
-		p->nop_cmds[i] = (struct nop_cmd_struct *)ptr;
+		p->nop_cmds[i] = ptr;
 		writew(CMD_NOP, &p->nop_cmds[i]->cmd_cmd);
 		writew(0, &p->nop_cmds[i]->cmd_status);
 		writew(make16(p->nop_cmds[i]), &p->nop_cmds[i]->cmd_link);
-		ptr = (char *) ptr + sizeof(struct nop_cmd_struct);
+		ptr = ptr + sizeof(struct nop_cmd_struct);
 	}
 #else
 	for (i = 0; i < NUM_XMIT_BUFFS; i++) {
-		p->nop_cmds[i] = (struct nop_cmd_struct *)ptr;
+		p->nop_cmds[i] = ptr;
 		writew(CMD_NOP, &p->nop_cmds[i]->cmd_cmd);
 		writew(0, &p->nop_cmds[i]->cmd_status);
 		writew(make16(p->nop_cmds[i]), &p->nop_cmds[i]->cmd_link);
-		ptr = (char *) ptr + sizeof(struct nop_cmd_struct);
+		ptr = ptr + sizeof(struct nop_cmd_struct);
 	}
 #endif
 
-	ptr = alloc_rfa(dev, (void *)ptr); /* init receive-frame-area */
+	ptr = alloc_rfa(dev, ptr); /* init receive-frame-area */
 
 	/*
 	 * alloc xmit-buffs / init xmit_cmds
 	 */
 	for (i = 0; i < NUM_XMIT_BUFFS; i++) {
 		/* Transmit cmd/buff 0 */
-		p->xmit_cmds[i] = (struct transmit_cmd_struct *)ptr;
-		ptr = (char *) ptr + sizeof(struct transmit_cmd_struct);
-		p->xmit_cbuffs[i] = (char *)ptr; /* char-buffs */
-		ptr = (char *) ptr + XMIT_BUFF_SIZE;
-		p->xmit_buffs[i] = (struct tbd_struct *)ptr; /* TBD */
-		ptr = (char *) ptr + sizeof(struct tbd_struct);
-		if ((void *)ptr > (void *)p->iscp) {
+		p->xmit_cmds[i] = ptr;
+		ptr = ptr + sizeof(struct transmit_cmd_struct);
+		p->xmit_cbuffs[i] = ptr; /* char-buffs */
+		ptr = ptr + XMIT_BUFF_SIZE;
+		p->xmit_buffs[i] = ptr; /* TBD */
+		ptr = ptr + sizeof(struct tbd_struct);
+		if ((void __iomem *)ptr > (void __iomem *)p->iscp) {
 			printk(KERN_ERR "%s: not enough shared-mem for your configuration!\n",
 				dev->name);
 			return 1;
 		}
-		memset_io((char *)(p->xmit_cmds[i]), 0,
+		memset_io(p->xmit_cmds[i], 0,
 					sizeof(struct transmit_cmd_struct));
-		memset_io((char *)(p->xmit_buffs[i]), 0,
+		memset_io(p->xmit_buffs[i], 0,
 					sizeof(struct tbd_struct));
 		writew(make16(p->nop_cmds[(i+1)%NUM_XMIT_BUFFS]),
 					&p->xmit_cmds[i]->cmd_link);
@@ -816,14 +824,14 @@ static int init586(struct net_device *dev)
  * It sets up the Receive Frame Area (RFA).
  */
 
-static void *alloc_rfa(struct net_device *dev, void *ptr)
+static void __iomem *alloc_rfa(struct net_device *dev, void __iomem *ptr)
 {
-	struct rfd_struct *rfd = (struct rfd_struct *)ptr;
-	struct rbd_struct *rbd;
+	struct rfd_struct __iomem *rfd = ptr;
+	struct rbd_struct __iomem *rbd;
 	int i;
 	struct priv *p = (struct priv *) dev->priv;
 
-	memset_io((char *) rfd, 0,
+	memset_io(rfd, 0,
 		sizeof(struct rfd_struct) * (p->num_recv_buffs + rfdadd));
 	p->rfd_first = rfd;
 
@@ -835,20 +843,19 @@ static void *alloc_rfa(struct net_device *dev, void *ptr)
 	/* RU suspend */
 	writeb(RFD_SUSP, &rfd[p->num_recv_buffs-1+rfdadd].last);
 
-	ptr = (void *) (rfd + (p->num_recv_buffs + rfdadd));
+	ptr = rfd + (p->num_recv_buffs + rfdadd);
 
-	rbd = (struct rbd_struct *) ptr;
-	ptr = (void *) (rbd + p->num_recv_buffs);
+	rbd = ptr;
+	ptr = rbd + p->num_recv_buffs;
 
 	 /* clr descriptors */
-	memset_io((char *)rbd, 0,
-			sizeof(struct rbd_struct) * (p->num_recv_buffs));
+	memset_io(rbd, 0, sizeof(struct rbd_struct) * (p->num_recv_buffs));
 
 	for (i = 0; i < p->num_recv_buffs; i++) {
 		writew(make16(rbd + (i+1) % p->num_recv_buffs), &rbd[i].next);
 		writew(RECV_BUFF_SIZE, &rbd[i].size);
 		writel(make24(ptr), &rbd[i].buffer);
-		ptr = (char *) ptr + RECV_BUFF_SIZE;
+		ptr = ptr + RECV_BUFF_SIZE;
 	}
 	p->rfd_top	= p->rfd_first;
 	p->rfd_last = p->rfd_first + (p->num_recv_buffs - 1 + rfdadd);
@@ -892,7 +899,7 @@ static irqreturn_t ni52_interrupt(int irq, void *dev_id)
 			if (readb(&p->scb->rus) & RU_SUSPEND) {
 				/* special case: RU_SUSPEND */
 				wait_for_scb_cmd(dev);
-				p->scb->cmd_ruc = RUC_RESUME;
+				writeb(RUC_RESUME, &p->scb->cmd_ruc);
 				ni_attn586();
 				wait_for_scb_cmd_ruc(dev);
 			} else {
@@ -919,7 +926,7 @@ static irqreturn_t ni52_interrupt(int irq, void *dev_id)
 
 		/* Wait for ack. (ni52_xmt_int can be faster than ack!!) */
 		wait_for_scb_cmd(dev);
-		if (p->scb->cmd_cuc) {	 /* timed out? */
+		if (readb(&p->scb->cmd_cuc)) {	 /* timed out? */
 			printk(KERN_ERR "%s: Acknowledge timed out.\n",
 				dev->name);
 			ni_disint();
@@ -942,14 +949,14 @@ static void ni52_rcv_int(struct net_device *dev)
 	int status, cnt = 0;
 	unsigned short totlen;
 	struct sk_buff *skb;
-	struct rbd_struct *rbd;
+	struct rbd_struct __iomem *rbd;
 	struct priv *p = (struct priv *)dev->priv;
 
 	if (debuglevel > 0)
 		printk("R");
 
 	for (; (status = readb(&p->rfd_top->stat_high)) & RFD_COMPL;) {
-		rbd = (struct rbd_struct *) make32(p->rfd_top->rbd_offset);
+		rbd = make32(readw(&p->rfd_top->rbd_offset));
 		if (status & RFD_OK) { /* frame received without error? */
 			totlen = readw(&rbd->status);
 			if (totlen & RBD_LAST) {
@@ -960,7 +967,7 @@ static void ni52_rcv_int(struct net_device *dev)
 				if (skb != NULL) {
 					skb_reserve(skb, 2);
 					skb_put(skb, totlen);
-					skb_copy_to_linear_data(skb, (char *)p->base + (unsigned long) rbd->buffer, totlen);
+					memcpy_fromio(skb->data, p->base + readl(&rbd->buffer), totlen);
 					skb->protocol = eth_type_trans(skb, dev);
 					netif_rx(skb);
 					dev->last_rx = jiffies;
@@ -979,7 +986,7 @@ static void ni52_rcv_int(struct net_device *dev)
 						break;
 					}
 					writew(0, &rbd->status);
-					rbd = (struct rbd_struct *) make32(readl(&rbd->next));
+					rbd = make32(readw(&rbd->next));
 				}
 				totlen += rstat & RBD_MASK;
 				writew(0, &rbd->status);
@@ -997,7 +1004,7 @@ static void ni52_rcv_int(struct net_device *dev)
 		writew(0xffff, &p->rfd_top->rbd_offset);
 		writeb(0, &p->rfd_last->last);	/* delete RFD_SUSP	*/
 		p->rfd_last = p->rfd_top;
-		p->rfd_top = (struct rfd_struct *) make32(p->rfd_top->next); /* step to next RFD */
+		p->rfd_top = make32(readw(&p->rfd_top->next)); /* step to next RFD */
 		writew(make16(p->rfd_top), &p->scb->rfa_offset);
 
 		if (debuglevel > 0)
@@ -1042,11 +1049,12 @@ static void ni52_rnr_int(struct net_device *dev)
 	ni_attn586();
 	wait_for_scb_cmd_ruc(dev);		/* wait for accept cmd. */
 
-	alloc_rfa(dev, (char *)p->rfd_first);
+	alloc_rfa(dev, p->rfd_first);
 	/* maybe add a check here, before restarting the RU */
 	startrecv586(dev); /* restart RU */
 
-	printk(KERN_ERR "%s: Receive-Unit restarted. Status: %04x\n", dev->name, p->scb->rus);
+	printk(KERN_ERR "%s: Receive-Unit restarted. Status: %04x\n",
+		dev->name, readb(&p->scb->rus));
 
 }
 
@@ -1178,12 +1186,11 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	skb_copy_from_linear_data(skb, (char *)p->xmit_cbuffs[p->xmit_count],
-							skb->len);
+	memcpy_toio(p->xmit_cbuffs[p->xmit_count], skb->data, skb->len);
 	len = skb->len;
 	if (len < ETH_ZLEN) {
 		len = ETH_ZLEN;
-		memset((char *)p->xmit_cbuffs[p->xmit_count]+skb->len, 0,
+		memset_io(p->xmit_cbuffs[p->xmit_count]+skb->len, 0,
 							len - skb->len);
 	}
 
@@ -1191,14 +1198,14 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 #	ifdef NO_NOPCOMMANDS
 
 #ifdef DEBUG
-	if (p->scb->cus & CU_ACTIVE) {
+	if (readb(&p->scb->cus) & CU_ACTIVE) {
 		printk(KERN_ERR "%s: Hmmm .. CU is still running and we wanna send a new packet.\n", dev->name);
 		printk(KERN_ERR "%s: stat: %04x %04x\n",
 				dev->name, readb(&p->scb->cus),
 				readw(&p->xmit_cmds[0]->cmd_status));
 	}
 #endif
-	writew(TBD_LAST | len, &p->xmit_buffs[0]->size);;
+	writew(TBD_LAST | len, &p->xmit_buffs[0]->size);
 	for (i = 0; i < 16; i++) {
 		writew(0, &p->xmit_cmds[0]->cmd_status);
 		wait_for_scb_cmd(dev);
@@ -1330,7 +1337,9 @@ int __init init_module(void)
 
 void __exit cleanup_module(void)
 {
+	struct priv *p = dev_ni52->priv;
 	unregister_netdev(dev_ni52);
+	iounmap(p->mapped);
 	release_region(dev_ni52->base_addr, NI52_TOTAL_SIZE);
 	free_netdev(dev_ni52);
 }
diff --git a/drivers/net/ni52.h b/drivers/net/ni52.h
index 1f28a4d..0a03b28 100644
--- a/drivers/net/ni52.h
+++ b/drivers/net/ni52.h
@@ -39,8 +39,8 @@ struct scp_struct
 	u16 zero_dum0;	/* has to be zero */
 	u8 sysbus;	/* 0=16Bit,1=8Bit */
 	u8 zero_dum1;	/* has to be zero for 586 */
-	u8 zero_dum2;
-	u8 zero_dum3;
+	u16 zero_dum2;
+	u16 zero_dum3;
 	u32 iscp;		/* pointer to the iscp-block */
 };
 
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 5b80358..f5310ed 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -99,6 +99,41 @@ static int bcm54xx_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+static int bcm5481_config_aneg(struct phy_device *phydev)
+{
+	int ret;
+
+	/* Aneg firsly. */
+	ret = genphy_config_aneg(phydev);
+
+	/* Then we can set up the delay. */
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) {
+		u16 reg;
+
+		/*
+		 * There is no BCM5481 specification available, so down
+		 * here is everything we know about "register 0x18". This
+		 * at least helps BCM5481 to successfuly receive packets
+		 * on MPC8360E-RDK board. Peter Barada <peterb@logicpd.com>
+		 * says: "This sets delay between the RXD and RXC signals
+		 * instead of using trace lengths to achieve timing".
+		 */
+
+		/* Set RDX clk delay. */
+		reg = 0x7 | (0x7 << 12);
+		phy_write(phydev, 0x18, reg);
+
+		reg = phy_read(phydev, 0x18);
+		/* Set RDX-RXC skew. */
+		reg |= (1 << 8);
+		/* Write bits 14:0. */
+		reg |= (1 << 15);
+		phy_write(phydev, 0x18, reg);
+	}
+
+	return ret;
+}
+
 static struct phy_driver bcm5411_driver = {
 	.phy_id		= 0x00206070,
 	.phy_id_mask	= 0xfffffff0,
@@ -141,8 +176,22 @@ static struct phy_driver bcm5461_driver = {
 	.driver 	= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcm5481_driver = {
+	.phy_id		= 0x0143bca0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM5481",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= bcm5481_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm54xx_ack_interrupt,
+	.config_intr	= bcm54xx_config_intr,
+	.driver 	= { .owner = THIS_MODULE },
+};
+
 static struct phy_driver bcm5482_driver = {
-    .phy_id		= 0x0143bcb0,
+	.phy_id		= 0x0143bcb0,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5482",
 	.features	= PHY_GBIT_FEATURES,
@@ -168,12 +217,17 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm5461_driver);
 	if (ret)
 		goto out_5461;
+	ret = phy_driver_register(&bcm5481_driver);
+	if (ret)
+		goto out_5481;
 	ret = phy_driver_register(&bcm5482_driver);
 	if (ret)
 		goto out_5482;
 	return ret;
 
 out_5482:
+	phy_driver_unregister(&bcm5481_driver);
+out_5481:
 	phy_driver_unregister(&bcm5461_driver);
 out_5461:
 	phy_driver_unregister(&bcm5421_driver);
@@ -186,6 +240,7 @@ out_5411:
 static void __exit broadcom_exit(void)
 {
 	phy_driver_unregister(&bcm5482_driver);
+	phy_driver_unregister(&bcm5481_driver);
 	phy_driver_unregister(&bcm5461_driver);
 	phy_driver_unregister(&bcm5421_driver);
 	phy_driver_unregister(&bcm5411_driver);
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index a6aeb9d..b7f7b22 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2472,8 +2472,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 
 	if (seg_cnt == 1) {
 		/* Terminate the last segment. */
-		oal_entry->len =
-		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
 	} else {
 		oal = tx_cb->oal;
 		for (completed_segs=0; completed_segs<frag_cnt; completed_segs++,seg++) {
@@ -2530,8 +2529,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 					  frag->size);
 		}
 		/* Terminate the last segment. */
-		oal_entry->len =
-		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
 	}
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6d8e5c4..86f1228 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4267,11 +4267,12 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		txdp->Control_1 |= TXD_UFO_MSS(ufo_size);
 		txdp->Control_1 |= TXD_BUFFER0_SIZE(8);
 #ifdef __BIG_ENDIAN
+		/* both variants do cpu_to_be64(be32_to_cpu(...)) */
 		fifo->ufo_in_band_v[put_off] =
-				(u64)skb_shinfo(skb)->ip6_frag_id;
+				(__force u64)skb_shinfo(skb)->ip6_frag_id;
 #else
 		fifo->ufo_in_band_v[put_off] =
-				(u64)skb_shinfo(skb)->ip6_frag_id << 32;
+				(__force u64)skb_shinfo(skb)->ip6_frag_id << 32;
 #endif
 		txdp->Host_Control = (unsigned long)fifo->ufo_in_band_v;
 		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
@@ -7089,11 +7090,11 @@ static int s2io_add_isr(struct s2io_nic * sp)
 				if(!(sp->msix_info[i].addr &&
 					sp->msix_info[i].data)) {
 					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx "
-						"Data:0x%lx\n",sp->desc[i],
+						"Data:0x%llx\n",sp->desc[i],
 						(unsigned long long)
 						sp->msix_info[i].addr,
-						(unsigned long)
-						ntohl(sp->msix_info[i].data));
+						(unsigned long long)
+						sp->msix_info[i].data);
 				} else {
 					msix_tx_cnt++;
 				}
@@ -7107,11 +7108,11 @@ static int s2io_add_isr(struct s2io_nic * sp)
 				if(!(sp->msix_info[i].addr &&
 					sp->msix_info[i].data)) {
 					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx "
-						"Data:0x%lx\n",sp->desc[i],
+						"Data:0x%llx\n",sp->desc[i],
 						(unsigned long long)
 						sp->msix_info[i].addr,
-						(unsigned long)
-						ntohl(sp->msix_info[i].data));
+						(unsigned long long)
+						sp->msix_info[i].data);
 				} else {
 					msix_rx_cnt++;
 				}
diff --git a/drivers/net/skfp/fplustm.c b/drivers/net/skfp/fplustm.c
index 76dc8ad..6028bbb 100644
--- a/drivers/net/skfp/fplustm.c
+++ b/drivers/net/skfp/fplustm.c
@@ -401,18 +401,18 @@ static void copy_tx_mac(struct s_smc *smc, u_long td, struct fddi_mac *mac,
 /* int len ;		 length of the frame including the FC */
 {
 	int	i ;
-	u_int	*p ;
+	__le32	*p ;
 
 	CHECK_NPP() ;
 	MARW(off) ;		/* set memory address reg for writes */
 
-	p = (u_int *) mac ;
+	p = (__le32 *) mac ;
 	for (i = (len + 3)/4 ; i ; i--) {
 		if (i == 1) {
 			/* last word, set the tag bit */
 			outpw(FM_A(FM_CMDREG2),FM_ISTTB) ;
 		}
-		write_mdr(smc,MDR_REVERSE(*p)) ;
+		write_mdr(smc,le32_to_cpu(*p)) ;
 		p++ ;
 	}
 
@@ -444,7 +444,7 @@ static void copy_tx_mac(struct s_smc *smc, u_long td, struct fddi_mac *mac,
  */
 static void directed_beacon(struct s_smc *smc)
 {
-	SK_LOC_DECL(u_int,a[2]) ;
+	SK_LOC_DECL(__le32,a[2]) ;
 
 	/*
 	 * set UNA in frame
@@ -458,9 +458,9 @@ static void directed_beacon(struct s_smc *smc)
 	CHECK_NPP() ;
 	 /* set memory address reg for writes */
 	MARW(smc->hw.fp.fifo.rbc_ram_start+DBEACON_FRAME_OFF+4) ;
-	write_mdr(smc,MDR_REVERSE(a[0])) ;
+	write_mdr(smc,le32_to_cpu(a[0])) ;
 	outpw(FM_A(FM_CMDREG2),FM_ISTTB) ;	/* set the tag bit */
-	write_mdr(smc,MDR_REVERSE(a[1])) ;
+	write_mdr(smc,le32_to_cpu(a[1])) ;
 
 	outpw(FM_A(FM_SABC),smc->hw.fp.fifo.rbc_ram_start + DBEACON_FRAME_OFF) ;
 }
diff --git a/drivers/net/skfp/h/fplustm.h b/drivers/net/skfp/h/fplustm.h
index 98bbf65..6d738e1 100644
--- a/drivers/net/skfp/h/fplustm.h
+++ b/drivers/net/skfp/h/fplustm.h
@@ -50,12 +50,12 @@ struct err_st {
  *	Transmit Descriptor struct
  */
 struct s_smt_fp_txd {
-	u_int txd_tbctrl ;		/* transmit buffer control */
-	u_int txd_txdscr ;		/* transmit frame status word */
-	u_int txd_tbadr ;		/* physical tx buffer address */
-	u_int txd_ntdadr ;		/* physical pointer to the next TxD */
+	__le32 txd_tbctrl ;		/* transmit buffer control */
+	__le32 txd_txdscr ;		/* transmit frame status word */
+	__le32 txd_tbadr ;		/* physical tx buffer address */
+	__le32 txd_ntdadr ;		/* physical pointer to the next TxD */
 #ifdef	ENA_64BIT_SUP
-	u_int txd_tbadr_hi ;		/* physical tx buffer addr (high dword)*/
+	__le32 txd_tbadr_hi ;		/* physical tx buffer addr (high dword)*/
 #endif
 	char far *txd_virt ;		/* virtual pointer to the data frag */
 					/* virt pointer to the next TxD */
@@ -67,12 +67,12 @@ struct s_smt_fp_txd {
  *	Receive Descriptor struct
  */
 struct s_smt_fp_rxd {
-	u_int rxd_rbctrl ;		/* receive buffer control */
-	u_int rxd_rfsw ;		/* receive frame status word */
-	u_int rxd_rbadr ;		/* physical rx buffer address */
-	u_int rxd_nrdadr ;		/* physical pointer to the next RxD */
+	__le32 rxd_rbctrl ;		/* receive buffer control */
+	__le32 rxd_rfsw ;		/* receive frame status word */
+	__le32 rxd_rbadr ;		/* physical rx buffer address */
+	__le32 rxd_nrdadr ;		/* physical pointer to the next RxD */
 #ifdef	ENA_64BIT_SUP
-	u_int rxd_rbadr_hi ;		/* physical tx buffer addr (high dword)*/
+	__le32 rxd_rbadr_hi ;		/* physical tx buffer addr (high dword)*/
 #endif
 	char far *rxd_virt ;		/* virtual pointer to the data frag */
 					/* virt pointer to the next RxD */
diff --git a/drivers/net/skfp/hwmtm.c b/drivers/net/skfp/hwmtm.c
index 46e3393..4218e97 100644
--- a/drivers/net/skfp/hwmtm.c
+++ b/drivers/net/skfp/hwmtm.c
@@ -208,7 +208,7 @@ SMbuf* smt_get_mbuf(struct s_smc *smc);
 #if	defined(NDIS_OS2) || defined(ODI2)
 #define CR_READ(var)	((var) & 0xffff0000 | ((var) & 0xffff))
 #else
-#define CR_READ(var)	(u_long)(var)
+#define CR_READ(var)	(__le32)(var)
 #endif
 
 #define IMASK_SLOW	(IS_PLINT1 | IS_PLINT2 | IS_TIMINT | IS_TOKEN | \
@@ -343,16 +343,16 @@ static u_long init_descr_ring(struct s_smc *smc,
 	for (i=count-1, d1=start; i ; i--) {
 		d2 = d1 ;
 		d1++ ;		/* descr is owned by the host */
-		d2->r.rxd_rbctrl = AIX_REVERSE(BMU_CHECK) ;
+		d2->r.rxd_rbctrl = cpu_to_le32(BMU_CHECK) ;
 		d2->r.rxd_next = &d1->r ;
 		phys = mac_drv_virt2phys(smc,(void *)d1) ;
-		d2->r.rxd_nrdadr = AIX_REVERSE(phys) ;
+		d2->r.rxd_nrdadr = cpu_to_le32(phys) ;
 	}
 	DB_GEN("descr ring ends at = %x ",(void *)d1,0,3) ;
-	d1->r.rxd_rbctrl = AIX_REVERSE(BMU_CHECK) ;
+	d1->r.rxd_rbctrl = cpu_to_le32(BMU_CHECK) ;
 	d1->r.rxd_next = &start->r ;
 	phys = mac_drv_virt2phys(smc,(void *)start) ;
-	d1->r.rxd_nrdadr = AIX_REVERSE(phys) ;
+	d1->r.rxd_nrdadr = cpu_to_le32(phys) ;
 
 	for (i=count, d1=start; i ; i--) {
 		DRV_BUF_FLUSH(&d1->r,DDI_DMA_SYNC_FORDEV) ;
@@ -376,7 +376,7 @@ static void init_txd_ring(struct s_smc *smc)
 	DB_GEN("Init async TxD ring, %d TxDs ",HWM_ASYNC_TXD_COUNT,0,3) ;
 	(void)init_descr_ring(smc,(union s_fp_descr volatile *)ds,
 		HWM_ASYNC_TXD_COUNT) ;
-	phys = AIX_REVERSE(ds->txd_ntdadr) ;
+	phys = le32_to_cpu(ds->txd_ntdadr) ;
 	ds++ ;
 	queue->tx_curr_put = queue->tx_curr_get = ds ;
 	ds-- ;
@@ -390,7 +390,7 @@ static void init_txd_ring(struct s_smc *smc)
 	DB_GEN("Init sync TxD ring, %d TxDs ",HWM_SYNC_TXD_COUNT,0,3) ;
 	(void)init_descr_ring(smc,(union s_fp_descr volatile *)ds,
 		HWM_SYNC_TXD_COUNT) ;
-	phys = AIX_REVERSE(ds->txd_ntdadr) ;
+	phys = le32_to_cpu(ds->txd_ntdadr) ;
 	ds++ ;
 	queue->tx_curr_put = queue->tx_curr_get = ds ;
 	queue->tx_free = HWM_SYNC_TXD_COUNT ;
@@ -412,7 +412,7 @@ static void init_rxd_ring(struct s_smc *smc)
 	DB_GEN("Init RxD ring, %d RxDs ",SMT_R1_RXD_COUNT,0,3) ;
 	(void)init_descr_ring(smc,(union s_fp_descr volatile *)ds,
 		SMT_R1_RXD_COUNT) ;
-	phys = AIX_REVERSE(ds->rxd_nrdadr) ;
+	phys = le32_to_cpu(ds->rxd_nrdadr) ;
 	ds++ ;
 	queue->rx_curr_put = queue->rx_curr_get = ds ;
 	queue->rx_free = SMT_R1_RXD_COUNT ;
@@ -607,12 +607,12 @@ static u_long repair_txd_ring(struct s_smc *smc, struct s_smt_tx_queue *queue)
 	for (i = tx_used+queue->tx_free-1 ; i ; i-- ) {
 		t = t->txd_next ;
 	}
-	phys = AIX_REVERSE(t->txd_ntdadr) ;
+	phys = le32_to_cpu(t->txd_ntdadr) ;
 
 	t = queue->tx_curr_get ;
 	while (tx_used) {
 		DRV_BUF_FLUSH(t,DDI_DMA_SYNC_FORCPU) ;
-		tbctrl = AIX_REVERSE(t->txd_tbctrl) ;
+		tbctrl = le32_to_cpu(t->txd_tbctrl) ;
 
 		if (tbctrl & BMU_OWN) {
 			if (tbctrl & BMU_STF) {
@@ -622,10 +622,10 @@ static u_long repair_txd_ring(struct s_smc *smc, struct s_smt_tx_queue *queue)
 				/*
 				 * repair the descriptor
 				 */
-				t->txd_tbctrl &= AIX_REVERSE(~BMU_OWN) ;
+				t->txd_tbctrl &= ~cpu_to_le32(BMU_OWN) ;
 			}
 		}
-		phys = AIX_REVERSE(t->txd_ntdadr) ;
+		phys = le32_to_cpu(t->txd_ntdadr) ;
 		DRV_BUF_FLUSH(t,DDI_DMA_SYNC_FORDEV) ;
 		t = t->txd_next ;
 		tx_used-- ;
@@ -659,12 +659,12 @@ static u_long repair_rxd_ring(struct s_smc *smc, struct s_smt_rx_queue *queue)
 	for (i = SMT_R1_RXD_COUNT-1 ; i ; i-- ) {
 		r = r->rxd_next ;
 	}
-	phys = AIX_REVERSE(r->rxd_nrdadr) ;
+	phys = le32_to_cpu(r->rxd_nrdadr) ;
 
 	r = queue->rx_curr_get ;
 	while (rx_used) {
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
-		rbctrl = AIX_REVERSE(r->rxd_rbctrl) ;
+		rbctrl = le32_to_cpu(r->rxd_rbctrl) ;
 
 		if (rbctrl & BMU_OWN) {
 			if (rbctrl & BMU_STF) {
@@ -674,10 +674,10 @@ static u_long repair_rxd_ring(struct s_smc *smc, struct s_smt_rx_queue *queue)
 				/*
 				 * repair the descriptor
 				 */
-				r->rxd_rbctrl &= AIX_REVERSE(~BMU_OWN) ;
+				r->rxd_rbctrl &= ~cpu_to_le32(BMU_OWN) ;
 			}
 		}
-		phys = AIX_REVERSE(r->rxd_nrdadr) ;
+		phys = le32_to_cpu(r->rxd_nrdadr) ;
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORDEV) ;
 		r = r->rxd_next ;
 		rx_used-- ;
@@ -1094,8 +1094,7 @@ void process_receive(struct s_smc *smc)
 		do {
 			DB_RX("Check RxD %x for OWN and EOF",(void *)r,0,5) ;
 			DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
-			rbctrl = CR_READ(r->rxd_rbctrl) ;
-			rbctrl = AIX_REVERSE(rbctrl) ;
+			rbctrl = le32_to_cpu(CR_READ(r->rxd_rbctrl));
 
 			if (rbctrl & BMU_OWN) {
 				NDD_TRACE("RHxE",r,rfsw,rbctrl) ;
@@ -1118,7 +1117,7 @@ void process_receive(struct s_smc *smc)
 				smc->os.hwm.detec_count = 0 ;
 				goto rx_end ;
 			}
-			rfsw = AIX_REVERSE(r->rxd_rfsw) ;
+			rfsw = le32_to_cpu(r->rxd_rfsw) ;
 			if ((rbctrl & BMU_STF) != ((rbctrl & BMU_ST_BUF) <<5)) {
 				/*
 				 * The BMU_STF bit is deleted, 1 frame is
@@ -1151,7 +1150,7 @@ void process_receive(struct s_smc *smc)
 		/* may be next 2 DRV_BUF_FLUSH() can be skipped, because */
 		/* BMU_ST_BUF will not be changed by the ASIC */
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
-		while (rx_used && !(r->rxd_rbctrl & AIX_REVERSE(BMU_ST_BUF))) {
+		while (rx_used && !(r->rxd_rbctrl & cpu_to_le32(BMU_ST_BUF))) {
 			DB_RX("Check STF bit in %x",(void *)r,0,5) ;
 			r = r->rxd_next ;
 			DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
@@ -1171,7 +1170,7 @@ void process_receive(struct s_smc *smc)
 		/*
 		 * ASIC Errata no. 7 (STF - Bit Bug)
 		 */
-		rxd->rxd_rbctrl &= AIX_REVERSE(~BMU_STF) ;
+		rxd->rxd_rbctrl &= cpu_to_le32(~BMU_STF) ;
 
 		for (r=rxd, i=frag_count ; i ; r=r->rxd_next, i--){
 			DB_RX("dma_complete for RxD %x",(void *)r,0,5) ;
@@ -1287,7 +1286,7 @@ void process_receive(struct s_smc *smc)
 			hwm_cpy_rxd2mb(rxd,data,len) ;
 #else
 			for (r=rxd, i=used_frags ; i ; r=r->rxd_next, i--){
-				n = AIX_REVERSE(r->rxd_rbctrl) & RD_LENGTH ;
+				n = le32_to_cpu(r->rxd_rbctrl) & RD_LENGTH ;
 				DB_RX("cp SMT frame to mb: len = %d",n,0,6) ;
 				memcpy(data,r->rxd_virt,n) ;
 				data += n ;
@@ -1426,14 +1425,14 @@ void hwm_rx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
 		 int frame_status)
 {
 	struct s_smt_fp_rxd volatile *r ;
-	u_int	rbctrl ;
+	__le32	rbctrl;
 
 	NDD_TRACE("RHfB",virt,len,frame_status) ;
 	DB_RX("hwm_rx_frag: len = %d, frame_status = %x\n",len,frame_status,2) ;
 	r = smc->hw.fp.rx_q[QUEUE_R1].rx_curr_put ;
 	r->rxd_virt = virt ;
-	r->rxd_rbadr = AIX_REVERSE(phys) ;
-	rbctrl = AIX_REVERSE( (((u_long)frame_status &
+	r->rxd_rbadr = cpu_to_le32(phys) ;
+	rbctrl = cpu_to_le32( (((__u32)frame_status &
 		(FIRST_FRAG|LAST_FRAG))<<26) |
 		(((u_long) frame_status & FIRST_FRAG) << 21) |
 		BMU_OWN | BMU_CHECK | BMU_EN_IRQ_EOF | len) ;
@@ -1444,7 +1443,7 @@ void hwm_rx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
 	smc->hw.fp.rx_q[QUEUE_R1].rx_free-- ;
 	smc->hw.fp.rx_q[QUEUE_R1].rx_used++ ;
 	smc->hw.fp.rx_q[QUEUE_R1].rx_curr_put = r->rxd_next ;
-	NDD_TRACE("RHfE",r,AIX_REVERSE(r->rxd_rbadr),0) ;
+	NDD_TRACE("RHfE",r,le32_to_cpu(r->rxd_rbadr),0) ;
 }
 
 /*
@@ -1494,15 +1493,15 @@ void mac_drv_clear_rx_queue(struct s_smc *smc)
 	while (queue->rx_used) {
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
 		DB_RX("switch OWN bit of RxD 0x%x ",r,0,5) ;
-		r->rxd_rbctrl &= AIX_REVERSE(~BMU_OWN) ;
+		r->rxd_rbctrl &= ~cpu_to_le32(BMU_OWN) ;
 		frag_count = 1 ;
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORDEV) ;
 		r = r->rxd_next ;
 		DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
 		while (r != queue->rx_curr_put &&
-			!(r->rxd_rbctrl & AIX_REVERSE(BMU_ST_BUF))) {
+			!(r->rxd_rbctrl & cpu_to_le32(BMU_ST_BUF))) {
 			DB_RX("Check STF bit in %x",(void *)r,0,5) ;
-			r->rxd_rbctrl &= AIX_REVERSE(~BMU_OWN) ;
+			r->rxd_rbctrl &= ~cpu_to_le32(BMU_OWN) ;
 			DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORDEV) ;
 			r = r->rxd_next ;
 			DRV_BUF_FLUSH(r,DDI_DMA_SYNC_FORCPU) ;
@@ -1640,7 +1639,7 @@ void hwm_tx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
 {
 	struct s_smt_fp_txd volatile *t ;
 	struct s_smt_tx_queue *queue ;
-	u_int	tbctrl ;
+	__le32	tbctrl ;
 
 	queue = smc->os.hwm.tx_p ;
 
@@ -1657,9 +1656,9 @@ void hwm_tx_frag(struct s_smc *smc, char far *virt, u_long phys, int len,
 		/* '*t' is already defined */
 		DB_TX("LAN_TX: TxD = %x, virt = %x ",t,virt,3) ;
 		t->txd_virt = virt ;
-		t->txd_txdscr = AIX_REVERSE(smc->os.hwm.tx_descr) ;
-		t->txd_tbadr = AIX_REVERSE(phys) ;
-		tbctrl = AIX_REVERSE((((u_long)frame_status &
+		t->txd_txdscr = cpu_to_le32(smc->os.hwm.tx_descr) ;
+		t->txd_tbadr = cpu_to_le32(phys) ;
+		tbctrl = cpu_to_le32((((__u32)frame_status &
 			(FIRST_FRAG|LAST_FRAG|EN_IRQ_EOF))<< 26) |
 			BMU_OWN|BMU_CHECK |len) ;
 		t->txd_tbctrl = tbctrl ;
@@ -1826,7 +1825,7 @@ void smt_send_mbuf(struct s_smc *smc, SMbuf *mb, int fc)
 	struct s_smt_tx_queue *queue ;
 	struct s_smt_fp_txd volatile *t ;
 	u_long	phys ;
-	u_int	tbctrl ;
+	__le32	tbctrl;
 
 	NDD_TRACE("THSB",mb,fc,0) ;
 	DB_TX("smt_send_mbuf: mb = 0x%x, fc = 0x%x",mb,fc,4) ;
@@ -1894,14 +1893,14 @@ void smt_send_mbuf(struct s_smc *smc, SMbuf *mb, int fc)
 			DB_TX("init TxD = 0x%x",(void *)t,0,5) ;
 			if (i == frag_count-1) {
 				frame_status |= LAST_FRAG ;
-				t->txd_txdscr = AIX_REVERSE(TX_DESCRIPTOR |
-					(((u_long)(mb->sm_len-1)&3) << 27)) ;
+				t->txd_txdscr = cpu_to_le32(TX_DESCRIPTOR |
+					(((__u32)(mb->sm_len-1)&3) << 27)) ;
 			}
 			t->txd_virt = virt[i] ;
 			phys = dma_master(smc, (void far *)virt[i],
 				frag_len[i], DMA_RD|SMT_BUF) ;
-			t->txd_tbadr = AIX_REVERSE(phys) ;
-			tbctrl = AIX_REVERSE((((u_long) frame_status &
+			t->txd_tbadr = cpu_to_le32(phys) ;
+			tbctrl = cpu_to_le32((((__u32)frame_status &
 				(FIRST_FRAG|LAST_FRAG)) << 26) |
 				BMU_OWN | BMU_CHECK | BMU_SMT_TX |frag_len[i]) ;
 			t->txd_tbctrl = tbctrl ;
@@ -1971,8 +1970,7 @@ static void mac_drv_clear_txd(struct s_smc *smc)
 			do {
 				DRV_BUF_FLUSH(t1,DDI_DMA_SYNC_FORCPU) ;
 				DB_TX("check OWN/EOF bit of TxD 0x%x",t1,0,5) ;
-				tbctrl = CR_READ(t1->txd_tbctrl) ;
-				tbctrl = AIX_REVERSE(tbctrl) ;
+				tbctrl = le32_to_cpu(CR_READ(t1->txd_tbctrl));
 
 				if (tbctrl & BMU_OWN || !queue->tx_used){
 					DB_TX("End of TxDs queue %d",i,0,4) ;
@@ -1984,7 +1982,7 @@ static void mac_drv_clear_txd(struct s_smc *smc)
 
 			t1 = queue->tx_curr_get ;
 			for (n = frag_count; n; n--) {
-				tbctrl = AIX_REVERSE(t1->txd_tbctrl) ;
+				tbctrl = le32_to_cpu(t1->txd_tbctrl) ;
 				dma_complete(smc,
 					(union s_fp_descr volatile *) t1,
 					(int) (DMA_RD |
@@ -2064,7 +2062,7 @@ void mac_drv_clear_tx_queue(struct s_smc *smc)
 		while (tx_used) {
 			DRV_BUF_FLUSH(t,DDI_DMA_SYNC_FORCPU) ;
 			DB_TX("switch OWN bit of TxD 0x%x ",t,0,5) ;
-			t->txd_tbctrl &= AIX_REVERSE(~BMU_OWN) ;
+			t->txd_tbctrl &= ~cpu_to_le32(BMU_OWN) ;
 			DRV_BUF_FLUSH(t,DDI_DMA_SYNC_FORDEV) ;
 			t = t->txd_next ;
 			tx_used-- ;
@@ -2086,10 +2084,10 @@ void mac_drv_clear_tx_queue(struct s_smc *smc)
 		 * tx_curr_get and tx_curr_put to this position
 		 */
 		if (i == QUEUE_S) {
-			outpd(ADDR(B5_XS_DA),AIX_REVERSE(t->txd_ntdadr)) ;
+			outpd(ADDR(B5_XS_DA),le32_to_cpu(t->txd_ntdadr)) ;
 		}
 		else {
-			outpd(ADDR(B5_XA_DA),AIX_REVERSE(t->txd_ntdadr)) ;
+			outpd(ADDR(B5_XA_DA),le32_to_cpu(t->txd_ntdadr)) ;
 		}
 
 		queue->tx_curr_put = queue->tx_curr_get->txd_next ;
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 7cf9b9f..a2b092b 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -495,7 +495,7 @@ static int skfp_open(struct net_device *dev)
 
 	PRINTK(KERN_INFO "entering skfp_open\n");
 	/* Register IRQ - support shared interrupts by passing device ptr */
-	err = request_irq(dev->irq, (void *) skfp_interrupt, IRQF_SHARED,
+	err = request_irq(dev->irq, skfp_interrupt, IRQF_SHARED,
 			  dev->name, dev);
 	if (err)
 		return err;
@@ -1644,7 +1644,7 @@ void mac_drv_rx_complete(struct s_smc *smc, volatile struct s_smt_fp_rxd *rxd,
 		// Get RIF length from Routing Control (RC) field.
 		cp = virt + FDDI_MAC_HDR_LEN;	// Point behind MAC header.
 
-		ri = ntohs(*((unsigned short *) cp));
+		ri = ntohs(*((__be16 *) cp));
 		RifLength = ri & FDDI_RCF_LEN_MASK;
 		if (len < (int) (FDDI_MAC_HDR_LEN + RifLength)) {
 			printk("fddi: Invalid RIF.\n");
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 4b131a6..81ccdfa 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -155,7 +155,7 @@ static void dm_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
 	dm_write_async_helper(dev, reg, value, 0, NULL);
 }
 
-static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, u16 *value)
+static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *value)
 {
 	int ret, i;
 
@@ -194,7 +194,7 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, u16 *value)
 	return ret;
 }
 
-static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg, u16 value)
+static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 value)
 {
 	int ret, i;
 
@@ -249,7 +249,7 @@ static int dm9601_get_eeprom(struct net_device *net,
 			     struct ethtool_eeprom *eeprom, u8 * data)
 {
 	struct usbnet *dev = netdev_priv(net);
-	u16 *ebuf = (u16 *) data;
+	__le16 *ebuf = (__le16 *) data;
 	int i;
 
 	/* access is 16bit */
@@ -268,7 +268,7 @@ static int dm9601_mdio_read(struct net_device *netdev, int phy_id, int loc)
 {
 	struct usbnet *dev = netdev_priv(netdev);
 
-	u16 res;
+	__le16 res;
 
 	if (phy_id) {
 		devdbg(dev, "Only internal phy supported");
@@ -288,7 +288,7 @@ static void dm9601_mdio_write(struct net_device *netdev, int phy_id, int loc,
 			      int val)
 {
 	struct usbnet *dev = netdev_priv(netdev);
-	u16 res = cpu_to_le16(val);
+	__le16 res = cpu_to_le16(val);
 
 	if (phy_id) {
 		devdbg(dev, "Only internal phy supported");
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 727547a..06ae1b2 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -218,7 +218,7 @@ EXPORT_SYMBOL_GPL(rndis_command);
  * ActiveSync 4.1 Windows driver.
  */
 static int rndis_query(struct usbnet *dev, struct usb_interface *intf,
-		void *buf, u32 oid, u32 in_len,
+		void *buf, __le32 oid, u32 in_len,
 		void **reply, int *reply_len)
 {
 	int retval;
@@ -283,7 +283,8 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 		struct rndis_set_c	*set_c;
 		struct rndis_halt	*halt;
 	} u;
-	u32			tmp, *phym;
+	u32			tmp;
+	__le32			*phym;
 	int			reply_len;
 	unsigned char		*bp;
 
