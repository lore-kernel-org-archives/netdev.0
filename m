From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 5/5] qede: Support XDP adjustment of headers
Date: Fri, 7 Apr 2017 11:05:01 +0300
Message-ID: <1491552301-23953-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ast@fb.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:56674 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754727AbdDGIGb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:06:31 -0400
In-Reply-To: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case an XDP program is attached, reserve XDP_PACKET_HEADROOM
bytes at the beginning of the packet for the program to play
with.

Modify the XDP logic in the driver to fill-in the missing bits
and re-calculate offsets and length after the program has finished
running to properly reflect the current status of the packet.

We can then go and remove the limitation of not supporting XDP programs
where xdp_adjust_head is set.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_filter.c |  5 -----
 drivers/net/ethernet/qlogic/qede/qede_fp.c     | 17 +++++++++++------
 drivers/net/ethernet/qlogic/qede/qede_main.c   |  1 +
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index ecd5b3a..b00a4fc 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -520,11 +520,6 @@ static int qede_xdp_set(struct qede_dev *edev, struct bpf_prog *prog)
 {
 	struct qede_reload_args args;
 
-	if (prog && prog->xdp_adjust_head) {
-		DP_ERR(edev, "Does not support bpf_xdp_adjust_head()\n");
-		return -EOPNOTSUPP;
-	}
-
 	/* If we're called, there was already a bpf reference increment */
 	args.func = &qede_xdp_reload_func;
 	args.u.new_prog = prog;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index e382d4b..961b1d3 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -994,14 +994,14 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 			struct bpf_prog *prog,
 			struct sw_rx_data *bd,
 			struct eth_fast_path_rx_reg_cqe *cqe,
-			u16 data_offset)
+			u16 *data_offset, u16 *len)
 {
-	u16 len = le16_to_cpu(cqe->len_on_first_bd);
 	struct xdp_buff xdp;
 	enum xdp_action act;
 
-	xdp.data = page_address(bd->data) + data_offset;
-	xdp.data_end = xdp.data + len;
+	xdp.data_hard_start = page_address(bd->data);
+	xdp.data = xdp.data_hard_start + *data_offset;
+	xdp.data_end = xdp.data + *len;
 
 	/* Queues always have a full reset currently, so for the time
 	 * being until there's atomic program replace just mark read
@@ -1011,6 +1011,10 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 	act = bpf_prog_run_xdp(prog, &xdp);
 	rcu_read_unlock();
 
+	/* Recalculate, as XDP might have changed the headers */
+	*data_offset = xdp.data - xdp.data_hard_start;
+	*len = xdp.data_end - xdp.data;
+
 	if (act == XDP_PASS)
 		return true;
 
@@ -1029,7 +1033,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 		/* Now if there's a transmission problem, we'd still have to
 		 * throw current buffer, as replacement was already allocated.
 		 */
-		if (qede_xdp_xmit(edev, fp, bd, data_offset, len)) {
+		if (qede_xdp_xmit(edev, fp, bd, *data_offset, *len)) {
 			dma_unmap_page(rxq->dev, bd->mapping,
 				       PAGE_SIZE, DMA_BIDIRECTIONAL);
 			__free_page(bd->data);
@@ -1231,7 +1235,8 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 
 	/* Run eBPF program if one is attached */
 	if (xdp_prog)
-		if (!qede_rx_xdp(edev, fp, rxq, xdp_prog, bd, fp_cqe, pad))
+		if (!qede_rx_xdp(edev, fp, rxq, xdp_prog, bd, fp_cqe,
+				 &pad, &len))
 			return 0;
 
 	/* If this is an error packet then drop it */
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 91c3078..8c2baf8 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1187,6 +1187,7 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev, struct qede_rx_queue *rxq)
 	rxq->num_rx_buffers = edev->q_num_rx_buffers;
 
 	rxq->rx_buf_size = NET_IP_ALIGN + ETH_OVERHEAD + edev->ndev->mtu;
+	rxq->rx_headroom = edev->xdp_prog ? XDP_PACKET_HEADROOM : 0;
 
 	/* Make sure that the headroom and  payload fit in a single page */
 	if (rxq->rx_buf_size + rxq->rx_headroom > PAGE_SIZE)
-- 
1.9.3
