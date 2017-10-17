From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH] macvlan/macvtap: Add support for L2 forwarding
 offloads with macvtap
Date: Mon, 16 Oct 2017 22:44:44 -0400
Message-ID: <20171017024428.28589.73728.stgit@ahduyck-green-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:9601 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754194AbdJQCsA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 22:48:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reverts earlier commit b13ba1b83f52 ("macvlan: forbid L2
fowarding offload for macvtap"). The reason for reverting this is because
the original patch no longer fixes what it previously did as the
underlying structure has changed for macvtap. Specifically macvtap
originally pulled packets directly off of the lowerdev. However in commit
6acf54f1cf0a ("macvtap: Add support of packet capture on macvtap device.")
that code was changed and instead macvtap would listen directly on the
macvtap device itself instead of the lower device. As such, the L2
forwarding offload should now be able to provide a performance advantage of
skipping the checks on the lower dev while not introducing any sort of
regression.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/macvlan.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 858bd66..cfeb0ee 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -596,8 +596,6 @@ static int macvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 	.cache_update	= eth_header_cache_update,
 };
 
-static struct rtnl_link_ops macvlan_link_ops;
-
 static int macvlan_open(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
@@ -613,8 +611,7 @@ static int macvlan_open(struct net_device *dev)
 		goto hash_add;
 	}
 
-	if (lowerdev->features & NETIF_F_HW_L2FW_DOFFLOAD &&
-	    dev->rtnl_link_ops == &macvlan_link_ops) {
+	if (lowerdev->features & NETIF_F_HW_L2FW_DOFFLOAD) {
 		vlan->fwd_priv =
 		      lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev, dev);
 
