From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 11 Apr 2007 14:04:53 -0400
Message-ID: <20070411180453.GA2064@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753499AbXDKSE7@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/cxgb3/common.h                   |    7 +-
 drivers/net/cxgb3/cxgb3_main.c               |   16 ++--
 drivers/net/cxgb3/cxgb3_offload.c            |   14 +---
 drivers/net/cxgb3/regs.h                     |    6 ++
 drivers/net/cxgb3/xgmac.c                    |  107 +++++++++++++++++++-------
 drivers/net/myri10ge/myri10ge.c              |   37 ++++++---
 drivers/net/skge.c                           |   93 ++++++++++++++---------
 drivers/net/sky2.c                           |   12 ++-
 drivers/net/wireless/bcm43xx/bcm43xx_main.c  |   20 +++++-
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c   |   57 ++++++++------
 drivers/net/wireless/zd1211rw/zd_chip.c      |   12 +--
 drivers/net/wireless/zd1211rw/zd_chip.h      |    4 +-
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c |    6 ++
 13 files changed, 257 insertions(+), 134 deletions(-)

Brice Goglin (3):
      myri10ge: fix management of the firmware 4KB boundary crossing restriction
      myri10ge: more Intel chipsets providing aligned PCIe completions
      myri10ge: update driver version to 1.3.0-1.233

Daniel Drake (2):
      zd1211rw: Reject AL2230S devices
      zd1211rw: Fix E2P_PHY_REG patching

Divy Le Ray (3):
      cxgb3 - avoid deadlock with mac watchdog
      cxgb3 - MAC watchdog update
      cxgb3 - missing CPL hanler and register setting.

Larry Finger (2):
      bcm43xx: Fix 802.11b/g scan limits to match regulatory reqs
      bcm43xx: Fix PPC machine checks and match loopback gain specs

