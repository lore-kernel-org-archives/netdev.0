From: leitao@linux.vnet.ibm.com
Subject: [PATCH 1/2] ehea: using wait queues instead of msleep on ehea_flush_sq
Date: Tue,  5 Oct 2010 19:16:22 -0400
Message-ID: <1286320583-5594-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:39718 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757835Ab0JEXQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 19:16:37 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id o95NB9AQ029160
	for <netdev@vger.kernel.org>; Tue, 5 Oct 2010 20:11:09 -0300
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o95NMhQ01146954
	for <netdev@vger.kernel.org>; Tue, 5 Oct 2010 20:22:44 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o95NGY58007926
	for <netdev@vger.kernel.org>; Tue, 5 Oct 2010 20:16:34 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just remove a msleep loop and change to wait queue,
making the code cleaner.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Acked-by: David Howells <dhowells@redhat.com>
---
 drivers/net/ehea/ehea.h      |    1 +
 drivers/net/ehea/ehea_main.c |   19 ++++++++++++-------
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 1846623..5bae7da 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -491,6 +491,7 @@ struct ehea_port {
 	u8 full_duplex;
 	u8 autoneg;
 	u8 num_def_qps;
+	wait_queue_head_t swqe_avail_wq;
 };
 
 struct port_res_cfg {
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index a333b42..4a3d33b 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -890,6 +890,7 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 		pr->queue_stopped = 0;
 	}
 	spin_unlock_irqrestore(&pr->netif_queue, flags);
+	wake_up(&pr->port->swqe_avail_wq);
 
 	return cqe;
 }
@@ -2654,6 +2655,8 @@ static int ehea_open(struct net_device *dev)
 		netif_start_queue(dev);
 	}
 
+	init_waitqueue_head(&port->swqe_avail_wq);
+
 	mutex_unlock(&port->port_lock);
 
 	return ret;
@@ -2726,13 +2729,15 @@ static void ehea_flush_sq(struct ehea_port *port)
 	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
 		struct ehea_port_res *pr = &port->port_res[i];
 		int swqe_max = pr->sq_skba_size - 2 - pr->swqe_ll_count;
-		int k = 0;
-		while (atomic_read(&pr->swqe_avail) < swqe_max) {
-			msleep(5);
-			if (++k == 20) {
-				ehea_error("WARNING: sq not flushed completely");
-				break;
-			}
+		int ret;
+
+		ret = wait_event_timeout(port->swqe_avail_wq,
+			 atomic_read(&pr->swqe_avail) >= swqe_max,
+			 msecs_to_jiffies(100));
+
+		if (!ret) {
+			ehea_error("WARNING: sq not flushed completely");
+			break;
 		}
 	}
 }
-- 
1.6.5

