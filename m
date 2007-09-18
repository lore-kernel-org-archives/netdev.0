From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 2/2] IPoIB: Code cleanup
Date: Tue, 18 Sep 2007 16:48:17 +0530
Message-ID: <20070918111817.1769.1042.sendpatchset@localhost.localdomain>
References: <20070918111803.1769.60619.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, davem@davemloft.net, general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070918111803.1769.60619.sendpatchset@localhost.localdomain>
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

Follow-up cleanup and "while loop" optimization in the poll handler.
net_rx_action guarantees that 'budget' is atleast 1.

Note: This could also be done for poll handlers of other drivers.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_ib.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff -ruNp new1/drivers/infiniband/ulp/ipoib/ipoib_ib.c new2/drivers/infiniband/ulp/ipoib/ipoib_ib.c
--- new1/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-09-18 16:14:20.000000000 +0530
+++ new2/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-09-18 16:31:42.000000000 +0530
@@ -285,19 +285,16 @@ int ipoib_poll(struct napi_struct *napi,
 {
 	struct ipoib_dev_priv *priv = container_of(napi, struct ipoib_dev_priv, napi);
 	struct net_device *dev = priv->dev;
-	int done;
-	int t;
-	int n, i;
+	int num_wc, max_wc;
+	int done = 0;
 
-	done  = 0;
-
-	while (done < budget) {
-		int max = (budget - done);
+	do {
+		int i;
 
-		t = min(IPOIB_NUM_WC, max);
-		n = ib_poll_cq(priv->cq, t, priv->ibwc);
+		max_wc = min(IPOIB_NUM_WC, budget - done);
+		num_wc = ib_poll_cq(priv->cq, max_wc, priv->ibwc);
 
-		for (i = 0; i < n; i++) {
+		for (i = 0; i < num_wc; i++) {
 			struct ib_wc *wc = priv->ibwc + i;
 
 			if (wc->wr_id & IPOIB_CM_OP_SRQ) {
@@ -309,10 +306,7 @@ int ipoib_poll(struct napi_struct *napi,
 			} else
 				ipoib_ib_handle_tx_wc(dev, wc);
 		}
-
-		if (n != t)
-			break;
-	}
+	} while (num_wc == max_wc && done < budget);
 
 	if (done < budget) {
 		if (likely(!ib_req_notify_cq(priv->cq,
