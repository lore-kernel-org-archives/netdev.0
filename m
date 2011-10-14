From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 04/15] ehea: Remove num_tx_qps module option
Date: Fri, 14 Oct 2011 12:31:01 -0300
Message-ID: <1318606272-27647-5-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:39696 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933203Ab1JNPbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:44 -0400
Received: from /spool/local
	by br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 14 Oct 2011 12:31:41 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFUEis3420402
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:30:14 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVUW3008570
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:31 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

The num_tx_qps module option allows a user to configure a different
number of tx and rx queues. Now the networking stack is multiqueue
aware it makes little sense just to enable the tx queues and not the
rx queues so remove the option.

v3:
[cascardo] fixed conflict with get_stats change

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea.h      |    3 --
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   51 ++++++++++------------------
 2 files changed, 18 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
index 4a4d466..8e7c594 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea.h
@@ -58,7 +58,6 @@
 #define EHEA_MIN_ENTRIES_QP  127
 
 #define EHEA_SMALL_QUEUES
-#define EHEA_NUM_TX_QP 1
 #define EHEA_LRO_MAX_AGGR 64
 
 #ifdef EHEA_SMALL_QUEUES
@@ -460,8 +459,6 @@ struct ehea_port {
 	char int_aff_name[EHEA_IRQ_NAME_SIZE];
 	int allmulti;			 /* Indicates IFF_ALLMULTI state */
 	int promisc;		 	 /* Indicates IFF_PROMISC state */
-	int num_tx_qps;
-	int num_add_tx_qps;
 	int num_mcs;
 	int resets;
 	unsigned long flags;
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 4032a0a..6ded42a 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -64,7 +64,6 @@ static int sq_entries = EHEA_DEF_ENTRIES_SQ;
 static int use_mcs = 1;
 static int use_lro;
 static int lro_max_aggr = EHEA_LRO_MAX_AGGR;
-static int num_tx_qps = EHEA_NUM_TX_QP;
 static int prop_carrier_state;
 
 module_param(msg_level, int, 0);
@@ -76,9 +75,7 @@ module_param(prop_carrier_state, int, 0);
 module_param(use_mcs, int, 0);
 module_param(use_lro, int, 0);
 module_param(lro_max_aggr, int, 0);
-module_param(num_tx_qps, int, 0);
 
-MODULE_PARM_DESC(num_tx_qps, "Number of TX-QPS");
 MODULE_PARM_DESC(msg_level, "msg_level");
 MODULE_PARM_DESC(prop_carrier_state, "Propagate carrier state of physical "
 		 "port to stack. 1:yes, 0:no.  Default = 0 ");
@@ -174,7 +171,7 @@ static void ehea_update_firmware_handles(void)
 				continue;
 
 			num_ports++;
-			num_portres += port->num_def_qps + port->num_add_tx_qps;
+			num_portres += port->num_def_qps;
 		}
 	}
 
@@ -200,9 +197,7 @@ static void ehea_update_firmware_handles(void)
 			    (num_ports == 0))
 				continue;
 
-			for (l = 0;
-			     l < port->num_def_qps + port->num_add_tx_qps;
-			     l++) {
+			for (l = 0; l < port->num_def_qps; l++) {
 				struct ehea_port_res *pr = &port->port_res[l];
 
 				arr[i].adh = adapter->handle;
@@ -340,7 +335,7 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 		rx_bytes   += port->port_res[i].rx_bytes;
 	}
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		tx_packets += port->port_res[i].tx_packets;
 		tx_bytes   += port->port_res[i].tx_bytes;
 	}
@@ -810,7 +805,7 @@ static void reset_sq_restart_flag(struct ehea_port *port)
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		struct ehea_port_res *pr = &port->port_res[i];
 		pr->sq_restart_flag = 0;
 	}
@@ -823,7 +818,7 @@ static void check_sqs(struct ehea_port *port)
 	int swqe_index;
 	int i, k;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		struct ehea_port_res *pr = &port->port_res[i];
 		int ret;
 		k = 0;
@@ -1112,13 +1107,6 @@ int ehea_sense_port_attr(struct ehea_port *port)
 		goto out_free;
 	}
 
-	port->num_tx_qps = num_tx_qps;
-
-	if (port->num_def_qps >= port->num_tx_qps)
-		port->num_add_tx_qps = 0;
-	else
-		port->num_add_tx_qps = port->num_tx_qps - port->num_def_qps;
-
 	ret = 0;
 out_free:
 	if (ret || netif_msg_probe(port))
