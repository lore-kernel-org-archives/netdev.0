From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 05/12] IB/ipoib: Grab rtnl lock on heavy flush when calling ndo_open/stop
Date: Sat, 14 Oct 2017 11:48:20 -0700
Message-ID: <20171014184827.18491-6-saeedm@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Alex Vesker <valex@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43278 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751634AbdJNSss (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:48:48 -0400
In-Reply-To: <20171014184827.18491-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Vesker <valex@mellanox.com>

When ndo_open and ndo_stop are called RTNL lock should be held.
In this specific case ipoib_ib_dev_open calls the offloaded ndo_open
which re-sets the number of TX queue assuming RTNL lock is held.
Since RTNL lock is not held, RTNL assert will fail.

Signed-off-by: Alex Vesker <valex@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_ib.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 6cd61638b441..c97384c914a4 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -1203,10 +1203,15 @@ static void __ipoib_ib_dev_flush(struct ipoib_dev_priv *priv,
 		ipoib_ib_dev_down(dev);
 
 	if (level == IPOIB_FLUSH_HEAVY) {
+		rtnl_lock();
 		if (test_bit(IPOIB_FLAG_INITIALIZED, &priv->flags))
 			ipoib_ib_dev_stop(dev);
-		if (ipoib_ib_dev_open(dev) != 0)
+
+		result = ipoib_ib_dev_open(dev);
+		rtnl_unlock();
+		if (result)
 			return;
+
 		if (netif_queue_stopped(dev))
 			netif_start_queue(dev);
 	}
-- 
2.14.2
