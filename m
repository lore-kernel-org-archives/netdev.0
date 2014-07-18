From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v2 net-next 11/16] bpf: allow eBPF programs to use maps
Date: Thu, 17 Jul 2014 21:20:01 -0700
Message-ID: <1405657206-12060-12-git-send-email-ast@plumgrid.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

expose bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
map accessors to eBPF programs

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |    5 +++
 include/uapi/linux/bpf.h |    3 ++
 kernel/bpf/syscall.c     |   85 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 93 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index b5e90efddfcf..a7566afbe23b 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -128,4 +128,9 @@ struct sk_filter *bpf_prog_get(u32 ufd);
 /* verify correctness of eBPF program */
 int bpf_check(struct sk_filter *fp);
 
+/* in-kernel helper functions called from eBPF programs */
+u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 3f288e1d08f1..06e0f63055fb 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -377,6 +377,9 @@ enum bpf_prog_type {
  */
 enum bpf_func_id {
 	BPF_FUNC_unspec,
+	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(map_id, void *key) */
+	BPF_FUNC_map_update_elem, /* int map_update_elem(map_id, void *key, void *value) */
+	BPF_FUNC_map_delete_elem, /* int map_delete_elem(map_id, void *key) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 9d441f17548e..2d6e6a171594 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -741,3 +741,88 @@ SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
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
