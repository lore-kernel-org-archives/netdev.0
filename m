From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH] usbnet: make sure no NULL pointer is passed through
Date: Wed,  5 Apr 2017 14:14:39 +0200
Message-ID: <20170405121439.22523-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: stephen@networkplumber.org, davem@davemloft.net,
        netdev@vger.kernel.org, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56456 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755050AbdDEMPn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 08:15:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coverity reports:

** CID 751368:  Null pointer dereferences  (FORWARD_NULL)
/drivers/net/usb/usbnet.c: 1925 in __usbnet_read_cmd()

________________________________________________________________________________________________________
*** CID 751368:  Null pointer dereferences  (FORWARD_NULL)
/drivers/net/usb/usbnet.c: 1925 in __usbnet_read_cmd()
1919     EXPORT_SYMBOL(usbnet_link_change);
1920
1921     /*-------------------------------------------------------------------------*/
1922     static int __usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
1923                                 u16 value, u16 index, void *data, u16 size)
1924     {
>>>     CID 751368:  Null pointer dereferences  (FORWARD_NULL)
>>>     Assigning: "buf" = "NULL".
1925            void *buf = NULL;
1926            int err = -ENOMEM;
1927
1928            netdev_dbg(dev->net, "usbnet_read_cmd cmd=0x%02x reqtype=%02x"
1929                       " value=0x%04x index=0x%04x size=%d\n",
1930                       cmd, reqtype, value, index, size);

** CID 751370:  Null pointer dereferences  (FORWARD_NULL)
/drivers/net/usb/usbnet.c: 1952 in __usbnet_write_cmd()

________________________________________________________________________________________________________
*** CID 751370:  Null pointer dereferences  (FORWARD_NULL)
/drivers/net/usb/usbnet.c: 1952 in __usbnet_write_cmd()
1946     }
1947
1948     static int __usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
1949                                  u16 value, u16 index, const void *data,
1950                                  u16 size)
1951     {
>>>     CID 751370:  Null pointer dereferences  (FORWARD_NULL)
>>>     Assigning: "buf" = "NULL".
1952            void *buf = NULL;
1953            int err = -ENOMEM;
1954
1955            netdev_dbg(dev->net, "usbnet_write_cmd cmd=0x%02x reqtype=%02x"
1956                       " value=0x%04x index=0x%04x size=%d\n",
1957                       cmd, reqtype, value, index, size);

** CID 1325026:  Null pointer dereferences  (FORWARD_NULL)
/drivers/net/usb/ch9200.c: 143 in control_write()

It is valid to offer commands without a buffer, but then you need a size
of zero. This should actually be checked.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/usbnet.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3de65ea..4532448 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1929,7 +1929,7 @@ static int __usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 		   " value=0x%04x index=0x%04x size=%d\n",
 		   cmd, reqtype, value, index, size);
 
-	if (data) {
+	if (size) {
 		buf = kmalloc(size, GFP_KERNEL);
 		if (!buf)
 			goto out;
@@ -1938,8 +1938,13 @@ static int __usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 	err = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
 			      cmd, reqtype, value, index, buf, size,
 			      USB_CTRL_GET_TIMEOUT);
-	if (err > 0 && err <= size)
-		memcpy(data, buf, err);
+	if (err > 0 && err <= size) {
+        if (data)
+            memcpy(data, buf, err);
+        else
+            netdev_dbg(dev->net,
+                "Huh? Data requested but thrown away.\n");
+    }
 	kfree(buf);
 out:
 	return err;
@@ -1960,7 +1965,13 @@ static int __usbnet_write_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 		buf = kmemdup(data, size, GFP_KERNEL);
 		if (!buf)
 			goto out;
-	}
+	} else {
+        if (size) {
+            WARN_ON_ONCE(1);
+            err = -EINVAL;
+            goto out;
+        }
+    }
 
 	err = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
 			      cmd, reqtype, value, index, buf, size,
-- 
2.10.2
