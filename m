From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH v2 04/10] userns: Generalize the user namespace count into ucount
Date: Thu, 21 Jul 2016 11:40:08 -0500
Message-ID: <20160721164014.17534-4-ebiederm@xmission.com>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
 <20160721164014.17534-1-ebiederm@xmission.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Jann Horn <jann@thejh.net>,
	Kees Cook <keescook@chromium.org>,
	Nikolay Borisov <kernel@kyup.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Linux Containers <containers@lists.linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160721164014.17534-1-ebiederm@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The same kind of recursive sane default limit and policy
countrol that has been implemented for the user namespace
is desirable for the other namespaces, so generalize
the user namespace refernce count into a ucount.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/user_namespace.h | 32 ++++++++++++++++++++++--
 kernel/fork.c                  |  5 +++-
 kernel/user_namespace.c        | 55 +++++++++++++++++++++++++++---------------
 3 files changed, 69 insertions(+), 23 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index ba6a995178f9..f74a0facc696 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -22,6 +22,16 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 
 #define USERNS_INIT_FLAGS USERNS_SETGROUPS_ALLOWED
 
+enum ucounts {
+	UCOUNT_USER_NAMESPACES,
+	UCOUNT_COUNTS,
+};
+
+struct ucount {
+	int max;
+	atomic_t count;
+};
+
 struct user_namespace {
 	struct uid_gid_map	uid_map;
 	struct uid_gid_map	gid_map;
@@ -43,8 +53,7 @@ struct user_namespace {
 	struct ctl_table_set	set;
 	struct ctl_table_header *sysctls;
 #endif
-	int max_user_namespaces;
-	atomic_t user_namespaces;
+	struct ucount ucount[UCOUNT_COUNTS];
 };
 
 extern struct user_namespace init_user_ns;
@@ -79,6 +88,8 @@ extern ssize_t proc_setgroups_write(struct file *, const char __user *, size_t,
 extern int proc_setgroups_show(struct seq_file *m, void *v);
 extern bool userns_may_setgroups(const struct user_namespace *ns);
 extern bool current_in_userns(const struct user_namespace *target_ns);
+extern bool inc_ucount(struct user_namespace *ns, enum ucounts type);
+extern void dec_ucount(struct user_namespace *ns, enum ucounts type);
 #else
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
@@ -112,6 +123,23 @@ static inline bool current_in_userns(const struct user_namespace *target_ns)
 {
 	return true;
 }
+
+static inline bool inc_ucount(struct user_namespace *ns, enum ucounts type)
+{
+	int max = READ_ONCE(init_user_ns.ucount[type].max);
+	int sum = atomic_inc_return(&init_user_ns.ucount[type].count);
+	if (sum > max) {
+		atomic_dec(&init_user_ns.ucount[type].count);
+		return false;
+	}
+	return true;
+}
+
+static inline void dec_ucount(struct user_namespace *ns, enum ucounts type)
+{
+	int dec = atomic_dec_if_positive(&init_user_ns.ucount[type].count);
+	WARN_ON_ONCE(dec < 0);
+}
 #endif
 
 #endif /* _LINUX_USER_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 95d5498c463f..30ca5eb4ca1e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -304,6 +304,7 @@ int arch_task_struct_size __read_mostly;
 
 void __init fork_init(void)
 {
+	int i;
 #ifndef CONFIG_ARCH_TASK_STRUCT_ALLOCATOR
 #ifndef ARCH_MIN_TASKALIGN
 #define ARCH_MIN_TASKALIGN	L1_CACHE_BYTES
@@ -324,7 +325,9 @@ void __init fork_init(void)
 	init_task.signal->rlim[RLIMIT_SIGPENDING] =
 		init_task.signal->rlim[RLIMIT_NPROC];
 
-	init_user_ns.max_user_namespaces = max_threads;
+	for (i = 0; i < UCOUNT_COUNTS; i++) {
+		init_user_ns.ucount[i].max = max_threads;
+	}
 }
 
 int __weak arch_dup_task_struct(struct task_struct *dst,
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 0061550e3282..728d7e4995ff 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -66,16 +66,17 @@ static struct ctl_table_root set_root = {
 
 static int zero = 0;
 static int count_max = COUNT_MAX;
+#define UCOUNT_ENTRY(name) 				\
+	{						\
+		.procname	= name,			\
+		.maxlen		= sizeof(int),		\
+		.mode		= 0644,			\
+		.proc_handler	= proc_dointvec_minmax,	\
+		.extra1		= &zero,		\
+		.extra2		= &count_max,		\
+	}
 static struct ctl_table userns_table[] = {
-	{
-		.procname	= "max_user_namespaces",
-		.data		= &init_user_ns.max_user_namespaces,
-		.maxlen		= sizeof(init_user_ns.max_user_namespaces),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero,
-		.extra2		= &count_max,
-	},
+	UCOUNT_ENTRY("max_user_namespaces"),
 	{ }
 };
 #endif /* CONFIG_SYSCTL */
@@ -87,8 +88,10 @@ static bool setup_userns_sysctls(struct user_namespace *ns)
 	setup_sysctl_set(&ns->set, &set_root, set_is_seen);
 	tbl = kmemdup(userns_table, sizeof(userns_table), GFP_KERNEL);
 	if (tbl) {
-		tbl[0].data = &ns->max_user_namespaces;
-
+		int i;
+		for (i = 0; i < UCOUNT_COUNTS; i++) {
+			tbl[i].data = &ns->ucount[i].max;
+		}
 		ns->sysctls = __register_sysctl_table(&ns->set, "userns", tbl);
 	}
 	if (!ns->sysctls) {
@@ -127,34 +130,44 @@ static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
 	cred->user_ns = user_ns;
 }
 
-static bool inc_user_namespaces(struct user_namespace *ns)
+bool inc_ucount(struct user_namespace *ns, enum ucounts type)
 {
 	struct user_namespace *pos, *bad;
 	for (pos = ns; pos; pos = pos->parent) {
-		int max = READ_ONCE(pos->max_user_namespaces);
-		int sum = atomic_inc_return(&pos->user_namespaces);
+		int max = READ_ONCE(pos->ucount[type].max);
+		int sum = atomic_inc_return(&pos->ucount[type].count);
 		if (sum > max)
 			goto fail;
 	}
 	return true;
 fail:
 	bad = pos;
-	atomic_dec(&pos->user_namespaces);
+	atomic_dec(&pos->ucount[type].count);
 	for (pos = ns; pos != bad; pos = pos->parent)
-		atomic_dec(&pos->user_namespaces);
+		atomic_dec(&pos->ucount[type].count);
 
 	return false;
 }
 
-static void dec_user_namespaces(struct user_namespace *ns)
+void dec_ucount(struct user_namespace *ns, enum ucounts type)
 {
 	struct user_namespace *pos;
 	for (pos = ns; pos; pos = pos->parent) {
-		int dec = atomic_dec_if_positive(&pos->user_namespaces);
+		int dec = atomic_dec_if_positive(&pos->ucount[type].count);
 		WARN_ON_ONCE(dec < 0);
 	}
 }
 
+static bool inc_user_namespaces(struct user_namespace *ns)
+{
+	return inc_ucount(ns, UCOUNT_USER_NAMESPACES);
+}
+
+static void dec_user_namespaces(struct user_namespace *ns)
+{
+	return dec_ucount(ns, UCOUNT_USER_NAMESPACES);
+}
+
 /*
  * Create a new user namespace, deriving the creator from the user in the
  * passed credentials, and replacing that user with the new root user for the
@@ -168,7 +181,7 @@ int create_user_ns(struct cred *new)
 	struct user_namespace *ns, *parent_ns = new->user_ns;
 	kuid_t owner = new->euid;
 	kgid_t group = new->egid;
-	int ret;
+	int ret, i;
 
 	ret = -EUSERS;
 	if (parent_ns->level > 32)
@@ -212,7 +225,9 @@ int create_user_ns(struct cred *new)
 	ns->level = parent_ns->level + 1;
 	ns->owner = owner;
 	ns->group = group;
-	ns->max_user_namespaces = COUNT_MAX;
+	for (i = 0; i < UCOUNT_COUNTS; i++) {
+		ns->ucount[i].max = COUNT_MAX;
+	}
 
 	/* Inherit USERNS_SETGROUPS_ALLOWED from our parent */
 	mutex_lock(&userns_state_mutex);
-- 
2.8.3
