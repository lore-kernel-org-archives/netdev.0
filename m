From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH -v1 1/3] usbnet: clear OPEN flag in failure path
Date: Wed, 20 Jun 2012 15:15:51 +0800
Message-ID: <1340176553-32225-2-git-send-email-ming.lei@canonical.com>
References: <1340176553-32225-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48233 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128Ab2FTHQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 03:16:21 -0400
In-Reply-To: <1340176553-32225-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without clearing OPEN flag in failure path, runtime or system resume
may submit interrupt/rx URB and start tx queue mistakenly on a
interface in DOWN state.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
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
