From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Mon, 25 Sep 2017 02:25:51 +0200
Message-ID: <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37213 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933009AbdIYA1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 20:27:06 -0400
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work enables generic transfer of metadata from XDP into skb. The
basic idea is that we can make use of the fact that the resulting skb
must be linear and already comes with a larger headroom for supporting
bpf_xdp_adjust_head(), which mangles xdp->data. Here, we base our work
on a similar principle and introduce a small helper bpf_xdp_adjust_meta()
for adjusting a new pointer called xdp->data_meta. Thus, the packet has
a flexible and programmable room for meta data, followed by the actual
packet data. struct xdp_buff is therefore laid out that we first point
to data_hard_start, then data_meta directly prepended to data followed
by data_end marking the end of packet. bpf_xdp_adjust_head() takes into
account whether we have meta data already prepended and if so, memmove()s
this along with the given offset provided there's enough room.

xdp->data_meta is optional and programs are not required to use it. The
rationale is that when we process the packet in XDP (e.g. as DoS filter),
we can push further meta data along with it for the XDP_PASS case, and
give the guarantee that a clsact ingress BPF program on the same device
can pick this up for further post-processing. Since we work with skb
there, we can also set skb->mark, skb->priority or other skb meta data
out of BPF, thus having this scratch space generic and programmable
allows for more flexibility than defining a direct 1:1 transfer of
potentially new XDP members into skb (it's also more efficient as we
don't need to initialize/handle each of such new members). The facility
also works together with GRO aggregation. The scratch space at the head
of the packet can be multiple of 4 byte up to 32 byte large. Drivers not
yet supporting xdp->data_meta can simply be set up with xdp->data_meta
as xdp->data + 1 as bpf_xdp_adjust_meta() will detect this and bail out,
such that the subsequent match against xdp->data for later access is
guaranteed to fail.

The verifier treats xdp->data_meta/xdp->data the same way as we treat
xdp->data/xdp->data_end pointer comparisons. The requirement for doing
the compare against xdp->data is that it hasn't been modified from it's
original address we got from ctx access. It may have a range marking
already from prior successful xdp->data/xdp->data_end pointer comparisons
though.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      |   1 +
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |   1 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   1 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   1 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   1 +
 drivers/net/ethernet/qlogic/qede/qede_fp.c         |   1 +
 drivers/net/tun.c                                  |   1 +
 drivers/net/virtio_net.c                           |   2 +
 include/linux/bpf.h                                |   1 +
 include/linux/filter.h                             |  21 +++-
 include/linux/skbuff.h                             |  68 +++++++++++-
 include/uapi/linux/bpf.h                           |  13 ++-
 kernel/bpf/verifier.c                              | 114 ++++++++++++++++-----
 net/bpf/test_run.c                                 |   1 +
 net/core/dev.c                                     |  31 +++++-
 net/core/filter.c                                  |  77 +++++++++++++-
 net/core/skbuff.c                                  |   2 +
 19 files changed, 297 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index d8f0c83..06ce63c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -94,6 +94,7 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 
 	xdp.data_hard_start = *data_ptr - offset;
 	xdp.data = *data_ptr;
+	xdp_set_data_meta_invalid(&xdp);
 	xdp.data_end = *data_ptr + *len;
 	orig_data = xdp.data;
 	mapping = rx_buf->mapping - bp->rx_dma_offset;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 49b80da..d68478a 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -523,6 +523,7 @@ static inline bool nicvf_xdp_rx(struct nicvf *nic, struct bpf_prog *prog,
 
 	xdp.data_hard_start = page_address(page);
 	xdp.data = (void *)cpu_addr;
+	xdp_set_data_meta_invalid(&xdp);
 	xdp.data_end = xdp.data + len;
 	orig_data = xdp.data;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 1519dfb..f426762 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2107,6 +2107,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		if (!skb) {
 			xdp.data = page_address(rx_buffer->page) +
 				   rx_buffer->page_offset;
+			xdp_set_data_meta_invalid(&xdp);
 			xdp.data_hard_start = xdp.data -
 					      i40e_rx_offset(rx_ring);
 			xdp.data_end = xdp.data + size;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d962368..04bb03b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2326,6 +2326,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		if (!skb) {
 			xdp.data = page_address(rx_buffer->page) +
 				   rx_buffer->page_offset;
+			xdp_set_data_meta_invalid(&xdp);
 			xdp.data_hard_start = xdp.data -
 					      ixgbe_rx_offset(rx_ring);
 			xdp.data_end = xdp.data + size;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b97a55c8..8f9cb8a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -762,6 +762,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 
 			xdp.data_hard_start = va - frags[0].page_offset;
 			xdp.data = va;
+			xdp_set_data_meta_invalid(&xdp);
 			xdp.data_end = xdp.data + length;
 			orig_data = xdp.data;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index f1dd638..30b3f3f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -794,6 +794,7 @@ static inline int mlx5e_xdp_handle(struct mlx5e_rq *rq,
 		return false;
 
 	xdp.data = va + *rx_headroom;
+	xdp_set_data_meta_invalid(&xdp);
 	xdp.data_end = xdp.data + *len;
 	xdp.data_hard_start = va;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 1c0187f..e3a38be 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1583,6 +1583,7 @@ static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, void *hard_start,
 
 	xdp.data_hard_start = hard_start;
 	xdp.data = data + *off;
+	xdp_set_data_meta_invalid(&xdp);
 	xdp.data_end = data + *off + *len;
 
 	orig_data = xdp.data;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 6fc854b..48ec4c5 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -1004,6 +1004,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 
 	xdp.data_hard_start = page_address(bd->data);
 	xdp.data = xdp.data_hard_start + *data_offset;
+	xdp_set_data_meta_invalid(&xdp);
 	xdp.data_end = xdp.data + *len;
 
 	/* Queues always have a full reset currently, so for the time
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3c9985f..1757fd7 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1314,6 +1314,7 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 
 		xdp.data_hard_start = buf;
 		xdp.data = buf + pad;
+		xdp_set_data_meta_invalid(&xdp);
 		xdp.data_end = xdp.data + len;
 		orig_data = xdp.data;
 		act = bpf_prog_run_xdp(xdp_prog, &xdp);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index dd14a45..fc059f1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -554,6 +554,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
 
 		xdp.data_hard_start = buf + VIRTNET_RX_PAD + vi->hdr_len;
 		xdp.data = xdp.data_hard_start + xdp_headroom;
+		xdp_set_data_meta_invalid(&xdp);
 		xdp.data_end = xdp.data + len;
 		orig_data = xdp.data;
 		act = bpf_prog_run_xdp(xdp_prog, &xdp);
@@ -686,6 +687,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		data = page_address(xdp_page) + offset;
 		xdp.data_hard_start = data - VIRTIO_XDP_HEADROOM + vi->hdr_len;
 		xdp.data = data + vi->hdr_len;
+		xdp_set_data_meta_invalid(&xdp);
 		xdp.data_end = xdp.data + (len - vi->hdr_len);
 		act = bpf_prog_run_xdp(xdp_prog, &xdp);
 
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 8390859..2b672c5 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -137,6 +137,7 @@ enum bpf_reg_type {
 	PTR_TO_MAP_VALUE,	 /* reg points to map element value */
 	PTR_TO_MAP_VALUE_OR_NULL,/* points to map elem value or NULL */
 	PTR_TO_STACK,		 /* reg == frame_pointer + offset */
+	PTR_TO_PACKET_META,	 /* skb->data - meta_len */
 	PTR_TO_PACKET,		 /* reg points to skb->data */
 	PTR_TO_PACKET_END,	 /* skb->data + headlen */
 };
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 052bab3..911d454 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -487,12 +487,14 @@ struct sk_filter {
 
 struct bpf_skb_data_end {
 	struct qdisc_skb_cb qdisc_cb;
+	void *data_meta;
 	void *data_end;
 };
 
 struct xdp_buff {
 	void *data;
 	void *data_end;
+	void *data_meta;
 	void *data_hard_start;
 };
 
@@ -507,7 +509,8 @@ static inline void bpf_compute_data_pointers(struct sk_buff *skb)
 	struct bpf_skb_data_end *cb = (struct bpf_skb_data_end *)skb->cb;
 
 	BUILD_BUG_ON(sizeof(*cb) > FIELD_SIZEOF(struct sk_buff, cb));
-	cb->data_end = skb->data + skb_headlen(skb);
+	cb->data_meta = skb->data - skb_metadata_len(skb);
+	cb->data_end  = skb->data + skb_headlen(skb);
 }
 
 static inline u8 *bpf_skb_cb(struct sk_buff *skb)
@@ -728,8 +731,22 @@ int xdp_do_redirect(struct net_device *dev,
 		    struct bpf_prog *prog);
 void xdp_do_flush_map(void);
 
+/* Drivers not supporting XDP metadata can use this helper, which
+ * rejects any room expansion for metadata as a result.
+ */
+static __always_inline void
+xdp_set_data_meta_invalid(struct xdp_buff *xdp)
+{
+	xdp->data_meta = xdp->data + 1;
+}
+
+static __always_inline bool
+xdp_data_meta_unsupported(const struct xdp_buff *xdp)
+{
+	return unlikely(xdp->data_meta > xdp->data);
+}
+
 void bpf_warn_invalid_xdp_action(u32 act);
-void bpf_warn_invalid_xdp_redirect(u32 ifindex);
 
 struct sock *do_sk_redirect_map(void);
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f9db553..19e64bf 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -489,8 +489,9 @@ int skb_zerocopy_iter_stream(struct sock *sk, struct sk_buff *skb,
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
-	unsigned short	_unused;
-	unsigned char	nr_frags;
+	__u8		__unused;
+	__u8		meta_len;
+	__u8		nr_frags;
 	__u8		tx_flags;
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
@@ -3400,6 +3401,69 @@ static inline ktime_t net_invalid_timestamp(void)
 	return 0;
 }
 
+static inline u8 skb_metadata_len(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->meta_len;
+}
+
+static inline void *skb_metadata_end(const struct sk_buff *skb)
+{
+	return skb_mac_header(skb);
+}
+
+static inline bool __skb_metadata_differs(const struct sk_buff *skb_a,
+					  const struct sk_buff *skb_b,
+					  u8 meta_len)
+{
+	const void *a = skb_metadata_end(skb_a);
+	const void *b = skb_metadata_end(skb_b);
+	/* Using more efficient varaiant than plain call to memcmp(). */
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	u64 diffs = 0;
+
+	switch (meta_len) {
+#define __it(x, op) (x -= sizeof(u##op))
+#define __it_diff(a, b, op) (*(u##op *)__it(a, op)) ^ (*(u##op *)__it(b, op))
+	case 32: diffs |= __it_diff(a, b, 64);
+	case 24: diffs |= __it_diff(a, b, 64);
+	case 16: diffs |= __it_diff(a, b, 64);
+	case  8: diffs |= __it_diff(a, b, 64);
+		break;
+	case 28: diffs |= __it_diff(a, b, 64);
+	case 20: diffs |= __it_diff(a, b, 64);
+	case 12: diffs |= __it_diff(a, b, 64);
+	case  4: diffs |= __it_diff(a, b, 32);
+		break;
+	}
+	return diffs;
+#else
+	return memcmp(a - meta_len, b - meta_len, meta_len);
+#endif
+}
+
+static inline bool skb_metadata_differs(const struct sk_buff *skb_a,
+					const struct sk_buff *skb_b)
+{
+	u8 len_a = skb_metadata_len(skb_a);
+	u8 len_b = skb_metadata_len(skb_b);
+
+	if (!(len_a | len_b))
+		return false;
+
+	return len_a != len_b ?
+	       true : __skb_metadata_differs(skb_a, skb_b, len_a);
+}
+
+static inline void skb_metadata_set(struct sk_buff *skb, u8 meta_len)
+{
+	skb_shinfo(skb)->meta_len = meta_len;
+}
+
+static inline void skb_metadata_clear(struct sk_buff *skb)
+{
+	skb_metadata_set(skb, 0);
+}
+
 struct sk_buff *skb_clone_sk(struct sk_buff *skb);
 
 #ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 43ab5c4..e43491a 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -582,6 +582,12 @@ enum bpf_attach_type {
  *	@map: pointer to sockmap to update
  *	@key: key to insert/update sock in map
  *	@flags: same flags as map update elem
+ *
+ * int bpf_xdp_adjust_meta(xdp_md, delta)
+ *     Adjust the xdp_md.data_meta by delta
+ *     @xdp_md: pointer to xdp_md
+ *     @delta: An positive/negative integer to be added to xdp_md.data_meta
+ *     Return: 0 on success or negative on error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -638,6 +644,7 @@ enum bpf_attach_type {
 	FN(redirect_map),		\
 	FN(sk_redirect_map),		\
 	FN(sock_map_update),		\
+	FN(xdp_adjust_meta),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -715,7 +722,7 @@ struct __sk_buff {
 	__u32 data_end;
 	__u32 napi_id;
 
-	/* accessed by BPF_PROG_TYPE_sk_skb types */
+	/* Accessed by BPF_PROG_TYPE_sk_skb types from here to ... */
 	__u32 family;
 	__u32 remote_ip4;	/* Stored in network byte order */
 	__u32 local_ip4;	/* Stored in network byte order */
@@ -723,6 +730,9 @@ struct __sk_buff {
 	__u32 local_ip6[4];	/* Stored in network byte order */
 	__u32 remote_port;	/* Stored in network byte order */
 	__u32 local_port;	/* stored in host byte order */
+	/* ... here. */
+
+	__u32 data_meta;
 };
 
 struct bpf_tunnel_key {
@@ -783,6 +793,7 @@ enum xdp_action {
 struct xdp_md {
 	__u32 data;
 	__u32 data_end;
+	__u32 data_meta;
 };
 
 enum sk_action {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index b914fbe..f849eca 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -177,6 +177,12 @@ static __printf(1, 2) void verbose(const char *fmt, ...)
 	va_end(args);
 }
 
+static bool type_is_pkt_pointer(enum bpf_reg_type type)
+{
+	return type == PTR_TO_PACKET ||
+	       type == PTR_TO_PACKET_META;
+}
+
 /* string representation of 'enum bpf_reg_type' */
 static const char * const reg_type_str[] = {
 	[NOT_INIT]		= "?",
@@ -187,6 +193,7 @@ static __printf(1, 2) void verbose(const char *fmt, ...)
 	[PTR_TO_MAP_VALUE_OR_NULL] = "map_value_or_null",
 	[PTR_TO_STACK]		= "fp",
 	[PTR_TO_PACKET]		= "pkt",
+	[PTR_TO_PACKET_META]	= "pkt_meta",
 	[PTR_TO_PACKET_END]	= "pkt_end",
 };
 
@@ -226,7 +233,7 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 			verbose("(id=%d", reg->id);
 			if (t != SCALAR_VALUE)
 				verbose(",off=%d", reg->off);
-			if (t == PTR_TO_PACKET)
+			if (type_is_pkt_pointer(t))
 				verbose(",r=%d", reg->range);
 			else if (t == CONST_PTR_TO_MAP ||
 				 t == PTR_TO_MAP_VALUE ||
@@ -519,6 +526,31 @@ static void mark_reg_known_zero(struct bpf_reg_state *regs, u32 regno)
 	__mark_reg_known_zero(regs + regno);
 }
 
+static bool reg_is_pkt_pointer(const struct bpf_reg_state *reg)
+{
+	return type_is_pkt_pointer(reg->type);
+}
+
+static bool reg_is_pkt_pointer_any(const struct bpf_reg_state *reg)
+{
+	return reg_is_pkt_pointer(reg) ||
+	       reg->type == PTR_TO_PACKET_END;
+}
+
+/* Unmodified PTR_TO_PACKET[_META,_END] register from ctx access. */
+static bool reg_is_init_pkt_pointer(const struct bpf_reg_state *reg,
+				    enum bpf_reg_type which)
+{
+	/* The register can already have a range from prior markings.
+	 * This is fine as long as it hasn't been advanced from its
+	 * origin.
+	 */
+	return reg->type == which &&
+	       reg->id == 0 &&
+	       reg->off == 0 &&
+	       tnum_equals_const(reg->var_off, 0);
+}
+
 /* Attempts to improve min/max values based on var_off information */
 static void __update_reg_bounds(struct bpf_reg_state *reg)
 {
@@ -702,6 +734,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case PTR_TO_STACK:
 	case PTR_TO_CTX:
 	case PTR_TO_PACKET:
+	case PTR_TO_PACKET_META:
 	case PTR_TO_PACKET_END:
 	case CONST_PTR_TO_MAP:
 		return true;
@@ -1047,7 +1080,10 @@ static int check_ptr_alignment(struct bpf_verifier_env *env,
 
 	switch (reg->type) {
 	case PTR_TO_PACKET:
-		/* special case, because of NET_IP_ALIGN */
+	case PTR_TO_PACKET_META:
+		/* Special case, because of NET_IP_ALIGN. Given metadata sits
+		 * right in front, treat it the very same way.
+		 */
 		return check_pkt_ptr_alignment(reg, off, size, strict);
 	case PTR_TO_MAP_VALUE:
 		pointer_desc = "value ";
@@ -1124,8 +1160,8 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 		err = check_ctx_access(env, insn_idx, off, size, t, &reg_type);
 		if (!err && t == BPF_READ && value_regno >= 0) {
 			/* ctx access returns either a scalar, or a
-			 * PTR_TO_PACKET[_END].  In the latter case, we know
-			 * the offset is zero.
+			 * PTR_TO_PACKET[_META,_END]. In the latter
+			 * case, we know the offset is zero.
 			 */
 			if (reg_type == SCALAR_VALUE)
 				mark_reg_unknown(state->regs, value_regno);
@@ -1170,7 +1206,7 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 		} else {
 			err = check_stack_read(state, off, size, value_regno);
 		}
-	} else if (reg->type == PTR_TO_PACKET) {
+	} else if (reg_is_pkt_pointer(reg)) {
 		if (t == BPF_WRITE && !may_access_direct_pkt_data(env, NULL, t)) {
 			verbose("cannot write into packet\n");
 			return -EACCES;
@@ -1310,6 +1346,7 @@ static int check_helper_mem_access(struct bpf_verifier_env *env, int regno,
 
 	switch (reg->type) {
 	case PTR_TO_PACKET:
+	case PTR_TO_PACKET_META:
 		return check_packet_access(env, regno, reg->off, access_size);
 	case PTR_TO_MAP_VALUE:
 		return check_map_access(env, regno, reg->off, access_size);
@@ -1342,7 +1379,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		return 0;
 	}
 
-	if (type == PTR_TO_PACKET &&
+	if (type_is_pkt_pointer(type) &&
 	    !may_access_direct_pkt_data(env, meta, BPF_READ)) {
 		verbose("helper access to the packet is not allowed\n");
 		return -EACCES;
@@ -1351,7 +1388,8 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 	if (arg_type == ARG_PTR_TO_MAP_KEY ||
 	    arg_type == ARG_PTR_TO_MAP_VALUE) {
 		expected_type = PTR_TO_STACK;
-		if (type != PTR_TO_PACKET && type != expected_type)
+		if (!type_is_pkt_pointer(type) &&
+		    type != expected_type)
 			goto err_type;
 	} else if (arg_type == ARG_CONST_SIZE ||
 		   arg_type == ARG_CONST_SIZE_OR_ZERO) {
@@ -1375,7 +1413,8 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		 */
 		if (register_is_null(*reg))
 			/* final test in check_stack_boundary() */;
-		else if (type != PTR_TO_PACKET && type != PTR_TO_MAP_VALUE &&
+		else if (!type_is_pkt_pointer(type) &&
+			 type != PTR_TO_MAP_VALUE &&
 			 type != expected_type)
 			goto err_type;
 		meta->raw_mode = arg_type == ARG_PTR_TO_UNINIT_MEM;
@@ -1401,7 +1440,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			verbose("invalid map_ptr to access map->key\n");
 			return -EACCES;
 		}
-		if (type == PTR_TO_PACKET)
+		if (type_is_pkt_pointer(type))
 			err = check_packet_access(env, regno, reg->off,
 						  meta->map_ptr->key_size);
 		else
@@ -1417,7 +1456,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			verbose("invalid map_ptr to access map->value\n");
 			return -EACCES;
 		}
-		if (type == PTR_TO_PACKET)
+		if (type_is_pkt_pointer(type))
 			err = check_packet_access(env, regno, reg->off,
 						  meta->map_ptr->value_size);
 		else
@@ -1590,8 +1629,8 @@ static int check_raw_mode(const struct bpf_func_proto *fn)
 	return count > 1 ? -EINVAL : 0;
 }
 
-/* Packet data might have moved, any old PTR_TO_PACKET[_END] are now invalid,
- * so turn them into unknown SCALAR_VALUE.
+/* Packet data might have moved, any old PTR_TO_PACKET[_META,_END]
+ * are now invalid, so turn them into unknown SCALAR_VALUE.
  */
 static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 {
@@ -1600,18 +1639,15 @@ static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 	int i;
 
 	for (i = 0; i < MAX_BPF_REG; i++)
-		if (regs[i].type == PTR_TO_PACKET ||
-		    regs[i].type == PTR_TO_PACKET_END)
+		if (reg_is_pkt_pointer_any(&regs[i]))
 			mark_reg_unknown(regs, i);
 
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] != STACK_SPILL)
 			continue;
 		reg = &state->spilled_regs[i / BPF_REG_SIZE];
-		if (reg->type != PTR_TO_PACKET &&
-		    reg->type != PTR_TO_PACKET_END)
-			continue;
-		__mark_reg_unknown(reg);
+		if (reg_is_pkt_pointer_any(reg))
+			__mark_reg_unknown(reg);
 	}
 }
 
@@ -1871,7 +1907,7 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 		}
 		dst_reg->var_off = tnum_add(ptr_reg->var_off, off_reg->var_off);
 		dst_reg->off = ptr_reg->off;
-		if (ptr_reg->type == PTR_TO_PACKET) {
+		if (reg_is_pkt_pointer(ptr_reg)) {
 			dst_reg->id = ++env->id_gen;
 			/* something was added to pkt_ptr, set range to zero */
 			dst_reg->range = 0;
@@ -1931,7 +1967,7 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 		}
 		dst_reg->var_off = tnum_sub(ptr_reg->var_off, off_reg->var_off);
 		dst_reg->off = ptr_reg->off;
-		if (ptr_reg->type == PTR_TO_PACKET) {
+		if (reg_is_pkt_pointer(ptr_reg)) {
 			dst_reg->id = ++env->id_gen;
 			/* something was added to pkt_ptr, set range to zero */
 			if (smin_val < 0)
@@ -2421,7 +2457,8 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 }
 
 static void find_good_pkt_pointers(struct bpf_verifier_state *state,
-				   struct bpf_reg_state *dst_reg)
+				   struct bpf_reg_state *dst_reg,
+				   enum bpf_reg_type type)
 {
 	struct bpf_reg_state *regs = state->regs, *reg;
 	int i;
@@ -2483,7 +2520,7 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 	 * dst_reg->off is known < MAX_PACKET_OFF, therefore it fits in a u16.
 	 */
 	for (i = 0; i < MAX_BPF_REG; i++)
-		if (regs[i].type == PTR_TO_PACKET && regs[i].id == dst_reg->id)
+		if (regs[i].type == type && regs[i].id == dst_reg->id)
 			/* keep the maximum range already checked */
 			regs[i].range = max_t(u16, regs[i].range, dst_reg->off);
 
@@ -2491,7 +2528,7 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 		if (state->stack_slot_type[i] != STACK_SPILL)
 			continue;
 		reg = &state->spilled_regs[i / BPF_REG_SIZE];
-		if (reg->type == PTR_TO_PACKET && reg->id == dst_reg->id)
+		if (reg->type == type && reg->id == dst_reg->id)
 			reg->range = max_t(u16, reg->range, dst_reg->off);
 	}
 }
@@ -2856,19 +2893,39 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
 		   dst_reg->type == PTR_TO_PACKET &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
-		find_good_pkt_pointers(this_branch, dst_reg);
+		find_good_pkt_pointers(this_branch, dst_reg, PTR_TO_PACKET);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLT &&
 		   dst_reg->type == PTR_TO_PACKET &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
-		find_good_pkt_pointers(other_branch, dst_reg);
+		find_good_pkt_pointers(other_branch, dst_reg, PTR_TO_PACKET);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGE &&
 		   dst_reg->type == PTR_TO_PACKET_END &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET) {
-		find_good_pkt_pointers(other_branch, &regs[insn->src_reg]);
+		find_good_pkt_pointers(other_branch, &regs[insn->src_reg],
+				       PTR_TO_PACKET);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLE &&
 		   dst_reg->type == PTR_TO_PACKET_END &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET) {
-		find_good_pkt_pointers(this_branch, &regs[insn->src_reg]);
+		find_good_pkt_pointers(this_branch, &regs[insn->src_reg],
+				       PTR_TO_PACKET);
+	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
+		   dst_reg->type == PTR_TO_PACKET_META &&
+		   reg_is_init_pkt_pointer(&regs[insn->src_reg], PTR_TO_PACKET)) {
+		find_good_pkt_pointers(this_branch, dst_reg, PTR_TO_PACKET_META);
+	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLT &&
+		   dst_reg->type == PTR_TO_PACKET_META &&
+		   reg_is_init_pkt_pointer(&regs[insn->src_reg], PTR_TO_PACKET)) {
+		find_good_pkt_pointers(other_branch, dst_reg, PTR_TO_PACKET_META);
+	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGE &&
+		   reg_is_init_pkt_pointer(dst_reg, PTR_TO_PACKET) &&
+		   regs[insn->src_reg].type == PTR_TO_PACKET_META) {
+		find_good_pkt_pointers(other_branch, &regs[insn->src_reg],
+				       PTR_TO_PACKET_META);
+	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLE &&
+		   reg_is_init_pkt_pointer(dst_reg, PTR_TO_PACKET) &&
+		   regs[insn->src_reg].type == PTR_TO_PACKET_META) {
+		find_good_pkt_pointers(this_branch, &regs[insn->src_reg],
+				       PTR_TO_PACKET_META);
 	} else if (is_pointer_value(env, insn->dst_reg)) {
 		verbose("R%d pointer comparison prohibited\n", insn->dst_reg);
 		return -EACCES;
@@ -3298,8 +3355,9 @@ static bool regsafe(struct bpf_reg_state *rold, struct bpf_reg_state *rcur,
 			return false;
 		/* Check our ids match any regs they're supposed to */
 		return check_ids(rold->id, rcur->id, idmap);
+	case PTR_TO_PACKET_META:
 	case PTR_TO_PACKET:
-		if (rcur->type != PTR_TO_PACKET)
+		if (rcur->type != rold->type)
 			return false;
 		/* We must have at least as much range as the old ptr
 		 * did, so that any accesses which were safe before are
diff --git a/net/bpf/test_run.c b/net/bpf/test_run.c
index df67251..a86e668 100644
--- a/net/bpf/test_run.c
+++ b/net/bpf/test_run.c
@@ -162,6 +162,7 @@ int bpf_prog_test_run_xdp(struct bpf_prog *prog, const union bpf_attr *kattr,
 
 	xdp.data_hard_start = data;
 	xdp.data = data + XDP_PACKET_HEADROOM + NET_IP_ALIGN;
+	xdp.data_meta = xdp.data;
 	xdp.data_end = xdp.data + size;
 
 	retval = bpf_test_run(prog, &xdp, repeat, &duration);
diff --git a/net/core/dev.c b/net/core/dev.c
index 97abddd..e350c76 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3864,8 +3864,8 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 				     struct bpf_prog *xdp_prog)
 {
+	u32 metalen, act = XDP_DROP;
 	struct xdp_buff xdp;
-	u32 act = XDP_DROP;
 	void *orig_data;
 	int hlen, off;
 	u32 mac_len;
@@ -3876,8 +3876,25 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 	if (skb_cloned(skb))
 		return XDP_PASS;
 
-	if (skb_linearize(skb))
-		goto do_drop;
+	/* XDP packets must be linear and must have sufficient headroom
+	 * of XDP_PACKET_HEADROOM bytes. This is the guarantee that also
+	 * native XDP provides, thus we need to do it here as well.
+	 */
+	if (skb_is_nonlinear(skb) ||
+	    skb_headroom(skb) < XDP_PACKET_HEADROOM) {
+		int hroom = XDP_PACKET_HEADROOM - skb_headroom(skb);
+		int troom = skb->tail + skb->data_len - skb->end;
+
+		/* In case we have to go down the path and also linearize,
+		 * then lets do the pskb_expand_head() work just once here.
+		 */
+		if (pskb_expand_head(skb,
+				     hroom > 0 ? ALIGN(hroom, NET_SKB_PAD) : 0,
+				     troom > 0 ? troom + 128 : 0, GFP_ATOMIC))
+			goto do_drop;
+		if (troom > 0 && __skb_linearize(skb))
+			goto do_drop;
+	}
 
 	/* The XDP program wants to see the packet starting at the MAC
 	 * header.
@@ -3885,6 +3902,7 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 	mac_len = skb->data - skb_mac_header(skb);
 	hlen = skb_headlen(skb) + mac_len;
 	xdp.data = skb->data - mac_len;
+	xdp.data_meta = xdp.data;
 	xdp.data_end = xdp.data + hlen;
 	xdp.data_hard_start = skb->data - skb_headroom(skb);
 	orig_data = xdp.data;
@@ -3902,10 +3920,12 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 	case XDP_REDIRECT:
 	case XDP_TX:
 		__skb_push(skb, mac_len);
-		/* fall through */
+		break;
 	case XDP_PASS:
+		metalen = xdp.data - xdp.data_meta;
+		if (metalen)
+			skb_metadata_set(skb, metalen);
 		break;
-
 	default:
 		bpf_warn_invalid_xdp_action(act);
 		/* fall through */
@@ -4695,6 +4715,7 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
 		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
 		diffs |= p->vlan_tci ^ skb->vlan_tci;
 		diffs |= skb_metadata_dst_cmp(p, skb);
+		diffs |= skb_metadata_differs(p, skb);
 		if (maclen == ETH_HLEN)
 			diffs |= compare_ether_header(skb_mac_header(p),
 						      skb_mac_header(skb));
diff --git a/net/core/filter.c b/net/core/filter.c
index c468e7c..9b6e7e8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2447,14 +2447,26 @@ static int bpf_skb_trim_rcsum(struct sk_buff *skb, unsigned int new_len)
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static unsigned long xdp_get_metalen(const struct xdp_buff *xdp)
+{
+	return xdp_data_meta_unsupported(xdp) ? 0 :
+	       xdp->data - xdp->data_meta;
+}
+
 BPF_CALL_2(bpf_xdp_adjust_head, struct xdp_buff *, xdp, int, offset)
 {
+	unsigned long metalen = xdp_get_metalen(xdp);
+	void *data_start = xdp->data_hard_start + metalen;
 	void *data = xdp->data + offset;
 
-	if (unlikely(data < xdp->data_hard_start ||
+	if (unlikely(data < data_start ||
 		     data > xdp->data_end - ETH_HLEN))
 		return -EINVAL;
 
+	if (metalen)
+		memmove(xdp->data_meta + offset,
+			xdp->data_meta, metalen);
+	xdp->data_meta += offset;
 	xdp->data = data;
 
 	return 0;
@@ -2468,6 +2480,33 @@ static int bpf_skb_trim_rcsum(struct sk_buff *skb, unsigned int new_len)
 	.arg2_type	= ARG_ANYTHING,
 };
 
+BPF_CALL_2(bpf_xdp_adjust_meta, struct xdp_buff *, xdp, int, offset)
+{
+	void *meta = xdp->data_meta + offset;
+	unsigned long metalen = xdp->data - meta;
+
+	if (xdp_data_meta_unsupported(xdp))
+		return -ENOTSUPP;
+	if (unlikely(meta < xdp->data_hard_start ||
+		     meta > xdp->data))
+		return -EINVAL;
+	if (unlikely((metalen & (sizeof(__u32) - 1)) ||
+		     (metalen > 32)))
+		return -EACCES;
+
+	xdp->data_meta = meta;
+
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_xdp_adjust_meta_proto = {
+	.func		= bpf_xdp_adjust_meta,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+};
+
 static int __bpf_tx_xdp(struct net_device *dev,
 			struct bpf_map *map,
 			struct xdp_buff *xdp,
@@ -2692,7 +2731,8 @@ bool bpf_helper_changes_pkt_data(void *func)
 	    func == bpf_clone_redirect ||
 	    func == bpf_l3_csum_replace ||
 	    func == bpf_l4_csum_replace ||
-	    func == bpf_xdp_adjust_head)
+	    func == bpf_xdp_adjust_head ||
+	    func == bpf_xdp_adjust_meta)
 		return true;
 
 	return false;
@@ -3288,6 +3328,8 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_xdp_adjust_head:
 		return &bpf_xdp_adjust_head_proto;
+	case BPF_FUNC_xdp_adjust_meta:
+		return &bpf_xdp_adjust_meta_proto;
 	case BPF_FUNC_redirect:
 		return &bpf_xdp_redirect_proto;
 	case BPF_FUNC_redirect_map:
@@ -3418,6 +3460,7 @@ static bool bpf_skb_is_valid_access(int off, int size, enum bpf_access_type type
 	case bpf_ctx_range_till(struct __sk_buff, remote_ip4, remote_ip4):
 	case bpf_ctx_range_till(struct __sk_buff, local_ip4, local_ip4):
 	case bpf_ctx_range(struct __sk_buff, data):
+	case bpf_ctx_range(struct __sk_buff, data_meta):
 	case bpf_ctx_range(struct __sk_buff, data_end):
 		if (size != size_default)
 			return false;
@@ -3444,6 +3487,7 @@ static bool sk_filter_is_valid_access(int off, int size,
 	switch (off) {
 	case bpf_ctx_range(struct __sk_buff, tc_classid):
 	case bpf_ctx_range(struct __sk_buff, data):
+	case bpf_ctx_range(struct __sk_buff, data_meta):
 	case bpf_ctx_range(struct __sk_buff, data_end):
 	case bpf_ctx_range_till(struct __sk_buff, family, local_port):
 		return false;
@@ -3468,6 +3512,7 @@ static bool lwt_is_valid_access(int off, int size,
 	switch (off) {
 	case bpf_ctx_range(struct __sk_buff, tc_classid):
 	case bpf_ctx_range_till(struct __sk_buff, family, local_port):
+	case bpf_ctx_range(struct __sk_buff, data_meta):
 		return false;
 	}
 
@@ -3586,6 +3631,9 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 	case bpf_ctx_range(struct __sk_buff, data):
 		info->reg_type = PTR_TO_PACKET;
 		break;
+	case bpf_ctx_range(struct __sk_buff, data_meta):
+		info->reg_type = PTR_TO_PACKET_META;
+		break;
 	case bpf_ctx_range(struct __sk_buff, data_end):
 		info->reg_type = PTR_TO_PACKET_END;
 		break;
@@ -3619,6 +3667,9 @@ static bool xdp_is_valid_access(int off, int size,
 	case offsetof(struct xdp_md, data):
 		info->reg_type = PTR_TO_PACKET;
 		break;
+	case offsetof(struct xdp_md, data_meta):
+		info->reg_type = PTR_TO_PACKET_META;
+		break;
 	case offsetof(struct xdp_md, data_end):
 		info->reg_type = PTR_TO_PACKET_END;
 		break;
@@ -3677,6 +3728,12 @@ static bool sk_skb_is_valid_access(int off, int size,
 				   enum bpf_access_type type,
 				   struct bpf_insn_access_aux *info)
 {
+	switch (off) {
+	case bpf_ctx_range(struct __sk_buff, tc_classid):
+	case bpf_ctx_range(struct __sk_buff, data_meta):
+		return false;
+	}
+
 	if (type == BPF_WRITE) {
 		switch (off) {
 		case bpf_ctx_range(struct __sk_buff, mark):
@@ -3689,8 +3746,6 @@ static bool sk_skb_is_valid_access(int off, int size,
 	}
 
 	switch (off) {
-	case bpf_ctx_range(struct __sk_buff, tc_classid):
-		return false;
 	case bpf_ctx_range(struct __sk_buff, data):
 		info->reg_type = PTR_TO_PACKET;
 		break;
@@ -3847,6 +3902,15 @@ static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 				      offsetof(struct sk_buff, data));
 		break;
 
+	case offsetof(struct __sk_buff, data_meta):
+		off  = si->off;
+		off -= offsetof(struct __sk_buff, data_meta);
+		off += offsetof(struct sk_buff, cb);
+		off += offsetof(struct bpf_skb_data_end, data_meta);
+		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(void *), si->dst_reg,
+				      si->src_reg, off);
+		break;
+
 	case offsetof(struct __sk_buff, data_end):
 		off  = si->off;
 		off -= offsetof(struct __sk_buff, data_end);
@@ -4095,6 +4159,11 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
 				      si->dst_reg, si->src_reg,
 				      offsetof(struct xdp_buff, data));
 		break;
+	case offsetof(struct xdp_md, data_meta):
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct xdp_buff, data_meta),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct xdp_buff, data_meta));
+		break;
 	case offsetof(struct xdp_md, data_end):
 		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct xdp_buff, data_end),
 				      si->dst_reg, si->src_reg,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 16982de..681177b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1509,6 +1509,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
 
+	skb_metadata_clear(skb);
+
 	/* It is not generally safe to change skb->truesize.
 	 * For the moment, we really care of rx path, or
 	 * when skb is orphaned (not attached to a socket).
-- 
1.9.3
