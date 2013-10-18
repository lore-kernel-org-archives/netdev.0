From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH RESENT] staging: r8188eu: Move writeN buffer off stack
Date: Fri, 18 Oct 2013 16:39:04 -0500
Message-ID: <5261AA78.6090205@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	devel@driverdev.osuosl.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:42250 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab3JRVjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 17:39:06 -0400
Received: by mail-oa0-f50.google.com with SMTP id j1so3933142oag.9
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 14:39:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver places a 254-byte buffer on the stack when writing long output.
To reduce stack usage, a buffer of the required length is acquired using
kmemdup().

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
  drivers/staging/rtl8188eu/hal/usb_ops_linux.c | 58 +++++++++++++++++++--------
  1 file changed, 42 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c 
b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
index 787763e..7ba52a1 100644
--- a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
@@ -267,28 +267,54 @@ static int usb_write32(struct intf_hdl *pintfhdl, u32 
addr, u32 val)
   static int usb_writeN(struct intf_hdl *pintfhdl, u32 addr, u32 length, u8 *pdata)
  {
-	u8 request;
-	u8 requesttype;
-	u16 wvalue;
-	u16 index;
-	u16 len;
-	u8 buf[VENDOR_CMD_MAX_DATA_LEN] = {0};
+	struct adapter	*adapt = pintfhdl->padapter;
+	struct dvobj_priv  *dvobjpriv = adapter_to_dvobj(adapt);
+	struct usb_device *udev = dvobjpriv->pusbdev;
+	u8 request = REALTEK_USB_VENQT_CMD_REQ;
+	u8 reqtype =  REALTEK_USB_VENQT_WRITE;
+	u16 value = (u16)(addr & 0x0000ffff);
+	u16 index = REALTEK_USB_VENQT_CMD_IDX;
+	int pipe = usb_sndctrlpipe(udev, 0); /* write_out */
+	u8 *buffer;
  	int ret;
+	int vendorreq_times = 0;
  -	_func_enter_;
-
-	request = 0x05;
-	requesttype = 0x00;/* write_out */
-	index = 0;/* n/a */
+	buffer = kmemdup(pdata, length, GFP_ATOMIC);
+	if (!buffer)
+		return -ENOMEM;
+	while (++vendorreq_times <= MAX_USBCTRL_VENDORREQ_TIMES) {
+		pipe = usb_sndctrlpipe(udev, 0);/* write_out */
  -	wvalue = (u16)(addr&0x0000ffff);
-	len = length;
-	 memcpy(buf, pdata, len);
+		ret = rtw_usb_control_msg(udev, pipe, request, reqtype,
+					  value, index, buffer, length,
+					  RTW_USB_CONTROL_MSG_TIMEOUT);
  -	ret = usbctrl_vendorreq(pintfhdl, request, wvalue, index, buf, len, 
requesttype);
+		if (ret == length) {   /*  Success this control transfer. */
+			rtw_reset_continual_urb_error(dvobjpriv);
+		} else { /*  error cases */
+			DBG_88E("reg 0x%x, usb %u write fail, status:%d value=0x%x, 
vendorreq_times:%d\n",
+				value, length, ret, *(u32 *)pdata, vendorreq_times);
  -	_func_exit_;
+			if (ret < 0) {
+				if (ret == (-ESHUTDOWN) || ret == -ENODEV) {
+					adapt->bSurpriseRemoved = true;
+				} else {
+					struct hal_data_8188e	*haldata = GET_HAL_DATA(adapt);
+					haldata->srestpriv.Wifi_Error_Status = USB_VEN_REQ_CMD_FAIL;
+				}
+			}
+			if (rtw_inc_and_chk_continual_urb_error(dvobjpriv)) {
+				adapt->bSurpriseRemoved = true;
+				break;
+			}
+		}
  +		/*  firmware download is checksumed, don't retry */
+		if ((value >= FW_8188E_START_ADDRESS &&
+		    value <= FW_8188E_END_ADDRESS) || ret == length)
+			break;
+	}
+	kfree(buffer);
  	return ret;
  }
  -- 1.8.4
