From: Jim Wylder <jwylder1@motorola.com>
Subject: [PATCH] usbnet: ignore get interface retval of -EINPROGRESS
Date: Sat, 3 Sep 2011 09:21:00 -0500
Message-ID: <CAPopfEUUaEChuh1mdZnHHT_9uRfsQmwMu7=gjnYr=AmFWik2HA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og105.obsmtp.com ([64.18.0.180]:39566 "EHLO
	exprod5og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab1ICOpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 10:45:04 -0400
Received: from DE01MGRG01.AM.MOT-MOBILITY.COM ([10.22.94.167])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p83ELqdB013649
	for <netdev@vger.kernel.org>; Sat, 3 Sep 2011 10:21:52 -0400 (EDT)
Received: from mail-wy0-f170.google.com (mail-wy0-f170.google.com [74.125.82.170])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p83ELXar013608
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 3 Sep 2011 10:21:51 -0400 (EDT)
Received: by mail-wy0-f170.google.com with SMTP id 23so3259928wyf.15
        for <netdev@vger.kernel.org>; Sat, 03 Sep 2011 07:21:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calling pm_runtime_get, usb_autopm_get_interface_async
treats a return value of -EINPROGRESS as a success and
increments the usage count.  Since the interface is resuming,
it is safe for usbnet_start_xmit to submit the urb.  If instead,
usbnet_start_xmit treats this as an error the packet will be
dropped.  Additionally, a corresponding tx_complete will not
run to offset the earlier increment of the usage count from the
call to usb_autopm_get_interface_async.

Signed-off-by: James Wylder <james.wylder@motorola.com>
---
 drivers/net/usb/usbnet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ce395fe..90849d6 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1105,7 +1105,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,

 	spin_lock_irqsave(&dev->txq.lock, flags);
 	retval = usb_autopm_get_interface_async(dev->intf);
-	if (retval < 0) {
+	if (retval < 0 && retval != -EINPROGRESS) {
 		spin_unlock_irqrestore(&dev->txq.lock, flags);
 		goto drop;
 	}
-- 
1.7.6
