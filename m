From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/13] cxgb3 - MAC workaround update
Date: Fri, 10 Aug 2007 23:29:33 -0700
Message-ID: <20070811062933.8022.51781.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:6107 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbXHKG3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 02:29:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Update the MAC workaround to deal with switches that do not
honor pause frames.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h |    1 +
 drivers/net/cxgb3/xgmac.c  |   22 +++++++++++-----------
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 1637800..c46c249 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -507,6 +507,7 @@ struct cmac {
 	unsigned int tx_xcnt;
 	u64 tx_mcnt;
 	unsigned int rx_xcnt;
+	unsigned int rx_ocnt;
 	u64 rx_mcnt;
 	unsigned int toggle_cnt;
 	unsigned int txen;
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index c302b1a..1d1c391 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -437,12 +437,13 @@ int t3_mac_enable(struct cmac *mac, int which)
 	struct mac_stats *s = &mac->stats;
 	
 	if (which & MAC_DIRECTION_TX) {
-		t3_write_reg(adap, A_XGM_TX_CTRL + oft, F_TXEN);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
 		t3_write_reg(adap, A_TP_PIO_DATA, 0xc0ede401);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_MODE);
 		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 1 << idx);
 
+		t3_write_reg(adap, A_XGM_TX_CTRL + oft, F_TXEN);
+
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CNT_CH0 + idx);
 		mac->tx_mcnt = s->tx_frames;
 		mac->tx_tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
@@ -454,6 +455,7 @@ int t3_mac_enable(struct cmac *mac, int which)
 		mac->rx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
 						A_XGM_RX_SPI4_SOP_EOP_CNT +
 						oft)));
+		mac->rx_ocnt = s->rx_fifo_ovfl;
 		mac->txen = F_TXEN;
 		mac->toggle_cnt = 0;
 	}
@@ -464,24 +466,19 @@ int t3_mac_enable(struct cmac *mac, int which)
 
 int t3_mac_disable(struct cmac *mac, int which)
 {
-	int idx = macidx(mac);
 	struct adapter *adap = mac->adapter;
-	int val;
 
 	if (which & MAC_DIRECTION_TX) {
 		t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, 0);
-		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
-		t3_write_reg(adap, A_TP_PIO_DATA, 0xc000001f);
-		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_MODE);
-		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 1 << idx);
 		mac->txen = 0;
 	}
 	if (which & MAC_DIRECTION_RX) {
+		int val = F_MAC_RESET_;
+
 		t3_set_reg_field(mac->adapter, A_XGM_RESET_CTRL + mac->offset,
 				 F_PCS_RESET_, 0);
 		msleep(100);
 		t3_write_reg(adap, A_XGM_RX_CTRL + mac->offset, 0);
-		val = F_MAC_RESET_;
 		if (is_10G(adap))
 			val |= F_PCS_RESET_;
 		else if (uses_xaui(adap))
@@ -541,11 +538,14 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 	}
 
 rxcheck:
-	if (rx_mcnt != mac->rx_mcnt)
+	if (rx_mcnt != mac->rx_mcnt) {
 		rx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
 						A_XGM_RX_SPI4_SOP_EOP_CNT +
-						mac->offset)));
-	else
+						mac->offset))) +
+						(s->rx_fifo_ovfl -
+						 mac->rx_ocnt);
+		mac->rx_ocnt = s->rx_fifo_ovfl;
+	} else
 		goto out;
 
 	if (mac->rx_mcnt != s->rx_frames && rx_xcnt == 0 &&
