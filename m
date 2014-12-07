From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/3] can: peak_usb: fix multi-byte values endianess
Date: Sun,  7 Dec 2014 23:06:06 +0100
Message-ID: <1417989966-31309-4-git-send-email-mkl@pengutronix.de>
References: <1417989966-31309-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1417989966-31309-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephane Grosjean <s.grosjean@peak-system.com>

This patch fixes the endianess definition as well as the usage of the
multi-byte fields in the data structures exchanged with the PEAK-System USB
adapters.

By fixing the endianess, this patch also fixes the wrong usage of a 32-bits
local variable for handling the error status 16-bits field, in function
pcan_usb_pro_handle_error().

Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb.c      | 14 ++++----
 drivers/net/can/usb/peak_usb/pcan_usb_core.c |  3 +-
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c  | 20 ++++++------
 drivers/net/can/usb/peak_usb/pcan_usb_pro.h  | 48 ++++++++++++++--------------
 4 files changed, 43 insertions(+), 42 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb.c b/drivers/net/can/usb/peak_usb/pcan_usb.c
index 925ab8ec9329..4e1659d07979 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb.c
@@ -316,7 +316,7 @@ static int pcan_usb_get_serial(struct peak_usb_device *dev, u32 *serial_number)
 	if (err) {
 		netdev_err(dev->netdev, "getting serial failure: %d\n", err);
 	} else if (serial_number) {
-		u32 tmp32;
+		__le32 tmp32;
 
 		memcpy(&tmp32, args, 4);
 		*serial_number = le32_to_cpu(tmp32);
@@ -347,7 +347,7 @@ static int pcan_usb_get_device_id(struct peak_usb_device *dev, u32 *device_id)
  */
 static int pcan_usb_update_ts(struct pcan_usb_msg_context *mc)
 {
-	u16 tmp16;
+	__le16 tmp16;
 
 	if ((mc->ptr+2) > mc->end)
 		return -EINVAL;
@@ -371,7 +371,7 @@ static int pcan_usb_decode_ts(struct pcan_usb_msg_context *mc, u8 first_packet)
 {
 	/* only 1st packet supplies a word timestamp */
 	if (first_packet) {
-		u16 tmp16;
+		__le16 tmp16;
 
 		if ((mc->ptr + 2) > mc->end)
 			return -EINVAL;
@@ -614,7 +614,7 @@ static int pcan_usb_decode_data(struct pcan_usb_msg_context *mc, u8 status_len)
 		return -ENOMEM;
 
 	if (status_len & PCAN_USB_STATUSLEN_EXT_ID) {
-		u32 tmp32;
+		__le32 tmp32;
 
 		if ((mc->ptr + 4) > mc->end)
 			goto decode_failed;
@@ -622,9 +622,9 @@ static int pcan_usb_decode_data(struct pcan_usb_msg_context *mc, u8 status_len)
 		memcpy(&tmp32, mc->ptr, 4);
 		mc->ptr += 4;
 
-		cf->can_id = le32_to_cpu(tmp32 >> 3) | CAN_EFF_FLAG;
+		cf->can_id = (le32_to_cpu(tmp32) >> 3) | CAN_EFF_FLAG;
 	} else {
-		u16 tmp16;
+		__le16 tmp16;
 
 		if ((mc->ptr + 2) > mc->end)
 			goto decode_failed;
@@ -632,7 +632,7 @@ static int pcan_usb_decode_data(struct pcan_usb_msg_context *mc, u8 status_len)
 		memcpy(&tmp16, mc->ptr, 2);
 		mc->ptr += 2;
 
-		cf->can_id = le16_to_cpu(tmp16 >> 5);
+		cf->can_id = le16_to_cpu(tmp16) >> 5;
 	}
 
 	cf->can_dlc = get_can_dlc(rec_len);
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index dc807e10f802..c62f48a1161d 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -856,6 +856,7 @@ static int peak_usb_probe(struct usb_interface *intf,
 			  const struct usb_device_id *id)
 {
 	struct usb_device *usb_dev = interface_to_usbdev(intf);
+	const u16 usb_id_product = le16_to_cpu(usb_dev->descriptor.idProduct);
 	struct peak_usb_adapter *peak_usb_adapter, **pp;
 	int i, err = -ENOMEM;
 
@@ -863,7 +864,7 @@ static int peak_usb_probe(struct usb_interface *intf,
 
 	/* get corresponding PCAN-USB adapter */
 	for (pp = peak_usb_adapters_list; *pp; pp++)
-		if ((*pp)->device_id == usb_dev->descriptor.idProduct)
+		if ((*pp)->device_id == usb_id_product)
 			break;
 
 	peak_usb_adapter = *pp;
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
index f7f796a2c50b..4cfa3b8605b1 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
@@ -78,8 +78,8 @@ struct pcan_usb_pro_msg {
 	int rec_buffer_size;
 	int rec_buffer_len;
 	union {
-		u16 *rec_cnt_rd;
-		u32 *rec_cnt;
+		__le16 *rec_cnt_rd;
+		__le32 *rec_cnt;
 		u8 *rec_buffer;
 	} u;
 };
@@ -155,7 +155,7 @@ static int pcan_msg_add_rec(struct pcan_usb_pro_msg *pm, u8 id, ...)
 		*pc++ = va_arg(ap, int);
 		*pc++ = va_arg(ap, int);
 		*pc++ = va_arg(ap, int);
-		*(u32 *)pc = cpu_to_le32(va_arg(ap, u32));
+		*(__le32 *)pc = cpu_to_le32(va_arg(ap, u32));
 		pc += 4;
 		memcpy(pc, va_arg(ap, int *), i);
 		pc += i;
@@ -165,7 +165,7 @@ static int pcan_msg_add_rec(struct pcan_usb_pro_msg *pm, u8 id, ...)
 	case PCAN_USBPRO_GETDEVID:
 		*pc++ = va_arg(ap, int);
 		pc += 2;
-		*(u32 *)pc = cpu_to_le32(va_arg(ap, u32));
+		*(__le32 *)pc = cpu_to_le32(va_arg(ap, u32));
 		pc += 4;
 		break;
 
@@ -173,21 +173,21 @@ static int pcan_msg_add_rec(struct pcan_usb_pro_msg *pm, u8 id, ...)
 	case PCAN_USBPRO_SETBUSACT:
 	case PCAN_USBPRO_SETSILENT:
 		*pc++ = va_arg(ap, int);
-		*(u16 *)pc = cpu_to_le16(va_arg(ap, int));
+		*(__le16 *)pc = cpu_to_le16(va_arg(ap, int));
 		pc += 2;
 		break;
 
 	case PCAN_USBPRO_SETLED:
 		*pc++ = va_arg(ap, int);
-		*(u16 *)pc = cpu_to_le16(va_arg(ap, int));
+		*(__le16 *)pc = cpu_to_le16(va_arg(ap, int));
 		pc += 2;
-		*(u32 *)pc = cpu_to_le32(va_arg(ap, u32));
+		*(__le32 *)pc = cpu_to_le32(va_arg(ap, u32));
 		pc += 4;
 		break;
 
 	case PCAN_USBPRO_SETTS:
 		pc++;
-		*(u16 *)pc = cpu_to_le16(va_arg(ap, int));
+		*(__le16 *)pc = cpu_to_le16(va_arg(ap, int));
 		pc += 2;
 		break;
 
@@ -200,7 +200,7 @@ static int pcan_msg_add_rec(struct pcan_usb_pro_msg *pm, u8 id, ...)
 
 	len = pc - pm->rec_ptr;
 	if (len > 0) {
-		*pm->u.rec_cnt = cpu_to_le32(*pm->u.rec_cnt+1);
+		*pm->u.rec_cnt = cpu_to_le32(le32_to_cpu(*pm->u.rec_cnt) + 1);
 		*pm->rec_ptr = id;
 
 		pm->rec_ptr = pc;
@@ -571,7 +571,7 @@ static int pcan_usb_pro_handle_canmsg(struct pcan_usb_pro_interface *usb_if,
 static int pcan_usb_pro_handle_error(struct pcan_usb_pro_interface *usb_if,
 				     struct pcan_usb_pro_rxstatus *er)
 {
-	const u32 raw_status = le32_to_cpu(er->status);
+	const u16 raw_status = le16_to_cpu(er->status);
 	const unsigned int ctrl_idx = (er->channel >> 4) & 0x0f;
 	struct peak_usb_device *dev = usb_if->dev[ctrl_idx];
 	struct net_device *netdev = dev->netdev;
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.h b/drivers/net/can/usb/peak_usb/pcan_usb_pro.h
index 32275af547e0..837cee267132 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.h
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.h
@@ -33,27 +33,27 @@
 
 /* PCAN_USBPRO_INFO_BL vendor request record type */
 struct __packed pcan_usb_pro_blinfo {
-	u32 ctrl_type;
+	__le32 ctrl_type;
 	u8  version[4];
 	u8  day;
 	u8  month;
 	u8  year;
 	u8  dummy;
-	u32 serial_num_hi;
-	u32 serial_num_lo;
-	u32 hw_type;
-	u32 hw_rev;
+	__le32 serial_num_hi;
+	__le32 serial_num_lo;
+	__le32 hw_type;
+	__le32 hw_rev;
 };
 
 /* PCAN_USBPRO_INFO_FW vendor request record type */
 struct __packed pcan_usb_pro_fwinfo {
-	u32 ctrl_type;
+	__le32 ctrl_type;
 	u8  version[4];
 	u8  day;
 	u8  month;
 	u8  year;
 	u8  dummy;
-	u32 fw_type;
+	__le32 fw_type;
 };
 
 /*
@@ -80,46 +80,46 @@ struct __packed pcan_usb_pro_fwinfo {
 struct __packed pcan_usb_pro_btr {
 	u8  data_type;
 	u8  channel;
-	u16 dummy;
-	u32 CCBT;
+	__le16 dummy;
+	__le32 CCBT;
 };
 
 struct __packed pcan_usb_pro_busact {
 	u8  data_type;
 	u8  channel;
-	u16 onoff;
+	__le16 onoff;
 };
 
 struct __packed pcan_usb_pro_silent {
 	u8  data_type;
 	u8  channel;
-	u16 onoff;
+	__le16 onoff;
 };
 
 struct __packed pcan_usb_pro_filter {
 	u8  data_type;
 	u8  dummy;
-	u16 filter_mode;
+	__le16 filter_mode;
 };
 
 struct __packed pcan_usb_pro_setts {
 	u8  data_type;
 	u8  dummy;
-	u16 mode;
+	__le16 mode;
 };
 
 struct __packed pcan_usb_pro_devid {
 	u8  data_type;
 	u8  channel;
-	u16 dummy;
-	u32 serial_num;
+	__le16 dummy;
+	__le32 serial_num;
 };
 
 struct __packed pcan_usb_pro_setled {
 	u8  data_type;
 	u8  channel;
-	u16 mode;
-	u32 timeout;
+	__le16 mode;
+	__le32 timeout;
 };
 
 struct __packed pcan_usb_pro_rxmsg {
@@ -127,8 +127,8 @@ struct __packed pcan_usb_pro_rxmsg {
 	u8  client;
 	u8  flags;
 	u8  len;
-	u32 ts32;
-	u32 id;
+	__le32 ts32;
+	__le32 id;
 
 	u8  data[8];
 };
@@ -141,15 +141,15 @@ struct __packed pcan_usb_pro_rxmsg {
 struct __packed pcan_usb_pro_rxstatus {
 	u8  data_type;
 	u8  channel;
-	u16 status;
-	u32 ts32;
-	u32 err_frm;
+	__le16 status;
+	__le32 ts32;
+	__le32 err_frm;
 };
 
 struct __packed pcan_usb_pro_rxts {
 	u8  data_type;
 	u8  dummy[3];
-	u32 ts64[2];
+	__le32 ts64[2];
 };
 
 struct __packed pcan_usb_pro_txmsg {
@@ -157,7 +157,7 @@ struct __packed pcan_usb_pro_txmsg {
 	u8  client;
 	u8  flags;
 	u8  len;
-	u32 id;
+	__le32 id;
 	u8  data[8];
 };
 
-- 
2.1.3

