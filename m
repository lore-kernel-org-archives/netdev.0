From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/3] r8152: change the EEE definition
Date: Thu, 25 Sep 2014 20:54:00 +0800
Message-ID: <1394712342-15778-47-Taiwan-albertk@realtek.com>
References: <1394712342-15778-46-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-46-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the EEE definitions with the ones which is declared
in "mdio.h".

Chage some definitions to make them readable.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 35 ++++++++++++++---------------------
 1 file changed, 14 insertions(+), 21 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3d5c39a..d225aa1 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -22,6 +22,8 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <net/ip6_checksum.h>
+#include <uapi/linux/mdio.h>
+#include <linux/mdio.h>
 
 /* Version Information */
 #define DRIVER_VERSION "v1.06.0 (2014/03/03)"
@@ -129,7 +131,7 @@
 #define OCP_SRAM_ADDR		0xa436
 #define OCP_SRAM_DATA		0xa438
 #define OCP_DOWN_SPEED		0xa442
-#define OCP_EEE_CFG2		0xa5d0
+#define OCP_EEE_ADV		0xa5d0
 #define OCP_ADC_CFG		0xbc06
 
 /* SRAM Register */
@@ -361,7 +363,7 @@
 #define EEE_NWAY_EN		0x1000
 #define TX_QUIET_EN		0x0200
 #define RX_QUIET_EN		0x0100
-#define SDRISETIME		0x0010	/* bit 4 ~ 6 */
+#define sd_rise_time(x)		(min(x, 7) << 4)	/* bit 4 ~ 6 */
 #define RG_RXLPI_MSK_HFDUP	0x0008
 #define SDFALLTIME		0x0007	/* bit 0 ~ 2 */
 
@@ -373,7 +375,7 @@
 #define RG_EEEPRG_EN		0x0010
 
 /* OCP_EEE_CONFIG3 */
-#define FST_SNR_EYE_R		0x1500	/* bit 7 ~ 15 */
+#define fast_snr(x)		(min(x, 0x1ff) << 7)	/* bit 7 ~ 15 */
 #define RG_LFS_SEL		0x0060	/* bit 6 ~ 5 */
 #define MSK_PH			0x0006	/* bit 0 ~ 3 */
 
@@ -382,11 +384,6 @@
 #define FUN_ADDR		0x0000
 #define FUN_DATA		0x4000
 /* bit[4:0] device addr */
-#define DEVICE_ADDR		0x0007
-
-/* OCP_EEE_DATA */
-#define EEE_ADDR		0x003C
-#define EEE_DATA		0x0002
 
 /* OCP_EEE_CFG */
 #define CTAP_SHORT_EN		0x0040
@@ -395,10 +392,6 @@
 /* OCP_DOWN_SPEED */
 #define EN_10M_BGOFF		0x0080
 
-/* OCP_EEE_CFG2 */
-#define MY1000_EEE		0x0004
-#define MY100_EEE		0x0002
-
 /* OCP_ADC_CFG */
 #define CKADSEL_L		0x0100
 #define ADC_EN			0x0080
@@ -2967,16 +2960,16 @@ static void r8152b_enable_eee(struct r8152 *tp)
 	ocp_reg_write(tp, OCP_EEE_CONFIG1, RG_TXLPI_MSK_HFDUP | RG_MATCLR_EN |
 					   EEE_10_CAP | EEE_NWAY_EN |
 					   TX_QUIET_EN | RX_QUIET_EN |
-					   SDRISETIME | RG_RXLPI_MSK_HFDUP |
+					   sd_rise_time(1) | RG_RXLPI_MSK_HFDUP |
 					   SDFALLTIME);
 	ocp_reg_write(tp, OCP_EEE_CONFIG2, RG_LPIHYS_NUM | RG_DACQUIET_EN |
 					   RG_LDVQUIET_EN | RG_CKRSEL |
 					   RG_EEEPRG_EN);
-	ocp_reg_write(tp, OCP_EEE_CONFIG3, FST_SNR_EYE_R | RG_LFS_SEL | MSK_PH);
-	ocp_reg_write(tp, OCP_EEE_AR, FUN_ADDR | DEVICE_ADDR);
-	ocp_reg_write(tp, OCP_EEE_DATA, EEE_ADDR);
-	ocp_reg_write(tp, OCP_EEE_AR, FUN_DATA | DEVICE_ADDR);
-	ocp_reg_write(tp, OCP_EEE_DATA, EEE_DATA);
+	ocp_reg_write(tp, OCP_EEE_CONFIG3, fast_snr(42) | RG_LFS_SEL | MSK_PH);
+	ocp_reg_write(tp, OCP_EEE_AR, FUN_ADDR | MDIO_MMD_AN);
+	ocp_reg_write(tp, OCP_EEE_DATA, MDIO_AN_EEE_ADV);
+	ocp_reg_write(tp, OCP_EEE_AR, FUN_DATA | MDIO_MMD_AN);
+	ocp_reg_write(tp, OCP_EEE_DATA, MDIO_EEE_100TX);
 	ocp_reg_write(tp, OCP_EEE_AR, 0x0000);
 }
 
@@ -2991,9 +2984,9 @@ static void r8153_enable_eee(struct r8152 *tp)
 	data = ocp_reg_read(tp, OCP_EEE_CFG);
 	data |= EEE10_EN;
 	ocp_reg_write(tp, OCP_EEE_CFG, data);
-	data = ocp_reg_read(tp, OCP_EEE_CFG2);
-	data |= MY1000_EEE | MY100_EEE;
-	ocp_reg_write(tp, OCP_EEE_CFG2, data);
+	data = ocp_reg_read(tp, OCP_EEE_ADV);
+	data |= MDIO_EEE_1000T | MDIO_EEE_100TX;
+	ocp_reg_write(tp, OCP_EEE_ADV, data);
 }
 
 static void r8152b_enable_fc(struct r8152 *tp)
-- 
1.9.3
