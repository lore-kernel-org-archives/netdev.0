From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 2/6] enic: Bug fix: try harder to fill Rx ring on skb
	allocation failures
Date: Wed, 23 Dec 2009 15:27:38 -0800
Message-ID: <20091223232738.19428.91548.stgit@savbu-pc100.cisco.com>
References: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:6154 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757098AbZLWX1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:27:38 -0500
In-Reply-To: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

During dev->open(), make sure we get at least one skb on the Rx ring. 
Otherwise abort the interface load.  Also, if we get skb allocation
failures in NAPI poll while trying to replenish the ring, try again
later so we don't end up starving out the Rx ring completely.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |   54 ++++++++++++++++++++++++++----------------
 1 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index b4a11be..452a6b7 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1091,6 +1091,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 	unsigned int rq_work_to_do = budget;
 	unsigned int wq_work_to_do = -1; /* no limit */
 	unsigned int  work_done, rq_work_done, wq_work_done;
+	int err;
 
 	/* Service RQ (first) and WQ
 	 */
@@ -1114,16 +1115,19 @@ static int enic_poll(struct napi_struct *napi, int budget)
 			0 /* don't unmask intr */,
 			0 /* don't reset intr timer */);
 
-	if (rq_work_done > 0) {
+	err = vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
 
-		/* Replenish RQ
-		 */
+	/* Buffer allocation failed. Stay in polling
+	 * mode so we can try to fill the ring again.
+	 */
 
-		vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
+	if (err)
+		rq_work_done = rq_work_to_do;
 
-	} else {
+	if (rq_work_done < rq_work_to_do) {
 
-		/* If no work done, flush all LROs and exit polling
+		/* Some work done, but not enough to stay in polling,
+		 * flush all LROs and exit polling
 		 */
 
 		if (netdev->features & NETIF_F_LRO)
@@ -1142,6 +1146,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 	struct net_device *netdev = enic->netdev;
 	unsigned int work_to_do = budget;
 	unsigned int work_done;
+	int err;
 
 	/* Service RQ
 	 */
@@ -1149,25 +1154,30 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 	work_done = vnic_cq_service(&enic->cq[ENIC_CQ_RQ],
 		work_to_do, enic_rq_service, NULL);
 
-	if (work_done > 0) {
-
-		/* Replenish RQ
-		 */
-
-		vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
-
-		/* Return intr event credits for this polling
-		 * cycle.  An intr event is the completion of a
-		 * RQ packet.
-		 */
+	/* Return intr event credits for this polling
+	 * cycle.  An intr event is the completion of a
+	 * RQ packet.
+	 */
 
+	if (work_done > 0)
 		vnic_intr_return_credits(&enic->intr[ENIC_MSIX_RQ],
 			work_done,
 			0 /* don't unmask intr */,
 			0 /* don't reset intr timer */);
-	} else {
 
-		/* If no work done, flush all LROs and exit polling
+	err = vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
+
+	/* Buffer allocation failed. Stay in polling mode
+	 * so we can try to fill the ring again.
+	 */
+
+	if (err)
+		work_done = work_to_do;
+
+	if (work_done < work_to_do) {
+
+		/* Some work done, but not enough to stay in polling,
+		 * flush all LROs and exit polling
 		 */
 
 		if (netdev->features & NETIF_F_LRO)
@@ -1350,11 +1360,13 @@ static int enic_open(struct net_device *netdev)
 	}
 
 	for (i = 0; i < enic->rq_count; i++) {
-		err = vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
-		if (err) {
+		vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
+		/* Need at least one buffer on ring to get going */
+		if (vnic_rq_desc_used(&enic->rq[i]) == 0) {
 			printk(KERN_ERR PFX
 				"%s: Unable to alloc receive buffers.\n",
 				netdev->name);
+			err = -ENOMEM;
 			goto err_out_notify_unset;
 		}
 	}

