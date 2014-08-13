From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 15/26] bpf: allow eBPF programs to use maps
Date: Wed, 13 Aug 2014 00:57:26 -0700
Message-ID: <1407916658-8731-16-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

expose bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
map accessors to eBPF programs

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |    5 ++++
 include/uapi/linux/bpf.h |    3 ++
 kernel/bpf/syscall.c     |   68 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 76 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 4d99c62c6cea..e811e294b59a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -132,4 +132,9 @@ struct bpf_prog *bpf_prog_get(u32 ufd);
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog *fp, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1]);
 
+/* in-kernel helper functions called from eBPF programs */
+u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 7e025ba49b70..c18ac0c1e3e5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -403,6 +403,9 @@ enum bpf_prog_type {
  */
 enum bpf_func_id {
 	BPF_FUNC_unspec,
+	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
+	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value) */
+	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 60cb760cb423..009fe8c77a0b 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -588,3 +588,71 @@ SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 		return -EINVAL;
 	}
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
