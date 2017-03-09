From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next v2 08/10] dpaa_eth: add four prioritised Tx traffic classes
Date: Thu, 9 Mar 2017 16:37:03 +0200
Message-ID: <1489070225-7891-9-git-send-email-madalin.bucur@nxp.com>
References: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@nxp.com>, linux-kernel@vger.kernel.org,
 camelia.groza@nxp.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
 dan.carpenter@oracle.com
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1489070225-7891-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

From: Camelia Groza <camelia.groza@nxp.com>

Each traffic class corresponds to a WQ priority level. The number of Tx
netdev queues and frame queues is increased to NR_CPUS queues for each
traffic class. In addition, the priority of the Rx, Error and Conf queues
is lowered but their order is maintained.

By default, only one traffic class is enabled, only the low priority Tx
queues are used and only the corresponding netdev queues are advertised.

Signed-off-by: Camelia Groza <camelia.groza@nxp.com>
Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 43 +++++++++++++++++++++-----
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h |  8 ++++-
 2 files changed, 42 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index ae64cdb..ac75d09 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -565,16 +565,18 @@ static void dpaa_bps_free(struct dpaa_priv *priv)
 
 /* Use multiple WQs for FQ assignment:
  *	- Tx Confirmation queues go to WQ1.
- *	- Rx Error and Tx Error queues go to WQ2 (giving them a better chance
- *	  to be scheduled, in case there are many more FQs in WQ3).
- *	- Rx Default and Tx queues go to WQ3 (no differentiation between
- *	  Rx and Tx traffic).
+ *	- Rx Error and Tx Error queues go to WQ5 (giving them a better chance
+ *	  to be scheduled, in case there are many more FQs in WQ6).
+ *	- Rx Default goes to WQ6.
+ *	- Tx queues go to different WQs depending on their priority. Equal
+ *	  chunks of NR_CPUS queues go to WQ6 (lowest priority), WQ2, WQ1 and
+ *	  WQ0 (highest priority).
  * This ensures that Tx-confirmed buffers are timely released. In particular,
  * it avoids congestion on the Tx Confirm FQs, which can pile up PFDRs if they
  * are greatly outnumbered by other FQs in the system, while
  * dequeue scheduling is round-robin.
  */
-static inline void dpaa_assign_wq(struct dpaa_fq *fq)
+static inline void dpaa_assign_wq(struct dpaa_fq *fq, int idx)
 {
 	switch (fq->fq_type) {
 	case FQ_TYPE_TX_CONFIRM:
@@ -583,11 +585,33 @@ static inline void dpaa_assign_wq(struct dpaa_fq *fq)
 		break;
 	case FQ_TYPE_RX_ERROR:
 	case FQ_TYPE_TX_ERROR:
-		fq->wq = 2;
+		fq->wq = 5;
 		break;
 	case FQ_TYPE_RX_DEFAULT:
+		fq->wq = 6;
+		break;
 	case FQ_TYPE_TX:
-		fq->wq = 3;
+		switch (idx / DPAA_TC_TXQ_NUM) {
+		case 0:
+			/* Low priority (best effort) */
+			fq->wq = 6;
+			break;
+		case 1:
+			/* Medium priority */
+			fq->wq = 2;
+			break;
+		case 2:
+			/* High priority */
+			fq->wq = 1;
+			break;
+		case 3:
+			/* Very high priority */
+			fq->wq = 0;
+			break;
+		default:
+			WARN(1, "Too many TX FQs: more than %d!\n",
+			     DPAA_ETH_TXQ_NUM);
+		}
 		break;
 	default:
 		WARN(1, "Invalid FQ type %d for FQID %d!\n",
@@ -615,7 +639,7 @@ static struct dpaa_fq *dpaa_fq_alloc(struct device *dev,
 	}
 
 	for (i = 0; i < count; i++)
-		dpaa_assign_wq(dpaa_fq + i);
+		dpaa_assign_wq(dpaa_fq + i, i);
 
 	return dpaa_fq;
 }
@@ -2683,6 +2707,9 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 		memset(percpu_priv, 0, sizeof(*percpu_priv));
 	}
 
+	priv->num_tc = 1;
+	netif_set_real_num_tx_queues(net_dev, priv->num_tc * DPAA_TC_TXQ_NUM);
+
 	/* Initialize NAPI */
 	err = dpaa_napi_add(net_dev);
 	if (err < 0)
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
index 1f9aebf..9941a78 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -39,7 +39,12 @@
 #include "mac.h"
 #include "dpaa_eth_trace.h"
 
-#define DPAA_ETH_TXQ_NUM	NR_CPUS
+/* Number of prioritised traffic classes */
+#define DPAA_TC_NUM		4
+/* Number of Tx queues per traffic class */
+#define DPAA_TC_TXQ_NUM		NR_CPUS
+/* Total number of Tx queues */
+#define DPAA_ETH_TXQ_NUM	(DPAA_TC_NUM * DPAA_TC_TXQ_NUM)
 
 #define DPAA_BPS_NUM 3 /* number of bpools per interface */
 
@@ -152,6 +157,7 @@ struct dpaa_priv {
 	u16 channel;
 	struct list_head dpaa_fq_list;
 
+	u8 num_tc;
 	u32 msg_enable;	/* net_device message level */
 
 	struct {
-- 
2.1.0
