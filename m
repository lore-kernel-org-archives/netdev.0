From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 7/10] cxgb3: Update Rev3 mac workaround
Date: Fri, 13 Mar 2009 00:14:14 -0700
Message-ID: <20090313071414.21994.90117.stgit@speedy5>
References: <20090313071343.21994.85719.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27591 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415AbZCMHOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:14:17 -0400
In-Reply-To: <20090313071343.21994.85719.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Update the heurstics workaround unlocking a hung mac:
- reduce Tx mac toggling by enabling Tx drain before resetting the mac
- Take Tx (lack of) activity in account only
- Update the monitoring counter range to 64 bits

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/xgmac.c |   72 +++++++++++++++++++++------------------------
 1 files changed, 33 insertions(+), 39 deletions(-)

diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 9d77869..4bd0901 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -150,7 +150,8 @@ int t3_mac_reset(struct cmac *mac)
 static int t3b2_mac_reset(struct cmac *mac)
 {
 	struct adapter *adap = mac->adapter;
-	unsigned int oft = mac->offset;
+	unsigned int oft = mac->offset, store;
+	int idx = macidx(mac);
 	u32 val;
 
 	if (!macidx(mac))
@@ -158,14 +159,28 @@ static int t3b2_mac_reset(struct cmac *mac)
 	else
 		t3_set_reg_field(adap, A_MPS_CFG, F_PORT1ACTIVE, 0);
 
+	/* Stop NIC traffic to reduce the number of TXTOGGLES */
+	t3_set_reg_field(adap, A_MPS_CFG, F_ENFORCEPKT, 0);
+	/* Ensure TX drains */
+	t3_set_reg_field(adap, A_XGM_TX_CFG + oft, F_TXPAUSEEN, 0);
+
 	t3_write_reg(adap, A_XGM_RESET_CTRL + oft, F_MAC_RESET_);
 	t3_read_reg(adap, A_XGM_RESET_CTRL + oft);    /* flush */
 
+	/* Store A_TP_TX_DROP_CFG_CH0 */
+	t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
+	store = t3_read_reg(adap, A_TP_TX_DROP_CFG_CH0 + idx);
+
 	msleep(10);
 
+	/* Change DROP_CFG to 0xc0000011 */
+	t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
+	t3_write_reg(adap, A_TP_PIO_DATA, 0xc0000011);
+
 	/* Check for xgm Rx fifo empty */
+	/* Increased loop count to 1000 from 5 cover 1G and 100Mbps case */
 	if (t3_wait_op_done(adap, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT + oft,
-			    0x80000000, 1, 5, 2)) {
+			    0x80000000, 1, 1000, 2)) {
 		CH_ERR(adap, "MAC %d Rx fifo drain failed\n",
 		       macidx(mac));
 		return -1;
@@ -191,11 +206,18 @@ static int t3b2_mac_reset(struct cmac *mac)
 		     F_DISPAUSEFRAMES | F_EN1536BFRAMES |
 		     F_RMFCS | F_ENJUMBO | F_ENHASHMCAST);
 
-	if (!macidx(mac))
+	/* Restore the DROP_CFG */
+	t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
+	t3_write_reg(adap, A_TP_PIO_DATA, store);
+
+	if (!idx)
 		t3_set_reg_field(adap, A_MPS_CFG, 0, F_PORT0ACTIVE);
 	else
 		t3_set_reg_field(adap, A_MPS_CFG, 0, F_PORT1ACTIVE);
 
+	/* re-enable nic traffic */
+	t3_set_reg_field(adap, A_MPS_CFG, F_ENFORCEPKT, 1);
+
 	return 0;
 }
 
@@ -332,15 +354,6 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 		return -EINVAL;
 	t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
 
-	/*
-	 * Adjust the PAUSE frame watermarks.  We always set the LWM, and the
-	 * HWM only if flow-control is enabled.
-	 */
-	hwm = max_t(unsigned int, MAC_RXFIFO_SIZE - 3 * mtu,
-		    MAC_RXFIFO_SIZE * 38 / 100);
-	hwm = min(hwm, MAC_RXFIFO_SIZE - 8192);
-	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
-
 	if (adap->params.rev >= T3_REV_B2 &&
 	    (t3_read_reg(adap, A_XGM_RX_CTRL + mac->offset) & F_RXEN)) {
 		disable_exact_filters(mac);
@@ -452,9 +465,12 @@ int t3_mac_enable(struct cmac *mac, int which)
 
 	if (which & MAC_DIRECTION_TX) {
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
-		t3_write_reg(adap, A_TP_PIO_DATA, 0xc0ede401);
+		t3_write_reg(adap, A_TP_PIO_DATA,
+			     adap->params.rev == T3_REV_C ?
+			     0xc4ffff01 : 0xc0ede401);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_MODE);
-		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 1 << idx);
+		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx,
+				 adap->params.rev == T3_REV_C ? 0 : 1 << idx);
 
 		t3_write_reg(adap, A_XGM_TX_CTRL + oft, F_TXEN);
 
@@ -510,15 +526,12 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 	struct adapter *adap = mac->adapter;
 	struct mac_stats *s = &mac->stats;
 	unsigned int tx_tcnt, tx_xcnt;
-	unsigned int tx_mcnt = s->tx_frames;
-	unsigned int rx_mcnt = s->rx_frames;
-	unsigned int rx_xcnt;
+	u64 tx_mcnt = s->tx_frames;
 	int status;
 
 	status = 0;
 	tx_xcnt = 1;		/* By default tx_xcnt is making progress */
 	tx_tcnt = mac->tx_tcnt;	/* If tx_mcnt is progressing ignore tx_tcnt */
-	rx_xcnt = 1;		/* By default rx_xcnt is making progress */
 	if (tx_mcnt == mac->tx_mcnt && mac->rx_pause == s->rx_pause) {
 		tx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
 						A_XGM_TX_SPI4_SOP_EOP_CNT +
@@ -529,11 +542,11 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 			tx_tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
 						      A_TP_PIO_DATA)));
 		} else {
-			goto rxcheck;
+			goto out;
 		}
 	} else {
 		mac->toggle_cnt = 0;
-		goto rxcheck;
+		goto out;
 	}
 
 	if ((tx_tcnt != mac->tx_tcnt) && (mac->tx_xcnt == 0)) {
@@ -546,23 +559,6 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 		}
 	} else {
 		mac->toggle_cnt = 0;
-		goto rxcheck;
-	}
-
-rxcheck:
-	if (rx_mcnt != mac->rx_mcnt) {
-		rx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
-						A_XGM_RX_SPI4_SOP_EOP_CNT +
-						mac->offset))) +
-						(s->rx_fifo_ovfl -
-						 mac->rx_ocnt);
-		mac->rx_ocnt = s->rx_fifo_ovfl;
-	} else
-		goto out;
-
-	if (mac->rx_mcnt != s->rx_frames && rx_xcnt == 0 &&
-	    mac->rx_xcnt == 0) {
-		status = 2;
 		goto out;
 	}
 
@@ -570,8 +566,6 @@ out:
 	mac->tx_tcnt = tx_tcnt;
 	mac->tx_xcnt = tx_xcnt;
 	mac->tx_mcnt = s->tx_frames;
-	mac->rx_xcnt = rx_xcnt;
-	mac->rx_mcnt = s->rx_frames;
 	mac->rx_pause = s->rx_pause;
 	if (status == 1) {
 		t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, 0);