Stephen Hemminger (5):
      skge: turn carrier off when down
      sky2: turn carrier off when down
      sky2: turn on clocks when doing resume
      sky2: phy workarounds for Yukon EC-U A1
      skge: fix wake on lan

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 97128d8..8d13796 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -478,8 +478,11 @@ struct cmac {
 	struct adapter *adapter;
 	unsigned int offset;
 	unsigned int nucast;	/* # of address filters for unicast MACs */
-	unsigned int tcnt;
-	unsigned int xcnt;
+	unsigned int tx_tcnt;
+	unsigned int tx_xcnt;
+	u64 tx_mcnt;
+	unsigned int rx_xcnt;
+	u64 rx_mcnt;
 	unsigned int toggle_cnt;
 	unsigned int txen;
 	struct mac_stats stats;
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 26240fd..67b4b21 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -194,15 +194,13 @@ void t3_os_link_changed(struct adapter *adapter, int port_id, int link_stat,
 
 	if (link_stat != netif_carrier_ok(dev)) {
 		if (link_stat) {
-			t3_set_reg_field(adapter,
-					 A_XGM_TXFIFO_CFG + mac->offset,
-					 F_ENDROPPKT, 0);
+			t3_mac_enable(mac, MAC_DIRECTION_RX);
 			netif_carrier_on(dev);
 		} else {
 			netif_carrier_off(dev);
-			t3_set_reg_field(adapter,
-					 A_XGM_TXFIFO_CFG + mac->offset,
-					 F_ENDROPPKT, F_ENDROPPKT);
+			pi->phy.ops->power_down(&pi->phy, 1);
+			t3_mac_disable(mac, MAC_DIRECTION_RX);
+			t3_link_start(&pi->phy, mac, &pi->link_config);
 		}
 
 		link_report(dev);
@@ -772,6 +770,8 @@ static int cxgb_up(struct adapter *adap)
 		if (err)
 			goto out;
 
+		t3_write_reg(adap, A_ULPRX_TDDP_PSZ, V_HPZ0(PAGE_SHIFT - 12));
+		
 		err = setup_sge_qsets(adap);
 		if (err)
 			goto out;
@@ -2119,7 +2119,9 @@ static void check_t3b2_mac(struct adapter *adapter)
 {
 	int i;
 
-	rtnl_lock();                      /* synchronize with ifdown */
+	if (!rtnl_trylock())	/* synchronize with ifdown */
+		return;
+
 	for_each_port(adapter, i) {
 		struct net_device *dev = adapter->port[i];
 		struct port_info *p = netdev_priv(dev);
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index eed7a48..4864924 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -743,17 +743,6 @@ static int do_act_establish(struct t3cdev *dev, struct sk_buff *skb)
 	}
 }
 
-static int do_set_tcb_rpl(struct t3cdev *dev, struct sk_buff *skb)
-{
-	struct cpl_set_tcb_rpl *rpl = cplhdr(skb);
-
-	if (rpl->status != CPL_ERR_NONE)
-		printk(KERN_ERR
-		       "Unexpected SET_TCB_RPL status %u for tid %u\n",
-		       rpl->status, GET_TID(rpl));
-	return CPL_RET_BUF_DONE;
-}
-
 static int do_trace(struct t3cdev *dev, struct sk_buff *skb)
 {
 	struct cpl_trace_pkt *p = cplhdr(skb);
@@ -1215,7 +1204,8 @@ void __init cxgb3_offload_init(void)
 	t3_register_cpl_handler(CPL_CLOSE_CON_RPL, do_hwtid_rpl);
 	t3_register_cpl_handler(CPL_ABORT_REQ_RSS, do_abort_req_rss);
 	t3_register_cpl_handler(CPL_ACT_ESTABLISH, do_act_establish);
-	t3_register_cpl_handler(CPL_SET_TCB_RPL, do_set_tcb_rpl);
+	t3_register_cpl_handler(CPL_SET_TCB_RPL, do_hwtid_rpl);
+	t3_register_cpl_handler(CPL_GET_TCB_RPL, do_hwtid_rpl);
 	t3_register_cpl_handler(CPL_RDMA_TERMINATE, do_term);
 	t3_register_cpl_handler(CPL_RDMA_EC_STATUS, do_hwtid_rpl);
 	t3_register_cpl_handler(CPL_TRACE_PKT, do_trace);
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index f8be41c..e5a5534 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1234,9 +1234,15 @@
 
 #define A_ULPRX_ISCSI_TAGMASK 0x514
 
+#define S_HPZ0    0
+#define M_HPZ0    0xf
+#define V_HPZ0(x) ((x) << S_HPZ0)
+#define G_HPZ0(x) (((x) >> S_HPZ0) & M_HPZ0)
+
 #define A_ULPRX_TDDP_LLIMIT 0x51c
 
 #define A_ULPRX_TDDP_ULIMIT 0x520
+#define A_ULPRX_TDDP_PSZ 0x528
 
 #define A_ULPRX_STAG_LLIMIT 0x52c
 
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 94aaff0..a506792 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -367,7 +367,8 @@ int t3_mac_enable(struct cmac *mac, int which)
 	int idx = macidx(mac);
 	struct adapter *adap = mac->adapter;
 	unsigned int oft = mac->offset;
-
+	struct mac_stats *s = &mac->stats;
+	
 	if (which & MAC_DIRECTION_TX) {
 		t3_write_reg(adap, A_XGM_TX_CTRL + oft, F_TXEN);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
@@ -376,10 +377,16 @@ int t3_mac_enable(struct cmac *mac, int which)
 		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 1 << idx);
 
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CNT_CH0 + idx);
-		mac->tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
-							    A_TP_PIO_DATA)));
-		mac->xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
-						A_XGM_TX_SPI4_SOP_EOP_CNT)));
+		mac->tx_mcnt = s->tx_frames;
+		mac->tx_tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
+							A_TP_PIO_DATA)));
+		mac->tx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
+						A_XGM_TX_SPI4_SOP_EOP_CNT +
+						oft)));
+		mac->rx_mcnt = s->rx_frames;
+		mac->rx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
+						A_XGM_RX_SPI4_SOP_EOP_CNT +
+						oft)));
 		mac->txen = F_TXEN;
 		mac->toggle_cnt = 0;
 	}
@@ -392,6 +399,7 @@ int t3_mac_disable(struct cmac *mac, int which)
 {
 	int idx = macidx(mac);
 	struct adapter *adap = mac->adapter;
+	int val;
 
 	if (which & MAC_DIRECTION_TX) {
 		t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, 0);
@@ -401,44 +409,89 @@ int t3_mac_disable(struct cmac *mac, int which)
 		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 1 << idx);
 		mac->txen = 0;
 	}
