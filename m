From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] USB Network driver infrastructure: Fix leak when
 usb_autopm_get_interface() returns less than zero in kevent().
Date: Thu, 10 Feb 2011 21:58:45 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1102102152450.26035@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>,
	David Brownell <dbrownell@users.sourceforge.net>,
	David Hollis <dhollis@davehollis.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We'll leak the memory allocated to 'urb' in 
drivers/net/usb/usbnet.c:kevent() when we 'goto fail_lowmem' and the 'urb' 
variable goes out of scope while still completely unused.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 usbnet.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

 compile tested only.

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ed9a416..95c41d5 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -931,8 +931,10 @@ fail_halt:
 		if (urb != NULL) {
 			clear_bit (EVENT_RX_MEMORY, &dev->flags);
 			status = usb_autopm_get_interface(dev->intf);
-			if (status < 0)
+			if (status < 0) {
+				usb_free_urb(urb);
 				goto fail_lowmem;
+			}
 			if (rx_submit (dev, urb, GFP_KERNEL) == -ENOLINK)
 				resched = 0;
 			usb_autopm_put_interface(dev->intf);


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
