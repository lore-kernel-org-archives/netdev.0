From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC v7 net-next 15/28] bpf: allow eBPF programs to use maps
Date: Tue, 26 Aug 2014 19:29:29 -0700
Message-ID: <1409106582-10095-16-git-send-email-ast@plumgrid.com>
References: <1409106582-10095-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409106582-10095-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

expose bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
map accessors to eBPF programs

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/bpf.h      |    5 ++++
 include/uapi/linux/bpf.h |    3 ++
 kernel/bpf/syscall.c     |   68 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 76 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index ad1bda7ece35..14e23bb10b2d 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -131,4 +131,9 @@ struct bpf_prog *bpf_prog_get(u32 ufd);
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
 
+/* in-kernel helper functions called from eBPF programs */
+u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index dee7a2469b8d..f87b501b2e1b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -419,6 +419,9 @@ union bpf_attr {
  */
 enum bpf_func_id {
 	BPF_FUNC_unspec,
+	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
+	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value) */
+	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 8f11d1549cfc..641bb9e6709c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -575,3 +575,71 @@ free_attr:
 	kfree(attr);
 	return err;
 }
+
+/* called from eBPF program under rcu lock
+ *
+ * if kernel subsystem is allowing eBPF programs to call this function,
+ * inside its own verifier_ops->get_func_proto() callback it should return
+ * (struct bpf_func_proto) {
+ *    .ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
+ *    .arg1_type = ARG_CONST_MAP_PTR,
+ *    .arg2_type = ARG_PTR_TO_MAP_KEY,
+ * }
+ * so that eBPF verifier properly checks the arguments
+ */
+u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	void *key = (void *) (unsigned long) r2;
+	void *value;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
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
+ *    .arg1_type = ARG_CONST_MAP_PTR,
+ *    .arg2_type = ARG_PTR_TO_MAP_KEY,
+ *    .arg3_type = ARG_PTR_TO_MAP_VALUE,
+ * }
+ * so that eBPF verifier properly checks the arguments
+ */
+u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	void *key = (void *) (unsigned long) r2;
+	void *value = (void *) (unsigned long) r3;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
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
+ *    .arg1_type = ARG_CONST_MAP_PTR,
+ *    .arg2_type = ARG_PTR_TO_MAP_KEY,
+ * }
+ * so that eBPF verifier properly checks the arguments
+ */
+u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+	void *key = (void *) (unsigned long) r2;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	return map->ops->map_delete_elem(map, key);
+}
-- 
1.7.9.5
