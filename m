From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/4] bpf: add bpf_skb_change_tail helper
Date: Thu, 18 Aug 2016 01:00:39 +0200
Message-ID: <ac44efffc4b60106a0931036d28a2ebe19a4db6a.1471473110.git.daniel@iogearbox.net>
References: <cover.1471473110.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34688 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbcHQXCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:02:00 -0400
In-Reply-To: <cover.1471473110.git.daniel@iogearbox.net>
In-Reply-To: <cover.1471473110.git.daniel@iogearbox.net>
References: <cover.1471473110.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work adds a bpf_skb_change_tail() helper for tc BPF programs. The
basic idea is to expand or shrink the skb in a controlled manner. The
eBPF program can then rewrite the rest via helpers like bpf_skb_store_bytes(),
bpf_lX_csum_replace() and others rather than passing a raw buffer for
writing here.

bpf_skb_change_tail() is really a slow path helper and intended for
replies with f.e. ICMP control messages. Concept is similar to other
helpers like bpf_skb_change_proto() helper to keep the helper without
protocol specifics and let the BPF program mangle the remaining parts.
A flags field has been added and is reserved for now should we extend
the helper in future.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/skbuff.h   |  43 +++++++++++++++++++-
 include/uapi/linux/bpf.h |  11 ++++++
 net/core/filter.c        | 100 +++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 150 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0f665cb..7047448 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2295,7 +2295,7 @@ static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
 
 int ___pskb_trim(struct sk_buff *skb, unsigned int len);
 
-static inline void __skb_trim(struct sk_buff *skb, unsigned int len)
+static inline void __skb_set_length(struct sk_buff *skb, unsigned int len)
 {
 	if (unlikely(skb_is_nonlinear(skb))) {
 		WARN_ON(1);
@@ -2305,6 +2305,11 @@ static inline void __skb_trim(struct sk_buff *skb, unsigned int len)
 	skb_set_tail_pointer(skb, len);
 }
 
+static inline void __skb_trim(struct sk_buff *skb, unsigned int len)
+{
+	__skb_set_length(skb, len);
+}
+
 void skb_trim(struct sk_buff *skb, unsigned int len);
 
 static inline int __pskb_trim(struct sk_buff *skb, unsigned int len)
@@ -2335,6 +2340,20 @@ static inline void pskb_trim_unique(struct sk_buff *skb, unsigned int len)
 	BUG_ON(err);
 }
 
