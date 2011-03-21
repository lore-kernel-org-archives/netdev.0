From: DMITRIY GRUZMAN <xmb836@motorola.com>
Subject: [PATCH] usbnet: fix memory leak in usbnet_disconnect()
Date: Mon, 21 Mar 2011 16:49:50 -0500
Message-ID: <AANLkTintuq7z45e-Cr8Ma5_Bm+UtnO+Gsysn6A3kv+CZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fulei TIAN <a20612@motorola.com>,
	Chang Junxiao <jxchang@motorola.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og105.obsmtp.com ([64.18.0.180]:37321 "EHLO
	exprod5og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506Ab1CUWjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 18:39:54 -0400
Received: from DE01MGRG01.AM.MOT-MOBILITY.COM ([10.22.94.168])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p2LLoAT3005245
	for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 17:50:11 -0400 (EDT)
Received: from mail-wy0-f170.google.com (mail-wy0-f170.google.com [74.125.82.170])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p2LLhifL003140
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 17:50:10 -0400 (EDT)
Received: by mail-wy0-f170.google.com with SMTP id 34so8328680wyb.15
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 14:49:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usb_probe() allocates memory for transfer buffer and urb and this
memory was not properly released in usbnet_disconnect().   The issue
was found and the fix was recommended by Fu-Lei Tian and Jun-Xiao
Chang.

Signed-off-by: Dmitriy Gruzman <xmb836@motorola.com>
---
 drivers/net/usb/usbnet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index c04d49e..67a5728 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -210,6 +210,7 @@ static int init_status (struct usbnet *dev, struct
usb_interface *intf)
 		} else {
 			usb_fill_int_urb(dev->interrupt, dev->udev, pipe,
 				buf, maxp, intr_complete, dev, period);
+			dev->interrupt->transfer_flags |= URB_FREE_BUFFER;
 			dev_dbg(&intf->dev,
 				"status ep%din, %d bytes period %d\n",
 				usb_pipeendpoint(pipe), maxp, period);
@@ -1237,6 +1238,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 	if (dev->driver_info->unbind)
 		dev->driver_info->unbind (dev, intf);

+	usb_free_urb(dev->interrupt);
 	free_netdev(net);
 	usb_put_dev (xdev);
 }
-- 
1.7.0.4
