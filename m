From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v4 5/5] selinux: bpf: Add addtional check for bpf object file receive
Date: Wed, 11 Oct 2017 18:46:41 -0700
Message-ID: <20171012014641.96818-6-chenbofeng.kernel@gmail.com>
References: <20171012014641.96818-1-chenbofeng.kernel@gmail.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Smalley <sds@tycho.nsa.gov>, viro@zeniv.linux.org.uk,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32932 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754894AbdJLBrQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 21:47:16 -0400
Received: by mail-pf0-f195.google.com with SMTP id m28so3970816pfi.0
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 18:47:16 -0700 (PDT)
In-Reply-To: <20171012014641.96818-1-chenbofeng.kernel@gmail.com>
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
 fs/anon_inodes.c                  |  7 ++++
 include/linux/lsm_hooks.h         | 17 ++++++++++
 include/linux/security.h          |  8 +++++
 security/security.c               |  8 +++++
 security/selinux/hooks.c          | 71 +++++++++++++++++++++++++++++++++++++++
 security/selinux/include/objsec.h |  8 +++++
 6 files changed, 119 insertions(+)

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 3168ee4e77f4..7a950978622c 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -19,6 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/magic.h>
 #include <linux/anon_inodes.h>
+#include <linux/security.h>
 
 #include <linux/uaccess.h>
 
@@ -152,6 +153,12 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
 		error = PTR_ERR(file);
 		goto err_put_unused_fd;
 	}
+#ifdef CONFIG_BPF_SYSCALL
+	if (!strcmp(name, "bpf-map"))
+		security_bpf_map_file(file);
+	else if (!strcmp(name, "bpf-prog"))
+		security_bpf_prog_file(file);
+#endif
 	fd_install(fd, file);
 
 	return fd;
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 7161d8e7ee79..fdeadb4ba590 100644
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
+	void (*bpf_map_file)(struct file *file);
+	void (*bpf_prog_file)(struct file *file);
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
index 18800b0911e5..ebb0cca5eef1 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1740,6 +1740,8 @@ extern int security_bpf_map_alloc(struct bpf_map *map);
 extern void security_bpf_map_free(struct bpf_map *map);
 extern int security_bpf_prog_alloc(struct bpf_prog_aux *aux);
 extern void security_bpf_prog_free(struct bpf_prog_aux *aux);
+extern void security_bpf_map_file(struct file *file);
+extern void security_bpf_prog_file(struct file *file);
 #else
 static inline int security_bpf(int cmd, union bpf_attr *attr,
 					     unsigned int size)
@@ -1772,6 +1774,12 @@ static inline int security_bpf_prog_alloc(struct bpf_prog_aux *aux)
 
 static inline void security_bpf_prog_free(struct bpf_prog_aux *aux)
 { }
+
+static inline void security_bpf_map_file(struct file *file)
+{ }
+
+static inline void security_bpf_prog_file(struct file *file)
+{ }
 #endif /* CONFIG_SECURITY */
 #endif /* CONFIG_BPF_SYSCALL */
 
diff --git a/security/security.c b/security/security.c
index 1cd8526cb0b7..2ee6ba5cd690 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1734,4 +1734,12 @@ void security_bpf_prog_free(struct bpf_prog_aux *aux)
 {
 	call_void_hook(bpf_prog_free_security, aux);
 }
+void security_bpf_map_file(struct file *file)
+{
+	call_void_hook(bpf_map_file, file);
+}
+void security_bpf_prog_file(struct file *file)
+{
+	call_void_hook(bpf_prog_file, file);
+}
 #endif /* CONFIG_BPF_SYSCALL */
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 94e473b9c884..30e9d0ca23a1 100644
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
 
@@ -6288,6 +6308,41 @@ static u32 bpf_map_fmode_to_av(fmode_t fmode)
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
+	struct bpf_security_struct *bpfsec;
+	struct bpf_prog *prog;
+	struct bpf_map *map;
+	int ret;
+
+	if (fsec->bpf_type == BPF_MAP) {
+		map = file->private_data;
+		bpfsec = map->security;
+		ret = avc_has_perm(sid, bpfsec->sid, SECCLASS_BPF,
+				  bpf_map_fmode_to_av(file->f_mode), NULL);
+		if (ret)
+			return ret;
+	} else if (fsec->bpf_type == BPF_PROG) {
+		prog = file->private_data;
+		bpfsec = prog->aux->security;
+		ret = avc_has_perm(sid, bpfsec->sid, SECCLASS_BPF,
+				  BPF__PROG_USE, NULL);
+		if (ret)
+			return ret;
+	}
+	return 0;
+
+}
+
 static int selinux_bpf_map(struct bpf_map *map, fmode_t fmode)
 {
 	u32 sid = current_sid();
@@ -6351,6 +6406,20 @@ static void selinux_bpf_prog_free(struct bpf_prog_aux *aux)
 	aux->security = NULL;
 	kfree(bpfsec);
 }
+
+static void selinux_bpf_map_file(struct file *file)
+{
+	struct file_security_struct *fsec = file->f_security;
+
+	fsec->bpf_type = BPF_MAP;
+}
+
+static void selinux_bpf_prog_file(struct file *file)
+{
+	struct file_security_struct *fsec = file->f_security;
+
+	fsec->bpf_type = BPF_PROG;
+}
 #endif
 
 static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
@@ -6581,6 +6650,8 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(bpf_prog_alloc_security, selinux_bpf_prog_alloc),
 	LSM_HOOK_INIT(bpf_map_free_security, selinux_bpf_map_free),
 	LSM_HOOK_INIT(bpf_prog_free_security, selinux_bpf_prog_free),
+	LSM_HOOK_INIT(bpf_map_file, selinux_bpf_map_file),
+	LSM_HOOK_INIT(bpf_prog_file, selinux_bpf_prog_file),
 #endif
 };
 
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index 3d54468ce334..4030d1c47f6b 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -67,11 +67,19 @@ struct inode_security_struct {
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
+#endif
 };
 
 struct superblock_security_struct {
-- 
2.15.0.rc0.271.g36b669edcc-goog