-	if (which & MAC_DIRECTION_RX)
+	if (which & MAC_DIRECTION_RX) {
+		t3_set_reg_field(mac->adapter, A_XGM_RESET_CTRL + mac->offset,
+				 F_PCS_RESET_, 0);
+		msleep(100);
 		t3_write_reg(adap, A_XGM_RX_CTRL + mac->offset, 0);
+		val = F_MAC_RESET_;
+		if (is_10G(adap))
+			val |= F_PCS_RESET_;
+		else if (uses_xaui(adap))
+			val |= F_PCS_RESET_ | F_XG2G_RESET_;
+		else
+			val |= F_RGMII_RESET_ | F_XG2G_RESET_;
+		t3_write_reg(mac->adapter, A_XGM_RESET_CTRL + mac->offset, val);
+	}
 	return 0;
 }
 
 int t3b2_mac_watchdog_task(struct cmac *mac)
 {
 	struct adapter *adap = mac->adapter;
-	unsigned int tcnt, xcnt;
+	struct mac_stats *s = &mac->stats;
+	unsigned int tx_tcnt, tx_xcnt;
+	unsigned int tx_mcnt = s->tx_frames;
+	unsigned int rx_mcnt = s->rx_frames;
+	unsigned int rx_xcnt;
 	int status;
 
-	t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CNT_CH0 + macidx(mac));
-	tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap, A_TP_PIO_DATA)));
-	xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap, 
-					   A_XGM_TX_SPI4_SOP_EOP_CNT +
-					   mac->offset)));
-
-	if (tcnt != mac->tcnt && xcnt == 0 && mac->xcnt == 0) {
-		if (mac->toggle_cnt > 4) {
-			t3b2_mac_reset(mac);
+	if (tx_mcnt == mac->tx_mcnt) {
+		tx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
+						A_XGM_TX_SPI4_SOP_EOP_CNT +
+					       	mac->offset)));
+		if (tx_xcnt == 0) {
+			t3_write_reg(adap, A_TP_PIO_ADDR,
+				     A_TP_TX_DROP_CNT_CH0 + macidx(mac));
+			tx_tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
+						      A_TP_PIO_DATA)));
+		} else {
 			mac->toggle_cnt = 0;
+			return 0;
+		}
+	} else {
+		mac->toggle_cnt = 0;
+		return 0;
+	}
+
+	if (((tx_tcnt != mac->tx_tcnt) &&
+	     (tx_xcnt == 0) && (mac->tx_xcnt == 0)) ||
+	    ((mac->tx_mcnt == tx_mcnt) &&
+	     (tx_xcnt != 0) && (mac->tx_xcnt != 0))) {
+		if (mac->toggle_cnt > 4)
 			status = 2;
-		} else {
-			t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, 0);
-			t3_read_reg(adap, A_XGM_TX_CTRL + mac->offset);
-			t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset,
-				     mac->txen);
-			t3_read_reg(adap, A_XGM_TX_CTRL + mac->offset);
-			mac->toggle_cnt++;
+		else 
 			status = 1;
-		}	
 	} else {
 		mac->toggle_cnt = 0;
-		status = 0;
+		return 0;
 	}
-	mac->tcnt = tcnt;
-	mac->xcnt = xcnt;
 