@@ -1359,7 +1347,7 @@ static int ehea_reg_interrupts(struct net_device *dev)
 		   port->qp_eq->attr.ist1);
 
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		pr = &port->port_res[i];
 		snprintf(pr->int_send_name, EHEA_IRQ_NAME_SIZE - 1,
 			 "%s-queue%d", dev->name, i);
@@ -1402,7 +1390,7 @@ static void ehea_free_interrupts(struct net_device *dev)
 
 	/* send */
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		pr = &port->port_res[i];
 		ibmebus_free_irq(pr->eq->attr.ist1, pr);
 		netif_info(port, intr, dev,
@@ -2438,8 +2426,7 @@ out:
 	return ret;
 }
 
-static int ehea_port_res_setup(struct ehea_port *port, int def_qps,
-			       int add_tx_qps)
+static int ehea_port_res_setup(struct ehea_port *port, int def_qps)
 {
 	int ret, i;
 	struct port_res_cfg pr_cfg, pr_cfg_small_rx;
@@ -2472,7 +2459,7 @@ static int ehea_port_res_setup(struct ehea_port *port, int def_qps,
 		if (ret)
 			goto out_clean_pr;
 	}
-	for (i = def_qps; i < def_qps + add_tx_qps; i++) {
+	for (i = def_qps; i < def_qps; i++) {
 		ret = ehea_init_port_res(port, &port->port_res[i],
 					 &pr_cfg_small_rx, i);
 		if (ret)
@@ -2495,7 +2482,7 @@ static int ehea_clean_all_portres(struct ehea_port *port)
 	int ret = 0;
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+	for (i = 0; i < port->num_def_qps; i++)
 		ret |= ehea_clean_portres(port, &port->port_res[i]);
 
 	ret |= ehea_destroy_eq(port->qp_eq);
@@ -2527,8 +2514,7 @@ static int ehea_up(struct net_device *dev)
 	if (port->state == EHEA_PORT_UP)
 		return 0;
 
-	ret = ehea_port_res_setup(port, port->num_def_qps,
-				  port->num_add_tx_qps);
+	ret = ehea_port_res_setup(port, port->num_def_qps);
 	if (ret) {
 		netdev_err(dev, "port_res_failed\n");
 		goto out;
@@ -2547,7 +2533,7 @@ static int ehea_up(struct net_device *dev)
 		goto out_clean_pr;
 	}
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		ret = ehea_activate_qp(port->adapter, port->port_res[i].qp);
 		if (ret) {
 			netdev_err(dev, "activate_qp failed\n");
@@ -2593,7 +2579,7 @@ static void port_napi_disable(struct ehea_port *port)
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+	for (i = 0; i < port->num_def_qps; i++)
 		napi_disable(&port->port_res[i].napi);
 }
 
@@ -2601,7 +2587,7 @@ static void port_napi_enable(struct ehea_port *port)
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+	for (i = 0; i < port->num_def_qps; i++)
 		napi_enable(&port->port_res[i].napi);
 }
 
@@ -2689,7 +2675,7 @@ static void ehea_flush_sq(struct ehea_port *port)
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		struct ehea_port_res *pr = &port->port_res[i];
 		int swqe_max = pr->sq_skba_size - 2 - pr->swqe_ll_count;
 		int ret;
@@ -2723,7 +2709,7 @@ int ehea_stop_qps(struct net_device *dev)
 		goto out;
 	}
 
-	for (i = 0; i < (port->num_def_qps + port->num_add_tx_qps); i++) {
+	for (i = 0; i < (port->num_def_qps); i++) {
 		struct ehea_port_res *pr =  &port->port_res[i];
 		struct ehea_qp *qp = pr->qp;
 
@@ -2825,7 +2811,7 @@ int ehea_restart_qps(struct net_device *dev)
 		goto out;
 	}
 
-	for (i = 0; i < (port->num_def_qps + port->num_add_tx_qps); i++) {
+	for (i = 0; i < (port->num_def_qps); i++) {
 		struct ehea_port_res *pr =  &port->port_res[i];
 		struct ehea_qp *qp = pr->qp;
 
@@ -3184,8 +3170,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		goto out_free_mc_list;
 
 	netif_set_real_num_rx_queues(dev, port->num_def_qps);
-	netif_set_real_num_tx_queues(dev, port->num_def_qps +
-				     port->num_add_tx_qps);
+	netif_set_real_num_tx_queues(dev, port->num_def_qps);
 
 	port_dev = ehea_register_port(port, dn);
 	if (!port_dev)
-- 
1.7.4.4
