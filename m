From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] tc: bpf: add checksum helpers
Date: Wed,  1 Apr 2015 17:12:13 -0700
Message-ID: <1427933533-14394-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33924 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904AbbDBAMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 20:12:23 -0400
Received: by pactp5 with SMTP id tp5so66841285pac.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 17:12:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 608cd71a9c7c ("tc: bpf: generalize pedit action") has added the
possibility to mangle packet data to BPF programs in the tc pipeline.
This patch adds two helpers bpf_l3_csum_replace() and bpf_l4_csum_replace()
for fixing up the protocol checksums after the packet mangling.

It also adds 'flags' argument to bpf_skb_store_bytes() helper to avoid
unnecessary checksum recomputations when BPF programs adjusting l3/l4
checksums and documents all three helpers in uapi header.

Moreover, a sample program is added to show how BPF programs can make use
of the mangle and csum helpers.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h  |   38 +++++++++++++++-
 net/core/filter.c         |  108 +++++++++++++++++++++++++++++++++++++++++++--
 samples/bpf/Makefile      |    1 +
 samples/bpf/bpf_helpers.h |    7 +++
 samples/bpf/tcbpf1_kern.c |   71 +++++++++++++++++++++++++++++
 5 files changed, 220 insertions(+), 5 deletions(-)
 create mode 100644 samples/bpf/tcbpf1_kern.c

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 74aab6e0d964..c8e3c29a080e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -168,7 +168,43 @@ enum bpf_func_id {
 	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 	BPF_FUNC_get_prandom_u32, /* u32 prandom_u32(void) */
 	BPF_FUNC_get_smp_processor_id, /* u32 raw_smp_processor_id(void) */
-	BPF_FUNC_skb_store_bytes, /* int skb_store_bytes(skb, offset, from, len) */
+
+	/**
+	 * skb_store_bytes(skb, offset, from, len, flags) - store bytes into packet
+	 * @skb: pointer to skb
+	 * @offset: offset within packet from skb->data
+	 * @from: pointer where to copy bytes from
+	 * @len: number of bytes to store into packet
+	 * @flags: bit 0 - if true, recompute skb->csum
+	 *         other bits - reserved
+	 * Return: 0 on success
+	 */
+	BPF_FUNC_skb_store_bytes,
+
+	/**
+	 * l3_csum_replace(skb, offset, from, to, flags) - recompute IP checksum
+	 * @skb: pointer to skb
+	 * @offset: offset within packet where IP checksum is located
+	 * @from: old value of header field
+	 * @to: new value of header field
+	 * @flags: bits 0-3 - size of header field
+	 *         other bits - reserved
+	 * Return: 0 on success
+	 */
+	BPF_FUNC_l3_csum_replace,
+
+	/**
+	 * l4_csum_replace(skb, offset, from, to, flags) - recompute TCP/UDP checksum
+	 * @skb: pointer to skb
+	 * @offset: offset within packet where TCP/UDP checksum is located
+	 * @from: old value of header field
+	 * @to: new value of header field
+	 * @flags: bits 0-3 - size of header field
+	 *         bit 4 - is pseudo header
+	 *         other bits - reserved
+	 * Return: 0 on success
+	 */
+	BPF_FUNC_l4_csum_replace,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 444a07e4f68d..e7a51a4b4d34 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1175,7 +1175,9 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	return 0;
 }
 
-static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+#define BPF_RECOMPUTE_CSUM(flags)	((flags) & 1)
+
+static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	unsigned int offset = (unsigned int) r2;
@@ -1192,7 +1194,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	 *
 	 * so check for invalid 'offset' and too large 'len'
 	 */
-	if (offset > 0xffff || len > sizeof(buf))
+	if (unlikely(offset > 0xffff || len > sizeof(buf)))
 		return -EFAULT;
 
 	if (skb_cloned(skb) && !skb_clone_writable(skb, offset + len))
@@ -1202,7 +1204,8 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	if (unlikely(!ptr))
 		return -EFAULT;
 
