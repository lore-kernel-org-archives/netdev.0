From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH 4/5] net: new XDP feature for reading HW rxhash
 from drivers
Date: Thu, 18 May 2017 17:41:48 +0200
Message-ID: <149512210827.14733.13997041998775151648.stgit@firesoul>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38006 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933863AbdERPlw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 11:41:52 -0400
In-Reply-To: <149512205297.14733.15729847433404265933.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introducing a new XDP feature and associated bpf helper bpf_xdp_rxhash.

The rxhash and type allow filtering on packets without touching
packet memory.  The performance difference on my system with a
100 Gbit/s mlx5 NIC is 12Mpps to 19Mpps.

TODO: desc RXHASH and associated type, and how XDP choose to map
and export these to bpf_prog's.

TODO: desc how this interacts with XDP driver features system.
---
 include/linux/filter.h          |   31 ++++++++++++++++-
 include/linux/netdev_features.h |    4 ++
 include/uapi/linux/bpf.h        |   56 +++++++++++++++++++++++++++++-
 kernel/bpf/verifier.c           |    3 ++
 net/core/dev.c                  |   16 ++++++++-
 net/core/filter.c               |   73 +++++++++++++++++++++++++++++++++++++++
 samples/bpf/bpf_helpers.h       |    2 +
 tools/include/uapi/linux/bpf.h  |   10 +++++
 8 files changed, 190 insertions(+), 5 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 9a7786db14fa..33a254ccd47d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -413,7 +413,8 @@ struct bpf_prog {
 				locked:1,	/* Program image locked? */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
-				dst_needed:1;	/* Do we need dst entry? */
+				dst_needed:1,	/* Do we need dst entry? */
+				xdp_rxhash_needed:1;/* Req XDP RXHASH support */
 	kmemcheck_bitfield_end(meta);
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
@@ -444,12 +445,40 @@ struct bpf_skb_data_end {
 	void *data_end;
 };
 
+/* Kernel internal xdp_buff->flags */
+#define XDP_CTX_F_RXHASH_TYPE_MASK	XDP_HASH_TYPE_MASK
+#define XDP_CTX_F_RXHASH_TYPE_BITS	XDP_HASH_TYPE_BITS
+#define XDP_CTX_F_RXHASH_SW		(1ULL <<  XDP_CTX_F_RXHASH_TYPE_BITS)
+#define XDP_CTX_F_RXHASH_HW		(1ULL << (XDP_CTX_F_RXHASH_TYPE_BITS+1))
+
 struct xdp_buff {
 	void *data;
 	void *data_end;
 	void *data_hard_start;
+	u64 flags;
+	u32 rxhash;
 };
 
+/* helper functions for driver setting rxhash */
+static inline void
+xdp_record_hash(struct xdp_buff *xdp, u32 hash, u32 type)
+{
+	xdp->flags |= XDP_CTX_F_RXHASH_HW;
+	xdp->flags |= type & XDP_CTX_F_RXHASH_TYPE_MASK;
+	xdp->rxhash = hash;
+}
+
+static inline void
+xdp_set_skb_hash(struct xdp_buff *xdp, struct sk_buff *skb)
+{
+	if (likely(xdp->flags & (XDP_CTX_F_RXHASH_HW|XDP_CTX_F_RXHASH_SW))) {
+		bool is_sw = !!(xdp->flags | XDP_CTX_F_RXHASH_SW);
+		bool is_l4 = !!(xdp->flags & XDP_HASH_TYPE_L4_MASK);
+
+		__skb_set_hash(skb, xdp->rxhash, is_sw, is_l4);
+	}
+}
+
 /* compute the linear packet data range [data, data_end) which
  * will be accessed by cls_bpf, act_bpf and lwt programs
  */
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index ff81ee231410..4b50e8c606c5 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -219,11 +219,13 @@ enum {
 /* XDP driver flags */
 enum {
 	XDP_DRV_F_ENABLED_BIT,
+	XDP_DRV_F_RXHASH_BIT,
 };
 
 #define __XDP_DRV_F_BIT(bit)	((netdev_features_t)1 << (bit))
 #define __XDP_DRV_F(name)	__XDP_DRV_F_BIT(XDP_DRV_F_##name##_BIT)
 #define XDP_DRV_F_ENABLED	__XDP_DRV_F(ENABLED)
+#define XDP_DRV_F_RXHASH	__XDP_DRV_F(RXHASH)
 
 /* XDP driver MUST support these features, else kernel MUST reject
  * bpf_prog to guarantee safe access to data structures
@@ -233,7 +235,7 @@ enum {
 /* Some XDP features are under development. Based on bpf_prog loading
  * detect if kernel feature can be activated.
  */
-#define XDP_DRV_FEATURES_DEVEL		0
+#define XDP_DRV_FEATURES_DEVEL		XDP_DRV_F_RXHASH
 
 /* Some XDP features are optional, like action return code, as they
  * are handled safely runtime.
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 945a1f5f63c5..1d9d3a46217d 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -482,6 +482,9 @@ union bpf_attr {
  *     Get the owner uid of the socket stored inside sk_buff.
  *     @skb: pointer to skb
  *     Return: uid of the socket owner on success or overflowuid if failed.
+ *
+ * u64 bpf_xdp_rxhash(xdp_md, new_hash, type, flags)
+ *	TODO: MISSING DESC
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -531,7 +534,8 @@ union bpf_attr {
 	FN(xdp_adjust_head),		\
 	FN(probe_read_str),		\
 	FN(get_socket_cookie),		\
-	FN(get_socket_uid),
+	FN(get_socket_uid),		\
+	FN(xdp_rxhash),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -581,6 +585,10 @@ enum bpf_func_id {
 /* BPF_FUNC_perf_event_output for sk_buff input context. */
 #define BPF_F_CTXLEN_MASK		(0xfffffULL << 32)
 
+/* BPF_FUNC_xdp_rxhash flags */
+#define BPF_F_RXHASH_SET		0ULL
+#define BPF_F_RXHASH_GET		(1ULL << 0)
+
 /* user accessible mirror of in-kernel sk_buff.
  * new fields can only be added to the end of this structure
  */
@@ -660,6 +668,52 @@ enum xdp_action {
 struct xdp_md {
 	__u32 data;
 	__u32 data_end;
+	__u32 rxhash;
+	/* (FIXME delete comment)
+	 * Discussion: If choosing to support direct read, then I
+	 * (believe) having a separate 'rxhash_type' is easier and
+	 * faster to implement. (Else I have to do BPF instruction
+	 * hacks to move the type into upper bits of 'rxhash', which I
+	 * couldn't figureout how to do ;-))
+	*/
+	__u32 rxhash_type;
 };
 
+/* XDP rxhash have an associated type, which is related to the RSS
+ * (Receive Side Scaling) standard, but NIC HW have different mapping
+ * and support. Thus, create mapping that is interesting for XDP.  XDP
+ * would primarly want insight into L3 and L4 protocol info.
+ *
+ * TODO: Likely need to get extended with "L3_IPV6_EX" due RSS standard
+ *
+ * The HASH_TYPE will be returned from bpf helper as the top 32-bit of
+ * the 64-bit rxhash (internally type stored in xdp_buff->flags).
+ */
+#define XDP_HASH(x)		((x) & ((1ULL << 32)-1))
+#define XDP_HASH_TYPE(x)	((x) >> 32)
+
+#define XDP_HASH_TYPE_L3_SHIFT	0
+#define XDP_HASH_TYPE_L3_BITS	3
+#define XDP_HASH_TYPE_L3_MASK	((1ULL << XDP_HASH_TYPE_L3_BITS)-1)
+#define XDP_HASH_TYPE_L3(x)	((x) & XDP_HASH_TYPE_L3_MASK)
+enum {
+	XDP_HASH_TYPE_L3_IPV4 = 1,
+	XDP_HASH_TYPE_L3_IPV6,
+};
+
+#define XDP_HASH_TYPE_L4_SHIFT	XDP_HASH_TYPE_L3_BITS
+#define XDP_HASH_TYPE_L4_BITS	5
+#define XDP_HASH_TYPE_L4_MASK						\
+	(((1ULL << XDP_HASH_TYPE_L4_BITS)-1) << XDP_HASH_TYPE_L4_SHIFT)
+#define XDP_HASH_TYPE_L4(x)	((x) & XDP_HASH_TYPE_L4_MASK)
+enum {
+	_XDP_HASH_TYPE_L4_TCP = 1,
+	_XDP_HASH_TYPE_L4_UDP,
+};
+#define XDP_HASH_TYPE_L4_TCP (_XDP_HASH_TYPE_L4_TCP << XDP_HASH_TYPE_L4_SHIFT)
+#define XDP_HASH_TYPE_L4_UDP (_XDP_HASH_TYPE_L4_UDP << XDP_HASH_TYPE_L4_SHIFT)
+
+#define XDP_HASH_TYPE_BITS   (XDP_HASH_TYPE_L3_BITS + XDP_HASH_TYPE_L4_BITS)
+#define XDP_HASH_TYPE_MASK   (XDP_HASH_TYPE_L3_MASK | XDP_HASH_TYPE_L4_MASK)
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 6f8b6ed690be..248bc113ad18 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3346,6 +3346,8 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			prog->dst_needed = 1;
 		if (insn->imm == BPF_FUNC_get_prandom_u32)
 			bpf_user_rnd_init_once();
+		if (insn->imm == BPF_FUNC_xdp_rxhash)
+			prog->xdp_rxhash_needed = 1;
 		if (insn->imm == BPF_FUNC_tail_call) {
 			/* If we tail call into other programs, we
 			 * cannot make any assumptions since they can
@@ -3353,6 +3355,7 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			 * the program array.
 			 */
 			prog->cb_access = 1;
+			prog->xdp_rxhash_needed = 1;
 
 			/* mark bpf_tail_call as different opcode to avoid
 			 * conditional branch in the interpeter for every normal
diff --git a/net/core/dev.c b/net/core/dev.c
index b4af5fbbd9da..28082067ac00 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4318,9 +4318,13 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 	xdp.data_end = xdp.data + hlen;
 	xdp.data_hard_start = skb->data - skb_headroom(skb);
 	orig_data = xdp.data;
+	xdp.flags  = 0;
+	xdp.rxhash = skb->hash;
 
 	act = bpf_prog_run_xdp(xdp_prog, &xdp);
 
+	xdp_set_skb_hash(&xdp, skb);
+
 	off = xdp.data - orig_data;
 	if (off > 0)
 		__skb_pull(skb, off);
@@ -6851,10 +6855,20 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
+netdev_features_t bpf_get_xdp_features(struct bpf_prog *prog)
+{
+	netdev_features_t features = XDP_DRV_FEATURES_REQUIRED;
+
+	if (prog->xdp_rxhash_needed)
+		features |= XDP_DRV_F_RXHASH;
+
+	return features;
+}
+
 bool xdp_features_check(struct net_device *dev, struct bpf_prog *xdp_prog,
 			struct netlink_ext_ack *extack, u32 flags)
 {
-	netdev_features_t req_features = XDP_DRV_FEATURES_REQUIRED;
+	netdev_features_t req_features = bpf_get_xdp_features(xdp_prog);
 	netdev_features_t dev_xdp_features;
 
 	/* Generic XDP naturally support all features */
diff --git a/net/core/filter.c b/net/core/filter.c
index a253a6197e6b..df04ac73f581 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2272,6 +2272,54 @@ static const struct bpf_func_proto bpf_xdp_adjust_head_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
+BPF_CALL_4(bpf_xdp_rxhash, struct xdp_buff *, xdp, u32, new_hash, u32, type,
+	   unsigned int, flags)
+{
+	/* Read+write access to xdp_buff->rxhash is safe, because
+	 * fixup_bpf_calls() detect when helper is used, and drivers
+	 * not implemeting rxhash will not be allowed to load bpf_prog.
+	 */
+
+	/* Set hash and type */
+	if (flags == BPF_F_RXHASH_SET) {
+		xdp->rxhash = new_hash;
+		xdp->flags |= XDP_CTX_F_RXHASH_SW; /* Need for skb "is_sw" */
+		xdp->flags |= type & XDP_CTX_F_RXHASH_TYPE_MASK;
+	}
+
+	/* Get can specify "type" interested in */
+	if ((flags == BPF_F_RXHASH_GET) &&
+	    (type & XDP_CTX_F_RXHASH_TYPE_MASK)) {
+		u32 f_type = (xdp->flags & XDP_CTX_F_RXHASH_TYPE_MASK);
+		bool match = false;
+
+		/* Match on either L3 or L4 type rxhash */
+		if (!((type ^ f_type) & XDP_HASH_TYPE_L3_MASK))
+			match = true;
+		if (!((type ^ f_type) & XDP_HASH_TYPE_L4_MASK))
+			match = true;
+		if (match == false)
+			return 0;
+	}
+
+	/* Drivers only xdp_record_hash if NETIF_F_RXHASH enabled */
+	if (likely(xdp->flags & (XDP_CTX_F_RXHASH_HW|XDP_CTX_F_RXHASH_SW))) {
+		u64 rxhash_type = xdp->flags & XDP_CTX_F_RXHASH_TYPE_MASK;
+
+		return (u64)(xdp->rxhash | (rxhash_type << 32));
+	}
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_xdp_rxhash_proto = {
+	.func           = bpf_xdp_rxhash,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER, // Q: how do I say "u64" ?
+	.arg1_type      = ARG_PTR_TO_CTX,
+	.arg2_type      = ARG_ANYTHING,
+	.arg3_type      = ARG_ANYTHING,
+};
+
 bool bpf_helper_changes_pkt_data(void *func)
 {
 	if (func == bpf_skb_vlan_push ||
@@ -2760,6 +2808,8 @@ xdp_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_xdp_adjust_head:
 		return &bpf_xdp_adjust_head_proto;
+	case BPF_FUNC_xdp_rxhash:
+		return &bpf_xdp_rxhash_proto;
 	default:
 		return bpf_base_func_proto(func_id);
 	}
@@ -3308,6 +3358,29 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
 				      si->dst_reg, si->src_reg,
 				      offsetof(struct xdp_buff, data_end));
 		break;
+	case offsetof(struct xdp_md, rxhash):
+		/* Direct read-access to rxhash is safe, as drivers
+		 * not implementing will not be allowed to load bpf_prog.
+		 *
+		 * Driver gotchas: Even if NETIF_F_RXHASH is disabled
+		 * drivers must init xdp_buff->rxhash, due to this
+		 * direct read.
+		 */
+		prog->xdp_rxhash_needed = 1;
+
+		BUILD_BUG_ON(FIELD_SIZEOF(struct xdp_buff, rxhash) != 4);
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
+				      offsetof(struct xdp_buff, rxhash));
+		break;
+	case offsetof(struct xdp_md, rxhash_type):
+		/* rxhash_type stored in lower 8-bits of xdp_buff->flags */
+		prog->xdp_rxhash_needed = 1;
+
+		BUILD_BUG_ON(XDP_HASH_TYPE_BITS != 8);
+		/* Load first 8 bits (BPF_B) of flags */
+		*insn++ = BPF_LDX_MEM(BPF_B, si->dst_reg, si->src_reg,
+				      offsetof(struct xdp_buff, flags));
+		break;
 	}
 
 	return insn - insn_buf;
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 9a9c95f2c9fb..634a976a02c6 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -59,6 +59,8 @@ static unsigned long long (*bpf_get_prandom_u32)(void) =
 	(void *) BPF_FUNC_get_prandom_u32;
 static int (*bpf_xdp_adjust_head)(void *ctx, int offset) =
 	(void *) BPF_FUNC_xdp_adjust_head;
+static unsigned long long (*bpf_xdp_rxhash)(void *ctx, __u32 new_hash, __u32 type, unsigned int flags) =
+	(void *) BPF_FUNC_xdp_rxhash;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index e553529929f6..a38c544bf6f0 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -483,6 +483,9 @@ union bpf_attr {
  *     @skb: pointer to skb
  *     Return: uid of the socket owner on success or 0 if the socket pointer
  *     inside sk_buff is NULL
+ *
+ * u64 bpf_xdp_rxhash(xdp_md, new_hash, type, flags)
+ *	FIXME: Copy desc from include/uapi/linux/bpf.h
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -532,7 +535,8 @@ union bpf_attr {
 	FN(xdp_adjust_head),		\
 	FN(probe_read_str),		\
 	FN(get_socket_cookie),		\
-	FN(get_socket_uid),
+	FN(get_socket_uid),		\
+	FN(xdp_rxhash),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -661,6 +665,10 @@ enum xdp_action {
 struct xdp_md {
 	__u32 data;
 	__u32 data_end;
+	__u32 rxhash;
+	__u32 rxhash_type;
 };
 
+// FIXME: Sync with include/uapi/linux/bpf.h
+
 #endif /* _UAPI__LINUX_BPF_H__ */
