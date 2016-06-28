From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/6] bpf: add bpf_skb_change_proto helper
Date: Tue, 28 Jun 2016 12:18:27 +0200
Message-ID: <3c349a51ac5324620811e80bb7aed7de60d45341.1467106475.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54352 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbcF1Kr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 06:47:58 -0400
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a minimal helper for doing the groundwork of changing
the skb->protocol in a controlled way. Currently supported is v4 to
v6 and vice versa transitions, which allows f.e. for a minimal, static
nat64 implementation where applications in containers that still
require IPv4 can be transparently operated in an IPv6-only environment.
For example, host facing veth of the container can transparently do
the transitions in a programmatic way with the help of clsact qdisc
and cls_bpf.

Idea is to separate concerns for keeping complexity of the helper
lower, which means that the programs utilize bpf_skb_change_proto(),
bpf_skb_store_bytes() and bpf_lX_csum_replace() to get the job done,
instead of doing everything in a single helper (and thus partially
duplicating helper functionality). Also, bpf_skb_change_proto()
shouldn't need to deal with raw packet data as this is done by other
helpers.

bpf_skb_proto_6_to_4() and bpf_skb_proto_4_to_6() unclone the skb to
operate on a private one, push or pop additionally required header
space and migrate the gso/gro meta data from the shared info. We do
mark the gso type as dodgy so that headers are checked and segs
recalculated by the gso/gro engine. The gso_size target is adapted
as well. The flags argument added is currently reserved and can be
used for future extensions.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  14 ++++
 net/core/filter.c        | 200 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 214 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 58df2da..66cd738 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -313,6 +313,20 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_skb_get_tunnel_opt,
 	BPF_FUNC_skb_set_tunnel_opt,
