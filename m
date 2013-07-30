From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v3 1/3] net/usb/r815x: replace USB buffer from stack to DMA-able
Date: Tue, 30 Jul 2013 16:28:54 +0800
Message-ID: <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allocate the transfer buffer in probe(), and use the buffer for
usb control transfer.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r815x.c | 117 +++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 90 insertions(+), 27 deletions(-)

diff --git a/drivers/net/usb/r815x.c b/drivers/net/usb/r815x.c
index 8523922..89ad63f 100644
--- a/drivers/net/usb/r815x.c
+++ b/drivers/net/usb/r815x.c
@@ -21,37 +21,52 @@
 #define R815x_PHY_ID		32
 #define REALTEK_VENDOR_ID	0x0bda
 
+struct r815x {
+	struct mutex transfer_mutex;
+	__le32 *transfer_buf;
+};
 
-static int pla_read_word(struct usb_device *udev, u16 index)
+static int pla_read_word(struct usbnet *dev, u16 index)
 {
-	int data, ret;
+	struct r815x *tp = dev->driver_priv;
+	struct usb_device *udev = dev->udev;
+	int ret;
 	u8 shift = index & 2;
-	__le32 ocp_data;
+	__le32 *tmp;
+
+	mutex_lock(&tp->transfer_mutex);
+	tmp = tp->transfer_buf;
 
 	index &= ~3;
 
 	ret = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
 			      RTL815x_REQ_GET_REGS, RTL815x_REQT_READ,
-			      index, MCU_TYPE_PLA, &ocp_data, sizeof(ocp_data),
-			      500);
+			      index, MCU_TYPE_PLA, tmp, sizeof(*tmp), 500);
 	if (ret < 0)
-		return ret;
+		goto out2;
 
-	data = __le32_to_cpu(ocp_data);
-	data >>= (shift * 8);
-	data &= 0xffff;
+	ret = __le32_to_cpu(*tmp);
+	ret >>= (shift * 8);
+	ret &= 0xffff;
 
-	return data;
+out2:
+	mutex_unlock(&tp->transfer_mutex);
+	return ret;
 }
 
-static int pla_write_word(struct usb_device *udev, u16 index, u32 data)
+static int pla_write_word(struct usbnet *dev, u16 index, u32 data)
 {
-	__le32 ocp_data;
+	struct r815x *tp = dev->driver_priv;
+	struct usb_device *udev = dev->udev;
+	__le32 *tmp;
 	u32 mask = 0xffff;
 	u16 byen = BYTE_EN_WORD;
 	u8 shift = index & 2;
 	int ret;
 
+	mutex_lock(&tp->transfer_mutex);
+	tmp = tp->transfer_buf;
+
 	data &= mask;
 
 	if (shift) {
@@ -63,19 +78,20 @@ static int pla_write_word(struct usb_device *udev, u16 index, u32 data)
 
 	ret = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
 			      RTL815x_REQ_GET_REGS, RTL815x_REQT_READ,
-			      index, MCU_TYPE_PLA, &ocp_data, sizeof(ocp_data),
-			      500);
+			      index, MCU_TYPE_PLA, tmp, sizeof(*tmp), 500);
 	if (ret < 0)
-		return ret;
+		goto out3;
 
-	data |= __le32_to_cpu(ocp_data) & ~mask;
-	ocp_data = __cpu_to_le32(data);
+	data |= __le32_to_cpu(*tmp) & ~mask;
+	*tmp = __cpu_to_le32(data);
 
 	ret = usb_control_msg(udev, usb_sndctrlpipe(udev, 0),
 			      RTL815x_REQ_SET_REGS, RTL815x_REQT_WRITE,
-			      index, MCU_TYPE_PLA | byen, &ocp_data,
-			      sizeof(ocp_data), 500);
+			      index, MCU_TYPE_PLA | byen, tmp, sizeof(*tmp),
+			      500);
 
+out3:
+	mutex_unlock(&tp->transfer_mutex);
 	return ret;
 }
 
