From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 04/14] tg3: Refine tg3_vlan_rx_register()
Date: Wed, 25 Feb 2009 16:23:56 -0800
Message-ID: <1235616370.16004@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2998 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753890AbZBZCq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3_vlan_rx_register() touches the hardware if netif_running() returns
false.  This patch fixes the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0ea61f7..ce29097 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9896,8 +9896,12 @@ static void tg3_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	if (netif_running(dev))
-		tg3_netif_stop(tp);
+	if (!netif_running(dev)) {
+		tp->vlgrp = grp;
+		return;
+	}
+
+	tg3_netif_stop(tp);
 
 	tg3_full_lock(tp, 0);
 
@@ -9906,8 +9910,7 @@ static void tg3_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	/* Update RX_MODE_KEEP_VLAN_TAG bit in RX_MODE register. */
 	__tg3_set_rx_mode(dev);
 
-	if (netif_running(dev))
-		tg3_netif_start(tp);
+	tg3_netif_start(tp);
 
 	tg3_full_unlock(tp);
 }
-- 
1.6.0.6


