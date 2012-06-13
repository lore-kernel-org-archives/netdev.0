From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 1/3] usbnet: clear OPEN flag in failure path
Date: Wed, 13 Jun 2012 12:20:15 +0800
Message-ID: <1339561217-18151-2-git-send-email-ming.lei@canonical.com>
References: <1339561217-18151-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1339561217-18151-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Without clearing OPEN flag in failure path, runtime or system resume
may submit interrupt/rx URB and start tx queue mistakenly on a
interface in DOWN state.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ac2e493..f06cf9b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -793,11 +793,13 @@ int usbnet_open (struct net_device *net)
 	if (info->manage_power) {
 		retval = info->manage_power(dev, 1);
 		if (retval < 0)
-			goto done;
+			goto done_manage_power_error;
 		usb_autopm_put_interface(dev->intf);
 	}
 	return retval;
 
+done_manage_power_error:
+	clear_bit(EVENT_DEV_OPEN, &dev->flags);
 done:
 	usb_autopm_put_interface(dev->intf);
 done_nopm:
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
