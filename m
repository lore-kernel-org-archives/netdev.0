From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 1/4] inotify: Add infrastructure to account inotify limits per-namespace
Date: Wed,  1 Jun 2016 10:52:57 +0300
Message-ID: <1464767580-22732-2-git-send-email-kernel@kyup.com>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Cc: jack@suse.cz, linux-kernel@vger.kernel.org, gorcunov@openvz.org,
	avagin@openvz.org, netdev@vger.kernel.org,
	operations@siteground.com, Nikolay Borisov <kernel@kyup.com>
To: john@johnmccutchan.com, eparis@redhat.com, ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the necessary members to user_struct. The idea behind
the solution is really simple - user the userns pointers as keys into
a hash table which holds the inotify instances/watches counts. This
allows to account the limits per userns rather than per real user,
which makes certain scenarios such as a single mapped user in a
container deplete the inotify resources for all other users, which
map to the exact same real user.

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 fs/notify/inotify/inotify.h      | 68 ++++++++++++++++++++++++++++++++++++++++
 fs/notify/inotify/inotify_user.c | 36 +++++++++++++++++++++
 include/linux/fsnotify_backend.h |  1 +
 include/linux/sched.h            |  3 ++
 kernel/user.c                    | 13 ++++++++
 5 files changed, 121 insertions(+)

diff --git a/fs/notify/inotify/inotify.h b/fs/notify/inotify/inotify.h
index ed855ef6f077..e069e1e4262a 100644
--- a/fs/notify/inotify/inotify.h
+++ b/fs/notify/inotify/inotify.h
@@ -1,6 +1,7 @@
 #include <linux/fsnotify_backend.h>
 #include <linux/inotify.h>
 #include <linux/slab.h> /* struct kmem_cache */
