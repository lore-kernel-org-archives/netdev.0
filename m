From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH 1/2] bpf: bpf_compute_data uses incorrect cb structure
Date: Fri, 27 Oct 2017 09:45:34 -0700
Message-ID: <20171027164534.28498.39170.stgit@john-Precision-Tower-5810>
References: <20171027163830.28498.82997.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, daniel@iogearbox.net
To: alexei.starovoitov@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:57309 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932343AbdJ0Qps (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 12:45:48 -0400
Received: by mail-pg0-f67.google.com with SMTP id m18so5687747pgd.13
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 09:45:48 -0700 (PDT)
In-Reply-To: <20171027163830.28498.82997.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SK_SKB program types use bpf_compute_data to store the end of the
packet data. However, bpf_compute_data assumes the cb is stored in the
qdisc layer format. But, for SK_SKB this is the wrong layer of the
stack for this type.

It happens to work (sort of!) because in most cases nothing happens
to be overwritten today. This is very fragile and error prone.
Fortunately, we have another hole in tcp_skb_cb we can use so lets
put the data_end value there.

Note, SK_SKB program types do not use data_meta, they are failed by
sk_skb_is_valid_access().

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/net/tcp.h    |    1 +
 kernel/bpf/sockmap.c |   12 ++++++++++--
 net/core/filter.c    |   27 ++++++++++++++++++++++++++-
 3 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b1ef98e..33599d17 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -844,6 +844,7 @@ struct tcp_skb_cb {
 			__u32 key;
 			__u32 flags;
 			struct bpf_map *map;
+			void *data_end;
 		} bpf;
 	};
 };
diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index 2b6eb35..6778fb7 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -93,6 +93,14 @@ static inline struct smap_psock *smap_psock_sk(const struct sock *sk)
 	return rcu_dereference_sk_user_data(sk);
 }
 
+/* compute the linear packet data range [data, data_end) for skb when
+ * sk_skb type programs are in use.
+ */
+static inline void bpf_compute_data_end_sk_skb(struct sk_buff *skb)
+{
+	TCP_SKB_CB(skb)->bpf.data_end = skb->data + skb_headlen(skb);
+}
+
 static int smap_verdict_func(struct smap_psock *psock, struct sk_buff *skb)
 {
 	struct bpf_prog *prog = READ_ONCE(psock->bpf_verdict);
@@ -108,7 +116,7 @@ static int smap_verdict_func(struct smap_psock *psock, struct sk_buff *skb)
 	 */
 	TCP_SKB_CB(skb)->bpf.map = NULL;
 	skb->sk = psock->sock;
-	bpf_compute_data_end(skb);
+	bpf_compute_data_end_sk_skb(skb);
 	preempt_disable();
 	rc = (*prog->bpf_func)(skb, prog->insnsi);
 	preempt_enable();
@@ -368,7 +376,7 @@ static int smap_parse_func_strparser(struct strparser *strp,
 	 * any socket yet.
 	 */
 	skb->sk = psock->sock;
-	bpf_compute_data_end(skb);
+	bpf_compute_data_end_sk_skb(skb);
 	rc = (*prog->bpf_func)(skb, prog->insnsi);
 	skb->sk = NULL;
 	rcu_read_unlock();
diff --git a/net/core/filter.c b/net/core/filter.c
index aa02659..68eaa2f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -4243,6 +4243,31 @@ static u32 sock_ops_convert_ctx_access(enum bpf_access_type type,
 	return insn - insn_buf;
 }
 
+static u32 sk_skb_convert_ctx_access(enum bpf_access_type type,
+				     const struct bpf_insn *si,
+				     struct bpf_insn *insn_buf,
+				     struct bpf_prog *prog, u32 *target_size)
+{
+	struct bpf_insn *insn = insn_buf;
+	int off;
+
+	switch (si->off) {
+	case offsetof(struct __sk_buff, data_end):
+		off  = si->off;
+		off -= offsetof(struct __sk_buff, data_end);
+		off += offsetof(struct sk_buff, cb);
+		off += offsetof(struct tcp_skb_cb, bpf.data_end);
+		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(void *), si->dst_reg,
+				      si->src_reg, off);
+		break;
+	default:
+		return bpf_convert_ctx_access(type, si, insn_buf, prog,
+					      target_size);
+	}
+
+	return insn - insn_buf;
+}
+
 const struct bpf_verifier_ops sk_filter_prog_ops = {
 	.get_func_proto		= sk_filter_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
@@ -4301,7 +4326,7 @@ static u32 sock_ops_convert_ctx_access(enum bpf_access_type type,
 const struct bpf_verifier_ops sk_skb_prog_ops = {
 	.get_func_proto		= sk_skb_func_proto,
 	.is_valid_access	= sk_skb_is_valid_access,
-	.convert_ctx_access	= bpf_convert_ctx_access,
+	.convert_ctx_access	= sk_skb_convert_ctx_access,
 	.gen_prologue		= sk_skb_prologue,
 };
 
