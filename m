From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 2/3] netvsc: fix net poll mode
Date: Mon,  5 Jun 2017 14:10:09 -0700
Message-ID: <20170605211010.9571-3-sthemmin@microsoft.com>
References: <20170605211010.9571-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36332 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751290AbdFEVKW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 17:10:22 -0400
Received: by mail-pg0-f50.google.com with SMTP id a70so18471789pge.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 14:10:22 -0700 (PDT)
In-Reply-To: <20170605211010.9571-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ndo_poll_controller function needs to schedule NAPI to pick
up arriving packets and send completions. Otherwise no data
will ever be received.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index d93e4da25fd2..252e5d52d17e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1158,11 +1158,22 @@ netvsc_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void netvsc_poll_controller(struct net_device *net)
+static void netvsc_poll_controller(struct net_device *dev)
 {
-	/* As netvsc_start_xmit() works synchronous we don't have to
-	 * trigger anything here.
-	 */
+	struct net_device_context *ndc = netdev_priv(dev);
+	struct netvsc_device *ndev;
+	int i;
+
+	rcu_read_lock();
+	ndev = rcu_dereference(ndc->nvdev);
+	if (ndev) {
+		for (i = 0; i < ndev->num_chn; i++) {
+			struct netvsc_channel *nvchan = &ndev->chan_table[i];
+
+			napi_schedule(&nvchan->napi);
+		}
+	}
+	rcu_read_unlock();
 }
 #endif
 
-- 
2.11.0
