From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netvsc: fix net poll mode
Date: Fri, 12 May 2017 13:03:31 -0700
Message-ID: <20170512200331.14433-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35222 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932439AbdELUEB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 16:04:01 -0400
Received: by mail-pg0-f43.google.com with SMTP id q125so15385466pgq.2
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 13:04:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ndo_poll_controller function needs to schedule NAPI to pick
up arriving packets and send completions. Otherwise no data
will ever be received.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4421a6d00375..e487ccea251c 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1158,11 +1158,20 @@ netvsc_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void netvsc_poll_controller(struct net_device *net)
+static void netvsc_poll_controller(struct net_device *dev)
 {
-	/* As netvsc_start_xmit() works synchronous we don't have to
-	 * trigger anything here.
-	 */
+	struct net_device_context *ndc = netdev_priv(dev);
+	struct netvsc_device *ndev = rtnl_dereference(ndc->nvdev);
+	int i;
+
+	if (!ndev)
+		return;
+
+	for (i = 0; i < ndev->num_chn; i++) {
+		struct netvsc_channel *nvchan = &ndev->chan_table[i];
+
+		napi_schedule(&nvchan->napi);
+	}
 }
 #endif
 
-- 
2.11.0
