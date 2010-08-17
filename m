From: Andre Detsch <adetsch@br.ibm.com>
Subject: [PATCH] ehea: Fix synchronization between HW and SW send queue
Date: Tue, 17 Aug 2010 12:49:12 -0300
Message-ID: <201008171249.12620.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, themann@de.ibm.com, brenohl@br.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:47694 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757106Ab0HQPtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 11:49:15 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7HFYYn6018431
	for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 11:34:34 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7HFnEmb209944
	for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 11:49:14 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7HFnDPo021388
	for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 11:49:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ehea: Fix synchronization between HW and SW send queue

When memory is added to / removed from a partition via the Memory DLPAR
mechanism, the eHEA driver has to do a couple of things to reflect the
memory change in its own IO address translation tables. This involves
stopping and restarting the HW queues. 
During this operation, it is possible that HW and SW pointer into these
queues get out of sync. This results in a situation where packets that
are attached to a send queue are not transmitted immediately, but
delayed until further X packets have been put on the queue.

This patch detects such loss of synchronization, and resets the ehea
port when needed.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Signed-off-by: Andre Detsch <adetsch@br.ibm.com>

Index: net-next-2.6/drivers/net/ehea/ehea.h
===================================================================
--- net-next-2.6.orig/drivers/net/ehea/ehea.h	2010-08-17 11:34:26.090036724 -0400
+++ net-next-2.6/drivers/net/ehea/ehea.h	2010-08-17 11:36:33.800036535 -0400
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0105"
+#define DRV_VERSION	"EHEA_0106"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -400,6 +400,7 @@
 	u32 poll_counter;
 	struct net_lro_mgr lro_mgr;
 	struct net_lro_desc lro_desc[MAX_LRO_DESCRIPTORS];
+	int sq_restart_flag;
 };
 
 
Index: net-next-2.6/drivers/net/ehea/ehea_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/ehea/ehea_main.c	2010-08-17 11:34:26.090036724 -0400
+++ net-next-2.6/drivers/net/ehea/ehea_main.c	2010-08-17 11:34:53.710036711 -0400
@@ -776,6 +776,53 @@
 	return processed;
 }
 
+#define SWQE_RESTART_CHECK 0xdeadbeaff00d0000ull
+
+static void reset_sq_restart_flag(struct ehea_port *port)
+{
+	int i;
+
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+		struct ehea_port_res *pr = &port->port_res[i];
+		pr->sq_restart_flag = 0;
+	}
+}
+
+static void check_sqs(struct ehea_port *port)
+{
+	struct ehea_swqe *swqe;
+	int swqe_index;
+	int i, k;
+
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+		struct ehea_port_res *pr = &port->port_res[i];
+		k = 0;
+		swqe = ehea_get_swqe(pr->qp, &swqe_index);
+		memset(swqe, 0, SWQE_HEADER_SIZE);
+		atomic_dec(&pr->swqe_avail);
+
+		swqe->tx_control |= EHEA_SWQE_PURGE;
+		swqe->wr_id = SWQE_RESTART_CHECK;
+		swqe->tx_control |= EHEA_SWQE_SIGNALLED_COMPLETION;
+		swqe->tx_control |= EHEA_SWQE_IMM_DATA_PRESENT;
+		swqe->immediate_data_length = 80;
+
+		ehea_post_swqe(pr->qp, swqe);
+
+		while (pr->sq_restart_flag == 0) {
+			msleep(5);
+			if (++k == 100) {
+				ehea_error("HW/SW queues out of sync");
+				ehea_schedule_port_reset(pr->port);
+				return;
+			}
+		}
+	}
+
+	return;
+}
+
+
 static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 {
 	struct sk_buff *skb;
@@ -793,6 +840,13 @@
 
 		cqe_counter++;
 		rmb();
+
+		if (cqe->wr_id == SWQE_RESTART_CHECK) {
+			pr->sq_restart_flag = 1;
+			swqe_av++;
+			break;
+		}
+
 		if (cqe->status & EHEA_CQE_STAT_ERR_MASK) {
 			ehea_error("Bad send completion status=0x%04X",
 				   cqe->status);
@@ -2675,8 +2729,10 @@
 		int k = 0;
 		while (atomic_read(&pr->swqe_avail) < swqe_max) {
 			msleep(5);
-			if (++k == 20)
+			if (++k == 20) {
+				ehea_error("WARNING: sq not flushed completely");
 				break;
+			}
 		}
 	}
 }
@@ -2917,6 +2973,7 @@
 					port_napi_disable(port);
 					mutex_unlock(&port->port_lock);
 				}
+				reset_sq_restart_flag(port);
 			}
 
 			/* Unregister old memory region */
@@ -2951,6 +3008,7 @@
 						mutex_lock(&port->port_lock);
 						port_napi_enable(port);
 						ret = ehea_restart_qps(dev);
+						check_sqs(port);
 						if (!ret)
 							netif_wake_queue(dev);
 						mutex_unlock(&port->port_lock);
