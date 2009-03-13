From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 8/10] cxgb3: detect mac link faults.
Date: Fri, 13 Mar 2009 00:14:19 -0700
Message-ID: <20090313071419.21994.33167.stgit@speedy5>
References: <20090313071343.21994.85719.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27603 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622AbZCMHOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:14:22 -0400
In-Reply-To: <20090313071343.21994.85719.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

The driver currently ignores the local or remote link faults
raised at the mac layer. This patch fixes it.
Our mac however only advertizes link events, so wait for the 
phy to stabilize the link, then enable mac link events interrupts.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h    |    5 +
 drivers/net/cxgb3/common.h     |    6 ++
 drivers/net/cxgb3/cxgb3_main.c |  123 ++++++++++++++++++++++++++++++++++++-
 drivers/net/cxgb3/regs.h       |   13 ++++
 drivers/net/cxgb3/t3_hw.c      |  134 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb3/xgmac.c      |   13 ++--
 6 files changed, 285 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 66ce456..71eaa43 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -68,6 +68,8 @@ struct port_info {
 	struct net_device_stats netstats;
 	int activity;
 	__be32 iscsi_ipv4addr;
+
+	int link_fault; /* link fault was detected */
 };
 
 enum {				/* adapter flags */
@@ -241,6 +243,7 @@ struct adapter {
 	struct delayed_work adap_check_task;
 	struct work_struct ext_intr_handler_task;
 	struct work_struct fatal_error_handler_task;
+	struct work_struct link_fault_handler_task;
 
 	struct dentry *debugfs_root;
 
@@ -283,6 +286,8 @@ void t3_os_ext_intr_handler(struct adapter *adapter);
 void t3_os_link_changed(struct adapter *adapter, int port_id, int link_status,
 			int speed, int duplex, int fc);
 void t3_os_phymod_changed(struct adapter *adap, int port_id);
+void t3_os_link_fault(struct adapter *adapter, int port_id, int state);
+void t3_os_link_fault_handler(struct adapter *adapter, int port_id);
 
 void t3_sge_start(struct adapter *adap);
 void t3_sge_stop(struct adapter *adap);
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index db4f4f5..9ee021e 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -280,6 +280,7 @@ struct mac_stats {
 	unsigned long num_toggled; /* # times toggled TxEn due to stuck TX */
 	unsigned long num_resets;  /* # times reset due to stuck TX */
 
+	unsigned long link_faults;  /* # detected link faults */
 };
 
 struct tp_mib_stats {
@@ -701,6 +702,8 @@ int t3_phy_lasi_intr_handler(struct cphy *phy);
 void t3_intr_enable(struct adapter *adapter);
 void t3_intr_disable(struct adapter *adapter);
 void t3_intr_clear(struct adapter *adapter);
+void t3_xgm_intr_enable(struct adapter *adapter, int idx);
+void t3_xgm_intr_disable(struct adapter *adapter, int idx);
 void t3_port_intr_enable(struct adapter *adapter, int idx);
 void t3_port_intr_disable(struct adapter *adapter, int idx);
 void t3_port_intr_clear(struct adapter *adapter, int idx);
@@ -708,6 +711,7 @@ int t3_slow_intr_handler(struct adapter *adapter);
 int t3_phy_intr_handler(struct adapter *adapter);
 
 void t3_link_changed(struct adapter *adapter, int port_id);
+void t3_link_fault(struct adapter *adapter, int port_id);
 int t3_link_start(struct cphy *phy, struct cmac *mac, struct link_config *lc);
 const struct adapter_info *t3_get_adapter_info(unsigned int board_id);
 int t3_seeprom_read(struct adapter *adapter, u32 addr, __le32 *data);
@@ -744,6 +748,8 @@ int t3_mc7_bd_read(struct mc7 *mc7, unsigned int start, unsigned int n,
 
 int t3_mac_reset(struct cmac *mac);
 void t3b_pcs_reset(struct cmac *mac);
+void t3_mac_disable_exact_filters(struct cmac *mac);
+void t3_mac_enable_exact_filters(struct cmac *mac);
 int t3_mac_enable(struct cmac *mac, int which);
 int t3_mac_disable(struct cmac *mac, int which);
 int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 9ff0452..d8be896 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -170,6 +170,40 @@ static void link_report(struct net_device *dev)
 	}
 }
 
+void t3_os_link_fault(struct adapter *adap, int port_id, int state)
+{
+	struct net_device *dev = adap->port[port_id];
+	struct port_info *pi = netdev_priv(dev);
+
+	if (state == netif_carrier_ok(dev))
+		return;
+
+	if (state) {
+		struct cmac *mac = &pi->mac;
+
+		netif_carrier_on(dev);
+
+		/* Clear local faults */
+		t3_xgm_intr_disable(adap, pi->port_id);
+		t3_read_reg(adap, A_XGM_INT_STATUS +
+				    pi->mac.offset);
+		t3_write_reg(adap,
+			     A_XGM_INT_CAUSE + pi->mac.offset,
+			     F_XGM_INT);
+
+		t3_set_reg_field(adap,
+				 A_XGM_INT_ENABLE +
+				 pi->mac.offset,
+				 F_XGM_INT, F_XGM_INT);
+		t3_xgm_intr_enable(adap, pi->port_id);
+
+		t3_mac_enable(mac, MAC_DIRECTION_TX);
+	} else
+		netif_carrier_off(dev);
+
+	link_report(dev);
+}
+
 /**
  *	t3_os_link_changed - handle link status changes
  *	@adapter: the adapter associated with the link change
@@ -197,10 +231,34 @@ void t3_os_link_changed(struct adapter *adapter, int port_id, int link_stat,
 	if (link_stat != netif_carrier_ok(dev)) {
 		if (link_stat) {
 			t3_mac_enable(mac, MAC_DIRECTION_RX);
+
+			/* Clear local faults */
+			t3_xgm_intr_disable(adapter, pi->port_id);
+			t3_read_reg(adapter, A_XGM_INT_STATUS +
+				    pi->mac.offset);
+			t3_write_reg(adapter,
+				     A_XGM_INT_CAUSE + pi->mac.offset,
+				     F_XGM_INT);
+
+			t3_set_reg_field(adapter,
+					 A_XGM_INT_ENABLE + pi->mac.offset,
+					 F_XGM_INT, F_XGM_INT);
+			t3_xgm_intr_enable(adapter, pi->port_id);
+
 			netif_carrier_on(dev);
 		} else {
 			netif_carrier_off(dev);
-			pi->phy.ops->power_down(&pi->phy, 1);
+
+			t3_xgm_intr_disable(adapter, pi->port_id);
+			t3_read_reg(adapter, A_XGM_INT_STATUS + pi->mac.offset);
+			t3_set_reg_field(adapter,
+					 A_XGM_INT_ENABLE + pi->mac.offset,
+					 F_XGM_INT, 0);
+
+			if (is_10G(adapter))
+				pi->phy.ops->power_down(&pi->phy, 1);
+
+			t3_read_reg(adapter, A_XGM_INT_STATUS + pi->mac.offset);
 			t3_mac_disable(mac, MAC_DIRECTION_RX);
 			t3_link_start(&pi->phy, mac, &pi->link_config);
 		}
@@ -1173,6 +1231,10 @@ static int cxgb_close(struct net_device *dev)
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
 
+	/* Stop link fault interrupts */
+	t3_xgm_intr_disable(adapter, pi->port_id);
+	t3_read_reg(adapter, A_XGM_INT_STATUS + pi->mac.offset);
+
 	t3_port_intr_disable(adapter, pi->port_id);
 	netif_tx_stop_all_queues(dev);
 	pi->phy.ops->power_down(&pi->phy, 1);
@@ -1299,6 +1361,7 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"CheckTXEnToggled   ",
 	"CheckResets        ",
 
+	"LinkFaults         ",
 };
 
 static int get_sset_count(struct net_device *dev, int sset)
