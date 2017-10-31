From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 14/14] xdp: introducing XDP_PASS_TO_KERNEL for PACKET_ZEROCOPY use
Date: Tue, 31 Oct 2017 13:41:45 +0100
Message-ID: <20171031124145.9667-15-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Cc: jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:35439 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751487AbdJaMnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:43:25 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Karlsson <magnus.karlsson@intel.com>

This patch introduces XDP_PASS_TO_KERNEL especially for use with
PACKET_ZEROCOPY (ZC) and AF_PACKET V4. When ZC is enabled, XDP_PASS
will send a packet to the V4 socket so that the application can
receive it. If the XDP program would like to send a packet
towards the kernel stack, then XDP_PASS_TO_KERNEL can be used. It will
copy the packet from the packet buffer into an skb and pass it on. When
PACKET_ZEROCOPY is not enabled, XDP_PASS_TO_KERNEL defaults to XDP_PASS.

Note that in ZC mode, user space will be able to see the packet that
XDP is running on, so this is only for trusted applications. For
untrusted applications, NIC HW steering support is a requirement to
make sure the untrusted applications can only see their own packets.

Signed-off-by: Magnus Karlsson <magnus.karlsson@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 62 +++++++++++++++++++++++++++--
 include/linux/tpacket4.h                    | 17 +++++++-
 include/uapi/linux/bpf.h                    |  1 +
 3 files changed, 75 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 730fe57ca8ee..bf2680ed2b05 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2050,6 +2050,7 @@ static struct sk_buff *i40e_run_xdp(struct i40e_ring *rx_ring,
 	act = bpf_prog_run_xdp(xdp_prog, xdp);
 	switch (act) {
 	case XDP_PASS:
+	case XDP_PASS_TO_KERNEL:
 		break;
 	case XDP_TX:
 		xdp_ring = rx_ring->vsi->xdp_rings[rx_ring->queue_index];
@@ -2278,7 +2279,8 @@ static inline unsigned int i40e_get_rx_desc_size(union i40e_rx_desc *rxd)
 }
 
 static void i40e_run_xdp_tp4(struct tp4_frame_set *f, bool *recycled,
-			     struct bpf_prog *xdp_prog, struct i40e_ring *xdpr);
+			     struct bpf_prog *xdp_prog, struct i40e_ring *xdpr,
+			     struct i40e_ring *rxr);
 
 /**
  * i40e_clean_rx_tp4_irq - Pulls received packets of the descriptor ring
@@ -2322,7 +2324,7 @@ int i40e_clean_rx_tp4_irq(struct i40e_ring *rxr, int budget)
 
 			xdpr = rxr->vsi->xdp_rings[rxr->queue_index];
 			i40e_run_xdp_tp4(&frame_set, &recycled,
-					 xdp_prog, xdpr);
+					 xdp_prog, xdpr, rxr);
 
 			if (!recycled)
 				nflush++;
@@ -3853,16 +3855,68 @@ static void i40e_tp4_xdp_tx_flush_handler(void *ctx)
 }
 
 /**
+ * i40e_tp4_xdp_tx_flush_handler - XDP pass to kernel callback
+ * @ctx: context. A pointer to the RX ring.
+ * @xdp: XDP buff
+ *
+ * Returns 0 for success and <0 on failure.
+ **/
+static int i40e_tp4_xdp_to_kernel_handler(void *ctx, struct xdp_buff *xdp)
+{
+	struct i40e_ring *rx_ring = ctx;
+	union i40e_rx_desc *rx_desc;
+	struct sk_buff *skb;
+	unsigned int len;
+	u16 vlan_tag;
+	u8 rx_ptype;
+	u64 qword;
+	int err;
+
+	len = xdp->data_end - xdp->data;
+	skb = __napi_alloc_skb(&rx_ring->q_vector->napi, len,
+			       GFP_ATOMIC | __GFP_NOWARN);
+	if (unlikely(!skb))
+		return -ENOMEM;
+
+	/* XXX Use fragments for the data here */
+	skb_put(skb, len);
+	err = skb_store_bits(skb, 0, xdp->data, len);
+	if (unlikely(err)) {
+		kfree_skb(skb);
+		return err;
+	}
+
+	rx_desc = I40E_RX_DESC(rx_ring, rx_ring->next_to_clean);
+	qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
+	rx_ptype = (qword & I40E_RXD_QW1_PTYPE_MASK) >>
+		I40E_RXD_QW1_PTYPE_SHIFT;
+
+	/* populate checksum, VLAN, and protocol */
+	i40e_process_skb_fields(rx_ring, rx_desc, skb, rx_ptype);
+
+	vlan_tag = (qword & BIT(I40E_RX_DESC_STATUS_L2TAG1P_SHIFT)) ?
+		le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1) : 0;
+
+	i40e_trace(clean_rx_irq_rx, rx_ring, rx_desc, skb);
+	i40e_receive_skb(rx_ring, skb, vlan_tag);
+
+	return 0;
+}
+
+/**
  * i40e_run_xdp_tp4 - Runs an XDP program on a the flushable range of packets
  * @a: pointer to frame set
  * @recycled: true if element was removed from flushable range
  * @xdp_prog: XDP program
  * @xdpr: XDP Tx ring
+ * @rxr: pointer to RX ring
  **/
 static void i40e_run_xdp_tp4(struct tp4_frame_set *f, bool *recycled,
-			     struct bpf_prog *xdp_prog, struct i40e_ring *xdpr)
+			     struct bpf_prog *xdp_prog, struct i40e_ring *xdpr,
+			     struct i40e_ring *rxr)
 {
 	tp4a_run_xdp(f, recycled, xdp_prog,
 		     i40e_tp4_xdp_tx_handler, xdpr,
-		     i40e_tp4_xdp_tx_flush_handler, xdpr);
+		     i40e_tp4_xdp_tx_flush_handler, xdpr,
+		     i40e_tp4_xdp_to_kernel_handler, rxr);
 }
diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
index cade34e48a2d..9cb879ea558e 100644
--- a/include/linux/tpacket4.h
+++ b/include/linux/tpacket4.h
@@ -1385,6 +1385,8 @@ static inline void __tp4a_fill_xdp_buff(struct tp4_packet_array *a,
  * @xdp_tx_ctx: XDP xmit handler ctx
  * @xdp_tx_flush_handler: XDP xmit flush handler
  * @xdp_tx_flush_ctx: XDP xmit flush ctx
+ * @xdp_to_kernel_handler: XDP pass to kernel handler
+ * @xdp_to_kernel_ctx: XDP pass to kernel ctx
  **/
 static inline void tp4a_run_xdp(struct tp4_frame_set *f,
 				bool *recycled,
@@ -1393,7 +1395,10 @@ static inline void tp4a_run_xdp(struct tp4_frame_set *f,
 						      struct xdp_buff *xdp),
 				void *xdp_tx_ctx,
 				void (*xdp_tx_flush_handler)(void *ctx),
-				void *xdp_tx_flush_ctx)
+				void *xdp_tx_flush_ctx,
+				int (*xdp_to_kernel_handler)(void *ctx,
+							 struct xdp_buff *xdp),
+				void *xdp_to_kernel_ctx)
 {
 	struct tp4_packet_array *a = f->pkt_arr;
 	struct tpacket4_desc *d, tmp;
@@ -1415,10 +1420,20 @@ static inline void tp4a_run_xdp(struct tp4_frame_set *f,
 	act = bpf_prog_run_xdp(xdp_prog, &xdp);
 	switch (act) {
 	case XDP_PASS:
+	case XDP_PASS_TO_KERNEL:
 		if (data != xdp.data) {
 			diff = data - xdp.data;
 			d->offset += diff;
 		}
+
+		if (act == XDP_PASS_TO_KERNEL) {
+			*recycled = true;
+			tmp = __tp4a_swap_out(a, idx);
+			__tp4a_recycle(a, &tmp);
+
+			err = xdp_to_kernel_handler(xdp_to_kernel_ctx, &xdp);
+		}
+
 		break;
 	case XDP_TX:
 	case XDP_REDIRECT:
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0b7b54d898bd..32d19f5727e2 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -875,6 +875,7 @@ enum xdp_action {
 	XDP_PASS,
 	XDP_TX,
 	XDP_REDIRECT,
+	XDP_PASS_TO_KERNEL,
 };
 
 /* user accessible metadata for XDP packet hook
-- 
2.11.0