-	skb_postpull_rcsum(skb, ptr, len);
+	if (BPF_RECOMPUTE_CSUM(flags))
+		skb_postpull_rcsum(skb, ptr, len);
 
 	memcpy(ptr, from, len);
 
@@ -1210,7 +1213,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 		/* skb_store_bits cannot return -EFAULT here */
 		skb_store_bits(skb, offset, ptr, len);
 
-	if (skb->ip_summed == CHECKSUM_COMPLETE)
+	if (BPF_RECOMPUTE_CSUM(flags) && skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_add(skb->csum, csum_partial(ptr, len, 0));
 	return 0;
 }
@@ -1223,6 +1226,99 @@ const struct bpf_func_proto bpf_skb_store_bytes_proto = {
 	.arg2_type	= ARG_ANYTHING,
 	.arg3_type	= ARG_PTR_TO_STACK,
 	.arg4_type	= ARG_CONST_STACK_SIZE,
+	.arg5_type	= ARG_ANYTHING,
+};
+
+#define BPF_HEADER_FIELD_SIZE(flags)	((flags) & 0x0f)
+#define BPF_IS_PSEUDO_HEADER(flags)	((flags) & 0x10)
+
+static u64 bpf_l3_csum_replace(u64 r1, u64 offset, u64 from, u64 to, u64 flags)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	__sum16 sum, *ptr;
+
+	if (unlikely(offset > 0xffff))
+		return -EFAULT;
+
+	if (skb_cloned(skb) && !skb_clone_writable(skb, offset + sizeof(sum)))
+		return -EFAULT;
+
+	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
+	if (unlikely(!ptr))
+		return -EFAULT;
+
+	switch (BPF_HEADER_FIELD_SIZE(flags)) {
+	case 2:
+		csum_replace2(ptr, from, to);
+		break;
+	case 4:
+		csum_replace4(ptr, from, to);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (ptr == &sum)
+		/* skb_store_bits guaranteed to not return -EFAULT here */
+		skb_store_bits(skb, offset, ptr, sizeof(sum));
+
+	return 0;
+}
+
+const struct bpf_func_proto bpf_l3_csum_replace_proto = {
+	.func		= bpf_l3_csum_replace,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_ANYTHING,
+	.arg5_type	= ARG_ANYTHING,
+};
+
+static u64 bpf_l4_csum_replace(u64 r1, u64 offset, u64 from, u64 to, u64 flags)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	u32 is_pseudo = BPF_IS_PSEUDO_HEADER(flags);
+	__sum16 sum, *ptr;
+
+	if (unlikely(offset > 0xffff))
+		return -EFAULT;
+
+	if (skb_cloned(skb) && !skb_clone_writable(skb, offset + sizeof(sum)))
+		return -EFAULT;
+
+	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
+	if (unlikely(!ptr))
+		return -EFAULT;
+
+	switch (BPF_HEADER_FIELD_SIZE(flags)) {
+	case 2:
+		inet_proto_csum_replace2(ptr, skb, from, to, is_pseudo);
+		break;
+	case 4:
+		inet_proto_csum_replace4(ptr, skb, from, to, is_pseudo);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (ptr == &sum)
+		/* skb_store_bits guaranteed to not return -EFAULT here */
+		skb_store_bits(skb, offset, ptr, sizeof(sum));
+
+	return 0;
+}
+
+const struct bpf_func_proto bpf_l4_csum_replace_proto = {
+	.func		= bpf_l4_csum_replace,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_ANYTHING,
+	.arg5_type	= ARG_ANYTHING,
 };
 
 static const struct bpf_func_proto *
