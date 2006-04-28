From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/6] tg3: Add phy workaround
Date: Fri, 28 Apr 2006 16:35:19 -0700
Message-ID: <1146267319.4780.15.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:61194 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932464AbWD2BPY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 21:15:24 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add some PHY workaround code to reduce jitter on some PHYs.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a28accb..a307340 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1030,6 +1030,12 @@ out:
 		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x14e2);
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
 	}
+	else if (tp->tg3_flags2 & TG3_FLG2_PHY_JITTER_BUG) {
+		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
+		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000a);
+		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x010b);
+		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
+	}
 	/* Set Extended packet length bit (bit 14) on all chips that */
 	/* support jumbo frames */
 	if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401) {
@@ -10360,10 +10366,13 @@ static int __devinit tg3_get_invariants(
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0)
 		tp->tg3_flags2 |= TG3_FLG2_PHY_5704_A0_BUG;
 
-	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5755) &&
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787))
-		tp->tg3_flags2 |= TG3_FLG2_PHY_BER_BUG;
+	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
+			tp->tg3_flags2 |= TG3_FLG2_PHY_JITTER_BUG;
+		else
+			tp->tg3_flags2 |= TG3_FLG2_PHY_BER_BUG;
+	}
 
 	tp->coalesce_mode = 0;
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_AX &&
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 8c8b987..0e29b88 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2215,6 +2215,7 @@ struct tg3 {
 #define TG3_FLG2_HW_TSO_2		0x08000000
 #define TG3_FLG2_HW_TSO			(TG3_FLG2_HW_TSO_1 | TG3_FLG2_HW_TSO_2)
 #define TG3_FLG2_1SHOT_MSI		0x10000000
+#define TG3_FLG2_PHY_JITTER_BUG		0x20000000
 
 	u32				split_mode_max_reqs;
 #define SPLIT_MODE_5704_MAX_REQ		3


