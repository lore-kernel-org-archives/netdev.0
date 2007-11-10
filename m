From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 9/13] tg3: Prescaler fix
Date: Fri, 09 Nov 2007 16:38:59 -0800
Message-ID: <1194655139.5745.271.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1628 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753623AbXKJAjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Internal hardware timers become inaccurate after link events.  Clock
frequency switches performed by the CPMU fail to adjust timer
prescalers.  The fix is to detect core clock frequency changes during
link events and adjust the timer prescalers accordingly.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bb3b734..ecd64a2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3154,6 +3154,22 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 		err = tg3_setup_copper_phy(tp, force_reset);
 	}
 
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0) {
+		u32 val, scale;
+
+		val = tr32(TG3_CPMU_CLCK_STAT) & CPMU_CLCK_STAT_MAC_CLCK_MASK;
+		if (val == CPMU_CLCK_STAT_MAC_CLCK_62_5)
+			scale = 65;
+		else if (val == CPMU_CLCK_STAT_MAC_CLCK_6_25)
+			scale = 6;
+		else
+			scale = 12;
+
+		val = tr32(GRC_MISC_CFG) & ~GRC_MISC_CFG_PRESCALAR_MASK;
+		val |= (scale << GRC_MISC_CFG_PRESCALAR_SHIFT);
+		tw32(GRC_MISC_CFG, val);
+	}
+
 	if (tp->link_config.active_speed == SPEED_1000 &&
 	    tp->link_config.active_duplex == DUPLEX_HALF)
 		tw32(MAC_TX_LENGTHS,
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5b799ff..d325ab5 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -874,7 +874,14 @@
 #define TG3_CPMU_HST_ACC		0x0000361c
 #define  CPMU_HST_ACC_MACCLK_MASK	 0x001f0000
 #define  CPMU_HST_ACC_MACCLK_6_25	 0x00130000
-/* 0x3620 --> 0x365c unused */
+/* 0x3620 --> 0x3630 unused */
+
+#define TG3_CPMU_CLCK_STAT		0x00003630
+#define  CPMU_CLCK_STAT_MAC_CLCK_MASK	 0x001f0000
+#define  CPMU_CLCK_STAT_MAC_CLCK_62_5	 0x00000000
+#define  CPMU_CLCK_STAT_MAC_CLCK_12_5	 0x00110000
+#define  CPMU_CLCK_STAT_MAC_CLCK_6_25	 0x00130000
+/* 0x3634 --> 0x365c unused */
 
 #define TG3_CPMU_MUTEX_REQ		0x0000365c
 #define  CPMU_MUTEX_REQ_DRIVER		 0x00001000




