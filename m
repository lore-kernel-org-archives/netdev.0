From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v2 5/5] selinux: bpf: Add addtional check for bpf object file receive
Date: Mon,  9 Oct 2017 15:20:28 -0700
Message-ID: <20171009222028.13096-6-chenbofeng.kernel@gmail.com>
References: <20171009222028.13096-1-chenbofeng.kernel@gmail.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Chenbo Feng <fengc@google.com>
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38613 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755191AbdJIWVE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 18:21:04 -0400
In-Reply-To: <20171009222028.13096-1-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 include/linux/bpf.h       |  3 +++
 include/linux/lsm_hooks.h | 17 +++++++++++++
 include/linux/security.h  |  9 +++++++
 kernel/bpf/syscall.c      |  4 ++--
 security/security.c       |  8 +++++++
 security/selinux/hooks.c  | 61 +++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 100 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 225740688ab7..81d6c01b8825 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -285,6 +285,9 @@ int bpf_prog_array_copy_to_user(struct bpf_prog_array __rcu *progs,
 #ifdef CONFIG_BPF_SYSCALL
 DECLARE_PER_CPU(int, bpf_prog_active);
 
+extern const struct file_operations bpf_map_fops;
+extern const struct file_operations bpf_prog_fops;
+
 #define BPF_PROG_TYPE(_id, _ops) \
 	extern const struct bpf_verifier_ops _ops;
 #define BPF_MAP_TYPE(_id, _ops) \
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
index 1cf31ddd7616..b144181d3f3a 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -313,7 +313,7 @@ static ssize_t bpf_dummy_write(struct file *filp, const char __user *buf,
 	return -EINVAL;
 }
 
-static const struct file_operations bpf_map_fops = {
+const struct file_operations bpf_map_fops = {
 #ifdef CONFIG_PROC_FS
 	.show_fdinfo	= bpf_map_show_fdinfo,
 #endif
@@ -964,7 +964,7 @@ static void bpf_prog_show_fdinfo(struct seq_file *m, struct file *filp)
 }
 #endif
 
-static const struct file_operations bpf_prog_fops = {
+const struct file_operations bpf_prog_fops = {
 #ifdef CONFIG_PROC_FS
 	.show_fdinfo	= bpf_prog_show_fdinfo,
 #endif
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
index 41aba4e3d57c..fea88655e0ee 100644
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
@@ -1845,6 +1849,12 @@ static int file_has_perm(const struct cred *cred,
 			goto out;
 	}
 
+#ifdef CONFIG_BPF_SYSCALL
+	rc = bpf_file_check(file, cred_sid(cred));
+	if (rc)
+		goto out;
+#endif
+
 	/* av is zero if only checking access to the descriptor. */
 	rc = 0;
 	if (av)
@@ -2165,6 +2175,12 @@ static int selinux_binder_transfer_file(struct task_struct *from,
 			return rc;
 	}
 
+#ifdef CONFIG_BPF_SYSCALL
+	rc = bpf_file_check(file, sid);
+	if (rc)
+		return rc;
+#endif
+
 	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
 		return 0;
 
@@ -6288,6 +6304,33 @@ static u32 bpf_map_fmode_to_av(fmode_t fmode)
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
+	if (file->f_op == &bpf_map_fops) {
+		ret = avc_has_perm(sid, fsec->sid, SECCLASS_BPF_MAP,
+				   bpf_map_fmode_to_av(file->f_mode), NULL);
+		if (ret)
+			return ret;
+	} else if (file->f_op == &bpf_prog_fops) {
+		ret = avc_has_perm(sid, fsec->sid, SECCLASS_BPF_PROG,
+				   BPF_PROG__USE, NULL);
+		if (ret)
+			return ret;
+	}
+	return 0;
+}
+
 static int selinux_bpf_map(struct bpf_map *map, fmode_t fmode)
 {
 	u32 sid = current_sid();
@@ -6351,6 +6394,22 @@ static void selinux_bpf_prog_free(struct bpf_prog_aux *aux)
 	aux->security = NULL;
 	kfree(bpfsec);
 }
+
+static void selinux_bpf_map_file(struct bpf_map *map, struct file *file)
+{
+	struct bpf_security_struct *bpfsec = map->security;
+	struct file_security_struct *fsec = file->f_security;
+
+	fsec->sid = bpfsec->sid;
+}
+
+static void selinux_bpf_prog_file(struct bpf_prog_aux *aux, struct file *file)
+{
+	struct bpf_security_struct *bpfsec = aux->security;
+	struct file_security_struct *fsec = file->f_security;
+
+	fsec->sid = bpfsec->sid;
+}
 #endif
 
 static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
@@ -6581,6 +6640,8 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(bpf_prog_alloc_security, selinux_bpf_prog_alloc),
 	LSM_HOOK_INIT(bpf_map_free_security, selinux_bpf_map_free),
 	LSM_HOOK_INIT(bpf_prog_free_security, selinux_bpf_prog_free),
+	LSM_HOOK_INIT(bpf_map_file, selinux_bpf_map_file),
+	LSM_HOOK_INIT(bpf_prog_file, selinux_bpf_prog_file),
 #endif
 };
 
-- 
2.14.2.920.gcf0c67979c-goog
