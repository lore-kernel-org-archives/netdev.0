From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: [PATCH] net/usb: rtl8150: allocate URB transfer_buffer and
 setup_packet separately
Date: Wed, 07 Aug 2013 16:36:53 +0300
Message-ID: <20130807133653.15587.35442.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Petko Manolov <petkan@nucleusys.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from saarni.dnainternet.net ([83.102.40.136]:34941 "EHLO
	saarni.dnainternet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040Ab3HGNhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 09:37:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8150 allocates URB transfer_buffer and setup_packet as part of same
structure 'struct async_req'. This can cause same cacheline to be DMA-mapped
twice with same URB. This can lead to memory corruption on some systems.

Patch make allocation of these buffers separate.

Use of 'struct async_req' was introduced by recent commit 4d12997a9b "drivers:
net: usb: rtl8150: concurrent URB bugfix".

Patch is only compile tested.

Cc: <stable@vger.kernel.org>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
---
 drivers/net/usb/rtl8150.c |   48 +++++++++++++++++++++++----------------------
 1 file changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 6cbdac6..c353bfd 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -142,11 +142,6 @@ struct rtl8150 {
 
 typedef struct rtl8150 rtl8150_t;
 
-struct async_req {
-	struct usb_ctrlrequest dr;
-	u16 rx_creg;
-};
-
 static const char driver_name [] = "rtl8150";
 
 /*
@@ -170,12 +165,12 @@ static int set_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
 
 static void async_set_reg_cb(struct urb *urb)
 {
-	struct async_req *req = (struct async_req *)urb->context;
 	int status = urb->status;
 
 	if (status < 0)
 		dev_dbg(&urb->dev->dev, "%s failed with %d", __func__, status);
-	kfree(req);
+	kfree(urb->setup_packet); /* dr */
+	kfree(urb->transfer_buffer); /* rx_creg */
 	usb_free_urb(urb);
 }
 
@@ -183,25 +178,27 @@ static int async_set_registers(rtl8150_t *dev, u16 indx, u16 size, u16 reg)
 {
 	int res = -ENOMEM;
 	struct urb *async_urb;
-	struct async_req *req;
+	struct usb_ctrlrequest *dr;
+	u16 *rx_creg;
+
+	dr = kmalloc(sizeof(*dr), GFP_ATOMIC);
+	rx_creg = kmalloc(sizeof(*rx_creg), GFP_ATOMIC);
+	if (!dr || !rx_creg)
+		goto err;
 
-	req = kmalloc(sizeof(struct async_req), GFP_ATOMIC);
-	if (req == NULL)
-		return res;
 	async_urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (async_urb == NULL) {
-		kfree(req);
-		return res;
-	}
-	req->rx_creg = cpu_to_le16(reg);
-	req->dr.bRequestType = RTL8150_REQT_WRITE;
-	req->dr.bRequest = RTL8150_REQ_SET_REGS;
-	req->dr.wIndex = 0;
-	req->dr.wValue = cpu_to_le16(indx);
-	req->dr.wLength = cpu_to_le16(size);
+	if (async_urb == NULL)
+		goto err;
+
+	*rx_creg = cpu_to_le16(reg);
+	dr->bRequestType = RTL8150_REQT_WRITE;
+	dr->bRequest = RTL8150_REQ_SET_REGS;
+	dr->wIndex = 0;
+	dr->wValue = cpu_to_le16(indx);
+	dr->wLength = cpu_to_le16(size);
 	usb_fill_control_urb(async_urb, dev->udev,
-	                     usb_sndctrlpipe(dev->udev, 0), (void *)&req->dr,
-			     &req->rx_creg, size, async_set_reg_cb, req);
+			     usb_sndctrlpipe(dev->udev, 0), (void *)dr,
+			     rx_creg, size, async_set_reg_cb, NULL);
 	res = usb_submit_urb(async_urb, GFP_ATOMIC);
 	if (res) {
 		if (res == -ENODEV)
@@ -209,6 +206,11 @@ static int async_set_registers(rtl8150_t *dev, u16 indx, u16 size, u16 reg)
 		dev_err(&dev->udev->dev, "%s failed with %d\n", __func__, res);
 	}
 	return res;
+
+err:
+	kfree(dr);
+	kfree(rx_creg);
+	return res;
 }
 
 static int read_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 * reg)
