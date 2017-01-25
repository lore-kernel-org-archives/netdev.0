From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/3] bpf: add initial bpf tracepoints
Date: Wed, 25 Jan 2017 02:28:18 +0100
Message-ID: <d330514b794dad5b8b3a8b8652cb449c96357e82.1485306168.git.daniel@iogearbox.net>
References: <cover.1485306168.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1485306168.git.daniel@iogearbox.net>
In-Reply-To: <cover.1485306168.git.daniel@iogearbox.net>
References: <cover.1485306168.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This work adds a number of tracepoints to paths that are either
considered slow-path or exception-like states, where monitoring or
inspecting them would be desirable.

For bpf(2) syscall, tracepoints have been placed for main commands
when they succeed. In XDP case, tracepoint is for exceptions, that
is, f.e. on abnormal BPF program exit such as unknown or XDP_ABORTED
return code, or when error occurs during XDP_TX action and the packet
could not be forwarded.

Both have been split into separate event headers, and can be further
extended. Worst case, if they unexpectedly should get into our way in
future, they can also removed [1]. Of course, these tracepoints (like
any other) can be analyzed by eBPF itself, etc. Example output:

  # ./perf record -a -e bpf:* sleep 10
  # ./perf script
  sock_example  6197 [005]   283.980322:      bpf:bpf_map_create: map type=ARRAY ufd=4 key=4 val=8 max=256 flags=0
  sock_example  6197 [005]   283.980721:       bpf:bpf_prog_load: prog=a5ea8fa30ea6849c type=SOCKET_FILTER ufd=5
  sock_example  6197 [005]   283.988423:   bpf:bpf_prog_get_type: prog=a5ea8fa30ea6849c type=SOCKET_FILTER
  sock_example  6197 [005]   283.988443: bpf:bpf_map_lookup_elem: map type=ARRAY ufd=4 key=[06 00 00 00] val=[00 00 00 00 00 00 00 00]
  [...]
  sock_example  6197 [005]   288.990868: bpf:bpf_map_lookup_elem: map type=ARRAY ufd=4 key=[01 00 00 00] val=[14 00 00 00 00 00 00 00]
       swapper     0 [005]   289.338243:    bpf:bpf_prog_put_rcu: prog=a5ea8fa30ea6849c type=SOCKET_FILTER

  [1] https://lwn.net/Articles/705270/

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  12 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  15 +-
 drivers/net/ethernet/qlogic/qede/qede_fp.c         |   4 +
 drivers/net/virtio_net.c                           |  12 +-
 include/linux/bpf_trace.h                          |   7 +
 include/trace/events/bpf.h                         | 347 +++++++++++++++++++++
 include/trace/events/xdp.h                         |  53 ++++
 kernel/bpf/core.c                                  |   9 +
 kernel/bpf/inode.c                                 |  17 +-
 kernel/bpf/syscall.c                               |  19 +-
 11 files changed, 483 insertions(+), 15 deletions(-)
 create mode 100644 include/linux/bpf_trace.h
 create mode 100644 include/trace/events/bpf.h
 create mode 100644 include/trace/events/xdp.h

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index e362f99..f15ddba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -33,6 +33,7 @@
 
 #include <net/busy_poll.h>
 #include <linux/bpf.h>
+#include <linux/bpf_trace.h>
 #include <linux/mlx4/cq.h>
 #include <linux/slab.h>
 #include <linux/mlx4/qp.h>
@@ -926,10 +927,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							length, cq->ring,
 							&doorbell_pending)))
 					goto consumed;
+				trace_xdp_exception(dev, xdp_prog, act);
 				goto xdp_drop_no_cnt; /* Drop on xmit failure */
 			default:
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
+				trace_xdp_exception(dev, xdp_prog, act);
 			case XDP_DROP:
 				ring->xdp_drop++;
 xdp_drop_no_cnt:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 20f116f..b88297c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -33,6 +33,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
