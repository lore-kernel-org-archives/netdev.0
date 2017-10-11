From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v3 5/5] selinux: bpf: Add addtional check for bpf object file receive
Date: Tue, 10 Oct 2017 17:09:30 -0700
Message-ID: <20171011000930.133308-6-chenbofeng.kernel@gmail.com>
References: <20171011000930.133308-1-chenbofeng.kernel@gmail.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Chenbo Feng <fengc@google.com>
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20171011000930.133308-1-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chenbo Feng <fengc@google.com>

Introduce a bpf object related check when sending and receiving files
through unix domain socket as well as binder. It checks if the receiving
process have privilege to read/write the bpf map or use the bpf program.
This check is necessary because the bpf maps and programs are using a
anonymous inode as their shared inode so the normal way of checking the
files and sockets when passing between processes cannot work properly on
eBPF object. This check only works when the BPF_SYSCALL is configured.
The information stored inside the file security struct is the same as
the information in bpf object security struct.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 include/linux/lsm_hooks.h         | 17 ++++++++++
 include/linux/security.h          |  9 ++++++
 kernel/bpf/syscall.c              | 27 ++++++++++++++--
 security/security.c               |  8 +++++
 security/selinux/hooks.c          | 67 +++++++++++++++++++++++++++++++++++++++
 security/selinux/include/objsec.h |  9 ++++++
 6 files changed, 135 insertions(+), 2 deletions(-)

diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 7161d8e7ee79..517dea60b87b 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1385,6 +1385,19 @@
  * @bpf_prog_free_security:
  *	Clean up the security information stored inside bpf prog.
  *
