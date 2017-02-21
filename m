From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v3 8/8] xdp: Cleanup after API changes
Date: Tue, 21 Feb 2017 11:34:17 -0800
Message-ID: <20170221193417.3641224-9-tom@herbertland.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47196 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754214AbdBUTeh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 14:34:37 -0500
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LJSBug025509
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:36 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28ru5a064b-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:36 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 c3bc1e6ef86c11e6b7900002c9dfb610-3df0a00 for <netdev@vger.kernel.org>; Tue,
 21 Feb 2017 11:34:30 -0800
In-Reply-To: <20170221193417.3641224-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
  - Change trace_xdp_hook_exception to trace_xdp_exception
  - Remove XDP_SETUP_PROG and XDP_QUERY_PROG constants
  - Remove bpf_warn_invalid_xdp_action

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      |  4 +--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  4 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  4 +--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  8 +++---
 drivers/net/ethernet/qlogic/qede/qede_fp.c         |  6 ++---
 drivers/net/virtio_net.c                           |  8 +++---
 include/linux/filter.h                             |  1 -
 include/linux/netdevice.h                          | 15 -----------
 include/trace/events/xdp.h                         | 29 ----------------------
 kernel/bpf/core.c                                  |  1 -
 net/core/filter.c                                  |  6 -----
 11 files changed, 16 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 3cfdc94..e894b67 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -134,7 +134,7 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 
 	case XDP_TX:
 		if (tx_avail < 2) {
-			trace_xdp_hook_exception(bp->dev, last_hook, act);
+			trace_xdp_exception(bp->dev, last_hook, act);
 			bnxt_reuse_rx_data(rxr, cons, page);
 			return true;
 		}
@@ -150,7 +150,7 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		xdp_warn_invalid_action(act);
 		/* Fall thru */
 	case XDP_ABORTED:
-		trace_xdp_hook_exception(bp->dev, last_hook, act);
+		trace_xdp_exception(bp->dev, last_hook, act);
 		/* Fall thru */
 	case XDP_DROP:
 		bnxt_reuse_rx_data(rxr, cons, page);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index a8fddc0..d8648fe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -927,12 +927,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							length, cq->ring,
 							&doorbell_pending)))
 					goto consumed;
-				trace_xdp_hook_exception(dev, last_hook, act);
+				trace_xdp_exception(dev, last_hook, act);
 				goto xdp_drop_no_cnt; /* Drop on xmit failure */
 			default:
 				xdp_warn_invalid_action(act);
 			case XDP_ABORTED:
-				trace_xdp_hook_exception(dev, last_hook, act);
+				trace_xdp_exception(dev, last_hook, act);
 			case XDP_DROP:
 				ring->xdp_drop++;
 xdp_drop_no_cnt:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 50ab4b9..1be1eef 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -740,12 +740,12 @@ static inline int mlx5e_xdp_handle(struct mlx5e_rq *rq,
 		return false;
 	case XDP_TX:
 		if (unlikely(!mlx5e_xmit_xdp_frame(rq, di, &xdp)))
-			trace_xdp_hook_exception(rq->netdev, last_hook, act);
+			trace_xdp_exception(rq->netdev, last_hook, act);
 		return true;
 	default:
 		xdp_warn_invalid_action(act);
 	case XDP_ABORTED:
-		trace_xdp_hook_exception(rq->netdev, last_hook, act);
+		trace_xdp_exception(rq->netdev, last_hook, act);
 	case XDP_DROP:
 		rq->stats.xdp_drop++;
 		mlx5e_page_release(rq, di, true);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 6200035..82c4975 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1616,15 +1616,13 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 				if (unlikely(!nfp_net_tx_xdp_buf(nn, rx_ring,
 								 tx_ring, rxbuf,
 								 pkt_off, pkt_len)))
-					trace_xdp_hook_exception(nn->netdev,
-								 last_hook,
-								 act);
+					trace_xdp_exception(nn->netdev,
+							    last_hook, act);
 				continue;
 			default:
 				xdp_warn_invalid_action(act);
 			case XDP_ABORTED:
-				trace_xdp_hook_exception(nn->netdev, last_hook,
-							 act);
+				trace_xdp_exception(nn->netdev, last_hook, act);
 			case XDP_DROP:
 				nfp_net_rx_give_one(rx_ring, rxbuf->frag,
 						    rxbuf->dma_addr);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 7423317..bd72718 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -1022,7 +1022,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 		/* We need the replacement buffer before transmit. */
 		if (qede_alloc_rx_buffer(rxq, true)) {
 			qede_recycle_rx_bd_ring(rxq, 1);
-			trace_xdp_hook_exception(edev->ndev, last_hook, act);
+			trace_xdp_exception(edev->ndev, last_hook, act);
 			goto out;
 		}
 
@@ -1033,7 +1033,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 			dma_unmap_page(rxq->dev, bd->mapping,
 				       PAGE_SIZE, DMA_BIDIRECTIONAL);
 			__free_page(bd->data);
-			trace_xdp_hook_exception(edev->ndev, last_hook, act);
+			trace_xdp_exception(edev->ndev, last_hook, act);
 		}
 
 		/* Regardless, we've consumed an Rx BD */
@@ -1043,7 +1043,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 	default:
 		xdp_warn_invalid_action(act);
 	case XDP_ABORTED:
-		trace_xdp_hook_exception(edev->ndev, last_hook, act);
+		trace_xdp_exception(edev->ndev, last_hook, act);
 	case XDP_DROP:
 		qede_recycle_rx_bd_ring(rxq, cqe->bd_num);
 	}
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 1f5eddf..12d5102 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -427,13 +427,13 @@ static struct sk_buff *receive_small(struct net_device *dev,
 			break;
 		case XDP_TX:
 			if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp)))
-				trace_xdp_hook_exception(vi->dev, last_hook, act);
+				trace_xdp_exception(vi->dev, last_hook, act);
 			rcu_read_unlock();
 			goto xdp_xmit;
 		default:
 			xdp_warn_invalid_action(act);
 		case XDP_ABORTED:
-			trace_xdp_hook_exception(vi->dev, last_hook, act);
+			trace_xdp_exception(vi->dev, last_hook, act);
 		case XDP_DROP:
 			goto err_xdp;
 		}
@@ -619,7 +619,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			break;
 		case XDP_TX:
 			if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp)))
-				trace_xdp_hook_exception(vi->dev, last_hook, act);
+				trace_xdp_exception(vi->dev, last_hook, act);
 			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
 			if (unlikely(xdp_page != page))
 				goto err_xdp;
@@ -628,7 +628,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		default:
 			xdp_warn_invalid_action(act);
 		case XDP_ABORTED:
-			trace_xdp_hook_exception(vi->dev, last_hook, act);
+			trace_xdp_exception(vi->dev, last_hook, act);
 		case XDP_DROP:
 			if (unlikely(xdp_page != page))
 				__free_pages(xdp_page, 0);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 53b737f..a9578e9 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -632,7 +632,6 @@ bool bpf_helper_changes_pkt_data(void *func);
 
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
-void bpf_warn_invalid_xdp_action(u32 act);
 
 #ifdef CONFIG_BPF_JIT
 extern int bpf_jit_enable;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 57ac7ea..4024088 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -811,18 +811,6 @@ struct tc_to_netdev {
  * to the netdevice through the xdp op.
  */
 enum xdp_netdev_command {
-	/* Set or clear a bpf program used in the earliest stages of packet
-	 * rx. The prog will have been loaded as BPF_PROG_TYPE_XDP. The callee
-	 * is responsible for calling bpf_prog_put on any old progs that are
-	 * stored. In case of error, the callee need not release the new prog
-	 * reference, but on success it takes ownership and must bpf_prog_put
-	 * when it is no longer used.
-	 */
-	XDP_SETUP_PROG,
-	/* Check if a bpf program is set on the device.  The callee should
-	 * return true if a program is currently attached and running.
-	 */
-	XDP_QUERY_PROG,
 	/* Initialize device to use XDP. Called when first XDP program is
 	 * registered on a device (including on a NAPI instance).
 	 */
@@ -840,11 +828,8 @@ enum xdp_netdev_command {
 struct netdev_xdp {
 	enum xdp_netdev_command command;
 	union {
-		/* XDP_SETUP_PROG */
 		/* XDP_CHECK_BPF_PROG */
 		struct bpf_prog *prog;
-		/* XDP_QUERY_PROG */
-		bool prog_attached;
 	};
 };
 
diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 9ca6306..d225de6 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -26,35 +26,6 @@ __XDP_ACT_MAP(__XDP_ACT_TP_FN)
 TRACE_EVENT(xdp_exception,
 
 	TP_PROTO(const struct net_device *dev,
-		 const struct bpf_prog *xdp, u32 act),
-
-	TP_ARGS(dev, xdp, act),
-
-	TP_STRUCT__entry(
-		__string(name, dev->name)
-		__array(u8, prog_tag, 8)
-		__field(u32, act)
-	),
-
-	TP_fast_assign(
-		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
-		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
-		__assign_str(name, dev->name);
-		__entry->act = act;
-	),
-
-	TP_printk("prog=%s device=%s action=%s",
-		  __print_hex_str(__entry->prog_tag, 8),
-		  __get_str(name),
-		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB))
-);
-
-/* Temporary trace function. This will be renamed to xdp_exception after all
- * the calling drivers have been patched.
- */
-TRACE_EVENT(xdp_hook_exception,
-
-	TP_PROTO(const struct net_device *dev,
 		 const struct xdp_hook *hook, u32 act),
 
 	TP_ARGS(dev, hook, act),
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 04f2e30..f45827e2 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1412,7 +1412,6 @@ int __weak skb_copy_bits(const struct sk_buff *skb, int offset, void *to,
 #include <linux/bpf_trace.h>
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(xdp_exception);
-EXPORT_TRACEPOINT_SYMBOL_GPL(xdp_hook_exception);
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(bpf_prog_get_type);
 EXPORT_TRACEPOINT_SYMBOL_GPL(bpf_prog_put_rcu);
diff --git a/net/core/filter.c b/net/core/filter.c
index 9a5de43..15337d4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2991,12 +2991,6 @@ static bool xdp_is_valid_access(int off, int size,
 	return __is_valid_xdp_access(off, size);
 }
 
-void bpf_warn_invalid_xdp_action(u32 act)
-{
-	WARN_ONCE(1, "Illegal XDP return value %u, expect packet loss\n", act);
-}
-EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
-
 static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 				  const struct bpf_insn *si,
 				  struct bpf_insn *insn_buf,
-- 
2.9.3