@@ -1250,6 +1346,10 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	switch (func_id) {
 	case BPF_FUNC_skb_store_bytes:
 		return &bpf_skb_store_bytes_proto;
+	case BPF_FUNC_l3_csum_replace:
+		return &bpf_l3_csum_replace_proto;
+	case BPF_FUNC_l4_csum_replace:
+		return &bpf_l4_csum_replace_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index b5b3600dcdf5..d24f51bca465 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -17,6 +17,7 @@ sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
 always := $(hostprogs-y)
 always += sockex1_kern.o
 always += sockex2_kern.o
+always += tcbpf1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index ca0333146006..72540ec1f003 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -37,4 +37,11 @@ struct bpf_map_def {
 	unsigned int max_entries;
 };
 
+static int (*bpf_skb_store_bytes)(void *ctx, int off, void *from, int len, int flags) =
+	(void *) BPF_FUNC_skb_store_bytes;
+static int (*bpf_l3_csum_replace)(void *ctx, int off, int from, int to, int flags) =
+	(void *) BPF_FUNC_l3_csum_replace;
+static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flags) =
+	(void *) BPF_FUNC_l4_csum_replace;
+
 #endif
diff --git a/samples/bpf/tcbpf1_kern.c b/samples/bpf/tcbpf1_kern.c
new file mode 100644
index 000000000000..7cf3f42a6e39
--- /dev/null
+++ b/samples/bpf/tcbpf1_kern.c
@@ -0,0 +1,71 @@
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/if_packet.h>
+#include <uapi/linux/ip.h>
+#include <uapi/linux/in.h>
+#include <uapi/linux/tcp.h>
+#include "bpf_helpers.h"
+
+/* compiler workaround */
+#define _htonl __builtin_bswap32
+
+static inline void set_dst_mac(struct __sk_buff *skb, char *mac)
+{
+	bpf_skb_store_bytes(skb, 0, mac, ETH_ALEN, 1);
+}
+
+/* use 1 below for ingress qdisc and 0 for egress */
+#if 0
+#undef ETH_HLEN
+#define ETH_HLEN 0
+#endif
+
+#define IP_CSUM_OFF (ETH_HLEN + offsetof(struct iphdr, check))
+#define TOS_OFF (ETH_HLEN + offsetof(struct iphdr, tos))
+
+static inline void set_ip_tos(struct __sk_buff *skb, __u8 new_tos)
+{
+	__u8 old_tos = load_byte(skb, TOS_OFF);
+
+	bpf_l3_csum_replace(skb, IP_CSUM_OFF, htons(old_tos), htons(new_tos), 2);
+	bpf_skb_store_bytes(skb, TOS_OFF, &new_tos, sizeof(new_tos), 0);
+}
+
+#define TCP_CSUM_OFF (ETH_HLEN + sizeof(struct iphdr) + offsetof(struct tcphdr, check))
+#define IP_SRC_OFF (ETH_HLEN + offsetof(struct iphdr, saddr))
+
+#define IS_PSEUDO 0x10
+
+static inline void set_tcp_ip_src(struct __sk_buff *skb, __u32 new_ip)
+{
+	__u32 old_ip = _htonl(load_word(skb, IP_SRC_OFF));
+
+	bpf_l4_csum_replace(skb, TCP_CSUM_OFF, old_ip, new_ip, IS_PSEUDO | sizeof(new_ip));
+	bpf_l3_csum_replace(skb, IP_CSUM_OFF, old_ip, new_ip, sizeof(new_ip));
+	bpf_skb_store_bytes(skb, IP_SRC_OFF, &new_ip, sizeof(new_ip), 0);
+}
+
+#define TCP_DPORT_OFF (ETH_HLEN + sizeof(struct iphdr) + offsetof(struct tcphdr, dest))
+static inline void set_tcp_dest_port(struct __sk_buff *skb, __u16 new_port)
+{
+	__u16 old_port = htons(load_half(skb, TCP_DPORT_OFF));
+
+	bpf_l4_csum_replace(skb, TCP_CSUM_OFF, old_port, new_port, sizeof(new_port));
+	bpf_skb_store_bytes(skb, TCP_DPORT_OFF, &new_port, sizeof(new_port), 0);
+}
+
+SEC("classifier")
+int bpf_prog1(struct __sk_buff *skb)
+{
+	__u8 proto = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
+	long *value;
+
+	if (proto == IPPROTO_TCP) {
+		set_ip_tos(skb, 8);
+		set_tcp_ip_src(skb, 0xA010101);
+		set_tcp_dest_port(skb, 5001);
+	}
+
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
-- 
1.7.9.5
