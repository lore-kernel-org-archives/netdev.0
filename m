From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 13/14] ehea: Remove LRO support
Date: Tue, 5 Apr 2011 21:43:57 +1000
Message-ID: <20110405214357.60a36a3e@kryten>
References: <20110405212825.6eb85677@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael@ellerman.id.au
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36955 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743Ab1DELoj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:44:39 -0400
In-Reply-To: <20110405212825.6eb85677@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In preparation for adding GRO to ehea, remove LRO.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_main.c	2011-04-05 20:47:47.280390562 +1000
+++ linux-2.6/drivers/net/ehea/ehea_main.c	2011-04-05 20:47:47.870323182 +1000
@@ -61,8 +61,6 @@ static int rq2_entries = EHEA_DEF_ENTRIE
 static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
 static int sq_entries = EHEA_DEF_ENTRIES_SQ;
 static int use_mcs = 1;
-static int use_lro;
-static int lro_max_aggr = EHEA_LRO_MAX_AGGR;
 static int prop_carrier_state;
 
 module_param(msg_level, int, 0);
@@ -72,8 +70,6 @@ module_param(rq3_entries, int, 0);
 module_param(sq_entries, int, 0);
 module_param(prop_carrier_state, int, 0);
 module_param(use_mcs, int, 0);
-module_param(use_lro, int, 0);
-module_param(lro_max_aggr, int, 0);
 
 MODULE_PARM_DESC(msg_level, "msg_level");
 MODULE_PARM_DESC(prop_carrier_state, "Propagate carrier state of physical "
@@ -92,11 +88,6 @@ MODULE_PARM_DESC(sq_entries, " Number of
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
 MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 0 ");
 
-MODULE_PARM_DESC(lro_max_aggr, " LRO: Max packets to be aggregated. Default = "
-		 __MODULE_STRING(EHEA_LRO_MAX_AGGR));
-MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
-		 "Default = 0");
-
 static int port_name_cnt;
 static LIST_HEAD(adapter_list);
 static unsigned long ehea_driver_flags;
@@ -643,58 +634,16 @@ static int ehea_treat_poll_error(struct
 	return 0;
 }
 
-static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
-		       void **tcph, u64 *hdr_flags, void *priv)
-{
-	struct ehea_cqe *cqe = priv;
-	unsigned int ip_len;
-	struct iphdr *iph;
-
-	/* non tcp/udp packets */
-	if (!cqe->header_length)
-		return -1;
-
-	/* non tcp packet */
-	skb_reset_network_header(skb);
-	iph = ip_hdr(skb);
-	if (iph->protocol != IPPROTO_TCP)
-		return -1;
-
-	ip_len = ip_hdrlen(skb);
-	skb_set_transport_header(skb, ip_len);
-	*tcph = tcp_hdr(skb);
-
-	/* check if ip header and tcp header are complete */
-	if (ntohs(iph->tot_len) < ip_len + tcp_hdrlen(skb))
-		return -1;
-
-	*hdr_flags = LRO_IPV4 | LRO_TCP;
-	*iphdr = iph;
-
-	return 0;
-}
-
 static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
 			  struct sk_buff *skb)
 {
 	int vlan_extracted = ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) &&
 			      pr->port->vgrp);
 
-	if (skb->dev->features & NETIF_F_LRO) {
-		if (vlan_extracted)
-			lro_vlan_hwaccel_receive_skb(&pr->lro_mgr, skb,
-						     pr->port->vgrp,
-						     cqe->vlan_tag,
-						     cqe);
-		else
-			lro_receive_skb(&pr->lro_mgr, skb, cqe);
-	} else {
-		if (vlan_extracted)
-			vlan_hwaccel_receive_skb(skb, pr->port->vgrp,
-						 cqe->vlan_tag);
-		else
-			netif_receive_skb(skb);
-	}
+	if (vlan_extracted)
+		vlan_hwaccel_receive_skb(skb, pr->port->vgrp, cqe->vlan_tag);
+	else
+		netif_receive_skb(skb);
 }
 
 static int ehea_proc_rwqes(struct net_device *dev,
@@ -790,8 +739,6 @@ static int ehea_proc_rwqes(struct net_de
 		}
 		cqe = ehea_poll_rq1(qp, &wqe_index);
 	}
-	if (dev->features & NETIF_F_LRO)
-		lro_flush_all(&pr->lro_mgr);
 
 	pr->rx_packets += processed;
 	pr->rx_bytes += processed_bytes;
