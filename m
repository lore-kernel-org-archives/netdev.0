From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 1/2] bnx2x: Fix kdump on 4-port device
Date: Wed, 1 Apr 2015 10:02:19 +0300
Message-ID: <1427871740-26271-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1427871740-26271-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43965 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751138AbbDAHCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 03:02:54 -0400
In-Reply-To: <1427871740-26271-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in a kdump kernel, it's very likely that due to sync. loss with
management firmware the first PCI function to probe and reach the previous
unload flow would decide it can reset the chip and continue onward. While doing
so, it will only close its own Rx port.

On a 4-port device where 2nd port on engine is a 1g-port, the 2nd port would
allow ingress traffic after the chip is reset [assuming it was active on the
first kernel]. This would later cause a HW attention.

This changes driver flow to close both ports' 1g capabilities during the
previous driver unload flow prior to the chip reset.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 53 ++++++++++++++++--------
 1 file changed, 35 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ae571a1..f391edb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -129,8 +129,8 @@ struct bnx2x_mac_vals {
 	u32 xmac_val;
 	u32 emac_addr;
 	u32 emac_val;
-	u32 umac_addr;
-	u32 umac_val;
+	u32 umac_addr[2];
+	u32 umac_val[2];
 	u32 bmac_addr;
 	u32 bmac_val[2];
 };
@@ -10141,6 +10141,25 @@ static u32 bnx2x_get_pretend_reg(struct bnx2x *bp)
 	return base + (BP_ABS_FUNC(bp)) * stride;
 }
 
+static bool bnx2x_prev_unload_close_umac(struct bnx2x *bp,
+					 u8 port, u32 reset_reg,
+					 struct bnx2x_mac_vals *vals)
+{
+	u32 mask = MISC_REGISTERS_RESET_REG_2_UMAC0 << port;
+	u32 base_addr;
+
+	if (!(mask & reset_reg))
+		return false;
+
+	BNX2X_DEV_INFO("Disable umac Rx %02x\n", port);
+	base_addr = port ? GRCBASE_UMAC1 : GRCBASE_UMAC0;
+	vals->umac_addr[port] = base_addr + UMAC_REG_COMMAND_CONFIG;
+	vals->umac_val[port] = REG_RD(bp, vals->umac_addr[port]);
+	REG_WR(bp, vals->umac_addr[port], 0);
+
+	return true;
+}
+
 static void bnx2x_prev_unload_close_mac(struct bnx2x *bp,
 					struct bnx2x_mac_vals *vals)
 {
@@ -10149,10 +10168,7 @@ static void bnx2x_prev_unload_close_mac(struct bnx2x *bp,
 	u8 port = BP_PORT(bp);
 
 	/* reset addresses as they also mark which values were changed */
-	vals->bmac_addr = 0;
-	vals->umac_addr = 0;
-	vals->xmac_addr = 0;
-	vals->emac_addr = 0;
+	memset(vals, 0, sizeof(*vals));
 
 	reset_reg = REG_RD(bp, MISC_REG_RESET_REG_2);
 
@@ -10201,15 +10217,11 @@ static void bnx2x_prev_unload_close_mac(struct bnx2x *bp,
 			REG_WR(bp, vals->xmac_addr, 0);
 			mac_stopped = true;
 		}
-		mask = MISC_REGISTERS_RESET_REG_2_UMAC0 << port;
-		if (mask & reset_reg) {
-			BNX2X_DEV_INFO("Disable umac Rx\n");
-			base_addr = BP_PORT(bp) ? GRCBASE_UMAC1 : GRCBASE_UMAC0;
-			vals->umac_addr = base_addr + UMAC_REG_COMMAND_CONFIG;
-			vals->umac_val = REG_RD(bp, vals->umac_addr);
-			REG_WR(bp, vals->umac_addr, 0);
-			mac_stopped = true;
-		}
+
+		mac_stopped |= bnx2x_prev_unload_close_umac(bp, 0,
+							    reset_reg, vals);
+		mac_stopped |= bnx2x_prev_unload_close_umac(bp, 1,
+							    reset_reg, vals);
 	}
 
 	if (mac_stopped)
@@ -10505,8 +10517,11 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 		/* Close the MAC Rx to prevent BRB from filling up */
 		bnx2x_prev_unload_close_mac(bp, &mac_vals);
 
-		/* close LLH filters towards the BRB */
+		/* close LLH filters for both ports towards the BRB */
+		bnx2x_set_rx_filter(&bp->link_params, 0);
+		bp->link_params.port ^= 1;
 		bnx2x_set_rx_filter(&bp->link_params, 0);
+		bp->link_params.port ^= 1;
 
 		/* Check if the UNDI driver was previously loaded */
 		if (bnx2x_prev_is_after_undi(bp)) {
@@ -10553,8 +10568,10 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 
 	if (mac_vals.xmac_addr)
 		REG_WR(bp, mac_vals.xmac_addr, mac_vals.xmac_val);
-	if (mac_vals.umac_addr)
-		REG_WR(bp, mac_vals.umac_addr, mac_vals.umac_val);
+	if (mac_vals.umac_addr[0])
+		REG_WR(bp, mac_vals.umac_addr[0], mac_vals.umac_val[0]);
+	if (mac_vals.umac_addr[1])
+		REG_WR(bp, mac_vals.umac_addr[1], mac_vals.umac_val[1]);
 	if (mac_vals.emac_addr)
 		REG_WR(bp, mac_vals.emac_addr, mac_vals.emac_val);
 	if (mac_vals.bmac_addr) {
-- 
1.9.3
