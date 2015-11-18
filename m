From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 10/14] net: move skb_mark_napi_id() into core networking stack
Date: Wed, 18 Nov 2015 06:30:59 -0800
Message-ID: <1447857063-618-11-git-send-email-edumazet@google.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34944 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933050AbbKRObo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:31:44 -0500
Received: by pacej9 with SMTP id ej9so46606995pac.2
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:31:43 -0800 (PST)
In-Reply-To: <1447857063-618-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We would like to automatically provide busy polling support
to all NAPI drivers, without them having to implement anything.

skb_mark_napi_id() can be called from napi_gro_receive() and
napi_get_frags().

Few drivers are still calling skb_mark_napi_id() because
they use netif_receive_skb(). They should eventually call
napi_gro_receive() instead. I will leave this to drivers
maintainers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c         | 1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 2 --
 drivers/net/ethernet/chelsio/cxgb4/sge.c         | 1 -
 drivers/net/ethernet/emulex/benet/be_main.c      | 1 -
 drivers/net/ethernet/intel/i40e/i40e_txrx.c      | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c    | 1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       | 3 ---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c  | 1 -
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c | 2 +-
 drivers/net/ethernet/sfc/rx.c                    | 1 -
 drivers/net/virtio_net.c                         | 2 --
 net/core/dev.c                                   | 2 ++
 13 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 53ce1222b11d..8a9b493566c9 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -2024,7 +2024,6 @@ read_again:
 		skb->dev = netdev;
 		skb->protocol = eth_type_trans(skb, netdev);
 		skb_record_rx_queue(skb, channel->queue_index);
-		skb_mark_napi_id(skb, napi);
 
 		napi_gro_receive(napi, skb);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ca208a7eecd5..ab9222924bd9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1094,8 +1094,6 @@ reuse_rx:
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 					       le16_to_cpu(cqe_fp->vlan_tag));
 
-		skb_mark_napi_id(skb, &fp->napi);
-
 		napi_gro_receive(&fp->napi, skb);
 next_rx:
 		rx_buf->data = NULL;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index b7b93e7a643d..f650f295f264 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1864,7 +1864,6 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb->truesize += skb->data_len;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxq->rspq.idx);
-	skb_mark_napi_id(skb, &rxq->rspq.napi);
 	pi = netdev_priv(skb->dev);
 	if (pi->rxtstamp)
 		cxgb4_sgetim_to_hwtstamp(adapter, skb_hwtstamps(skb),
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b6ad02909d6b..c29d62496ad9 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2184,7 +2184,6 @@ static void be_rx_compl_process_gro(struct be_rx_obj *rxo,
 		skb_set_hash(skb, rxcp->rss_hash, PKT_HASH_TYPE_L3);
 
 	skb->csum_level = rxcp->tunneled;
-	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), rxcp->vlan_tag);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 635b3ac17877..6649ce4ba2de 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1632,7 +1632,6 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 			continue;
 		}
 #endif
-		skb_mark_napi_id(skb, &rx_ring->q_vector->napi);
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 
 		rx_desc->wb.qword1.status_error_len = 0;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 47e9a90d6b10..77968b184b1f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1090,7 +1090,6 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 			continue;
 		}
 #endif
-		skb_mark_napi_id(skb, &rx_ring->q_vector->napi);
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 
 		rx_desc->wb.qword1.status_error_len = 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 47395ff5d908..4089d776d01a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1659,6 +1659,7 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
 			 struct sk_buff *skb)
 {
+	skb_mark_napi_id(skb, &q_vector->napi);
 	if (ixgbe_qv_busy_polling(q_vector))
 		netif_receive_skb(skb);
 	else
@@ -2123,7 +2124,6 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 #endif /* IXGBE_FCOE */
-		skb_mark_napi_id(skb, &q_vector->napi);
 		ixgbe_rx_skb(q_vector, skb);
 
 		/* update budget accounting */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 1feead34093b..41440b2b20a3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -925,7 +925,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 						PKT_HASH_TYPE_L3);
 
 			skb_record_rx_queue(gro_skb, cq->ring);
-			skb_mark_napi_id(gro_skb, &cq->napi);
 
 			if (ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL) {
 				timestamp = mlx4_en_get_cqe_ts(cqe);
@@ -988,8 +987,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					       timestamp);
 		}
 
-		skb_mark_napi_id(skb, &cq->napi);
-
 		napi_gro_receive(&cq->napi, skb);
 next:
 		for (nr = 0; nr < priv->num_frags; nr++)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index fe752f8e24b9..7c8c4088d1be 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -243,7 +243,6 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
 		skb            = rq->skb[wqe_counter];
 		prefetch(skb->data);
-		skb_mark_napi_id(skb, cq->napi);
 		rq->skb[wqe_counter] = NULL;
 
 		dma_unmap_single(rq->pdev,
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 83651ac8ddb9..acf866147d65 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1488,7 +1488,6 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 	}
 	myri10ge_vlan_rx(mgp->dev, va, skb);
 	skb_record_rx_queue(skb, ss - &mgp->ss[0]);
-	skb_mark_napi_id(skb, &ss->napi);
 
 	if (polling) {
 		int hlen;
@@ -1506,6 +1505,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum)
 		skb->data_len -= hlen;
 		skb->tail += hlen;
 		skb->protocol = eth_type_trans(skb, dev);
+		skb_mark_napi_id(skb, &ss->napi);
 		netif_receive_skb(skb);
 	}
 	else
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 809ea4610a77..8956995b2fe7 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -463,7 +463,6 @@ efx_rx_packet_gro(struct efx_channel *channel, struct efx_rx_buffer *rx_buf,
 
 	skb_record_rx_queue(skb, channel->rx_queue.core_index);
 
-	skb_mark_napi_id(skb, &channel->napi_str);
 	gro_result = napi_gro_frags(napi);
 	if (gro_result != GRO_DROP)
 		channel->irq_mod_score += 2;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d8838dedb7a4..d1d14cecf450 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -516,8 +516,6 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 		skb_shinfo(skb)->gso_segs = 0;
 	}
 
-	skb_mark_napi_id(skb, &rq->napi);
-
 	napi_gro_receive(&rq->napi, skb);
 	return;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 93009610aee8..83b48747928c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4356,6 +4356,7 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
+	skb_mark_napi_id(skb, napi);
 	trace_napi_gro_receive_entry(skb);
 
 	skb_gro_reset_offset(skb);
@@ -4390,6 +4391,7 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi)
 	if (!skb) {
 		skb = napi_alloc_skb(napi, GRO_MAX_HEAD);
 		napi->skb = skb;
+		skb_mark_napi_id(skb, napi);
 	}
 	return skb;
 }
-- 
2.6.0.rc2.230.g3dd15c0
