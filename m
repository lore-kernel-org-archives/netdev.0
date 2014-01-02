From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 1/6] r8152: move rtl8152_unload and ocp_reg_write
Date: Thu, 2 Jan 2014 11:22:39 +0800
Message-ID: <1388632963-1341-2-git-send-email-hayeswang@realtek.com>
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

Change the locations of rtl8152_unload() and ocp_reg_write().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 58 ++++++++++++++++++++++++-------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5107372..79bb553 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -653,6 +653,20 @@ static void ocp_write_byte(struct r8152 *tp, u16 type, u16 index, u32 data)
 	generic_ocp_write(tp, index, byen, sizeof(tmp), &tmp, type);
 }
 
+static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
+{
+	u16 ocp_base, ocp_index;
+
+	ocp_base = addr & 0xf000;
+	if (ocp_base != tp->ocp_base) {
+		ocp_write_word(tp, MCU_TYPE_PLA, PLA_OCP_GPHY_BASE, ocp_base);
+		tp->ocp_base = ocp_base;
+	}
+
+	ocp_index = (addr & 0x0fff) | 0xb000;
+	ocp_write_word(tp, MCU_TYPE_PLA, ocp_index, data);
+}
+
 static void r8152_mdio_write(struct r8152 *tp, u32 reg_addr, u32 value)
 {
 	u32	ocp_data;
@@ -715,20 +729,6 @@ void write_mii_word(struct net_device *netdev, int phy_id, int reg, int val)
 	r8152_mdio_write(tp, reg, val);
 }
 
-static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
-{
-	u16 ocp_base, ocp_index;
-
-	ocp_base = addr & 0xf000;
-	if (ocp_base != tp->ocp_base) {
-		ocp_write_word(tp, MCU_TYPE_PLA, PLA_OCP_GPHY_BASE, ocp_base);
-		tp->ocp_base = ocp_base;
-	}
-
-	ocp_index = (addr & 0x0fff) | 0xb000;
-	ocp_write_word(tp, MCU_TYPE_PLA, ocp_index, data);
-}
-
 static
 int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags);
 
@@ -2079,6 +2079,21 @@ static void r8152b_get_version(struct r8152 *tp)
 	}
 }
 
+static void rtl8152_unload(struct r8152 *tp)
+{
+	u32	ocp_data;
+
+	if (tp->version != RTL_VER_01) {
+		ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_UPS_CTRL);
+		ocp_data |= POWER_CUT;
+		ocp_write_word(tp, MCU_TYPE_USB, USB_UPS_CTRL, ocp_data);
+	}
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
+	ocp_data &= ~RWSUME_INDICATE;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
+}
+
 static int rtl8152_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
@@ -2150,21 +2165,6 @@ out:
 	return ret;
 }
 
-static void rtl8152_unload(struct r8152 *tp)
-{
-	u32	ocp_data;
-
-	if (tp->version != RTL_VER_01) {
-		ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_UPS_CTRL);
-		ocp_data |= POWER_CUT;
-		ocp_write_word(tp, MCU_TYPE_USB, USB_UPS_CTRL, ocp_data);
-	}
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
-	ocp_data &= ~RWSUME_INDICATE;
-	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
-}
-
 static void rtl8152_disconnect(struct usb_interface *intf)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
-- 
1.8.3.1
