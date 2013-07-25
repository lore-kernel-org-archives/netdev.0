From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v2 3/3] net/usb/r8152: adjust relative ocp function
Date: Thu, 25 Jul 2013 15:59:04 +0800
Message-ID: <1374739144-732-3-git-send-email-hayeswang@realtek.com>
References: <20130724.174947.452272360732442554.davem@davemloft.net>
 <1374739144-732-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:42024 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755160Ab3GYH7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 03:59:48 -0400
In-Reply-To: <1374739144-732-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 - fix the conversion between cpu and __le32
 - replace some pla_ocp and usb_ocp functions with generic_ocp function

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 66 +++++++++++++++++--------------------------------
 1 file changed, 23 insertions(+), 43 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ef033ab..11c51f2 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -514,37 +514,31 @@ int usb_ocp_write(struct r8152 *tp, u16 index, u16 byteen, u16 size, void *data)
 
 static u32 ocp_read_dword(struct r8152 *tp, u16 type, u16 index)
 {
-	u32 data;
+	__le32 data;
 
-	if (type == MCU_TYPE_PLA)
-		pla_ocp_read(tp, index, sizeof(data), &data);
-	else
-		usb_ocp_read(tp, index, sizeof(data), &data);
+	generic_ocp_read(tp, index, sizeof(data), &data, type);
 
 	return __le32_to_cpu(data);
 }
 
 static void ocp_write_dword(struct r8152 *tp, u16 type, u16 index, u32 data)
 {
-	if (type == MCU_TYPE_PLA)
-		pla_ocp_write(tp, index, BYTE_EN_DWORD, sizeof(data), &data);
-	else
-		usb_ocp_write(tp, index, BYTE_EN_DWORD, sizeof(data), &data);
+	__le32 tmp = __cpu_to_le32(data);
+
+	generic_ocp_write(tp, index, BYTE_EN_DWORD, sizeof(tmp), &tmp, type);
 }
 
 static u16 ocp_read_word(struct r8152 *tp, u16 type, u16 index)
 {
 	u32 data;
+	__le32 tmp;
 	u8 shift = index & 2;
 
 	index &= ~3;
 
-	if (type == MCU_TYPE_PLA)
-		pla_ocp_read(tp, index, sizeof(data), &data);
-	else
-		usb_ocp_read(tp, index, sizeof(data), &data);
+	generic_ocp_read(tp, index, sizeof(tmp), &tmp, type);
 
-	data = __le32_to_cpu(data);
+	data = __le32_to_cpu(tmp);
 	data >>= (shift * 8);
 	data &= 0xffff;
 
@@ -553,7 +547,8 @@ static u16 ocp_read_word(struct r8152 *tp, u16 type, u16 index)
 
 static void ocp_write_word(struct r8152 *tp, u16 type, u16 index, u32 data)
 {
-	u32 tmp, mask = 0xffff;
+	u32 mask = 0xffff;
+	__le32 tmp;
 	u16 byen = BYTE_EN_WORD;
 	u8 shift = index & 2;
 
@@ -566,34 +561,25 @@ static void ocp_write_word(struct r8152 *tp, u16 type, u16 index, u32 data)
 		index &= ~3;
 	}
 
-	if (type == MCU_TYPE_PLA)
-		pla_ocp_read(tp, index, sizeof(tmp), &tmp);
-	else
-		usb_ocp_read(tp, index, sizeof(tmp), &tmp);
+	generic_ocp_read(tp, index, sizeof(tmp), &tmp, type);
 
-	tmp = __le32_to_cpu(tmp) & ~mask;
-	tmp |= data;
-	tmp = __cpu_to_le32(tmp);
+	data |= __le32_to_cpu(tmp) & ~mask;
+	tmp = __cpu_to_le32(data);
 
-	if (type == MCU_TYPE_PLA)
-		pla_ocp_write(tp, index, byen, sizeof(tmp), &tmp);
-	else
-		usb_ocp_write(tp, index, byen, sizeof(tmp), &tmp);
+	generic_ocp_write(tp, index, byen, sizeof(tmp), &tmp, type);
 }
 
 static u8 ocp_read_byte(struct r8152 *tp, u16 type, u16 index)
 {
 	u32 data;
+	__le32 tmp;
 	u8 shift = index & 3;
 
 	index &= ~3;
 
-	if (type == MCU_TYPE_PLA)
-		pla_ocp_read(tp, index, sizeof(data), &data);
-	else
-		usb_ocp_read(tp, index, sizeof(data), &data);
+	generic_ocp_read(tp, index, sizeof(tmp), &tmp, type);
 
-	data = __le32_to_cpu(data);
+	data = __le32_to_cpu(tmp);
 	data >>= (shift * 8);
 	data &= 0xff;
 
@@ -602,7 +588,8 @@ static u8 ocp_read_byte(struct r8152 *tp, u16 type, u16 index)
 
 static void ocp_write_byte(struct r8152 *tp, u16 type, u16 index, u32 data)
 {
-	u32 tmp, mask = 0xff;
+	u32 mask = 0xff;
+	__le32 tmp;
 	u16 byen = BYTE_EN_BYTE;
 	u8 shift = index & 3;
 
@@ -615,19 +602,12 @@ static void ocp_write_byte(struct r8152 *tp, u16 type, u16 index, u32 data)
 		index &= ~3;
 	}
 
-	if (type == MCU_TYPE_PLA)
-		pla_ocp_read(tp, index, sizeof(tmp), &tmp);
-	else
-		usb_ocp_read(tp, index, sizeof(tmp), &tmp);
+	generic_ocp_read(tp, index, sizeof(tmp), &tmp, type);
 
-	tmp = __le32_to_cpu(tmp) & ~mask;
-	tmp |= data;
-	tmp = __cpu_to_le32(tmp);
+	data |= __le32_to_cpu(tmp) & ~mask;
+	tmp = __cpu_to_le32(data);
 
-	if (type == MCU_TYPE_PLA)
-		pla_ocp_write(tp, index, byen, sizeof(tmp), &tmp);
-	else
-		usb_ocp_write(tp, index, byen, sizeof(tmp), &tmp);
+	generic_ocp_write(tp, index, byen, sizeof(tmp), &tmp, type);
 }
 
 static void r8152_mdio_write(struct r8152 *tp, u32 reg_addr, u32 value)
-- 
1.8.3.1
