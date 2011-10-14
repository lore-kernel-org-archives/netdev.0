From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 13/15] ehea: Remove LRO support
Date: Fri, 14 Oct 2011 12:31:10 -0300
Message-ID: <1318606272-27647-14-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:51441 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933216Ab1JNPbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:49 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id p9EGqdc0010476
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:52:39 -0400
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFUNAk3174428
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:30:23 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVdDY008855
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:39 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

In preparation for adding GRO to ehea, remove LRO.

v3:
[cascardo] fixed conflict with vlan cleanup

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea.h         |    7 ---
 drivers/net/ethernet/ibm/ehea/ehea_ethtool.c |   16 -------
 drivers/net/ethernet/ibm/ehea/ehea_main.c    |   61 +-------------------------
 3 files changed, 1 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
index c9dbe52..410d6a1 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea.h
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
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
index d185016..05b7359 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
@@ -205,9 +205,6 @@ static const char ehea_ethtool_stats_keys[][ETH_GSTRING_LEN] = {
 	{"PR13 free_swqes"},
 	{"PR14 free_swqes"},
 	{"PR15 free_swqes"},
-	{"LRO aggregated"},
-	{"LRO flushed"},
-	{"LRO no_desc"},
 };
 
 static void ehea_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -264,19 +261,6 @@ static void ehea_get_ethtool_stats(struct net_device *dev,
 
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
 }
 
 const struct ethtool_ops ehea_ethtool_ops = {
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index a0a3c5f..3b8e657 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -62,8 +62,6 @@ static int rq2_entries = EHEA_DEF_ENTRIES_RQ2;
 static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
 static int sq_entries = EHEA_DEF_ENTRIES_SQ;
 static int use_mcs = 1;
-static int use_lro;
-static int lro_max_aggr = EHEA_LRO_MAX_AGGR;
 static int prop_carrier_state;
 
 module_param(msg_level, int, 0);
@@ -73,8 +71,6 @@ module_param(rq3_entries, int, 0);
 module_param(sq_entries, int, 0);
 module_param(prop_carrier_state, int, 0);
 module_param(use_mcs, int, 0);
-module_param(use_lro, int, 0);
-module_param(lro_max_aggr, int, 0);
 
 MODULE_PARM_DESC(msg_level, "msg_level");
 MODULE_PARM_DESC(prop_carrier_state, "Propagate carrier state of physical "
@@ -94,11 +90,6 @@ MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
 MODULE_PARM_DESC(use_mcs, " Multiple receive queues, 1: enable, 0: disable, "
 		 "Default = 1");
 
-MODULE_PARM_DESC(lro_max_aggr, " LRO: Max packets to be aggregated. Default = "
-		 __MODULE_STRING(EHEA_LRO_MAX_AGGR));
-MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
-		 "Default = 0");
-
 static int port_name_cnt;
 static LIST_HEAD(adapter_list);
 static unsigned long ehea_driver_flags;
@@ -656,47 +647,13 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
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
 	if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
 		__vlan_hwaccel_put_tag(skb, cqe->vlan_tag);
 
-	if (skb->dev->features & NETIF_F_LRO)
-		lro_receive_skb(&pr->lro_mgr, skb, cqe);
-	else
-		netif_receive_skb(skb);
+	netif_receive_skb(skb);
 }
 
 static int ehea_proc_rwqes(struct net_device *dev,
@@ -786,8 +743,6 @@ static int ehea_proc_rwqes(struct net_device *dev,
 		}
 		cqe = ehea_poll_rq1(qp, &wqe_index);
 	}
-	if (dev->features & NETIF_F_LRO)
-		lro_flush_all(&pr->lro_mgr);
 
 	pr->rx_packets += processed;
 	pr->rx_bytes += processed_bytes;
@@ -1611,15 +1566,6 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 
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
 
@@ -3082,9 +3028,6 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 			NETIF_F_IP_CSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
-	if (use_lro)
-		dev->features |= NETIF_F_LRO;
-
 	INIT_WORK(&port->reset_task, ehea_reset_port);
 	INIT_DELAYED_WORK(&port->stats_work, ehea_update_stats);
 
@@ -3098,8 +3041,6 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		goto out_unreg_port;
 	}
 
-	port->lro_max_aggr = lro_max_aggr;
-
 	ret = ehea_get_jumboframe_status(port, &jumbo);
 	if (ret)
 		netdev_err(dev, "failed determining jumbo frame status\n");
-- 
1.7.4.4
