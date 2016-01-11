From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] bpf: export helper function flags and reject invalid ones
Date: Mon, 11 Jan 2016 01:16:38 +0100
Message-ID: <a948ba8030e453ce04981ac2e532b8a1e708381f.1452385316.git.daniel@iogearbox.net>
References: <cover.1452385316.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53595 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757894AbcAKAQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 19:16:58 -0500
In-Reply-To: <cover.1452385316.git.daniel@iogearbox.net>
In-Reply-To: <cover.1452385316.git.daniel@iogearbox.net>
References: <cover.1452385316.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export flags used by eBPF helper functions through UAPI, so they can be
used by programs (instead of them redefining all flags each time or just
using the hard-coded values). It also gives a better overview what flags
are used where and we can further get rid of the extra macros defined in
filter.c. Moreover, reject invalid flags.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h | 16 ++++++++++++++++
 net/core/filter.c        | 37 +++++++++++++++++++++++--------------
 2 files changed, 39 insertions(+), 14 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 8bed7f1..d94797c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -273,6 +273,22 @@ enum bpf_func_id {
 	__BPF_FUNC_MAX_ID,
 };
 
+/* All flags used by eBPF helper functions, placed here. */
+
+/* BPF_FUNC_skb_store_bytes flags. */
+#define BPF_F_RECOMPUTE_CSUM		(1ULL << 0)
+
+/* BPF_FUNC_l3_csum_replace and BPF_FUNC_l4_csum_replace flags.
+ * First 4 bits are for passing the header field size.
+ */
+#define BPF_F_HDR_FIELD_MASK		0xfULL
+
+/* BPF_FUNC_l4_csum_replace flags. */
+#define BPF_F_PSEUDO_HDR		(1ULL << 4)
+
+/* BPF_FUNC_clone_redirect and BPF_FUNC_redirect flags. */
+#define BPF_F_INGRESS			(1ULL << 0)
+
 /* user accessible mirror of in-kernel sk_buff.
  * new fields can only be added to the end of this structure
  */
diff --git a/net/core/filter.c b/net/core/filter.c
index 0db92b5..7c55cad 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1328,8 +1328,7 @@ int sk_reuseport_attach_bpf(u32 ufd, struct sock *sk)
 	return 0;
 }
 
-#define BPF_RECOMPUTE_CSUM(flags)	((flags) & 1)
-#define BPF_LDST_LEN			16U
+#define BPF_LDST_LEN 16U
 
 static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 {
@@ -1340,6 +1339,9 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	char buf[BPF_LDST_LEN];
 	void *ptr;
 
+	if (unlikely(flags & ~(BPF_F_RECOMPUTE_CSUM)))
+		return -EINVAL;
+
 	/* bpf verifier guarantees that:
 	 * 'from' pointer points to bpf program stack
 	 * 'len' bytes of it were initialized
@@ -1359,7 +1361,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	if (unlikely(!ptr))
 		return -EFAULT;
 
-	if (BPF_RECOMPUTE_CSUM(flags))
+	if (flags & BPF_F_RECOMPUTE_CSUM)
 		skb_postpull_rcsum(skb, ptr, len);
 
 	memcpy(ptr, from, len);
@@ -1368,7 +1370,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 		/* skb_store_bits cannot return -EFAULT here */
 		skb_store_bits(skb, offset, ptr, len);
 
-	if (BPF_RECOMPUTE_CSUM(flags))
+	if (flags & BPF_F_RECOMPUTE_CSUM)
 		skb_postpush_rcsum(skb, ptr, len);
 
 	return 0;
@@ -1415,15 +1417,14 @@ const struct bpf_func_proto bpf_skb_load_bytes_proto = {
 	.arg4_type	= ARG_CONST_STACK_SIZE,
 };
 
-#define BPF_HEADER_FIELD_SIZE(flags)	((flags) & 0x0f)
-#define BPF_IS_PSEUDO_HEADER(flags)	((flags) & 0x10)
-
 static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	int offset = (int) r2;
 	__sum16 sum, *ptr;
 
+	if (unlikely(flags & ~(BPF_F_HDR_FIELD_MASK)))
+		return -EINVAL;
 	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
 
@@ -1435,7 +1436,7 @@ static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 	if (unlikely(!ptr))
 		return -EFAULT;
 
-	switch (BPF_HEADER_FIELD_SIZE(flags)) {
+	switch (flags & BPF_F_HDR_FIELD_MASK) {
 	case 2:
 		csum_replace2(ptr, from, to);
 		break;
@@ -1467,10 +1468,12 @@ const struct bpf_func_proto bpf_l3_csum_replace_proto = {
 static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	bool is_pseudo = !!BPF_IS_PSEUDO_HEADER(flags);
+	bool is_pseudo = flags & BPF_F_PSEUDO_HDR;
 	int offset = (int) r2;
 	__sum16 sum, *ptr;
 
+	if (unlikely(flags & ~(BPF_F_PSEUDO_HDR | BPF_F_HDR_FIELD_MASK)))
+		return -EINVAL;
 	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
 
@@ -1482,7 +1485,7 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 	if (unlikely(!ptr))
 		return -EFAULT;
 
-	switch (BPF_HEADER_FIELD_SIZE(flags)) {
+	switch (flags & BPF_F_HDR_FIELD_MASK) {
 	case 2:
 		inet_proto_csum_replace2(ptr, skb, from, to, is_pseudo);
 		break;
@@ -1511,13 +1514,14 @@ const struct bpf_func_proto bpf_l4_csum_replace_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
-#define BPF_IS_REDIRECT_INGRESS(flags)	((flags) & 1)
-
 static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1, *skb2;
 	struct net_device *dev;
 
+	if (unlikely(flags & ~(BPF_F_INGRESS)))
+		return -EINVAL;
+
 	dev = dev_get_by_index_rcu(dev_net(skb->dev), ifindex);
 	if (unlikely(!dev))
 		return -EINVAL;
@@ -1526,7 +1530,7 @@ static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 	if (unlikely(!skb2))
 		return -ENOMEM;
 
-	if (BPF_IS_REDIRECT_INGRESS(flags)) {
+	if (flags & BPF_F_INGRESS) {
 		if (skb_at_tc_ingress(skb2))
 			skb_postpush_rcsum(skb2, skb_mac_header(skb2),
 					   skb2->mac_len);
@@ -1553,12 +1557,17 @@ struct redirect_info {
 };
 
 static DEFINE_PER_CPU(struct redirect_info, redirect_info);
+
 static u64 bpf_redirect(u64 ifindex, u64 flags, u64 r3, u64 r4, u64 r5)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 
+	if (unlikely(flags & ~(BPF_F_INGRESS)))
+		return TC_ACT_SHOT;
+
 	ri->ifindex = ifindex;
 	ri->flags = flags;
+
 	return TC_ACT_REDIRECT;
 }
 
@@ -1574,7 +1583,7 @@ int skb_do_redirect(struct sk_buff *skb)
 		return -EINVAL;
 	}
 
-	if (BPF_IS_REDIRECT_INGRESS(ri->flags)) {
+	if (ri->flags & BPF_F_INGRESS) {
 		if (skb_at_tc_ingress(skb))
 			skb_postpush_rcsum(skb, skb_mac_header(skb),
 					   skb->mac_len);
-- 
1.9.3
