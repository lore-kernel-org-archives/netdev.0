From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH] IPoIB: Optimizations in poll handler.
Date: Tue, 18 Sep 2007 17:09:16 +0530
Message-ID: <20070918113916.2065.14065.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, davem@davemloft.net, general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Final follow-up optimizations: If the poll loop executes more than
once (and it happens on my system with two flood pings):
	- no need to calculate "budget - done" on every iteration (but
		will require to do this once, when returning from fn)
	- check for one variable being non-zero instead of comparing two
		vars for every iteration.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_ib.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff -ruNp new2/drivers/infiniband/ulp/ipoib/ipoib_ib.c new3/drivers/infiniband/ulp/ipoib/ipoib_ib.c
--- new2/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-09-18 16:31:42.000000000 +0530
+++ new3/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-09-18 17:01:44.000000000 +0530
@@ -286,36 +286,37 @@ int ipoib_poll(struct napi_struct *napi,
 	struct ipoib_dev_priv *priv = container_of(napi, struct ipoib_dev_priv, napi);
 	struct net_device *dev = priv->dev;
 	int num_wc, max_wc;
-	int done = 0;
+	int remaining = budget;
 
 	do {
 		int i;
 
-		max_wc = min(IPOIB_NUM_WC, budget - done);
+		max_wc = min(IPOIB_NUM_WC, remaining);
 		num_wc = ib_poll_cq(priv->cq, max_wc, priv->ibwc);
 
 		for (i = 0; i < num_wc; i++) {
 			struct ib_wc *wc = priv->ibwc + i;
 
 			if (wc->wr_id & IPOIB_CM_OP_SRQ) {
-				++done;
+				--remaining;
 				ipoib_cm_handle_rx_wc(dev, wc);
 			} else if (wc->wr_id & IPOIB_OP_RECV) {
-				++done;
+				--remaining;
 				ipoib_ib_handle_rx_wc(dev, wc);
 			} else
 				ipoib_ib_handle_tx_wc(dev, wc);
 		}
-	} while (num_wc == max_wc && done < budget);
+	} while (num_wc == max_wc && remaining);
 
-	if (done < budget) {
+	if (remaining) {
 		if (likely(!ib_req_notify_cq(priv->cq,
 					     IB_CQ_NEXT_COMP |
 					     IB_CQ_REPORT_MISSED_EVENTS)))
 			netif_rx_complete(dev, napi);
 	}
 
-	return done;
+	/* return number of receives processed */
+	return budget - remaining;
 }
 
 void ipoib_ib_completion(struct ib_cq *cq, void *dev_ptr)