+#include <linux/hashtable.h>
 
 struct inotify_event_info {
 	struct fsnotify_event fse;
@@ -15,6 +16,13 @@ struct inotify_inode_mark {
 	int wd;
 };
 
+struct inotify_state {
+	struct hlist_node node;
+	void *key; /* user_namespace ptr */
+	u32 inotify_watches; /* How many inotify watches does this user have? */
+	u32 inotify_devs;  /* How many inotify devs does this user have opened? */
+};
+
 static inline struct inotify_event_info *INOTIFY_E(struct fsnotify_event *fse)
 {
 	return container_of(fse, struct inotify_event_info, fse);
@@ -30,3 +38,63 @@ extern int inotify_handle_event(struct fsnotify_group *group,
 				const unsigned char *file_name, u32 cookie);
 
 extern const struct fsnotify_ops inotify_fsnotify_ops;
+
+/* Helpers for manipulating various inotify state, stored in user_struct */
+static inline struct inotify_state *__find_inotify_state(struct user_struct *user,
+							  void *key)
+{
+	struct inotify_state *state;
+
+	hash_for_each_possible(user->inotify_tbl, state, node, (unsigned long)key)
+		if (state->key == key)
+			return state;
+
+	return NULL;
+}
+
+static inline void inotify_inc_watches(struct user_struct *user, void *key)
+{
+	struct inotify_state *state;
+
+	spin_lock(&user->inotify_lock);
+	state = __find_inotify_state(user, key);
+	state->inotify_watches++;
+	spin_unlock(&user->inotify_lock);
+}
+
+
+static inline void inotify_dec_watches(struct user_struct *user, void *key)
+{
+	struct inotify_state *state;
+
+	spin_lock(&user->inotify_lock);
+	state = __find_inotify_state(user, key);
+	state->inotify_watches--;
+	spin_unlock(&user->inotify_lock);
+}
+
+static inline int inotify_read_watches(struct user_struct *user, void *key)
+{
+	struct inotify_state *state;
+	int ret;
+
+	spin_lock(&user->inotify_lock);
+	state = __find_inotify_state(user, key);
+	ret = state->inotify_watches;
+	spin_unlock(&user->inotify_lock);
+	return ret;
+}
+
+static inline unsigned long inotify_dec_return_dev(struct user_struct *user,
+						   void *key)
+{
+	struct inotify_state *state;
+	unsigned long ret;
+
+	spin_lock(&user->inotify_lock);
+	state = __find_inotify_state(user, key);
+	ret = --state->inotify_devs;
+	spin_unlock(&user->inotify_lock);
+
+	return ret;
+}
diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
index b8d08d0d0a4d..ae7ec2414252 100644
--- a/fs/notify/inotify/inotify_user.c
+++ b/fs/notify/inotify/inotify_user.c
@@ -86,6 +86,42 @@ struct ctl_table inotify_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
+
+static int inotify_init_state(struct user_struct *user,
+						  void *key)
+{
+	struct inotify_state *state;
+	int ret = 0;
+
+	spin_lock(&user->inotify_lock);
+	state =  __find_inotify_count(user, key);
+
+	if (!state) {
+		spin_unlock(&user->inotify_lock);
+		state = kzalloc(sizeof(struct inotify_state), GFP_KERNEL);
+		if (!state)
+			return -ENOMEM;
+
+		state->key = current_user_ns();
+		state->inotify_watches = 0;
+		state->inotify_devs = 1;
+
+		spin_lock(&user->inotify_lock);
+		hash_add(user->inotify_tbl, &state->node, (unsigned long)key);
+
+		goto out;
+	} else {
+
+		if (++state->inotify_devs > inotify_max_user_instances) {
+			ret = -EMFILE;
+			goto out;
+		}
+	}
+out:
+	spin_unlock(&user->inotify_lock);
+	return ret;
+}
+
 static inline __u32 inotify_arg_to_mask(u32 arg)
 {
 	__u32 mask;
diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
index 29f917517299..89f7c247b038 100644
--- a/include/linux/fsnotify_backend.h
+++ b/include/linux/fsnotify_backend.h
@@ -170,6 +170,7 @@ struct fsnotify_group {
 			spinlock_t	idr_lock;
 			struct idr      idr;
 			struct user_struct      *user;
+			void *userns_ptr;
 		} inotify_data;
 #endif
 #ifdef CONFIG_FANOTIFY
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6e42ada26345..0c55d951d0bb 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -58,6 +58,7 @@ struct sched_param {
 #include <linux/uidgid.h>
 #include <linux/gfp.h>
 #include <linux/magic.h>
+#include <linux/hashtable.h>
 #include <linux/cgroup-defs.h>
 
 #include <asm/processor.h>
@@ -839,6 +840,8 @@ struct user_struct {
 	atomic_t processes;	/* How many processes does this user have? */
 	atomic_t sigpending;	/* How many pending signals does this user have? */
 #ifdef CONFIG_INOTIFY_USER
+	spinlock_t inotify_lock;
+	DECLARE_HASHTABLE(inotify_tbl, 6);
 	atomic_t inotify_watches; /* How many inotify watches does this user have? */
 	atomic_t inotify_devs;	/* How many inotify devs does this user have opened? */
 #endif
diff --git a/kernel/user.c b/kernel/user.c
index b069ccbfb0b0..0c73b0318806 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -17,6 +17,8 @@
 #include <linux/export.h>
 #include <linux/user_namespace.h>
 #include <linux/proc_ns.h>
+#include <linux/hashtable.h>
+
 
 /*
  * userns count is 1 for root user, 1 for init_uts_ns,
@@ -94,6 +96,9 @@ struct user_struct root_user = {
 	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
 	.uid		= GLOBAL_ROOT_UID,
+#ifdef CONFIG_INOTIFY_USER
+	.inotify_lock	= __SPIN_LOCK_UNLOCKED(root_user.inotify_lock),
+#endif
 };
 
 /*
@@ -184,6 +189,10 @@ struct user_struct *alloc_uid(kuid_t uid)
 
 		new->uid = uid;
 		atomic_set(&new->__count, 1);
+#ifdef CONFIG_INOTIFY_USER
+		spin_lock_init(&new->inotify_lock);
+		hash_init(new->inotify_tbl);
+#endif
 
 		/*
 		 * Before adding this, check whether we raced
@@ -223,6 +232,10 @@ static int __init uid_cache_init(void)
 	uid_hash_insert(&root_user, uidhashentry(GLOBAL_ROOT_UID));
 	spin_unlock_irq(&uidhash_lock);
 
+#ifdef CONFIG_INOTIFY_USER
+	hash_init(root_user.inotify_tbl);
+#endif
+
 	return 0;
 }
 subsys_initcall(uid_cache_init);
-- 
2.5.0
