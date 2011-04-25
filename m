From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v4 27/27] HFI: hfi_ip ethtool support
Date: Mon, 25 Apr 2011 17:24:07 -0400
Message-ID: <1303766647-30156-28-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:54324 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755104Ab1DYVYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 17:24:35 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PL8CUe006045
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:08:12 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3PLOZtp108938
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:35 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PLOYV3001072
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:34 -0600
In-Reply-To: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Signed-off-by:  Piyush Chaudhary <piyushc@linux.vnet.ibm.com>
Signed-off-by:  Jim Dykman <dykmanj@linux.vnet.ibm.com>
Signed-off-by:  Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
Signed-off-by:  William S. Cadden <wscadden@linux.vnet.ibm.com>
Signed-off-by:  Wen C. Chen <winstonc@linux.vnet.ibm.com>
Signed-off-by:  Scot Sakolish <sakolish@linux.vnet.ibm.com>
Signed-off-by:  Jian Xiao <jian@linux.vnet.ibm.com>
Signed-off-by:  Carol L. Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by:  Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
---
 drivers/net/hfi/ip/Makefile      |    2 +-
 drivers/net/hfi/ip/hf_ethtool.c  |  136 ++++++++++++++++++++++++++++++++++++++
 drivers/net/hfi/ip/hf_proto.h    |    1 +
 drivers/net/hfi/ip/hfi_ip_main.c |   36 +++++++++-
 include/linux/hfi/hfi_ip.h       |   32 +++++++++-
 5 files changed, 201 insertions(+), 6 deletions(-)
 create mode 100644 drivers/net/hfi/ip/hf_ethtool.c

diff --git a/drivers/net/hfi/ip/Makefile b/drivers/net/hfi/ip/Makefile
index 90c7dea..28a4a51 100644
--- a/drivers/net/hfi/ip/Makefile
+++ b/drivers/net/hfi/ip/Makefile
@@ -3,4 +3,4 @@
 #
 obj-$(CONFIG_HFI_IP) += hfi_ip.o
 
