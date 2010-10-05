From: leitao@linux.vnet.ibm.com
Subject: [PATCH 2/2] ehea: converting msleeps to waitqueue on check_sqs() function
Date: Tue,  5 Oct 2010 19:16:23 -0400
Message-ID: <1286320583-5594-2-git-send-email-leitao@linux.vnet.ibm.com>
References: <1286320583-5594-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:44144 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757837Ab0JEXQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 19:16:38 -0400
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id o95NMa0Q031556
	for <netdev@vger.kernel.org>; Tue, 5 Oct 2010 20:22:36 -0300
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o95NMmic3137642
	for <netdev@vger.kernel.org>; Tue, 5 Oct 2010 20:22:48 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o95NGZgT007942
	for <netdev@vger.kernel.org>; Tue, 5 Oct 2010 20:16:35 -0300
In-Reply-To: <1286320583-5594-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing the msleep() call in check_sqs() function, and replacing by a wait queue.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea.h      |    1 +
 drivers/net/ehea/ehea_main.c |   18 +++++++++++-------
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 5bae7da..1321cb6 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -492,6 +492,7 @@ struct ehea_port {
 	u8 autoneg;
 	u8 num_def_qps;
 	wait_queue_head_t swqe_avail_wq;
+	wait_queue_head_t restart_wq;
 };
 
 struct port_res_cfg {
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 4a3d33b..0471cae 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -786,6 +786,7 @@ static void reset_sq_restart_flag(struct ehea_port *port)
 		struct ehea_port_res *pr = &port->port_res[i];
 		pr->sq_restart_flag = 0;
 	}
+	wake_up(&port->restart_wq);
 }
 
 static void check_sqs(struct ehea_port *port)
@@ -796,6 +797,7 @@ static void check_sqs(struct ehea_port *port)
 
 	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
 		struct ehea_port_res *pr = &port->port_res[i];
+		int ret;
 		k = 0;
 		swqe = ehea_get_swqe(pr->qp, &swqe_index);
 		memset(swqe, 0, SWQE_HEADER_SIZE);
@@ -809,13 +811,14 @@ static void check_sqs(struct ehea_port *port)
 
 		ehea_post_swqe(pr->qp, swqe);
 
-		while (pr->sq_restart_flag == 0) {
-			msleep(5);
-			if (++k == 100) {
-				ehea_error("HW/SW queues out of sync");
-				ehea_schedule_port_reset(pr->port);
-				return;
-			}
+		ret = wait_event_timeout(port->restart_wq,
+					 pr->sq_restart_flag == 0,
+					 msecs_to_jiffies(100));
+
+		if (!ret) {
+			ehea_error("HW/SW queues out of sync");
+			ehea_schedule_port_reset(pr->port);
+			return;
 		}
 	}
 
@@ -2656,6 +2659,7 @@ static int ehea_open(struct net_device *dev)
 	}
 
 	init_waitqueue_head(&port->swqe_avail_wq);
+	init_waitqueue_head(&port->restart_wq);
 
 	mutex_unlock(&port->port_lock);
 
-- 
1.6.5