+static inline int __skb_grow(struct sk_buff *skb, unsigned int len)
+{
+	unsigned int diff = len - skb->len;
+
+	if (skb_tailroom(skb) < diff) {
+		int ret = pskb_expand_head(skb, 0, diff - skb_tailroom(skb),
+					   GFP_ATOMIC);
+		if (ret)
+			return ret;
+	}
+	__skb_set_length(skb, len);
+	return 0;
+}
+
 /**
  *	skb_orphan - orphan a buffer
  *	@skb: buffer to orphan
@@ -2938,6 +2957,21 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
 	return __pskb_trim(skb, len);
 }
 
+static inline int __skb_trim_rcsum(struct sk_buff *skb, unsigned int len)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->ip_summed = CHECKSUM_NONE;
+	__skb_trim(skb, len);
+	return 0;
+}
+
+static inline int __skb_grow_rcsum(struct sk_buff *skb, unsigned int len)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->ip_summed = CHECKSUM_NONE;
+	return __skb_grow(skb, len);
+}
+
 #define skb_queue_walk(queue, skb) \
 		for (skb = (queue)->next;					\
 		     skb != (struct sk_buff *)(queue);				\
@@ -3726,6 +3760,13 @@ static inline bool skb_is_gso_v6(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
 }
 
+static inline void skb_gso_reset(struct sk_buff *skb)
+{
+	skb_shinfo(skb)->gso_size = 0;
+	skb_shinfo(skb)->gso_segs = 0;
+	skb_shinfo(skb)->gso_type = 0;
+}
+
 void __skb_warn_lro_forwarding(const struct sk_buff *skb);
 
 static inline bool skb_warn_if_lro(const struct sk_buff *skb)
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 866d53c..e4c5a1b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -386,6 +386,17 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_current_task_under_cgroup,
 
+	/**
+	 * bpf_skb_change_tail(skb, len, flags)
+	 * The helper will resize the skb to the given new size,
+	 * to be used f.e. with control messages.
+	 * @skb: pointer to skb
+	 * @len: new skb length
+	 * @flags: reserved
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_skb_change_tail,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 58b5e6d..abf546d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1350,14 +1350,18 @@ struct bpf_scratchpad {
 
 static DEFINE_PER_CPU(struct bpf_scratchpad, bpf_sp);
 
+static inline int __bpf_try_make_writable(struct sk_buff *skb,
+					  unsigned int write_len)
+{
+	return skb_ensure_writable(skb, write_len);
+}
+
 static inline int bpf_try_make_writable(struct sk_buff *skb,
 					unsigned int write_len)
 {
-	int err;
+	int err = __bpf_try_make_writable(skb, write_len);
 
-	err = skb_ensure_writable(skb, write_len);
 	bpf_compute_data_end(skb);
-
 	return err;
 }
 
@@ -1992,6 +1996,92 @@ static const struct bpf_func_proto bpf_skb_change_type_proto = {
 	.arg2_type	= ARG_ANYTHING,
 };
 
+static u32 __bpf_skb_min_len(const struct sk_buff *skb)
+{
+	u32 min_len = skb_network_offset(skb);
+
+	if (skb_transport_header_was_set(skb))
+		min_len = skb_transport_offset(skb);
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		min_len = skb_checksum_start_offset(skb) +
+			  skb->csum_offset + sizeof(__sum16);
+	return min_len;
+}
+
+static u32 __bpf_skb_max_len(const struct sk_buff *skb)
+{
+	return skb->dev ? skb->dev->mtu + skb->dev->hard_header_len :
+	       65536;
+}
+
+static int bpf_skb_grow_rcsum(struct sk_buff *skb, unsigned int new_len)
+{
+	unsigned int old_len = skb->len;
+	int ret;
+
+	ret = __skb_grow_rcsum(skb, new_len);
+	if (!ret)
+		memset(skb->data + old_len, 0, new_len - old_len);
+	return ret;
+}
+
+static int bpf_skb_trim_rcsum(struct sk_buff *skb, unsigned int new_len)
+{
+	return __skb_trim_rcsum(skb, new_len);
+}
+
+static u64 bpf_skb_change_tail(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *)(long) r1;
+	u32 max_len = __bpf_skb_max_len(skb);
+	u32 min_len = __bpf_skb_min_len(skb);
+	u32 new_len = (u32) r2;
+	int ret;
+
+	if (unlikely(flags || new_len > max_len || new_len < min_len))
+		return -EINVAL;
+	if (skb->encapsulation)
+		return -ENOTSUPP;
+
+	/* The basic idea of this helper is that it's performing the
+	 * needed work to either grow or trim an skb, and eBPF program
+	 * rewrites the rest via helpers like bpf_skb_store_bytes(),
+	 * bpf_lX_csum_replace() and others rather than passing a raw
+	 * buffer here. This one is a slow path helper and intended
+	 * for replies with control messages.
+	 *
+	 * Like in bpf_skb_change_proto(), we want to keep this rather
+	 * minimal and without protocol specifics so that we are able
+	 * to separate concerns as in bpf_skb_store_bytes() should only
+	 * be the one responsible for writing buffers.
+	 *
+	 * It's really expected to be a slow path operation here for
+	 * control message replies, so we're implicitly linearizing,
+	 * uncloning and drop offloads from the skb by this.
+	 */
+	ret = __bpf_try_make_writable(skb, skb->len);
+	if (!ret) {
+		if (new_len > skb->len)
+			ret = bpf_skb_grow_rcsum(skb, new_len);
+		else if (new_len < skb->len)
+			ret = bpf_skb_trim_rcsum(skb, new_len);
+		if (!ret && skb_is_gso(skb))
+			skb_gso_reset(skb);
+	}
+
+	bpf_compute_data_end(skb);
+	return ret;
+}
+
+static const struct bpf_func_proto bpf_skb_change_tail_proto = {
+	.func		= bpf_skb_change_tail,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 bool bpf_helper_changes_skb_data(void *func)
 {
 	if (func == bpf_skb_vlan_push)
@@ -2002,6 +2092,8 @@ bool bpf_helper_changes_skb_data(void *func)
 		return true;
 	if (func == bpf_skb_change_proto)
 		return true;
+	if (func == bpf_skb_change_tail)
+		return true;
 	if (func == bpf_l3_csum_replace)
 		return true;
 	if (func == bpf_l4_csum_replace)
@@ -2368,6 +2460,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_change_proto_proto;
 	case BPF_FUNC_skb_change_type:
 		return &bpf_skb_change_type_proto;
+	case BPF_FUNC_skb_change_tail:
+		return &bpf_skb_change_tail_proto;
 	case BPF_FUNC_skb_get_tunnel_key:
 		return &bpf_skb_get_tunnel_key_proto;
 	case BPF_FUNC_skb_set_tunnel_key:
-- 
1.9.3
