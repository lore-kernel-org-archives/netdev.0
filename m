From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 25/37] drivers/net/usb: Use kmemdup
Date: Sat, 15 May 2010 23:20:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152320270.21345@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use kmemdup when some other buffer is immediately copied into the
allocated region.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/usb/asix.c    |    3 +--
 drivers/net/usb/mcs7830.c |    4 +---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff -u -p a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -224,10 +224,9 @@ static int asix_write_cmd(struct usbnet 
 		   cmd, value, index, size);
 
 	if (data) {
-		buf = kmalloc(size, GFP_KERNEL);
+		buf = kmemdup(data, size, GFP_KERNEL);
 		if (!buf)
 			goto out;
-		memcpy(buf, data, size);
 	}
 
 	err = usb_control_msg(
diff -u -p a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -142,12 +142,10 @@ static int mcs7830_set_reg(struct usbnet
 	int ret;
 	void *buffer;
 
-	buffer = kmalloc(size, GFP_NOIO);
+	buffer = kmemdup(data, size, GFP_NOIO);
 	if (buffer == NULL)
 		return -ENOMEM;
 
-	memcpy(buffer, data, size);
-
 	ret = usb_control_msg(xdev, usb_sndctrlpipe(xdev, 0), MCS7830_WR_BREQ,
 			      MCS7830_WR_BMREQ, 0x0000, index, buffer,
 			      size, MCS7830_CTRL_TIMEOUT);