+#include <linux/bpf_trace.h>
 #include <net/busy_poll.h>
 #include "en.h"
 #include "en_tc.h"
@@ -644,7 +645,7 @@ static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
 	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
 }
 
-static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
+static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 					struct mlx5e_dma_info *di,
 					const struct xdp_buff *xdp)
 {
@@ -666,7 +667,7 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 		     MLX5E_SW2HW_MTU(rq->netdev->mtu) < dma_len)) {
 		rq->stats.xdp_drop++;
 		mlx5e_page_release(rq, di, true);
-		return;
+		return false;
 	}
 
 	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_XDP_TX_WQEBBS))) {
@@ -677,7 +678,7 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 		}
 		rq->stats.xdp_tx_full++;
 		mlx5e_page_release(rq, di, true);
-		return;
+		return false;
 	}
 
 	dma_len -= MLX5E_XDP_MIN_INLINE;
@@ -707,6 +708,7 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 
 	sq->db.xdp.doorbell = true;
 	rq->stats.xdp_tx++;
+	return true;
 }
 
 /* returns true if packet was consumed by xdp */
@@ -732,11 +734,13 @@ static inline int mlx5e_xdp_handle(struct mlx5e_rq *rq,
 		*len = xdp.data_end - xdp.data;
 		return false;
 	case XDP_TX:
-		mlx5e_xmit_xdp_frame(rq, di, &xdp);
+		if (unlikely(!mlx5e_xmit_xdp_frame(rq, di, &xdp)))
+			trace_xdp_exception(rq->netdev, prog, act);
 		return true;
 	default:
 		bpf_warn_invalid_xdp_action(act);
 	case XDP_ABORTED:
+		trace_xdp_exception(rq->netdev, prog, act);
 	case XDP_DROP:
 		rq->stats.xdp_drop++;
 		mlx5e_page_release(rq, di, true);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 67afd95..6ac43ab 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -42,6 +42,7 @@
  */
 
 #include <linux/bpf.h>
+#include <linux/bpf_trace.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -1459,7 +1460,7 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 		dev_kfree_skb_any(skb);
 }
 
-static void
+static bool
 nfp_net_tx_xdp_buf(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 		   struct nfp_net_tx_ring *tx_ring,
 		   struct nfp_net_rx_buf *rxbuf, unsigned int pkt_off,
@@ -1473,13 +1474,13 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 
 	if (unlikely(nfp_net_tx_full(tx_ring, 1))) {
 		nfp_net_rx_drop(rx_ring->r_vec, rx_ring, rxbuf, NULL);
-		return;
+		return false;
 	}
 
 	new_frag = nfp_net_napi_alloc_one(nn, DMA_BIDIRECTIONAL, &new_dma_addr);
 	if (unlikely(!new_frag)) {
 		nfp_net_rx_drop(rx_ring->r_vec, rx_ring, rxbuf, NULL);
-		return;
+		return false;
 	}
 	nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
 
@@ -1509,6 +1510,7 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 
 	tx_ring->wr_p++;
 	tx_ring->wr_ptr_add++;
+	return true;
 }
 
 static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, unsigned int len)
@@ -1613,12 +1615,15 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			case XDP_PASS:
 				break;
 			case XDP_TX:
-				nfp_net_tx_xdp_buf(nn, rx_ring, tx_ring, rxbuf,
-						   pkt_off, pkt_len);
+				if (unlikely(!nfp_net_tx_xdp_buf(nn, rx_ring,
+								 tx_ring, rxbuf,
+								 pkt_off, pkt_len)))
+					trace_xdp_exception(nn->netdev, xdp_prog, act);
 				continue;
 			default:
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
+				trace_xdp_exception(nn->netdev, xdp_prog, act);
 			case XDP_DROP:
 				nfp_net_rx_give_one(rx_ring, rxbuf->frag,
 						    rxbuf->dma_addr);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 1a6ca48..445d4d2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -32,6 +32,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
