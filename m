From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/2] cxgb3 - T3C support update
Date: Wed, 05 Dec 2007 10:15:01 -0800
Message-ID: <20071205181501.22081.97696.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28681 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbXLESPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 13:15:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Update GPIO mapping for T3C.
Update xgmac for T3C support.
Fix typo in mtu table.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/regs.h  |   27 ++++++++++++++++++++++++++-
 drivers/net/cxgb3/t3_hw.c |    6 +++---
 drivers/net/cxgb3/xgmac.c |   44 +++++++++++++++++++++++++++++---------------
 3 files changed, 58 insertions(+), 19 deletions(-)

diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index a7d5f65..70e1961 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1959,6 +1959,10 @@
 
 #define A_XGM_RXFIFO_CFG 0x884
 
+#define S_RXFIFO_EMPTY    31
+#define V_RXFIFO_EMPTY(x) ((x) << S_RXFIFO_EMPTY)
+#define F_RXFIFO_EMPTY    V_RXFIFO_EMPTY(1U)
+
 #define S_RXFIFOPAUSEHWM    17
 #define M_RXFIFOPAUSEHWM    0xfff
 
@@ -1983,6 +1987,10 @@
 
 #define A_XGM_TXFIFO_CFG 0x888
 
+#define S_UNDERUNFIX    22
+#define V_UNDERUNFIX(x) ((x) << S_UNDERUNFIX)
+#define F_UNDERUNFIX    V_UNDERUNFIX(1U)
+
 #define S_TXIPG    13
 #define M_TXIPG    0xff
 #define V_TXIPG(x) ((x) << S_TXIPG)
@@ -2056,10 +2064,27 @@
 #define V_XAUIIMP(x) ((x) << S_XAUIIMP)
 
 #define A_XGM_RX_MAX_PKT_SIZE 0x8a8
-#define A_XGM_RX_MAX_PKT_SIZE_ERR_CNT 0x9a4
+
+#define S_RXMAXFRAMERSIZE    17
+#define M_RXMAXFRAMERSIZE    0x3fff
+#define V_RXMAXFRAMERSIZE(x) ((x) << S_RXMAXFRAMERSIZE)
+#define G_RXMAXFRAMERSIZE(x) (((x) >> S_RXMAXFRAMERSIZE) & M_RXMAXFRAMERSIZE)
+
+#define S_RXENFRAMER    14
+#define V_RXENFRAMER(x) ((x) << S_RXENFRAMER)
+#define F_RXENFRAMER    V_RXENFRAMER(1U)
+
+#define S_RXMAXPKTSIZE    0
+#define M_RXMAXPKTSIZE    0x3fff
+#define V_RXMAXPKTSIZE(x) ((x) << S_RXMAXPKTSIZE)
+#define G_RXMAXPKTSIZE(x) (((x) >> S_RXMAXPKTSIZE) & M_RXMAXPKTSIZE)
 
 #define A_XGM_RESET_CTRL 0x8ac
 