@@ -1616,15 +1563,6 @@ static int ehea_init_port_res(struct ehe
 
 	netif_napi_add(pr->port->netdev, &pr->napi, ehea_poll, 64);
 
-	pr->lro_mgr.max_aggr = pr->port->lro_max_aggr;
-	pr->lro_mgr.max_desc = MAX_LRO_DESCRIPTORS;
-	pr->lro_mgr.lro_arr = pr->lro_desc;
-	pr->lro_mgr.get_skb_header = get_skb_hdr;
-	pr->lro_mgr.features = LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
-	pr->lro_mgr.dev = port->netdev;
-	pr->lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
-	pr->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
-
 	ret = 0;
 	goto out;
 
@@ -3114,9 +3052,6 @@ struct ehea_port *ehea_setup_single_port
 			NETIF_F_IP_CSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
-	if (use_lro)
-		dev->features |= NETIF_F_LRO;
-
 	INIT_WORK(&port->reset_task, ehea_reset_port);
 
 	ret = register_netdev(dev);
@@ -3125,8 +3060,6 @@ struct ehea_port *ehea_setup_single_port
 		goto out_unreg_port;
 	}
 
-	port->lro_max_aggr = lro_max_aggr;
-
 	ret = ehea_get_jumboframe_status(port, &jumbo);
 	if (ret)
 		netdev_err(dev, "failed determining jumbo frame status\n");
Index: linux-2.6/drivers/net/ehea/ehea.h
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea.h	2011-04-05 20:47:42.730910160 +1000
+++ linux-2.6/drivers/net/ehea/ehea.h	2011-04-05 20:47:47.870323182 +1000
@@ -33,7 +33,6 @@
 #include <linux/ethtool.h>
 #include <linux/vmalloc.h>
 #include <linux/if_vlan.h>
-#include <linux/inet_lro.h>
 
 #include <asm/ibmebus.h>
 #include <asm/abs_addr.h>
@@ -58,7 +57,6 @@
 #define EHEA_MIN_ENTRIES_QP  127
 
 #define EHEA_SMALL_QUEUES
-#define EHEA_LRO_MAX_AGGR 64
 
 #ifdef EHEA_SMALL_QUEUES
 #define EHEA_MAX_CQE_COUNT      1023
@@ -85,8 +83,6 @@
 #define EHEA_RQ2_PKT_SIZE       2048
 #define EHEA_L_PKT_SIZE         256	/* low latency */
 
-#define MAX_LRO_DESCRIPTORS 8
-
 /* Send completion signaling */
 
 /* Protection Domain Identifier */
@@ -382,8 +378,6 @@ struct ehea_port_res {
 	u64 tx_bytes;
 	u64 rx_packets;
 	u64 rx_bytes;
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_desc[MAX_LRO_DESCRIPTORS];
 	int sq_restart_flag;
 };
 
@@ -468,7 +462,6 @@ struct ehea_port {
 	u32 msg_enable;
 	u32 sig_comp_iv;
 	u32 state;
-	u32 lro_max_aggr;
 	u8 phy_link;
 	u8 full_duplex;
 	u8 autoneg;
Index: linux-2.6/drivers/net/ehea/ehea_ethtool.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_ethtool.c	2011-04-05 20:47:47.280390562 +1000
+++ linux-2.6/drivers/net/ehea/ehea_ethtool.c	2011-04-05 20:47:47.870323182 +1000
@@ -192,9 +192,6 @@ static char ehea_ethtool_stats_keys[][ET
 	{"PR13 free_swqes"},
 	{"PR14 free_swqes"},
 	{"PR15 free_swqes"},
-	{"LRO aggregated"},
-	{"LRO flushed"},
-	{"LRO no_desc"},
 };
 
 static void ehea_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -251,33 +248,6 @@ static void ehea_get_ethtool_stats(struc
 
 	for (k = 0; k < 16; k++)
 		data[i++] = atomic_read(&port->port_res[k].swqe_avail);
-
-	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
-		tmp |= port->port_res[k].lro_mgr.stats.aggregated;
-	data[i++] = tmp;
-
-	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
-		tmp |= port->port_res[k].lro_mgr.stats.flushed;
-	data[i++] = tmp;
-
-	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
-		tmp |= port->port_res[k].lro_mgr.stats.no_desc;
-	data[i++] = tmp;
-
-}
-
-static int ehea_set_flags(struct net_device *dev, u32 data)
-{
-	/* Avoid changing the VLAN flags */
-	if ((data & (ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN)) !=
-	    (ethtool_op_get_flags(dev) & (ETH_FLAG_RXVLAN |
-					  ETH_FLAG_TXVLAN))){
-		return -EINVAL;
-	}
-
-	return ethtool_op_set_flags(dev, data, ETH_FLAG_LRO
-					| ETH_FLAG_TXVLAN
-					| ETH_FLAG_RXVLAN);
 }
 
 const struct ethtool_ops ehea_ethtool_ops = {
@@ -293,7 +263,6 @@ const struct ethtool_ops ehea_ethtool_op
 	.get_rx_csum = ehea_get_rx_csum,
 	.set_settings = ehea_set_settings,
 	.get_flags = ethtool_op_get_flags,
-	.set_flags = ehea_set_flags,
 	.nway_reset = ehea_nway_reset,		/* Restart autonegotiation */
 	.set_tx_csum = ethtool_op_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
