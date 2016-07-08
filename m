From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v6 12/12] net/mlx4_en: add prefetch in xdp rx path
Date: Thu,  7 Jul 2016 19:15:24 -0700
Message-ID: <1467944124-14891-13-git-send-email-bblanco@plumgrid.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35764 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993AbcGHCPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 22:15:54 -0400
Received: by mail-pf0-f171.google.com with SMTP id c2so11321981pfa.2
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 19:15:54 -0700 (PDT)
In-Reply-To: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP programs read and/or write packet data very early, and cache miss is
seen to be a bottleneck.

Add prefetch logic in the xdp case 3 packets in the future. Throughput
improved from 10Mpps to 12.5Mpps.  LLC misses as reported by perf stat
reduced from ~14% to ~7%.  Prefetch values of 0 through 5 were compared
with >3 showing dimishing returns.

Before:
 21.94%  ksoftirqd/0  [mlx4_en]         [k] 0x000000000001d6e4
 12.96%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_process_rx_cq
 12.28%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_xmit_frame
 11.93%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_poll_tx_cq
  4.77%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_prepare_rx_desc
  3.13%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_free_tx_desc.isra.30
  2.68%  ksoftirqd/0  [kernel.vmlinux]  [k] bpf_map_lookup_elem
  2.22%  ksoftirqd/0  [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
  2.02%  ksoftirqd/0  [mlx4_core]       [k] mlx4_eq_int
  1.92%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_rx_recycle

After:
 20.70%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_xmit_frame
 18.14%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_process_rx_cq
 16.30%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_poll_tx_cq
  6.49%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_prepare_rx_desc
  4.06%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_free_tx_desc.isra.30
  2.76%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_rx_recycle
  2.37%  ksoftirqd/0  [mlx4_core]       [k] mlx4_eq_int
  1.44%  ksoftirqd/0  [kernel.vmlinux]  [k] bpf_map_lookup_elem
  1.43%  swapper      [kernel.vmlinux]  [k] intel_idle
  1.20%  ksoftirqd/0  [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
  1.19%  ksoftirqd/0  [mlx4_core]       [k] 0x0000000000049eb8

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 41c76fe..65e93f7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -881,10 +881,17 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		 * read bytes but not past the end of the frag.
 		 */
 		if (prog) {
+			struct mlx4_en_rx_alloc *pref;
 			struct xdp_buff xdp;
+			int pref_index;
 			dma_addr_t dma;
 			u32 act;
 
+			pref_index = (index + 3) & ring->size_mask;
+			pref = ring->rx_info +
+					(pref_index << priv->log_rx_info);
+			prefetch(page_address(pref->page) + pref->page_offset);
+
 			dma = be64_to_cpu(rx_desc->data[0].addr);
 			dma_sync_single_for_cpu(priv->ddev, dma,
 						priv->frag_info[0].frag_size,
-- 
2.8.2