@@ -1431,6 +1494,8 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 
 	*data++ = s->num_toggled;
 	*data++ = s->num_resets;
+
+	*data++ = s->link_faults;
 }
 
 static inline void reg_block_dump(struct adapter *ap, void *buf,
@@ -2425,8 +2490,20 @@ static void check_link_status(struct adapter *adapter)
 		struct net_device *dev = adapter->port[i];
 		struct port_info *p = netdev_priv(dev);
 
-		if (!(p->phy.caps & SUPPORTED_IRQ) && netif_running(dev))
+		spin_lock_irq(&adapter->work_lock);
+		if (p->link_fault) {
+			spin_unlock_irq(&adapter->work_lock);
+			continue;
+		}
+		spin_unlock_irq(&adapter->work_lock);
+
+		if (!(p->phy.caps & SUPPORTED_IRQ) && netif_running(dev)) {
+			t3_xgm_intr_disable(adapter, i);
+			t3_read_reg(adapter, A_XGM_INT_STATUS + p->mac.offset);
+
 			t3_link_changed(adapter, i);
+			t3_xgm_intr_enable(adapter, i);
+		}
 	}
 }
 
@@ -2553,9 +2630,23 @@ static void ext_intr_task(struct work_struct *work)
 {
 	struct adapter *adapter = container_of(work, struct adapter,
 					       ext_intr_handler_task);
+	int i;
+
+	/* Disable link fault interrupts */
+	for_each_port(adapter, i) {
+		struct net_device *dev = adapter->port[i];
+		struct port_info *p = netdev_priv(dev);
+
+		t3_xgm_intr_disable(adapter, i);
+		t3_read_reg(adapter, A_XGM_INT_STATUS + p->mac.offset);
+	}
 
+	/* Re-enable link fault interrupts */
 	t3_phy_intr_handler(adapter);
 
+	for_each_port(adapter, i)
+		t3_xgm_intr_enable(adapter, i);
+
 	/* Now reenable external interrupts */
 	spin_lock_irq(&adapter->work_lock);
 	if (adapter->slow_intr_mask) {
@@ -2588,6 +2679,32 @@ void t3_os_ext_intr_handler(struct adapter *adapter)
 	spin_unlock(&adapter->work_lock);
 }
 
+static void link_fault_task(struct work_struct *work)
+{
+	struct adapter *adapter = container_of(work, struct adapter,
+					       link_fault_handler_task);
+	int i;
+
+	for_each_port(adapter, i) {
+		struct net_device *netdev = adapter->port[i];
+		struct port_info *pi = netdev_priv(netdev);
+
+		if (pi->link_fault)
+			t3_link_fault(adapter, i);
+	}
+}
+
+void t3_os_link_fault_handler(struct adapter *adapter, int port_id)
+{
+	struct net_device *netdev = adapter->port[port_id];
+	struct port_info *pi = netdev_priv(netdev);
+
+	spin_lock(&adapter->work_lock);
+	pi->link_fault = 1;
+	queue_work(cxgb3_wq, &adapter->link_fault_handler_task);
+	spin_unlock(&adapter->work_lock);
+}
+
 static int t3_adapter_error(struct adapter *adapter, int reset)
 {
 	int i, ret = 0;
@@ -2704,7 +2821,6 @@ void t3_fatal_err(struct adapter *adapter)
 		CH_ALERT(adapter, "FW status: 0x%x, 0x%x, 0x%x, 0x%x\n",
 			 fw_status[0], fw_status[1],
 			 fw_status[2], fw_status[3]);
-
 }
 
 /**
@@ -2962,6 +3078,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 	INIT_LIST_HEAD(&adapter->adapter_list);
 	INIT_WORK(&adapter->ext_intr_handler_task, ext_intr_task);
+	INIT_WORK(&adapter->link_fault_handler_task, link_fault_task);
 	INIT_WORK(&adapter->fatal_error_handler_task, fatal_error_task);
 	INIT_DELAYED_WORK(&adapter->adap_check_task, t3_adap_check_task);
 
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index aa08550..1b5327b 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -2215,6 +2215,15 @@
 
 #define A_XGM_RX_EXACT_MATCH_LOW_8 0x854
 
+#define A_XGM_INT_STATUS 0x86c
+
+#define S_LINKFAULTCHANGE    9
+#define V_LINKFAULTCHANGE(x) ((x) << S_LINKFAULTCHANGE)
+#define F_LINKFAULTCHANGE    V_LINKFAULTCHANGE(1U)
+
+#define A_XGM_XGM_INT_ENABLE 0x874
+#define A_XGM_XGM_INT_DISABLE 0x878
+
 #define A_XGM_STAT_CTRL 0x880
 
 #define S_CLRSTATS    2
@@ -2413,6 +2422,10 @@
 #define V_XAUIPCSALIGNCHANGE(x) ((x) << S_XAUIPCSALIGNCHANGE)
 #define F_XAUIPCSALIGNCHANGE    V_XAUIPCSALIGNCHANGE(1U)
 
+#define S_XGM_INT    0
+#define V_XGM_INT(x) ((x) << S_XGM_INT)
+#define F_XGM_INT    V_XGM_INT(1U)
+
 #define A_XGM_INT_CAUSE 0x8d8
 
 #define A_XGM_XAUI_ACT_CTRL 0x8dc
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 7c6ee0c..ff262a0 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1153,6 +1153,38 @@ int t3_cim_ctl_blk_read(struct adapter *adap, unsigned int addr,
 	return ret;
 }
 
+static void t3_gate_rx_traffic(struct cmac *mac, u32 *rx_cfg,
+			       u32 *rx_hash_high, u32 *rx_hash_low)
+{
+	/* stop Rx unicast traffic */
+	t3_mac_disable_exact_filters(mac);
+
+	/* stop broadcast, multicast, promiscuous mode traffic */
+	*rx_cfg = t3_read_reg(mac->adapter, A_XGM_RX_CFG);
+	t3_set_reg_field(mac->adapter, A_XGM_RX_CFG,
+			 F_ENHASHMCAST | F_DISBCAST | F_COPYALLFRAMES,
+			 F_DISBCAST);
+
+	*rx_hash_high = t3_read_reg(mac->adapter, A_XGM_RX_HASH_HIGH);
+	t3_write_reg(mac->adapter, A_XGM_RX_HASH_HIGH, 0);
+
+	*rx_hash_low = t3_read_reg(mac->adapter, A_XGM_RX_HASH_LOW);
+	t3_write_reg(mac->adapter, A_XGM_RX_HASH_LOW, 0);
+
+	/* Leave time to drain max RX fifo */
+	msleep(1);
+}
+
+static void t3_open_rx_traffic(struct cmac *mac, u32 rx_cfg,
+			       u32 rx_hash_high, u32 rx_hash_low)
+{
+	t3_mac_enable_exact_filters(mac);
+	t3_set_reg_field(mac->adapter, A_XGM_RX_CFG,
+			 F_ENHASHMCAST | F_DISBCAST | F_COPYALLFRAMES,
+			 rx_cfg);
+	t3_write_reg(mac->adapter, A_XGM_RX_HASH_HIGH, rx_hash_high);
+	t3_write_reg(mac->adapter, A_XGM_RX_HASH_LOW, rx_hash_low);
+}
 
 /**
  *	t3_link_changed - handle interface link changes
@@ -1170,9 +1202,32 @@ void t3_link_changed(struct adapter *adapter, int port_id)
 	struct cphy *phy = &pi->phy;
 	struct cmac *mac = &pi->mac;
 	struct link_config *lc = &pi->link_config;
+	int force_link_down = 0;
 
 	phy->ops->get_link_status(phy, &link_ok, &speed, &duplex, &fc);
 
+	if (!lc->link_ok && link_ok) {
+		u32 rx_cfg, rx_hash_high, rx_hash_low;
+		u32 status;
+
+		t3_xgm_intr_enable(adapter, port_id);
+		t3_gate_rx_traffic(mac, &rx_cfg, &rx_hash_high, &rx_hash_low);
+		t3_write_reg(adapter, A_XGM_RX_CTRL + mac->offset, 0);
+		t3_mac_enable(mac, MAC_DIRECTION_RX);
+
+		status = t3_read_reg(adapter, A_XGM_INT_STATUS + mac->offset);
+		if (status & F_LINKFAULTCHANGE) {
+			mac->stats.link_faults++;
+			force_link_down = 1;
+		}
+		t3_open_rx_traffic(mac, rx_cfg, rx_hash_high, rx_hash_low);
+
+		if (force_link_down) {
+			t3_os_link_fault_handler(adapter, port_id);
+			return;
+		}
+	}
+
 	if (lc->requested_fc & PAUSE_AUTONEG)
 		fc &= lc->requested_fc;
 	else
@@ -1202,6 +1257,57 @@ void t3_link_changed(struct adapter *adapter, int port_id)
 	t3_os_link_changed(adapter, port_id, link_ok, speed, duplex, fc);
 }
 
+void t3_link_fault(struct adapter *adapter, int port_id)
+{
+	struct port_info *pi = adap2pinfo(adapter, port_id);
+	struct cmac *mac = &pi->mac;
+	struct cphy *phy = &pi->phy;
+	struct link_config *lc = &pi->link_config;
+	int link_ok, speed, duplex, fc, link_fault;
+	u32 rx_cfg, rx_hash_high, rx_hash_low;
+
+	t3_gate_rx_traffic(mac, &rx_cfg, &rx_hash_high, &rx_hash_low);
+
+	if (adapter->params.rev > 0 && uses_xaui(adapter))
+		t3_write_reg(adapter, A_XGM_XAUI_ACT_CTRL + mac->offset, 0);
+
+	t3_write_reg(adapter, A_XGM_RX_CTRL + mac->offset, 0);
+	t3_mac_enable(mac, MAC_DIRECTION_RX);
+
+	t3_open_rx_traffic(mac, rx_cfg, rx_hash_high, rx_hash_low);
+
+	link_fault = t3_read_reg(adapter,
+				 A_XGM_INT_STATUS + mac->offset);
+	link_fault &= F_LINKFAULTCHANGE;
+
+	phy->ops->get_link_status(phy, &link_ok, &speed, &duplex, &fc);
+
+	if (link_fault) {
+		lc->link_ok = 0;
+		lc->speed = SPEED_INVALID;
+		lc->duplex = DUPLEX_INVALID;
+
+		t3_os_link_fault(adapter, port_id, 0);
+
+		/* Account link faults only when the phy reports a link up */
+		if (link_ok)
+			mac->stats.link_faults++;
+
+		msleep(1000);
+		t3_os_link_fault_handler(adapter, port_id);
+	} else {
+		if (link_ok)
+			t3_write_reg(adapter, A_XGM_XAUI_ACT_CTRL + mac->offset,
+				     F_TXACTENABLE | F_RXEN);
+
+		pi->link_fault = 0;
+		lc->link_ok = (unsigned char)link_ok;
+		lc->speed = speed < 0 ? SPEED_INVALID : speed;
+		lc->duplex = duplex < 0 ? DUPLEX_INVALID : duplex;
+		t3_os_link_fault(adapter, port_id, link_ok);
+	}
+}
+
 /**
  *	t3_link_start - apply link configuration to MAC/PHY
  *	@phy: the PHY to setup
@@ -1360,11 +1466,11 @@ static int t3_handle_intr_status(struct adapter *adapter, unsigned int reg,
 		       V_TX1TPPARERRENB(M_TX1TPPARERRENB) | \
 		       V_RXTPPARERRENB(M_RXTPPARERRENB) | \
 		       V_MCAPARERRENB(M_MCAPARERRENB))
+#define XGM_EXTRA_INTR_MASK (F_LINKFAULTCHANGE)
 #define PL_INTR_MASK (F_T3DBG | F_XGMAC0_0 | F_XGMAC0_1 | F_MC5A | F_PM1_TX | \
 		      F_PM1_RX | F_ULP2_TX | F_ULP2_RX | F_TP1 | F_CIM | \
 		      F_MC7_CM | F_MC7_PMTX | F_MC7_PMRX | F_SGE3 | F_PCIM0 | \
 		      F_MPS0 | F_CPL_SWITCH)
-
 /*
  * Interrupt handler for the PCIX1 module.
  */
