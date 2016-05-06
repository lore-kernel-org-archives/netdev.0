From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/7] bpf: wire in data and data_end for cls_act_bpf
Date: Thu, 5 May 2016 19:49:12 -0700
Message-ID: <1462502955-1731797-5-git-send-email-ast@fb.com>
References: <1462502955-1731797-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33080 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756782AbcEFCtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 22:49:21 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u462jjsj027658
	for <netdev@vger.kernel.org>; Thu, 5 May 2016 19:49:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22rh7ugj8u-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 05 May 2016 19:49:17 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 1f9715ea133511e6b5310002c95209d8-9baf4c50 for <netdev@vger.kernel.org>;	Thu,
 05 May 2016 19:49:16 -0700
In-Reply-To: <1462502955-1731797-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allow cls_bpf and act_bpf programs access skb->data and skb->data_end pointers.
The bpf helpers that change skb->data need to update data_end pointer as well.
The verifier checks that programs always reload data, data_end pointers
after calls to such bpf helpers.
We cannot add 'data_end' pointer to struct qdisc_skb_cb directly,
since it's embedded as-is by infiniband ipoib, so wrapper struct is needed.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/filter.h | 16 ++++++++++++++++
 net/core/filter.c      | 51 ++++++++++++++++++++++++++++++++++++++++++++------
 net/sched/act_bpf.c    |  2 ++
 net/sched/cls_bpf.c    |  2 ++
 4 files changed, 65 insertions(+), 6 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 43aa1f8855c7..ec1411c89105 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -352,6 +352,22 @@ struct sk_filter {
 
 #define BPF_SKB_CB_LEN QDISC_CB_PRIV_LEN
 
+struct bpf_skb_data_end {
+	struct qdisc_skb_cb qdisc_cb;
+	void *data_end;
+};
+
+/* compute the linear packet data range [data, data_end) which
+ * will be accessed by cls_bpf and act_bpf programs
+ */
+static inline void bpf_compute_data_end(struct sk_buff *skb)
+{
+	struct bpf_skb_data_end *cb = (struct bpf_skb_data_end *)skb->cb;
+
+	BUILD_BUG_ON(sizeof(*cb) > FIELD_SIZEOF(struct sk_buff, cb));
+	cb->data_end = skb->data + skb_headlen(skb);
+}
+
 static inline u8 *bpf_skb_cb(struct sk_buff *skb)
 {
 	/* eBPF programs may read/write skb->cb[] area to transfer meta
diff --git a/net/core/filter.c b/net/core/filter.c
index 218e5de8c402..71c2a1f473ad 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1344,6 +1344,21 @@ struct bpf_scratchpad {
 
 static DEFINE_PER_CPU(struct bpf_scratchpad, bpf_sp);
 
+static inline int bpf_try_make_writable(struct sk_buff *skb,
+					unsigned int write_len)
+{
+	int err;
+
+	if (!skb_cloned(skb))
+		return 0;
+	if (skb_clone_writable(skb, write_len))
+		return 0;
+	err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+	if (!err)
+		bpf_compute_data_end(skb);
+	return err;
+}
+
 static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 {
 	struct bpf_scratchpad *sp = this_cpu_ptr(&bpf_sp);
@@ -1366,7 +1381,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	 */
 	if (unlikely((u32) offset > 0xffff || len > sizeof(sp->buff)))
 		return -EFAULT;
-	if (unlikely(skb_try_make_writable(skb, offset + len)))
+	if (unlikely(bpf_try_make_writable(skb, offset + len)))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, len, sp->buff);
@@ -1444,7 +1459,7 @@ static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 		return -EINVAL;
 	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
-	if (unlikely(skb_try_make_writable(skb, offset + sizeof(sum))))
+	if (unlikely(bpf_try_make_writable(skb, offset + sizeof(sum))))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
@@ -1499,7 +1514,7 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 		return -EINVAL;
 	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
-	if (unlikely(skb_try_make_writable(skb, offset + sizeof(sum))))
+	if (unlikely(bpf_try_make_writable(skb, offset + sizeof(sum))))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
@@ -1699,12 +1714,15 @@ static u64 bpf_skb_vlan_push(u64 r1, u64 r2, u64 vlan_tci, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	__be16 vlan_proto = (__force __be16) r2;
+	int ret;
 
 	if (unlikely(vlan_proto != htons(ETH_P_8021Q) &&
 		     vlan_proto != htons(ETH_P_8021AD)))
 		vlan_proto = htons(ETH_P_8021Q);
 
-	return skb_vlan_push(skb, vlan_proto, vlan_tci);
+	ret = skb_vlan_push(skb, vlan_proto, vlan_tci);
+	bpf_compute_data_end(skb);
+	return ret;
 }
 
 const struct bpf_func_proto bpf_skb_vlan_push_proto = {
@@ -1720,8 +1738,11 @@ EXPORT_SYMBOL_GPL(bpf_skb_vlan_push_proto);
 static u64 bpf_skb_vlan_pop(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	int ret;
 
-	return skb_vlan_pop(skb);
+	ret = skb_vlan_pop(skb);
+	bpf_compute_data_end(skb);
+	return ret;
 }
 
 const struct bpf_func_proto bpf_skb_vlan_pop_proto = {
@@ -2066,8 +2087,12 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 static bool sk_filter_is_valid_access(int off, int size,
 				      enum bpf_access_type type)
 {
-	if (off == offsetof(struct __sk_buff, tc_classid))
+	switch (off) {
+	case offsetof(struct __sk_buff, tc_classid):
+	case offsetof(struct __sk_buff, data):
+	case offsetof(struct __sk_buff, data_end):
 		return false;
+	}
 
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -2215,6 +2240,20 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 			*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg, ctx_off);
 		break;
 
+	case offsetof(struct __sk_buff, data):
+		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct sk_buff, data)),
+				      dst_reg, src_reg,
+				      offsetof(struct sk_buff, data));
+		break;
+
+	case offsetof(struct __sk_buff, data_end):
+		ctx_off -= offsetof(struct __sk_buff, data_end);
+		ctx_off += offsetof(struct sk_buff, cb);
+		ctx_off += offsetof(struct bpf_skb_data_end, data_end);
+		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(sizeof(void *)),
+				      dst_reg, src_reg, ctx_off);
+		break;
+
 	case offsetof(struct __sk_buff, tc_index):
 #ifdef CONFIG_NET_SCHED
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, tc_index) != 2);
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 4fd703362563..c7123e01c2ca 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -53,9 +53,11 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 	filter = rcu_dereference(prog->filter);
 	if (at_ingress) {
 		__skb_push(skb, skb->mac_len);
+		bpf_compute_data_end(skb);
 		filter_res = BPF_PROG_RUN(filter, skb);
 		__skb_pull(skb, skb->mac_len);
 	} else {
+		bpf_compute_data_end(skb);
 		filter_res = BPF_PROG_RUN(filter, skb);
 	}
 	rcu_read_unlock();
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 425fe6a0eda3..7b342c779da7 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -96,9 +96,11 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		if (at_ingress) {
 			/* It is safe to push/pull even if skb_shared() */
 			__skb_push(skb, skb->mac_len);
+			bpf_compute_data_end(skb);
 			filter_res = BPF_PROG_RUN(prog->filter, skb);
 			__skb_pull(skb, skb->mac_len);
 		} else {
+			bpf_compute_data_end(skb);
 			filter_res = BPF_PROG_RUN(prog->filter, skb);
 		}
 
-- 
2.8.0
