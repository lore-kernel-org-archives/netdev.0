From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH RFC net-next] bnx2x: avoid printing unnecessary messages during register dump
Date: Tue, 27 Sep 2016 15:33:54 -0300
Message-ID: <1475001234-25933-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, gpiccoli@linux.vnet.ibm.com
To: ariel.elior@qlogic.com, Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56549 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750762AbcI0SeU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 14:34:20 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8RIX2WB074987
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 14:34:19 -0400
Received: from e24smtp05.br.ibm.com (e24smtp05.br.ibm.com [32.104.18.26])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25qt1rcunr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 14:34:19 -0400
Received: from localhost
        by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Tue, 27 Sep 2016 15:34:17 -0300
Received: from d24relay04.br.ibm.com (d24relay04.br.ibm.com [9.18.232.146])
        by d24dlp02.br.ibm.com (Postfix) with ESMTP id CA9941DC006E
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 14:34:13 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
        by d24relay04.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8RIYDHX29491310
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 15:34:13 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
        by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8RIYDV0003592
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 15:34:13 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2x driver prints multiple error messages during register dump,
with "ethtool -d" for example. The driver even warn that many messages
might be seen during the register dump, but they are harmless. A typical
kernel log after register dump looks like this:

  [9.375] bnx2x: [bnx2x_get_regs:987(net0)]Generating register dump. Might trigger harmless GRC timeouts
  [9.439] bnx2x: [bnx2x_attn_int_deasserted3:4342(net0)]LATCHED attention 0x04000000 (masked)
  [9.439] bnx2x: [bnx2x_attn_int_deasserted3:4346(net0)]GRC time-out 0x010580cd
  [...]

The notation [...] means that some messages were supressed - in our
tests we saw 78 more "LATCHED attention" and "GRC time-out" messages,
supressed here.

This patch avoid these messages to be printed on register dump instead
of just warn they are harmless.

Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---

  * This was sent as RFC for two main reasons: firstly, I might be ignoring
    some importance in showing these error messages during register dump.
    Also, there are multiple ways to implement this idea - I just did the
    first one that came to my head. We might also add a new flag on struct
    bnx2x or even a new field. Any suggestions regarding the best
    implementation are welcome.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  1 +
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 17 ++++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 22 ++++++++++++----------
 3 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 7dd7490..73f2713 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2053,6 +2053,7 @@ void bnx2x_update_coalesce(struct bnx2x *bp);
 int bnx2x_get_cur_phy_idx(struct bnx2x *bp);
 
 bool bnx2x_port_after_undi(struct bnx2x *bp);
+bool bnx2x_is_reading_regs(void);
 
 static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 			   int wait)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 85a7800..d7dc867 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -29,6 +29,8 @@
 #include "bnx2x_dump.h"
 #include "bnx2x_init.h"
 
+static int bnx2x_reading_regs;
+
 /* Note: in the format strings below %s is replaced by the queue-name which is
  * either its index or 'fcoe' for the fcoe queue. Make sure the format string
  * length does not exceed ETH_GSTRING_LEN - MAX_QUEUE_NAME_LEN + 2
@@ -981,19 +983,24 @@ static void bnx2x_get_regs(struct net_device *dev,
 	memcpy(p, &dump_hdr, sizeof(struct dump_header));
 	p += dump_hdr.header_size + 1;
 
-	/* This isn't really an error, but since attention handling is going
-	 * to print the GRC timeouts using this macro, we use the same.
+	/* Actually read the registers - we use bnx2x_reading_regs to
+	 * avoid multiple unnecessary error messages to be printed on
+	 * kernel log when reading registers, like GRC timeouts.
 	 */
-	BNX2X_ERR("Generating register dump. Might trigger harmless GRC timeouts\n");
-
-	/* Actually read the registers */
+	bnx2x_reading_regs = 1;
 	__bnx2x_get_regs(bp, p);
+	bnx2x_reading_regs = 0;
 
 	/* Re-enable parity attentions */
 	bnx2x_clear_blocks_parity(bp);
 	bnx2x_enable_blocks_parity(bp);
 }
 
+inline bool bnx2x_is_reading_regs(void)
+{
+	return !!bnx2x_reading_regs;
+}
+
 static int bnx2x_get_preset_regs_len(struct net_device *dev, u32 preset)
 {
 	struct bnx2x *bp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fa3386b..392d14c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -4339,16 +4339,18 @@ static void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 	}
 
 	if (attn & EVEREST_LATCHED_ATTN_IN_USE_MASK) {
-		BNX2X_ERR("LATCHED attention 0x%08x (masked)\n", attn);
-		if (attn & BNX2X_GRC_TIMEOUT) {
-			val = CHIP_IS_E1(bp) ? 0 :
-					REG_RD(bp, MISC_REG_GRC_TIMEOUT_ATTN);
-			BNX2X_ERR("GRC time-out 0x%08x\n", val);
-		}
-		if (attn & BNX2X_GRC_RSV) {
-			val = CHIP_IS_E1(bp) ? 0 :
-					REG_RD(bp, MISC_REG_GRC_RSV_ATTN);
-			BNX2X_ERR("GRC reserved 0x%08x\n", val);
+		if (!bnx2x_is_reading_regs()) {
+			BNX2X_ERR("LATCHED attention 0x%08x (masked)\n", attn);
+			if (attn & BNX2X_GRC_TIMEOUT) {
+				val = CHIP_IS_E1(bp) ? 0 :
+				      REG_RD(bp, MISC_REG_GRC_TIMEOUT_ATTN);
+				BNX2X_ERR("GRC time-out 0x%08x\n", val);
+			}
+			if (attn & BNX2X_GRC_RSV) {
+				val = CHIP_IS_E1(bp) ? 0 :
+				      REG_RD(bp, MISC_REG_GRC_RSV_ATTN);
+				BNX2X_ERR("GRC reserved 0x%08x\n", val);
+			}
 		}
 		REG_WR(bp, MISC_REG_AEU_CLR_LATCH_SIGNAL, 0x7ff);
 	}
-- 
2.1.0
