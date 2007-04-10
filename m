From: divy@chelsio.com
Subject: [PATCH 2.6.21 2/3] cxgb3 - MAC watchdog update
Date: Mon, 09 Apr 2007 20:10:27 -0700
Message-ID: <20070410031027.12896.88409.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932760AbXDJDKo@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

The MAC watchdog was failing if the peer interface was brought down.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    7 ++-
 drivers/net/cxgb3/cxgb3_main.c |   10 +---
 drivers/net/cxgb3/xgmac.c      |  107 ++++++++++++++++++++++++++++++----------
 3 files changed, 89 insertions(+), 35 deletions(-)

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
index c6ebe25..d6eb982 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -194,15 +194,13 @@ void t3_os_link_changed(struct adapter *
 
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
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 94aaff0..a506792 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -367,7 +367,8 @@ int t3_mac_enable(struct cmac *mac, int
 	int idx = macidx(mac);
 	struct adapter *adap = mac->adapter;
 	unsigned int oft = mac->offset;
-
+	struct mac_stats *s = &mac->stats;
+	
 	if (which & MAC_DIRECTION_TX) {
 		t3_write_reg(adap, A_XGM_TX_CTRL + oft, F_TXEN);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
@@ -376,10 +377,16 @@ int t3_mac_enable(struct cmac *mac, int
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
@@ -392,6 +399,7 @@ int t3_mac_disable(struct cmac *mac, int
 {
 	int idx = macidx(mac);
 	struct adapter *adap = mac->adapter;
+	int val;
 
 	if (which & MAC_DIRECTION_TX) {
 		t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, 0);
@@ -401,44 +409,89 @@ int t3_mac_disable(struct cmac *mac, int
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
 
