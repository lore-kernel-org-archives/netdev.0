From: sunil.kovvuri@gmail.com
Subject: [PATCH 8/9] net: thunderx: Support for XDP header adjustment
Date: Tue,  2 May 2017 18:36:57 +0530
Message-ID: <1493730418-24606-9-git-send-email-sunil.kovvuri@gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

When in XDP mode reserve XDP_PACKET_HEADROOM bytes at the start
of receive buffer for XDP program to modify headers and adjust
packet start. Additional code changes done to handle such packets.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 63 ++++++++++++++++------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  9 +++-
 2 files changed, 55 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index bb13dee..d6477af 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -502,13 +502,15 @@ static int nicvf_init_resources(struct nicvf *nic)
 }
 
 static inline bool nicvf_xdp_rx(struct nicvf *nic, struct bpf_prog *prog,
-				struct cqe_rx_t *cqe_rx, struct snd_queue *sq)
+				struct cqe_rx_t *cqe_rx, struct snd_queue *sq,
+				struct sk_buff **skb)
 {
 	struct xdp_buff xdp;
 	struct page *page;
 	u32 action;
-	u16 len;
+	u16 len, offset = 0;
 	u64 dma_addr, cpu_addr;
+	void *orig_data;
 
 	/* Retrieve packet buffer's DMA address and length */
 	len = *((u16 *)((void *)cqe_rx + (3 * sizeof(u64))));
@@ -517,17 +519,47 @@ static inline bool nicvf_xdp_rx(struct nicvf *nic, struct bpf_prog *prog,
 	cpu_addr = nicvf_iova_to_phys(nic, dma_addr);
 	if (!cpu_addr)
 		return false;
+	cpu_addr = (u64)phys_to_virt(cpu_addr);
+	page = virt_to_page((void *)cpu_addr);
 
-	xdp.data = phys_to_virt(cpu_addr);
+	xdp.data_hard_start = page_address(page);
+	xdp.data = (void *)cpu_addr;
 	xdp.data_end = xdp.data + len;
+	orig_data = xdp.data;
 
 	rcu_read_lock();
 	action = bpf_prog_run_xdp(prog, &xdp);
 	rcu_read_unlock();
 
+	/* Check if XDP program has changed headers */
+	if (orig_data != xdp.data) {
+		len = xdp.data_end - xdp.data;
+		offset = orig_data - xdp.data;
+		dma_addr -= offset;
+	}
+
 	switch (action) {
 	case XDP_PASS:
-		/* Pass on packet to network stack */
+		/* Check if it's a recycled page, if not
+		 * unmap the DMA mapping.
+		 *
+		 * Recycled page holds an extra reference.
+		 */
+		if (page_ref_count(page) == 1) {
+			dma_addr &= PAGE_MASK;
+			dma_unmap_page_attrs(&nic->pdev->dev, dma_addr,
+					     RCV_FRAG_LEN + XDP_PACKET_HEADROOM,
+					     DMA_FROM_DEVICE,
+					     DMA_ATTR_SKIP_CPU_SYNC);
+		}
+
+		/* Build SKB and pass on packet to network stack */
+		*skb = build_skb(xdp.data,
+				 RCV_FRAG_LEN - cqe_rx->align_pad + offset);
+		if (!*skb)
+			put_page(page);
+		else
+			skb_put(*skb, len);
 		return false;
 	case XDP_TX:
 		nicvf_xdp_sq_append_pkt(nic, sq, (u64)xdp.data, dma_addr, len);
@@ -537,7 +569,6 @@ static inline bool nicvf_xdp_rx(struct nicvf *nic, struct bpf_prog *prog,
 	case XDP_ABORTED:
 		trace_xdp_exception(nic->netdev, prog, action);
 	case XDP_DROP:
-		page = virt_to_page(xdp.data);
 		/* Check if it's a recycled page, if not
 		 * unmap the DMA mapping.
 		 *
@@ -546,7 +577,8 @@ static inline bool nicvf_xdp_rx(struct nicvf *nic, struct bpf_prog *prog,
 		if (page_ref_count(page) == 1) {
 			dma_addr &= PAGE_MASK;
 			dma_unmap_page_attrs(&nic->pdev->dev, dma_addr,
-					     RCV_FRAG_LEN, DMA_FROM_DEVICE,
+					     RCV_FRAG_LEN + XDP_PACKET_HEADROOM,
+					     DMA_FROM_DEVICE,
 					     DMA_ATTR_SKIP_CPU_SYNC);
 		}
 		put_page(page);
@@ -654,7 +686,7 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 				  struct napi_struct *napi,
 				  struct cqe_rx_t *cqe_rx, struct snd_queue *sq)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	struct nicvf *nic = netdev_priv(netdev);
 	struct nicvf *snic = nic;
 	int err = 0;
@@ -676,15 +708,17 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 	}
 
 	/* For XDP, ignore pkts spanning multiple pages */
-	if (nic->xdp_prog && (cqe_rx->rb_cnt == 1))
-		if (nicvf_xdp_rx(snic, nic->xdp_prog, cqe_rx, sq))
+	if (nic->xdp_prog && (cqe_rx->rb_cnt == 1)) {
+		/* Packet consumed by XDP */
+		if (nicvf_xdp_rx(snic, nic->xdp_prog, cqe_rx, sq, &skb))
 			return;
+	} else {
+		skb = nicvf_get_rcv_skb(snic, cqe_rx,
+					nic->xdp_prog ? true : false);
+	}
 
-	skb = nicvf_get_rcv_skb(snic, cqe_rx, nic->xdp_prog ? true : false);
-	if (!skb) {
-		netdev_dbg(nic->netdev, "Packet not received\n");
+	if (!skb)
 		return;
-	}
 
 	if (netif_msg_pktdata(nic)) {
 		netdev_info(nic->netdev, "%s: skb 0x%p, len=%d\n", netdev->name,
@@ -1672,9 +1706,6 @@ static int nicvf_xdp_setup(struct nicvf *nic, struct bpf_prog *prog)
 		return -EOPNOTSUPP;
 	}
 
-	if (prog && prog->xdp_adjust_head)
-		return -EOPNOTSUPP;
-
 	/* ALL SQs attached to CQs i.e same as RQs, are treated as
 	 * XDP Tx queues and more Tx queues are allocated for
 	 * network stack to send pkts out.
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index ec234b6..43428ce 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -164,6 +164,11 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, struct rbdr *rbdr,
 	}
 
 	nic->rb_page_offset = 0;
+
+	/* Reserve space for header modifications by BPF program */
+	if (rbdr->is_xdp)
+		buf_len += XDP_PACKET_HEADROOM;
+
 	/* Check if it's recycled */
 	if (pgcache)
 		nic->rb_page = pgcache->page;
@@ -183,7 +188,7 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, struct rbdr *rbdr,
 			return -ENOMEM;
 		}
 		if (pgcache)
-			pgcache->dma_addr = *rbuf;
+			pgcache->dma_addr = *rbuf + XDP_PACKET_HEADROOM;
 		nic->rb_page_offset += buf_len;
 	}
 
@@ -1575,6 +1580,8 @@ static void nicvf_unmap_rcv_buffer(struct nicvf *nic, u64 dma_addr,
 		 */
 		if (page_ref_count(page) != 1)
 			return;
+
+		len += XDP_PACKET_HEADROOM;
 		/* Receive buffers in XDP mode are mapped from page start */
 		dma_addr &= PAGE_MASK;
 	}
-- 
2.7.4
