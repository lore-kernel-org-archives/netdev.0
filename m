From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: [02/04] hso: fix refcounting on the ttyHSx devices
Date: Fri, 8 Aug 2008 12:01:41 -0700
Message-ID: <20080808190141.GC2953@kroah.com>
References: <20080808190023.GA2953@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jari Tenhunen <jari.tenhunen-X3B1VOXEql0@public.gmane.org>,
	Olivier Blin <blino-4qZELD6FgxhWk0Htik3J/w@public.gmane.org>,
	Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	Paul Rolland <rol-fjEKYshTNZ1eoWH0uzbU5w@public.gmane.org>,
	Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080808190023.GA2953-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Olivier Blin <blino-4qZELD6FgxhWk0Htik3J/w@public.gmane.org>


The references on ttyHSx devices were not decremented correctly when
the tty was closed. The helper freeing the serial devices was never
called because of that, and the module left some dangling sysfs
devices after being unloaded.

Signed-off-by: Olivier Blin <blino-4qZELD6FgxhWk0Htik3J/w@public.gmane.org>
Cc: Jari Tenhunen <jari.tenhunen-X3B1VOXEql0@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

---
 drivers/net/usb/hso.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1103,8 +1103,8 @@ static void hso_serial_close(struct tty_
 	/* reset the rts and dtr */
 	/* do the actual close */
 	serial->open_count--;
+	kref_put(&serial->parent->ref, hso_serial_ref_free);
 	if (serial->open_count <= 0) {
-		kref_put(&serial->parent->ref, hso_serial_ref_free);
 		serial->open_count = 0;
 		if (serial->tty) {
 			serial->tty->driver_data = NULL;
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