@@ -1722,10 +1828,20 @@ static int mac_intr_handler(struct adapter *adap, unsigned int idx)
 		mac->stats.xaui_pcs_ctc_err++;
 	if (cause & F_XAUIPCSALIGNCHANGE)
 		mac->stats.xaui_pcs_align_change++;
+	if (cause & F_XGM_INT) {
+		t3_set_reg_field(adap,
+				 A_XGM_INT_ENABLE + mac->offset,
+				 F_XGM_INT, 0);
+		mac->stats.link_faults++;
+
+		t3_os_link_fault_handler(adap, idx);
+	}
 
 	t3_write_reg(adap, A_XGM_INT_CAUSE + mac->offset, cause);
+
 	if (cause & XGM_INTR_FATAL)
 		t3_fatal_err(adap);
+
 	return cause != 0;
 }
 
@@ -1931,6 +2047,22 @@ void t3_intr_clear(struct adapter *adapter)
 	t3_read_reg(adapter, A_PL_INT_CAUSE0);	/* flush */
 }
 
+void t3_xgm_intr_enable(struct adapter *adapter, int idx)
+{
+	struct port_info *pi = adap2pinfo(adapter, idx);
+
+	t3_write_reg(adapter, A_XGM_XGM_INT_ENABLE + pi->mac.offset,
+		     XGM_EXTRA_INTR_MASK);
+}
+
+void t3_xgm_intr_disable(struct adapter *adapter, int idx)
+{
+	struct port_info *pi = adap2pinfo(adapter, idx);
+
+	t3_write_reg(adapter, A_XGM_XGM_INT_DISABLE + pi->mac.offset,
+		     0x7ff);
+}
+
 /**
  *	t3_port_intr_enable - enable port-specific interrupts
  *	@adapter: associated adapter
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 4bd0901..f87f943 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -218,6 +218,9 @@ static int t3b2_mac_reset(struct cmac *mac)
 	/* re-enable nic traffic */
 	t3_set_reg_field(adap, A_MPS_CFG, F_ENFORCEPKT, 1);
 
