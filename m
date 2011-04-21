From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 26/27] HFI: hfi_ip fifo receive path
Date: Thu, 21 Apr 2011 17:38:56 -0400
Message-ID: <1303421937-2325-27-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e8.ny.us.ibm.com ([32.97.182.138]:47295 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755285Ab1DUVjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:21 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLDk1j032699
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:13:46 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdD9j593970
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:14 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLdCGt012808
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:13 -0400
In-Reply-To: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
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
 drivers/net/hfi/ip/hf_proto.h    |    2 +
 drivers/net/hfi/ip/hfi_ip_main.c |  326 +++++++++++++++++++++++++++++++++++++-
 include/linux/hfi/hfi_ip.h       |   26 +++-
 3 files changed, 351 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hfi/ip/hf_proto.h b/drivers/net/hfi/ip/hf_proto.h
index b0232ab..022512a 100644
--- a/drivers/net/hfi/ip/hf_proto.h
+++ b/drivers/net/hfi/ip/hf_proto.h
@@ -34,6 +34,8 @@
 #define _HF_PROTO_H_
 
 int hf_tx_check_avail(struct hf_net *net, u32 xmit_cls);
+void hf_construct_hwhdr(struct hf_if *net_if, struct sk_buff *skb,
+			struct base_hdr *b_hdr);
 extern int hfidd_open_window_func(struct hfidd_acs *p_acs,
 		u32 is_userspace,
 		struct hfi_client_info *user_p,
diff --git a/drivers/net/hfi/ip/hfi_ip_main.c b/drivers/net/hfi/ip/hfi_ip_main.c
index 689f92e..6b2ec3f 100644
--- a/drivers/net/hfi/ip/hfi_ip_main.c
+++ b/drivers/net/hfi/ip/hfi_ip_main.c
@@ -154,6 +154,9 @@ static int hf_alloc_rx_resource(struct hf_net *net)
 
 	memset(net_if->rx_fifo.addr, 0, net_if->rx_fifo.size);
 
+	net_if->rx_fslot_debt = 0;
+	net_if->rx_pkt_valid = 1;
+
 	return 0;
 }
 
@@ -209,8 +212,18 @@ static int hf_send_intr_callback(void *parm, u32 win, u32 ext)
 	return 0;
 }
 
+static int hf_recv_intr_callback(void *parm, u32 win, u32 ext)
+{
+	struct hf_net	*net = (struct hf_net *)parm;
+
+	napi_schedule(&(net->napi));
+
+	return 0;
+}
+
 struct hf_events_cb hf_events[HF_EVENT_NUM] = {
 	{HFIDD_SEND,		(void *)hf_send_intr_callback},
+	{HFIDD_RECV,		(void *)hf_recv_intr_callback},
 };
 
 static int hf_register_ip_events(struct hf_net *net,
@@ -357,14 +370,50 @@ static int hf_set_mac_addr(struct net_device *netdev, void *p)
 	return 0;
 }
 
+static void hf_set_recv_intr(struct hf_if *net_if)
+{
+	int			offset;
+	struct hfi_hdr		*rx_pkt;
+
+	/* enable recv intr and set threshold to next packet */
+	offset = net_if->rx_fifo.head;
+
+	hf_mmio_regs_write_then_read(net_if, HFI_RFIFO_INTR_REG,
+		(HF_ENA_RECV_INTR + (offset << HF_RECV_INTR_MATCH_SHIFT)));
+
+	/* check if there is packet received in the mean time */
+	rx_pkt = net_if->rx_fifo.addr + (offset << HFI_CACHE_LINE_SHIFT);
+
+	if ((rx_pkt->id.job_id == HF_IP_JOBID) &&
+		(rx_pkt->base_hdr.pkt_valid == net_if->rx_pkt_valid)) {
+
+		/* force an immediate recv intr */
+		hf_mmio_regs_write(net_if, HFI_RFIFO_INTR_REG,
+		(HF_IMM_RECV_INTR + (offset << HF_RECV_INTR_MATCH_SHIFT)));
+	}
+}
+
 static void hf_init_hw_regs(struct hf_if *net_if)
 {
 	/* setup IP with payload threshold in cache line size */
 	hf_mmio_regs_write(net_if, HFI_IP_RECV_SIZE,
 		(HF_PAYLOAD_RX_THRESHOLD << HF_PAYLOAD_RX_THRESH_SHIFT));
 
+	/* setup recv fifo out of order intr control to disable */
+	hf_mmio_regs_write(net_if, HFI_RFIFO_OUT_EVENT_REG,
+			HF_RFIFO_OUT_CNTL_REARM);
+
+	/* setup recv fifo out of order threshold */
+	hf_mmio_regs_write(net_if, HFI_RFIFO_OUT_TH_REG, HF_RFIFO_OUT_THRESH);
+
 	/* initialize SEND INTR STATUS */
 	hf_mmio_regs_write(net_if, HFI_SINTR_STATUS_REG, 0);
+
+	hf_mmio_regs_write(net_if, HFI_RFIFO_INJ_TH_REG,
+			(HF_RFIFO_CACHE_INJ_TH << HF_RFIFO_CACHE_INJ_TH_SHIFT));
+
+	/* enable and set receive intr */
+	hf_set_recv_intr(net_if);
 }
 
 static int hf_net_delayed_open(void *parm, u16 win, u16 ext)
