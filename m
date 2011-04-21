From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v3 25/27] HFI: hfi_ip fifo transmit paths
Date: Thu, 21 Apr 2011 17:38:55 -0400
Message-ID: <1303421937-2325-26-git-send-email-dykmanj@linux.vnet.ibm.com>
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
Received: from e4.ny.us.ibm.com ([32.97.182.144]:59589 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321Ab1DUVjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:39:23 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LLJ84S015225
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:19:08 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LLdDub1617990
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:14 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLdCAT012805
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 17:39:12 -0400
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
 drivers/net/hfi/ip/hf_proto.h    |    1 +
 drivers/net/hfi/ip/hfi_ip_main.c |  438 ++++++++++++++++++++++++++++++++++++++
 include/linux/hfi/hfi_ip.h       |   72 ++++++-
 3 files changed, 510 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hfi/ip/hf_proto.h b/drivers/net/hfi/ip/hf_proto.h
index b4133b7..b0232ab 100644
--- a/drivers/net/hfi/ip/hf_proto.h
+++ b/drivers/net/hfi/ip/hf_proto.h
@@ -33,6 +33,7 @@
 #ifndef _HF_PROTO_H_
 #define _HF_PROTO_H_
 
+int hf_tx_check_avail(struct hf_net *net, u32 xmit_cls);
 extern int hfidd_open_window_func(struct hfidd_acs *p_acs,
 		u32 is_userspace,
 		struct hfi_client_info *user_p,
diff --git a/drivers/net/hfi/ip/hfi_ip_main.c b/drivers/net/hfi/ip/hfi_ip_main.c
index 0c1ebd7..689f92e 100644
--- a/drivers/net/hfi/ip/hfi_ip_main.c
+++ b/drivers/net/hfi/ip/hfi_ip_main.c
@@ -185,6 +185,87 @@ alloc_resource_err0:
 	return rc;
 }
 
+static int hf_send_intr_callback(void *parm, u32 win, u32 ext)
+{
+	struct hf_net	*net = (struct hf_net *)parm;
+	struct hf_if	*net_if = &(net->hfif);
+	u64		sintr_status;
+
+	sintr_status = hf_mmio_regs_read(net_if, HFI_SINTR_STATUS_REG);
+
+	netdev_info(net->netdev, "hf_send_intr_callback: "
+		"sintr_status 0x%016llx", sintr_status);
+
+	/* mask off the interrupt */
+	if (sintr_status & HF_SFIFO_INTR_EVENT)
+		hf_mmio_regs_write(net_if, HFI_SFIFO_INTR_CNTL, 0);
+
+	/* Make sure interrupts are masked */
+	/* Otherwise after the queue is awaken, it will get stale interrupt */
+	mb();
+
+	netif_wake_queue(net->netdev);
+
+	return 0;
+}
+
+struct hf_events_cb hf_events[HF_EVENT_NUM] = {
+	{HFIDD_SEND,		(void *)hf_send_intr_callback},
+};
+
+static int hf_register_ip_events(struct hf_net *net,
+				 struct hfidd_acs *p_acs,
+				 int flag)
+{
+	struct hf_if		*net_if = &(net->hfif);
+	int			rc = 0, i, j;
+	struct hfi_reg_events	events[HF_EVENT_NUM];
+	int			(*reg_func)(struct hfidd_acs *,
+				struct hfi_reg_events *);
+
+	if (flag == HFIDD_REQ_EVENT_REGISTER)
+		reg_func = hfidd_callback_register;
+	else
+		reg_func = hfidd_callback_unregister;
+
+	for (i = 0; i < HF_EVENT_NUM; i++) {
+		events[i].window = net_if->client.window;
+		events[i].type = FUNCTIONS_FOR_EVENTS;
+		events[i].info.func.index = hf_events[i].type;
+		events[i].info.func.function_p.use.kptr = hf_events[i].func;
+		events[i].info.func.parameter.use.kptr = (void *)(net);
+
+		events[i].hdr.req = flag;
+		events[i].hdr.req_len = sizeof(struct hfi_reg_events);
+		events[i].hdr.result.use.kptr = &(events[i]);
+
+		rc = reg_func(p_acs, &(events[i]));
+		if (rc) {
+			netdev_err(net->netdev, "hf_register_ip_events: "
+				"fail event 0x%x, flag=0x%x rc=0x%x\n",
+				hf_events[i].type, flag, rc);
+
+			if (flag == HFIDD_REQ_EVENT_REGISTER)
+				goto err_out;
+		}
+	}
+
+	return rc;
+
+err_out:
+	for (j = 0; j < i; j++) {
+		events[j].hdr.req = HFIDD_REQ_EVENT_UNREGISTER;
+		rc = hfidd_callback_unregister(p_acs, &(events[i]));
+		if (rc) {
+			netdev_err(net->netdev, "hf_register_ip_events: failed "
+				"to unregister callback event 0x%x, rc=0x%x\n",
+				events[i].info.func.index, rc);
+		}
+	}
+
+	return rc;
+}
+
 static int hf_close_ip_window(struct hf_net *net, struct hfidd_acs *p_acs)
 {
 	struct hf_if *net_if = &(net->hfif);
@@ -276,6 +357,16 @@ static int hf_set_mac_addr(struct net_device *netdev, void *p)
 	return 0;
 }
 
+static void hf_init_hw_regs(struct hf_if *net_if)
+{
+	/* setup IP with payload threshold in cache line size */
+	hf_mmio_regs_write(net_if, HFI_IP_RECV_SIZE,
+		(HF_PAYLOAD_RX_THRESHOLD << HF_PAYLOAD_RX_THRESH_SHIFT));
+
+	/* initialize SEND INTR STATUS */
+	hf_mmio_regs_write(net_if, HFI_SINTR_STATUS_REG, 0);
+}
+
 static int hf_net_delayed_open(void *parm, u16 win, u16 ext)
 {
 	struct net_device	*netdev = (struct net_device *)parm;
@@ -300,13 +391,25 @@ static int hf_net_delayed_open(void *parm, u16 win, u16 ext)
 	if (rc)
 		goto delayed_open_err1;
 
+	rc = hf_register_ip_events(net, p_acs, HFIDD_REQ_EVENT_REGISTER);
+	if (rc)
+		goto delayed_open_err2;
+
 	hf_set_mac_addr(netdev, NULL);
 
+	hf_init_hw_regs(net_if);
+
 	net_if->state = HF_NET_OPEN;
 	spin_unlock(&(net_if->lock));
 
+	netif_carrier_on(netdev);
+	netif_start_queue(netdev);
+
 	return 0;
 
+delayed_open_err2:
+	hf_close_ip_window(net, p_acs);
+
 delayed_open_err1:
 	hf_free_resource(net_if);
 
@@ -385,6 +488,11 @@ static int hf_net_close(struct net_device *netdev)
 
 	spin_lock(&(net_if->lock));
 	if (net_if->state == HF_NET_OPEN) {
+		netif_stop_queue(netdev);
+		netif_carrier_off(netdev);
+
+		hf_register_ip_events(net, p_acs, HFIDD_REQ_EVENT_UNREGISTER);
+
 		hf_close_ip_window(net, p_acs);
 
 		hf_free_resource(net_if);
@@ -399,6 +507,332 @@ static int hf_net_close(struct net_device *netdev)
 	return 0;
 }
 
+static void hf_tx_recycle(struct hf_if *net_if)
+{
+	u32		head, head_idx, slots_per_blk;
+	u32		*fv;
+	int		i;
+	u32		fv_bit;
+	u8		nr;
+
+	head = net_if->tx_fifo.head;
+
+	slots_per_blk = net_if->sfifo_slots_per_blk;
+
+	head_idx = head / slots_per_blk;
+
+	fv = (u32 *)(net_if->sfifo_finishvec);
+
+	while (1) {
+		nr = HF_FV_BIT_MAX - head_idx;
+		fv_bit = BIT(nr) & (ACCESS_ONCE(*fv));
+		fv_bit = fv_bit >> nr;
+
+		if ((fv_bit ^ (net_if->sfifo_fv_polarity)) == 0)
+			break;
+
+		for (i = 0; i < slots_per_blk; i++) {
+			struct sk_buff		*skb;
+
+			skb = net_if->tx_skb[head + i];
+			if (skb != NULL) {
+				dev_kfree_skb_any(skb);
+				net_if->tx_skb[head + i] = NULL;
+			}
+		}
+
+		head = (head + slots_per_blk) & (net_if->tx_fifo.emax);
+
+		atomic_add(slots_per_blk, &(net_if->tx_fifo.avail));
+
+		if (++head_idx == HF_FV_BIT_CNT) {
+			head_idx = 0;
+			net_if->sfifo_fv_polarity ^= 1;
+		}
+	}
+
+	net_if->tx_fifo.head = head;
+
+	return;
+}
+
+int hf_tx_check_avail(struct hf_net *net, u32 xmit_cls)
+{
+	struct net_device	*netdev = net->netdev;
+	struct hf_if		*net_if = &(net->hfif);
+
+	if (atomic_read(&net_if->tx_fifo.avail) < xmit_cls) {
+
+		hf_tx_recycle(net_if);
+
+		if (atomic_read(&net_if->tx_fifo.avail) < xmit_cls) {
+			u32		intr_cntl;
+			u64		intr_thresh;
+
+			netif_stop_queue(netdev);
+
+			/* turn on transmit interrupt */
+			intr_thresh = (net_if->sfifo_packets -
+			HF_SFIFO_INTR_WATERMARK) & HF_SFIFO_INTR_MASK;
+
+			intr_cntl = HF_SFIFO_INTR_ENABLE |
+			(intr_thresh << HF_SFIFO_INTR_CNT_SHIFT);
+
+			hf_mmio_regs_write_then_read(net_if,
+					HFI_SFIFO_INTR_CNTL, intr_cntl);
+
+			return -EBUSY;
+		}
+	}
+
+	return 0;
+}
+
+static inline void hf_fill_route(u16 dst_isr, struct base_hdr *base_hdr_p)
+{
+	base_hdr_p->route_control = HFI_HW_DIRECT_ROUTE;
+}
+
+static int hf_copy_skb_to_fifo(struct hf_net *net,
+				struct sk_buff *skb,
+				char *dst,
+				u32 len,
+				u32 offset)
+{
+	struct hf_if *net_if = &(net->hfif);
+	u64		fifo_end;
+	u32		tail_room;
+	int		rc;
+
+	fifo_end = (u64)(net_if->tx_fifo.addr) + net_if->tx_fifo.size;
+
+	tail_room = fifo_end - (u64)dst;
+	if (tail_room >= len) {
+		rc = skb_copy_bits(skb, offset, dst, len);
+		if (rc) {
+			netdev_err(net->netdev,
+				"hf_copy_skb_to_fifo: skb_copy_bits"
+				"fail1 offset=0x%x, len=0x%x, rc=0x%x\n",
+				offset, len, rc);
+			return rc;
+		}
+	} else {
+		rc = skb_copy_bits(skb, offset, dst, tail_room);
+		if (rc) {
+			netdev_err(net->netdev,
+				"hf_copy_skb_to_fifo: skb_copy_bits"
+				"fail2 offset=0x%x, len=0x%x, rc=0x%x\n",
+				offset, tail_room, rc);
+
+			return rc;
+		}
+		rc = skb_copy_bits(skb, offset + tail_room,
+				net_if->tx_fifo.addr, len - tail_room);
+		if (rc) {
+			netdev_err(net->netdev,
+				"hf_copy_skb_to_fifo: skb_copy_bits"
+				"fail3 offset=0x%x, len=0x%x, rc=0x%x\n",
+				offset + tail_room, len - tail_room, rc);
+
+			return rc;
+		}
+	}
+
+	return 0;
+}
+
+/* Build base_hdr and proto_hdr for payload pkt.
+   Return pointer to the end of proto_hdr */
+static char *hf_build_payload_hdr(struct hf_net *net,
+				  struct sk_buff *skb,
+				  u32 msg_len,
+				  u32 xmit_cls,
+				  u32 is_bcast)
+{
+	struct hf_if			*net_if = &(net->hfif);
+	struct hf_if_proto_hdr		*proto_hdr_p;
+	struct hfi_ip_with_payload_pkt	*hdr_p;
+	char				*dst;
+	u8				msg_type, msg_flag;
+	struct ethhdr			*hwhdr_p;
+
+	hwhdr_p = (struct ethhdr *)(skb->data);
+
+	if (hwhdr_p->h_proto == htons(ETH_P_IP))
+		msg_type = HF_IF_FIFO;
+	else if (hwhdr_p->h_proto == htons(ETH_P_ARP))
+		msg_type = HF_IF_ARP;
+	else {
+		netdev_err(net->netdev, "hf_build_payload_hdr: h_proto = 0x%x "
+			" not supported\n", hwhdr_p->h_proto);
+
+		dev_kfree_skb_any(skb);
+		return NULL;
+	}
+
+	dst = net_if->tx_fifo.addr +
+		(net_if->tx_fifo.tail << HFI_CACHE_LINE_SHIFT);
+
+	/* fill in base_hdr + ip_extended_hdr */
+	hdr_p = (struct hfi_ip_with_payload_pkt *)dst;
+
+	/* Do not memset over one cacheline since it might wrap */
+	memset(hdr_p, 0, HF_IP_HDR_LEN);
+
+	hdr_p->hfi_hdr.type.header_type = HFI_IP_WITH_PAYLOAD;
+	hdr_p->hfi_hdr.id.job_id = net_if->client.job_id;
+
+	if (is_bcast) {
+		hdr_p->hfi_hdr.base_hdr.dst_isr = HFIDD_DST_BCST_ISR;
+		hdr_p->hfi_hdr.base_hdr.dst_win = HFIDD_DST_BCST_WIN;
+		hdr_p->hfi_hdr.type.header_type = HFI_IP_MULTICAST_WITH_PAYLOAD;
+
+		msg_flag = HF_IF_BCAST;
+	} else {
+		u16	dst_isr, dst_win;
+
+		hf_get_dst_info(hwhdr_p, &dst_isr, &dst_win);
+		hdr_p->hfi_hdr.base_hdr.dst_isr = dst_isr;
+		hdr_p->hfi_hdr.base_hdr.dst_win = dst_win;
+
+		hf_fill_route(dst_isr, &(hdr_p->hfi_hdr.base_hdr));
+
+		msg_flag = HF_IF_UCAST;
+	}
+
+	netdev_dbg(net->netdev, "hf_build_payload_hdr: dst_isr = 0x%x, "
+			"dst_win = 0x%x, xmit_cls = 0x%x\n",
+			hdr_p->hfi_hdr.base_hdr.dst_isr,
+			hdr_p->hfi_hdr.base_hdr.dst_win, xmit_cls);
+
+	hdr_p->hfi_hdr.base_hdr.pkt_len = hfi_cachelines_to_pktlen(xmit_cls);
+
+	dst += HF_IP_HDR_LEN;
+	proto_hdr_p = (struct hf_if_proto_hdr *)dst;
+
+	proto_hdr_p->version = HF_PROTO_HDR_VERSION;
+	proto_hdr_p->msg_len = msg_len;
+	proto_hdr_p->msg_id = net_if->msg_id;
+	proto_hdr_p->msg_type = msg_type;
+	proto_hdr_p->msg_flag = msg_flag;
+
+	dst += HF_PROTO_LEN;
+
+	return dst;
+}
+
+static int hf_payload_tx(struct sk_buff *skb, struct hf_net *net, u32 is_bcast)
+{
+	struct hf_if		*net_if = &(net->hfif);
+	u32			msg_len, len;
+	u32			xmit_cls;
+	char			*dst;
+	int			rc = 0;
+
+	msg_len = skb->len - ETH_HLEN + HF_PROTO_LEN;
+	xmit_cls = hfi_bytes_to_cacheline(msg_len + HF_IP_HDR_LEN);
+
+	if (is_bcast) {
+		if (xmit_cls <= HF_BCAST_CACHE_LINE_2)
+			xmit_cls = HF_BCAST_CACHE_LINE_2;
+		else
+			xmit_cls = HF_BCAST_CACHE_LINE_16;
+	}
+
+	rc = hf_tx_check_avail(net, xmit_cls);
+	if (rc) {
+		netdev_err(net->netdev, "hf_payload_tx: hf_tx_check_avail find "
+				"no avail slot\n");
+		return rc;
+	}
+
+	dst = hf_build_payload_hdr(net, skb, msg_len, xmit_cls, is_bcast);
+	if (!dst)
+		return 0;
+
+	/* copy skb data, skipping hwhdr */
+	len = skb->len - ETH_HLEN;
+
+	rc = hf_copy_skb_to_fifo(net, skb, dst, len, ETH_HLEN);
+	if (rc)
+		return rc;
+
+	net_if->tx_fifo.tail =
+		(net_if->tx_fifo.tail + xmit_cls) & (net_if->tx_fifo.emax);
+	atomic_sub(xmit_cls, &(net_if->tx_fifo.avail));
+
+	net_if->sfifo_packets++;
+	net->netdev->stats.tx_packets++;
+	net->netdev->stats.tx_bytes += msg_len;
+
+	netdev_dbg(net->netdev, "hf_payload_tx: exit, tx_fifo tail = 0x%x, "
+		"avail = 0x%x, skb->len = 0x%x\n", net_if->tx_fifo.tail,
+		atomic_read(&(net_if->tx_fifo.avail)), skb->len);
+
+	dev_kfree_skb_any(skb);
+	return 0;
+
+}
+
+static int hf_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct hf_net	*net = netdev_priv(netdev);
+	struct hf_if	*net_if = &(net->hfif);
+	u32		len, is_bcast;
+	u32		send_cnt = 1;
+
+	is_bcast = !memcmp(((struct ethhdr *)(skb->data))->h_dest,
+				netdev->broadcast,
+				netdev->addr_len);
+
+	if (unlikely(skb->len <= 0)) {
+		netdev_err(netdev, "hf_start_xmit: invalid skb->len 0x%x\n",
+						skb->len);
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	/* total len to transfer */
+	len = skb->len - ETH_HLEN;
+
+	if (len <= HF_PAYLOAD_MAX) {
+		/* send ip with payload */
+		if (hf_payload_tx(skb, net, is_bcast) < 0) {
+			netdev_err(netdev, "hf_start_xmit: "
+				"hf_payload_tx fail 1\n");
+
+			return NETDEV_TX_BUSY;
+		}
+	} else {
+		netdev_err(netdev, "hf_start_xmit: skb->len 0x%x "
+			"greater than max 0x%x\n",
+			skb->len, (u32)HF_PAYLOAD_MAX);
+
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	/* Make sure all fields are written before ringing hw doorbell */
+	wmb();
+
+	/* ring doorbell */
+	hf_mmio_regs_write(net_if, HFI_SFIFO_DB_REG, send_cnt);
+
+	if (atomic_read(&net_if->tx_fifo.avail) < HF_TX_LOW_WATERMARK)
+		hf_tx_check_avail(net, HF_TX_LOW_WATERMARK);
+
+	net_if->msg_id++;
+	netdev->trans_start = jiffies;
+
+	return NETDEV_TX_OK;
+}
+
+static void hf_tx_timeout(struct net_device *netdev)
+{
+	netdev_warn(netdev, "hf_tx_timeout: queue_stopped is %d\n",
+			netif_queue_stopped(netdev));
+}
+
 static int hf_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	if ((new_mtu <= 68) || (new_mtu > HF_NET_MTU))
@@ -449,6 +883,8 @@ static const struct net_device_ops hf_netdev_ops = {
 	.ndo_open		= hf_net_open,
 	.ndo_stop		= hf_net_close,
 	.ndo_change_mtu		= hf_change_mtu,
+	.ndo_start_xmit		= hf_start_xmit,
+	.ndo_tx_timeout		= hf_tx_timeout,
 	.ndo_set_mac_address	= NULL,
 };
 
@@ -465,6 +901,8 @@ static void hf_if_setup(struct net_device *netdev)
 	netdev->header_ops	= &hf_header_ops;
 	netdev->netdev_ops	= &hf_netdev_ops;
 
+	netdev->watchdog_timeo	= HF_TX_TIMEOUT;
+
 	memcpy(netdev->broadcast, hfi_bcast_addr, ETH_ALEN);
 }
 
diff --git a/include/linux/hfi/hfi_ip.h b/include/linux/hfi/hfi_ip.h
index 6b6a74c..4e70c14 100644
--- a/include/linux/hfi/hfi_ip.h
+++ b/include/linux/hfi/hfi_ip.h
@@ -43,6 +43,7 @@
 #include <linux/hfi/hfidd_internal.h>
 #include <linux/hfi/hfidd_client.h>
 #include <linux/hfi/hfidd_requests.h>
+#include <linux/hfi/hfidd_regs.h>
 #include <linux/hfi/hfidd_pkt_formats.h>
 
 #define HF_DRV_VERSION			"1.0"
@@ -51,16 +52,32 @@
 
 #define MAX_HF_PER_HFI			2
 #define	HF_IP_JOBID			0xFFFFFFF0
+#define HF_TX_TIMEOUT			(500 * HZ)
+#define HF_NAPI_WEIGHT			256
 #define HF_MAX_NAME_LEN			64
 
+/* sfifo intr: bit 39-55 is threshold */
+/*             bit 34 enable, bit 35 unmask */
+#define HF_SFIFO_INTR_ENABLE		(0x3 << (63 - 35))
+#define HF_SFIFO_INTR_MASK		0x1FFFF		/* 17 bits */
+#define HF_SFIFO_INTR_CNT_SHIFT		(63 - 55)
+#define HF_SFIFO_INTR_EVENT		0x00000040 /* bit 57 */
+#define HF_SFIFO_INTR_WATERMARK		(HF_SFIFO_SLOTS - (HF_SFIFO_SLOTS >> 3))
+
 #define HF_SFIFO_SIZE			0x40000	/* 256K */
 #define HF_SFIFO_SLOTS			(HF_SFIFO_SIZE >> HFI_CACHE_LINE_SHIFT)
 #define HF_RFIFO_SIZE			0x1000000	/* 16M */
 #define HF_RFIFO_SLOTS			(HF_RFIFO_SIZE >> HFI_CACHE_LINE_SHIFT)
+#define HF_TX_LOW_WATERMARK		(HF_SFIFO_SLOTS >> 4)
 
 #define HF_FV_BIT_CNT			32
+#define HF_FV_BIT_MAX			31
+#define HF_SEND_ONE			1
 
-#define HF_NET_MTU			(2048 - HF_IP_HDR_LEN - HF_PROTO_LEN)
+#define HF_PAYLOAD_MAX			(2048 - HF_IP_HDR_LEN - HF_PROTO_LEN)
+#define HF_NET_MTU			HF_PAYLOAD_MAX
+#define HF_PAYLOAD_RX_THRESHOLD		0x10ULL
+#define HF_PAYLOAD_RX_THRESH_SHIFT	59
 
 struct hfi_ip_extended_hdr {            /* 16B */
 	unsigned int	immediate_len:7;/* In bytes */
@@ -83,6 +100,14 @@ struct hfi_ip_with_payload_pkt {
 #define HF_IP_HDR_LEN			((sizeof(struct hfi_hdr) + \
 				sizeof(struct hfi_ip_extended_hdr)))
 #define HF_ALIGN_PAD			2
+#define HF_PROTO_HDR_VERSION		0x1
+/* HFI protocol message type */
+#define	HF_IF_ARP			0xA0
+#define	HF_IF_FIFO			0xA1
+
+/* HFI protocol message flag */
+#define	HF_IF_UCAST			0xB0
+#define	HF_IF_BCAST			0xB1
 
 struct hf_if_proto_hdr {
 	u16			version;
@@ -93,6 +118,8 @@ struct hf_if_proto_hdr {
 };
 
 #define HF_PROTO_LEN		sizeof(struct hf_if_proto_hdr)
+#define HF_BCAST_CACHE_LINE_16	16
+#define HF_BCAST_CACHE_LINE_2	2
 
 struct hf_fifo {
 	void			*addr;
@@ -119,6 +146,7 @@ struct hf_if {
 	u32			sfifo_fv_polarity;
 	u32			sfifo_slots_per_blk;
 	u32			sfifo_packets;
+	u32			msg_id;
 	void __iomem		*doorbell;		/* mapped mmio_regs */
 	struct hf_fifo		tx_fifo;
 	struct hf_fifo		rx_fifo;
@@ -144,5 +172,47 @@ struct hf_global_info {
 
 extern struct hf_global_info	hf_ginfo;
 
+#define HF_EVENT_NUM		1
+
+struct hf_events_cb {
+	enum hfi_event_type	type;
+	void			*func;
+};
+
 #define HF_MAC_HFI_SHIFT	12
+#define HF_HDR_HFI_SHIFT	8
+
+static inline u32 hf_get_win(u16 id)
+{
+	return ((id >> HF_MAC_HFI_SHIFT) << HF_HDR_HFI_SHIFT) | (id & 0xFF);
+}
+
+static inline void hf_get_dst_info(struct ethhdr *hwhdr_p,
+				   u16 *d_isr,
+				   u16 *d_win)
+{
+	*d_isr = (*(u16 *)(&(hwhdr_p->h_dest[2]))) & 0xFFF;
+	*d_win = hf_get_win(*(u16 *)(&(hwhdr_p->h_dest[4])));
+}
+
+static inline void hf_mmio_regs_write_then_read(struct hf_if *net_if,
+				int off,
+				u64 data)
+{
+	__raw_writeq(data, net_if->doorbell + off);
+	isync();
+	__raw_readq(net_if->doorbell + off);
+	/* Make sure all received pkt shows up in rfifo */
+	mb();
+}
+
+static inline u64 hf_mmio_regs_read(struct hf_if *net_if, int off)
+{
+	return __raw_readq(net_if->doorbell + off);
+}
+
+static inline void hf_mmio_regs_write(struct hf_if *net_if, int off, u64 data)
+{
+	__raw_writeq(data, net_if->doorbell + off);
+}
 #endif
-- 
1.7.3.5

