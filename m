From: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [2.6 patch] hso_create_bulk_serial_device(): fix a double free
Date: Thu, 28 Aug 2008 01:02:37 +0300
Message-ID: <20080827220236.GL11734@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: gregkh-l3A5Bk7waGM@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

hso_serial_common_free() mustn't be called if
hso_serial_common_create() fails.

Reported-by: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

---

 drivers/net/usb/hso.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

d7557f8eda806e6888232bae1b86dfdd8b6cf330 
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 1b7cac7..8c11295 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2206,39 +2206,40 @@ static struct hso_device *hso_create_bulk_serial_device(
 	if (hso_serial_common_create(serial, num_urbs, BULK_URB_RX_SIZE,
 				     BULK_URB_TX_SIZE))
 		goto exit;
 
 	serial->in_endp = hso_get_ep(interface, USB_ENDPOINT_XFER_BULK,
 				     USB_DIR_IN);
 	if (!serial->in_endp) {
 		dev_err(&interface->dev, "Failed to find BULK IN ep\n");
-		goto exit;
+		goto exit2;
 	}
 
 	if (!
 	    (serial->out_endp =
 	     hso_get_ep(interface, USB_ENDPOINT_XFER_BULK, USB_DIR_OUT))) {
 		dev_err(&interface->dev, "Failed to find BULK IN ep\n");
-		goto exit;
+		goto exit2;
 	}
 
 	serial->write_data = hso_std_serial_write_data;
 
 	/* and record this serial */
 	set_serial_by_index(serial->minor, serial);
 
 	/* setup the proc dirs and files if needed */
 	hso_log_port(hso_dev);
 
 	/* done, return it */
 	return hso_dev;
+
+exit2:
+	hso_serial_common_free(serial);
 exit:
-	if (hso_dev && serial)
-		hso_serial_common_free(serial);
 	kfree(serial);
 	hso_free_device(hso_dev);
 	return NULL;
 }
 
 /* Creates a multiplexed AT channel */
 static
 struct hso_device *hso_create_mux_serial_device(struct usb_interface *interface,
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
