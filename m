From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 46/62] usb: Use static const
Date: Sat, 20 Nov 2010 18:38:47 -0800
Message-ID: <ed2a5bd07f07601ba12ce3c8fcbce2dd954c35aa.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1290305773.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  36120	    312	   9000	  45432	   b178	drivers/net/usb/hso.o.old
  36043	    312	   9008	  45363	   b133	drivers/net/usb/hso.o.new

Consolidate duplicated code into new fix_crc_bug function
and declare data in that function static const.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/hso.c |   39 ++++++++++++++++-----------------------
 1 files changed, 16 insertions(+), 23 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index be8cc2a..c77d0ea 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1001,6 +1001,18 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 	}
 }
 
+static void fix_crc_bug(struct urb *urb, __le16 max_packet_size)
+{
+	static const u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
+	u32 rest = urb->actual_length % le16_to_cpu(max_packet_size);
+
+	if (((rest == 5) || (rest == 6)) &&
+	    !memcmp(((u8 *)urb->transfer_buffer) + urb->actual_length - 4,
+		    crc_check, 4)) {
+		urb->actual_length -= 4;
+	}
+}
+
 /* Moving data from usb to kernel (in interrupt state) */
 static void read_bulk_callback(struct urb *urb)
 {
@@ -1029,17 +1041,8 @@ static void read_bulk_callback(struct urb *urb)
 		return;
 	}
 
-	if (odev->parent->port_spec & HSO_INFO_CRC_BUG) {
-		u32 rest;
-		u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
-		rest = urb->actual_length %
-			le16_to_cpu(odev->in_endp->wMaxPacketSize);
-		if (((rest == 5) || (rest == 6)) &&
-		    !memcmp(((u8 *) urb->transfer_buffer) +
-			    urb->actual_length - 4, crc_check, 4)) {
-			urb->actual_length -= 4;
-		}
-	}
+	if (odev->parent->port_spec & HSO_INFO_CRC_BUG)
+		fix_crc_bug(urb, odev->in_endp->wMaxPacketSize);
 
 	/* do we even have a packet? */
 	if (urb->actual_length) {
@@ -1231,18 +1234,8 @@ static void hso_std_serial_read_bulk_callback(struct urb *urb)
 		return;
 
 	if (status == 0) {
-		if (serial->parent->port_spec & HSO_INFO_CRC_BUG) {
-			u32 rest;
-			u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
-			rest =
-			    urb->actual_length %
-			    le16_to_cpu(serial->in_endp->wMaxPacketSize);
-			if (((rest == 5) || (rest == 6)) &&
-			    !memcmp(((u8 *) urb->transfer_buffer) +
-				    urb->actual_length - 4, crc_check, 4)) {
-				urb->actual_length -= 4;
-			}
-		}
+		if (serial->parent->port_spec & HSO_INFO_CRC_BUG)
+			fix_crc_bug(urb, serial->in_endp->wMaxPacketSize);
 		/* Valid data, handle RX data */
 		spin_lock(&serial->serial_lock);
 		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 1;
-- 
1.7.3.2.245.g03276.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