@@ -402,6 +451,7 @@ static int hf_net_delayed_open(void *parm, u16 win, u16 ext)
 	net_if->state = HF_NET_OPEN;
 	spin_unlock(&(net_if->lock));
 
+	napi_enable(&net->napi);
 	netif_carrier_on(netdev);
 	netif_start_queue(netdev);
 
@@ -488,6 +538,7 @@ static int hf_net_close(struct net_device *netdev)
 
 	spin_lock(&(net_if->lock));
 	if (net_if->state == HF_NET_OPEN) {
+		napi_disable(&net->napi);
 		netif_stop_queue(netdev);
 		netif_carrier_off(netdev);
 
@@ -507,6 +558,245 @@ static int hf_net_close(struct net_device *netdev)
 	return 0;
 }
 
+/* Invalidate the jobid field of each cache line before advancing head.
+ * The first cache line is protected by the valid bit, so we skip it. */
+static inline void hf_advance_rx_head(struct hf_if *net_if, u32 len)
+{
+	int		i, h;
+	u32		*cache_p;
+
+	h = (net_if->rx_fifo.head + 1) & (net_if->rx_fifo.emax);
+
+	for (i = 1; i < len; i++) {
+		cache_p = (u32 *)((char *)(net_if->rx_fifo.addr) +
+				(h << HFI_CACHE_LINE_SHIFT));
+		if (*cache_p == HF_IP_JOBID)
+			*cache_p = 0;
+		h = (h + 1) & (net_if->rx_fifo.emax);
+	}
+
+	if (net_if->rx_fifo.head > h)
+		net_if->rx_pkt_valid ^= 0x1;
+
+	net_if->rx_fifo.head = h;
+}
+
+void hf_construct_hwhdr(struct hf_if *net_if,
+			struct sk_buff *skb,
+			struct base_hdr *b_hdr)
+{
+	struct ethhdr		*hwhdr_p;
+
+	hwhdr_p = (struct ethhdr *)(skb->data);
+
+	/* MAC byte 1, bits6 = 1, locally admin MAC */
+	hwhdr_p->h_dest[0] = 0x2;
+	/* MAC byte 2, bits2-7 = cluster id */
+	hwhdr_p->h_dest[1] = 0x0;
+	*(u16 *)(&(hwhdr_p->h_dest[2])) = (u16)(b_hdr->dst_isr);
+	*(u16 *)(&(hwhdr_p->h_dest[4])) =
+			(u16)hf_get_mac(b_hdr->dst_win);
+
+	hwhdr_p->h_source[0] = 0x2;
+	hwhdr_p->h_source[1] = 0x0;
+	*(u16 *)(&(hwhdr_p->h_source[2])) = (u16)(b_hdr->src_isr);
+	*(u16 *)(&(hwhdr_p->h_source[4])) =
+				(u16)hf_get_mac(b_hdr->src_win);
+
+	hwhdr_p->h_proto = skb->protocol;
+}
+
+static inline int hf_check_hdr_version(struct hf_net *net,
+				struct hf_if_proto_hdr *hf_hdr)
+{
+	if (hf_hdr->version != HF_PROTO_HDR_VERSION) {
+		netdev_err(net->netdev,
+			"hf_check_hdr_version: hdr version 0x%x "
+			"does not match 0x%x\n",
+			hf_hdr->version, HF_PROTO_HDR_VERSION);
+		net->netdev->stats.rx_dropped++;
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static void hf_recv_ip_with_payload(struct hf_net *net,
+				    struct hfi_ip_with_payload_pkt *pkt,
+				    u32 pkt_len)
+{
+	u32			len, resid;
+	struct hf_if		*net_if = &(net->hfif);
+	struct net_device	*netdev = net->netdev;
+	struct hf_if_proto_hdr	*hf_hdr;
+	struct sk_buff		*skb;
+	void			*src, *dst;
+	u32			cache_ln_num = 0;
+	u16			proto;
+
+	/* retrieve the protocol header pointer */
+	hf_hdr = (struct hf_if_proto_hdr *)(pkt->payload);
+
+	if (hf_check_hdr_version(net, hf_hdr) != 0)
+		return;
+
+	switch (hf_hdr->msg_type) {
+	case HF_IF_ARP:
+		proto = htons(ETH_P_ARP);
+		break;
+
+	case HF_IF_FIFO:
+		proto = htons(ETH_P_IP);
+		break;
+
+	default:
+		netdev_err(net->netdev,
+			"hf_recv_ip_with_payload: unknown msg_type 0x%x\n",
+			hf_hdr->msg_type);
+		netdev->stats.rx_dropped++;
+		return;
+	}
+
+	len = hf_hdr->msg_len - HF_PROTO_LEN;
+
+	skb = netdev_alloc_skb_ip_align(net->netdev,
+				len + ETH_HLEN + HF_ALIGN_PAD);
+	if (!skb) {
+		netdev_err(net->netdev, "hf_recv_ip_with_payload: "
+				"netdev_alloc_skb_ip_align fail\n");
+		netdev->stats.rx_dropped++;
+		BUG();
+		return;
+	}
+
+	skb_reserve(skb, HF_ALIGN_PAD);
+	skb->protocol = proto;
+
+	skb_put(skb, len + ETH_HLEN);
+
+	/* construct ethhdr from base hdr */
+	hf_construct_hwhdr(net_if, skb, &(pkt->hfi_hdr.base_hdr));
+
+	skb_reset_mac_header(skb);
+
+	skb_pull(skb, ETH_HLEN);
+
+	src = (void *)(hf_hdr + 1);
+	dst = (void *)skb->data;
+
+	/* check if the payload wrapped the rx_fifo */
+	if ((net_if->rx_fifo.head + (pkt_len - 1)) > net_if->rx_fifo.emax) {
+		/* Wrapped */
+		cache_ln_num = net_if->rx_fifo.emax - net_if->rx_fifo.head + 1;
+		resid  = cache_ln_num << HFI_CACHE_LINE_SHIFT;
+		resid -= (HF_IP_HDR_LEN + HF_PROTO_LEN);
+
+		/* For netboot, pkt_len maybe larger than len */
+		if (resid > len)
+			resid = len;
+
+		memcpy(dst, src, resid);
+
+		src = (void *)net_if->rx_fifo.addr;
+		dst = (void *)skb->data + resid;
+		len -= resid;
+	}
+
+	/* copy the rest of payload */
+	if (len > 0)
+		memcpy(dst, src, len);
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	netdev->stats.rx_packets++;
+	netdev->stats.rx_bytes += skb->len;
+
+	netif_receive_skb(skb);
+}
+
+static void hf_recv_ip_good(struct hf_net *net,
+			    struct hfi_hdr *rx_curr,
+			    u32 pkt_len)
+{
+	switch (rx_curr->type.header_type) {
+
+	case  HFI_IP_WITH_PAYLOAD:
+	case  HFI_IP_MULTICAST_WITH_PAYLOAD:
+		hf_recv_ip_with_payload(net,
+			(struct hfi_ip_with_payload_pkt *)rx_curr, pkt_len);
+		break;
+
+	default:
+		netdev_err(net->netdev, "hf_rx: receive unknown "
+			"headerType = 0x%x, pkt_len = 0x%x\n",
+			rx_curr->type.header_type, pkt_len);
+
+		/* unknown packet, drop it */
+		net->netdev->stats.rx_dropped++;
+		break;
+	}
+}
+
+static int hf_rx(struct hf_net *net, int budget)
+{
+	int		num = 0;
+	struct hf_if	*net_if = &(net->hfif);
+	u32		pkt_len, status;
+	struct hfi_hdr	*rx_curr;
+	u32		job_id, pkt_valid;
+
+	rx_curr = (struct hfi_hdr *) (net_if->rx_fifo.addr +
+			(net_if->rx_fifo.head << HFI_CACHE_LINE_SHIFT));
+
+	while (budget != 0) {
+		job_id = rx_curr->id.job_id;
+		pkt_valid = rx_curr->base_hdr.pkt_valid;
+
+		isync();
+		if ((job_id != HF_IP_JOBID) ||
+		    (pkt_valid != net_if->rx_pkt_valid))
+			break;
+
+		pkt_len = hfi_pktlen_to_cachelines(rx_curr->base_hdr.pkt_len);
+
+		status = rx_curr->base_hdr.status;
+		if (status == HFI_PKT_STATUS_GOOD) {
+			hf_recv_ip_good(net, rx_curr, pkt_len);
+		} else {
+			/* bad packet */
+			netdev_err(net->netdev, "hf_rx: receive bad "
+				"status = 0x%x, pkt_len = 0x%x\n",
+				status, pkt_len);
+
+			net->netdev->stats.rx_dropped++;
+		}
+
+		net->netdev->last_rx = jiffies;
+
+		hf_advance_rx_head(net_if, pkt_len);
+
+		/* Make sure the jobid is invalidated before posting to hw */
+		wmb();
+
+		net_if->rx_fslot_debt += pkt_len;
+		if (net_if->rx_fslot_debt >= HF_INC_FSLOT_WATERMARK) {
+			hf_mmio_regs_write(net_if, HFI_RFIFO_INC_FSLOT_REG,
+					net_if->rx_fslot_debt);
+			net_if->rx_fslot_debt = 0;
+		}
+
+		budget--;
+		num++;
+		rx_curr = net_if->rx_fifo.addr +
+			(net_if->rx_fifo.head << HFI_CACHE_LINE_SHIFT);
+
+	}
+
+	netdev_dbg(net->netdev, "hf_rx: exit, head = 0x%x, recv 0x%x pkts\n",
+			net_if->rx_fifo.head, num);
+
+	return num;
+}
+
 static void hf_tx_recycle(struct hf_if *net_if)
 {
 	u32		head, head_idx, slots_per_blk;
@@ -906,6 +1196,30 @@ static void hf_if_setup(struct net_device *netdev)
 	memcpy(netdev->broadcast, hfi_bcast_addr, ETH_ALEN);
 }
 
+static int hf_poll(struct napi_struct *napi, int budget)
+{
+	int			work_done;
+	struct net_device	*netdev;
+	struct hf_net		*net;
+	struct hf_if		*net_if;
+
+	net	= container_of(napi, struct hf_net, napi);
+	net_if	= &(net->hfif);
+	netdev	= net->netdev;
+
+	work_done = hf_rx(net, budget);
+
+	/* Always assume we have received all available packets */
+	/*  and set recv intr for next packet */
+	if (work_done < budget) {
+		napi_complete(napi);
+		isync();
+		hf_set_recv_intr(net_if);
+	}
+
+	return work_done;
+}
+
 static struct hf_net *hf_init_netdev(int idx, int ai)
 {
 	struct net_device	*netdev;
@@ -924,6 +1238,7 @@ static struct hf_net *hf_init_netdev(int idx, int ai)
 	}
 
 	net = netdev_priv(netdev);
+	netif_napi_add(netdev, &(net->napi), hf_poll, HF_NAPI_WEIGHT);
 	net->netdev = netdev;
 
 	memset(&(net->hfif), 0, sizeof(struct hf_if));
@@ -939,11 +1254,16 @@ static struct hf_net *hf_init_netdev(int idx, int ai)
 		netdev_err(netdev, "hf_init_netdev: "
 				"failed to register netdev=hfi%d:hf%d, "
 				"rc = 0x%x\n", ai, idx, rc);
-		free_netdev(netdev);
-		return ERR_PTR(-ENODEV);
+		goto err_out1;
 	}
 
 	return net;
+
+err_out1:
+	netif_napi_del(&(net->napi));
+	free_netdev(netdev);
+
+	return ERR_PTR(-ENODEV);
 }
 
 static void hf_del_netdev(struct hf_net *net)
