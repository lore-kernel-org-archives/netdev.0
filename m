From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 03/10] userns: Add a limit on the number of user namespaces
Date: Thu, 21 Jul 2016 11:40:07 -0500
Message-ID: <20160721164014.17534-3-ebiederm@xmission.com>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
	<20160721164014.17534-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160721164014.17534-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Export the export the maximum number of user namespaces as
/proc/sys/userns/max_user_namespaces.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/user_namespace.h |  2 ++
 kernel/fork.c                  |  2 ++
 kernel/user_namespace.c        | 69 +++++++++++++++++++++++++++++++++++++-----
 3 files changed, 65 insertions(+), 8 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 7d59af1f08f1..ba6a995178f9 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -43,6 +43,8 @@ struct user_namespace {
 	struct ctl_table_set	set;
 	struct ctl_table_header *sysctls;
 #endif
+	int max_user_namespaces;
+	atomic_t user_namespaces;
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/kernel/fork.c b/kernel/fork.c
index 5c2c355aa97f..95d5498c463f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -323,6 +323,8 @@ void __init fork_init(void)
 	init_task.signal->rlim[RLIMIT_NPROC].rlim_max = max_threads/2;
 	init_task.signal->rlim[RLIMIT_SIGPENDING] =
 		init_task.signal->rlim[RLIMIT_NPROC];
+
+	init_user_ns.max_user_namespaces = max_threads;
 }
 
 int __weak arch_dup_task_struct(struct task_struct *dst,
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 10afbb55dfc2..0061550e3282 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -29,6 +29,7 @@ static DEFINE_MUTEX(userns_state_mutex);
 static bool new_idmap_permitted(const struct file *file,
 				struct user_namespace *ns, int cap_setid,
 				struct uid_gid_map *map);
+#define COUNT_MAX (INT_MAX - 1)
 
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_set *
@@ -63,7 +64,18 @@ static struct ctl_table_root set_root = {
 	.permissions = set_permissions,
 };
 
+static int zero = 0;
+static int count_max = COUNT_MAX;
 static struct ctl_table userns_table[] = {
+	{
+		.procname	= "max_user_namespaces",
+		.data		= &init_user_ns.max_user_namespaces,
+		.maxlen		= sizeof(init_user_ns.max_user_namespaces),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &count_max,
+	},
 	{ }
 };
 #endif /* CONFIG_SYSCTL */
@@ -75,6 +87,8 @@ static bool setup_userns_sysctls(struct user_namespace *ns)
 	setup_sysctl_set(&ns->set, &set_root, set_is_seen);
 	tbl = kmemdup(userns_table, sizeof(userns_table), GFP_KERNEL);
 	if (tbl) {
+		tbl[0].data = &ns->max_user_namespaces;
+
 		ns->sysctls = __register_sysctl_table(&ns->set, "userns", tbl);
 	}
 	if (!ns->sysctls) {
@@ -113,6 +127,34 @@ static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
 	cred->user_ns = user_ns;
 }
 
+static bool inc_user_namespaces(struct user_namespace *ns)
+{
+	struct user_namespace *pos, *bad;
+	for (pos = ns; pos; pos = pos->parent) {
+		int max = READ_ONCE(pos->max_user_namespaces);
+		int sum = atomic_inc_return(&pos->user_namespaces);
+		if (sum > max)
+			goto fail;
+	}
+	return true;
+fail:
+	bad = pos;
+	atomic_dec(&pos->user_namespaces);
+	for (pos = ns; pos != bad; pos = pos->parent)
+		atomic_dec(&pos->user_namespaces);
+
+	return false;
+}
+
+static void dec_user_namespaces(struct user_namespace *ns)
+{
+	struct user_namespace *pos;
+	for (pos = ns; pos; pos = pos->parent) {
+		int dec = atomic_dec_if_positive(&pos->user_namespaces);
+		WARN_ON_ONCE(dec < 0);
+	}
+}
+
 /*
  * Create a new user namespace, deriving the creator from the user in the
  * passed credentials, and replacing that user with the new root user for the
@@ -128,8 +170,12 @@ int create_user_ns(struct cred *new)
 	kgid_t group = new->egid;
 	int ret;
 
+	ret = -EUSERS;
 	if (parent_ns->level > 32)
-		return -EUSERS;
+		goto fail;
+
+	if (!inc_user_namespaces(parent_ns))
+		goto fail;
 
 	/*
 	 * Verify that we can not violate the policy of which files
@@ -137,26 +183,27 @@ int create_user_ns(struct cred *new)
 	 * by verifing that the root directory is at the root of the
 	 * mount namespace which allows all files to be accessed.
 	 */
+	ret = -EPERM;
 	if (current_chrooted())
-		return -EPERM;
+		goto fail_dec;
 
 	/* The creator needs a mapping in the parent user namespace
 	 * or else we won't be able to reasonably tell userspace who
 	 * created a user_namespace.
 	 */
+	ret = -EPERM;
 	if (!kuid_has_mapping(parent_ns, owner) ||
 	    !kgid_has_mapping(parent_ns, group))
-		return -EPERM;
+		goto fail_dec;
 
+	ret = -ENOMEM;
 	ns = kmem_cache_zalloc(user_ns_cachep, GFP_KERNEL);
 	if (!ns)
-		return -ENOMEM;
+		goto fail_dec;
 
 	ret = ns_alloc_inum(&ns->ns);
-	if (ret) {
-		kmem_cache_free(user_ns_cachep, ns);
-		return ret;
-	}
+	if (ret)
+		goto fail_free;
 	ns->ns.ops = &userns_operations;
 
 	atomic_set(&ns->count, 1);
@@ -165,6 +212,7 @@ int create_user_ns(struct cred *new)
 	ns->level = parent_ns->level + 1;
 	ns->owner = owner;
 	ns->group = group;
+	ns->max_user_namespaces = COUNT_MAX;
 
 	/* Inherit USERNS_SETGROUPS_ALLOWED from our parent */
 	mutex_lock(&userns_state_mutex);
@@ -185,7 +233,11 @@ fail_keyring:
 	key_put(ns->persistent_keyring_register);
 #endif
 	ns_free_inum(&ns->ns);
+fail_free:
 	kmem_cache_free(user_ns_cachep, ns);
+fail_dec:
+	dec_user_namespaces(parent_ns);
+fail:
 	return ret;
 }
 
@@ -221,6 +273,7 @@ void free_user_ns(struct user_namespace *ns)
 #endif
 		ns_free_inum(&ns->ns);
 		kmem_cache_free(user_ns_cachep, ns);
+		dec_user_namespaces(parent);
 		ns = parent;
 	} while (atomic_dec_and_test(&parent->count));
 }
-- 
2.8.3
