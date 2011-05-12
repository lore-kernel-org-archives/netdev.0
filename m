From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 04/15] ehea: Remove num_tx_qps module option
Date: Thu, 12 May 2011 10:52:17 +1000
Message-ID: <20110512005622.862264994@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40952 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540Ab1ELB17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:27:59 -0400
Content-Disposition: inline; filename=ehea_5.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The num_tx_qps module option allows a user to configure a different
number of tx and rx queues. Now the networking stack is multiqueue
aware it makes little sense just to enable the tx queues and not the
rx queues so remove the option.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea.h
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea.h	2011-05-12 07:47:51.960153456 +1000
+++ linux-net/drivers/net/ehea/ehea.h	2011-05-12 07:47:53.490177714 +1000
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
Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:51.960153456 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:53.490177714 +1000
@@ -63,7 +63,6 @@ static int sq_entries = EHEA_DEF_ENTRIES
 static int use_mcs = 1;
 static int use_lro;
 static int lro_max_aggr = EHEA_LRO_MAX_AGGR;
-static int num_tx_qps = EHEA_NUM_TX_QP;
 static int prop_carrier_state;
 
 module_param(msg_level, int, 0);
@@ -75,9 +74,7 @@ module_param(prop_carrier_state, int, 0)
 module_param(use_mcs, int, 0);
 module_param(use_lro, int, 0);
 module_param(lro_max_aggr, int, 0);
-module_param(num_tx_qps, int, 0);
 
-MODULE_PARM_DESC(num_tx_qps, "Number of TX-QPS");
 MODULE_PARM_DESC(msg_level, "msg_level");
 MODULE_PARM_DESC(prop_carrier_state, "Propagate carrier state of physical "
 		 "port to stack. 1:yes, 0:no.  Default = 0 ");
@@ -172,7 +169,7 @@ static void ehea_update_firmware_handles
 				continue;
 
 			num_ports++;
-			num_portres += port->num_def_qps + port->num_add_tx_qps;
+			num_portres += port->num_def_qps;
 		}
 	}
 
@@ -198,9 +195,7 @@ static void ehea_update_firmware_handles
 			    (num_ports == 0))
 				continue;
 
-			for (l = 0;
-			     l < port->num_def_qps + port->num_add_tx_qps;
-			     l++) {
+			for (l = 0; l < port->num_def_qps; l++) {
 				struct ehea_port_res *pr = &port->port_res[l];
 
 				arr[i].adh = adapter->handle;
@@ -360,7 +355,7 @@ static struct net_device_stats *ehea_get
 	}
 
 	tx_packets = 0;
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		tx_packets += port->port_res[i].tx_packets;
 		tx_bytes   += port->port_res[i].tx_bytes;
 	}
@@ -811,7 +806,7 @@ static void reset_sq_restart_flag(struct
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		struct ehea_port_res *pr = &port->port_res[i];
 		pr->sq_restart_flag = 0;
 	}
@@ -824,7 +819,7 @@ static void check_sqs(struct ehea_port *
 	int swqe_index;
 	int i, k;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		struct ehea_port_res *pr = &port->port_res[i];
 		int ret;
 		k = 0;
@@ -1113,13 +1108,6 @@ int ehea_sense_port_attr(struct ehea_por
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
@@ -1360,7 +1348,7 @@ static int ehea_reg_interrupts(struct ne
 		   port->qp_eq->attr.ist1);
 
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		pr = &port->port_res[i];
 		snprintf(pr->int_send_name, EHEA_IRQ_NAME_SIZE - 1,
 			 "%s-queue%d", dev->name, i);
@@ -1403,7 +1391,7 @@ static void ehea_free_interrupts(struct
 
 	/* send */
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		pr = &port->port_res[i];
 		ibmebus_free_irq(pr->eq->attr.ist1, pr);
 		netif_info(port, intr, dev,
@@ -2472,8 +2460,7 @@ out:
 	return ret;
 }
 
-static int ehea_port_res_setup(struct ehea_port *port, int def_qps,
-			       int add_tx_qps)
+static int ehea_port_res_setup(struct ehea_port *port, int def_qps)
 {
 	int ret, i;
 	struct port_res_cfg pr_cfg, pr_cfg_small_rx;
@@ -2506,7 +2493,7 @@ static int ehea_port_res_setup(struct eh
 		if (ret)
 			goto out_clean_pr;
 	}
-	for (i = def_qps; i < def_qps + add_tx_qps; i++) {
+	for (i = def_qps; i < def_qps; i++) {
 		ret = ehea_init_port_res(port, &port->port_res[i],
 					 &pr_cfg_small_rx, i);
 		if (ret)
@@ -2529,7 +2516,7 @@ static int ehea_clean_all_portres(struct
 	int ret = 0;
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+	for (i = 0; i < port->num_def_qps; i++)
 		ret |= ehea_clean_portres(port, &port->port_res[i]);
 
 	ret |= ehea_destroy_eq(port->qp_eq);
@@ -2561,8 +2548,7 @@ static int ehea_up(struct net_device *de
 	if (port->state == EHEA_PORT_UP)
 		return 0;
 
-	ret = ehea_port_res_setup(port, port->num_def_qps,
-				  port->num_add_tx_qps);
+	ret = ehea_port_res_setup(port, port->num_def_qps);
 	if (ret) {
 		netdev_err(dev, "port_res_failed\n");
 		goto out;
@@ -2581,7 +2567,7 @@ static int ehea_up(struct net_device *de
 		goto out_clean_pr;
 	}
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		ret = ehea_activate_qp(port->adapter, port->port_res[i].qp);
 		if (ret) {
 			netdev_err(dev, "activate_qp failed\n");
@@ -2627,7 +2613,7 @@ static void port_napi_disable(struct ehe
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+	for (i = 0; i < port->num_def_qps; i++)
 		napi_disable(&port->port_res[i].napi);
 }
 
@@ -2635,7 +2621,7 @@ static void port_napi_enable(struct ehea
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+	for (i = 0; i < port->num_def_qps; i++)
 		napi_enable(&port->port_res[i].napi);
 }
 
@@ -2721,7 +2707,7 @@ static void ehea_flush_sq(struct ehea_po
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		struct ehea_port_res *pr = &port->port_res[i];
 		int swqe_max = pr->sq_skba_size - 2 - pr->swqe_ll_count;
 		int ret;
@@ -2755,7 +2741,7 @@ int ehea_stop_qps(struct net_device *dev
 		goto out;
 	}
 
-	for (i = 0; i < (port->num_def_qps + port->num_add_tx_qps); i++) {
+	for (i = 0; i < (port->num_def_qps); i++) {
 		struct ehea_port_res *pr =  &port->port_res[i];
 		struct ehea_qp *qp = pr->qp;
 
@@ -2857,7 +2843,7 @@ int ehea_restart_qps(struct net_device *
 		goto out;
 	}
 
-	for (i = 0; i < (port->num_def_qps + port->num_add_tx_qps); i++) {
+	for (i = 0; i < (port->num_def_qps); i++) {
 		struct ehea_port_res *pr =  &port->port_res[i];
 		struct ehea_qp *qp = pr->qp;
 
@@ -3217,8 +3203,7 @@ struct ehea_port *ehea_setup_single_port
 		goto out_free_mc_list;
 
 	netif_set_real_num_rx_queues(dev, port->num_def_qps);
-	netif_set_real_num_tx_queues(dev, port->num_def_qps +
-				     port->num_add_tx_qps);
+	netif_set_real_num_tx_queues(dev, port->num_def_qps);
 
 	port_dev = ehea_register_port(port, dn);
 	if (!port_dev)


