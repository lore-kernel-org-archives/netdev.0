From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/9] mlx4: order-0 allocations and page
 recycling
Date: Tue, 07 Feb 2017 08:06:32 -0800
Message-ID: <1486483592.7793.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170207030240.31357-1-edumazet@google.com>
         <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33214 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754983AbdBGQGe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:06:34 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so12483900pgd.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 08:06:34 -0800 (PST)
In-Reply-To: <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-07 at 17:50 +0200, Tariq Toukan wrote:
> Hi Eric,
> 
> Thanks for your series.
> 
> On 07/02/2017 5:02 AM, Eric Dumazet wrote:
> > As mentioned half a year ago, we better switch mlx4 driver to order-0
> > allocations and page recycling.
> >
> > This reduces vulnerability surface thanks to better skb->truesize tracking
> > and provides better performance in most cases.
> The series makes significant change in the RX data-path, that requires 
> deeper checks, in addition to code review.
> We applied your series and started running both our functional and 
> performance regression.
> We will have results by tomorrow morning, and will analyze them during 
> the day. I'll update about that.


Thanks Tariq.

I have also removed the need to access rx_desc, one less cache line
miss. Added two prefetches as well.

I will incorporate the following in the series.

30 -> 32 Gbits on a single TCP flow.

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 6854a19087edbf0bc9bf29e20a82deaaf043..3959db42b3d15657d4073a0d6391afd6a2a5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -483,7 +483,9 @@ static noinline int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 		truesize += frag_info->frag_stride;
 		if (frag_info->frag_stride == PAGE_SIZE / 2) {
 			frags[nr].page_offset ^= PAGE_SIZE / 2;
-			release = page_count(page) != 1 || page_is_pfmemalloc(page);
+			release = page_count(page) != 1 ||
+				  page_is_pfmemalloc(page) ||
+				  page_to_nid(page) != numa_mem_id();
 		} else {
 			frags[nr].page_offset += frag_info->frag_stride;
 			release = frags[nr].page_offset + frag_info->frag_size > PAGE_SIZE;
@@ -514,12 +516,11 @@ static noinline int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 
 
 static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
-				      struct mlx4_en_rx_desc *rx_desc,
 				      struct mlx4_en_rx_alloc *frags,
+				      void *va,
 				      unsigned int length)
 {
 	struct sk_buff *skb;
-	void *va;
 	int used_frags;
 	dma_addr_t dma;
 
@@ -531,10 +532,6 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	skb_reserve(skb, NET_IP_ALIGN);
 	skb->len = length;
 
-	/* Get pointer to first fragment so we could copy the headers into the
-	 * (linear part of the) skb */
-	va = page_address(frags[0].page) + frags[0].page_offset;
-
 	if (length <= SMALL_PACKET_SIZE) {
 		/* We are copying all relevant data to the skb - temporarily
 		 * sync buffers for the copy */
@@ -689,7 +686,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_cqe *cqe;
 	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
 	struct mlx4_en_rx_alloc *frags;
-	struct mlx4_en_rx_desc *rx_desc;
 	struct bpf_prog *xdp_prog;
 	int doorbell_pending;
 	struct sk_buff *skb;
@@ -722,14 +718,18 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	/* Process all completed CQEs */
 	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
 		    cq->mcq.cons_index & cq->size)) {
+		void *va;
 
 		frags = ring->rx_info + (index << priv->log_rx_info);
-		rx_desc = ring->buf + (index << ring->log_stride);
 
 		/*
 		 * make sure we read the CQE after we read the ownership bit
 		 */
 		dma_rmb();
+		prefetch(frags[0].page);
+		va = page_address(frags[0].page) + frags[0].page_offset;
+
+		prefetch(va + 64);
 
 		/* Drop packet on bad receive or bad checksum */
 		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
@@ -753,7 +753,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			/* Get pointer to first fragment since we haven't
 			 * skb yet and cast it to ethhdr struct
 			 */
-			dma = be64_to_cpu(rx_desc->data[0].addr);
+			dma = frags[0].dma + frags[0].page_offset;
 			dma_sync_single_for_cpu(priv->ddev, dma, sizeof(*ethh),
 						DMA_FROM_DEVICE);
 			ethh = (struct ethhdr *)(page_address(frags[0].page) +
@@ -792,7 +792,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			void *orig_data;
 			u32 act;
 
-			dma = be64_to_cpu(rx_desc->data[0].addr);
+			dma = frags[0].dma + frags[0].page_offset;
 			dma_sync_single_for_cpu(priv->ddev, dma,
 						priv->frag_info[0].frag_size,
 						DMA_FROM_DEVICE);
@@ -880,7 +880,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				goto next;
 
 			if (ip_summed == CHECKSUM_COMPLETE) {
-				void *va = skb_frag_address(skb_shinfo(gro_skb)->frags);
 				if (check_csum(cqe, gro_skb, va,
 					       dev->features)) {
 					ip_summed = CHECKSUM_NONE;
@@ -932,7 +931,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		}
 
 		/* GRO not possible, complete processing here */
-		skb = mlx4_en_rx_skb(priv, rx_desc, frags, length);
+		skb = mlx4_en_rx_skb(priv, frags, va, length);
 		if (unlikely(!skb)) {
 			ring->dropped++;
 			goto next;
