From: <ilant@mellanox.com>
Subject: [PATCH net] xfrm: Fix NETDEV_DOWN with IPSec offload
Date: Mon, 8 May 2017 10:30:18 +0300
Message-ID: <20170508073018.27380-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Boris Pismenny <borisp@mellanox.com>, <netdev@vger.kernel.org>,
        Ilan Tayari <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0080.outbound.protection.outlook.com ([104.47.2.80]:60672
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752610AbdEHHac (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 03:30:32 -0400
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
