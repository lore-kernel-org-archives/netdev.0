From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC net-next 09/14] bpf: allow eBPF programs to use maps
Date: Fri, 27 Jun 2014 17:06:01 -0700
Message-ID: <1403913966-4927-10-git-send-email-ast@plumgrid.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403913966-4927-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

expose bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
map accessors to eBPF programs

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/bpf.h      |    5 +++
 include/uapi/linux/bpf.h |    3 ++
 kernel/bpf/syscall.c     |   85 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 93 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 67fd49eac904..bc505093683a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -127,4 +127,9 @@ struct sk_filter *bpf_prog_get(u32 prog_id);
 /* verify correctness of eBPF program */
 int bpf_check(struct sk_filter *fp);
 
+/* in-kernel helper functions called from eBPF programs */
+u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 597a35cc101d..03c65eedd3d5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -389,6 +389,9 @@ enum bpf_prog_type {
  */
 enum bpf_func_id {
 	BPF_FUNC_unspec,
+	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(map_id, void *key) */
+	BPF_FUNC_map_update_elem, /* int map_update_elem(map_id, void *key, void *value) */
+	BPF_FUNC_map_delete_elem, /* int map_delete_elem(map_id, void *key) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 48d8f43da151..266136f0d333 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -691,3 +691,88 @@ SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 		return -EINVAL;
 	}
 }
+
+/* called from eBPF program under rcu lock
+ *
+ * if kernel subsystem is allowing eBPF programs to call this function,
+ * inside its own verifier_ops->get_func_proto() callback it should return
+ * (struct bpf_func_proto) {
+ *    .ret_type = PTR_TO_MAP_CONDITIONAL,
+ *    .arg1_type = CONST_ARG_MAP_ID,
+ *    .arg2_type = PTR_TO_STACK_IMM_MAP_KEY,
+ * }
+ * so that eBPF verifier properly checks the arguments
+ */
+u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map;
+	int map_id = r1;
+	void *key = (void *) (unsigned long) r2;
+	void *value;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	map = idr_find(&bpf_map_id_idr, map_id);
+	/* eBPF verifier guarantees that map_id is valid for the life of
+	 * the program
+	 */
+	BUG_ON(!map);
+
+	value = map->ops->map_lookup_elem(map, key);
+
+	return (unsigned long) value;
+}
+
+/* called from eBPF program under rcu lock
+ *
+ * if kernel subsystem is allowing eBPF programs to call this function,
+ * inside its own verifier_ops->get_func_proto() callback it should return
+ * (struct bpf_func_proto) {
+ *    .ret_type = RET_INTEGER,
+ *    .arg1_type = CONST_ARG_MAP_ID,
+ *    .arg2_type = PTR_TO_STACK_IMM_MAP_KEY,
+ *    .arg3_type = PTR_TO_STACK_IMM_MAP_VALUE,
+ * }
+ * so that eBPF verifier properly checks the arguments
+ */
+u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map;
+	int map_id = r1;
+	void *key = (void *) (unsigned long) r2;
+	void *value = (void *) (unsigned long) r3;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	map = idr_find(&bpf_map_id_idr, map_id);
+	/* eBPF verifier guarantees that map_id is valid */
+	BUG_ON(!map);
+
+	return map->ops->map_update_elem(map, key, value);
+}
+
+/* called from eBPF program under rcu lock
+ *
+ * if kernel subsystem is allowing eBPF programs to call this function,
+ * inside its own verifier_ops->get_func_proto() callback it should return
+ * (struct bpf_func_proto) {
+ *    .ret_type = RET_INTEGER,
+ *    .arg1_type = CONST_ARG_MAP_ID,
+ *    .arg2_type = PTR_TO_STACK_IMM_MAP_KEY,
+ * }
+ * so that eBPF verifier properly checks the arguments
+ */
+u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map;
+	int map_id = r1;
+	void *key = (void *) (unsigned long) r2;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	map = idr_find(&bpf_map_id_idr, map_id);
+	/* eBPF verifier guarantees that map_id is valid */
+	BUG_ON(!map);
+
+	return map->ops->map_delete_elem(map, key);
+}
-- 
1.7.9.5
