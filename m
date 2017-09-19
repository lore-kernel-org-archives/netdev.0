From: Douglas Anderson <dianders@chromium.org>
Subject: [RFC PATCH 3/3] usbnet: Fix memory leak when rx_submit() fails
Date: Tue, 19 Sep 2017 09:15:22 -0700
Message-ID: <20170919161522.995-3-dianders@chromium.org>
References: <20170919161522.995-1-dianders@chromium.org>
Cc: groeck@chromium.org, grundler@chromium.org,
        Douglas Anderson <dianders@chromium.org>,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:54379 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdISQPy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 12:15:54 -0400
Received: by mail-pf0-f169.google.com with SMTP id d187so51052pfg.11
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 09:15:54 -0700 (PDT)
In-Reply-To: <20170919161522.995-1-dianders@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If rx_submit() returns an error code then nobody calls usb_free_urb().
That means it's leaked.

NOTE: This problem was found solely by code inspection and not due to
any failing test cases.

Signed-off-by: Douglas Anderson <dianders@chromium.org>
---

 drivers/net/usb/usbnet.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index e72547d8d0e6..4c067aaeea5a 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1182,9 +1182,12 @@ usbnet_deferred_kevent (struct work_struct *work)
 					usb_free_urb(urb);
 					goto fail_lowmem;
 				}
-				if (rx_submit (dev, urb, GFP_KERNEL) ==
-				    -ENOLINK)
-					resched = 0;
+				status = rx_submit (dev, urb, GFP_KERNEL);
+				if (status) {
+					usb_free_urb(urb);
+					if (status == -ENOLINK)
+						resched = 0;
+				}
 				usb_autopm_put_interface(dev->intf);
 fail_lowmem:
 				if (resched)
-- 
2.14.1.690.gbb1197296e-goog
