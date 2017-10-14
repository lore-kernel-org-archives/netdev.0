From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 06/12] IB/ipoib: Add ability to set PKEY index to lower device driver
Date: Sat, 14 Oct 2017 11:48:21 -0700
Message-ID: <20171014184827.18491-7-saeedm@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Alex Vesker <valex@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43320 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751659AbdJNSsu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:48:50 -0400
In-Reply-To: <20171014184827.18491-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Vesker <valex@mellanox.com>

To support passing child interfaces to the lower device a new
rdma_netdev function was used, set_id. This will allow us to
attach the PKEY index lower device resources such as TIS/QP.
For devices that do not support offloads in IPoIB same logic
will be used, setting the PKEY index to priv struct.

Signed-off-by: Alex Vesker <valex@mellanox.com>
Reviewed-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_ib.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index c97384c914a4..fe690f82af29 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -893,13 +893,17 @@ int ipoib_ib_dev_open(struct net_device *dev)
 void ipoib_pkey_dev_check_presence(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
 
 	if (!(priv->pkey & 0x7fff) ||
 	    ib_find_pkey(priv->ca, priv->port, priv->pkey,
-			 &priv->pkey_index))
+			 &priv->pkey_index)) {
 		clear_bit(IPOIB_PKEY_ASSIGNED, &priv->flags);
-	else
+	} else {
+		if (rn->set_id)
+			rn->set_id(dev, priv->pkey_index);
 		set_bit(IPOIB_PKEY_ASSIGNED, &priv->flags);
+	}
 }
 
 void ipoib_ib_dev_up(struct net_device *dev)
-- 
2.14.2