+	/*  Set: re-enable NIC traffic */
+	t3_set_reg_field(adap, A_MPS_CFG, F_ENFORCEPKT, 1);
+
 	return 0;
 }
 
@@ -258,7 +261,7 @@ int t3_mac_set_num_ucast(struct cmac *mac, int n)
 	return 0;
 }
 
-static void disable_exact_filters(struct cmac *mac)
+void t3_mac_disable_exact_filters(struct cmac *mac)
 {
 	unsigned int i, reg = mac->offset + A_XGM_RX_EXACT_MATCH_LOW_1;
 
@@ -269,7 +272,7 @@ static void disable_exact_filters(struct cmac *mac)
 	t3_read_reg(mac->adapter, A_XGM_RX_EXACT_MATCH_LOW_1);	/* flush */
 }
 
-static void enable_exact_filters(struct cmac *mac)
+void t3_mac_enable_exact_filters(struct cmac *mac)
 {
 	unsigned int i, reg = mac->offset + A_XGM_RX_EXACT_MATCH_HIGH_1;
 
@@ -356,7 +359,7 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 
 	if (adap->params.rev >= T3_REV_B2 &&
 	    (t3_read_reg(adap, A_XGM_RX_CTRL + mac->offset) & F_RXEN)) {
-		disable_exact_filters(mac);
+		t3_mac_disable_exact_filters(mac);
 		v = t3_read_reg(adap, A_XGM_RX_CFG + mac->offset);
 		t3_set_reg_field(adap, A_XGM_RX_CFG + mac->offset,
 				 F_ENHASHMCAST | F_COPYALLFRAMES, F_DISBCAST);
@@ -368,14 +371,14 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 		if (t3_wait_op_done(adap, reg + mac->offset,
 				    F_RXFIFO_EMPTY, 1, 20, 5)) {
 			t3_write_reg(adap, A_XGM_RX_CFG + mac->offset, v);
-			enable_exact_filters(mac);
+			t3_mac_enable_exact_filters(mac);
 			return -EIO;
 		}
 		t3_set_reg_field(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset,
 				 V_RXMAXPKTSIZE(M_RXMAXPKTSIZE),
 				 V_RXMAXPKTSIZE(mtu));
 		t3_write_reg(adap, A_XGM_RX_CFG + mac->offset, v);
-		enable_exact_filters(mac);
+		t3_mac_enable_exact_filters(mac);
 	} else
 		t3_set_reg_field(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset,
 				 V_RXMAXPKTSIZE(M_RXMAXPKTSIZE),

