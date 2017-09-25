From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/6] bpf: rename bpf_compute_data_end into bpf_compute_data_pointers
Date: Mon, 25 Sep 2017 02:25:50 +0200
Message-ID: <9ab7611469e6314f35ae85a274308064417f3be2.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37229 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933040AbdIYA1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 20:27:07 -0400
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just do the rename into bpf_compute_data_pointers() as we'll add
one more pointer here to recompute.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 include/linux/filter.h |  9 ++++++---
 kernel/bpf/sockmap.c   |  4 ++--
 net/bpf/test_run.c     |  2 +-
 net/core/filter.c      | 14 +++++++-------
 net/core/lwt_bpf.c     |  2 +-
 net/sched/act_bpf.c    |  4 ++--
 net/sched/cls_bpf.c    |  4 ++--
 7 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index d29e58f..052bab3 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -496,10 +496,13 @@ struct xdp_buff {
 	void *data_hard_start;
 };
 
-/* compute the linear packet data range [data, data_end) which
- * will be accessed by cls_bpf, act_bpf and lwt programs
+/* Compute the linear packet data range [data, data_end) which
+ * will be accessed by various program types (cls_bpf, act_bpf,
+ * lwt, ...). Subsystems allowing direct data access must (!)
+ * ensure that cb[] area can be written to when BPF program is
+ * invoked (otherwise cb[] save/restore is necessary).
  */
-static inline void bpf_compute_data_end(struct sk_buff *skb)
+static inline void bpf_compute_data_pointers(struct sk_buff *skb)
 {
 	struct bpf_skb_data_end *cb = (struct bpf_skb_data_end *)skb->cb;
 
diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index 6424ce0..a298d66 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -102,7 +102,7 @@ static int smap_verdict_func(struct smap_psock *psock, struct sk_buff *skb)
 
 	skb_orphan(skb);
 	skb->sk = psock->sock;
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	rc = (*prog->bpf_func)(skb, prog->insnsi);
 	skb->sk = NULL;
 
@@ -369,7 +369,7 @@ static int smap_parse_func_strparser(struct strparser *strp,
 	 * any socket yet.
 	 */
 	skb->sk = psock->sock;
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	rc = (*prog->bpf_func)(skb, prog->insnsi);
 	skb->sk = NULL;
 	rcu_read_unlock();
diff --git a/net/bpf/test_run.c b/net/bpf/test_run.c
index 6be41a4..df67251 100644
--- a/net/bpf/test_run.c
+++ b/net/bpf/test_run.c
@@ -133,7 +133,7 @@ int bpf_prog_test_run_skb(struct bpf_prog *prog, const union bpf_attr *kattr,
 	if (is_l2)
 		__skb_push(skb, ETH_HLEN);
 	if (is_direct_pkt_access)
-		bpf_compute_data_end(skb);
+		bpf_compute_data_pointers(skb);
 	retval = bpf_test_run(prog, skb, repeat, &duration);
 	if (!is_l2)
 		__skb_push(skb, ETH_HLEN);
diff --git a/net/core/filter.c b/net/core/filter.c
index 82edad5..c468e7c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1402,7 +1402,7 @@ static inline int bpf_try_make_writable(struct sk_buff *skb,
 {
 	int err = __bpf_try_make_writable(skb, write_len);
 
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	return err;
 }
 
@@ -1962,7 +1962,7 @@ struct sock *do_sk_redirect_map(void)
 	ret = skb_vlan_push(skb, vlan_proto, vlan_tci);
 	bpf_pull_mac_rcsum(skb);
 
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	return ret;
 }
 
@@ -1984,7 +1984,7 @@ struct sock *do_sk_redirect_map(void)
 	ret = skb_vlan_pop(skb);
 	bpf_pull_mac_rcsum(skb);
 
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	return ret;
 }
 
@@ -2178,7 +2178,7 @@ static int bpf_skb_proto_xlat(struct sk_buff *skb, __be16 to_proto)
 	 * need to be verified first.
 	 */
 	ret = bpf_skb_proto_xlat(skb, proto);
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	return ret;
 }
 
@@ -2303,7 +2303,7 @@ static int bpf_skb_adjust_net(struct sk_buff *skb, s32 len_diff)
 	ret = shrink ? bpf_skb_net_shrink(skb, len_diff_abs) :
 		       bpf_skb_net_grow(skb, len_diff_abs);
 
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	return ret;
 }
 
@@ -2394,7 +2394,7 @@ static int bpf_skb_trim_rcsum(struct sk_buff *skb, unsigned int new_len)
 			skb_gso_reset(skb);
 	}
 
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	return ret;
 }
 
@@ -2434,7 +2434,7 @@ static int bpf_skb_trim_rcsum(struct sk_buff *skb, unsigned int new_len)
 		skb_reset_mac_header(skb);
 	}
 
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	return 0;
 }
 
diff --git a/net/core/lwt_bpf.c b/net/core/lwt_bpf.c
index 1307731..e7e626f 100644
--- a/net/core/lwt_bpf.c
+++ b/net/core/lwt_bpf.c
@@ -51,7 +51,7 @@ static int run_lwt_bpf(struct sk_buff *skb, struct bpf_lwt_prog *lwt,
 	 */
 	preempt_disable();
 	rcu_read_lock();
-	bpf_compute_data_end(skb);
+	bpf_compute_data_pointers(skb);
 	ret = bpf_prog_run_save_cb(lwt->prog, skb);
 	rcu_read_unlock();
 
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index c0c707e..5ef8ce8 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -49,11 +49,11 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 	filter = rcu_dereference(prog->filter);
 	if (at_ingress) {
 		__skb_push(skb, skb->mac_len);
-		bpf_compute_data_end(skb);
+		bpf_compute_data_pointers(skb);
 		filter_res = BPF_PROG_RUN(filter, skb);
 		__skb_pull(skb, skb->mac_len);
 	} else {
-		bpf_compute_data_end(skb);
+		bpf_compute_data_pointers(skb);
 		filter_res = BPF_PROG_RUN(filter, skb);
 	}
 	rcu_read_unlock();
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 520c502..36671b0 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -99,11 +99,11 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		} else if (at_ingress) {
 			/* It is safe to push/pull even if skb_shared() */
 			__skb_push(skb, skb->mac_len);
-			bpf_compute_data_end(skb);
+			bpf_compute_data_pointers(skb);
 			filter_res = BPF_PROG_RUN(prog->filter, skb);
 			__skb_pull(skb, skb->mac_len);
 		} else {
-			bpf_compute_data_end(skb);
+			bpf_compute_data_pointers(skb);
 			filter_res = BPF_PROG_RUN(prog->filter, skb);
 		}
 
-- 
1.9.3
