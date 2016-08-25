From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 03/10] bpf,landlock: Add a new arraymap type to deal with (Landlock) handles
Date: Thu, 25 Aug 2016 12:32:38 +0200
Message-ID: <1472121165-29071-4-git-send-email-mic@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
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
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4456-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
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

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
---
 include/linux/bpf.h      |  18 +++++
 include/uapi/linux/bpf.h |  18 +++++
 kernel/bpf/arraymap.c    | 181 +++++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c     |   9 ++-
 kernel/bpf/verifier.c    |  12 +++-
 5 files changed, 235 insertions(+), 3 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index ca3742729ae7..9a5b388be099 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -12,6 +12,10 @@
 #include <linux/file.h>
 #include <linux/percpu.h>
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+#include <linux/fs.h> /* struct file */
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 struct bpf_map;
 
 /* map is generic key/value storage optionally accesible by eBPF programs */
@@ -34,6 +38,7 @@ struct bpf_map_ops {
 struct bpf_map {
 	atomic_t refcnt;
 	enum bpf_map_type map_type;
+	enum bpf_map_array_type map_array_type;
 	u32 key_size;
 	u32 value_size;
 	u32 max_entries;
@@ -183,12 +188,25 @@ struct bpf_array {
 	 */
 	enum bpf_prog_type owner_prog_type;
 	bool owner_jited;
+#ifdef CONFIG_SECURITY_LANDLOCK
+	u32 n_entries;	/* number of entries in a handle array */
+#endif /* CONFIG_SECURITY_LANDLOCK */
 	union {
 		char value[0] __aligned(8);
 		void *ptrs[0] __aligned(8);
 		void __percpu *pptrs[0] __aligned(8);
 	};
 };
+
+#ifdef CONFIG_SECURITY_LANDLOCK
+struct map_landlock_handle {
+	u32 type;
+	union {
+		struct file *file;
+	};
+};
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 #define MAX_TAIL_CALL_CNT 32
 
 u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 406459b935a2..a60eedc17d40 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -84,6 +84,15 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_PERCPU_HASH,
 	BPF_MAP_TYPE_PERCPU_ARRAY,
 	BPF_MAP_TYPE_STACK_TRACE,
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
@@ -386,4 +395,13 @@ struct bpf_tunnel_key {
 	__u32 tunnel_label;
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
index 76d5a794e426..5938b8ee475b 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -16,6 +16,8 @@
 #include <linux/mm.h>
 #include <linux/filter.h>
 #include <linux/perf_event.h>
+#include <linux/file.h> /* fput() */
+#include <linux/fs.h> /* struct file */
 
 static void bpf_array_free_percpu(struct bpf_array *array)
 {
@@ -491,3 +493,182 @@ static int __init register_perf_event_array_map(void)
 	return 0;
 }
 late_initcall(register_perf_event_array_map);
+
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
+	switch (handle->type) {
+		/* TODO: add handle types */
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
+		/* TODO: add handle types */
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
+static inline long landlock_store_handle(struct map_landlock_handle *dst,
+		struct landlock_handle *khandle)
+{
+	struct path kpath;
+
+	if (unlikely(!khandle))
+		return -EINVAL;
+
+	/* access control already done for the FD */
+
+	switch (khandle->type) {
+		/* TODO: add handle types */
+	default:
+		WARN_ON(1);
+		path_put(&kpath);
+		return -EINVAL;
+	}
+	dst->type = khandle->type;
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
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index d305a3ce0fa7..32a10ef4b878 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -717,8 +717,13 @@ static int bpf_prog_load(union bpf_attr *attr)
 	    attr->kern_version != LINUX_VERSION_CODE)
 		return -EINVAL;
 
-	if (type != BPF_PROG_TYPE_SOCKET_FILTER && !capable(CAP_SYS_ADMIN))
-		return -EPERM;
+	switch (type) {
+	case BPF_PROG_TYPE_SOCKET_FILTER:
+		break;
+	default:
+		if (!capable(CAP_SYS_ADMIN))
+			return -EPERM;
+	}
 
 	/* plain bpf_prog allocation */
 	prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index eec9f90ba030..c15f6cc28e00 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1716,6 +1716,15 @@ static struct bpf_map *ld_imm64_to_map_ptr(struct bpf_insn *insn)
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
@@ -1742,8 +1751,9 @@ static int check_ld_imm(struct verifier_env *env, struct bpf_insn *insn)
 	/* replace_map_fd_with_map_ptr() should have caught bad ld_imm64 */
 	BUG_ON(insn->src_reg != BPF_PSEUDO_MAP_FD);
 
-	regs[insn->dst_reg].type = CONST_PTR_TO_MAP;
 	regs[insn->dst_reg].map_ptr = ld_imm64_to_map_ptr(insn);
+	regs[insn->dst_reg].type =
+		bpf_reg_type_from_map(regs[insn->dst_reg].map_ptr);
 	return 0;
 }
 
-- 
2.8.1