-hfi_ip-objs :=	hfi_ip_main.o
+hfi_ip-objs :=	hfi_ip_main.o hf_ethtool.o
diff --git a/drivers/net/hfi/ip/hf_ethtool.c b/drivers/net/hfi/ip/hf_ethtool.c
new file mode 100644
index 0000000..204a1bf
--- /dev/null
+++ b/drivers/net/hfi/ip/hf_ethtool.c
@@ -0,0 +1,136 @@
+/*
+ * hf_ethtool.c
+ *
+ * HF IP driver for IBM System p
+ *
+ *  Authors:
+ *	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *	William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *	Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *	Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *	Jian Xiao <jian@linux.vnet.ibm.com>
+ *	Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *	Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include <linux/ethtool.h>
+
+#include <linux/hfi/hfi_ip.h>
+
+static char hf_ethtool_stats_keys[][ETH_GSTRING_LEN] = {
+	{"sfifo_packets"},
+	{"rdma_packets"},
+	{"tx_timeout"},
+	{"tx_queue_stop"},
+	{"tx_drop"},
+	{"tx_err_headlen"},
+	{"rx_version_mismatch"},
+	{"rx_err_restore"},
+	{"rx_err_cookie"},
+	{"rx_err_skb"},
+	{"rx_err_hdr_type"},
+	{"rx_err_msg_type"},
+	{"rx_err_status"},
+	{"rx_err_bcast_csum"},
+	{"rx_fslot_debt"},
+	{"mmio_rx_inc_avail"},
+	{"mmio_rx_post_desc"},
+	{"payload_sent"},
+	{"desc_sent"},
+	{"large_bcast_sent"},
+	{"super_sent"},
+	{"payload_recv"},
+	{"desc_recv"},
+	{"rdma_write"},
+	{"rdma_write_fail"},
+	{"rdma_cancel"},
+	{"rdma_cancel_fail"},
+	{"rdma_cancel_already"},
+	{"rdma_rndz_request_sent"},
+	{"rdma_rndz_request_fail"},
+	{"rdma_rndz_reply_recv"},
+	{"rdma_rndz_reply_fail"},
+	{"rdma_rndz_request_recv"},
+	{"rdma_rndz_reply_sent"},
+	{"bad_rdma_notification"},
+	{"bad_rdma_first_notification"},
+	{"rdma_src_completion"},
+	{"rdma_sink_completion"},
+	{"rdma_send_timeout"},
+	{"rdma_recv_timeout"},
+	{"sfifo_send_intr_armed"},
+	{"rdma_send_intr_armed"},
+	{"recv_intr_armed"},
+	{"recv_intr_offset"},
+	{"recv_imm_intr_armed"},
+	{"recv_imm_intr_offset"},
+	{"send_intr_fired"},
+	{"recv_intr_fired"},
+	{"in_poll"},
+	{"max_poll_recv"},
+};
+
+static void hf_get_drvinfo(struct net_device *netdev,
+		struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, HF_DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, HF_DRV_VERSION, sizeof(info->version));
+}
+
+static void hf_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, &hf_ethtool_stats_keys,
+				sizeof(hf_ethtool_stats_keys));
+		break;
+	}
+}
+
+static int hf_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(hf_ethtool_stats_keys);
+	default:
+		return -EINVAL;
+	}
+}
+
+static void hf_get_ethtool_stats(struct net_device *netdev,
+		struct ethtool_stats *stats, u64 *data)
+{
+	struct hf_net	*net = netdev_priv(netdev);
+	struct hf_if	*net_if = &(net->hfif);
+
+	memcpy(data, &(net_if->eth_stats), sizeof(struct hf_ethtool_stats));
+}
+
+static const struct ethtool_ops hf_ethtool_ops = {
+	.get_drvinfo		= hf_get_drvinfo,
+	.get_strings		= hf_get_strings,
+	.get_sset_count		= hf_get_sset_count,
+	.get_ethtool_stats	= hf_get_ethtool_stats,
+};
+
+void hf_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &hf_ethtool_ops);
+}
diff --git a/drivers/net/hfi/ip/hf_proto.h b/drivers/net/hfi/ip/hf_proto.h
index 022512a..3b2b23b 100644
--- a/drivers/net/hfi/ip/hf_proto.h
+++ b/drivers/net/hfi/ip/hf_proto.h
@@ -36,6 +36,7 @@
 int hf_tx_check_avail(struct hf_net *net, u32 xmit_cls);
 void hf_construct_hwhdr(struct hf_if *net_if, struct sk_buff *skb,
 			struct base_hdr *b_hdr);
+void hf_set_ethtool_ops(struct net_device *netdev);
 extern int hfidd_open_window_func(struct hfidd_acs *p_acs,
 		u32 is_userspace,
 		struct hfi_client_info *user_p,
diff --git a/drivers/net/hfi/ip/hfi_ip_main.c b/drivers/net/hfi/ip/hfi_ip_main.c
index 6b2ec3f..4b897d3 100644
--- a/drivers/net/hfi/ip/hfi_ip_main.c
+++ b/drivers/net/hfi/ip/hfi_ip_main.c
@@ -208,6 +208,7 @@ static int hf_send_intr_callback(void *parm, u32 win, u32 ext)
 	mb();
 
 	netif_wake_queue(net->netdev);
+	net->hfif.eth_stats.send_intr_fired++;
 
 	return 0;
 }
@@ -218,6 +219,7 @@ static int hf_recv_intr_callback(void *parm, u32 win, u32 ext)
 
 	napi_schedule(&(net->napi));
 
+	net->hfif.eth_stats.recv_intr_fired++;
 	return 0;
 }
 
@@ -381,6 +383,9 @@ static void hf_set_recv_intr(struct hf_if *net_if)
 	hf_mmio_regs_write_then_read(net_if, HFI_RFIFO_INTR_REG,
 		(HF_ENA_RECV_INTR + (offset << HF_RECV_INTR_MATCH_SHIFT)));
 
+	net_if->eth_stats.recv_intr_offset = offset;
+	net_if->eth_stats.recv_intr_armed++;
+
 	/* check if there is packet received in the mean time */
 	rx_pkt = net_if->rx_fifo.addr + (offset << HFI_CACHE_LINE_SHIFT);
 
@@ -390,6 +395,9 @@ static void hf_set_recv_intr(struct hf_if *net_if)
 		/* force an immediate recv intr */
 		hf_mmio_regs_write(net_if, HFI_RFIFO_INTR_REG,
 		(HF_IMM_RECV_INTR + (offset << HF_RECV_INTR_MATCH_SHIFT)));
+
+		net_if->eth_stats.recv_imm_intr_offset = offset;
+		net_if->eth_stats.recv_imm_intr_armed++;
 	}
 }
 
@@ -507,7 +515,7 @@ static int hf_net_open(struct net_device *netdev)
 	struct hfidd_acs	*p_acs = HF_ACS(net_if);
 
 	memset(&(netdev->stats), 0, sizeof(struct net_device_stats));