+	if (rx_mcnt != mac->rx_mcnt)
+		rx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
+						A_XGM_RX_SPI4_SOP_EOP_CNT +
+						mac->offset)));
+	else 
+		return 0;
+
+	if (mac->rx_mcnt != s->rx_frames && rx_xcnt == 0 && mac->rx_xcnt == 0) 
+		status = 2;
+	
+	mac->tx_tcnt = tx_tcnt;
+	mac->tx_xcnt = tx_xcnt;
+	mac->tx_mcnt = s->tx_frames;
+	mac->rx_xcnt = rx_xcnt;
+	mac->rx_mcnt = s->rx_frames;
+	if (status == 1) {
+		t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, 0);
+		t3_read_reg(adap, A_XGM_TX_CTRL + mac->offset);  /* flush */
+		t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, mac->txen);
+		t3_read_reg(adap, A_XGM_TX_CTRL + mac->offset);  /* flush */
+		mac->toggle_cnt++;
+	} else if (status == 2) {
+		t3b2_mac_reset(mac);
+		mac->toggle_cnt = 0;
+	}
 	return status;
 }
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index c216e6a..f8efe0e 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.0-1.227"
+#define MYRI10GE_VERSION_STR "1.3.0-1.233"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -900,19 +900,9 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 	/* try to refill entire ring */
 	while (rx->fill_cnt != (rx->cnt + rx->mask + 1)) {
 		idx = rx->fill_cnt & rx->mask;
-
-		if ((bytes < MYRI10GE_ALLOC_SIZE / 2) &&
-		    (rx->page_offset + bytes <= MYRI10GE_ALLOC_SIZE)) {
+		if (rx->page_offset + bytes <= MYRI10GE_ALLOC_SIZE) {
 			/* we can use part of previous page */
 			get_page(rx->page);
-#if MYRI10GE_ALLOC_SIZE > 4096
-			/* Firmware cannot cross 4K boundary.. */
-			if ((rx->page_offset >> 12) !=
-			    ((rx->page_offset + bytes - 1) >> 12)) {
-				rx->page_offset =
-				    (rx->page_offset + bytes) & ~4095;
-			}
-#endif
 		} else {
 			/* we need a new page */
 			page =
@@ -941,6 +931,13 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 
 		/* start next packet on a cacheline boundary */
 		rx->page_offset += SKB_DATA_ALIGN(bytes);
+
+#if MYRI10GE_ALLOC_SIZE > 4096
+		/* don't cross a 4KB boundary */
+		if ((rx->page_offset >> 12) !=
+		    ((rx->page_offset + bytes - 1) >> 12))
+			rx->page_offset = (rx->page_offset + 4096) & ~4095;
+#endif
 		rx->fill_cnt++;
 
 		/* copy 8 descriptors to the firmware at a time */
@@ -2490,6 +2487,10 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
 
 #define PCI_DEVICE_ID_INTEL_E5000_PCIE23 0x25f7
 #define PCI_DEVICE_ID_INTEL_E5000_PCIE47 0x25fa
+#define PCI_DEVICE_ID_INTEL_6300ESB_PCIEE1 0x3510
+#define PCI_DEVICE_ID_INTEL_6300ESB_PCIEE4 0x351b
+#define PCI_DEVICE_ID_INTEL_E3000_PCIE	0x2779
+#define PCI_DEVICE_ID_INTEL_E3010_PCIE	0x277a
 #define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST 0x140
 #define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST 0x142
 
@@ -2529,6 +2530,18 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST
 				&& bridge->device <=
 				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST)
+			    /* All Intel E3000/E3010 PCIE ports */
+			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
+				&& (bridge->device ==
+				    PCI_DEVICE_ID_INTEL_E3000_PCIE
+				    || bridge->device ==
+				    PCI_DEVICE_ID_INTEL_E3010_PCIE))
+			    /* All Intel 6310/6311/6321ESB PCIE ports */
+			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
+				&& bridge->device >=
+				PCI_DEVICE_ID_INTEL_6300ESB_PCIEE1
+				&& bridge->device <=
+				PCI_DEVICE_ID_INTEL_6300ESB_PCIEE4)
 			    /* All Intel E5000 PCIE ports */
 			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
 				&& bridge->device >=
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 39c6677..d476a3c 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -163,27 +163,46 @@ static void skge_wol_init(struct skge_port *skge)
 {
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	enum pause_control save_mode;
-	u32 ctrl;
+	u16 ctrl;
 
-	/* Bring hardware out of reset */
 	skge_write16(hw, B0_CTST, CS_RST_CLR);
 	skge_write16(hw, SK_REG(port, GMAC_LINK_CTRL), GMLC_RST_CLR);
 
-	skge_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
-	skge_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
+	/* Turn on Vaux */
+	skge_write8(hw, B0_POWER_CTRL,
+		    PC_VAUX_ENA | PC_VCC_ENA | PC_VAUX_ON | PC_VCC_OFF);
 
-	/* Force to 10/100 skge_reset will re-enable on resume	 */
-	save_mode = skge->flow_control;
-	skge->flow_control = FLOW_MODE_SYMMETRIC;
+	/* WA code for COMA mode -- clear PHY reset */
+	if (hw->chip_id == CHIP_ID_YUKON_LITE &&
+	    hw->chip_rev >= CHIP_REV_YU_LITE_A3) {
+		u32 reg = skge_read32(hw, B2_GP_IO);
+		reg |= GP_DIR_9;
+		reg &= ~GP_IO_9;
+		skge_write32(hw, B2_GP_IO, reg);
+	}
 
-	ctrl = skge->advertising;
-	skge->advertising &= ~(ADVERTISED_1000baseT_Half|ADVERTISED_1000baseT_Full);
+	skge_write32(hw, SK_REG(port, GPHY_CTRL),
+		     GPC_DIS_SLEEP |
+		     GPC_HWCFG_M_3 | GPC_HWCFG_M_2 | GPC_HWCFG_M_1 | GPC_HWCFG_M_0 |
+		     GPC_ANEG_1 | GPC_RST_SET);
 
-	skge_phy_reset(skge);
+	skge_write32(hw, SK_REG(port, GPHY_CTRL),
+		     GPC_DIS_SLEEP |
+		     GPC_HWCFG_M_3 | GPC_HWCFG_M_2 | GPC_HWCFG_M_1 | GPC_HWCFG_M_0 |
+		     GPC_ANEG_1 | GPC_RST_CLR);
+
+	skge_write32(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
+
+	/* Force to 10/100 skge_reset will re-enable on resume	 */
+	gm_phy_write(hw, port, PHY_MARV_AUNE_ADV,
+		     PHY_AN_100FULL | PHY_AN_100HALF |
+		     PHY_AN_10FULL | PHY_AN_10HALF| PHY_AN_CSMA);
+	/* no 1000 HD/FD */
+	gm_phy_write(hw, port, PHY_MARV_1000T_CTRL, 0);
+	gm_phy_write(hw, port, PHY_MARV_CTRL,
+		     PHY_CT_RESET | PHY_CT_SPS_LSB | PHY_CT_ANE |
+		     PHY_CT_RE_CFG | PHY_CT_DUP_MD);
 
-	skge->flow_control = save_mode;
-	skge->advertising = ctrl;
 
 	/* Set GMAC to no flow control and auto update for speed/duplex */
 	gma_write16(hw, port, GM_GP_CTRL,
@@ -227,12 +246,10 @@ static int skge_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 
-	if (wol->wolopts & wol_supported(hw))
+	if (wol->wolopts & ~wol_supported(hw))
 		return -EOPNOTSUPP;
 
 	skge->wol = wol->wolopts;
-	if (!netif_running(dev))
-		skge_wol_init(skge);
 	return 0;
 }
 
@@ -2535,10 +2552,12 @@ static int skge_down(struct net_device *dev)
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
 	netif_stop_queue(dev);
+
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
 		del_timer_sync(&skge->link_timer);
 
 	netif_poll_disable(dev);
+	netif_carrier_off(dev);
 
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask &= ~portmask[port];
@@ -3765,21 +3784,6 @@ static void __devexit skge_remove(struct pci_dev *pdev)
 }
 
 #ifdef CONFIG_PM
-static int vaux_avail(struct pci_dev *pdev)
-{
-	int pm_cap;
-
-	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
-	if (pm_cap) {
-		u16 ctl;
-		pci_read_config_word(pdev, pm_cap + PCI_PM_PMC, &ctl);
-		if (ctl & PCI_PM_CAP_AUX_POWER)
-			return 1;
-	}
-	return 0;
-}
-
-
 static int skge_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
@@ -3801,10 +3805,6 @@ static int skge_suspend(struct pci_dev *pdev, pm_message_t state)
 		wol |= skge->wol;
 	}
 
