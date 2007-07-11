From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [RFC 3/3] lro: LRO support for eHEA
Date: Wed, 11 Jul 2007 16:21:49 +0200
Message-ID: <200707111621.49848.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:65183 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765205AbXGKOro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 10:47:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LRO support for eHEA

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---
 drivers/net/ehea/ehea.h      |    9 +++-
 drivers/net/ehea/ehea_main.c |  102 +++++++++++++++++++++++++++++++++++++++---
 2 files changed, 104 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index f03f070..c350cff 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -33,13 +33,14 @@
 #include <linux/ethtool.h>
 #include <linux/vmalloc.h>
 #include <linux/if_vlan.h>
+#include <linux/inet_lro.h>
 
 #include <asm/ibmebus.h>
 #include <asm/abs_addr.h>
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0067"
+#define DRV_VERSION	"EHEA_0069"
 
 /* EHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -55,6 +56,7 @@
 #define EHEA_MAX_ENTRIES_RQ3 16383
 #define EHEA_MAX_ENTRIES_SQ  32767
 #define EHEA_MIN_ENTRIES_QP  127
+#define EHEA_LRO_MAX_PKTS 60
 
 #define EHEA_SMALL_QUEUES
 #define EHEA_NUM_TX_QP 1
@@ -84,6 +86,8 @@
 #define EHEA_RQ2_PKT_SIZE       1522
 #define EHEA_L_PKT_SIZE         256	/* low latency */
 
+#define MAX_LRO_DESCRIPTORS 8
+
 /* Send completion signaling */
 
 /* Protection Domain Identifier */
@@ -368,6 +372,8 @@ struct ehea_port_res {
 	u64 tx_packets;
 	u64 rx_packets;
 	u32 poll_counter;
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_desc[MAX_LRO_DESCRIPTORS];
 };
 
 
@@ -417,6 +423,7 @@ struct ehea_port {
 	u32 msg_enable;
 	u32 sig_comp_iv;
 	u32 state;
+	u32 lro_max_aggr;
 	u8 full_duplex;
 	u8 autoneg;
 	u8 num_def_qps;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 383144d..d1d09fb 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -34,6 +34,7 @@
 #include <linux/list.h>
 #include <linux/if_ether.h>
 #include <net/ip.h>
+#include <net/tcp.h>
 
 #include "ehea.h"
 #include "ehea_qmr.h"
@@ -52,6 +53,8 @@ static int rq2_entries = EHEA_DEF_ENTRIES_RQ2;
 static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
 static int sq_entries = EHEA_DEF_ENTRIES_SQ;
 static int use_mcs = 0;
+static int use_lro = 0;
+static int lro_max_pkts = EHEA_LRO_MAX_PKTS;
 static int num_tx_qps = EHEA_NUM_TX_QP;
 
 module_param(msg_level, int, 0);
@@ -60,6 +63,8 @@ module_param(rq2_entries, int, 0);
 module_param(rq3_entries, int, 0);
 module_param(sq_entries, int, 0);
 module_param(use_mcs, int, 0);
+module_param(use_lro, int, 0);
+module_param(lro_max_pkts, int, 0);
 module_param(num_tx_qps, int, 0);
 
 MODULE_PARM_DESC(num_tx_qps, "Number of TX-QPS");
@@ -77,6 +82,10 @@ MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
 		 "[2^x - 1], x = [6..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
 MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
+MODULE_PARM_DESC(lro_max_pkts, " LRO: Max packets to be aggregated. Default = "
+		 __MODULE_STRING(EHEA_LRO_MAX_PKTS));
+MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
+		 "Default = 0");
 
 static int port_name_cnt = 0;
 
@@ -380,6 +389,60 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	return 0;
 }
 
