From: divy@chelsio.com
Subject: [PATCH 4/5] cxgb3 - Stop mac RX when changing MTU
Date: Wed, 30 May 2007 10:01:44 -0700
Message-ID: <20070530170144.22843.74669.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:5180 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756906AbXE3RBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 13:01:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Rx traffic needs to be halted when the MTU is changed
to avoid a potential chip hang.
Reset/restore MAC filters around a MTU change.
Also fix the pause frames high materwark setting.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/regs.h  |    4 +++
 drivers/net/cxgb3/xgmac.c |   67 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 70 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index bf9d6be..020859c 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1882,6 +1882,10 @@
 #define V_COPYALLFRAMES(x) ((x) << S_COPYALLFRAMES)
 #define F_COPYALLFRAMES    V_COPYALLFRAMES(1U)
 
+#define S_DISBCAST    1
+#define V_DISBCAST(x) ((x) << S_DISBCAST)
+#define F_DISBCAST    V_DISBCAST(1U)
+
 #define A_XGM_RX_HASH_LOW 0x814
 
 #define A_XGM_RX_HASH_HIGH 0x818
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index a506792..16cadba 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -231,6 +231,28 @@ int t3_mac_set_num_ucast(struct cmac *ma
 	return 0;
 }
 
+static void disable_exact_filters(struct cmac *mac)
+{
+	unsigned int i, reg = mac->offset + A_XGM_RX_EXACT_MATCH_LOW_1;
+
+	for (i = 0; i < EXACT_ADDR_FILTERS; i++, reg += 8) {
+		u32 v = t3_read_reg(mac->adapter, reg);
+		t3_write_reg(mac->adapter, reg, v);
+	}
+	t3_read_reg(mac->adapter, A_XGM_RX_EXACT_MATCH_LOW_1);	/* flush */
+}
+
+static void enable_exact_filters(struct cmac *mac)
+{
+	unsigned int i, reg = mac->offset + A_XGM_RX_EXACT_MATCH_HIGH_1;
+
+	for (i = 0; i < EXACT_ADDR_FILTERS; i++, reg += 8) {
+		u32 v = t3_read_reg(mac->adapter, reg);
+		t3_write_reg(mac->adapter, reg, v);
+	}
+	t3_read_reg(mac->adapter, A_XGM_RX_EXACT_MATCH_LOW_1);	/* flush */
+}
+
 /* Calculate the RX hash filter index of an Ethernet address */
 static int hash_hw_addr(const u8 * addr)
 {
@@ -281,6 +303,14 @@ int t3_mac_set_rx_mode(struct cmac *mac,
 	return 0;
 }
 
+static int rx_fifo_hwm(int mtu)
+{
+	int hwm;
+
+	hwm = max(MAC_RXFIFO_SIZE - 3 * mtu, (MAC_RXFIFO_SIZE * 38) / 100);
+	return min(hwm, MAC_RXFIFO_SIZE - 8192);
+}
+
 int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 {
 	int hwm, lwm;
@@ -306,11 +336,38 @@ int t3_mac_set_mtu(struct cmac *mac, uns
 	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
 
 	v = t3_read_reg(adap, A_XGM_RXFIFO_CFG + mac->offset);
+	if (adap->params.rev == T3_REV_B2 &&
+	    (t3_read_reg(adap, A_XGM_RX_CTRL + mac->offset) & F_RXEN)) {
+		disable_exact_filters(mac);
+		t3_set_reg_field(adap, A_XGM_RXFIFO_CFG + mac->offset,
+				 F_ENHASHMCAST | F_COPYALLFRAMES, F_DISBCAST);
+
+		/* drain rx FIFO */
+		if (t3_wait_op_done(adap,
+				    A_XGM_RX_MAX_PKT_SIZE_ERR_CNT +
+				    mac->offset,
+				    1 << 31, 1, 20, 5)) {
+			t3_write_reg(adap, A_XGM_RXFIFO_CFG + mac->offset, v);
+			enable_exact_filters(mac);
+			return -EIO;
+		}
+		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
+		enable_exact_filters(mac);
+	} else
+		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
+
+	/*
+	 * Adjust the PAUSE frame watermarks.  We always set the LWM, and the
+	 * HWM only if flow-control is enabled.
+	 */
+	hwm = rx_fifo_hwm(mtu);
+	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
 	v &= ~V_RXFIFOPAUSELWM(M_RXFIFOPAUSELWM);
 	v |= V_RXFIFOPAUSELWM(lwm / 8);
 	if (G_RXFIFOPAUSEHWM(v))
 		v = (v & ~V_RXFIFOPAUSEHWM(M_RXFIFOPAUSEHWM)) |
 		    V_RXFIFOPAUSEHWM(hwm / 8);
+
 	t3_write_reg(adap, A_XGM_RXFIFO_CFG + mac->offset, v);
 
 	/* Adjust the TX FIFO threshold based on the MTU */
@@ -329,7 +386,6 @@ int t3_mac_set_mtu(struct cmac *mac, uns
 			     (hwm - lwm) * 4 / 8);
 	t3_write_reg(adap, A_XGM_TX_PAUSE_QUANTA + mac->offset,
 		     MAC_RXFIFO_SIZE * 4 * 8 / 512);
-
 	return 0;
 }
 
@@ -357,6 +413,15 @@ int t3_mac_set_speed_duplex_fc(struct cm
 				 V_PORTSPEED(M_PORTSPEED), val);
 	}
 
+	val = t3_read_reg(adap, A_XGM_RXFIFO_CFG + oft);
+	val &= ~V_RXFIFOPAUSEHWM(M_RXFIFOPAUSEHWM);
+	if (fc & PAUSE_TX)
+		val |= V_RXFIFOPAUSEHWM(rx_fifo_hwm(
+						t3_read_reg(adap,
+						A_XGM_RX_MAX_PKT_SIZE
+						+ oft)) / 8);
+	t3_write_reg(adap, A_XGM_RXFIFO_CFG + oft, val);
+
 	t3_set_reg_field(adap, A_XGM_TX_CFG + oft, F_TXPAUSEEN,
 			 (fc & PAUSE_RX) ? F_TXPAUSEEN : 0);
 	return 0;
