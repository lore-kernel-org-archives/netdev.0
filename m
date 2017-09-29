From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH 2/2] userns: control capabilities of some user namespaces
Date: Fri, 29 Sep 2017 16:10:08 -0700
Message-ID: <20170929231008.29834-1-mahesh@bandewar.net>
Cc: Netdev <netdev@vger.kernel.org>,
        Kernel-hardening <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>,
        Serge Hallyn <serge@hallyn.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mahesh Bandewar <maheshb@google.com>

With this new notion of "controlled" user-namespaces, the controlled
user-namespaces are marked at the time of their creation while the
capabilities of processes that belong to them are controlled using the
global mask.

Init-user-ns is always uncontrolled and a process that has SYS_ADMIN
that belongs to uncontrolled user-ns can create another (child) user-
namespace that is uncontrolled. Any other process (that either does
not have SYS_ADMIN or belongs to a controlled user-ns) can only
create a user-ns that is controlled.

global-capability-whitelist (controlled_userns_caps_whitelist) is used
at the capability check-time and keeps the semantics for the processes
that belong to uncontrolled user-ns as it is. Processes that belong to
controlled user-ns however are subjected to different checks-

   (a) if the capability in question is controlled and process belongs
       to controlled user-ns, then it's always denied.
   (b) if the capability in question is NOT controlled then fall back
       to the traditional check.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/capability.h     |  1 +
 include/linux/user_namespace.h | 20 ++++++++++++++++++++
 kernel/capability.c            |  5 +++++
 kernel/user_namespace.c        |  3 +++
 security/commoncap.c           |  8 ++++++++
 5 files changed, 37 insertions(+)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 6c0b9677c03f..b8c6cac18658 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -250,6 +250,7 @@ extern bool ptracer_capable(struct task_struct *tsk, struct user_namespace *ns);
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_vfs_cap_data *cpu_caps);
 int proc_douserns_caps_whitelist(struct ctl_table *table, int write,
 				 void __user *buff, size_t *lenp, loff_t *ppos);
+bool is_capability_controlled(int cap);
 
 extern int cap_convert_nscap(struct dentry *dentry, void **ivalue, size_t size);
 
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index c18e01252346..e890fe81b47e 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -22,6 +22,7 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 };
 
 #define USERNS_SETGROUPS_ALLOWED 1UL
+#define USERNS_CONTROLLED	 2UL
 
 #define USERNS_INIT_FLAGS USERNS_SETGROUPS_ALLOWED
 
@@ -102,6 +103,16 @@ static inline void put_user_ns(struct user_namespace *ns)
 		__put_user_ns(ns);
 }
 
+static inline bool is_user_ns_controlled(const struct user_namespace *ns)
+{
+	return ns->flags & USERNS_CONTROLLED;
+}
+
+static inline void mark_user_ns_controlled(struct user_namespace *ns)
+{
+	ns->flags |= USERNS_CONTROLLED;
+}
+
 struct seq_operations;
 extern const struct seq_operations proc_uid_seq_operations;
 extern const struct seq_operations proc_gid_seq_operations;
@@ -160,6 +171,15 @@ static inline struct ns_common *ns_get_owner(struct ns_common *ns)
 {
 	return ERR_PTR(-EPERM);
 }
+
+static inline bool is_user_ns_controlled(const struct user_namespace *ns)
+{
+	return false;
+}
+
+static inline void mark_user_ns_controlled(struct user_namespace *ns)
+{
+}
 #endif
 
 #endif /* _LINUX_USER_H */
diff --git a/kernel/capability.c b/kernel/capability.c
index 62dbe3350c1b..40a38cc4ff43 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -510,6 +510,11 @@ bool ptracer_capable(struct task_struct *tsk, struct user_namespace *ns)
 }
 
 /* Controlled-userns capabilities routines */
+bool is_capability_controlled(int cap)
+{
+	return !cap_raised(controlled_userns_caps_whitelist, cap);
+}
+
 #ifdef CONFIG_SYSCTL
 int proc_douserns_caps_whitelist(struct ctl_table *table, int write,
 				 void __user *buff, size_t *lenp, loff_t *ppos)
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index c490f1e4313b..f393ea5108f0 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -53,6 +53,9 @@ static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
 	cred->cap_effective = CAP_FULL_SET;
 	cred->cap_ambient = CAP_EMPTY_SET;
 	cred->cap_bset = CAP_FULL_SET;
+	if (!ns_capable(user_ns->parent, CAP_SYS_ADMIN) ||
+	    is_user_ns_controlled(user_ns->parent))
+		mark_user_ns_controlled(user_ns);
 #ifdef CONFIG_KEYS
 	key_put(cred->request_key_auth);
 	cred->request_key_auth = NULL;
diff --git a/security/commoncap.c b/security/commoncap.c
index 6bf72b175b49..26f41602da10 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -73,6 +73,14 @@ int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
 {
 	struct user_namespace *ns = targ_ns;
 
+	/* If the capability is controlled and user-ns that process
+	 * belongs-to is 'controlled' then return EPERM and no need
+	 * to check the user-ns hierarchy.
+	 */
+	if (is_user_ns_controlled(cred->user_ns) &&
+	    is_capability_controlled(cap))
+		return -EPERM;
+
 	/* See if cred has the capability in the target user namespace
 	 * by examining the target user namespace and all of the target
 	 * user namespace's parents.
-- 
2.14.2.822.g60be5d43e6-goog
