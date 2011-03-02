From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH 27/27] HFI: hf ethtool support
Date: Wed,  2 Mar 2011 16:10:13 -0500
Message-ID: <1299100213-8770-27-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:58713 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756919Ab1CBVK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 16:10:28 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p22L0iQi020232
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:00:44 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 553D46E8038
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 16:10:27 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p22LARge216434
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:10:27 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p22LAQij032262
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:10:26 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
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
 drivers/net/hfi/ip/Makefile     |    2 +-
 drivers/net/hfi/ip/hf_ethtool.c |  136 +++++++++++++++++++++++++++++++++++++++
 drivers/net/hfi/ip/hf_if_main.c |   34 +++++++++-
 drivers/net/hfi/ip/hf_proto.h   |    1 +
 include/linux/hfi/hf_if.h       |   32 +++++++++
 5 files changed, 200 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/hfi/ip/hf_ethtool.c

diff --git a/drivers/net/hfi/ip/Makefile b/drivers/net/hfi/ip/Makefile
index 59eff9b..2909b00 100644
--- a/drivers/net/hfi/ip/Makefile
+++ b/drivers/net/hfi/ip/Makefile
@@ -3,4 +3,4 @@
 #
 obj-$(CONFIG_HFI_IP) += hf_if.o
 
-hf_if-objs :=	hf_if_main.o
+hf_if-objs :=	hf_if_main.o hf_ethtool.o
diff --git a/drivers/net/hfi/ip/hf_ethtool.c b/drivers/net/hfi/ip/hf_ethtool.c
new file mode 100644
index 0000000..8fd48d0
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
+#include <linux/hfi/hf_if.h>
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
+		return -EOPNOTSUPP;
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
diff --git a/drivers/net/hfi/ip/hf_if_main.c b/drivers/net/hfi/ip/hf_if_main.c
index 10dc1da..e45b48f 100644
--- a/drivers/net/hfi/ip/hf_if_main.c
+++ b/drivers/net/hfi/ip/hf_if_main.c
@@ -231,6 +231,7 @@ static int hf_send_intr_callback(void *parm, u32 win, u32 ext)
 	mb();
 
 	netif_wake_queue(net->netdev);
+	net->hfif.eth_stats.send_intr_fired++;
 
 	return 0;
 }
@@ -241,6 +242,7 @@ static int hf_recv_intr_callback(void *parm, u32 win, u32 ext)
 
 	napi_schedule(&(net->napi));
 
+	net->hfif.eth_stats.recv_intr_fired++;
 	return 0;
 }
 
@@ -400,6 +402,9 @@ static void hf_set_recv_intr(struct hf_if *net_if)
 	hf_mmio_regs_write_then_read(net_if, HFI_RFIFO_INTR_REG,
 		(HF_ENA_RECV_INTR + (offset << HF_RECV_INTR_MATCH_SHIFT)));
 
+	net_if->eth_stats.recv_intr_offset = offset;
+	net_if->eth_stats.recv_intr_armed++;
+
 	/* check if there is packet received in the mean time */
 	rx_pkt = net_if->rx_fifo.addr + (offset << HFI_CACHE_LINE_SHIFT);
 
@@ -409,6 +414,9 @@ static void hf_set_recv_intr(struct hf_if *net_if)
 		/* force an immediate recv intr */
 		hf_mmio_regs_write(net_if, HFI_RFIFO_INTR_REG,
 		(HF_IMM_RECV_INTR + (offset << HF_RECV_INTR_MATCH_SHIFT)));
+
+		net_if->eth_stats.recv_imm_intr_offset = offset;
+		net_if->eth_stats.recv_imm_intr_armed++;
 	}
 }
 
@@ -527,7 +535,7 @@ static int hf_net_open(struct net_device *netdev)
 	struct hfidd_acs	*p_acs = HF_ACS(net_if);
 
 	memset(&(net_if->net_stats), 0, sizeof(struct net_device_stats));
-	net_if->sfifo_packets = 0;
+	memset(&(net_if->eth_stats), 0, sizeof(struct hf_ethtool_stats));
 
 	spin_lock(&(net_if->lock));
 	net_if->state = HF_NET_HALF_OPEN;
@@ -637,6 +645,7 @@ static inline int hf_check_hdr_version(struct hf_if *net_if,
 			"%s: hf_check_hdr_version: hdr version 0x%x "
 			"does not match 0x%x\n",
 			net_if->name, hf_hdr->version, HF_PROTO_HDR_VERSION);
+		net_if->eth_stats.rx_version_mismatch++;
 		net_if->net_stats.rx_dropped++;
 
 		return -EINVAL;
@@ -733,6 +742,7 @@ static void hf_recv_ip_with_payload(struct hf_net *net,
 	net_if->net_stats.rx_packets++;
 	net_if->net_stats.rx_bytes += skb->len;
 
+	net_if->eth_stats.payload_recv++;
 	netif_receive_skb(skb);
 }
 
@@ -756,6 +766,7 @@ static void hf_recv_ip_good(struct hf_net *net,
 			rx_curr->type.header_type, pkt_len);
 
 		/* unknown packet, drop it */
+		net_if->eth_stats.rx_err_hdr_type++;
 		net_if->net_stats.rx_dropped++;
 		break;
 	}
@@ -792,6 +803,7 @@ static int hf_rx(struct hf_net *net, int budget)
 				"status = 0x%x, pkt_len = 0x%x\n",
 				status, pkt_len);
 
+			net_if->eth_stats.rx_err_status++;
 			net_if->net_stats.rx_dropped++;
 		}
 
