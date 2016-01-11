From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 4/9] bpf: add percpu version of lookup/update element helpers
Date: Mon, 11 Jan 2016 23:56:56 +0800
Message-ID: <1452527821-12276-5-git-send-email-tom.leiming@gmail.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prepare for supporting percpu map.

These introduced two callback & helpers can be used to
retrieve/update the value from one specific CPU for percpu map.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 include/linux/bpf.h      |  3 +++
 include/uapi/linux/bpf.h |  6 ++++++
 kernel/bpf/core.c        |  2 ++
 kernel/bpf/helpers.c     | 53 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c        |  4 ++++
 5 files changed, 68 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 7fa339f..75d75d8 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -219,6 +219,9 @@ extern const struct bpf_func_proto bpf_get_current_comm_proto;
 extern const struct bpf_func_proto bpf_skb_vlan_push_proto;
 extern const struct bpf_func_proto bpf_skb_vlan_pop_proto;
 
+extern const struct bpf_func_proto bpf_map_lookup_elem_percpu_proto;
+extern const struct bpf_func_proto bpf_map_update_elem_percpu_proto;
+
 /* Shared helpers among cBPF and eBPF. */
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 8bed7f1..2658917 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -270,6 +270,12 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_perf_event_output,
 	BPF_FUNC_skb_load_bytes,
+
+	/* void *map_lookup_elem(&map, &key, cpu) */
+	BPF_FUNC_map_lookup_elem_percpu,
+	/* int map_update_elem(&map, &key, &value, flags, cpu) */
+	BPF_FUNC_map_update_elem_percpu,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 972d9a8..71a09fa 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -769,6 +769,8 @@ const struct bpf_func_proto * __weak bpf_get_trace_printk_proto(void)
 {
 	return NULL;
 }
+const struct bpf_func_proto bpf_map_lookup_elem_percpu_proto __weak;
+const struct bpf_func_proto bpf_map_update_elem_percpu_proto __weak;
 
 /* Always built-in helper functions. */
 const struct bpf_func_proto bpf_tail_call_proto = {
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 4504ca6..d05164a 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -54,6 +54,36 @@ const struct bpf_func_proto bpf_map_lookup_elem_proto = {
 	.arg2_type	= ARG_PTR_TO_MAP_KEY,
 };
 
+static u64 bpf_map_lookup_elem_percpu(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	/* verifier checked that R1 contains a valid pointer to bpf_map
+	 * and R2 points to a program stack and map->key_size bytes were
+	 * initialized
+	 */
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	void *key = (void *) (unsigned long) r2;
+	u32 cpu = (u32)(unsigned long) r3;
+	void *value;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	value = map->ops->map_lookup_elem_percpu(map, key, cpu);
+
+	/* lookup() returns either pointer to element value or NULL
+	 * which is the meaning of PTR_TO_MAP_VALUE_OR_NULL type
+	 */
+	return (unsigned long) value;
+}
+
+const struct bpf_func_proto bpf_map_lookup_elem_percpu_proto = {
+	.func		= bpf_map_lookup_elem_percpu,
+	.gpl_only	= false,
+	.ret_type	= RET_PTR_TO_MAP_VALUE_OR_NULL,
+	.arg1_type	= ARG_CONST_MAP_PTR,
+	.arg2_type	= ARG_PTR_TO_MAP_KEY,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 static u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
@@ -75,6 +105,29 @@ const struct bpf_func_proto bpf_map_update_elem_proto = {
 	.arg4_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_map_update_elem_percpu(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	void *key = (void *) (unsigned long) r2;
+	void *value = (void *) (unsigned long) r3;
+	u32 cpu = (u32)(unsigned long) r5;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	return map->ops->map_update_elem_percpu(map, key, value, r4, cpu);
+}
+
+const struct bpf_func_proto bpf_map_update_elem_percpu_proto = {
+	.func		= bpf_map_update_elem_percpu,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_CONST_MAP_PTR,
+	.arg2_type	= ARG_PTR_TO_MAP_KEY,
+	.arg3_type	= ARG_PTR_TO_MAP_VALUE,
+	.arg4_type	= ARG_ANYTHING,
+	.arg5_type	= ARG_ANYTHING,
+};
+
 static u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
diff --git a/net/core/filter.c b/net/core/filter.c
index 35e6fed..8c558fc 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1743,8 +1743,12 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 	switch (func_id) {
 	case BPF_FUNC_map_lookup_elem:
 		return &bpf_map_lookup_elem_proto;
+	case BPF_FUNC_map_lookup_elem_percpu:
+		return &bpf_map_lookup_elem_percpu_proto;
 	case BPF_FUNC_map_update_elem:
 		return &bpf_map_update_elem_proto;
+	case BPF_FUNC_map_update_elem_percpu:
+		return &bpf_map_update_elem_percpu_proto;
 	case BPF_FUNC_map_delete_elem:
 		return &bpf_map_delete_elem_proto;
 	case BPF_FUNC_get_prandom_u32:
-- 
1.9.1
