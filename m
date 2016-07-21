From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 02/10] userns: Add per user namespace sysctls.
Date: Thu, 21 Jul 2016 11:40:06 -0500
Message-ID: <20160721164014.17534-2-ebiederm@xmission.com>
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

Limit per userns sysctls to only be opened for write by a holder
of CAP_SYS_RESOURCE.

Add all of the necessary boilerplate for having per user namespace
sysctls.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/user_namespace.h |  4 ++
 kernel/user_namespace.c        | 96 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 98 insertions(+), 2 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 9217169c64cb..7d59af1f08f1 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -39,6 +39,10 @@ struct user_namespace {
 	struct key		*persistent_keyring_register;
 	struct rw_semaphore	persistent_keyring_register_sem;
 #endif
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_set	set;
+	struct ctl_table_header *sysctls;
+#endif
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 68f594212759..10afbb55dfc2 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -30,6 +30,70 @@ static bool new_idmap_permitted(const struct file *file,
 				struct user_namespace *ns, int cap_setid,
 				struct uid_gid_map *map);
 
+#ifdef CONFIG_SYSCTL
+static struct ctl_table_set *
+set_lookup(struct ctl_table_root *root)
+{
+	return &current_user_ns()->set;
+}
+
+static int set_is_seen(struct ctl_table_set *set)
+{
+	return &current_user_ns()->set == set;
+}
+
+static int set_permissions(struct ctl_table_header *head,
+				  struct ctl_table *table)
+{
+	struct user_namespace *user_ns =
+		container_of(head->set, struct user_namespace, set);
+	int mode;
+
+	/* Allow users with CAP_SYS_RESOURCE unrestrained access */
+	if (ns_capable(user_ns, CAP_SYS_RESOURCE))
+		mode = (table->mode & S_IRWXU) >> 6;
+	else
+	/* Allow all others at most read-only access */
+		mode = table->mode & S_IROTH;
+	return (mode << 6) | (mode << 3) | mode;
+}
+
+static struct ctl_table_root set_root = {
+	.lookup = set_lookup,
+	.permissions = set_permissions,
+};
+
+static struct ctl_table userns_table[] = {
+	{ }
+};
+#endif /* CONFIG_SYSCTL */
+
+static bool setup_userns_sysctls(struct user_namespace *ns)
+{
+#ifdef CONFIG_SYSCTL
+	struct ctl_table *tbl;
+	setup_sysctl_set(&ns->set, &set_root, set_is_seen);
+	tbl = kmemdup(userns_table, sizeof(userns_table), GFP_KERNEL);
+	if (tbl) {
+		ns->sysctls = __register_sysctl_table(&ns->set, "userns", tbl);
+	}
+	if (!ns->sysctls) {
+		kfree(tbl);
+		retire_sysctl_set(&ns->set);
+		return false;
+	}
+#endif
+	return true;
+}
+
+static void retire_userns_sysctls(struct user_namespace *ns)
+{
+#ifdef CONFIG_SYSCTL
+	unregister_sysctl_table(ns->sysctls);
+	retire_sysctl_set(&ns->set);
+#endif
+}
+
 static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
 {
 	/* Start with the same capabilities as init but useless for doing
@@ -107,12 +171,22 @@ int create_user_ns(struct cred *new)
 	ns->flags = parent_ns->flags;
 	mutex_unlock(&userns_state_mutex);
 
-	set_cred_user_ns(new, ns);
-
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 	init_rwsem(&ns->persistent_keyring_register_sem);
 #endif
+	ret = -ENOMEM;
+	if (!setup_userns_sysctls(ns))
+		goto fail_keyring;
+
+	set_cred_user_ns(new, ns);
 	return 0;
+fail_keyring:
+#ifdef CONFIG_PERSISTENT_KEYRINGS
+	key_put(ns->persistent_keyring_register);
+#endif
+	ns_free_inum(&ns->ns);
+	kmem_cache_free(user_ns_cachep, ns);
+	return ret;
 }
 
 int unshare_userns(unsigned long unshare_flags, struct cred **new_cred)
@@ -141,6 +215,7 @@ void free_user_ns(struct user_namespace *ns)
 
 	do {
 		parent = ns->parent;
+		retire_userns_sysctls(ns);
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 		key_put(ns->persistent_keyring_register);
 #endif
@@ -1012,9 +1087,26 @@ const struct proc_ns_operations userns_operations = {
 	.install	= userns_install,
 };
 
+static __init void user_namespace_sysctl_init(void)
+{
+#ifdef CONFIG_SYSCTL
+	static struct ctl_table_header *userns_header;
+	static struct ctl_table empty[1];
+	/*
+	 * It is necessary to register the userns directory in the
+	 * default set so that registrations in the child sets work
+	 * properly.
+	 */
+	userns_header = register_sysctl("userns", empty);
+	BUG_ON(!userns_header);
+	BUG_ON(!setup_userns_sysctls(&init_user_ns));
+#endif
+}
+
 static __init int user_namespaces_init(void)
 {
 	user_ns_cachep = KMEM_CACHE(user_namespace, SLAB_PANIC);
+	user_namespace_sysctl_init();
 	return 0;
 }
 subsys_initcall(user_namespaces_init);
-- 
2.8.3