-	if (wol && vaux_avail(pdev))
-		skge_write8(hw, B0_POWER_CTRL,
-			    PC_VAUX_ENA | PC_VCC_ENA | PC_VAUX_ON | PC_VCC_OFF);
-
 	skge_write32(hw, B0_IMSK, 0);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -3850,6 +3850,28 @@ out:
 }
 #endif
 
+static void skge_shutdown(struct pci_dev *pdev)
+{
+	struct skge_hw *hw  = pci_get_drvdata(pdev);
+	int i, wol = 0;
+
+	for (i = 0; i < hw->ports; i++) {
+		struct net_device *dev = hw->dev[i];
+		struct skge_port *skge = netdev_priv(dev);
+
+		if (skge->wol)
+			skge_wol_init(skge);
+		wol |= skge->wol;
+	}
+
+	pci_enable_wake(pdev, PCI_D3hot, wol);
+	pci_enable_wake(pdev, PCI_D3cold, wol);
+
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+}
+
 static struct pci_driver skge_driver = {
 	.name =         DRV_NAME,
 	.id_table =     skge_id_table,
@@ -3859,6 +3881,7 @@ static struct pci_driver skge_driver = {
 	.suspend = 	skge_suspend,
 	.resume = 	skge_resume,
 #endif
+	.shutdown =	skge_shutdown,
 };
 
 static int __init skge_init_module(void)
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index ab0ab92..4a009b7 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -510,9 +510,9 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		ledover &= ~PHY_M_LED_MO_RX;
 	}
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U && hw->chip_rev == CHIP_REV_YU_EC_A1) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
+	    hw->chip_rev == CHIP_REV_YU_EC_U_A1) {
 		/* apply fixes in PHY AFE */
-		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 255);
 
 		/* increase differential signal amplitude in 10BASE-T */
