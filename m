From: divy@chelsio.com
Subject: [PATCH 2.6.21 3/4] cxgb3 - Fix potential MAC hang
Date: Sun, 18 Mar 2007 13:10:12 -0700
Message-ID: <20070318201011.16310.77866.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933142AbXCRULN@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Under rare conditions, the MAC might hang while generating a pause frame.
This patch fine tunes the MAC settings to avoid the issue, allows for 
periodic MAC state check, and triggers a recovery if hung. 

Also fix one MAC statistics counter for the rev board T3B2.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---
---

 drivers/net/cxgb3/common.h     |   15 +++++
 drivers/net/cxgb3/cxgb3_main.c |   46 ++++++++++++++
 drivers/net/cxgb3/regs.h       |   22 +++++++
 drivers/net/cxgb3/xgmac.c      |  133 +++++++++++++++++++++++++++++++++++-----
 4 files changed, 200 insertions(+), 16 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index e23deeb..85e5543 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -260,6 +260,10 @@ struct mac_stats {
 	unsigned long serdes_signal_loss;
 	unsigned long xaui_pcs_ctc_err;
 	unsigned long xaui_pcs_align_change;
+
+	unsigned long num_toggled; /* # times toggled TxEn due to stuck TX */
+	unsigned long num_resets;  /* # times reset due to stuck TX */
+
 };
 
 struct tp_mib_stats {
@@ -400,6 +404,12 @@ struct adapter_params {
 	unsigned int rev;	/* chip revision */
 };
 
+enum {					    /* chip revisions */
+	T3_REV_A  = 0,
+	T3_REV_B  = 2,
+	T3_REV_B2 = 3,
+};
+
 struct trace_params {
 	u32 sip;
 	u32 sip_mask;
@@ -465,6 +475,10 @@ struct cmac {
 	struct adapter *adapter;
 	unsigned int offset;
 	unsigned int nucast;	/* # of address filters for unicast MACs */
+	unsigned int tcnt;
+	unsigned int xcnt;
+	unsigned int toggle_cnt;
+	unsigned int txen;
 	struct mac_stats stats;
 };
 
@@ -666,6 +680,7 @@ int t3_mac_set_address(struct cmac *mac,
 int t3_mac_set_num_ucast(struct cmac *mac, int n);
 const struct mac_stats *t3_mac_update_stats(struct cmac *mac);
 int t3_mac_set_speed_duplex_fc(struct cmac *mac, int speed, int duplex, int fc);
+int t3b2_mac_watchdog_task(struct cmac *mac);
 
 void t3_mc5_prep(struct adapter *adapter, struct mc5 *mc5, int mode);
 int t3_mc5_init(struct mc5 *mc5, unsigned int nservers, unsigned int nfilters,
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index b9bcda8..d553836 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1056,7 +1056,11 @@ static char stats_strings[][ETH_GSTRING_
 	"VLANinsertions     ",
 	"TxCsumOffload      ",
 	"RxCsumGood         ",
-	"RxDrops            "
+	"RxDrops            ",
+
+	"CheckTXEnToggled   ",
+	"CheckResets        ",
+
 };
 
 static int get_stats_count(struct net_device *dev)
@@ -1170,6 +1174,9 @@ static void get_stats(struct net_device
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_TX_CSUM);
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_RX_CSUM_GOOD);
 	*data++ = s->rx_cong_drops;
+
+	*data++ = s->num_toggled;
+	*data++ = s->num_resets;
 }
 
 static inline void reg_block_dump(struct adapter *ap, void *buf,
@@ -2095,6 +2102,40 @@ static void check_link_status(struct ada
 	}
 }
 
+static void check_t3b2_mac(struct adapter *adapter)
+{
+	int i;
+
+	rtnl_lock();                      /* synchronize with ifdown */
+	for_each_port(adapter, i) {
+		struct net_device *dev = adapter->port[i];
+		struct port_info *p = netdev_priv(dev);
+		int status;
+
+		if (!netif_running(dev))
+			continue;
+
+		status = 0;
+		if (netif_running(dev))
+			status = t3b2_mac_watchdog_task(&p->mac);
+		if (status == 1)
+			p->mac.stats.num_toggled++;
+		else if (status == 2) {
+			struct cmac *mac = &p->mac;
+
+			t3_mac_set_mtu(mac, dev->mtu);
+			t3_mac_set_address(mac, 0, dev->dev_addr);
+			cxgb_set_rxmode(dev);
+			t3_link_start(&p->phy, mac, &p->link_config);
+			t3_mac_enable(mac, MAC_DIRECTION_RX | MAC_DIRECTION_TX);
+			t3_port_intr_enable(adapter, p->port_id);
+			p->mac.stats.num_resets++;
+		}
+	}
+	rtnl_unlock();
+}
+
+
 static void t3_adap_check_task(struct work_struct *work)
 {
 	struct adapter *adapter = container_of(work, struct adapter,
@@ -2115,6 +2156,9 @@ static void t3_adap_check_task(struct wo
 		adapter->check_task_cnt = 0;
 	}
 
+	if (p->rev == T3_REV_B2)
+		check_t3b2_mac(adapter);
+
 	/* Schedule the next check update if any port is active. */
 	spin_lock(&adapter->work_lock);
 	if (adapter->open_device_map & PORT_MASK)
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index b56c5f5..b38629a 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1206,6 +1206,14 @@
 
 #define A_TP_RX_TRC_KEY0 0x120
 
+#define A_TP_TX_DROP_CNT_CH0 0x12d
+
+#define S_TXDROPCNTCH0RCVD    0
+#define M_TXDROPCNTCH0RCVD    0xffff
+#define V_TXDROPCNTCH0RCVD(x) ((x) << S_TXDROPCNTCH0RCVD)
+#define G_TXDROPCNTCH0RCVD(x) (((x) >> S_TXDROPCNTCH0RCVD) & \
+			       M_TXDROPCNTCH0RCVD)
+
 #define A_ULPRX_CTL 0x500
 
 #define S_ROUND_ROBIN    4
@@ -1834,6 +1842,8 @@
 #define V_TXPAUSEEN(x) ((x) << S_TXPAUSEEN)
 #define F_TXPAUSEEN    V_TXPAUSEEN(1U)
 
+#define A_XGM_TX_PAUSE_QUANTA 0x808
+
 #define A_XGM_RX_CTRL 0x80c
 
 #define S_RXEN    0
@@ -1920,6 +1930,11 @@
 
 #define A_XGM_TXFIFO_CFG 0x888
 
+#define S_TXIPG    13
+#define M_TXIPG    0xff
+#define V_TXIPG(x) ((x) << S_TXIPG)
+#define G_TXIPG(x) (((x) >> S_TXIPG) & M_TXIPG)
+
 #define S_TXFIFOTHRESH    4
 #define M_TXFIFOTHRESH    0x1ff
 
@@ -2190,6 +2205,13 @@
 
 #define A_XGM_RX_MAX_PKT_SIZE_ERR_CNT 0x9a4
 
+#define A_XGM_TX_SPI4_SOP_EOP_CNT 0x9a8
+
+#define S_TXSPI4SOPCNT    16
+#define M_TXSPI4SOPCNT    0xffff
+#define V_TXSPI4SOPCNT(x) ((x) << S_TXSPI4SOPCNT)
+#define G_TXSPI4SOPCNT(x) (((x) >> S_TXSPI4SOPCNT) & M_TXSPI4SOPCNT)
+
 #define A_XGM_RX_SPI4_SOP_EOP_CNT 0x9ac
 
 #define XGMAC0_1_BASE_ADDR 0xa00
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 907a272..2b42c13 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -124,9 +124,6 @@ int t3_mac_reset(struct cmac *mac)
 			xaui_serdes_reset(mac);
 	}
 
-	if (adap->params.rev > 0)
-		t3_write_reg(adap, A_XGM_PAUSE_TIMER + oft, 0xf000);
-
 	val = F_MAC_RESET_;
 	if (is_10G(adap))
 		val |= F_PCS_RESET_;
@@ -145,6 +142,58 @@ int t3_mac_reset(struct cmac *mac)
 	return 0;
 }
 
+int t3b2_mac_reset(struct cmac *mac)
+{
+	struct adapter *adap = mac->adapter;
+	unsigned int oft = mac->offset;
+	u32 val;
+
+	if (!macidx(mac)) 
+		t3_set_reg_field(adap, A_MPS_CFG, F_PORT0ACTIVE, 0);
+	else
+		t3_set_reg_field(adap, A_MPS_CFG, F_PORT1ACTIVE, 0);
+
+	t3_write_reg(adap, A_XGM_RESET_CTRL + oft, F_MAC_RESET_);
+	t3_read_reg(adap, A_XGM_RESET_CTRL + oft);    /* flush */
+
+	msleep(10);
+
+	/* Check for xgm Rx fifo empty */
+	if (t3_wait_op_done(adap, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT + oft,
+			    0x80000000, 1, 5, 2)) {
+		CH_ERR(adap, "MAC %d Rx fifo drain failed\n",
+		       macidx(mac));
+		return -1;
+	}
+
+	t3_write_reg(adap, A_XGM_RESET_CTRL + oft, 0);
+	t3_read_reg(adap, A_XGM_RESET_CTRL + oft);    /* flush */
+
+	val = F_MAC_RESET_;
+	if (is_10G(adap))
+		val |= F_PCS_RESET_;
+	else if (uses_xaui(adap))
+		val |= F_PCS_RESET_ | F_XG2G_RESET_;
+	else
+		val |= F_RGMII_RESET_ | F_XG2G_RESET_;
+	t3_write_reg(adap, A_XGM_RESET_CTRL + oft, val);
+	t3_read_reg(adap, A_XGM_RESET_CTRL + oft);  /* flush */
+	if ((val & F_PCS_RESET_) && adap->params.rev) {
+		msleep(1);
+		t3b_pcs_reset(mac);
+	}
+	t3_write_reg(adap, A_XGM_RX_CFG + oft, 
+		     F_DISPAUSEFRAMES | F_EN1536BFRAMES |
+		     F_RMFCS | F_ENJUMBO | F_ENHASHMCAST);
+
+	if (!macidx(mac)) 
+		t3_set_reg_field(adap, A_MPS_CFG, 0, F_PORT0ACTIVE);
+	else
+		t3_set_reg_field(adap, A_MPS_CFG, 0, F_PORT1ACTIVE);
+
+	return 0;
+}
+
 /*
  * Set the exact match register 'idx' to recognize the given Ethernet address.
  */
@@ -251,9 +300,11 @@ int t3_mac_set_mtu(struct cmac *mac, uns
 	 * Adjust the PAUSE frame watermarks.  We always set the LWM, and the
 	 * HWM only if flow-control is enabled.
 	 */
-	hwm = max(MAC_RXFIFO_SIZE - 3 * mtu, MAC_RXFIFO_SIZE / 2U);
-	hwm = min(hwm, 3 * MAC_RXFIFO_SIZE / 4 + 1024);
-	lwm = hwm - 1024;
+	hwm = max_t(unsigned int, MAC_RXFIFO_SIZE - 3 * mtu, 
+		    MAC_RXFIFO_SIZE * 38 / 100);
+	hwm = min(hwm, MAC_RXFIFO_SIZE - 8192);
+	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
+
 	v = t3_read_reg(adap, A_XGM_RXFIFO_CFG + mac->offset);
 	v &= ~V_RXFIFOPAUSELWM(M_RXFIFOPAUSELWM);
 	v |= V_RXFIFOPAUSELWM(lwm / 8);
@@ -270,7 +321,15 @@ int t3_mac_set_mtu(struct cmac *mac, uns
 	thres = mtu > thres ? (mtu - thres + 7) / 8 : 0;
 	thres = max(thres, 8U);	/* need at least 8 */
 	t3_set_reg_field(adap, A_XGM_TXFIFO_CFG + mac->offset,
-			 V_TXFIFOTHRESH(M_TXFIFOTHRESH), V_TXFIFOTHRESH(thres));
+			 V_TXFIFOTHRESH(M_TXFIFOTHRESH) | V_TXIPG(M_TXIPG),
+			 V_TXFIFOTHRESH(thres) | V_TXIPG(1));
+
+	if (adap->params.rev > 0)
+		t3_write_reg(adap, A_XGM_PAUSE_TIMER + mac->offset,
+			     (hwm - lwm) * 4 / 8);
+	t3_write_reg(adap, A_XGM_TX_PAUSE_QUANTA + mac->offset,
+		     MAC_RXFIFO_SIZE * 4 * 8 / 512);
+
 	return 0;
 }
 
@@ -298,12 +357,6 @@ int t3_mac_set_speed_duplex_fc(struct cm
 				 V_PORTSPEED(M_PORTSPEED), val);
 	}
 