@@ -807,6 +819,7 @@ static int hf_rx(struct hf_net *net, int budget)
 			hf_mmio_regs_write(net_if, HFI_RFIFO_INC_FSLOT_REG,
 					net_if->rx_fslot_debt);
 			net_if->rx_fslot_debt = 0;
+			net_if->eth_stats.mmio_rx_inc_avail++;
 		}
 
 		budget--;
@@ -816,6 +829,7 @@ static int hf_rx(struct hf_net *net, int budget)
 
 	}
 
+	net_if->eth_stats.rx_fslot_debt = net_if->rx_fslot_debt;
 	netdev_dbg(net->netdev, "hf_rx: exit, head = 0x%x, recv 0x%x pkts\n",
 			net_if->rx_fifo.head, num);
 
@@ -885,9 +899,10 @@ int hf_tx_check_avail(struct hf_net *net, u32 xmit_cls)
 			u64		intr_thresh;
 
 			netif_stop_queue(netdev);
+			net_if->eth_stats.tx_queue_stop++;
 
 			/* turn on transmit interrupt */
-			intr_thresh = (net_if->sfifo_packets -
+			intr_thresh = (net_if->eth_stats.sfifo_packets -
 			HF_SFIFO_INTR_WATERMARK) & HF_SFIFO_INTR_MASK;
 
 			intr_cntl = HF_SFIFO_INTR_ENABLE |
@@ -896,6 +911,7 @@ int hf_tx_check_avail(struct hf_net *net, u32 xmit_cls)
 			hf_mmio_regs_write_then_read(net_if,
 					HFI_SFIFO_INTR_CNTL, intr_cntl);
 
+			net_if->eth_stats.sfifo_send_intr_armed++;
 			return -EBUSY;
 		}
 	}
@@ -978,6 +994,7 @@ static char *hf_build_payload_hdr(struct hf_net *net,
 			" not supported\n", hwhdr_p->h_proto);
 
 		dev_kfree_skb_any(skb);
+		net_if->eth_stats.tx_drop++;
 		return NULL;
 	}
 
@@ -1072,7 +1089,8 @@ static int hf_payload_tx(struct sk_buff *skb, struct hf_net *net, u32 is_bcast)
 		(net_if->tx_fifo.tail + xmit_cls) & (net_if->tx_fifo.emax);
 	atomic_sub(xmit_cls, &(net_if->tx_fifo.avail));
 
-	net_if->sfifo_packets++;
+	net_if->eth_stats.sfifo_packets++;
+	net_if->eth_stats.payload_sent++;
 	net_if->net_stats.tx_packets++;
 	net_if->net_stats.tx_bytes += msg_len;
 
@@ -1100,6 +1118,7 @@ static int hf_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		netdev_err(netdev, "hf_start_xmit: invalid skb->len 0x%x\n",
 						skb->len);
 		dev_kfree_skb_any(skb);
+		net_if->eth_stats.tx_drop++;
 		return NETDEV_TX_OK;
 	}
 
@@ -1140,8 +1159,12 @@ static int hf_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 static void hf_tx_timeout(struct net_device *netdev)
 {
+	struct hf_net	*net = netdev_priv(netdev);
+	struct hf_if	*net_if = &(net->hfif);
+
 	netdev_warn(netdev, "hf_tx_timeout: queue_stopped is %d\n",
 			netif_queue_stopped(netdev));
+	net_if->eth_stats.tx_timeout++;
 }
 
 struct net_device_stats *hf_get_stats(struct net_device *netdev)
@@ -1238,6 +1261,7 @@ static int hf_poll(struct napi_struct *napi, int budget)
 	net_if	= &(net->hfif);
 	netdev	= net->netdev;
 
+	net_if->eth_stats.in_poll++;
 	work_done = hf_rx(net, budget);
 
 	/* Always assume we have received all available packets */
@@ -1246,7 +1270,8 @@ static int hf_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		isync();
 		hf_set_recv_intr(net_if);
-	}
+	} else
+		net_if->eth_stats.max_poll_recv++;
 
 	return work_done;
 }
@@ -1279,6 +1304,7 @@ static struct hf_net *hf_init_netdev(int idx, int ai)
 	net->hfif.state = HF_NET_CLOSE;
 
 	spin_lock_init(&net->hfif.lock);
+	hf_set_ethtool_ops(netdev);
 
 	rc = register_netdev(netdev);
 	if (rc) {
diff --git a/drivers/net/hfi/ip/hf_proto.h b/drivers/net/hfi/ip/hf_proto.h
index b70ecdd..6f53959 100644
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
diff --git a/include/linux/hfi/hf_if.h b/include/linux/hfi/hf_if.h
index 39bcdae..85aa90f 100644
--- a/include/linux/hfi/hf_if.h
+++ b/include/linux/hfi/hf_if.h
@@ -38,9 +38,11 @@
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
+#include <linux/etherdevice.h>
 #include <net/arp.h>
 
 #include <linux/hfi/hfidd_internal.h>
+#include <linux/hfi/hfidd_adpt.h>
 #include <linux/hfi/hfidd_client.h>
 #include <linux/hfi/hfidd_requests.h>
 #include <linux/hfi/hfidd_regs.h>
@@ -157,6 +159,35 @@ struct hf_fifo {
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
@@ -180,6 +211,7 @@ struct hf_if {
 							   2k skb */
 	void			*sfifo_finishvec;
 	struct net_device_stats	net_stats;
+	struct hf_ethtool_stats eth_stats;
 };
 
 /* Private structure for HF inetrface */
-- 
1.7.3.1

