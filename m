From: Maksim Salau <maksim.salau@gmail.com>
Subject: [PATCH] net: wireless: orinoco: usb: Fix buffer on stack
Date: Sat, 22 Apr 2017 20:03:06 +0300
Message-ID: <20170422170306.11668-1-maksim.salau@gmail.com>
Cc: Maksim Salau <maksim.salau@gmail.com>
To: Kalle Valo <kvalo@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        Wolfram Sang <wsa-dev@sang-engineering.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Florian Westphal <fw@strlen.de>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35423 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426070AbdDVRDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 13:03:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate buffer on HEAP instead of STACK for a local variable
that is to be sent using usb_control_msg().

Signed-off-by: Maksim Salau <maksim.salau@gmail.com>
---
 drivers/net/wireless/intersil/orinoco/orinoco_usb.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/intersil/orinoco/orinoco_usb.c b/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
index bca6935..eb4528b 100644
--- a/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
@@ -770,18 +770,31 @@ static int ezusb_submit_in_urb(struct ezusb_priv *upriv)
 
 static inline int ezusb_8051_cpucs(struct ezusb_priv *upriv, int reset)
 {
-	u8 res_val = reset;	/* avoid argument promotion */
+	int ret;
+	u8 *res_val = NULL;
 
 	if (!upriv->udev) {
 		err("%s: !upriv->udev", __func__);
 		return -EFAULT;
 	}
-	return usb_control_msg(upriv->udev,
+
+	res_val = kmalloc(sizeof(*res_val), GFP_KERNEL);
+
+	if (!res_val)
+		return -ENOMEM;
+
+	*res_val = reset;	/* avoid argument promotion */
+
+	ret =  usb_control_msg(upriv->udev,
 			       usb_sndctrlpipe(upriv->udev, 0),
 			       EZUSB_REQUEST_FW_TRANS,
 			       USB_TYPE_VENDOR | USB_RECIP_DEVICE |
-			       USB_DIR_OUT, EZUSB_CPUCS_REG, 0, &res_val,
-			       sizeof(res_val), DEF_TIMEOUT);
+			       USB_DIR_OUT, EZUSB_CPUCS_REG, 0, res_val,
+			       sizeof(*res_val), DEF_TIMEOUT);
+
+	kfree(res_val);
+
+	return ret;
 }
 
 static int ezusb_firmware_download(struct ezusb_priv *upriv,
-- 
2.9.3