-	val = t3_read_reg(adap, A_XGM_RXFIFO_CFG + oft);
-	val &= ~V_RXFIFOPAUSEHWM(M_RXFIFOPAUSEHWM);
-	if (fc & PAUSE_TX)
-		val |= V_RXFIFOPAUSEHWM(G_RXFIFOPAUSELWM(val) + 128);	/* +1KB */
-	t3_write_reg(adap, A_XGM_RXFIFO_CFG + oft, val);
-
 	t3_set_reg_field(adap, A_XGM_TX_CFG + oft, F_TXPAUSEEN,
 			 (fc & PAUSE_RX) ? F_TXPAUSEEN : 0);
 	return 0;
@@ -318,9 +371,17 @@ int t3_mac_enable(struct cmac *mac, int
 	if (which & MAC_DIRECTION_TX) {
 		t3_write_reg(adap, A_XGM_TX_CTRL + oft, F_TXEN);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
-		t3_write_reg(adap, A_TP_PIO_DATA, 0xbf000001);
+		t3_write_reg(adap, A_TP_PIO_DATA, 0xc0ede401);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_MODE);
 		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 1 << idx);
+
+		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CNT_CH0 + idx);
+		mac->tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
+							    A_TP_PIO_DATA)));
+		mac->xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
+						A_XGM_TX_SPI4_SOP_EOP_CNT)));
+		mac->txen = F_TXEN;
+		mac->toggle_cnt = 0;
 	}
 	if (which & MAC_DIRECTION_RX)
 		t3_write_reg(adap, A_XGM_RX_CTRL + oft, F_RXEN);