@@ -524,7 +524,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		gm_phy_write(hw, port, 0x17, 0x2002);
 
 		/* set page register to 0 */
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 	} else if (hw->chip_id != CHIP_ID_YUKON_EX) {
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 
@@ -1561,6 +1561,7 @@ static int sky2_down(struct net_device *dev)
 
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
+	netif_carrier_off(dev);
 
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
@@ -3769,6 +3770,11 @@ static int sky2_resume(struct pci_dev *pdev)
 		goto out;
 
 	pci_enable_wake(pdev, PCI_D0, 0);
+
+	/* Re-enable all clocks */
+	if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == CHIP_ID_YUKON_EC_U)
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+
 	sky2_reset(hw);
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 80cb88e..a38e7ee 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -946,6 +946,7 @@ static int bcm43xx_geo_init(struct bcm43xx_private *bcm)
 	u8 channel;
 	struct bcm43xx_phyinfo *phy;
 	const char *iso_country;
+	u8 max_bg_channel;
 
 	geo = kzalloc(sizeof(*geo), GFP_KERNEL);
 	if (!geo)
@@ -967,6 +968,23 @@ static int bcm43xx_geo_init(struct bcm43xx_private *bcm)
 	}
 	iso_country = bcm43xx_locale_iso(bcm->sprom.locale);
 
+/* set the maximum channel based on locale set in sprom or witle locale option */
+	switch (bcm->sprom.locale) {
+	case BCM43xx_LOCALE_THAILAND:
+	case BCM43xx_LOCALE_ISRAEL:
+	case BCM43xx_LOCALE_JORDAN:
+	case BCM43xx_LOCALE_USA_CANADA_ANZ:
+	case BCM43xx_LOCALE_USA_LOW:
+		max_bg_channel = 11;
+		break;
+	case BCM43xx_LOCALE_JAPAN:
+	case BCM43xx_LOCALE_JAPAN_HIGH:
+		max_bg_channel = 14;
+		break;
+	default:
+		max_bg_channel = 13;
+	}
+
  	if (have_a) {
 		for (i = 0, channel = IEEE80211_52GHZ_MIN_CHANNEL;
 		      channel <= IEEE80211_52GHZ_MAX_CHANNEL; channel++) {
@@ -978,7 +996,7 @@ static int bcm43xx_geo_init(struct bcm43xx_private *bcm)
 	}
 	if (have_bg) {
 		for (i = 0, channel = IEEE80211_24GHZ_MIN_CHANNEL;
-		      channel <= IEEE80211_24GHZ_MAX_CHANNEL; channel++) {
+		      channel <= max_bg_channel; channel++) {
 			chan = &geo->bg[i++];
 			chan->freq = bcm43xx_channel_to_freq_bg(channel);
 			chan->channel = channel;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index d1e89be..72529a4 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -978,7 +978,7 @@ static void bcm43xx_calc_loopback_gain(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
-	u16 backup_phy[15];
+	u16 backup_phy[15] = {0};
 	u16 backup_radio[3];
 	u16 backup_bband;
 	u16 i;
@@ -989,8 +989,10 @@ static void bcm43xx_calc_loopback_gain(struct bcm43xx_private *bcm)
 	backup_phy[1] = bcm43xx_phy_read(bcm, 0x0001);
 	backup_phy[2] = bcm43xx_phy_read(bcm, 0x0811);
 	backup_phy[3] = bcm43xx_phy_read(bcm, 0x0812);
-	backup_phy[4] = bcm43xx_phy_read(bcm, 0x0814);
-	backup_phy[5] = bcm43xx_phy_read(bcm, 0x0815);
+	if (phy->rev != 1) {
+		backup_phy[4] = bcm43xx_phy_read(bcm, 0x0814);
+		backup_phy[5] = bcm43xx_phy_read(bcm, 0x0815);
+	}
 	backup_phy[6] = bcm43xx_phy_read(bcm, 0x005A);
 	backup_phy[7] = bcm43xx_phy_read(bcm, 0x0059);
 	backup_phy[8] = bcm43xx_phy_read(bcm, 0x0058);
@@ -1018,14 +1020,16 @@ static void bcm43xx_calc_loopback_gain(struct bcm43xx_private *bcm)
 			  bcm43xx_phy_read(bcm, 0x0811) | 0x0001);
 	bcm43xx_phy_write(bcm, 0x0812,
 			  bcm43xx_phy_read(bcm, 0x0812) & 0xFFFE);
-	bcm43xx_phy_write(bcm, 0x0814,
-			  bcm43xx_phy_read(bcm, 0x0814) | 0x0001);
-	bcm43xx_phy_write(bcm, 0x0815,
-			  bcm43xx_phy_read(bcm, 0x0815) & 0xFFFE);
-	bcm43xx_phy_write(bcm, 0x0814,
-			  bcm43xx_phy_read(bcm, 0x0814) | 0x0002);
-	bcm43xx_phy_write(bcm, 0x0815,
-			  bcm43xx_phy_read(bcm, 0x0815) & 0xFFFD);
+	if (phy->rev != 1) {
+		bcm43xx_phy_write(bcm, 0x0814,
+				  bcm43xx_phy_read(bcm, 0x0814) | 0x0001);
+		bcm43xx_phy_write(bcm, 0x0815,
+				  bcm43xx_phy_read(bcm, 0x0815) & 0xFFFE);
+		bcm43xx_phy_write(bcm, 0x0814,
+				  bcm43xx_phy_read(bcm, 0x0814) | 0x0002);
+		bcm43xx_phy_write(bcm, 0x0815,
+				  bcm43xx_phy_read(bcm, 0x0815) & 0xFFFD);
+	}
 	bcm43xx_phy_write(bcm, 0x0811,
 			  bcm43xx_phy_read(bcm, 0x0811) | 0x000C);
 	bcm43xx_phy_write(bcm, 0x0812,
@@ -1048,10 +1052,12 @@ static void bcm43xx_calc_loopback_gain(struct bcm43xx_private *bcm)
 				  bcm43xx_phy_read(bcm, 0x000A)
 				  | 0x2000);
 	}
-	bcm43xx_phy_write(bcm, 0x0814,
-			  bcm43xx_phy_read(bcm, 0x0814) | 0x0004);
-	bcm43xx_phy_write(bcm, 0x0815,
-			  bcm43xx_phy_read(bcm, 0x0815) & 0xFFFB);
+	if (phy->rev != 1) {
+		bcm43xx_phy_write(bcm, 0x0814,
+				  bcm43xx_phy_read(bcm, 0x0814) | 0x0004);
+		bcm43xx_phy_write(bcm, 0x0815,
+				  bcm43xx_phy_read(bcm, 0x0815) & 0xFFFB);
+	}
 	bcm43xx_phy_write(bcm, 0x0003,
 			  (bcm43xx_phy_read(bcm, 0x0003)
 			   & 0xFF9F) | 0x0040);
@@ -1138,8 +1144,10 @@ static void bcm43xx_calc_loopback_gain(struct bcm43xx_private *bcm)
 		}
 	}
 
