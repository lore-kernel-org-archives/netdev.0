From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 17/18] liquidio: CN23XX napi support
Date: Fri, 12 Aug 2016 11:20:34 -0700
Message-ID: <1471026035-15323-18-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0082.outbound.protection.outlook.com ([104.47.41.82]:55592
	"EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751154AbcHLS4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 14:56:09 -0400
In-Reply-To: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds NAPI related support for cn23xx device.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c      | 10 ++++++----
 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 19 +++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c   |  7 +++++--
 3 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index e05fad4..a5ba8f6 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -999,8 +999,7 @@ int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
  * \brief Droq packet processor sceduler
  * @param oct octeon device
  */
-static
-void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
+static void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
 {
 	struct octeon_device_priv *oct_priv =
 		(struct octeon_device_priv *)oct->priv;
@@ -2372,11 +2371,14 @@ static void napi_schedule_wrapper(void *param)
  */
 static void liquidio_napi_drv_callback(void *arg)
 {
+	struct octeon_device *oct;
 	struct octeon_droq *droq = arg;
 	int this_cpu = smp_processor_id();
 
-	if (droq->cpu_id == this_cpu) {
-		napi_schedule(&droq->napi);
+	oct = droq->oct_dev;
+
+	if (OCTEON_CN23XX_PF(oct) || droq->cpu_id == this_cpu) {
+		napi_schedule_irqoff(&droq->napi);
 	} else {
 		struct call_single_data *csd = &droq->csd;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 85e3123..586b688 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -1301,17 +1301,36 @@ int lio_get_device_id(void *dev)
 
 void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq)
 {
+	u64 instr_cnt;
+	struct octeon_device *oct = NULL;
+
 	/* the whole thing needs to be atomic, ideally */
 	if (droq) {
 		spin_lock_bh(&droq->lock);
 		writel(droq->pkt_count, droq->pkts_sent_reg);
 		droq->pkt_count = 0;
 		spin_unlock_bh(&droq->lock);
+		oct = droq->oct_dev;
 	}
 	if (iq) {
 		spin_lock_bh(&iq->lock);
 		writel(iq->pkt_in_done, iq->inst_cnt_reg);
 		iq->pkt_in_done = 0;
 		spin_unlock_bh(&iq->lock);
+		oct = iq->oct_dev;
+	}
+	/*write resend. Writing RESEND in SLI_PKTX_CNTS should be enough
+	 *to trigger tx interrupts as well, if they are pending.
+	 */
+	if (oct && OCTEON_CN23XX_PF(oct)) {
+		if (droq)
+			writeq(CN23XX_INTR_RESEND, droq->pkts_sent_reg);
+		/*we race with firmrware here. read and write the IN_DONE_CNTS*/
+		else if (iq) {
+			instr_cnt =  readq(iq->inst_cnt_reg);
+			writeq(((instr_cnt & 0xFFFFFFFF00000000ULL) |
+				CN23XX_INTR_RESEND),
+			       iq->inst_cnt_reg);
+		}
 	}
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 8848ce2..f60e532 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -573,7 +573,7 @@ octeon_droq_dispatch_pkt(struct octeon_device *oct,
 			(unsigned int)rh->r.opcode,
 			(unsigned int)rh->r.subcode);
 		droq->stats.dropped_nodispatch++;
-	}                       /* else (dispatch_fn ... */
+	}
 
 	return cnt;
 }
@@ -887,8 +887,11 @@ octeon_process_droq_poll_cmd(struct octeon_device *oct, u32 q_no, int cmd,
 			return 0;
 		}
 		break;
+		case OCTEON_CN23XX_PF_VID: {
+			lio_enable_irq(oct->droq[q_no], oct->instr_queue[q_no]);
+		}
+		break;
 		}
-
 		return 0;
 	}
 
-- 
1.8.3.1