@@ -337,13 +398,50 @@ int t3_mac_disable(struct cmac *mac, int
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
 		t3_write_reg(adap, A_TP_PIO_DATA, 0xc000001f);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_MODE);
-		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 0);
+		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 1 << idx);
+		mac->txen = 0;
 	}
 	if (which & MAC_DIRECTION_RX)
 		t3_write_reg(adap, A_XGM_RX_CTRL + mac->offset, 0);
 	return 0;
 }
 
+int t3b2_mac_watchdog_task(struct cmac *mac)
+{
+	struct adapter *adap = mac->adapter;
+	unsigned int tcnt, xcnt;
+	int status;
+
+	t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CNT_CH0 + macidx(mac));
+	tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap, A_TP_PIO_DATA)));
+	xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap, 
+					   A_XGM_TX_SPI4_SOP_EOP_CNT +
+					   mac->offset)));
+
+	if (tcnt != mac->tcnt && xcnt == 0 && mac->xcnt == 0) {
+		if (mac->toggle_cnt > 4) {
+			t3b2_mac_reset(mac);
+			mac->toggle_cnt = 0;
+			status = 2;
+		} else {
+			t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, 0);
+			t3_read_reg(adap, A_XGM_TX_CTRL + mac->offset);
+			t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset,
+				     mac->txen);
+			t3_read_reg(adap, A_XGM_TX_CTRL + mac->offset);
+			mac->toggle_cnt++;
+			status = 1;
+		}	
+	} else {
+		mac->toggle_cnt = 0;
+		status = 0;
+	}
+	mac->tcnt = tcnt;
+	mac->xcnt = xcnt;
+
+	return status;
+}
+
 /*
  * This function is called periodically to accumulate the current values of the
  * RMON counters into the port statistics.  Since the packet counters are only
@@ -375,6 +473,11 @@ const struct mac_stats *t3_mac_update_st
 	RMON_UPDATE(mac, rx_too_long, RX_OVERSIZE_FRAMES);
 	mac->stats.rx_too_long += RMON_READ(mac, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT);
 
+	v = RMON_READ(mac, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT);
+	if (mac->adapter->params.rev == T3_REV_B2)
+		v &= 0x7fffffff;
+	mac->stats.rx_too_long += v;
+
 	RMON_UPDATE(mac, rx_frames_64, RX_64B_FRAMES);
 	RMON_UPDATE(mac, rx_frames_65_127, RX_65_127B_FRAMES);
 	RMON_UPDATE(mac, rx_frames_128_255, RX_128_255B_FRAMES);