+static int try_get_ip_tcp_hdr(struct sk_buff *skb,
+			      struct iphdr **iphdr,
+			      struct tcphdr **tcph,
+			      void *priv)
+{
+	struct ehea_cqe *cqe = priv;
+	unsigned int ip_hdrlength;
+	struct iphdr *iph;
+
+	/* non tcp/udp packets */
+	if (!cqe->header_length)
+		return -1;
+
+	/* non tcp packet */
+	skb_reset_network_header(skb);
+	iph = ip_hdr(skb);
+	if (iph->protocol != IPPROTO_TCP)
+		return -1;
+
+	ip_hdrlength = ip_hdrlen(skb);
+	skb_set_transport_header(skb, ip_hdrlength);
+	*tcph = tcp_hdr(skb);
+
+	/* check if ip header and tcp header are complete */
+	if (iph->tot_len < ip_hdrlength + tcp_hdrlen(skb))
+		return -1;
+
+	*iphdr = iph;
+	return 0;
+}
+
+static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
+		     struct sk_buff *skb)
+{
+	int vlan_extracted = (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
+		&& pr->port->vgrp;
+
+	if (use_lro) {
+		if (vlan_extracted)
+			lro_vlan_hwaccel_receive_skb(&pr->lro_mgr, skb,
+						     pr->port->vgrp,
+						     cqe->vlan_tag,
+						     cqe);
+		else
+			lro_receive_skb(&pr->lro_mgr, skb, cqe);
+	} else {
+		if (vlan_extracted)
+			vlan_hwaccel_receive_skb(skb, pr->port->vgrp,
+						 cqe->vlan_tag);
+		else
+			netif_receive_skb(skb);
+	}
+}
+
 static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 					struct ehea_port_res *pr,
 					int *budget)
@@ -426,6 +489,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 					if (!skb)
 						break;
 				}
+				skb_reserve(skb, NET_IP_ALIGN);
 				skb_copy_to_linear_data(skb, ((char*)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
 				ehea_fill_skb(port->netdev, skb, cqe);
@@ -451,12 +515,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 				processed_rq3++;
 			}
 
-			if ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
-			    && port->vgrp)
-				vlan_hwaccel_receive_skb(skb, port->vgrp,
-							 cqe->vlan_tag);
-			else
-				netif_receive_skb(skb);
+			ehea_proc_skb(pr, cqe, skb);
 		} else {
 			pr->p_stats.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
@@ -468,6 +527,9 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 		cqe = ehea_poll_rq1(qp, &wqe_index);
 	}
 
+	if (use_lro)
+		lro_flush_all(&pr->lro_mgr);
+
 	pr->rx_packets += processed;
 	*budget -= processed;
 
@@ -1205,6 +1267,11 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 	set_bit(__LINK_STATE_START, &pr->d_netdev->state);
 	strcpy(pr->d_netdev->name, port->netdev->name);
 
+	pr->lro_mgr.max_aggr = pr->port->lro_max_aggr;
+	pr->lro_mgr.max_desc = MAX_LRO_DESCRIPTORS;
+	pr->lro_mgr.lro_arr = pr->lro_desc;
+	pr->lro_mgr.get_ip_tcp_hdr = try_get_ip_tcp_hdr;
+
 	ret = 0;
 	goto out;
 
@@ -1684,9 +1751,25 @@ out:
 
 static int ehea_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct ehea_port *port = netdev_priv(dev);
+	int i;
+	int lro_aggr;
+
 	if ((new_mtu < 68) || (new_mtu > EHEA_MAX_PACKET_SIZE))
 		return -EINVAL;
 	dev->mtu = new_mtu;
+
+	if (use_lro) {
+		port->lro_max_aggr = (0xFFFF / new_mtu);
+
+		lro_aggr = (0xFFFF / dev->mtu);
+		if (lro_aggr > lro_max_pkts)
+			lro_aggr = lro_max_pkts;
+
+		for (i = 0; i < port->num_def_qps; i++)
+			port->port_res[i].lro_mgr.max_aggr = lro_aggr;
+	}
+
 	return 0;
 }
 
@@ -2491,6 +2574,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	struct ehea_port *port;
 	struct device *port_dev;
 	int jumbo;
+	int lro_pkts;
 
 	/* allocate memory for the port structures */
 	dev = alloc_etherdev(sizeof(struct ehea_port));
@@ -2565,6 +2649,12 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		goto out_unreg_port;
 	}
 
+	lro_pkts = (0xFFFF / dev->mtu);
+	if (lro_pkts < lro_max_pkts)
+		port->lro_max_aggr = lro_pkts;
+	else
+		port->lro_max_aggr = lro_max_pkts;
+
 	ret = ehea_get_jumboframe_status(port, &jumbo);
 	if (ret)
 		ehea_error("failed determining jumbo frame status for %s",
-- 
1.5.2

