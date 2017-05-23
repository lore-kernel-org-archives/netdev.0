From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/5] xfrm: Fix NETDEV_DOWN with IPSec offload
Date: Tue, 23 May 2017 07:33:43 +0200
Message-ID: <1495517624-27096-5-git-send-email-steffen.klassert@secunet.com>
References: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45154 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934700AbdEWFdy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 01:33:54 -0400
In-Reply-To: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
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
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 8ec8a3f..574e6f3 100644
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
2.7.4
