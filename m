From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/2] bnx2x: Allow management traffic after boot from
 SAN
Date: Thu, 10 Jan 2013 16:53:40 +0200
Message-ID: <1357829620-17890-3-git-send-email-yuvalmin@broadcom.com>
References: <1357829620-17890-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Barak Witkowski" <barak@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3438 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667Ab3AJPv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 10:51:29 -0500
In-Reply-To: <1357829620-17890-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

As part of the previous driver unload flow, whenever bnx2x is
loaded after the UNDI driver it closes all Rx traffic.
However, this leads to management traffic also being stopped until
the network interface associated with one of its functions gets loaded.

To remedy this, management traffic is re-opened once the 'cleaning'
after the previous driver ends.

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   60 +++++++++++++++++++---
 1 files changed, 52 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 940ef85..5523da3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -127,6 +127,17 @@ MODULE_PARM_DESC(debug, " Default debug msglevel");
 
 struct workqueue_struct *bnx2x_wq;
 
+struct bnx2x_mac_vals {
+	u32 xmac_addr;
+	u32 xmac_val;
+	u32 emac_addr;
+	u32 emac_val;
+	u32 umac_addr;
+	u32 umac_val;
+	u32 bmac_addr;
+	u32 bmac_val[2];
+};
+
 enum bnx2x_board_type {
 	BCM57710 = 0,
 	BCM57711,
@@ -9420,12 +9431,19 @@ static inline void bnx2x_undi_int_disable(struct bnx2x *bp)
 		bnx2x_undi_int_disable_e1h(bp);
 }
 
-static void bnx2x_prev_unload_close_mac(struct bnx2x *bp)
+static void bnx2x_prev_unload_close_mac(struct bnx2x *bp,
+					struct bnx2x_mac_vals *vals)
 {
 	u32 val, base_addr, offset, mask, reset_reg;
 	bool mac_stopped = false;
 	u8 port = BP_PORT(bp);
 
+	/* reset addresses as they also mark which values were changed */
+	vals->bmac_addr = 0;
+	vals->umac_addr = 0;
+	vals->xmac_addr = 0;
+	vals->emac_addr = 0;
+
 	reset_reg = REG_RD(bp, MISC_REG_RESET_REG_2);
 
 	if (!CHIP_IS_E3(bp)) {
@@ -9447,14 +9465,18 @@ static void bnx2x_prev_unload_close_mac(struct bnx2x *bp)
 			 */
 			wb_data[0] = REG_RD(bp, base_addr + offset);
 			wb_data[1] = REG_RD(bp, base_addr + offset + 0x4);
+			vals->bmac_addr = base_addr + offset;
+			vals->bmac_val[0] = wb_data[0];
+			vals->bmac_val[1] = wb_data[1];
 			wb_data[0] &= ~BMAC_CONTROL_RX_ENABLE;
-			REG_WR(bp, base_addr + offset, wb_data[0]);
-			REG_WR(bp, base_addr + offset + 0x4, wb_data[1]);
+			REG_WR(bp, vals->bmac_addr, wb_data[0]);
+			REG_WR(bp, vals->bmac_addr + 0x4, wb_data[1]);
 
 		}
 		BNX2X_DEV_INFO("Disable emac Rx\n");
-		REG_WR(bp, NIG_REG_NIG_EMAC0_EN + BP_PORT(bp)*4, 0);
-
+		vals->emac_addr = NIG_REG_NIG_EMAC0_EN + BP_PORT(bp)*4;
+		vals->emac_val = REG_RD(bp, vals->emac_addr);
+		REG_WR(bp, vals->emac_addr, 0);
 		mac_stopped = true;
 	} else {
 		if (reset_reg & MISC_REGISTERS_RESET_REG_2_XMAC) {
@@ -9465,14 +9487,18 @@ static void bnx2x_prev_unload_close_mac(struct bnx2x *bp)
 			       val & ~(1 << 1));
 			REG_WR(bp, base_addr + XMAC_REG_PFC_CTRL_HI,
 			       val | (1 << 1));
-			REG_WR(bp, base_addr + XMAC_REG_CTRL, 0);
+			vals->xmac_addr = base_addr + XMAC_REG_CTRL;
+			vals->xmac_val = REG_RD(bp, vals->xmac_addr);
+			REG_WR(bp, vals->xmac_addr, 0);
 			mac_stopped = true;
 		}
 		mask = MISC_REGISTERS_RESET_REG_2_UMAC0 << port;
 		if (mask & reset_reg) {
 			BNX2X_DEV_INFO("Disable umac Rx\n");
 			base_addr = BP_PORT(bp) ? GRCBASE_UMAC1 : GRCBASE_UMAC0;
-			REG_WR(bp, base_addr + UMAC_REG_COMMAND_CONFIG, 0);
+			vals->umac_addr = base_addr + UMAC_REG_COMMAND_CONFIG;
+			vals->umac_val = REG_RD(bp, vals->umac_addr);
+			REG_WR(bp, vals->umac_addr, 0);
 			mac_stopped = true;
 		}
 	}
@@ -9664,12 +9690,16 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 {
 	u32 reset_reg, tmp_reg = 0, rc;
 	bool prev_undi = false;
+	struct bnx2x_mac_vals mac_vals;
+
 	/* It is possible a previous function received 'common' answer,
 	 * but hasn't loaded yet, therefore creating a scenario of
 	 * multiple functions receiving 'common' on the same path.
 	 */
 	BNX2X_DEV_INFO("Common unload Flow\n");
 
+	memset(&mac_vals, 0, sizeof(mac_vals));
+
 	if (bnx2x_prev_is_path_marked(bp))
 		return bnx2x_prev_mcp_done(bp);
 
@@ -9680,7 +9710,10 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 		u32 timer_count = 1000;
 
 		/* Close the MAC Rx to prevent BRB from filling up */
-		bnx2x_prev_unload_close_mac(bp);
+		bnx2x_prev_unload_close_mac(bp, &mac_vals);
+
+		/* close LLH filters towards the BRB */
+		bnx2x_set_rx_filter(&bp->link_params, 0);
 
 		/* Check if the UNDI driver was previously loaded
 		 * UNDI driver initializes CID offset for normal bell to 0x7
@@ -9727,6 +9760,17 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 	/* No packets are in the pipeline, path is ready for reset */
 	bnx2x_reset_common(bp);
 
+	if (mac_vals.xmac_addr)
+		REG_WR(bp, mac_vals.xmac_addr, mac_vals.xmac_val);
+	if (mac_vals.umac_addr)
+		REG_WR(bp, mac_vals.umac_addr, mac_vals.umac_val);
+	if (mac_vals.emac_addr)
+		REG_WR(bp, mac_vals.emac_addr, mac_vals.emac_val);
+	if (mac_vals.bmac_addr) {
+		REG_WR(bp, mac_vals.bmac_addr, mac_vals.bmac_val[0]);
+		REG_WR(bp, mac_vals.bmac_addr + 4, mac_vals.bmac_val[1]);
+	}
+
 	rc = bnx2x_prev_mark_path(bp, prev_undi);
 	if (rc) {
 		bnx2x_prev_mcp_done(bp);
-- 
1.7.1
