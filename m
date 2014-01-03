From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 3/5] tg3: Set the MAC clock to the fastest speed during boot code load
Date: Fri, 3 Jan 2014 10:09:13 -0800
Message-ID: <1388772555-916-4-git-send-email-nsujir@broadcom.com>
References: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:64862 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbaACSJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 13:09:29 -0500
In-Reply-To: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the 5717, 5718 and 5719 devices, the bootcode runs slower when any
port doesn't have a link due to clock speed slowing down as part of the
link-aware feature. This leads to the driver timing out waiting for the
bootcode signature.

This patch overrides the clock policy to the highest frequency just before
reset and restores it after the bootcode is up.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 55 ++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/broadcom/tg3.h |  3 ++
 2 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index c3b12de..7bc8449 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8941,6 +8941,49 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 	}
 }
 
+static void tg3_override_clk(struct tg3 *tp)
+{
+	u32 val;
+
+	switch (tg3_asic_rev(tp)) {
+	case ASIC_REV_5717:
+		val = tr32(TG3_CPMU_CLCK_ORIDE_ENABLE);
+		tw32(TG3_CPMU_CLCK_ORIDE_ENABLE, val |
+		     TG3_CPMU_MAC_ORIDE_ENABLE);
+		break;
+
+	case ASIC_REV_5719:
+	case ASIC_REV_5720:
+		tw32(TG3_CPMU_CLCK_ORIDE, CPMU_CLCK_ORIDE_MAC_ORIDE_EN);
+		break;
+
+	default:
+		return;
+	}
+}
+
+static void tg3_restore_clk(struct tg3 *tp)
+{
+	u32 val;
+
+	switch (tg3_asic_rev(tp)) {
+	case ASIC_REV_5717:
+		val = tr32(TG3_CPMU_CLCK_ORIDE_ENABLE);
+		tw32(TG3_CPMU_CLCK_ORIDE_ENABLE,
+		     val & ~TG3_CPMU_MAC_ORIDE_ENABLE);
+		break;
+
+	case ASIC_REV_5719:
+	case ASIC_REV_5720:
+		val = tr32(TG3_CPMU_CLCK_ORIDE);
+		tw32(TG3_CPMU_CLCK_ORIDE, val & ~CPMU_CLCK_ORIDE_MAC_ORIDE_EN);
+		break;
+
+	default:
+		return;
+	}
+}
+
 /* tp->lock is held. */
 static int tg3_chip_reset(struct tg3 *tp)
 {
@@ -9029,6 +9072,13 @@ static int tg3_chip_reset(struct tg3 *tp)
 		     tr32(GRC_VCPU_EXT_CTRL) & ~GRC_VCPU_EXT_CTRL_HALT_CPU);
 	}
 
+	/* Set the clock to the highest frequency to avoid timeouts. With link
+	 * aware mode, the clock speed could be slow and bootcode does not
+	 * complete within the expected time. Override the clock to allow the
+	 * bootcode to finish sooner and then restore it.
+	 */
+	tg3_override_clk(tp);
+
 	/* Manage gphy power for all CPMU absent PCIe devices. */
 	if (tg3_flag(tp, 5705_PLUS) && !tg3_flag(tp, CPMU_PRESENT))
 		val |= GRC_MISC_CFG_KEEP_GPHY_POWER;
@@ -9167,10 +9217,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tw32(0x7c00, val | (1 << 25));
 	}
 
-	if (tg3_asic_rev(tp) == ASIC_REV_5720) {
-		val = tr32(TG3_CPMU_CLCK_ORIDE);
-		tw32(TG3_CPMU_CLCK_ORIDE, val & ~CPMU_CLCK_ORIDE_MAC_ORIDE_EN);
-	}
+	tg3_restore_clk(tp);
 
 	/* Reprobe ASF enable state.  */
 	tg3_flag_clear(tp, ENABLE_ASF);
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index e4da9d7..9e31ecc 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -1146,6 +1146,9 @@
 #define TG3_CPMU_CLCK_ORIDE		0x00003624
 #define  CPMU_CLCK_ORIDE_MAC_ORIDE_EN	 0x80000000
 
+#define TG3_CPMU_CLCK_ORIDE_ENABLE	0x00003628
+#define  TG3_CPMU_MAC_ORIDE_ENABLE	 (1 << 13)
+
 #define TG3_CPMU_STATUS			0x0000362c
 #define  TG3_CPMU_STATUS_FMSK_5717	 0x20000000
 #define  TG3_CPMU_STATUS_FMSK_5719	 0xc0000000
-- 
1.8.1.4
