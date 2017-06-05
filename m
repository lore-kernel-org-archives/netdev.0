From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 3/3] netvsc: fix RCU warning from set_multicast
Date: Mon,  5 Jun 2017 14:10:10 -0700
Message-ID: <20170605211010.9571-4-sthemmin@microsoft.com>
References: <20170605211010.9571-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33281 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdFEVK3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 17:10:29 -0400
Received: by mail-pg0-f50.google.com with SMTP id f185so25507683pgc.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 14:10:28 -0700 (PDT)
In-Reply-To: <20170605211010.9571-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

do_set_multicast runs in a work queue and therefore is not holding
RCU read lock. This causes:

WARNING: suspicious RCU usage
4.12.0-rc2-net-00284-ge23454766d55-dirty #2 Not tainted
-----------------------------
drivers/net/hyperv/netvsc_drv.c:65 suspicious rcu_dereference_check() usage!

Fix by acquiring rtnl_lock which is ok in the work queue context.

Better fix is to move do_set_mulitcast into rndis_filter.c but
that has more complex impacts, so hold off until net-next.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 252e5d52d17e..ba5c4d037b76 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -62,24 +62,26 @@ static void do_set_multicast(struct work_struct *w)
 		container_of(w, struct net_device_context, work);
 	struct hv_device *device_obj = ndevctx->device_ctx;
 	struct net_device *ndev = hv_get_drvdata(device_obj);
-	struct netvsc_device *nvdev = rcu_dereference(ndevctx->nvdev);
+	struct netvsc_device *nvdev;
 	struct rndis_device *rdev;
 
-	if (!nvdev)
-		return;
-
-	rdev = nvdev->extension;
-	if (rdev == NULL)
-		return;
-
-	if (ndev->flags & IFF_PROMISC)
-		rndis_filter_set_packet_filter(rdev,
-			NDIS_PACKET_TYPE_PROMISCUOUS);
-	else
-		rndis_filter_set_packet_filter(rdev,
-			NDIS_PACKET_TYPE_BROADCAST |
-			NDIS_PACKET_TYPE_ALL_MULTICAST |
-			NDIS_PACKET_TYPE_DIRECTED);
+	rtnl_lock();
+	nvdev = rtnl_dereference(ndevctx->nvdev);
+	if (nvdev)
+		rdev = nvdev->extension;
+
+		if (rdev) {
+			if (ndev->flags & IFF_PROMISC)
+				rndis_filter_set_packet_filter(rdev,
+							       NDIS_PACKET_TYPE_PROMISCUOUS);
+			else
+				rndis_filter_set_packet_filter(rdev,
+							       NDIS_PACKET_TYPE_BROADCAST |
+							       NDIS_PACKET_TYPE_ALL_MULTICAST |
+							       NDIS_PACKET_TYPE_DIRECTED);
+		}
+	}
+	rtnl_unlock();
 }
 
 static void netvsc_set_multicast_list(struct net_device *net)
-- 
2.11.0