@@ -952,6 +1272,8 @@ static void hf_del_netdev(struct hf_net *net)
 
 	unregister_netdev(netdev);
 
+	netif_napi_del(&(net->napi));
+
 	free_netdev(netdev);
 }
 
diff --git a/include/linux/hfi/hfi_ip.h b/include/linux/hfi/hfi_ip.h
index 4e70c14..ec87300 100644
--- a/include/linux/hfi/hfi_ip.h
+++ b/include/linux/hfi/hfi_ip.h
@@ -38,6 +38,7 @@
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
+#include <linux/etherdevice.h>
 #include <net/arp.h>
 
 #include <linux/hfi/hfidd_internal.h>
@@ -56,6 +57,12 @@
 #define HF_NAPI_WEIGHT			256
 #define HF_MAX_NAME_LEN			64
 
+/* rfifo intr */
+#define HF_RFIFO_OUT_CNTL_REARM		0	/* 0 to disable interrupt */
+#define HF_IMM_RECV_INTR		0xf0000000	/* bit 32-35 on */
+#define HF_ENA_RECV_INTR		0xc0000000	/* bit 32-33 on */
+#define HF_RECV_INTR_MATCH_SHIFT	7	/* bit 37-56 */
+
 /* sfifo intr: bit 39-55 is threshold */
 /*             bit 34 enable, bit 35 unmask */
 #define HF_SFIFO_INTR_ENABLE		(0x3 << (63 - 35))
