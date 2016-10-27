From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 1/3] net: Move functions for configuring traffic
 classes out of inline headers
Date: Thu, 27 Oct 2016 11:40:04 -0400
Message-ID: <20161027154004.13989.63679.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161027153539.13989.14349.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, tom@herbertland.com,
        intel-wired-lan@lists.osuosl.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:5216 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936436AbcJ0Vkt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 17:40:49 -0400
In-Reply-To: <20161027153539.13989.14349.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions for configuring the traffic class to queue mappings have
other effects that need to be addressed.  Instead of trying to export a
bunch of new functions just relocate the functions so that we can
instrument them directly with the functionality they will need.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/netdevice.h |   31 +++----------------------------
 net/core/dev.c            |   29 +++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 458c876..d045432 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1920,34 +1920,9 @@ int netdev_set_prio_tc_map(struct net_device *dev, u8 prio, u8 tc)
 	return 0;
 }
 
-static inline
-void netdev_reset_tc(struct net_device *dev)
-{
-	dev->num_tc = 0;
-	memset(dev->tc_to_txq, 0, sizeof(dev->tc_to_txq));
-	memset(dev->prio_tc_map, 0, sizeof(dev->prio_tc_map));
-}
-
-static inline
-int netdev_set_tc_queue(struct net_device *dev, u8 tc, u16 count, u16 offset)
-{
-	if (tc >= dev->num_tc)
-		return -EINVAL;
-
-	dev->tc_to_txq[tc].count = count;
-	dev->tc_to_txq[tc].offset = offset;
-	return 0;
-}
-
-static inline
-int netdev_set_num_tc(struct net_device *dev, u8 num_tc)
-{
-	if (num_tc > TC_MAX_QUEUE)
-		return -EINVAL;
-
-	dev->num_tc = num_tc;
-	return 0;
-}
+void netdev_reset_tc(struct net_device *dev);
+int netdev_set_tc_queue(struct net_device *dev, u8 tc, u16 count, u16 offset);
+int netdev_set_num_tc(struct net_device *dev, u8 num_tc);
 
 static inline
 int netdev_get_num_tc(struct net_device *dev)
diff --git a/net/core/dev.c b/net/core/dev.c
index f55fb45..d4d45bf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2173,6 +2173,35 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
 EXPORT_SYMBOL(netif_set_xps_queue);
 
 #endif
+void netdev_reset_tc(struct net_device *dev)
+{
+	dev->num_tc = 0;
+	memset(dev->tc_to_txq, 0, sizeof(dev->tc_to_txq));
+	memset(dev->prio_tc_map, 0, sizeof(dev->prio_tc_map));
+}
+EXPORT_SYMBOL(netdev_reset_tc);
+
+int netdev_set_tc_queue(struct net_device *dev, u8 tc, u16 count, u16 offset)
+{
+	if (tc >= dev->num_tc)
+		return -EINVAL;
+
+	dev->tc_to_txq[tc].count = count;
+	dev->tc_to_txq[tc].offset = offset;
+	return 0;
+}
+EXPORT_SYMBOL(netdev_set_tc_queue);
+
+int netdev_set_num_tc(struct net_device *dev, u8 num_tc)
+{
+	if (num_tc > TC_MAX_QUEUE)
+		return -EINVAL;
+
+	dev->num_tc = num_tc;
+	return 0;
+}
+EXPORT_SYMBOL(netdev_set_num_tc);
+
 /*
  * Routine to help set real_num_tx_queues. To avoid skbs mapped to queues
  * greater then real_num_tx_queues stale skbs on the qdisc must be flushed.
