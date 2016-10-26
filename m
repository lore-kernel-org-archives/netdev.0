From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v4 03/18] bpf,landlock: Add a new arraymap type to deal with (Landlock) handles
Date: Wed, 26 Oct 2016 08:56:39 +0200
Message-ID: <20161026065654.19166-4-mic@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        cgroups@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-5019-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161026065654.19166-1-mic@digikod.net>
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

Changes since v3:
* make handle arraymap safe (RCU) and remove buggy synchronize_rcu()
* factor out the arraymay walk

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
 include/linux/bpf.h      |  24 +++++
 include/uapi/linux/bpf.h |  21 ++++
 kernel/bpf/arraymap.c    | 270 +++++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/verifier.c    |  20 +++-
 4 files changed, 334 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index cf87db6daf27..34b9e9cd1af7 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -13,6 +13,11 @@
 #include <linux/percpu.h>
 #include <linux/err.h>
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+#include <linux/fs.h> /* struct file */
+#include <linux/spinlock_types.h> /* spinlock_t */
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 struct perf_event;
 struct bpf_map;
 
@@ -38,6 +43,7 @@ struct bpf_map_ops {
 struct bpf_map {
 	atomic_t refcnt;
 	enum bpf_map_type map_type;
+	enum bpf_map_array_type map_array_type;
 	u32 key_size;
 	u32 value_size;
 	u32 max_entries;
@@ -80,6 +86,8 @@ enum bpf_arg_type {
 
 	ARG_PTR_TO_CTX,		/* pointer to context */
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
+
+	ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS,	/* pointer to Landlock FS map handle */
 };
 
 /* type of values returned from helper functions */
@@ -146,6 +154,9 @@ enum bpf_reg_type {
 	 * map element.
 	 */
 	PTR_TO_MAP_VALUE_ADJ,
+
+	/* Landlock */
+	CONST_PTR_TO_LANDLOCK_HANDLE_FS,
 };
 
 struct bpf_prog;
@@ -196,6 +207,10 @@ struct bpf_array {
 	 */
 	enum bpf_prog_type owner_prog_type;
 	bool owner_jited;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	atomic_t n_entries;	/* number of entries in a handle array */
+	raw_spinlock_t update;	/* protect n_entries consistency */
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	union {
 		char value[0] __aligned(8);
 		void *ptrs[0] __aligned(8);
@@ -203,6 +218,15 @@ struct bpf_array {
 	};
 };
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+struct map_landlock_handle {
+	u32 type; /* enum bpf_map_handle_type */
+	union {
+		struct path path;
+	};
+};
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 #define MAX_TAIL_CALL_CNT 32
 
 struct bpf_event_entry {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f31b655f93cf..339a9307ba6e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -87,6 +87,18 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_PERCPU_ARRAY,
 	BPF_MAP_TYPE_STACK_TRACE,
 	BPF_MAP_TYPE_CGROUP_ARRAY,
+	BPF_MAP_TYPE_LANDLOCK_ARRAY,
+};
+
+enum bpf_map_array_type {
+	BPF_MAP_ARRAY_TYPE_UNSPEC,
+	BPF_MAP_ARRAY_TYPE_LANDLOCK_FS,
+};
+
+enum bpf_map_handle_type {
+	BPF_MAP_HANDLE_TYPE_UNSPEC,
+	BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD,
+	/* BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_GLOB, */
 };
 
 enum bpf_prog_type {
@@ -538,4 +550,13 @@ struct xdp_md {
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
index a2ac051c342f..3d045ee71eef 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -16,6 +16,15 @@
 #include <linux/mm.h>
 #include <linux/filter.h>
 #include <linux/perf_event.h>
+#include <linux/file.h> /* fput() */
+#include <linux/fs.h> /* struct file */
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+#include <asm/resource.h> /* RLIMIT_NOFILE */
+#include <linux/mount.h> /* struct vfsmount, MNT_INTERNAL */
+#include <linux/path.h> /* path_get(), path_put() */
+#include <linux/sched.h> /* rlimit() */
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
 static void bpf_array_free_percpu(struct bpf_array *array)
 {
@@ -89,6 +98,10 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	array->map.value_size = attr->value_size;
 	array->map.max_entries = attr->max_entries;
 	array->elem_size = elem_size;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	atomic_set(&array->n_entries, 0);
+	raw_spin_lock_init(&array->update);
+#endif /* CONFIG_SECURITY_LANDLOCK */
 
 	if (!percpu)
 		goto out;
@@ -580,3 +593,260 @@ static int __init register_cgroup_array_map(void)
 }
 late_initcall(register_cgroup_array_map);
 #endif
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+
+static struct bpf_map *landlock_array_map_alloc(union bpf_attr *attr)
+{
+	if (attr->value_size != sizeof(struct landlock_handle))
+		return ERR_PTR(-EINVAL);
+	/* XXX: FD arraymap works because elem_size = round_up(attr->value_size, 8) */
+	/* XXX: do we want memory with GFP_USER? */
+	return array_map_alloc(attr);
+}
+
+static void landlock_free_handle(struct map_landlock_handle *handle)
+{
+	enum bpf_map_handle_type handle_type;
+
+	if (WARN_ON(!handle))
+		return;
+	handle_type = handle->type;
+
+	switch (handle_type) {
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
+		path_put(&handle->path);
+		break;
+	case BPF_MAP_HANDLE_TYPE_UNSPEC:
+	default:
+		WARN_ON(1);
+	}
+	kfree(handle);
+}
+
+/* called when map->refcnt goes to zero, either from workqueue or from syscall */
+static void landlock_array_map_free(struct bpf_map *map)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct map_landlock_handle **handle;
+	size_t i;
+
+	/* wait for all eBPF programs to complete before freeing the map */
+	synchronize_rcu();
+
+	for (i = 0, handle = (struct map_landlock_handle **) array->value;
+			i < atomic_read(&array->n_entries);
+			i++, handle = (struct map_landlock_handle **)
+			(array->value + array->elem_size * i)) {
+		landlock_free_handle(*handle);
+	}
+	kvfree(array);
+}
+
+static enum bpf_map_array_type landlock_get_array_type(
+		enum bpf_map_handle_type handle_type)
+{
+	switch (handle_type) {
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
+		return BPF_MAP_ARRAY_TYPE_LANDLOCK_FS;
+	case BPF_MAP_HANDLE_TYPE_UNSPEC:
+	default:
+		return -EINVAL;
+	}
+}
+
+/**
+ * landlock_new_handle - store an user handle in an arraymap entry
+ *
+ * @handle: non-NULL user-side Landlock handle source
+ *
+ * Return a new Landlock handle
+ */
+static inline struct map_landlock_handle *landlock_new_handle(
+		struct landlock_handle *handle)
+{
+	enum bpf_map_handle_type handle_type = handle->type;
+	struct file *handle_file;
+	struct map_landlock_handle *ret;
+
+	/* access control already done for the FD */
+
+	switch (handle_type) {
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
+		handle_file = fget(handle->fd);
+		if (IS_ERR(handle_file))
+			return ERR_CAST(handle_file);
+		/* check if the FD is tied to a user mount point */
+		if (unlikely(handle_file->f_path.mnt->mnt_flags & MNT_INTERNAL)) {
+			fput(handle_file);
+			return ERR_PTR(-EINVAL);
+		}
+		path_get(&handle_file->f_path);
+		ret = kmalloc(sizeof(*ret), GFP_KERNEL);
+		ret->path = handle_file->f_path;
+		fput(handle_file);
+		break;
+	case BPF_MAP_HANDLE_TYPE_UNSPEC:
+	default:
+		return ERR_PTR(-EINVAL);
+	}
+	ret->type = handle_type;
+	return ret;
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
+	int ret, n_entries;
+	struct landlock_handle *khandle = (struct landlock_handle *)value;
+	struct map_landlock_handle **handle_ref, *handle_old, *handle_new;
+	unsigned long flags;
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
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	/* bpf_map_update_elem() can be called in_irq() */
+	raw_spin_lock_irqsave(&array->update, flags);
+	n_entries = atomic_read(&array->n_entries);
+
+	if (unlikely(index > n_entries)) {
+		/* only replace an existing entry or append a new one */
+		ret = -EINVAL;
+		goto err;
+	}
+
+	handle_new = landlock_new_handle(khandle);
+	if (IS_ERR(handle_new)) {
+		ret = PTR_ERR(handle_new);
+		goto err;
+	}
+
+	handle_ref = (struct map_landlock_handle **)
+		(array->value + array->elem_size * index);
+	handle_old = xchg(handle_ref, handle_new);
+	if (index == n_entries)
+		atomic_inc(&array->n_entries);
+	raw_spin_unlock_irqrestore(&array->update, flags);
+
+	if (index != n_entries) {
+		synchronize_rcu();
+		landlock_free_handle(handle_old);
+	}
+	return 0;
+
+err:
+	raw_spin_unlock_irqrestore(&array->update, flags);
+	return ret;
+}
+
+/* called from syscall or from eBPF program */
+static int landlock_array_map_delete_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+	struct map_landlock_handle *handle_old, **handle_ref;
+	unsigned long flags;
+	int n_entries;
+
+	if (unlikely(index >= array->map.max_entries))
+		return -E2BIG;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	/* bpf_map_delete_elem() can be called in_irq() */
+	raw_spin_lock_irqsave(&array->update, flags);
+	n_entries = atomic_read(&array->n_entries);
+
+	/* only delete the last element: forbid holes in the array */
+	if (!n_entries || index != (n_entries - 1))
+		goto err;
+
+	atomic_dec(&array->n_entries);
+	handle_ref = (struct map_landlock_handle **)
+		(array->value + array->elem_size * index);
+	handle_old = xchg(handle_ref, NULL);
+	raw_spin_unlock_irqrestore(&array->update, flags);
+
+	synchronize_rcu();
+	landlock_free_handle(handle_old);
+	return 0;
+
+err:
+	raw_spin_unlock_irqrestore(&array->update, flags);
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
index 99a7e5b388f2..1bc7701466b0 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -188,6 +188,7 @@ static const char * const reg_type_str[] = {
 	[CONST_IMM]		= "imm",
 	[PTR_TO_PACKET]		= "pkt",
 	[PTR_TO_PACKET_END]	= "pkt_end",
+	[CONST_PTR_TO_LANDLOCK_HANDLE_FS] = "landlock_handle_fs",
 };
 
 static void print_verifier_state(struct bpf_verifier_state *state)
@@ -513,6 +514,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case PTR_TO_PACKET_END:
 	case FRAME_PTR:
 	case CONST_PTR_TO_MAP:
+	case CONST_PTR_TO_LANDLOCK_HANDLE_FS:
 		return true;
 	default:
 		return false;
@@ -973,6 +975,10 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		expected_type = PTR_TO_CTX;
 		if (type != expected_type)
 			goto err_type;
+	} else if (arg_type == ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS) {
+		expected_type = CONST_PTR_TO_LANDLOCK_HANDLE_FS;
+		if (type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_PTR_TO_STACK ||
 		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
@@ -2031,6 +2037,17 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
 	return (struct bpf_map *) (unsigned long) imm64;
 }
 
+static inline enum bpf_reg_type bpf_reg_type_from_map(struct bpf_map *map)
+{
+	switch (map->map_array_type) {
+	case BPF_MAP_ARRAY_TYPE_LANDLOCK_FS:
+		return CONST_PTR_TO_LANDLOCK_HANDLE_FS;
+	case BPF_MAP_ARRAY_TYPE_UNSPEC:
+	default:
+		return CONST_PTR_TO_MAP;
+	}
+}
+
 /* verify BPF_LD_IMM64 instruction */
 static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 {
@@ -2067,8 +2084,9 @@ static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
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
