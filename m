From: John Fastabend <john.r.fastabend@gmail.com>
Subject: [net PATCH 2/5] bpf: avoid preempt enable/disable in sockmap using
 tcp_skb_cb region
Date: Wed, 18 Oct 2017 07:10:36 -0700
Message-ID: <150833583655.3588.17390274249900913369.stgit@john-XPS-13-9360>
References: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net
To: alexei.starovoitov@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:55699 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750935AbdJROKx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:10:53 -0400
Received: by mail-pg0-f65.google.com with SMTP id y184so3173349pgd.12
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:10:52 -0700 (PDT)
In-Reply-To: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

SK_SKB BPF programs are run from the socket/tcp context but early in
the stack before much of the TCP metadata is needed in tcp_skb_cb. So
we can use some unused fields to place BPF metadata needed for SK_SKB
programs when implementing the redirect function.

This allows us to drop the preempt disable logic. It does however
require an API change so sk_redirect_map() has been updated to
additionally provide ctx_ptr to skb. Note, we do however continue to
disable/enable preemption around actual BPF program running to account
for map updates.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/filter.h                             |    2 +
 include/net/tcp.h                                  |    5 +++
 kernel/bpf/sockmap.c                               |   19 ++++++-------
 net/core/filter.c                                  |   29 ++++++++++----------
 samples/sockmap/sockmap_kern.c                     |    2 +
 tools/include/uapi/linux/bpf.h                     |    3 +-
 tools/testing/selftests/bpf/bpf_helpers.h          |    2 +
 tools/testing/selftests/bpf/sockmap_verdict_prog.c |    4 +--
 8 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index d29e58f..818a0b2 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -728,7 +728,7 @@ void xdp_do_flush_map(void);
 void bpf_warn_invalid_xdp_action(u32 act);
 void bpf_warn_invalid_xdp_redirect(u32 ifindex);
 
-struct sock *do_sk_redirect_map(void);
+struct sock *do_sk_redirect_map(struct sk_buff *skb);
 
 #ifdef CONFIG_BPF_JIT
 extern int bpf_jit_enable;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 89974c5..b1ef98e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -840,6 +840,11 @@ struct tcp_skb_cb {
 			struct inet6_skb_parm	h6;
 #endif
 		} header;	/* For incoming skbs */
+		struct {
+			__u32 key;
+			__u32 flags;
+			struct bpf_map *map;
+		} bpf;
 	};
 };
 
diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index c68899d..beaabb2 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -39,6 +39,7 @@
 #include <linux/workqueue.h>
 #include <linux/list.h>
 #include <net/strparser.h>
