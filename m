From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2/2] ehea: Receive SKB Aggregation
Date: Thu, 31 May 2007 13:54:56 +0200
Message-ID: <200705311354.56979.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:29458 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759255AbXEaLy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 07:54:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After there were no technical concerns about this patch I'm resending it with
all whitespace issues fixed which were mentioned by Stephen Rothwell.

This patch enables the receive side processing to aggregate TCP packets within
the HEA device driver. It analyses the packets already received after an
interrupt arrived and forwards these as chains of SKBs for the same TCP
connection with modified header field. We have seen a lower CPU load and
improved throughput for small numbers of parallel TCP connections.

We added a disabled module parameter to prevent disruption of normal driver
operation.
We currently consider this as "experimental" until further review and tests
have been passed.


Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


diff -Nurp -X dontdiff linux-2.6.22-rc3/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.22-rc3/drivers/net/ehea/ehea.h	2007-05-30 13:25:43.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2007-05-30 13:28:16.000000000 +0200
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0062"
+#define DRV_VERSION	"EHEA_0063"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
@@ -49,6 +49,7 @@
 #define EHEA_MAX_ENTRIES_RQ3 16383
 #define EHEA_MAX_ENTRIES_SQ  32767
 #define EHEA_MIN_ENTRIES_QP  127
+#define EHEA_LRO_MAX_PKTS 60
 
 #define EHEA_SMALL_QUEUES
 #define EHEA_NUM_TX_QP 1
@@ -78,6 +79,9 @@
 #define EHEA_RQ2_PKT_SIZE       1522
 #define EHEA_L_PKT_SIZE         256	/* low latency */
 
+#define MAX_LRO_DESCRIPTORS 8
+#define LRO_DESC_MASK 0xFFFFFFFF
+
 /* Send completion signaling */
 
 /* Protection Domain Identifier */
