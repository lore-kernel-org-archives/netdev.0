From: Elly Jones <ellyjones@google.com>
Subject: [patch] usbnet: fix 100% CPU use on suspended device
Date: Wed, 21 Jul 2010 14:51:48 -0400
Message-ID: <AANLkTi=pSkOuiFGAK4inPdm-KbLuVrz51e2T6eV51ts0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:56918 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab0GUSvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 14:51:55 -0400
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o6LIpr0E003697
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 11:51:54 -0700
Received: from gxk25 (gxk25.prod.google.com [10.202.11.25])
	by kpbe20.cbf.corp.google.com with ESMTP id o6LIpKtm026557
	for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 11:51:52 -0700
Received: by gxk25 with SMTP id 25so4951799gxk.1
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 11:51:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [patch] usbnet: fix 100% CPU use on suspended device
From: Elly Jones <ellyjones@google.com>

This patch causes the usbnet module not to attempt to submit URBs to the device
if the device is not ready to accept them. This fixes a misbehavior trigged by
the Qualcomm Gobi driver (released under GPL through their Code Aurora
initiative) which causes the usbnet core to consume 100% of CPU attempting and
failing to submit URBs. This patch is against Linus's 2.6 repo commit
a9f7f2e74ae0e6a801a2433dc8e9124d73da0cb4.
Signed-off-by: Elizabeth Jones <ellyjones@google.com>
---
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 81c76ad..df7e72e 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1172,6 +1172,7 @@ static void usbnet_bh (unsigned long param)
 	// or are we maybe short a few urbs?
 	} else if (netif_running (dev->net) &&
 		   netif_device_present (dev->net) &&
+		   dev->udev->can_submit &&
 		   !timer_pending (&dev->delay) &&
 		   !test_bit (EVENT_RX_HALT, &dev->flags)) {
 		int	temp = dev->rxq.qlen;