+#include <net/tcp.h>
 
 struct bpf_stab {
 	struct bpf_map map;
@@ -101,9 +102,16 @@ static int smap_verdict_func(struct smap_psock *psock, struct sk_buff *skb)
 		return SK_DROP;
 
 	skb_orphan(skb);
+	/* We need to ensure that BPF metadata for maps is also cleared
+	 * when we orphan the skb so that we don't have the possibility
+	 * to reference a stale map.
+	 */
+	TCP_SKB_CB(skb)->bpf.map = NULL;
 	skb->sk = psock->sock;
 	bpf_compute_data_end(skb);
+	preempt_disable();
 	rc = (*prog->bpf_func)(skb, prog->insnsi);
+	preempt_enable();
 	skb->sk = NULL;
 
 	return rc;
@@ -114,17 +122,10 @@ static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
 	struct sock *sk;
 	int rc;
 
-	/* Because we use per cpu values to feed input from sock redirect
-	 * in BPF program to do_sk_redirect_map() call we need to ensure we
-	 * are not preempted. RCU read lock is not sufficient in this case
-	 * with CONFIG_PREEMPT_RCU enabled so we must be explicit here.
-	 */
-	preempt_disable();
 	rc = smap_verdict_func(psock, skb);
 	switch (rc) {
 	case SK_REDIRECT:
-		sk = do_sk_redirect_map();
-		preempt_enable();
+		sk = do_sk_redirect_map(skb);
 		if (likely(sk)) {
 			struct smap_psock *peer = smap_psock_sk(sk);
 
@@ -141,8 +142,6 @@ static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
 	/* Fall through and free skb otherwise */
 	case SK_DROP:
 	default:
-		if (rc != SK_REDIRECT)
-			preempt_enable();
 		kfree_skb(skb);
 	}
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index 74b8c91..ca1ba0b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1839,31 +1839,31 @@ static const struct bpf_func_proto bpf_redirect_proto = {
 	.arg2_type      = ARG_ANYTHING,
 };
 
-BPF_CALL_3(bpf_sk_redirect_map, struct bpf_map *, map, u32, key, u64, flags)
+BPF_CALL_4(bpf_sk_redirect_map, struct sk_buff *, skb,
+	   struct bpf_map *, map, u32, key, u64, flags)
 {
-	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
 	if (unlikely(flags))
 		return SK_ABORTED;
 
-	ri->ifindex = key;
-	ri->flags = flags;
-	ri->map = map;
+	tcb->bpf.key = key;
+	tcb->bpf.flags = flags;
+	tcb->bpf.map = map;
 
 	return SK_REDIRECT;
 }
 
-struct sock *do_sk_redirect_map(void)
+struct sock *do_sk_redirect_map(struct sk_buff *skb)
 {
-	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 	struct sock *sk = NULL;
 
-	if (ri->map) {
-		sk = __sock_map_lookup_elem(ri->map, ri->ifindex);
+	if (tcb->bpf.map) {
+		sk = __sock_map_lookup_elem(tcb->bpf.map, tcb->bpf.key);
 
-		ri->ifindex = 0;
-		ri->map = NULL;
-		/* we do not clear flags for future lookup */
+		tcb->bpf.key = 0;
+		tcb->bpf.map = NULL;
 	}
 
 	return sk;
@@ -1873,9 +1873,10 @@ static const struct bpf_func_proto bpf_sk_redirect_map_proto = {
 	.func           = bpf_sk_redirect_map,
 	.gpl_only       = false,
 	.ret_type       = RET_INTEGER,
-	.arg1_type      = ARG_CONST_MAP_PTR,
-	.arg2_type      = ARG_ANYTHING,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type      = ARG_CONST_MAP_PTR,
 	.arg3_type      = ARG_ANYTHING,
+	.arg4_type      = ARG_ANYTHING,
 };
 
 BPF_CALL_1(bpf_get_cgroup_classid, const struct sk_buff *, skb)
diff --git a/samples/sockmap/sockmap_kern.c b/samples/sockmap/sockmap_kern.c
index f9b38ef..52b0053 100644
--- a/samples/sockmap/sockmap_kern.c
+++ b/samples/sockmap/sockmap_kern.c
@@ -62,7 +62,7 @@ int bpf_prog2(struct __sk_buff *skb)
 		ret = 1;
 
 	bpf_printk("sockmap: %d -> %d @ %d\n", lport, bpf_ntohl(rport), ret);
-	return bpf_sk_redirect_map(&sock_map, ret, 0);
+	return bpf_sk_redirect_map(skb, &sock_map, ret, 0);
 }
 
 SEC("sockops")
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 43ab5c4..be9a631 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -569,9 +569,10 @@ union bpf_attr {
  *     @flags: reserved for future use
  *     Return: 0 on success or negative error code
  *
- * int bpf_sk_redirect_map(map, key, flags)
+ * int bpf_sk_redirect_map(skb, map, key, flags)
  *     Redirect skb to a sock in map using key as a lookup key for the
  *     sock in map.
+ *     @skb: pointer to skb
  *     @map: pointer to sockmap
  *     @key: key to lookup sock in map
  *     @flags: reserved for future use
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index 36fb916..b2e02bd 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -65,7 +65,7 @@ static int (*bpf_xdp_adjust_head)(void *ctx, int offset) =
 static int (*bpf_setsockopt)(void *ctx, int level, int optname, void *optval,
 			     int optlen) =
 	(void *) BPF_FUNC_setsockopt;
-static int (*bpf_sk_redirect_map)(void *map, int key, int flags) =
+static int (*bpf_sk_redirect_map)(void *ctx, void *map, int key, int flags) =
 	(void *) BPF_FUNC_sk_redirect_map;
 static int (*bpf_sock_map_update)(void *map, void *key, void *value,
 				  unsigned long long flags) =
diff --git a/tools/testing/selftests/bpf/sockmap_verdict_prog.c b/tools/testing/selftests/bpf/sockmap_verdict_prog.c
index 9b99bd1..2cd2d55 100644
--- a/tools/testing/selftests/bpf/sockmap_verdict_prog.c
+++ b/tools/testing/selftests/bpf/sockmap_verdict_prog.c
@@ -61,8 +61,8 @@ int bpf_prog2(struct __sk_buff *skb)
 	bpf_printk("verdict: data[0] = redir(%u:%u)\n", map, sk);
 
 	if (!map)
-		return bpf_sk_redirect_map(&sock_map_rx, sk, 0);
-	return bpf_sk_redirect_map(&sock_map_tx, sk, 0);
+		return bpf_sk_redirect_map(skb, &sock_map_rx, sk, 0);
+	return bpf_sk_redirect_map(skb, &sock_map_tx, sk, 0);
 }
 
 char _license[] SEC("license") = "GPL";
