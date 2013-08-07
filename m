From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: [PATCH 1/2] net/usb: pegasus: do not use stack for URB buffers
Date: Wed, 07 Aug 2013 16:33:26 +0300
Message-ID: <20130807133326.15270.86891.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Petko Manolov <petkan@nucleusys.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tulikuusama.dnainternet.net ([83.102.40.132]:35505 "EHLO
	tulikuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933057Ab3HGNdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 09:33:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently pegasus passes stack memory (which must not be used for DMA
transfers) as URB buffers with get_registers(), set_registers() and
set_register(). Apply fix inside these functions instead of changing every
call site.

Stack usage was introduced by recent commit 323b34963d11 "drivers: net: usb:
pegasus: fix control urb submission".

Patch is only compile tested.

Cc: <stable@vger.kernel.org>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
---
 drivers/net/usb/pegasus.c |   26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 03e8a15..3bce862 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -127,39 +127,59 @@ static void async_ctrl_callback(struct urb *urb)
 static int get_registers(pegasus_t *pegasus, __u16 indx, __u16 size, void *data)
 {
 	int ret;
+	void *buf;
+
+	buf = kmalloc(size, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
 
 	ret = usb_control_msg(pegasus->usb, usb_rcvctrlpipe(pegasus->usb, 0),
 			      PEGASUS_REQ_GET_REGS, PEGASUS_REQT_READ, 0,
-			      indx, data, size, 1000);
+			      indx, buf, size, 1000);
 	if (ret < 0)
 		netif_dbg(pegasus, drv, pegasus->net,
 			  "%s returned %d\n", __func__, ret);
+	else
+		memcpy(data, buf, ret); /* ret == bytes read (max == size) */
+	kfree(buf);
 	return ret;
 }
 
 static int set_registers(pegasus_t *pegasus, __u16 indx, __u16 size, void *data)
 {
 	int ret;
+	void *buf;
+
+	buf = kmemdup(data, size, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
 
 	ret = usb_control_msg(pegasus->usb, usb_sndctrlpipe(pegasus->usb, 0),
 			      PEGASUS_REQ_SET_REGS, PEGASUS_REQT_WRITE, 0,
-			      indx, data, size, 100);
+			      indx, buf, size, 100);
 	if (ret < 0)
 		netif_dbg(pegasus, drv, pegasus->net,
 			  "%s returned %d\n", __func__, ret);
+	kfree(buf);
 	return ret;
 }
 
 static int set_register(pegasus_t *pegasus, __u16 indx, __u8 data)
 {
 	int ret;
+	void *buf;
+
+	buf = kmemdup(&data, 1, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
 
 	ret = usb_control_msg(pegasus->usb, usb_sndctrlpipe(pegasus->usb, 0),
 			      PEGASUS_REQ_SET_REG, PEGASUS_REQT_WRITE, data,
-			      indx, &data, 1, 1000);
+			      indx, buf, 1, 1000);
 	if (ret < 0)
 		netif_dbg(pegasus, drv, pegasus->net,
 			  "%s returned %d\n", __func__, ret);
+	kfree(buf);
 	return ret;
 }
 
