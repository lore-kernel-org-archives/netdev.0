From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net v2] netvsc: fix net poll mode
Date: Fri, 12 May 2017 15:55:30 -0700
Message-ID: <20170512225530.2233-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35095 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757551AbdELWzk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 18:55:40 -0400
Received: by mail-pf0-f182.google.com with SMTP id n23so31524493pfb.2
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 15:55:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ndo_poll_controller function needs to schedule NAPI to pick
up arriving packets and send completions. Otherwise no data
will ever be received.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
v2 - use rcu to ensure lower data structure is present

 drivers/net/hyperv/netvsc_drv.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4421a6d00375..c171f5bc41b9 100644
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
