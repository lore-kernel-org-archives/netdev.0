From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 3/14] ehea: Remove force_irq logic in napi poll routine
Date: Tue, 5 Apr 2011 21:30:55 +1000
Message-ID: <20110405213055.757a270a@kryten>
References: <20110405212825.6eb85677@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael@ellerman.id.au
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:55430 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183Ab1DELa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:30:57 -0400
In-Reply-To: <20110405212825.6eb85677@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


commit 18604c548545 (ehea: NAPI multi queue TX/RX path for SMP) added
driver specific logic for exiting napi mode. I'm not sure what it was
trying to solve and it should be up to the network stack to decide when
we are done polling so remove it.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_main.c	2011-03-21 09:44:15.792816780 +1100
+++ linux-2.6/drivers/net/ehea/ehea_main.c	2011-03-21 14:18:42.213238477 +1100
@@ -931,7 +931,6 @@ static struct ehea_cqe *ehea_proc_cqes(s
 	return cqe;
 }
 
-#define EHEA_NAPI_POLL_NUM_BEFORE_IRQ 16
 #define EHEA_POLL_MAX_CQES 65535
 
 static int ehea_poll(struct napi_struct *napi, int budget)
@@ -941,18 +940,13 @@ static int ehea_poll(struct napi_struct
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
+	while ((rx != budget)) {
 		napi_complete(napi);
 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_ep(pr->send_cq);
@@ -972,7 +966,6 @@ static int ehea_poll(struct napi_struct
 		rx += ehea_proc_rwqes(dev, pr, budget - rx);
 	}
 
-	pr->poll_counter++;
 	return rx;
 }
 
Index: linux-2.6/drivers/net/ehea/ehea.h
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea.h	2011-03-21 14:18:26.442655734 +1100
+++ linux-2.6/drivers/net/ehea/ehea.h	2011-03-21 14:18:33.252907379 +1100
@@ -383,7 +383,6 @@ struct ehea_port_res {
 	u64 tx_bytes;
 	u64 rx_packets;
 	u64 rx_bytes;
-	u32 poll_counter;
 	struct net_lro_mgr lro_mgr;
 	struct net_lro_desc lro_desc[MAX_LRO_DESCRIPTORS];
 	int sq_restart_flag;
