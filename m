From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 2/2] usb/net/r815x: fix cast to restricted __le32
Date: Fri, 12 Jul 2013 16:26:16 +0800
Message-ID: <1373617576-2272-2-git-send-email-hayeswang@realtek.com>
References: <1373617576-2272-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373617576-2272-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> drivers/net/usb/r815x.c:38:16: sparse: cast to restricted __le32
>> drivers/net/usb/r815x.c:67:15: sparse: cast to restricted __le32
>> drivers/net/usb/r815x.c:69:13: sparse: incorrect type in assignment (different base types)
   drivers/net/usb/r815x.c:69:13:    expected unsigned int [unsigned] [addressable] [assigned] [usertype] tmp
   drivers/net/usb/r815x.c:69:13:    got restricted __le32 [usertype] <noident>

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
Spotted-by: kbuild test robot <fengguang.wu@intel.com>
---
 drivers/net/usb/r815x.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/r815x.c b/drivers/net/usb/r815x.c
index 6516737..8523922 100644
--- a/drivers/net/usb/r815x.c
+++ b/drivers/net/usb/r815x.c
@@ -26,16 +26,18 @@ static int pla_read_word(struct usb_device *udev, u16 index)
 {
 	int data, ret;
 	u8 shift = index & 2;
+	__le32 ocp_data;
 
 	index &= ~3;
 
 	ret = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
 			      RTL815x_REQ_GET_REGS, RTL815x_REQT_READ,
-			      index, MCU_TYPE_PLA, &data, sizeof(data), 500);
+			      index, MCU_TYPE_PLA, &ocp_data, sizeof(ocp_data),
+			      500);
 	if (ret < 0)
 		return ret;
 
-	data = __le32_to_cpu(data);
+	data = __le32_to_cpu(ocp_data);
 	data >>= (shift * 8);
 	data &= 0xffff;
 
@@ -44,7 +46,8 @@ static int pla_read_word(struct usb_device *udev, u16 index)
 
 static int pla_write_word(struct usb_device *udev, u16 index, u32 data)
 {
-	u32 tmp, mask = 0xffff;
+	__le32 ocp_data;
+	u32 mask = 0xffff;
 	u16 byen = BYTE_EN_WORD;
 	u8 shift = index & 2;
 	int ret;
@@ -60,18 +63,18 @@ static int pla_write_word(struct usb_device *udev, u16 index, u32 data)
 
 	ret = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
 			      RTL815x_REQ_GET_REGS, RTL815x_REQT_READ,
-			      index, MCU_TYPE_PLA, &tmp, sizeof(tmp), 500);
+			      index, MCU_TYPE_PLA, &ocp_data, sizeof(ocp_data),
+			      500);
 	if (ret < 0)
 		return ret;
 
-	tmp = __le32_to_cpu(tmp) & ~mask;
-	tmp |= data;
-	tmp = __cpu_to_le32(tmp);
+	data |= __le32_to_cpu(ocp_data) & ~mask;
+	ocp_data = __cpu_to_le32(data);
 
 	ret = usb_control_msg(udev, usb_sndctrlpipe(udev, 0),
 			      RTL815x_REQ_SET_REGS, RTL815x_REQT_WRITE,
-			      index, MCU_TYPE_PLA | byen, &tmp,
-			      sizeof(tmp), 500);
+			      index, MCU_TYPE_PLA | byen, &ocp_data,
+			      sizeof(ocp_data), 500);
 
 	return ret;
 }
-- 
1.8.3.1