@@ -74,11 +81,17 @@
 #define HF_FV_BIT_MAX			31
 #define HF_SEND_ONE			1
 
+#define HF_RFIFO_CACHE_INJ_TH		7ULL
+#define HF_RFIFO_CACHE_INJ_TH_SHIFT	61
+#define HF_RFIFO_OUT_THRESH		0
+
 #define HF_PAYLOAD_MAX			(2048 - HF_IP_HDR_LEN - HF_PROTO_LEN)
 #define HF_NET_MTU			HF_PAYLOAD_MAX
 #define HF_PAYLOAD_RX_THRESHOLD		0x10ULL
 #define HF_PAYLOAD_RX_THRESH_SHIFT	59
 
+#define HF_INC_FSLOT_WATERMARK		(HF_RFIFO_SLOTS >> 3)
+
 struct hfi_ip_extended_hdr {            /* 16B */
 	unsigned int	immediate_len:7;/* In bytes */
 	unsigned int	num_desc:3;     /* number of descriptors */
@@ -99,7 +112,9 @@ struct hfi_ip_with_payload_pkt {
 
 #define HF_IP_HDR_LEN			((sizeof(struct hfi_hdr) + \
 				sizeof(struct hfi_ip_extended_hdr)))
+
 #define HF_ALIGN_PAD			2
