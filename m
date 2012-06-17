From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH 1/2] bnx2x: fix I2C non-respondent issue
Date: Sun, 17 Jun 2012 09:27:14 +0300
Message-ID: <1339914435-12912-2-git-send-email-yuvalmin@broadcom.com>
References: <1339914435-12912-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, yaniv.rosner@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4778 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411Ab2FQG30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jun 2012 02:29:26 -0400
In-Reply-To: <1339914435-12912-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I2C is not responding it's usually due to a previous
unexpected reset during I2C operation. We release it by
powering down and up the SFP+ module.


Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   52 ++++++++++++----------
 1 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index a3fb721..65f673f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -40,6 +40,7 @@
 #define I2C_BSC0			0
 #define I2C_BSC1			1
 #define I2C_WA_RETRY_CNT		3
+#define I2C_WA_PWR_ITER			(I2C_WA_RETRY_CNT - 1)
 #define MCPR_IMC_COMMAND_READ_OP	1
 #define MCPR_IMC_COMMAND_WRITE_OP	2
 
@@ -7659,6 +7660,28 @@ static int bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	return -EINVAL;
 }
 
+static void bnx2x_warpcore_power_module(struct link_params *params,
+					struct bnx2x_phy *phy,
+					u8 power)
+{
+	u32 pin_cfg;
+	struct bnx2x *bp = params->bp;
+
+	pin_cfg = (REG_RD(bp, params->shmem_base +
+			  offsetof(struct shmem_region,
+			dev_info.port_hw_config[params->port].e3_sfp_ctrl)) &
+			PORT_HW_CFG_E3_PWR_DIS_MASK) >>
+			PORT_HW_CFG_E3_PWR_DIS_SHIFT;
+
+	if (pin_cfg == PIN_CFG_NA)
+		return;
+	DP(NETIF_MSG_LINK, "Setting SFP+ module power to %d using pin cfg %d\n",
+		       power, pin_cfg);
+	/* Low ==> corresponding SFP+ module is powered
+	 * high ==> the SFP+ module is powered down
+	 */
+	bnx2x_set_cfg_pin(bp, pin_cfg, power ^ 1);
+}
 static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 						 struct link_params *params,
 						 u16 addr, u8 byte_cnt,
@@ -7678,6 +7701,12 @@ static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	/* 4 byte aligned address */
 	addr32 = addr & (~0x3);
 	do {
+		if (cnt == I2C_WA_PWR_ITER) {
+			bnx2x_warpcore_power_module(params, phy, 0);
+			/* Note that 100us are not enough here */
+			usleep_range(1000,1000);
+			bnx2x_warpcore_power_module(params, phy, 1);
+		}
 		rc = bnx2x_bsc_read(params, phy, 0xa0, addr32, 0, byte_cnt,
 				    data_array);
 	} while ((rc != 0) && (++cnt < I2C_WA_RETRY_CNT));
@@ -8200,29 +8229,6 @@ static void bnx2x_set_sfp_module_fault_led(struct link_params *params,
 		bnx2x_set_e1e2_module_fault_led(params, gpio_mode);
 }
 
-static void bnx2x_warpcore_power_module(struct link_params *params,
-					struct bnx2x_phy *phy,
-					u8 power)
-{
-	u32 pin_cfg;
-	struct bnx2x *bp = params->bp;
-
-	pin_cfg = (REG_RD(bp, params->shmem_base +
-			  offsetof(struct shmem_region,
-			dev_info.port_hw_config[params->port].e3_sfp_ctrl)) &
-			PORT_HW_CFG_E3_PWR_DIS_MASK) >>
-			PORT_HW_CFG_E3_PWR_DIS_SHIFT;
-
-	if (pin_cfg == PIN_CFG_NA)
-		return;
-	DP(NETIF_MSG_LINK, "Setting SFP+ module power to %d using pin cfg %d\n",
-		       power, pin_cfg);
-	/* Low ==> corresponding SFP+ module is powered
-	 * high ==> the SFP+ module is powered down
-	 */
-	bnx2x_set_cfg_pin(bp, pin_cfg, power ^ 1);
-}
-
 static void bnx2x_warpcore_hw_reset(struct bnx2x_phy *phy,
 				    struct link_params *params)
 {
-- 
1.7.9.rc2
