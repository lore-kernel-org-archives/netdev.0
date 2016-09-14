From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 03/22] bpf,landlock: Add a new arraymap type to deal with (Landlock) handles
Date: Wed, 14 Sep 2016 09:23:56 +0200
Message-ID: <20160914072415.26021-4-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4593-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This new arraymap looks like a set and brings new properties:
* strong typing of entries: the eBPF functions get the array type of
  elements instead of CONST_PTR_TO_MAP (e.g.
  CONST_PTR_TO_LANDLOCK_HANDLE_FS);
* force sequential filling (i.e. replace or append-only update), which
  allow quick browsing of all entries.

This strong typing is useful to statically check if the content of a map
can be passed to an eBPF function. For example, Landlock use it to store
and manage kernel objects (e.g. struct file) instead of dealing with
userland raw data. This improve efficiency and ensure that an eBPF
program can only call functions with the right high-level arguments.

The enum bpf_map_handle_type list low-level types (e.g.
BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) which are identified when
updating a map entry (handle). This handle types are used to infer a
high-level arraymap type which are listed in enum bpf_map_array_type
(e.g. BPF_MAP_ARRAY_TYPE_LANDLOCK_FS).

For now, this new arraymap is only used by Landlock LSM (cf. next
commits) but it could be useful for other needs.

Changes since v2:
* add a RLIMIT_NOFILE-based limit to the maximum number of arraymap
  handle entries (suggested by Andy Lutomirski)
* remove useless checks

Changes since v1:
* arraymap of handles replace custom checker groups
* simpler userland API

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Kees Cook <keescook@chromium.org>
Link: https://lkml.kernel.org/r/CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh77FD2G5o71yD7g@mail.gmail.com
---
 include/linux/bpf.h      |  14 ++++
 include/uapi/linux/bpf.h |  18 +++++
 kernel/bpf/arraymap.c    | 203 +++++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/verifier.c    |  12 ++-
 4 files changed, 246 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index fa9a988400d9..eae4ce4542c1 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -13,6 +13,10 @@
 #include <linux/percpu.h>
 #include <linux/err.h>
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+#include <linux/fs.h> /* struct file */
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 struct perf_event;
 struct bpf_map;
 
