From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH net-2.6.24] eHEA: poll function update for new NAPI scheme
Date: Wed, 19 Sep 2007 17:40:30 +0200
Message-ID: <200709191740.30640.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:9870 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbXISPkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 11:40:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update of ehea_poll function to work with new NAPI scheme.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
Hi David,

this patch is built upon the patches provided by Mel Gorman
(2.6.23-rc6-mm1: Build failure on ppc64 drivers/net/ehea/ehea_main.c)
and Roland Dreier 
([PATCH net-2.6.24] Fix refcounting problem with netif_rx_reschedule())


 drivers/net/ehea/ehea_main.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index c5fc0b1..1bb39a7 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -609,6 +609,7 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 }
 
 #define EHEA_NAPI_POLL_NUM_BEFORE_IRQ 16
+#define EHEA_POLL_MAX_CQES 65535
 
 static int ehea_poll(struct napi_struct *napi, int budget)
 {
@@ -616,15 +617,18 @@ static int ehea_poll(struct napi_struct *napi, int budget)
 	struct net_device *dev = pr->port->netdev;
 	struct ehea_cqe *cqe;
 	struct ehea_cqe *cqe_skb = NULL;
-	int force_irq, wqe_index, rx;
-
-	cqe = ehea_poll_rq1(pr->qp, &wqe_index);
-	cqe_skb = ehea_poll_cq(pr->send_cq);
+	int force_irq, wqe_index;
+	int rx = 0;
 
 	force_irq = (pr->poll_counter > EHEA_NAPI_POLL_NUM_BEFORE_IRQ);
+	cqe_skb = ehea_proc_cqes(pr, EHEA_POLL_MAX_CQES);
+
+	if (!force_irq)
+		rx += ehea_proc_rwqes(dev, pr, budget - rx);
 
-	if ((!cqe && !cqe_skb) || force_irq) {
+	while ((rx != budget) || force_irq) {
 		pr->poll_counter = 0;
+		force_irq = 0;
 		netif_rx_complete(dev, napi);
 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_ep(pr->send_cq);
@@ -634,19 +638,16 @@ static int ehea_poll(struct napi_struct *napi, int budget)
 		cqe_skb = ehea_poll_cq(pr->send_cq);
 
 		if (!cqe && !cqe_skb)
-			return 0;
+			return rx;
 
 		if (!netif_rx_reschedule(dev, napi))
-			return 0;
-	}
+			return rx;
 
-	rx = ehea_proc_rwqes(dev, pr, budget);
-	cqe = ehea_poll_rq1(pr->qp, &wqe_index);
-	cqe_skb = ehea_proc_cqes(pr, 300);
-
-	if (cqe || cqe_skb)
-		pr->poll_counter++;
+		cqe_skb = ehea_proc_cqes(pr, EHEA_POLL_MAX_CQES);
+		rx += ehea_proc_rwqes(dev, pr, budget - rx);
+	}
 
+	pr->poll_counter++;
 	return rx;
 }
 
-- 
1.5.2

