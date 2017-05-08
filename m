From: <ilant@mellanox.com>
Subject: [PATCH net v2 1/1] xfrm: Fix NETDEV_DOWN with IPSec offload
Date: Mon, 8 May 2017 10:39:34 +0300
Message-ID: <20170508073934.28529-2-ilant@mellanox.com>
References: <20170508073934.28529-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Boris Pismenny <borisp@mellanox.com>, <netdev@vger.kernel.org>,
        Ilan Tayari <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00087.outbound.protection.outlook.com ([40.107.0.87]:15232
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752321AbdEHHjs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 03:39:48 -0400
In-Reply-To: <20170508073934.28529-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Upon NETDEV_DOWN event, all xfrm_state objects which are bound to
the device are flushed.

The condition for this is wrong, though, testing dev->hw_features
instead of dev->features. If a device has non-user-modifiable
NETIF_F_HW_ESP, then its xfrm_state objects are not flushed,
causing a crash later on after the device is deleted.

Check dev->features instead of dev->hw_features.

Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 8ec8a3fcf8d4..574e6f32f94f 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -170,7 +170,7 @@ static int xfrm_dev_feat_change(struct net_device *dev)
 
 static int xfrm_dev_down(struct net_device *dev)
 {
-	if (dev->hw_features & NETIF_F_HW_ESP)
+	if (dev->features & NETIF_F_HW_ESP)
 		xfrm_dev_state_flush(dev_net(dev), dev, true);
 
 	xfrm_garbage_collect(dev_net(dev));
-- 
2.11.0
