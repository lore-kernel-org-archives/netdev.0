From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 01/11] r8152: add r8153_phy_status function
Date: Fri, 9 Jun 2017 17:11:38 +0800
Message-ID: <1394712342-15778-261-Taiwan-albertk@realtek.com>
References: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use r8153_phy_status() to check phy status of RTL8153.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 37 +++++++++++++++++++++++++------------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index fd31fab..9239dfb 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -394,6 +394,7 @@
 
 /* OCP_PHY_STATUS */
 #define PHY_STAT_MASK		0x0007
+#define PHY_STAT_EXT_INIT	2
 #define PHY_STAT_LAN_ON		3
 #define PHY_STAT_PWRDN		5
 
@@ -2452,6 +2453,28 @@ static void r8153_u2p3en(struct r8152 *tp, bool enable)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_U2P3_CTRL, ocp_data);
 }
 
+static u16 r8153_phy_status(struct r8152 *tp, u16 desired)
+{
+	u16 data;
+	int i;
+
+	for (i = 0; i < 500; i++) {
+		data = ocp_reg_read(tp, OCP_PHY_STATUS);
+		data &= PHY_STAT_MASK;
+		if (desired) {
+			if (data == desired)
+				break;
+		} else if (data == PHY_STAT_LAN_ON || data == PHY_STAT_PWRDN ||
+			   data == PHY_STAT_EXT_INIT) {
+			break;
+		}
+
+		msleep(20);
+	}
+
+	return data;
+}
+
 static void r8153_power_cut_en(struct r8152 *tp, bool enable)
 {
 	u32 ocp_data;
@@ -3420,12 +3443,7 @@ static void r8153_init(struct r8152 *tp)
 		msleep(20);
 	}
 
-	for (i = 0; i < 500; i++) {
-		ocp_data = ocp_reg_read(tp, OCP_PHY_STATUS) & PHY_STAT_MASK;
-		if (ocp_data == PHY_STAT_LAN_ON || ocp_data == PHY_STAT_PWRDN)
-			break;
-		msleep(20);
-	}
+	data = r8153_phy_status(tp, 0);
 
 	if (tp->version == RTL_VER_03 || tp->version == RTL_VER_04 ||
 	    tp->version == RTL_VER_05)
@@ -3437,12 +3455,7 @@ static void r8153_init(struct r8152 *tp)
 		r8152_mdio_write(tp, MII_BMCR, data);
 	}
 
-	for (i = 0; i < 500; i++) {
-		ocp_data = ocp_reg_read(tp, OCP_PHY_STATUS) & PHY_STAT_MASK;
-		if (ocp_data == PHY_STAT_LAN_ON)
-			break;
-		msleep(20);
-	}
+	data = r8153_phy_status(tp, PHY_STAT_LAN_ON);
 
 	usb_disable_lpm(tp->udev);
 	r8153_u2p3en(tp, false);
-- 
2.7.4
