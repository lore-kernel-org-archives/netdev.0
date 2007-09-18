From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH net-2.6.24] Fix refcounting problem with netif_rx_reschedule()
Date: Tue, 18 Sep 2007 10:58:37 -0700
Message-ID: <adawsunkg8i.fsf@cisco.com>
References: <20070918111803.1769.60619.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar <krkumar2@in.ibm.com>, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2-in.cisco.com ([171.71.176.71]:36549 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174AbXIRR71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 13:59:27 -0400
In-Reply-To: <20070918111803.1769.60619.sendpatchset@localhost.localdomain> (Krishna Kumar's message of "Tue, 18 Sep 2007 16:48:03 +0530")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netif_rx_complete() takes a netdev parameter and does dev_put() on
that netdev, so netif_rx_reschedule() needs to also take a netdev
parameter and do dev_hold() on it to avoid reference counts from
getting becoming negative because of unbalanced dev_put()s.

This should fix the problem reported by Krishna Kumar
<krkumar2@in.ibm.com> with IPoIB waiting forever for netdev refcounts
to become 0 during module unload.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
Dave, feel free to roll this up into earlier NAPI conversion patches
(assuming I'm understanding things correctly and this patch actually
makes sense!).

BTW, it looks like drivers/net/ibm_emac/ibm_emac_mal.c would not have 
built in the current net-2.6.24 tree, since its call to
netif_rx_reschedule() was left with the netdev parameter.  So that
file does not need to be touched in this patch.

 drivers/infiniband/ulp/ipoib/ipoib_ib.c |    2 +-
 drivers/net/arm/ep93xx_eth.c            |    2 +-
 drivers/net/ehea/ehea_main.c            |    2 +-
 drivers/net/ibmveth.c                   |    2 +-
 include/linux/netdevice.h               |   21 +++++++++++----------
 5 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 6a2bff4..481e4b6 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -320,7 +320,7 @@ poll_more:
 		if (unlikely(ib_req_notify_cq(priv->cq,
 					      IB_CQ_NEXT_COMP |
 					      IB_CQ_REPORT_MISSED_EVENTS)) &&
-		    netif_rx_reschedule(napi))
+		    netif_rx_reschedule(dev, napi))
 			goto poll_more;
 	}
 
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index f3858d1..7f016f3 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -309,7 +309,7 @@ poll_some_more:
 		}
 		spin_unlock_irq(&ep->rx_lock);
 
-		if (more && netif_rx_reschedule(napi))
+		if (more && netif_rx_reschedule(dev, napi))
 			goto poll_some_more;
 	}
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 4a5ab4a..9a499f4 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -636,7 +636,7 @@ static int ehea_poll(struct napi_struct *napi, int budget)
 		if (!cqe && !cqe_skb)
 			return 0;
 
-		if (!netif_rx_reschedule(napi))
+		if (!netif_rx_reschedule(dev, napi))
 			return 0;
 	}
 
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index b8d7cec..b94f266 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -973,7 +973,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 		netif_rx_complete(netdev, napi);
 
 		if (ibmveth_rxq_pending_buffer(adapter) &&
-		    netif_rx_reschedule(napi)) {
+		    netif_rx_reschedule(netdev, napi)) {
 			lpar_rc = h_vio_signal(adapter->vdev->unit_address,
 					       VIO_IRQ_DISABLE);
 			goto restart_poll;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index be5fe05..0dbf185 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1198,16 +1198,6 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
 	return (1 << debug_value) - 1;
 }
 
-/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().  */
-static inline int netif_rx_reschedule(struct napi_struct *n)
-{
-	if (napi_schedule_prep(n)) {
-		__napi_schedule(n);
-		return 1;
-	}
-	return 0;
-}
-
 /* Test if receive needs to be scheduled but only if up */
 static inline int netif_rx_schedule_prep(struct net_device *dev,
 					 struct napi_struct *napi)
@@ -1234,6 +1224,17 @@ static inline void netif_rx_schedule(struct net_device *dev,
 		__netif_rx_schedule(dev, napi);
 }
 
+/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().  */
+static inline int netif_rx_reschedule(struct net_device *dev,
+				      struct napi_struct *napi)
+{
+	if (napi_schedule_prep(napi)) {
+		__netif_rx_schedule(dev, napi);
+		return 1;
+	}
+	return 0;
+}
+
 /* same as netif_rx_complete, except that local_irq_save(flags)
  * has already been issued
  */
