From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] lro: eHEA example how to use LRO
Date: Fri, 3 Aug 2007 14:41:26 +0200
Message-ID: <200708031441.26841.ossthema@de.ibm.com>
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
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:57032 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489AbXHCNKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 09:10:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch shows how the generic LRO interface is used for SKB mode

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 drivers/net/Kconfig             |    1 +
 drivers/net/ehea/ehea.h         |    9 ++++-
 drivers/net/ehea/ehea_ethtool.c |   15 +++++++
 drivers/net/ehea/ehea_main.c    |   84 +++++++++++++++++++++++++++++++++++---
 4 files changed, 101 insertions(+), 8 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f8a602c..fec4004 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2399,6 +2399,7 @@ config CHELSIO_T3
 config EHEA
 	tristate "eHEA Ethernet support"
 	depends on IBMEBUS
+	select INET_LRO
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
 
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index d67f97b..70e33fe 100644
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
-#define DRV_VERSION	"EHEA_0073"
+#define DRV_VERSION	"EHEA_0074"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -58,6 +59,7 @@
 
 #define EHEA_SMALL_QUEUES
 #define EHEA_NUM_TX_QP 1
+#define EHEA_LRO_MAX_AGGR 64
 
 #ifdef EHEA_SMALL_QUEUES
 #define EHEA_MAX_CQE_COUNT      1023
@@ -84,6 +86,8 @@
 #define EHEA_RQ2_PKT_SIZE       1522
 #define EHEA_L_PKT_SIZE         256	/* low latency */
 
+#define MAX_LRO_DESCRIPTORS 8
+
 /* Send completion signaling */
 
 /* Protection Domain Identifier */
@@ -376,6 +380,8 @@ struct ehea_port_res {
 	u64 tx_packets;
 	u64 rx_packets;
 	u32 poll_counter;
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_desc[MAX_LRO_DESCRIPTORS];
 };
 
 
@@ -427,6 +433,7 @@ struct ehea_port {
 	u32 msg_enable;
 	u32 sig_comp_iv;
 	u32 state;
+	u32 lro_max_aggr;
 	u8 full_duplex;
 	u8 autoneg;
 	u8 num_def_qps;
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index decec8c..29ef7a9 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -183,6 +183,9 @@ static char ehea_ethtool_stats_keys[][ETH_GSTRING_LEN] = {
 	{"PR5 free_swqes"},
 	{"PR6 free_swqes"},
 	{"PR7 free_swqes"},
+	{"LRO aggregated"},
+	{"LRO flushed"},
+	{"LRO no_desc"},
 };
 
 static void ehea_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -239,6 +242,18 @@ static void ehea_get_ethtool_stats(struct net_device *dev,
 	for (k = 0; k < 8; k++)
 		data[i++] = atomic_read(&port->port_res[k].swqe_avail);
 
+	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
+		tmp |= port->port_res[k].lro_mgr.stats.aggregated;
+	data[i++] = tmp;
+
+	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
+		tmp |= port->port_res[k].lro_mgr.stats.flushed;
+	data[i++] = tmp;
+
+	for (k = 0, tmp = 0; k < EHEA_MAX_PORT_RES; k++)
+		tmp |= port->port_res[k].lro_mgr.stats.no_desc;
+	data[i++] = tmp;
+
 }
 
 const struct ethtool_ops ehea_ethtool_ops = {
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 9756211..fbaa395 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -52,6 +52,8 @@ static int rq2_entries = EHEA_DEF_ENTRIES_RQ2;
 static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
 static int sq_entries = EHEA_DEF_ENTRIES_SQ;
 static int use_mcs = 0;
+static int use_lro = 0;
+static int lro_max_aggr = EHEA_LRO_MAX_AGGR;
 static int num_tx_qps = EHEA_NUM_TX_QP;
 
 module_param(msg_level, int, 0);
@@ -60,6 +62,8 @@ module_param(rq2_entries, int, 0);
 module_param(rq3_entries, int, 0);
 module_param(sq_entries, int, 0);
 module_param(use_mcs, int, 0);
+module_param(use_lro, int, 0);
+module_param(lro_max_aggr, int, 0);
 module_param(num_tx_qps, int, 0);
 
 MODULE_PARM_DESC(num_tx_qps, "Number of TX-QPS");
@@ -77,6 +81,10 @@ MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
 		 "[2^x - 1], x = [6..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
 MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
+MODULE_PARM_DESC(lro_max_aggr, " LRO: Max packets to be aggregated. Default = "
+		 __MODULE_STRING(EHEA_LRO_MAX_AGGR));
+MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
+                 "Default = 0");
 
 static int port_name_cnt = 0;
 static LIST_HEAD(adapter_list);
@@ -389,6 +397,60 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	return 0;
 }
 
