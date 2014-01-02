From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 2/6] r8152: modify the method of accessing PHY
Date: Thu, 2 Jan 2014 11:22:40 +0800
Message-ID: <1388632963-1341-3-git-send-email-hayeswang@realtek.com>
References: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
 <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The old method to access PHY is through mdio channel. Replace it
with the OCP channel.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 52 +++++++++++++++++--------------------------------
 1 file changed, 18 insertions(+), 34 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 79bb553..b8bc3eb 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -98,6 +98,7 @@
 #define OCP_EEE_CONFIG1		0x2080
 #define OCP_EEE_CONFIG2		0x2092
 #define OCP_EEE_CONFIG3		0x2094
+#define OCP_BASE_MII		0xa400
 #define OCP_EEE_AR		0xa41a
 #define OCP_EEE_DATA		0xa41c
 
@@ -653,7 +654,7 @@ static void ocp_write_byte(struct r8152 *tp, u16 type, u16 index, u32 data)
 	generic_ocp_write(tp, index, byen, sizeof(tmp), &tmp, type);
 }
 
-static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
+static u16 ocp_reg_read(struct r8152 *tp, u16 addr)
 {
 	u16 ocp_base, ocp_index;
 
@@ -664,48 +665,31 @@ static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
 	}
 
 	ocp_index = (addr & 0x0fff) | 0xb000;
-	ocp_write_word(tp, MCU_TYPE_PLA, ocp_index, data);
+	return ocp_read_word(tp, MCU_TYPE_PLA, ocp_index);
 }
 
-static void r8152_mdio_write(struct r8152 *tp, u32 reg_addr, u32 value)
+static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
 {
-	u32	ocp_data;
-	int	i;
-
-	ocp_data = PHYAR_FLAG | ((reg_addr & 0x1f) << 16) |
-		   (value & 0xffff);
-
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_PHYAR, ocp_data);
+	u16 ocp_base, ocp_index;
 
-	for (i = 20; i > 0; i--) {
-		udelay(25);
-		ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_PHYAR);
-		if (!(ocp_data & PHYAR_FLAG))
-			break;
+	ocp_base = addr & 0xf000;
+	if (ocp_base != tp->ocp_base) {
+		ocp_write_word(tp, MCU_TYPE_PLA, PLA_OCP_GPHY_BASE, ocp_base);
+		tp->ocp_base = ocp_base;
 	}
-	udelay(20);
+
+	ocp_index = (addr & 0x0fff) | 0xb000;
+	ocp_write_word(tp, MCU_TYPE_PLA, ocp_index, data);
 }
 
-static int r8152_mdio_read(struct r8152 *tp, u32 reg_addr)
+static inline void r8152_mdio_write(struct r8152 *tp, u32 reg_addr, u32 value)
 {
-	u32	ocp_data;
-	int	i;
-
-	ocp_data = (reg_addr & 0x1f) << 16;
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_PHYAR, ocp_data);
-
-	for (i = 20; i > 0; i--) {
-		udelay(25);
-		ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_PHYAR);
-		if (ocp_data & PHYAR_FLAG)
-			break;
-	}
-	udelay(20);
-
-	if (!(ocp_data & PHYAR_FLAG))
-		return -EAGAIN;
+	ocp_reg_write(tp, OCP_BASE_MII + reg_addr * 2, value);
+}
 
-	return (u16)(ocp_data & 0xffff);
+static inline int r8152_mdio_read(struct r8152 *tp, u32 reg_addr)
+{
+	return ocp_reg_read(tp, OCP_BASE_MII + reg_addr * 2);
 }
 
 static int read_mii_word(struct net_device *netdev, int phy_id, int reg)
-- 
1.8.3.1
