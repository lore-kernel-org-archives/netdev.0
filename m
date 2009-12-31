From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Lock transmit queue while disabling device
Date: Thu, 31 Dec 2009 19:55:31 +0900
Message-ID: <4B3C8323.1080301@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, flyboy@gmail.com, dhazelton@enter.net,
	mbreuer@majjas.com, "netdev@vger.kernel.org"@ogre.sisk.pl
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:37756 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbZLaK65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 05:58:57 -0500
Received: by pzk1 with SMTP id 1so674854pzk.33
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 02:58:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


netif_device_detach() does not take the tx_lock, so it's
 possible that a call to sky2_xmit_frame is still in
 progress after netif_device_detach() is complete.

Take netif_tx_lock() to make sure all transmits have
 stopped while we're disabling the devices and that
 no other CPU is still transmitting a frame after
 we've disabling the device.

Proposed fix for "sky2 panic under load" reported by Berck E. Nash.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index faa4841..8ae8520 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3176,7 +3176,9 @@ static void sky2_reset(struct sky2_hw *hw)
 static void sky2_detach(struct net_device *dev)
 {
 	if (netif_running(dev)) {
+		netif_tx_lock(dev);
 		netif_device_detach(dev);	/* stop txq */
+		netif_tx_unlock(dev);
 		sky2_down(dev);
 	}
 }
-- 
1.5.6.5