+
+	/**
+	 * bpf_skb_change_proto(skb, proto, flags)
+	 * Change protocol of the skb. Currently supported is
+	 * v4 -> v6, v6 -> v4 transitions. The helper will also
+	 * resize the skb. eBPF program is expected to fill the
+	 * new headers via skb_store_bytes and lX_csum_replace.
+	 * @skb: pointer to skb
+	 * @proto: new skb->protocol type
+	 * @flags: reserved
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_skb_change_proto,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 46c88d9..d983e76 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1783,6 +1783,202 @@ const struct bpf_func_proto bpf_skb_vlan_pop_proto = {
 };
 EXPORT_SYMBOL_GPL(bpf_skb_vlan_pop_proto);
 
+static int bpf_skb_generic_push(struct sk_buff *skb, u32 off, u32 len)
+{
+	/* Caller already did skb_cow() with len as headroom,
+	 * so no need to do it here.
+	 */
+	skb_push(skb, len);
+	memmove(skb->data, skb->data + len, off);
+	memset(skb->data + off, 0, len);
+
+	/* No skb_postpush_rcsum(skb, skb->data + off, len)
+	 * needed here as it does not change the skb->csum
+	 * result for checksum complete when summing over
+	 * zeroed blocks.
+	 */
+	return 0;
+}
+
+static int bpf_skb_generic_pop(struct sk_buff *skb, u32 off, u32 len)
+{
+	/* skb_ensure_writable() is not needed here, as we're
+	 * already working on an uncloned skb.
+	 */
+	if (unlikely(!pskb_may_pull(skb, off + len)))
+		return -ENOMEM;
+
+	skb_postpull_rcsum(skb, skb->data + off, len);
+	memmove(skb->data + len, skb->data, off);
+	__skb_pull(skb, len);
+
+	return 0;
+}
+
+static int bpf_skb_net_hdr_push(struct sk_buff *skb, u32 off, u32 len)
+{
+	bool trans_same = skb->transport_header == skb->network_header;
+	int ret;
+
+	/* There's no need for __skb_push()/__skb_pull() pair to
+	 * get to the start of the mac header as we're guaranteed
+	 * to always start from here under eBPF.
+	 */
+	ret = bpf_skb_generic_push(skb, off, len);
+	if (likely(!ret)) {
+		skb->mac_header -= len;
+		skb->network_header -= len;
+		if (trans_same)
+			skb->transport_header = skb->network_header;
+	}
+
+	return ret;
+}
+
+static int bpf_skb_net_hdr_pop(struct sk_buff *skb, u32 off, u32 len)
+{
+	bool trans_same = skb->transport_header == skb->network_header;
+	int ret;
+
+	/* Same here, __skb_push()/__skb_pull() pair not needed. */
+	ret = bpf_skb_generic_pop(skb, off, len);
+	if (likely(!ret)) {
+		skb->mac_header += len;
+		skb->network_header += len;
+		if (trans_same)
+			skb->transport_header = skb->network_header;
+	}
+
+	return ret;
+}
+
+static int bpf_skb_proto_4_to_6(struct sk_buff *skb)
+{
+	const u32 len_diff = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+	u32 off = skb->network_header - skb->mac_header;
+	int ret;
+
+	ret = skb_cow(skb, len_diff);
+	if (unlikely(ret < 0))
+		return ret;
+
+	ret = bpf_skb_net_hdr_push(skb, off, len_diff);
+	if (unlikely(ret < 0))
+		return ret;
+
+	if (skb_is_gso(skb)) {
+		/* SKB_GSO_UDP stays as is. SKB_GSO_TCPV4 needs to
+		 * be changed into SKB_GSO_TCPV6.
+		 */
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
+			skb_shinfo(skb)->gso_type &= ~SKB_GSO_TCPV4;
+			skb_shinfo(skb)->gso_type |=  SKB_GSO_TCPV6;
+		}
+
+		/* Due to IPv6 header, MSS needs to be downgraded. */
+		skb_shinfo(skb)->gso_size -= len_diff;
+		/* Header must be checked, and gso_segs recomputed. */
+		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+		skb_shinfo(skb)->gso_segs = 0;
+	}
+
+	skb->protocol = htons(ETH_P_IPV6);
+	skb_clear_hash(skb);
+
+	return 0;
+}
+
+static int bpf_skb_proto_6_to_4(struct sk_buff *skb)
+{
+	const u32 len_diff = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+	u32 off = skb->network_header - skb->mac_header;
+	int ret;
+
+	ret = skb_unclone(skb, GFP_ATOMIC);
+	if (unlikely(ret < 0))
+		return ret;
+
+	ret = bpf_skb_net_hdr_pop(skb, off, len_diff);
+	if (unlikely(ret < 0))
+		return ret;
+
+	if (skb_is_gso(skb)) {
+		/* SKB_GSO_UDP stays as is. SKB_GSO_TCPV6 needs to
+		 * be changed into SKB_GSO_TCPV4.
+		 */
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
+			skb_shinfo(skb)->gso_type &= ~SKB_GSO_TCPV6;
+			skb_shinfo(skb)->gso_type |=  SKB_GSO_TCPV4;
+		}
+
+		/* Due to IPv4 header, MSS can be upgraded. */
+		skb_shinfo(skb)->gso_size += len_diff;
+		/* Header must be checked, and gso_segs recomputed. */
+		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+		skb_shinfo(skb)->gso_segs = 0;
+	}
+
+	skb->protocol = htons(ETH_P_IP);
+	skb_clear_hash(skb);
+
+	return 0;
+}
+
+static int bpf_skb_proto_xlat(struct sk_buff *skb, __be16 to_proto)
+{
+	__be16 from_proto = skb->protocol;
+
+	if (from_proto == htons(ETH_P_IP) &&
+	      to_proto == htons(ETH_P_IPV6))
+		return bpf_skb_proto_4_to_6(skb);
+
+	if (from_proto == htons(ETH_P_IPV6) &&
+	      to_proto == htons(ETH_P_IP))
+		return bpf_skb_proto_6_to_4(skb);
+
+	return -ENOTSUPP;
+}
+
+static u64 bpf_skb_change_proto(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	__be16 proto = (__force __be16) r2;
+	int ret;
+
+	if (unlikely(flags))
+		return -EINVAL;
+
+	/* General idea is that this helper does the basic groundwork
+	 * needed for changing the protocol, and eBPF program fills the
+	 * rest through bpf_skb_store_bytes(), bpf_lX_csum_replace()
+	 * and other helpers, rather than passing a raw buffer here.
+	 *
+	 * The rationale is to keep this minimal and without a need to
+	 * deal with raw packet data. F.e. even if we would pass buffers
+	 * here, the program still needs to call the bpf_lX_csum_replace()
+	 * helpers anyway. Plus, this way we keep also separation of
+	 * concerns, since f.e. bpf_skb_store_bytes() should only take
+	 * care of stores.
+	 *
+	 * Currently, additional options and extension header space are
+	 * not supported, but flags register is reserved so we can adapt
+	 * that. For offloads, we mark packet as dodgy, so that headers
+	 * need to be verified first.
+	 */
+	ret = bpf_skb_proto_xlat(skb, proto);
+	bpf_compute_data_end(skb);
+	return ret;
+}
+
+static const struct bpf_func_proto bpf_skb_change_proto_proto = {
+	.func		= bpf_skb_change_proto,
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
@@ -1791,6 +1987,8 @@ bool bpf_helper_changes_skb_data(void *func)
 		return true;
 	if (func == bpf_skb_store_bytes)
 		return true;
+	if (func == bpf_skb_change_proto)
+		return true;
 	if (func == bpf_l3_csum_replace)
 		return true;
 	if (func == bpf_l4_csum_replace)
@@ -2078,6 +2276,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_vlan_push_proto;
 	case BPF_FUNC_skb_vlan_pop:
 		return &bpf_skb_vlan_pop_proto;
+	case BPF_FUNC_skb_change_proto:
+		return &bpf_skb_change_proto_proto;
 	case BPF_FUNC_skb_get_tunnel_key:
 		return &bpf_skb_get_tunnel_key_proto;
 	case BPF_FUNC_skb_set_tunnel_key:
-- 
1.9.3