+#include <linux/bpf_trace.h>
 #include <net/udp_tunnel.h>
 #include <linux/ip.h>
 #include <net/ipv6.h>
@@ -1016,6 +1017,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 		/* We need the replacement buffer before transmit. */
 		if (qede_alloc_rx_buffer(rxq, true)) {
 			qede_recycle_rx_bd_ring(rxq, 1);
+			trace_xdp_exception(edev->ndev, prog, act);
 			return false;
 		}
 
@@ -1026,6 +1028,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 			dma_unmap_page(rxq->dev, bd->mapping,
 				       PAGE_SIZE, DMA_BIDIRECTIONAL);
 			__free_page(bd->data);
+			trace_xdp_exception(edev->ndev, prog, act);
 		}
 
 		/* Regardless, we've consumed an Rx BD */
@@ -1035,6 +1038,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 	default:
 		bpf_warn_invalid_xdp_action(act);
 	case XDP_ABORTED:
+		trace_xdp_exception(edev->ndev, prog, act);
 	case XDP_DROP:
 		qede_recycle_rx_bd_ring(rxq, cqe->bd_num);
 	}
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 37db91d..f9bf948 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -23,6 +23,7 @@
 #include <linux/virtio.h>
 #include <linux/virtio_net.h>
 #include <linux/bpf.h>
+#include <linux/bpf_trace.h>
 #include <linux/scatterlist.h>
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
@@ -330,7 +331,7 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	return skb;
 }
 
-static void virtnet_xdp_xmit(struct virtnet_info *vi,
+static bool virtnet_xdp_xmit(struct virtnet_info *vi,
 			     struct receive_queue *rq,
 			     struct send_queue *sq,
 			     struct xdp_buff *xdp,
@@ -382,10 +383,12 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 			put_page(page);
 		} else /* small buffer */
 			kfree_skb(data);
-		return; // On error abort to avoid unnecessary kick
+		/* On error abort to avoid unnecessary kick */
+		return false;
 	}
 
 	virtqueue_kick(sq->vq);
+	return true;
 }
 
 static u32 do_xdp_prog(struct virtnet_info *vi,
@@ -421,11 +424,14 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
 			vi->xdp_queue_pairs +
 			smp_processor_id();
 		xdp.data = buf;
-		virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, data);
+		if (unlikely(!virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp,
+					       data)))
+			trace_xdp_exception(vi->dev, xdp_prog, act);
 		return XDP_TX;
 	default:
 		bpf_warn_invalid_xdp_action(act);
 	case XDP_ABORTED:
+		trace_xdp_exception(vi->dev, xdp_prog, act);
 	case XDP_DROP:
 		return XDP_DROP;
 	}