+#define S_XGMAC_STOP_EN    4
+#define V_XGMAC_STOP_EN(x) ((x) << S_XGMAC_STOP_EN)
+#define F_XGMAC_STOP_EN    V_XGMAC_STOP_EN(1U)
+
 #define S_XG2G_RESET_    3
 #define V_XG2G_RESET_(x) ((x) << S_XG2G_RESET_)
 #define F_XG2G_RESET_    V_XG2G_RESET_(1U)
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 553dd9a..dfdda47 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -447,8 +447,8 @@ static const struct adapter_info t3_adap_info[] = {
 	 &mi1_mdio_ops, "Chelsio T302"},
 	{1, 0, 0, 0,
 	 F_GPIO1_OEN | F_GPIO6_OEN | F_GPIO7_OEN | F_GPIO10_OEN |
-	 F_GPIO1_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL, 0,
-	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
+	 F_GPIO11_OEN | F_GPIO1_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL,
+	 0, SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
 	 &mi1_mdio_ext_ops, "Chelsio T310"},
 	{2, 0, 0, 0,
 	 F_GPIO1_OEN | F_GPIO2_OEN | F_GPIO4_OEN | F_GPIO5_OEN | F_GPIO6_OEN |
@@ -2631,7 +2631,7 @@ static void __devinit init_mtus(unsigned short mtus[])
 	 * it can accomodate max size TCP/IP headers when SACK and timestamps
 	 * are enabled and still have at least 8 bytes of payload.
 	 */
-	mtus[1] = 88;
+	mtus[0] = 88;
 	mtus[1] = 88;
 	mtus[2] = 256;
 	mtus[3] = 512;
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 98303fd..ffdc0a1 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -106,6 +106,7 @@ int t3_mac_reset(struct cmac *mac)
 	t3_set_reg_field(adap, A_XGM_RXFIFO_CFG + oft,
 			 F_RXSTRFRWRD | F_DISERRFRAMES,
 			 uses_xaui(adap) ? 0 : F_RXSTRFRWRD);
+	t3_set_reg_field(adap, A_XGM_TXFIFO_CFG + oft, 0, F_UNDERUNFIX);
 
 	if (uses_xaui(adap)) {
 		if (adap->params.rev == 0) {
@@ -124,7 +125,11 @@ int t3_mac_reset(struct cmac *mac)
 			xaui_serdes_reset(mac);
 	}
 
-	val = F_MAC_RESET_;
+	t3_set_reg_field(adap, A_XGM_RX_MAX_PKT_SIZE + oft,
+			 V_RXMAXFRAMERSIZE(M_RXMAXFRAMERSIZE),
+			 V_RXMAXFRAMERSIZE(MAX_FRAME_SIZE) | F_RXENFRAMER);
+	val = F_MAC_RESET_ | F_XGMAC_STOP_EN;
+
 	if (is_10G(adap))
 		val |= F_PCS_RESET_;
 	else if (uses_xaui(adap))
@@ -313,8 +318,9 @@ static int rx_fifo_hwm(int mtu)
 
 int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 {
-	int hwm, lwm;
-	unsigned int thres, v;
+	int hwm, lwm, divisor;
+	int ipg;
+	unsigned int thres, v, reg;
 	struct adapter *adap = mac->adapter;
 
 	/*
@@ -335,27 +341,32 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 	hwm = min(hwm, MAC_RXFIFO_SIZE - 8192);
 	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
 
-	if (adap->params.rev == T3_REV_B2 &&
+	if (adap->params.rev >= T3_REV_B2 &&
 	    (t3_read_reg(adap, A_XGM_RX_CTRL + mac->offset) & F_RXEN)) {
 		disable_exact_filters(mac);
 		v = t3_read_reg(adap, A_XGM_RX_CFG + mac->offset);
 		t3_set_reg_field(adap, A_XGM_RX_CFG + mac->offset,
 				 F_ENHASHMCAST | F_COPYALLFRAMES, F_DISBCAST);
 
-		/* drain rx FIFO */
-		if (t3_wait_op_done(adap,
-				    A_XGM_RX_MAX_PKT_SIZE_ERR_CNT +
-				    mac->offset,
-				    1 << 31, 1, 20, 5)) {
+		reg = adap->params.rev == T3_REV_B2 ?
+			A_XGM_RX_MAX_PKT_SIZE_ERR_CNT : A_XGM_RXFIFO_CFG;
+
+		/* drain RX FIFO */
+		if (t3_wait_op_done(adap, reg + mac->offset,
+				    F_RXFIFO_EMPTY, 1, 20, 5)) {
 			t3_write_reg(adap, A_XGM_RX_CFG + mac->offset, v);
 			enable_exact_filters(mac);
 			return -EIO;
 		}
-		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
+		t3_set_reg_field(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset,
+				 V_RXMAXPKTSIZE(M_RXMAXPKTSIZE),
+				 V_RXMAXPKTSIZE(mtu));
 		t3_write_reg(adap, A_XGM_RX_CFG + mac->offset, v);
 		enable_exact_filters(mac);
 	} else
-		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
+		t3_set_reg_field(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset,
+				 V_RXMAXPKTSIZE(M_RXMAXPKTSIZE),
+				 V_RXMAXPKTSIZE(mtu));
 
 	/*
 	 * Adjust the PAUSE frame watermarks.  We always set the LWM, and the
@@ -379,13 +390,16 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 		thres /= 10;
 	thres = mtu > thres ? (mtu - thres + 7) / 8 : 0;
 	thres = max(thres, 8U);	/* need at least 8 */
+	ipg = (adap->params.rev == T3_REV_C) ? 0 : 1;
 	t3_set_reg_field(adap, A_XGM_TXFIFO_CFG + mac->offset,
 			 V_TXFIFOTHRESH(M_TXFIFOTHRESH) | V_TXIPG(M_TXIPG),
-			 V_TXFIFOTHRESH(thres) | V_TXIPG(1));
+			 V_TXFIFOTHRESH(thres) | V_TXIPG(ipg));
 
-	if (adap->params.rev > 0)
+	if (adap->params.rev > 0) {
+		divisor = (adap->params.rev == T3_REV_C) ? 64 : 8;
 		t3_write_reg(adap, A_XGM_PAUSE_TIMER + mac->offset,
-			     (hwm - lwm) * 4 / 8);
+			     (hwm - lwm) * 4 / divisor);
+	}
 	t3_write_reg(adap, A_XGM_TX_PAUSE_QUANTA + mac->offset,
 		     MAC_RXFIFO_SIZE * 4 * 8 / 512);
 	return 0;
@@ -522,7 +536,7 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 		goto rxcheck;
 	}
 
-	if ((tx_tcnt != mac->tx_tcnt) && (mac->tx_xcnt == 0))  {
+	if ((tx_tcnt != mac->tx_tcnt) && (mac->tx_xcnt == 0)) {
 		if (mac->toggle_cnt > 4) {
 			status = 2;
 			goto out;