+static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
+		       void **tcph, u64 *hdr_flags, void *priv)
+{
+	struct ehea_cqe *cqe = priv;
+	unsigned int ip_len;
+	struct iphdr *iph;
+
+        /* non tcp/udp packets */
+	if (!cqe->header_length)
+		return -1;
+
+        /* non tcp packet */
+	skb_reset_network_header(skb);
+	iph = ip_hdr(skb);
+	if (iph->protocol != IPPROTO_TCP)
+		return -1;
+
+	ip_len = ip_hdrlen(skb);
+	skb_set_transport_header(skb, ip_len);
+	*tcph = tcp_hdr(skb);
+
+        /* check if ip header and tcp header are complete */
+	if (iph->tot_len < ip_len + tcp_hdrlen(skb))
+		return -1;
+
+	*hdr_flags = LRO_IPV4 | LRO_TCP;
+	*iphdr = iph;
+
+	return 0;
+}
+
+static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
+			  struct sk_buff *skb)
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
@@ -460,13 +522,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 				processed_rq3++;
 			}
 
-			if ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
-			    && port->vgrp)
-				vlan_hwaccel_receive_skb(skb, port->vgrp,
-							 cqe->vlan_tag);
-			else
-				netif_receive_skb(skb);
-
+			ehea_proc_skb(pr, cqe, skb);
 			dev->last_rx = jiffies;
 		} else {
 			pr->p_stats.poll_receive_errors++;
@@ -478,6 +534,8 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 		}
 		cqe = ehea_poll_rq1(qp, &wqe_index);
 	}
+	if (use_lro)
+		lro_flush_all(&pr->lro_mgr);
 
 	pr->rx_packets += processed;
 	*budget -= processed;
@@ -1233,6 +1291,15 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 	set_bit(__LINK_STATE_START, &pr->d_netdev->state);
 	strcpy(pr->d_netdev->name, port->netdev->name);
 
+	pr->lro_mgr.max_aggr = pr->port->lro_max_aggr;
+	pr->lro_mgr.max_desc = MAX_LRO_DESCRIPTORS;
+	pr->lro_mgr.lro_arr = pr->lro_desc;
+	pr->lro_mgr.get_skb_header = get_skb_hdr;
+	pr->lro_mgr.features = LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
+	pr->lro_mgr.dev = port->netdev;
+	pr->lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
+	pr->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
+
 	ret = 0;
 	goto out;
 
@@ -1712,6 +1779,7 @@ static int ehea_change_mtu(struct net_device *dev, int new_mtu)
 	if ((new_mtu < 68) || (new_mtu > EHEA_MAX_PACKET_SIZE))
 		return -EINVAL;
 	dev->mtu = new_mtu;
+
 	return 0;
 }
 
@@ -2669,6 +2737,8 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		goto out_dereg_bc;
 	}
 
+	port->lro_max_aggr = lro_max_aggr;
+
 	ret = ehea_get_jumboframe_status(port, &jumbo);
 	if (ret)
 		ehea_error("failed determining jumbo frame status for %s",
-- 
1.5.2

