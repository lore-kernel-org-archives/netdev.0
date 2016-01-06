From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: cleanup bpf_prog_run_{save,clear}_cb helpers
Date: Wed,  6 Jan 2016 22:32:16 +0100
Message-ID: <aaa1eb34322115d06f15946989f4ebd3e399a56e.1452115518.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50865 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbcAFVcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 16:32:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the details behind the cb[] access into a small helper to decouple
and make them generic for bpf_prog_run_save_cb()/bpf_prog_run_clear_cb()
that was introduced via commit ff936a04e5f2 ("bpf: fix cb access in socket
filter programs"). Also add a comment to better clarify what is done in
bpf_skb_cb().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/filter.h | 39 +++++++++++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 10 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 294c3cd..30fa395 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -350,25 +350,43 @@ struct sk_filter {
 
 #define BPF_PROG_RUN(filter, ctx)  (*filter->bpf_func)(ctx, filter->insnsi)
 
+#define BPF_SKB_CB_LEN QDISC_CB_PRIV_LEN
+
+static inline u8 *bpf_skb_cb(struct sk_buff *skb)
+{
+	/* eBPF programs may read/write skb->cb[] area to transfer meta
+	 * data between tail calls. Since this also needs to work with
+	 * tc, that scratch memory is mapped to qdisc_skb_cb's data area.
+	 *
+	 * In some socket filter cases, the cb unfortunately needs to be
+	 * saved/restored so that protocol specific skb->cb[] data won't
+	 * be lost. In any case, due to unpriviledged eBPF programs
+	 * attached to sockets, we need to clear the bpf_skb_cb() area
+	 * to not leak previous contents to user space.
+	 */
+	BUILD_BUG_ON(FIELD_SIZEOF(struct __sk_buff, cb) != BPF_SKB_CB_LEN);
+	BUILD_BUG_ON(FIELD_SIZEOF(struct __sk_buff, cb) !=
+		     FIELD_SIZEOF(struct qdisc_skb_cb, data));
+
+	return qdisc_skb_cb(skb)->data;
+}
+
 static inline u32 bpf_prog_run_save_cb(const struct bpf_prog *prog,
 				       struct sk_buff *skb)
 {
-	u8 *cb_data = qdisc_skb_cb(skb)->data;
-	u8 saved_cb[QDISC_CB_PRIV_LEN];
+	u8 *cb_data = bpf_skb_cb(skb);
+	u8 cb_saved[BPF_SKB_CB_LEN];
 	u32 res;
 
-	BUILD_BUG_ON(FIELD_SIZEOF(struct __sk_buff, cb) !=
-		     QDISC_CB_PRIV_LEN);
-
 	if (unlikely(prog->cb_access)) {
-		memcpy(saved_cb, cb_data, sizeof(saved_cb));
-		memset(cb_data, 0, sizeof(saved_cb));
+		memcpy(cb_saved, cb_data, sizeof(cb_saved));
+		memset(cb_data, 0, sizeof(cb_saved));
 	}
 
 	res = BPF_PROG_RUN(prog, skb);
 
 	if (unlikely(prog->cb_access))
-		memcpy(cb_data, saved_cb, sizeof(saved_cb));
+		memcpy(cb_data, cb_saved, sizeof(cb_saved));
 
 	return res;
 }
@@ -376,10 +394,11 @@ static inline u32 bpf_prog_run_save_cb(const struct bpf_prog *prog,
 static inline u32 bpf_prog_run_clear_cb(const struct bpf_prog *prog,
 					struct sk_buff *skb)
 {
-	u8 *cb_data = qdisc_skb_cb(skb)->data;
+	u8 *cb_data = bpf_skb_cb(skb);
 
 	if (unlikely(prog->cb_access))
-		memset(cb_data, 0, QDISC_CB_PRIV_LEN);
+		memset(cb_data, 0, BPF_SKB_CB_LEN);
+
 	return BPF_PROG_RUN(prog, skb);
 }
 
-- 
1.9.3