@@ -85,12 +101,12 @@ static int ocp_reg_read(struct usbnet *dev, u16 addr)
 	int ret;
 
 	ocp_base = addr & 0xf000;
-	ret = pla_write_word(dev->udev, OCP_BASE, ocp_base);
+	ret = pla_write_word(dev, OCP_BASE, ocp_base);
 	if (ret < 0)
 		goto out;
 
 	ocp_index = (addr & 0x0fff) | 0xb000;
-	ret = pla_read_word(dev->udev, ocp_index);
+	ret = pla_read_word(dev, ocp_index);
 
 out:
 	return ret;
@@ -102,12 +118,12 @@ static int ocp_reg_write(struct usbnet *dev, u16 addr, u16 data)
 	int ret;
 
 	ocp_base = addr & 0xf000;
-	ret = pla_write_word(dev->udev, OCP_BASE, ocp_base);
+	ret = pla_write_word(dev, OCP_BASE, ocp_base);
 	if (ret < 0)
 		goto out1;
 
 	ocp_index = (addr & 0x0fff) | 0xb000;
-	ret = pla_write_word(dev->udev, ocp_index, data);
+	ret = pla_write_word(dev, ocp_index, data);
 
 out1:
 	return ret;
@@ -134,12 +150,59 @@ void r815x_mdio_write(struct net_device *netdev, int phy_id, int reg, int val)
 	ocp_reg_write(dev, BASE_MII + reg * 2, val);
 }
 
-static int r8153_bind(struct usbnet *dev, struct usb_interface *intf)
+static int r815x_bind(struct usbnet *dev, struct usb_interface *intf)
 {
+	struct r815x *tp;
 	int status;
 
+	tp = kmalloc(sizeof(*tp), GFP_KERNEL);
+	if (!tp)
+		return -ENOMEM;
+
+	memset(tp, 0, sizeof(*tp));
+
+	status = -ENOMEM;
+
+	tp->transfer_buf = kmalloc(sizeof(*tp->transfer_buf), GFP_KERNEL);
+	if (!tp->transfer_buf)
+		goto out1;
+
+	mutex_init (&tp->transfer_mutex);
+	dev->driver_priv = tp;
+
 	status = usbnet_cdc_bind(dev, intf);
 	if (status < 0)
+		goto out2;
+
+	return 0;
+
+out2:
+	kfree(tp->transfer_buf);
+out1:
+	kfree(tp);
+	return status;
+}
+
+static void r815x_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct r815x *tp = dev->driver_priv;
+
+	usbnet_cdc_unbind(dev, intf);
+
+	if (tp) {
+		if (tp->transfer_buf)
+			kfree(tp->transfer_buf);
+		kfree(tp);
+		dev->driver_priv = NULL;
+	}
+}
+
+static int r8153_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int status;
+
+	status = r815x_bind(dev, intf);
+	if (status < 0)
 		return status;
 
 	dev->mii.dev = dev->net;
@@ -157,7 +220,7 @@ static int r8152_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int status;
 
-	status = usbnet_cdc_bind(dev, intf);
+	status = r815x_bind(dev, intf);
 	if (status < 0)
 		return status;
 
@@ -176,7 +239,7 @@ static const struct driver_info r8152_info = {
 	.description =	"RTL8152 ECM Device",
 	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
 	.bind =		r8152_bind,
-	.unbind =	usbnet_cdc_unbind,
+	.unbind =	r815x_unbind,
 	.status =	usbnet_cdc_status,
 	.manage_power =	usbnet_manage_power,
 };
@@ -185,7 +248,7 @@ static const struct driver_info r8153_info = {
 	.description =	"RTL8153 ECM Device",
 	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
 	.bind =		r8153_bind,
-	.unbind =	usbnet_cdc_unbind,
+	.unbind =	r815x_unbind,
 	.status =	usbnet_cdc_status,
 	.manage_power =	usbnet_manage_power,
 };
-- 
1.8.3.1