-	net_if->sfifo_packets = 0;
+	memset(&(net_if->eth_stats), 0, sizeof(struct hf_ethtool_stats));
 
 	spin_lock(&(net_if->lock));
 	net_if->state = HF_NET_HALF_OPEN;
@@ -614,6 +622,7 @@ static inline int hf_check_hdr_version(struct hf_net *net,
 			"hf_check_hdr_version: hdr version 0x%x "
 			"does not match 0x%x\n",
 			hf_hdr->version, HF_PROTO_HDR_VERSION);
+		net->hfif.eth_stats.rx_version_mismatch++;
 		net->netdev->stats.rx_dropped++;
 		return -EINVAL;
 	}
@@ -710,6 +719,7 @@ static void hf_recv_ip_with_payload(struct hf_net *net,
 	netdev->stats.rx_packets++;
 	netdev->stats.rx_bytes += skb->len;
 
+	net_if->eth_stats.payload_recv++;
 	netif_receive_skb(skb);
 }
 
@@ -717,6 +727,8 @@ static void hf_recv_ip_good(struct hf_net *net,
 			    struct hfi_hdr *rx_curr,
 			    u32 pkt_len)
 {
+	struct hf_if	*net_if = &(net->hfif);
+
 	switch (rx_curr->type.header_type) {
 
 	case  HFI_IP_WITH_PAYLOAD:
@@ -731,6 +743,7 @@ static void hf_recv_ip_good(struct hf_net *net,
 			rx_curr->type.header_type, pkt_len);
 
 		/* unknown packet, drop it */
+		net_if->eth_stats.rx_err_hdr_type++;
 		net->netdev->stats.rx_dropped++;
 		break;
 	}
@@ -767,6 +780,7 @@ static int hf_rx(struct hf_net *net, int budget)
 				"status = 0x%x, pkt_len = 0x%x\n",
 				status, pkt_len);
 
+			net_if->eth_stats.rx_err_status++;
 			net->netdev->stats.rx_dropped++;
 		}
 
@@ -782,6 +796,7 @@ static int hf_rx(struct hf_net *net, int budget)
 			hf_mmio_regs_write(net_if, HFI_RFIFO_INC_FSLOT_REG,
 					net_if->rx_fslot_debt);
 			net_if->rx_fslot_debt = 0;
+			net_if->eth_stats.mmio_rx_inc_avail++;
 		}
 
 		budget--;
@@ -791,6 +806,7 @@ static int hf_rx(struct hf_net *net, int budget)
 
 	}
 
+	net_if->eth_stats.rx_fslot_debt = net_if->rx_fslot_debt;
 	netdev_dbg(net->netdev, "hf_rx: exit, head = 0x%x, recv 0x%x pkts\n",
 			net_if->rx_fifo.head, num);
 
@@ -860,9 +876,10 @@ int hf_tx_check_avail(struct hf_net *net, u32 xmit_cls)
 			u64		intr_thresh;
 
 			netif_stop_queue(netdev);
+			net_if->eth_stats.tx_queue_stop++;
 
 			/* turn on transmit interrupt */
-			intr_thresh = (net_if->sfifo_packets -
+			intr_thresh = (net_if->eth_stats.sfifo_packets -
 			HF_SFIFO_INTR_WATERMARK) & HF_SFIFO_INTR_MASK;
 
 			intr_cntl = HF_SFIFO_INTR_ENABLE |
@@ -871,6 +888,7 @@ int hf_tx_check_avail(struct hf_net *net, u32 xmit_cls)
 			hf_mmio_regs_write_then_read(net_if,
 					HFI_SFIFO_INTR_CNTL, intr_cntl);
 
+			net_if->eth_stats.sfifo_send_intr_armed++;
 			return -EBUSY;
 		}
 	}
@@ -957,6 +975,7 @@ static char *hf_build_payload_hdr(struct hf_net *net,
 			" not supported\n", hwhdr_p->h_proto);
 
 		dev_kfree_skb_any(skb);
+		net_if->eth_stats.tx_drop++;
 		return NULL;
 	}
 
@@ -1051,7 +1070,8 @@ static int hf_payload_tx(struct sk_buff *skb, struct hf_net *net, u32 is_bcast)
 		(net_if->tx_fifo.tail + xmit_cls) & (net_if->tx_fifo.emax);
 	atomic_sub(xmit_cls, &(net_if->tx_fifo.avail));
 
-	net_if->sfifo_packets++;
+	net_if->eth_stats.sfifo_packets++;
+	net_if->eth_stats.payload_sent++;
 	net->netdev->stats.tx_packets++;
 	net->netdev->stats.tx_bytes += msg_len;
 