diff --git a/include/linux/bpf_trace.h b/include/linux/bpf_trace.h
new file mode 100644
index 0000000..b22efbd
--- /dev/null
+++ b/include/linux/bpf_trace.h
@@ -0,0 +1,7 @@
+#ifndef __LINUX_BPF_TRACE_H__
+#define __LINUX_BPF_TRACE_H__
+
+#include <trace/events/bpf.h>
+#include <trace/events/xdp.h>
+
+#endif /* __LINUX_BPF_TRACE_H__ */
diff --git a/include/trace/events/bpf.h b/include/trace/events/bpf.h
new file mode 100644
index 0000000..c3a53fd
--- /dev/null
+++ b/include/trace/events/bpf.h
@@ -0,0 +1,347 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM bpf
+
+#if !defined(_TRACE_BPF_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_BPF_H
+
+#include <linux/filter.h>
+#include <linux/bpf.h>
+#include <linux/fs.h>
+#include <linux/tracepoint.h>
+
+#define __PROG_TYPE_MAP(FN)	\
+	FN(SOCKET_FILTER)	\
+	FN(KPROBE)		\
+	FN(SCHED_CLS)		\
+	FN(SCHED_ACT)		\
+	FN(TRACEPOINT)		\
+	FN(XDP)			\
+	FN(PERF_EVENT)		\
+	FN(CGROUP_SKB)		\
+	FN(CGROUP_SOCK)		\
+	FN(LWT_IN)		\
+	FN(LWT_OUT)		\
+	FN(LWT_XMIT)
+
+#define __MAP_TYPE_MAP(FN)	\
+	FN(HASH)		\
+	FN(ARRAY)		\
+	FN(PROG_ARRAY)		\
+	FN(PERF_EVENT_ARRAY)	\
+	FN(PERCPU_HASH)		\
+	FN(PERCPU_ARRAY)	\
+	FN(STACK_TRACE)		\
+	FN(CGROUP_ARRAY)	\
+	FN(LRU_HASH)		\
+	FN(LRU_PERCPU_HASH)	\
+	FN(LPM_TRIE)
+
+#define __PROG_TYPE_TP_FN(x)	\
+	TRACE_DEFINE_ENUM(BPF_PROG_TYPE_##x);
+#define __PROG_TYPE_SYM_FN(x)	\
+	{ BPF_PROG_TYPE_##x, #x },
+#define __PROG_TYPE_SYM_TAB	\
+	__PROG_TYPE_MAP(__PROG_TYPE_SYM_FN) { -1, 0 }
+__PROG_TYPE_MAP(__PROG_TYPE_TP_FN)
+
+#define __MAP_TYPE_TP_FN(x)	\
+	TRACE_DEFINE_ENUM(BPF_MAP_TYPE_##x);
+#define __MAP_TYPE_SYM_FN(x)	\
+	{ BPF_MAP_TYPE_##x, #x },
+#define __MAP_TYPE_SYM_TAB	\
+	__MAP_TYPE_MAP(__MAP_TYPE_SYM_FN) { -1, 0 }
+__MAP_TYPE_MAP(__MAP_TYPE_TP_FN)
+
+DECLARE_EVENT_CLASS(bpf_prog_event,
+
+	TP_PROTO(const struct bpf_prog *prg),
+
+	TP_ARGS(prg),
+
+	TP_STRUCT__entry(
+		__array(u8, prog_tag, 8)
+		__field(u32, type)
+	),
+
+	TP_fast_assign(
+		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(prg->tag));
+		memcpy(__entry->prog_tag, prg->tag, sizeof(prg->tag));
+		__entry->type = prg->type;
+	),
+
+	TP_printk("prog=%s type=%s",
+		  __print_hex_str(__entry->prog_tag, 8),
+		  __print_symbolic(__entry->type, __PROG_TYPE_SYM_TAB))
+);
+
+DEFINE_EVENT(bpf_prog_event, bpf_prog_get_type,
+
+	TP_PROTO(const struct bpf_prog *prg),
+
+	TP_ARGS(prg)
+);
+
+DEFINE_EVENT(bpf_prog_event, bpf_prog_put_rcu,
+
+	TP_PROTO(const struct bpf_prog *prg),
+
+	TP_ARGS(prg)
+);
+
+TRACE_EVENT(bpf_prog_load,
+
+	TP_PROTO(const struct bpf_prog *prg, int ufd),
+
+	TP_ARGS(prg, ufd),
+
+	TP_STRUCT__entry(
+		__array(u8, prog_tag, 8)
+		__field(u32, type)
+		__field(int, ufd)
+	),
+
+	TP_fast_assign(
+		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(prg->tag));
+		memcpy(__entry->prog_tag, prg->tag, sizeof(prg->tag));
+		__entry->type = prg->type;
+		__entry->ufd  = ufd;
+	),
+
+	TP_printk("prog=%s type=%s ufd=%d",
+		  __print_hex_str(__entry->prog_tag, 8),
+		  __print_symbolic(__entry->type, __PROG_TYPE_SYM_TAB),
+		  __entry->ufd)
+);
+
+TRACE_EVENT(bpf_map_create,
+
+	TP_PROTO(const struct bpf_map *map, int ufd),
+
+	TP_ARGS(map, ufd),
+
+	TP_STRUCT__entry(
+		__field(u32, type)
+		__field(u32, size_key)
+		__field(u32, size_value)
+		__field(u32, max_entries)
+		__field(u32, flags)
+		__field(int, ufd)
+	),
+
+	TP_fast_assign(
+		__entry->type        = map->map_type;
+		__entry->size_key    = map->key_size;
+		__entry->size_value  = map->value_size;
+		__entry->max_entries = map->max_entries;
+		__entry->flags       = map->map_flags;
+		__entry->ufd         = ufd;
+	),
+
+	TP_printk("map type=%s ufd=%d key=%u val=%u max=%u flags=%x",
+		  __print_symbolic(__entry->type, __MAP_TYPE_SYM_TAB),
+		  __entry->ufd, __entry->size_key, __entry->size_value,
+		  __entry->max_entries, __entry->flags)
+);
+
+DECLARE_EVENT_CLASS(bpf_obj_prog,
+
+	TP_PROTO(const struct bpf_prog *prg, int ufd,
+		 const struct filename *pname),
+
+	TP_ARGS(prg, ufd, pname),
+
+	TP_STRUCT__entry(
+		__array(u8, prog_tag, 8)
+		__field(int, ufd)
+		__string(path, pname->name)
+	),
+
+	TP_fast_assign(
+		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(prg->tag));
+		memcpy(__entry->prog_tag, prg->tag, sizeof(prg->tag));
+		__assign_str(path, pname->name);
+		__entry->ufd = ufd;
+	),
+
+	TP_printk("prog=%s path=%s ufd=%d",
+		  __print_hex_str(__entry->prog_tag, 8),
+		  __get_str(path), __entry->ufd)
+);
+
+DEFINE_EVENT(bpf_obj_prog, bpf_obj_pin_prog,
+
+	TP_PROTO(const struct bpf_prog *prg, int ufd,
+		 const struct filename *pname),
+
+	TP_ARGS(prg, ufd, pname)
+);
+
+DEFINE_EVENT(bpf_obj_prog, bpf_obj_get_prog,
+
+	TP_PROTO(const struct bpf_prog *prg, int ufd,
+		 const struct filename *pname),
+
+	TP_ARGS(prg, ufd, pname)
+);
+
+DECLARE_EVENT_CLASS(bpf_obj_map,
+
+	TP_PROTO(const struct bpf_map *map, int ufd,
+		 const struct filename *pname),
+
+	TP_ARGS(map, ufd, pname),
+
+	TP_STRUCT__entry(
+		__field(u32, type)
+		__field(int, ufd)
+		__string(path, pname->name)
+	),
+
+	TP_fast_assign(
+		__assign_str(path, pname->name);
+		__entry->type = map->map_type;
+		__entry->ufd  = ufd;
+	),
+
+	TP_printk("map type=%s ufd=%d path=%s",
+		  __print_symbolic(__entry->type, __MAP_TYPE_SYM_TAB),
+		  __entry->ufd, __get_str(path))
+);
+
+DEFINE_EVENT(bpf_obj_map, bpf_obj_pin_map,
+
+	TP_PROTO(const struct bpf_map *map, int ufd,
+		 const struct filename *pname),
+
+	TP_ARGS(map, ufd, pname)
+);
+
+DEFINE_EVENT(bpf_obj_map, bpf_obj_get_map,
+
+	TP_PROTO(const struct bpf_map *map, int ufd,
+		 const struct filename *pname),
+
+	TP_ARGS(map, ufd, pname)
+);
+
+DECLARE_EVENT_CLASS(bpf_map_keyval,
+
+	TP_PROTO(const struct bpf_map *map, int ufd,
+		 const void *key, const void *val),
+
+	TP_ARGS(map, ufd, key, val),
+
+	TP_STRUCT__entry(
+		__field(u32, type)
+		__field(u32, key_len)
+		__dynamic_array(u8, key, map->key_size)
+		__field(bool, key_trunc)
+		__field(u32, val_len)
+		__dynamic_array(u8, val, map->value_size)
+		__field(bool, val_trunc)
+		__field(int, ufd)
+	),
+
+	TP_fast_assign(
+		memcpy(__get_dynamic_array(key), key, map->key_size);
+		memcpy(__get_dynamic_array(val), val, map->value_size);
+		__entry->type      = map->map_type;
+		__entry->key_len   = min(map->key_size, 16U);
+		__entry->key_trunc = map->key_size != __entry->key_len;
+		__entry->val_len   = min(map->value_size, 16U);
+		__entry->val_trunc = map->value_size != __entry->val_len;
+		__entry->ufd       = ufd;
+	),
+
+	TP_printk("map type=%s ufd=%d key=[%s%s] val=[%s%s]",
+		  __print_symbolic(__entry->type, __MAP_TYPE_SYM_TAB),
+		  __entry->ufd,
+		  __print_hex(__get_dynamic_array(key), __entry->key_len),
+		  __entry->key_trunc ? " ..." : "",
+		  __print_hex(__get_dynamic_array(val), __entry->val_len),
+		  __entry->val_trunc ? " ..." : "")
+);
+
+DEFINE_EVENT(bpf_map_keyval, bpf_map_lookup_elem,
+
+	TP_PROTO(const struct bpf_map *map, int ufd,
+		 const void *key, const void *val),
+
+	TP_ARGS(map, ufd, key, val)
+);
+
+DEFINE_EVENT(bpf_map_keyval, bpf_map_update_elem,
+
+	TP_PROTO(const struct bpf_map *map, int ufd,
+		 const void *key, const void *val),
+
+	TP_ARGS(map, ufd, key, val)
+);
+
+TRACE_EVENT(bpf_map_delete_elem,
+
+	TP_PROTO(const struct bpf_map *map, int ufd,
+		 const void *key),
+
+	TP_ARGS(map, ufd, key),
+
+	TP_STRUCT__entry(
+		__field(u32, type)
+		__field(u32, key_len)
+		__dynamic_array(u8, key, map->key_size)
+		__field(bool, key_trunc)
+		__field(int, ufd)
+	),
+
+	TP_fast_assign(
+		memcpy(__get_dynamic_array(key), key, map->key_size);
+		__entry->type      = map->map_type;
+		__entry->key_len   = min(map->key_size, 16U);
+		__entry->key_trunc = map->key_size != __entry->key_len;
+		__entry->ufd       = ufd;
+	),
+
+	TP_printk("map type=%s ufd=%d key=[%s%s]",
+		  __print_symbolic(__entry->type, __MAP_TYPE_SYM_TAB),
+		  __entry->ufd,
+		  __print_hex(__get_dynamic_array(key), __entry->key_len),
+		  __entry->key_trunc ? " ..." : "")
+);
+
+TRACE_EVENT(bpf_map_next_key,
+
+	TP_PROTO(const struct bpf_map *map, int ufd,
+		 const void *key, const void *key_next),
+
+	TP_ARGS(map, ufd, key, key_next),
+
+	TP_STRUCT__entry(
+		__field(u32, type)
+		__field(u32, key_len)
+		__dynamic_array(u8, key, map->key_size)
+		__dynamic_array(u8, nxt, map->key_size)
+		__field(bool, key_trunc)
+		__field(int, ufd)
+	),
+
+	TP_fast_assign(
+		memcpy(__get_dynamic_array(key), key, map->key_size);
+		memcpy(__get_dynamic_array(nxt), key_next, map->key_size);
+		__entry->type      = map->map_type;
+		__entry->key_len   = min(map->key_size, 16U);
+		__entry->key_trunc = map->key_size != __entry->key_len;
+		__entry->ufd       = ufd;
+	),
+
+	TP_printk("map type=%s ufd=%d key=[%s%s] next=[%s%s]",
+		  __print_symbolic(__entry->type, __MAP_TYPE_SYM_TAB),
+		  __entry->ufd,
+		  __print_hex(__get_dynamic_array(key), __entry->key_len),
+		  __entry->key_trunc ? " ..." : "",
+		  __print_hex(__get_dynamic_array(nxt), __entry->key_len),
+		  __entry->key_trunc ? " ..." : "")
+);
+
+#endif /* _TRACE_BPF_H */
+
+#include <trace/define_trace.h>
diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
new file mode 100644
index 0000000..1b61357
--- /dev/null
+++ b/include/trace/events/xdp.h
@@ -0,0 +1,53 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM xdp
+
+#if !defined(_TRACE_XDP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_XDP_H
+
+#include <linux/netdevice.h>
+#include <linux/filter.h>
+#include <linux/tracepoint.h>
+
+#define __XDP_ACT_MAP(FN)	\
+	FN(ABORTED)		\
+	FN(DROP)		\
+	FN(PASS)		\
+	FN(TX)
+
+#define __XDP_ACT_TP_FN(x)	\
+	TRACE_DEFINE_ENUM(XDP_##x);
+#define __XDP_ACT_SYM_FN(x)	\
+	{ XDP_##x, #x },
+#define __XDP_ACT_SYM_TAB	\
+	__XDP_ACT_MAP(__XDP_ACT_SYM_FN) { -1, 0 }
+__XDP_ACT_MAP(__XDP_ACT_TP_FN)
+
+TRACE_EVENT(xdp_exception,
+
+	TP_PROTO(const struct net_device *dev,
+		 const struct bpf_prog *xdp, u32 act),
+
+	TP_ARGS(dev, xdp, act),
+
+	TP_STRUCT__entry(
+		__string(name, dev->name)
+		__array(u8, prog_tag, 8)
+		__field(u32, act)
+	),
+
+	TP_fast_assign(
+		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
+		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
+		__assign_str(name, dev->name);
+		__entry->act = act;
+	),
+
+	TP_printk("prog=%s device=%s action=%s",
+		  __print_hex_str(__entry->prog_tag, 8),
+		  __get_str(name),
+		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB))
+);
+
+#endif /* _TRACE_XDP_H */
+
+#include <trace/define_trace.h>
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 503d421..fddd76b 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1173,3 +1173,12 @@ int __weak skb_copy_bits(const struct sk_buff *skb, int offset, void *to,
 {
 	return -EFAULT;
 }
+
+/* All definitions of tracepoints related to BPF. */
+#define CREATE_TRACE_POINTS
+#include <linux/bpf_trace.h>
+
+EXPORT_TRACEPOINT_SYMBOL_GPL(xdp_exception);
+
+EXPORT_TRACEPOINT_SYMBOL_GPL(bpf_prog_get_type);
+EXPORT_TRACEPOINT_SYMBOL_GPL(bpf_prog_put_rcu);
diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 0b030c9..fddcae8 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -21,6 +21,7 @@
 #include <linux/parser.h>
 #include <linux/filter.h>
 #include <linux/bpf.h>
+#include <linux/bpf_trace.h>
 
 enum bpf_type {
 	BPF_TYPE_UNSPEC	= 0,
@@ -281,6 +282,13 @@ int bpf_obj_pin_user(u32 ufd, const char __user *pathname)
 	ret = bpf_obj_do_pin(pname, raw, type);
 	if (ret != 0)
 		bpf_any_put(raw, type);
+	if ((trace_bpf_obj_pin_prog_enabled() ||
+	     trace_bpf_obj_pin_map_enabled()) && !ret) {
+		if (type == BPF_TYPE_PROG)
+			trace_bpf_obj_pin_prog(raw, ufd, pname);
+		if (type == BPF_TYPE_MAP)
+			trace_bpf_obj_pin_map(raw, ufd, pname);
+	}
 out:
 	putname(pname);
 	return ret;
@@ -342,8 +350,15 @@ int bpf_obj_get_user(const char __user *pathname)
 	else
 		goto out;
 
-	if (ret < 0)
+	if (ret < 0) {
 		bpf_any_put(raw, type);
+	} else if (trace_bpf_obj_get_prog_enabled() ||
+		   trace_bpf_obj_get_map_enabled()) {
+		if (type == BPF_TYPE_PROG)
+			trace_bpf_obj_get_prog(raw, ret, pname);
+		if (type == BPF_TYPE_MAP)
+			trace_bpf_obj_get_map(raw, ret, pname);
+	}
 out:
 	putname(pname);
 	return ret;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 1d6b29e..05ad086 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -10,6 +10,7 @@
  * General Public License for more details.
  */
 #include <linux/bpf.h>
+#include <linux/bpf_trace.h>
 #include <linux/syscalls.h>
 #include <linux/slab.h>
 #include <linux/anon_inodes.h>
@@ -215,6 +216,7 @@ static int map_create(union bpf_attr *attr)
 		/* failed to allocate fd */
 		goto free_map;
 
+	trace_bpf_map_create(map, err);
 	return err;
 
 free_map:
@@ -339,6 +341,7 @@ static int map_lookup_elem(union bpf_attr *attr)
 	if (copy_to_user(uvalue, value, value_size) != 0)
 		goto free_value;
 
+	trace_bpf_map_lookup_elem(map, ufd, key, value);
 	err = 0;
 
 free_value:
@@ -421,6 +424,8 @@ static int map_update_elem(union bpf_attr *attr)
 	__this_cpu_dec(bpf_prog_active);
 	preempt_enable();
 
+	if (!err)
+		trace_bpf_map_update_elem(map, ufd, key, value);
 free_value:
 	kfree(value);
 free_key:
@@ -466,6 +471,8 @@ static int map_delete_elem(union bpf_attr *attr)
 	__this_cpu_dec(bpf_prog_active);
 	preempt_enable();
 
+	if (!err)
+		trace_bpf_map_delete_elem(map, ufd, key);
 free_key:
 	kfree(key);
 err_put:
@@ -518,6 +525,7 @@ static int map_get_next_key(union bpf_attr *attr)
 	if (copy_to_user(unext_key, next_key, map->key_size) != 0)
 		goto free_next_key;
 
+	trace_bpf_map_next_key(map, ufd, key, next_key);
 	err = 0;
 
 free_next_key:
@@ -671,8 +679,10 @@ static void __bpf_prog_put_rcu(struct rcu_head *rcu)
 
 void bpf_prog_put(struct bpf_prog *prog)
 {
-	if (atomic_dec_and_test(&prog->aux->refcnt))
+	if (atomic_dec_and_test(&prog->aux->refcnt)) {
+		trace_bpf_prog_put_rcu(prog);
 		call_rcu(&prog->aux->rcu, __bpf_prog_put_rcu);
+	}
 }
 EXPORT_SYMBOL_GPL(bpf_prog_put);
 
@@ -781,7 +791,11 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 
 struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 {
-	return __bpf_prog_get(ufd, &type);
+	struct bpf_prog *prog = __bpf_prog_get(ufd, &type);
+
+	if (!IS_ERR(prog))
+		trace_bpf_prog_get_type(prog);
+	return prog;
 }
 EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
@@ -863,6 +877,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 		/* failed to allocate fd */
 		goto free_used_maps;
 
+	trace_bpf_prog_load(prog, err);
 	return err;
 
 free_used_maps:
-- 
1.9.3
