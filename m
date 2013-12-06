From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 2/5] tg3: Add flag to disable 1G Half Duplex advertisement
Date: Fri, 6 Dec 2013 09:53:17 -0800
Message-ID: <1386352400-9623-3-git-send-email-nsujir@broadcom.com>
References: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:18749 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab3LFRzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:55:46 -0500
In-Reply-To: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some link partners have issues if the non-standard 1G half duplex is
advertised. This patch adds support for an nvram setting to disable the
advertisement.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 28 +++++++++++++++++++++-------
 drivers/net/ethernet/broadcom/tg3.h |  4 ++++
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 886d50b..e8847cc 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4403,9 +4403,12 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 			if (tg3_flag(tp, WOL_SPEED_100MB))
 				adv |= ADVERTISED_100baseT_Half |
 				       ADVERTISED_100baseT_Full;
-			if (tp->phy_flags & TG3_PHYFLG_1G_ON_VAUX_OK)
-				adv |= ADVERTISED_1000baseT_Half |
-				       ADVERTISED_1000baseT_Full;
+			if (tp->phy_flags & TG3_PHYFLG_1G_ON_VAUX_OK) {
+				if (!(tp->phy_flags &
+				      TG3_PHYFLG_DISABLE_1G_HD_ADV))
+					adv |= ADVERTISED_1000baseT_Half;
+				adv |= ADVERTISED_1000baseT_Full;
+			}
 
 			fc = FLOW_CTRL_TX | FLOW_CTRL_RX;
 		} else {
@@ -14917,7 +14920,8 @@ static void tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 	tg3_read_mem(tp, NIC_SRAM_DATA_SIG, &val);
 	if (val == NIC_SRAM_DATA_SIG_MAGIC) {
 		u32 nic_cfg, led_cfg;
-		u32 nic_phy_id, ver, cfg2 = 0, cfg4 = 0, eeprom_phy_id;
+		u32 cfg2 = 0, cfg4 = 0, cfg5 = 0;
+		u32 nic_phy_id, ver, eeprom_phy_id;
 		int eeprom_phy_serdes = 0;
 
 		tg3_read_mem(tp, NIC_SRAM_DATA_CFG, &nic_cfg);
@@ -14934,6 +14938,11 @@ static void tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		if (tg3_asic_rev(tp) == ASIC_REV_5785)
 			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_4, &cfg4);
 
+		if (tg3_asic_rev(tp) == ASIC_REV_5717 ||
+		    tg3_asic_rev(tp) == ASIC_REV_5719 ||
+		    tg3_asic_rev(tp) == ASIC_REV_5720)
+			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_5, &cfg5);
+
 		if ((nic_cfg & NIC_SRAM_DATA_CFG_PHY_TYPE_MASK) ==
 		    NIC_SRAM_DATA_CFG_PHY_TYPE_FIBER)
 			eeprom_phy_serdes = 1;
@@ -15086,6 +15095,9 @@ static void tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			tg3_flag_set(tp, RGMII_EXT_IBND_RX_EN);
 		if (cfg4 & NIC_SRAM_RGMII_EXT_IBND_TX_EN)
 			tg3_flag_set(tp, RGMII_EXT_IBND_TX_EN);
+
+		if (cfg5 & NIC_SRAM_DISABLE_1G_HALF_ADV)
+			tp->phy_flags |= TG3_PHYFLG_DISABLE_1G_HD_ADV;
 	}
 done:
 	if (tg3_flag(tp, WOL_CAP))
@@ -15181,9 +15193,11 @@ static void tg3_phy_init_link_config(struct tg3 *tp)
 {
 	u32 adv = ADVERTISED_Autoneg;
 
-	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY))
-		adv |= ADVERTISED_1000baseT_Half |
-		       ADVERTISED_1000baseT_Full;
+	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
+		if (!(tp->phy_flags & TG3_PHYFLG_DISABLE_1G_HD_ADV))
+			adv |= ADVERTISED_1000baseT_Half;
+		adv |= ADVERTISED_1000baseT_Full;
+	}
 
 	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES))
 		adv |= ADVERTISED_100baseT_Half |
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 5c3835a..e128f37 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2226,6 +2226,9 @@
 #define  NIC_SRAM_CPMUSTAT_SIG		0x0000362c
 #define  NIC_SRAM_CPMUSTAT_SIG_MSK	0x0000ffff
 
+#define NIC_SRAM_DATA_CFG_5		0x00000e0c
+#define  NIC_SRAM_DISABLE_1G_HALF_ADV	0x00000002
+
 #define NIC_SRAM_RX_MINI_BUFFER_DESC	0x00001000
 
 #define NIC_SRAM_DMA_DESC_POOL_BASE	0x00002000
@@ -3325,6 +3328,7 @@ struct tg3 {
 #define TG3_PHYFLG_1G_ON_VAUX_OK	0x00080000
 #define TG3_PHYFLG_KEEP_LINK_ON_PWRDN	0x00100000
 #define TG3_PHYFLG_MDIX_STATE		0x00200000
+#define TG3_PHYFLG_DISABLE_1G_HD_ADV	0x00400000
 
 	u32				led_ctrl;
 	u32				phy_otp;
-- 
1.8.1.4