@@ -1079,6 +1099,7 @@ static int hf_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		netdev_err(netdev, "hf_start_xmit: invalid skb->len 0x%x\n",
 						skb->len);
 		dev_kfree_skb_any(skb);
+		net_if->eth_stats.tx_drop++;
 		return NETDEV_TX_OK;
 	}
 
@@ -1119,8 +1140,12 @@ static int hf_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 static void hf_tx_timeout(struct net_device *netdev)
 {
+	struct hf_net	*net = netdev_priv(netdev);
+	struct hf_if	*net_if = &(net->hfif);
+
 	netdev_warn(netdev, "hf_tx_timeout: queue_stopped is %d\n",
 			netif_queue_stopped(netdev));
+	net_if->eth_stats.tx_timeout++;
 }
 
 static int hf_change_mtu(struct net_device *netdev, int new_mtu)
@@ -1207,6 +1232,7 @@ static int hf_poll(struct napi_struct *napi, int budget)
 	net_if	= &(net->hfif);
 	netdev	= net->netdev;
 
+	net_if->eth_stats.in_poll++;
 	work_done = hf_rx(net, budget);
 
 	/* Always assume we have received all available packets */
@@ -1215,7 +1241,8 @@ static int hf_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		isync();
 		hf_set_recv_intr(net_if);
-	}
+	} else
+		net_if->eth_stats.max_poll_recv++;
 
 	return work_done;
 }
@@ -1248,6 +1275,7 @@ static struct hf_net *hf_init_netdev(int idx, int ai)
 	net->hfif.state = HF_NET_CLOSE;
 
 	spin_lock_init(&net->hfif.lock);
+	hf_set_ethtool_ops(netdev);
 
 	rc = register_netdev(netdev);
 	if (rc) {
diff --git a/include/linux/hfi/hfi_ip.h b/include/linux/hfi/hfi_ip.h
index ec87300..d4317ee 100644
--- a/include/linux/hfi/hfi_ip.h
+++ b/include/linux/hfi/hfi_ip.h
@@ -42,6 +42,7 @@
 #include <net/arp.h>
 
 #include <linux/hfi/hfidd_internal.h>
+#include <linux/hfi/hfidd_adpt.h>
 #include <linux/hfi/hfidd_client.h>
 #include <linux/hfi/hfidd_requests.h>
 #include <linux/hfi/hfidd_regs.h>
@@ -150,6 +151,35 @@ struct hf_fifo {
 #define	HF_NET_HALF_OPEN	0xA0
 #define	HF_NET_OPEN		0xA1
 
+struct hf_ethtool_stats {
+	u64		sfifo_packets;	/* total packets send through sfifo */
+	u64		tx_timeout;
+	u64		tx_queue_stop;
+	u64		tx_drop;
+	u64		tx_err_headlen;
+	u64		rx_version_mismatch;
+	u64		rx_err_skb;
+	u64		rx_err_hdr_type;
+	u64		rx_err_msg_type;
+	u64		rx_err_status;
+	u64		rx_err_bcast_csum;
+	u64		rx_fslot_debt;
+	u64		mmio_rx_inc_avail;
+	u64		payload_sent;	/* packets from IP send with payload
+					   mode */
+	u64		payload_recv;	/* packets delivered to IP with payload
+					   mode */
+	u64		sfifo_send_intr_armed;
+	u64		recv_intr_armed;
+	u64		recv_intr_offset;
+	u64		recv_imm_intr_armed;
+	u64		recv_imm_intr_offset;
+	u64		send_intr_fired;
+	u64		recv_intr_fired;
+	u64		in_poll;
+	u64		max_poll_recv;
+};
+
 struct hf_if {
 	u32			idx;			/* 0, 1, 2, 3 ...   */
 	u32			ai;			/* 0=hfi0, 1=hfi1   */
@@ -160,7 +190,6 @@ struct hf_if {
 	spinlock_t		lock;			/* lock for state */
 	u32			sfifo_fv_polarity;
 	u32			sfifo_slots_per_blk;
-	u32			sfifo_packets;
 	u32			rx_pkt_valid;		/* Polarity of recv
 							   packet valid bit */
 	u32			msg_id;
@@ -172,6 +201,7 @@ struct hf_if {
 	struct sk_buff		**tx_skb;		/* array to store tx
 							   2k skb */
 	void			*sfifo_finishvec;
+	struct hf_ethtool_stats eth_stats;
 };
 
 /* Private structure for HF inetrface */
-- 
1.7.3.5

