From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v6 3/5] security: bpf: Add LSM hooks for bpf object related syscall
Date: Mon, 16 Oct 2017 12:11:33 -0700
Message-ID: <20171016191135.8046-4-chenbofeng.kernel@gmail.com>
References: <20171016191135.8046-1-chenbofeng.kernel@gmail.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20171016191135.8046-1-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chenbo Feng <fengc@google.com>

Introduce several LSM hooks for the syscalls that will allow the
userspace to access to eBPF object such as eBPF programs and eBPF maps.
The security check is aimed to enforce a per object security protection
for eBPF object so only processes with the right priviliges can
read/write to a specific map or use a specific eBPF program. Besides
that, a general security hook is added before the multiplexer of bpf
syscall to check the cmd and the attribute used for the command. The
actual security module can decide which command need to be checked and
how the cmd should be checked.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 include/linux/bpf.h       |  6 ++++++
 include/linux/lsm_hooks.h | 54 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/security.h  | 45 +++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c      | 34 +++++++++++++++++++++++++++--
 security/security.c       | 32 ++++++++++++++++++++++++++++
 5 files changed, 169 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index efbde1639970..1479442d5293 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -57,6 +57,9 @@ struct bpf_map {
 	atomic_t usercnt;
 	struct bpf_map *inner_map_meta;
 	char name[BPF_OBJ_NAME_LEN];
+#ifdef CONFIG_SECURITY
+	void *security;
+#endif
 };
 
 /* function argument constraints */
