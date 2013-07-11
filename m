From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 20/50] USB: serial: usb_wwan: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:43 +0800
Message-ID: <1373533573-12272-21-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/usb/serial/usb_wwan.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/serial/usb_wwan.c b/drivers/usb/serial/usb_wwan.c
index 8257d30..c807d65 100644
--- a/drivers/usb/serial/usb_wwan.c
+++ b/drivers/usb/serial/usb_wwan.c
@@ -312,6 +312,7 @@ static void usb_wwan_outdat_callback(struct urb *urb)
 	struct usb_wwan_port_private *portdata;
 	struct usb_wwan_intf_private *intfdata;
 	int i;
+	unsigned long flags;
 
 	port = urb->context;
 	intfdata = port->serial->private;
@@ -319,9 +320,9 @@ static void usb_wwan_outdat_callback(struct urb *urb)
 	usb_serial_port_softint(port);
 	usb_autopm_put_interface_async(port->serial->interface);
 	portdata = usb_get_serial_port_data(port);
-	spin_lock(&intfdata->susp_lock);
+	spin_lock_irqsave(&intfdata->susp_lock, flags);
 	intfdata->in_flight--;
-	spin_unlock(&intfdata->susp_lock);
+	spin_unlock_irqrestore(&intfdata->susp_lock, flags);
 
 	for (i = 0; i < N_OUT_URB; ++i) {
 		if (portdata->out_urbs[i] == urb) {
-- 
1.7.9.5
