From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/5] cxgb4: Don't call t4_slow_intr_handler when we're not the Master PF
Date: Wed, 15 Apr 2015 02:02:34 +0530
Message-ID: <1429043554-8744-6-git-send-email-hariprasad@chelsio.com>
References: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4081 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753818AbbDNPUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:20:47 -0400
In-Reply-To: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 3 ++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5892706..4e00bea 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -724,7 +724,8 @@ static irqreturn_t t4_nondata_intr(int irq, void *cookie)
 		adap->swintr = 1;
 		t4_write_reg(adap, MYPF_REG(PL_PF_INT_CAUSE_A), v);
 	}
-	t4_slow_intr_handler(adap);
+	if (adap->flags & MASTER_PF)
+		t4_slow_intr_handler(adap);
 	return IRQ_HANDLED;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 1a31e40..0d2edda 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2238,7 +2238,8 @@ static irqreturn_t t4_intr_msi(int irq, void *cookie)
 {
 	struct adapter *adap = cookie;
 
-	t4_slow_intr_handler(adap);
+	if (adap->flags & MASTER_PF)
+		t4_slow_intr_handler(adap);
 	process_intrq(adap);
 	return IRQ_HANDLED;
 }
@@ -2253,7 +2254,8 @@ static irqreturn_t t4_intr_intx(int irq, void *cookie)
 	struct adapter *adap = cookie;
 
 	t4_write_reg(adap, MYPF_REG(PCIE_PF_CLI_A), 0);
-	if (t4_slow_intr_handler(adap) | process_intrq(adap))
+	if (((adap->flags & MASTER_PF) && t4_slow_intr_handler(adap)) |
+	    process_intrq(adap))
 		return IRQ_HANDLED;
 	return IRQ_NONE;             /* probably shared interrupt */
 }
-- 
2.3.4