-	bcm43xx_phy_write(bcm, 0x0814, backup_phy[4]);
-	bcm43xx_phy_write(bcm, 0x0815, backup_phy[5]);
+	if (phy->rev != 1) {
+		bcm43xx_phy_write(bcm, 0x0814, backup_phy[4]);
+		bcm43xx_phy_write(bcm, 0x0815, backup_phy[5]);
+	}
 	bcm43xx_phy_write(bcm, 0x005A, backup_phy[6]);
 	bcm43xx_phy_write(bcm, 0x0059, backup_phy[7]);
 	bcm43xx_phy_write(bcm, 0x0058, backup_phy[8]);
@@ -1188,24 +1196,23 @@ static void bcm43xx_phy_initg(struct bcm43xx_private *bcm)
 		bcm43xx_phy_write(bcm, 0x0811, 0x0000);
 		bcm43xx_phy_write(bcm, 0x0015, 0x00C0);
 	}
-	if (phy->rev >= 3) {
+	if (phy->rev > 5) {
 		bcm43xx_phy_write(bcm, 0x0811, 0x0400);
 		bcm43xx_phy_write(bcm, 0x0015, 0x00C0);
 	}
 	if (phy->rev >= 2 && phy->connected) {
 		tmp = bcm43xx_phy_read(bcm, 0x0400) & 0xFF;
-		if (tmp < 6) {
+		if (tmp ==3 || tmp == 5) {
 			bcm43xx_phy_write(bcm, 0x04C2, 0x1816);
 			bcm43xx_phy_write(bcm, 0x04C3, 0x8006);
-			if (tmp != 3) {
+			if (tmp == 5) {
 				bcm43xx_phy_write(bcm, 0x04CC,
 						  (bcm43xx_phy_read(bcm, 0x04CC)
 						   & 0x00FF) | 0x1F00);
 			}
 		}
-	}
-	if (phy->rev < 3 && phy->connected)
 		bcm43xx_phy_write(bcm, 0x047E, 0x0078);
+	}
 	if (radio->revision == 8) {
 		bcm43xx_phy_write(bcm, 0x0801, bcm43xx_phy_read(bcm, 0x0801) | 0x0080);
 		bcm43xx_phy_write(bcm, 0x043E, bcm43xx_phy_read(bcm, 0x043E) | 0x0004);
@@ -1232,7 +1239,7 @@ static void bcm43xx_phy_initg(struct bcm43xx_private *bcm)
 		if (phy->rev >= 6) {
 			bcm43xx_phy_write(bcm, 0x0036,
 					  (bcm43xx_phy_read(bcm, 0x0036)
-					   & 0xF000) | (radio->txctl2 << 12));
+					   & 0x0FFF) | (radio->txctl2 << 12));
 		}
 		if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL)
 			bcm43xx_phy_write(bcm, 0x002E, 0x8075);
