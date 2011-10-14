From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 03/15] ehea: Remove force_irq logic in napi poll routine
Date: Fri, 14 Oct 2011 12:31:00 -0300
Message-ID: <1318606272-27647-4-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:55100 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933200Ab1JNPbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:42 -0400
Received: from /spool/local
	by br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 14 Oct 2011 12:31:41 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFUDmD3211326
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:30:13 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVUge008548
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:30 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

commit 18604c548545 (ehea: NAPI multi queue TX/RX path for SMP) added
driver specific logic for exiting napi mode. I'm not sure what it was
trying to solve and it should be up to the network stack to decide when
we are done polling so remove it.

v3:
[cascardo] Fixed extra parentheses.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea.h      |    1 -
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   13 +++----------
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
index e247927..4a4d466 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea.h
@@ -383,7 +383,6 @@ struct ehea_port_res {
 	u64 tx_bytes;
 	u64 rx_packets;
 	u64 rx_bytes;
-	u32 poll_counter;
 	struct net_lro_mgr lro_mgr;
 	struct net_lro_desc lro_desc[MAX_LRO_DESCRIPTORS];
 	int sq_restart_flag;
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index a6c4192..4032a0a 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -926,7 +926,6 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 	return cqe;
 }
 
-#define EHEA_NAPI_POLL_NUM_BEFORE_IRQ 16
 #define EHEA_POLL_MAX_CQES 65535
 
 static int ehea_poll(struct napi_struct *napi, int budget)
@@ -936,18 +935,13 @@ static int ehea_poll(struct napi_struct *napi, int budget)
 	struct net_device *dev = pr->port->netdev;
 	struct ehea_cqe *cqe;
 	struct ehea_cqe *cqe_skb = NULL;
-	int force_irq, wqe_index;
+	int wqe_index;
 	int rx = 0;
 
-	force_irq = (pr->poll_counter > EHEA_NAPI_POLL_NUM_BEFORE_IRQ);
 	cqe_skb = ehea_proc_cqes(pr, EHEA_POLL_MAX_CQES);
+	rx += ehea_proc_rwqes(dev, pr, budget - rx);
 
-	if (!force_irq)
-		rx += ehea_proc_rwqes(dev, pr, budget - rx);
-
-	while ((rx != budget) || force_irq) {
-		pr->poll_counter = 0;
-		force_irq = 0;
+	while (rx != budget) {
 		napi_complete(napi);
 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_ep(pr->send_cq);
@@ -967,7 +961,6 @@ static int ehea_poll(struct napi_struct *napi, int budget)
 		rx += ehea_proc_rwqes(dev, pr, budget - rx);
 	}
 
-	pr->poll_counter++;
 	return rx;
 }
 
-- 
1.7.4.4
