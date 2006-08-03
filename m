From: jamal <hadi@cyberus.ca>
Subject: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 03 Aug 2006 09:15:21 -0400
Message-ID: <1154610922.5205.38.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-n2BdpEw2IF0AlW2XlOWZ"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:4240 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932320AbWHCNP2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 09:15:28 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G8d2w-0006bu-A2
	for netdev@vger.kernel.org; Thu, 03 Aug 2006 09:15:30 -0400
To: jesse.brandeburg@intel.com, Auke Kok <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-n2BdpEw2IF0AlW2XlOWZ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


There is no need for tx_locking if you are already netif stopped
(transmit path will never be entered).
With this change under high speed forwarding i see anywhere
between 2-4Kpps improvement on a 2 CPU environment with twoo e1000s tied
to different CPUs forwarding between each other. Actually the
performance improvement should be attributed to the use of
TX_WAKE_THRESHOLD - more drivers should use that technique.

cheers,
jamal

signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

-----


--=-n2BdpEw2IF0AlW2XlOWZ
Content-Disposition: attachment; filename=e1000_wq
Content-Type: text/x-patch; name=e1000_wq; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index da62db8..559e334 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3517,11 +3517,8 @@ #endif
 #define TX_WAKE_THRESHOLD 32
 	if (unlikely(cleaned && netif_queue_stopped(netdev) &&
 	             netif_carrier_ok(netdev))) {
-		spin_lock(&tx_ring->tx_lock);
-		if (netif_queue_stopped(netdev) &&
-		    (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))
+		if (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)
 			netif_wake_queue(netdev);
-		spin_unlock(&tx_ring->tx_lock);
 	}
 
 	if (adapter->detect_tx_hung) {

--=-n2BdpEw2IF0AlW2XlOWZ--