@@ -1243,7 +1250,7 @@ static void bcm43xx_phy_initg(struct bcm43xx_private *bcm)
 		else
 			bcm43xx_phy_write(bcm, 0x002F, 0x0202);
 	}
-	if (phy->connected) {
+	if (phy->connected || phy->rev >= 2) {
 		bcm43xx_phy_lo_adjust(bcm, 0);
 		bcm43xx_phy_write(bcm, 0x080F, 0x8078);
 	}
@@ -1257,7 +1264,7 @@ static void bcm43xx_phy_initg(struct bcm43xx_private *bcm)
 		 */
 		bcm43xx_nrssi_hw_update(bcm, 0xFFFF);
 		bcm43xx_calc_nrssi_threshold(bcm);
-	} else if (phy->connected) {
+	} else if (phy->connected || phy->rev >= 2) {
 		if (radio->nrssi[0] == -1000) {
 			assert(radio->nrssi[1] == -1000);
 			bcm43xx_calc_nrssi_slope(bcm);
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 9c64f89..87ee3ee 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -337,6 +337,7 @@ static int read_pod(struct zd_chip *chip, u8 *rf_type)
 	chip->patch_cr157 = (value >> 13) & 0x1;
 	chip->patch_6m_band_edge = (value >> 21) & 0x1;
 	chip->new_phy_layout = (value >> 31) & 0x1;
+	chip->al2230s_bit = (value >> 7) & 0x1;
 	chip->link_led = ((value >> 4) & 1) ? LED1 : LED2;
 	chip->supports_tx_led = 1;
 	if (value & (1 << 24)) { /* LED scenario */
@@ -591,16 +592,16 @@ int zd_chip_unlock_phy_regs(struct zd_chip *chip)
 	return r;
 }
 
-/* CR157 can be optionally patched by the EEPROM */
+/* CR157 can be optionally patched by the EEPROM for original ZD1211 */
 static int patch_cr157(struct zd_chip *chip)
 {
 	int r;
-	u32 value;
+	u16 value;
 
 	if (!chip->patch_cr157)
 		return 0;
 
-	r = zd_ioread32_locked(chip, &value, E2P_PHY_REG);
+	r = zd_ioread16_locked(chip, &value, E2P_PHY_REG);
 	if (r)
 		return r;
 
@@ -790,11 +791,6 @@ static int zd1211b_hw_reset_phy(struct zd_chip *chip)
 		goto out;
 
 	r = zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
-	if (r)
-		goto unlock;
-
-	r = patch_cr157(chip);
-unlock:
 	t = zd_chip_unlock_phy_regs(chip);
 	if (t && !r)
 		r = t;
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index b07569e..e57ed75 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -641,8 +641,8 @@ enum {
  * also only 11 channels. */
 #define E2P_ALLOWED_CHANNEL	E2P_DATA(0x18)
 
-#define E2P_PHY_REG		E2P_DATA(0x1a)
 #define E2P_DEVICE_VER		E2P_DATA(0x20)
+#define E2P_PHY_REG		E2P_DATA(0x25)
 #define E2P_36M_CAL_VALUE1	E2P_DATA(0x28)
 #define E2P_36M_CAL_VALUE2      E2P_DATA(0x2a)
 #define E2P_36M_CAL_VALUE3      E2P_DATA(0x2c)
@@ -711,7 +711,7 @@ struct zd_chip {
 	u16 link_led;
 	unsigned int pa_type:4,
 		patch_cck_gain:1, patch_cr157:1, patch_6m_band_edge:1,
-		new_phy_layout:1,
+		new_phy_layout:1, al2230s_bit:1,
 		is_zd1211b:1, supports_tx_led:1;
 };
 
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
index 25323a1..5235a78 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
@@ -358,6 +358,12 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
+	if (chip->al2230s_bit) {
+		dev_err(zd_chip_dev(chip), "AL2230S devices are not yet "
+			"supported by this driver.\n");
+		return -ENODEV;
+	}
+
 	rf->switch_radio_off = al2230_switch_radio_off;
 	if (chip->is_zd1211b) {
 		rf->init_hw = zd1211b_al2230_init_hw;
