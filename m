From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: Implement "Unhandled Interrupts" statistic
Date: Thu, 8 Jul 2010 11:07:44 -0700
Message-ID: <201007081107.45287.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10047 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab0GHSRQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 14:17:16 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o68IHHrn004561
	for <netdev@vger.kernel.org>; Thu, 8 Jul 2010 11:17:17 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 6c9cc1b5441afb32ecfcd10ac3060452e3c4df6f Mon Sep 17 00:00:00 2001
From: Casey Leedom <leedom@chelsio.com>
Date: Thu, 8 Jul 2010 10:05:48 -0700
Subject: [PATCH net-next] cxgb4vf: Implement "Unhandled Interrupts" statistic

Implement "Unhandled Interrupts" statistic so we can detect when the
hardware tells us that it things we have work to do but we don't find
anything ...

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |    8 +++++---
 drivers/net/cxgb4vf/sge.c          |    3 +++
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index bd73ff5..e988031 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1790,7 +1790,7 @@ static int sge_qstats_show(struct seq_file *seq, void *v)
 		  (rxq[qs].rspq.netdev
 		   ? rxq[qs].rspq.netdev->name
 		   : "N/A"));
-		R3("u", "RspQNullInts", rspq.unhandled_irqs);
+		R3("u", "RspQNullInts:", rspq.unhandled_irqs);
 		R("RxPackets:", stats.pkts);
 		R("RxCSO:", stats.rx_cso);
 		R("VLANxtract:", stats.vlan_ex);
@@ -1814,14 +1814,16 @@ static int sge_qstats_show(struct seq_file *seq, void *v)
 		const struct sge_rspq *evtq = &adapter->sge.fw_evtq;
 
 		seq_printf(seq, "%-8s %16s\n", "QType:", "FW event queue");
-		/* no real response queue statistics available to display */
+		seq_printf(seq, "%-16s %8u\n", "RspQNullInts:",
+			   evtq->unhandled_irqs);
 		seq_printf(seq, "%-16s %8u\n", "RspQ CIdx:", evtq->cidx);
 		seq_printf(seq, "%-16s %8u\n", "RspQ Gen:", evtq->gen);
 	} else if (r == 1) {
 		const struct sge_rspq *intrq = &adapter->sge.intrq;
 
 		seq_printf(seq, "%-8s %16s\n", "QType:", "Interrupt Queue");
-		/* no real response queue statistics available to display */
+		seq_printf(seq, "%-16s %8u\n", "RspQNullInts:",
+			   intrq->unhandled_irqs);
 		seq_printf(seq, "%-16s %8u\n", "RspQ CIdx:", intrq->cidx);
 		seq_printf(seq, "%-16s %8u\n", "RspQ Gen:", intrq->gen);
 	}
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index 3a7c02f..5c6663a 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1776,6 +1776,9 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 	} else
 		intr_params = QINTR_TIMER_IDX(SGE_TIMER_UPD_CIDX);
 
+	if (unlikely(work_done == 0))
+		rspq->unhandled_irqs++;
+
 	t4_write_reg(rspq->adapter,
 		     T4VF_SGE_BASE_ADDR + SGE_VF_GTS,
 		     CIDXINC(work_done) |
-- 
1.7.0.4