@@ -334,6 +338,29 @@ struct ehea_q_skb_arr {
 };
 
 /*
+ * Large Receive Offload (LRO) descriptor for a tcp seesion
+ */
+struct ehea_lro {
+	struct sk_buff *parent;
+	struct sk_buff *last_skb;
+	struct iphdr *iph;
+	struct tcphdr *tcph;
+
+	u32 tcp_rcv_tsecr;
+	u32 tcp_rcv_tsval;
+	u32 tcp_ack;
+	u32 tcp_next_seq;
+	u32 skb_tot_frags_len;
+	u16 ip_tot_len;
+	u16 tcp_saw_tstamp; 		/* timestamps enabled */
+	u16 tcp_window;
+	u16 vlan_tag;
+	int skb_sg_cnt;			/* counts aggregated skbs */
+	int vlan_packet;
+	int active;
+};
+
+/*
  * Port resources
  */
 struct ehea_port_res {
@@ -362,6 +389,9 @@ struct ehea_port_res {
 	u64 tx_packets;
 	u64 rx_packets;
 	u32 poll_counter;
+	struct ehea_lro lro[MAX_LRO_DESCRIPTORS];
+	u64 lro_desc;
+	struct port_stats p_state;
 };
 
 
@@ -411,6 +441,7 @@ struct ehea_port {
 	u32 msg_enable;
 	u32 sig_comp_iv;
 	u32 state;
+	u32 lro_max_aggr;
 	u8 full_duplex;
 	u8 autoneg;
 	u8 num_def_qps;
diff -Nurp -X dontdiff linux-2.6.22-rc3/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.22-rc3/drivers/net/ehea/ehea_main.c	2007-05-30 13:25:43.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-05-30 13:28:16.000000000 +0200
@@ -34,6 +34,7 @@
 #include <linux/list.h>
 #include <linux/if_ether.h>
 #include <net/ip.h>
+#include <net/tcp.h>
 
 #include "ehea.h"
 #include "ehea_qmr.h"
@@ -52,6 +53,8 @@ static int rq2_entries = EHEA_DEF_ENTRIE
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
@@ -77,6 +82,9 @@ MODULE_PARM_DESC(sq_entries, " Number of
 		 "[2^x - 1], x = [6..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
 MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
+MODULE_PARM_DESC(lro_max_pkts, "LRO: Max packets to be aggregated. Default = "
+		 __MODULE_STRING(EHEA_LRO_MAX_PKTS));
+MODULE_PARM_DESC(use_lro, "1: enable, 0: disable Large Reveive Offload ");
 
 static int port_name_cnt = 0;
 
@@ -380,6 +388,282 @@ static int ehea_treat_poll_error(struct 
 	return 0;
 }
 
+static int try_get_ip_tcp_hdr(struct ehea_cqe *cqe, struct sk_buff *skb,
+			      struct iphdr **iph, struct tcphdr **tcph)
+{
+	int ip_len;
+
+	/* non tcp/udp packets */
+	if (!cqe->header_length)
+		return -1;
+
+	/* non tcp packet */
+	*iph = (struct iphdr *)(skb->data);
+	if ((*iph)->protocol != IPPROTO_TCP)
+		return -1;
+
+	ip_len = (u8)((*iph)->ihl);
+	ip_len <<= 2;
+	*tcph = (struct tcphdr *)(((u64)*iph) + ip_len);
+
+	return 0;
+}
+
+#define TCP_PAYLOAD_LENGTH(iph, tcph) \
+(ntohs(iph->tot_len) - (iph->ihl << 2) - (tcph->doff << 2))
+
+#define IPH_LEN_WO_OPTIONS 5
+#define TCPH_LEN_WO_OPTIONS 5
+#define TCPH_LEN_W_TIMESTAMP 8
+
+static int lro_tcp_check(struct iphdr *iph, struct tcphdr *tcph,
+			 int tcp_data_len, struct ehea_lro *lro)
+{
+	if (tcp_data_len == 0)
+		return -1;
+
+	if (iph->ihl != IPH_LEN_WO_OPTIONS)
+		return -1;
+
+	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack || tcph->psh
+	    || tcph->rst || tcph->syn || tcph->fin)
+		return -1;
+
+	if (INET_ECN_is_ce(ipv4_get_dsfield(iph)))
+		return -1;
+
+	if (tcph->doff != TCPH_LEN_WO_OPTIONS
+	    && tcph->doff != TCPH_LEN_W_TIMESTAMP)
+		return -1;
+
+	/* check tcp options (only timestamp allowed) */
+	if (tcph->doff == TCPH_LEN_W_TIMESTAMP) {
+		u32 *topt = (u32 *)(tcph + 1);
+
+		if (*topt != htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
+				   | (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP))
+			return -1;
+
+		/* timestamp should be in right order */
+		topt++;
+		if (lro && (ntohl(lro->tcp_rcv_tsval) > ntohl(*topt)))
+			return -1;
+
+		/* timestamp reply should not be zero */
+		topt++;
+		if (*topt == 0)
+			return -1;
+	}
+
+	return 0;
+}
+
+static void update_tcp_ip_header(struct ehea_lro *lro)
+{
+	struct iphdr *iph = lro->iph;
+	struct tcphdr *tcph = lro->tcph;
+	u32 *p;
+
+	tcph->ack_seq = lro->tcp_ack;
+	tcph->window = lro->tcp_window;
+
+	if (lro->tcp_saw_tstamp) {
+		p = (u32 *)(tcph + 1);
+		*(p+2) = lro->tcp_rcv_tsecr;
+	}
+
+	iph->tot_len = htons(lro->ip_tot_len);
+	iph->check = 0;
+	iph->check = ip_fast_csum((u8 *)lro->iph, iph->ihl);
+}
+
+static void init_lro_desc(struct ehea_lro *lro, struct ehea_cqe *cqe,
+			  struct sk_buff *skb, struct iphdr *iph,
+			  struct tcphdr *tcph, u32 tcp_data_len)
+{
+	u32 *ptr;
+
+	lro->parent = skb;
+	lro->iph = iph;
+	lro->tcph = tcph;
+	lro->tcp_next_seq = ntohl(tcph->seq) + tcp_data_len;
+	lro->tcp_ack = ntohl(tcph->ack_seq);
+	
+	lro->skb_sg_cnt = 1;
+	lro->ip_tot_len = ntohs(iph->tot_len);
+	
+	if (tcph->doff == 8) {
+		ptr = (u32 *)(tcph+1);
+		lro->tcp_saw_tstamp = 1;
+		lro->tcp_rcv_tsval = *(ptr+1);
+		lro->tcp_rcv_tsecr = *(ptr+2);
+	}
+
+	if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) {
+		lro->vlan_packet = 1;
+		lro->vlan_tag = cqe->vlan_tag;
+	}
+
+	lro->active = 1;
+}
+
+static inline void clear_lro_desc(struct ehea_lro *lro)
+{
+	memset(lro, 0, sizeof(struct ehea_lro));
+}
+
+static void lro_add_packet(struct ehea_lro *lro, struct sk_buff *skb,
+			   struct tcphdr *tcph, u32 tcp_len)
+{
+	struct sk_buff *parent = lro->parent;
+	u32 *topt;
+
+	lro->skb_sg_cnt++;
+	
+	lro->ip_tot_len += tcp_len;
+	lro->tcp_next_seq += tcp_len;
+	lro->tcp_window = lro->tcph->window;
+	lro->tcp_ack = lro->tcph->ack_seq;
+	
+	if (lro->tcp_saw_tstamp) {
+		topt = (u32 *) (tcph + 1);
+		lro->tcp_rcv_tsval = *(topt + 1);
+		lro->tcp_rcv_tsecr = *(topt + 2);
+	}
+
+	parent->len += tcp_len;
+	parent->data_len += tcp_len;
+
+	skb_pull(skb, (skb->len - tcp_len));
+	parent->truesize += skb->truesize;
+
+	if (lro->last_skb)
+		lro->last_skb->next = skb;
+	else
+		skb_shinfo(parent)->frag_list = skb;
+
+	lro->last_skb = skb;
+
+	return;
+}
+
+static int check_tcp_conn(struct ehea_lro *lro, struct iphdr *iph,
+			 struct tcphdr *tcph)
+{
+	// fixme: compare source and destination at the same time? u64 compare?
+	if ((lro->iph->saddr != iph->saddr) || (lro->iph->daddr != iph->daddr) ||
+	    (lro->tcph->source != tcph->source) || (lro->tcph->dest != tcph->dest))
+		return -1;
+	return 0;
+}
+
+static void flush_lro(struct ehea_port_res *pr, struct ehea_lro *lro)
+{
+	update_tcp_ip_header(lro);
+
+	if (lro->vlan_packet)
+		vlan_hwaccel_receive_skb(lro->parent, pr->port->vgrp,
+					 lro->vlan_tag);
+	else
+		netif_receive_skb(lro->parent);
+
+	clear_lro_desc(lro);
+}
+
+static void flush_all_lro(struct ehea_port_res *pr)
+{
+	int i;
+	struct ehea_lro *lro;
+
+	for (i = 0; i < MAX_LRO_DESCRIPTORS; i++) {
+		lro = &pr->lro[i];
+		if (lro->active)
+			flush_lro(pr, lro);
+	}
+}
+
+static struct ehea_lro *ehea_get_lro(struct ehea_port_res *pr,
+				     struct iphdr *iph, struct tcphdr *tcph)
+{
+	struct ehea_lro *lro = NULL;
+	struct ehea_lro *tmp;
+	int i;
+
+	for (i = 0; i < MAX_LRO_DESCRIPTORS; i++) {
+		tmp = &pr->lro[i];
+		if (tmp->active)
+			if (!check_tcp_conn(tmp, iph, tcph)) {
+				lro = tmp;
+				goto out;
+			}
+	}
+
+	for (i = 0; i < MAX_LRO_DESCRIPTORS; i++) {
+		if(!pr->lro[i].active) {
+			lro = &pr->lro[i];
+			goto out;
+		}
+	}
+
+out:
+	return lro;
+}
+
+static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
+		     struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	struct tcphdr *tcph;
+	struct ehea_lro *lro;
+	int tcp_data_len;
+	int skip_orig_skb = 0;
+
+	if (use_lro) {
+		if (try_get_ip_tcp_hdr(cqe, skb, &iph, &tcph))
+			goto out;
+
+		lro = ehea_get_lro(pr, iph, tcph);
+		if (!lro)
+			goto out;
+
+		tcp_data_len = TCP_PAYLOAD_LENGTH(iph, tcph);
+
+		if (!lro->active) {
+			if (lro_tcp_check(iph, tcph, tcp_data_len, NULL))
+				goto out;
+
+			init_lro_desc(lro, cqe, skb, iph, tcph, tcp_data_len);
+			return;
+		}
+
+		if (lro->tcp_next_seq != ntohl(tcph->seq)) {
+			flush_lro(pr, lro);
+			goto out;
+		}
+
+		if (lro_tcp_check(iph, tcph, tcp_data_len, lro)) {
+			flush_lro(pr, lro);
+			goto out;
+		}
+
+		lro_add_packet(lro, skb, tcph, tcp_data_len);
+
+		if (lro->skb_sg_cnt > pr->port->lro_max_aggr)
+			flush_lro(pr, lro);
+
+		skip_orig_skb = 1;
+	}
+
+out:
+	if (skip_orig_skb)
+		return;
+
+	if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
+		vlan_hwaccel_receive_skb(skb, pr->port->vgrp, cqe->vlan_tag);
+	else
+		netif_receive_skb(skb);
+}
+
 static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 					struct ehea_port_res *pr,
 					int *budget)