@@ -38,6 +42,7 @@ struct bpf_map_ops {
 struct bpf_map {
 	atomic_t refcnt;
 	enum bpf_map_type map_type;
+	enum bpf_map_array_type map_array_type;
 	u32 key_size;
 	u32 value_size;
 	u32 max_entries;
@@ -187,6 +192,9 @@ struct bpf_array {
 	 */
 	enum bpf_prog_type owner_prog_type;
 	bool owner_jited;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	u32 n_entries;	/* number of entries in a handle array */
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	union {
 		char value[0] __aligned(8);
 		void *ptrs[0] __aligned(8);
@@ -194,6 +202,12 @@ struct bpf_array {
 	};
 };
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+struct map_landlock_handle {
+	u32 type; /* enum bpf_map_handle_type */
+};
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 #define MAX_TAIL_CALL_CNT 32
 
 struct bpf_event_entry {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 7cd36166f9b7..b68de57f7ab8 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -87,6 +87,15 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_PERCPU_ARRAY,
 	BPF_MAP_TYPE_STACK_TRACE,
 	BPF_MAP_TYPE_CGROUP_ARRAY,
+	BPF_MAP_TYPE_LANDLOCK_ARRAY,
+};
+
+enum bpf_map_array_type {
+	BPF_MAP_ARRAY_TYPE_UNSPEC,
+};
+
+enum bpf_map_handle_type {
+	BPF_MAP_HANDLE_TYPE_UNSPEC,
 };
 
 enum bpf_prog_type {
@@ -510,4 +519,13 @@ struct xdp_md {
 	__u32 data_end;
 };
 
+/* Map handle entry */
+struct landlock_handle {
+	__u32 type; /* enum bpf_map_handle_type */
+	union {
+		__u32 fd;
+		__aligned_u64 glob;
+	};
+} __attribute__((aligned(8)));
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index a2ac051c342f..94256597eacd 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -16,6 +16,13 @@
 #include <linux/mm.h>
 #include <linux/filter.h>
 #include <linux/perf_event.h>
+#include <linux/file.h> /* fput() */
+#include <linux/fs.h> /* struct file */
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+#include <asm/resource.h> /* RLIMIT_NOFILE */
+#include <linux/sched.h> /* rlimit() */
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
 static void bpf_array_free_percpu(struct bpf_array *array)
 {
@@ -580,3 +587,199 @@ static int __init register_cgroup_array_map(void)
 }
 late_initcall(register_cgroup_array_map);
 #endif
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+static struct bpf_map *landlock_array_map_alloc(union bpf_attr *attr)
+{
+	if (attr->value_size != sizeof(struct landlock_handle))
+		return ERR_PTR(-EINVAL);
+	attr->value_size = sizeof(struct map_landlock_handle);
+
+	return array_map_alloc(attr);
+}
+
+static void landlock_put_handle(struct map_landlock_handle *handle)
+{
+	enum bpf_map_handle_type handle_type = handle->type;
+
+	switch (handle_type) {
+	case BPF_MAP_HANDLE_TYPE_UNSPEC:
+	default:
+		WARN_ON(1);
+	}
+	/* safeguard */
+	handle->type = BPF_MAP_HANDLE_TYPE_UNSPEC;
+}
+
+static void landlock_array_map_free(struct bpf_map *map)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	int i;
+
+	synchronize_rcu();
+
+	for (i = 0; i < array->n_entries; i++)
+		landlock_put_handle((struct map_landlock_handle *)
+				(array->value + array->elem_size * i));
+	kvfree(array);
+}
+
+static enum bpf_map_array_type landlock_get_array_type(
+		enum bpf_map_handle_type handle_type)
+{
+	switch (handle_type) {
+	case BPF_MAP_HANDLE_TYPE_UNSPEC:
+	default:
+		return -EINVAL;
+	}
+}
+
+#define FGET_OR_RET(file, fd) { \
+	file = fget(fd); \
+	if (unlikely(IS_ERR(file))) \
+		return PTR_ERR(file); \
+	}
+
+/**
+ * landlock_store_handle - store an user handle in an arraymap entry
+ *
+ * @dst: non-NULL kernel-side Landlock handle destination
+ * @handle: non-NULL user-side Landlock handle source
+ */
+static inline long landlock_store_handle(struct map_landlock_handle *dst,
+		struct landlock_handle *handle)
+{
+	enum bpf_map_handle_type handle_type = handle->type;
+
+	switch (handle_type) {
+	case BPF_MAP_HANDLE_TYPE_UNSPEC:
+	default:
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	dst->type = handle_type;
+	return 0;
+}
+
+static void *nop_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+/* called from syscall or from eBPF program */
+static int landlock_array_map_update_elem(struct bpf_map *map, void *key,
+		void *value, u64 map_flags)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+	enum bpf_map_array_type array_type;
+	int ret;
+	struct landlock_handle *khandle = (struct landlock_handle *)value;
+	struct map_landlock_handle *handle, handle_new;
+
+	if (unlikely(map_flags > BPF_EXIST))
+		/* unknown flags */
+		return -EINVAL;
+
+	/*
+	 * Limit number of entries in an arraymap of handles to the maximum
+	 * number of open files for the current process. The maximum number of
+	 * handle entries (including all arraymaps) for a process is then
+	 * (RLIMIT_NOFILE - 1) * RLIMIT_NOFILE. If the process' RLIMIT_NOFILE
+	 * is 0, then any entry update is forbidden.
+	 *
+	 * An eBPF program can inherit all the arraymap FD. The worse case is
+	 * to fill a bunch of arraymaps, create an eBPF program, close the
+	 * arraymap FDs, and start again. The maximum number of arraymap
+	 * entries can then be close to RLIMIT_NOFILE^3.
+	 *
+	 * FIXME: This should be improved... any idea?
+	 */
+	if (unlikely(index >= rlimit(RLIMIT_NOFILE)))
+		return -EMFILE;
+
+	if (unlikely(index >= array->map.max_entries))
+		/* all elements were pre-allocated, cannot insert a new one */
+		return -E2BIG;
+
+	/* FIXME: add lock */
+	if (unlikely(index > array->n_entries))
+		/* only replace an existing entry or append a new one */
+		return -EINVAL;
+
+	/* TODO: handle all flags, not only BPF_ANY */
+	if (unlikely(map_flags == BPF_NOEXIST))
+		/* all elements already exist */
+		return -EEXIST;
+
+	if (unlikely(!khandle))
+		return -EINVAL;
+
+	array_type = landlock_get_array_type(khandle->type);
+	if (array_type < 0)
+		return array_type;
+
+	if (!map->map_array_type) {
+		/* set the initial set type */
+		map->map_array_type = array_type;
+	} else if (map->map_array_type != array_type) {
+		return -EINVAL;
+	}
+
+	ret = landlock_store_handle(&handle_new, khandle);
+	if (!ret) {
+		/* map->value_size == sizeof(struct map_landlock_handle) */
+		handle = (struct map_landlock_handle *)
+			(array->value + array->elem_size * index);
+		/* FIXME: make atomic update */
+		if (index < array->n_entries)
+			landlock_put_handle(handle);
+		*handle = handle_new;
+		/* TODO: use atomic_inc? */
+		if (index == array->n_entries)
+			array->n_entries++;
+	}
+	/* FIXME: unlock */
+
+	return ret;
+}
+
+/* called from syscall or from eBPF program */
+static int landlock_array_map_delete_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+
+	/* only remove the last element */
+	/* TODO: use atomic_dec? */
+	if (array->n_entries && index == array->n_entries - 1) {
+		array->n_entries--;
+		landlock_put_handle((struct map_landlock_handle *)
+				(array->value + array->elem_size * index));
+		return 0;
+	}
+	return -EINVAL;
+}
+
+static const struct bpf_map_ops landlock_array_ops = {
+	.map_alloc = landlock_array_map_alloc,
+	.map_free = landlock_array_map_free,
+	.map_get_next_key = array_map_get_next_key,
+	.map_lookup_elem = nop_map_lookup_elem,
+	.map_update_elem = landlock_array_map_update_elem,
+	.map_delete_elem = landlock_array_map_delete_elem,
+};
+
+static struct bpf_map_type_list landlock_array_type __read_mostly = {
+	.ops = &landlock_array_ops,
+	.type = BPF_MAP_TYPE_LANDLOCK_ARRAY,
+};
+
+static int __init register_landlock_array_map(void)
+{
+	bpf_register_map_type(&landlock_array_type);
+	return 0;
+}
+
+late_initcall(register_landlock_array_map);
+#endif /* CONFIG_SECURITY_LANDLOCK */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d5d28758d04c..c0c4a92dae8c 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1793,6 +1793,15 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
 	return (struct bpf_map *) (unsigned long) imm64;
 }
 
+static inline enum bpf_reg_type bpf_reg_type_from_map(struct bpf_map *map)
+{
+	switch (map->map_array_type) {
+	case BPF_MAP_ARRAY_TYPE_UNSPEC:
+	default:
+		return CONST_PTR_TO_MAP;
+	}
+}
+
 /* verify BPF_LD_IMM64 instruction */
 static int check_ld_imm(struct verifier_env *env, struct bpf_insn *insn)
 {
@@ -1819,8 +1828,9 @@ static int check_ld_imm(struct verifier_env *env, struct bpf_insn *insn)
 	/* replace_map_fd_with_map_ptr() should have caught bad ld_imm64 */
 	BUG_ON(insn->src_reg != BPF_PSEUDO_MAP_FD);
 
-	regs[insn->dst_reg].type = CONST_PTR_TO_MAP;
 	regs[insn->dst_reg].map_ptr = ld_imm64_to_map_ptr(insn);
+	regs[insn->dst_reg].type =
+		bpf_reg_type_from_map(regs[insn->dst_reg].map_ptr);
 	return 0;
 }
 
-- 
2.9.3
