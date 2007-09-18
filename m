From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 1/2] IPoIB: Fix unregister_netdev hang
Date: Tue, 18 Sep 2007 16:48:03 +0530
Message-ID: <20070918111803.1769.60619.sendpatchset@localhost.localdomain>
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

While using IPoIB over EHCA (rc6 bits), unregister_netdev hangs with
the message: "waiting for ib2 to become free.  Usage count = -515276",
etc.

The problem is that the poll handler does netif_rx_complete (which
does a dev_put) followed by netif_rx_reschedule() to schedule for
more receives (which again does a dev_put). This reduces refcount to
< 0 (depending on how many times netif_rx_complete followed by
netif_rx_reschedule was called).

The following patch fixes the bug, but I don't know if there is some
specific IB issue that prevents this approach.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_ib.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_ib.c new1/drivers/infiniband/ulp/ipoib/ipoib_ib.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-09-18 15:50:09.000000000 +0530
+++ new1/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-09-18 16:14:20.000000000 +0530
@@ -291,7 +291,6 @@ int ipoib_poll(struct napi_struct *napi,
 
 	done  = 0;
 
-poll_more:
 	while (done < budget) {
 		int max = (budget - done);
 
@@ -316,12 +315,10 @@ poll_more:
 	}
 
 	if (done < budget) {
-		netif_rx_complete(dev, napi);
-		if (unlikely(ib_req_notify_cq(priv->cq,
-					      IB_CQ_NEXT_COMP |
-					      IB_CQ_REPORT_MISSED_EVENTS)) &&
-		    netif_rx_reschedule(napi))
-			goto poll_more;
+		if (likely(!ib_req_notify_cq(priv->cq,
+					     IB_CQ_NEXT_COMP |
+					     IB_CQ_REPORT_MISSED_EVENTS)))
+			netif_rx_complete(dev, napi);
 	}
 
 	return done;