+ * @bpf_map_file:
+ *	When creating a bpf map fd, set up the file security information with
+ *	the bpf security information stored in the map struct. So when the map
+ *	fd is passed between processes, the security module can directly read
+ *	the security information from file security struct rather than the bpf
+ *	security struct.
+ *
+ * @bpf_prog_file:
+ *	When creating a bpf prog fd, set up the file security information with
+ *	the bpf security information stored in the prog struct. So when the prog
+ *	fd is passed between processes, the security module can directly read
+ *	the security information from file security struct rather than the bpf
+ *	security struct.
  */
 union security_list_options {
 	int (*binder_set_context_mgr)(struct task_struct *mgr);
@@ -1726,6 +1739,8 @@ union security_list_options {
 	void (*bpf_map_free_security)(struct bpf_map *map);
 	int (*bpf_prog_alloc_security)(struct bpf_prog_aux *aux);
 	void (*bpf_prog_free_security)(struct bpf_prog_aux *aux);
+	void (*bpf_map_file)(struct bpf_map *map, struct file *file);
+	void (*bpf_prog_file)(struct bpf_prog_aux *aux, struct file *file);
 #endif /* CONFIG_BPF_SYSCALL */
 };
 
@@ -1954,6 +1969,8 @@ struct security_hook_heads {
 	struct list_head bpf_map_free_security;
 	struct list_head bpf_prog_alloc_security;
 	struct list_head bpf_prog_free_security;
+	struct list_head bpf_map_file;
+	struct list_head bpf_prog_file;
 #endif /* CONFIG_BPF_SYSCALL */
 } __randomize_layout;
 
diff --git a/include/linux/security.h b/include/linux/security.h
index 18800b0911e5..57573b794e2d 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1740,6 +1740,8 @@ extern int security_bpf_map_alloc(struct bpf_map *map);
 extern void security_bpf_map_free(struct bpf_map *map);
 extern int security_bpf_prog_alloc(struct bpf_prog_aux *aux);
 extern void security_bpf_prog_free(struct bpf_prog_aux *aux);
+extern void security_bpf_map_file(struct bpf_map *map, struct file *file);
+extern void security_bpf_prog_file(struct bpf_prog_aux *aux, struct file *file);
 #else
 static inline int security_bpf(int cmd, union bpf_attr *attr,
 					     unsigned int size)
@@ -1772,6 +1774,13 @@ static inline int security_bpf_prog_alloc(struct bpf_prog_aux *aux)
 
 static inline void security_bpf_prog_free(struct bpf_prog_aux *aux)
 { }
+
+static inline void security_bpf_map_file(struct bpf_map *map, struct file *file)
+{ }
+
+static inline void security_bpf_prog_file(struct bpf_prog_aux *aux,
+					  struct file *file)
+{ }
 #endif /* CONFIG_SECURITY */
 #endif /* CONFIG_BPF_SYSCALL */
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 1cf31ddd7616..aee69e564c50 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -324,11 +324,22 @@ static const struct file_operations bpf_map_fops = {
 
 int bpf_map_new_fd(struct bpf_map *map, int flags)
 {
+	int fd;
+	struct fd f;
 	if (security_bpf_map(map, OPEN_FMODE(flags)))
 		return -EPERM;
 
-	return anon_inode_getfd("bpf-map", &bpf_map_fops, map,
+	fd = anon_inode_getfd("bpf-map", &bpf_map_fops, map,
 				flags | O_CLOEXEC);
+	if (fd < 0)
+		return fd;
+
+	f = fdget(fd);
+	if (!f.file)
+		return -EBADF;
+	security_bpf_map_file(map, f.file);
+	fdput(f);
+	return fd;
 }
 
 int bpf_get_file_flag(int flags)
@@ -975,11 +986,23 @@ static const struct file_operations bpf_prog_fops = {
 
 int bpf_prog_new_fd(struct bpf_prog *prog)
 {
+	int fd;
+	struct fd f;
+
 	if (security_bpf_prog(prog))
 		return -EPERM;
 
-	return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog,
+	fd =  anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog,
 				O_RDWR | O_CLOEXEC);
+	if (fd < 0)
+		return fd;
+
+	f = fdget(fd);
+	if (!f.file)
+		return -EBADF;
+	security_bpf_prog_file(prog->aux, f.file);
+	fdput(f);
+	return fd;
 }
 
 static struct bpf_prog *____bpf_prog_get(struct fd f)
diff --git a/security/security.c b/security/security.c
index 1cd8526cb0b7..dacf649b8cfa 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1734,4 +1734,12 @@ void security_bpf_prog_free(struct bpf_prog_aux *aux)
 {
 	call_void_hook(bpf_prog_free_security, aux);
 }
+void security_bpf_map_file(struct bpf_map *map, struct file *file)
+{
+	call_void_hook(bpf_map_file, map, file);
+}
+void security_bpf_prog_file(struct bpf_prog_aux *aux, struct file *file)
+{
+	call_void_hook(bpf_prog_file, aux, file);
+}
 #endif /* CONFIG_BPF_SYSCALL */
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 94e473b9c884..0a6ef20513b0 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -1815,6 +1815,10 @@ static inline int file_path_has_perm(const struct cred *cred,
 	return inode_has_perm(cred, file_inode(file), av, &ad);
 }
 
+#ifdef CONFIG_BPF_SYSCALL
+static int bpf_file_check(struct file *file, u32 sid);
+#endif
+
 /* Check whether a task can use an open file descriptor to
    access an inode in a given way.  Check access to the
    descriptor itself, and then use dentry_has_perm to
@@ -1845,6 +1849,14 @@ static int file_has_perm(const struct cred *cred,
 			goto out;
 	}
 
+#ifdef CONFIG_BPF_SYSCALL
+	if (fsec->bpf_type) {
+		rc = bpf_file_check(file, cred_sid(cred));
+		if (rc)
+			goto out;
+	}
+#endif
+
 	/* av is zero if only checking access to the descriptor. */
 	rc = 0;
 	if (av)
@@ -2165,6 +2177,14 @@ static int selinux_binder_transfer_file(struct task_struct *from,
 			return rc;
 	}
 
+#ifdef CONFIG_BPF_SYSCALL
+	if (fsec->bpf_type) {
+		rc = bpf_file_check(file, sid);
+		if (rc)
+			return rc;
+	}
+#endif
+
 	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
 		return 0;
 
@@ -6288,6 +6308,33 @@ static u32 bpf_map_fmode_to_av(fmode_t fmode)
 	return av;
 }
 
+/* This function will check the file pass through unix socket or binder to see
+ * if it is a bpf related object. And apply correspinding checks on the bpf
+ * object based on the type. The bpf maps and programs, not like other files and
+ * socket, are using a shared anonymous inode inside the kernel as their inode.
+ * So checking that inode cannot identify if the process have privilege to
+ * access the bpf object and that's why we have to add this additional check in
+ * selinux_file_receive and selinux_binder_transfer_files.
+ */
+static int bpf_file_check(struct file *file, u32 sid)
+{
+	struct file_security_struct *fsec = file->f_security;
+	int ret;
+
+	if (fsec->bpf_type == BPF_MAP) {
+		ret = avc_has_perm(sid, fsec->bpf_sid, SECCLASS_BPF,
+				   bpf_map_fmode_to_av(file->f_mode), NULL);
+		if (ret)
+			return ret;
+	} else if (fsec->bpf_type == BPF_PROG) {
+		ret = avc_has_perm(sid, fsec->bpf_sid, SECCLASS_BPF,
+				   BPF__PROG_USE, NULL);
+		if (ret)
+			return ret;
+	}
+	return 0;
+}
+
 static int selinux_bpf_map(struct bpf_map *map, fmode_t fmode)
 {
 	u32 sid = current_sid();
@@ -6351,6 +6398,24 @@ static void selinux_bpf_prog_free(struct bpf_prog_aux *aux)
 	aux->security = NULL;
 	kfree(bpfsec);
 }
+
+static void selinux_bpf_map_file(struct bpf_map *map, struct file *file)
+{
+	struct bpf_security_struct *bpfsec = map->security;
+	struct file_security_struct *fsec = file->f_security;
+
+	fsec->bpf_type = BPF_MAP;
+	fsec->bpf_sid = bpfsec->sid;
+}
+
+static void selinux_bpf_prog_file(struct bpf_prog_aux *aux, struct file *file)
+{
+	struct bpf_security_struct *bpfsec = aux->security;
+	struct file_security_struct *fsec = file->f_security;
+
+	fsec->bpf_type = BPF_PROG;
+	fsec->bpf_sid = bpfsec->sid;
+}
 #endif
 
 static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
@@ -6581,6 +6646,8 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(bpf_prog_alloc_security, selinux_bpf_prog_alloc),
 	LSM_HOOK_INIT(bpf_map_free_security, selinux_bpf_map_free),
 	LSM_HOOK_INIT(bpf_prog_free_security, selinux_bpf_prog_free),
+	LSM_HOOK_INIT(bpf_map_file, selinux_bpf_map_file),
+	LSM_HOOK_INIT(bpf_prog_file, selinux_bpf_prog_file),
 #endif
 };
 
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index 3d54468ce334..0162648761f9 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -67,11 +67,20 @@ struct inode_security_struct {
 	spinlock_t lock;
 };
 
+enum bpf_obj_type {
+	BPF_MAP = 1,
+	BPF_PROG,
+};
+
 struct file_security_struct {
 	u32 sid;		/* SID of open file description */
 	u32 fown_sid;		/* SID of file owner (for SIGIO) */
 	u32 isid;		/* SID of inode at the time of file open */
 	u32 pseqno;		/* Policy seqno at the time of file open */
+#ifdef CONFIG_BPF_SYSCALL
+	unsigned char bpf_type;
+	u32 bpf_sid;
+#endif
 };
 
 struct superblock_security_struct {
-- 
2.14.2.920.gcf0c67979c-goog