+
 #define HF_PROTO_HDR_VERSION		0x1
 /* HFI protocol message type */
 #define	HF_IF_ARP			0xA0
@@ -146,7 +161,10 @@ struct hf_if {
 	u32			sfifo_fv_polarity;
 	u32			sfifo_slots_per_blk;
 	u32			sfifo_packets;
+	u32			rx_pkt_valid;		/* Polarity of recv
+							   packet valid bit */
 	u32			msg_id;
+	u32			rx_fslot_debt;
 	void __iomem		*doorbell;		/* mapped mmio_regs */
 	struct hf_fifo		tx_fifo;
 	struct hf_fifo		rx_fifo;
@@ -159,6 +177,7 @@ struct hf_if {
 /* Private structure for HF inetrface */
 struct hf_net {
 	struct net_device	*netdev;
+	struct napi_struct	napi;
 	struct hf_if		hfif;
 };
 
@@ -172,7 +191,7 @@ struct hf_global_info {
 
 extern struct hf_global_info	hf_ginfo;
 
-#define HF_EVENT_NUM		1
+#define HF_EVENT_NUM		2
 
 struct hf_events_cb {
 	enum hfi_event_type	type;
@@ -182,6 +201,11 @@ struct hf_events_cb {
 #define HF_MAC_HFI_SHIFT	12
 #define HF_HDR_HFI_SHIFT	8
 
+static inline u32 hf_get_mac(u32 w)
+{
+	return ((w >> HF_HDR_HFI_SHIFT) << HF_MAC_HFI_SHIFT) | (w & 0xFF);
+}
+
 static inline u32 hf_get_win(u16 id)
 {
 	return ((id >> HF_MAC_HFI_SHIFT) << HF_HDR_HFI_SHIFT) | (id & 0xFF);
-- 
1.7.3.5