@@ -190,6 +193,9 @@ struct bpf_prog_aux {
 	struct user_struct *user;
 	u64 load_time; /* ns since boottime */
 	char name[BPF_OBJ_NAME_LEN];
+#ifdef CONFIG_SECURITY
+	void *security;
+#endif
 	union {
 		struct work_struct work;
 		struct rcu_head	rcu;
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index c9258124e417..7161d8e7ee79 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1351,6 +1351,40 @@
  *	@inode we wish to get the security context of.
  *	@ctx is a pointer in which to place the allocated security context.
  *	@ctxlen points to the place to put the length of @ctx.
+ *
+ * Security hooks for using the eBPF maps and programs functionalities through
+ * eBPF syscalls.
+ *
+ * @bpf:
+ *	Do a initial check for all bpf syscalls after the attribute is copied
+ *	into the kernel. The actual security module can implement their own
+ *	rules to check the specific cmd they need.
+ *
+ * @bpf_map:
+ *	Do a check when the kernel generate and return a file descriptor for
+ *	eBPF maps.
+ *
+ *	@map: bpf map that we want to access
+ *	@mask: the access flags
+ *
+ * @bpf_prog:
+ *	Do a check when the kernel generate and return a file descriptor for
+ *	eBPF programs.
+ *
+ *	@prog: bpf prog that userspace want to use.
+ *
+ * @bpf_map_alloc_security:
+ *	Initialize the security field inside bpf map.
+ *
+ * @bpf_map_free_security:
+ *	Clean up the security information stored inside bpf map.
+ *
+ * @bpf_prog_alloc_security:
+ *	Initialize the security field inside bpf program.
+ *
+ * @bpf_prog_free_security:
+ *	Clean up the security information stored inside bpf prog.
+ *
  */
 union security_list_options {
 	int (*binder_set_context_mgr)(struct task_struct *mgr);
@@ -1682,6 +1716,17 @@ union security_list_options {
 				struct audit_context *actx);
 	void (*audit_rule_free)(void *lsmrule);
 #endif /* CONFIG_AUDIT */
+
+#ifdef CONFIG_BPF_SYSCALL
+	int (*bpf)(int cmd, union bpf_attr *attr,
+				 unsigned int size);
+	int (*bpf_map)(struct bpf_map *map, fmode_t fmode);
+	int (*bpf_prog)(struct bpf_prog *prog);
+	int (*bpf_map_alloc_security)(struct bpf_map *map);
+	void (*bpf_map_free_security)(struct bpf_map *map);
+	int (*bpf_prog_alloc_security)(struct bpf_prog_aux *aux);
+	void (*bpf_prog_free_security)(struct bpf_prog_aux *aux);
+#endif /* CONFIG_BPF_SYSCALL */
 };
 
 struct security_hook_heads {
@@ -1901,6 +1946,15 @@ struct security_hook_heads {
 	struct list_head audit_rule_match;
 	struct list_head audit_rule_free;
 #endif /* CONFIG_AUDIT */
+#ifdef CONFIG_BPF_SYSCALL
+	struct list_head bpf;
+	struct list_head bpf_map;
+	struct list_head bpf_prog;
+	struct list_head bpf_map_alloc_security;
+	struct list_head bpf_map_free_security;
+	struct list_head bpf_prog_alloc_security;
+	struct list_head bpf_prog_free_security;
+#endif /* CONFIG_BPF_SYSCALL */
 } __randomize_layout;
 
 /*
diff --git a/include/linux/security.h b/include/linux/security.h
index ce6265960d6c..18800b0911e5 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -31,6 +31,7 @@
 #include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
+#include <linux/bpf.h>
 
 struct linux_binprm;
 struct cred;
@@ -1730,6 +1731,50 @@ static inline void securityfs_remove(struct dentry *dentry)
 
 #endif
 
+#ifdef CONFIG_BPF_SYSCALL
+#ifdef CONFIG_SECURITY
+extern int security_bpf(int cmd, union bpf_attr *attr, unsigned int size);
+extern int security_bpf_map(struct bpf_map *map, fmode_t fmode);
+extern int security_bpf_prog(struct bpf_prog *prog);
+extern int security_bpf_map_alloc(struct bpf_map *map);
+extern void security_bpf_map_free(struct bpf_map *map);
+extern int security_bpf_prog_alloc(struct bpf_prog_aux *aux);
+extern void security_bpf_prog_free(struct bpf_prog_aux *aux);
+#else
+static inline int security_bpf(int cmd, union bpf_attr *attr,
+					     unsigned int size)
+{
+	return 0;
+}
+
+static inline int security_bpf_map(struct bpf_map *map, fmode_t fmode)
+{
+	return 0;
+}
+
+static inline int security_bpf_prog(struct bpf_prog *prog)
+{
+	return 0;
+}
+
+static inline int security_bpf_map_alloc(struct bpf_map *map)
+{
+	return 0;
+}
+
+static inline void security_bpf_map_free(struct bpf_map *map)
+{ }
+
+static inline int security_bpf_prog_alloc(struct bpf_prog_aux *aux)
+{
+	return 0;
+}
+
+static inline void security_bpf_prog_free(struct bpf_prog_aux *aux)
+{ }
+#endif /* CONFIG_SECURITY */
+#endif /* CONFIG_BPF_SYSCALL */
+
 #ifdef CONFIG_SECURITY
 
 static inline char *alloc_secdata(void)
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index b02582ead9a4..d3e152e282d8 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -210,6 +210,7 @@ static void bpf_map_free_deferred(struct work_struct *work)
 	struct bpf_map *map = container_of(work, struct bpf_map, work);
 
 	bpf_map_uncharge_memlock(map);
+	security_bpf_map_free(map);
 	/* implementation dependent freeing */
 	map->ops->map_free(map);
 }
@@ -323,6 +324,12 @@ static const struct file_operations bpf_map_fops = {
 
 int bpf_map_new_fd(struct bpf_map *map, int flags)
 {
+	int ret;
+
+	ret = security_bpf_map(map, OPEN_FMODE(flags));
+	if (ret < 0)
+		return ret;
+
 	return anon_inode_getfd("bpf-map", &bpf_map_fops, map,
 				flags | O_CLOEXEC);
 }
@@ -403,10 +410,14 @@ static int map_create(union bpf_attr *attr)
 	atomic_set(&map->refcnt, 1);
 	atomic_set(&map->usercnt, 1);
 
-	err = bpf_map_charge_memlock(map);
+	err = security_bpf_map_alloc(map);
 	if (err)
 		goto free_map_nouncharge;
 
+	err = bpf_map_charge_memlock(map);
+	if (err)
+		goto free_map_sec;
+
 	err = bpf_map_alloc_id(map);
 	if (err)
 		goto free_map;
@@ -428,6 +439,8 @@ static int map_create(union bpf_attr *attr)
 
 free_map:
 	bpf_map_uncharge_memlock(map);
+free_map_sec:
+	security_bpf_map_free(map);
 free_map_nouncharge:
 	map->ops->map_free(map);
 	return err;
@@ -906,6 +919,7 @@ static void __bpf_prog_put_rcu(struct rcu_head *rcu)
 
 	free_used_maps(aux);
 	bpf_prog_uncharge_memlock(aux->prog);
+	security_bpf_prog_free(aux);
 	bpf_prog_free(aux->prog);
 }
 
@@ -964,6 +978,12 @@ static const struct file_operations bpf_prog_fops = {
 
 int bpf_prog_new_fd(struct bpf_prog *prog)
 {
+	int ret;
+
+	ret = security_bpf_prog(prog);
+	if (ret < 0)
+		return ret;
+
 	return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog,
 				O_RDWR | O_CLOEXEC);
 }
@@ -1103,10 +1123,14 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (!prog)
 		return -ENOMEM;
 
-	err = bpf_prog_charge_memlock(prog);
+	err = security_bpf_prog_alloc(prog->aux);
 	if (err)
 		goto free_prog_nouncharge;
 
+	err = bpf_prog_charge_memlock(prog);
+	if (err)
+		goto free_prog_sec;
+
 	prog->len = attr->insn_cnt;
 
 	err = -EFAULT;
@@ -1164,6 +1188,8 @@ static int bpf_prog_load(union bpf_attr *attr)
 	free_used_maps(prog->aux);
 free_prog:
 	bpf_prog_uncharge_memlock(prog);
+free_prog_sec:
+	security_bpf_prog_free(prog->aux);
 free_prog_nouncharge:
 	bpf_prog_free(prog);
 	return err;
@@ -1630,6 +1656,10 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	if (copy_from_user(&attr, uattr, size) != 0)
 		return -EFAULT;
 
+	err = security_bpf(cmd, &attr, size);
+	if (err < 0)
+		return err;
+
 	switch (cmd) {
 	case BPF_MAP_CREATE:
 		err = map_create(&attr);
diff --git a/security/security.c b/security/security.c
index 4bf0f571b4ef..1cd8526cb0b7 100644
--- a/security/security.c
+++ b/security/security.c
@@ -12,6 +12,7 @@
  *	(at your option) any later version.
  */
 
+#include <linux/bpf.h>
 #include <linux/capability.h>
 #include <linux/dcache.h>
 #include <linux/module.h>
@@ -1703,3 +1704,34 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
 				actx);
 }
 #endif /* CONFIG_AUDIT */
+
+#ifdef CONFIG_BPF_SYSCALL
+int security_bpf(int cmd, union bpf_attr *attr, unsigned int size)
+{
+	return call_int_hook(bpf, 0, cmd, attr, size);
+}
+int security_bpf_map(struct bpf_map *map, fmode_t fmode)
+{
+	return call_int_hook(bpf_map, 0, map, fmode);
+}
+int security_bpf_prog(struct bpf_prog *prog)
+{
+	return call_int_hook(bpf_prog, 0, prog);
+}
+int security_bpf_map_alloc(struct bpf_map *map)
+{
+	return call_int_hook(bpf_map_alloc_security, 0, map);
+}
+int security_bpf_prog_alloc(struct bpf_prog_aux *aux)
+{
+	return call_int_hook(bpf_prog_alloc_security, 0, aux);
+}
+void security_bpf_map_free(struct bpf_map *map)
+{
+	call_void_hook(bpf_map_free_security, map);
+}
+void security_bpf_prog_free(struct bpf_prog_aux *aux)
+{
+	call_void_hook(bpf_prog_free_security, aux);
+}
+#endif /* CONFIG_BPF_SYSCALL */
-- 
2.15.0.rc0.271.g36b669edcc-goog

