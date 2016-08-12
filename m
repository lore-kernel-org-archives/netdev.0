From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix bpf_skb_in_cgroup helper naming
Date: Fri, 12 Aug 2016 22:17:17 +0200
Message-ID: <f08aab1ab054e7609ff3dc1632c4cc4603636d7d.1471031665.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, kafai@fb.com, tj@kernel.org,
	sargun@sargun.me, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51027 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbcHLURX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 16:17:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While hashing out BPF's current_task_under_cgroup helper bits, it came
to discussion that the skb_in_cgroup helper name was suboptimally chosen.

Tejun says:

  So, I think in_cgroup should mean that the object is in that
  particular cgroup while under_cgroup in the subhierarchy of that
  cgroup. Let's rename the other subhierarchy test to under too. I
  think that'd be a lot less confusing going forward.

  [...]

  It's more intuitive and gives us the room to implement the real
  "in" test if ever necessary in the future.

Since this touches uapi bits, we need to change this as long as v4.8
is not yet officially released. Thus, change the helper enum and rename
related bits.

Fixes: 4a482f34afcc ("cgroup: bpf: Add bpf_skb_in_cgroup_proto")
Reference: http://patchwork.ozlabs.org/patch/658500/
Suggested-by: Sargun Dhillon <sargun@sargun.me>
Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h         |  4 ++--
 kernel/bpf/verifier.c            |  4 ++--
 net/core/filter.c                | 10 +++++-----
 samples/bpf/bpf_helpers.h        |  4 ++--
 samples/bpf/test_cgrp2_tc_kern.c |  2 +-
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index da218fe..9e5fc16 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -339,7 +339,7 @@ enum bpf_func_id {
 	BPF_FUNC_skb_change_type,
 
 	/**
-	 * bpf_skb_in_cgroup(skb, map, index) - Check cgroup2 membership of skb
+	 * bpf_skb_under_cgroup(skb, map, index) - Check cgroup2 membership of skb
 	 * @skb: pointer to skb
 	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
 	 * @index: index of the cgroup in the bpf_map
@@ -348,7 +348,7 @@ enum bpf_func_id {
 	 *   == 1 skb succeeded the cgroup2 descendant test
 	 *    < 0 error
 	 */
-	BPF_FUNC_skb_in_cgroup,
+	BPF_FUNC_skb_under_cgroup,
 
 	/**
 	 * bpf_get_hash_recalc(skb)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 7094c69..daea765 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1053,7 +1053,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 			goto error;
 		break;
 	case BPF_MAP_TYPE_CGROUP_ARRAY:
-		if (func_id != BPF_FUNC_skb_in_cgroup)
+		if (func_id != BPF_FUNC_skb_under_cgroup)
 			goto error;
 		break;
 	default:
@@ -1075,7 +1075,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		if (map->map_type != BPF_MAP_TYPE_STACK_TRACE)
 			goto error;
 		break;
-	case BPF_FUNC_skb_in_cgroup:
+	case BPF_FUNC_skb_under_cgroup:
 		if (map->map_type != BPF_MAP_TYPE_CGROUP_ARRAY)
 			goto error;
 		break;
diff --git a/net/core/filter.c b/net/core/filter.c
index 927e136..cb06ace 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2283,7 +2283,7 @@ bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
 }
 
 #ifdef CONFIG_SOCK_CGROUP_DATA
-static u64 bpf_skb_in_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+static u64 bpf_skb_under_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *)(long)r1;
 	struct bpf_map *map = (struct bpf_map *)(long)r2;
@@ -2306,8 +2306,8 @@ static u64 bpf_skb_in_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return cgroup_is_descendant(sock_cgroup_ptr(&sk->sk_cgrp_data), cgrp);
 }
 
-static const struct bpf_func_proto bpf_skb_in_cgroup_proto = {
-	.func		= bpf_skb_in_cgroup,
+static const struct bpf_func_proto bpf_skb_under_cgroup_proto = {
+	.func		= bpf_skb_under_cgroup,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
@@ -2387,8 +2387,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_smp_processor_id_proto;
 #ifdef CONFIG_SOCK_CGROUP_DATA
-	case BPF_FUNC_skb_in_cgroup:
-		return &bpf_skb_in_cgroup_proto;
+	case BPF_FUNC_skb_under_cgroup:
+		return &bpf_skb_under_cgroup_proto;
 #endif
 	default:
 		return sk_filter_func_proto(func_id);
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 217c8d5..7927a09 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -72,8 +72,8 @@ static int (*bpf_l3_csum_replace)(void *ctx, int off, int from, int to, int flag
 	(void *) BPF_FUNC_l3_csum_replace;
 static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flags) =
 	(void *) BPF_FUNC_l4_csum_replace;
-static int (*bpf_skb_in_cgroup)(void *ctx, void *map, int index) =
-	(void *) BPF_FUNC_skb_in_cgroup;
+static int (*bpf_skb_under_cgroup)(void *ctx, void *map, int index) =
+	(void *) BPF_FUNC_skb_under_cgroup;
 
 #if defined(__x86_64__)
 
diff --git a/samples/bpf/test_cgrp2_tc_kern.c b/samples/bpf/test_cgrp2_tc_kern.c
index 2732c37..10ff734 100644
--- a/samples/bpf/test_cgrp2_tc_kern.c
+++ b/samples/bpf/test_cgrp2_tc_kern.c
@@ -57,7 +57,7 @@ int handle_egress(struct __sk_buff *skb)
 		bpf_trace_printk(dont_care_msg, sizeof(dont_care_msg),
 				 eth->h_proto, ip6h->nexthdr);
 		return TC_ACT_OK;
-	} else if (bpf_skb_in_cgroup(skb, &test_cgrp2_array_pin, 0) != 1) {
+	} else if (bpf_skb_under_cgroup(skb, &test_cgrp2_array_pin, 0) != 1) {
 		bpf_trace_printk(pass_msg, sizeof(pass_msg));
 		return TC_ACT_OK;
 	} else {
-- 
1.9.3