@@ -426,6 +710,7 @@ static struct ehea_cqe *ehea_proc_rwqes(
 					if (!skb)
 						break;
 				}
+				skb_reserve(skb, NET_IP_ALIGN);
 				skb_copy_to_linear_data(skb, ((char*)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
 				ehea_fill_skb(port->netdev, skb, cqe);
@@ -451,11 +736,7 @@ static struct ehea_cqe *ehea_proc_rwqes(
 				processed_rq3++;
 			}
 
-			if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
-				vlan_hwaccel_receive_skb(skb, port->vgrp,
-							 cqe->vlan_tag);
-			else
-				netif_receive_skb(skb);
+			ehea_proc_skb(pr, cqe, skb);
 		} else {
 			pr->p_stats.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
@@ -467,6 +748,8 @@ static struct ehea_cqe *ehea_proc_rwqes(
 		cqe = ehea_poll_rq1(qp, &wqe_index);
 	}
 
+	flush_all_lro(pr);
+
 	pr->rx_packets += processed;
 	*budget -= processed;
 
@@ -1683,9 +1966,15 @@ out:
 
 static int ehea_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct ehea_port *port = netdev_priv(dev);
+
 	if ((new_mtu < 68) || (new_mtu > EHEA_MAX_PACKET_SIZE))
 		return -EINVAL;
 	dev->mtu = new_mtu;
+
+	if (use_lro)
+		port->lro_max_aggr = (0xFFFF / new_mtu);
+
 	return 0;
 }
 
@@ -2493,6 +2782,7 @@ struct ehea_port *ehea_setup_single_port
 	struct ehea_port *port;
 	struct device *port_dev;
 	int jumbo;
+	int lro_pkts;
 
 	/* allocate memory for the port structures */
 	dev = alloc_etherdev(sizeof(struct ehea_port));
@@ -2567,6 +2857,12 @@ struct ehea_port *ehea_setup_single_port
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


