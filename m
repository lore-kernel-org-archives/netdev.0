From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 03/15] userns: Convert security/keys to the new userns infrastructure
Date: Sat, 25 Aug 2012 16:59:39 -0700
Message-ID: <87393ah6ac.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Cc: linux-security-module@vger.kernel.org
Cc: keyrings@linux-nfs.org
Cc: David Howells <dhowells@redhat.com>
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- Replace key_user ->user_ns equality checks with kuid_has_mapping checks.
- Use from_kuid to generate key descriptions
- Use kuid_t and kgid_t and the associated helpers instead of uid_t and gid_t
- Avoid potential problems with file descriptor passing by displaying
  keys in the user namespace of the opener of key status proc files.

Cc: linux-security-module@vger.kernel.org
Cc: keyrings@linux-nfs.org
Cc: David Howells <dhowells@redhat.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/key.h          |    9 ++++---
 init/Kconfig                 |    1 -
 security/keys/internal.h     |    6 +---
 security/keys/key.c          |   23 ++++++------------
 security/keys/keyctl.c       |   50 +++++++++++++++++++++++++----------------
 security/keys/keyring.c      |    4 +-
 security/keys/permission.c   |   14 +++--------
 security/keys/proc.c         |   44 ++++++++++++++++++------------------
 security/keys/process_keys.c |   15 ++++++------
 security/keys/request_key.c  |    6 ++--
 10 files changed, 84 insertions(+), 88 deletions(-)

diff --git a/include/linux/key.h b/include/linux/key.h
index cef3b31..2393b1c 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -24,6 +24,7 @@
 #include <linux/atomic.h>
 
 #ifdef __KERNEL__
+#include <linux/uidgid.h>
 
 /* key handle serial number */
 typedef int32_t key_serial_t;
@@ -137,8 +138,8 @@ struct key {
 		time_t		revoked_at;	/* time at which key was revoked */
 	};
 	time_t			last_used_at;	/* last time used for LRU keyring discard */
-	uid_t			uid;
-	gid_t			gid;
+	kuid_t			uid;
+	kgid_t			gid;
 	key_perm_t		perm;		/* access permissions */
 	unsigned short		quotalen;	/* length added to quota */
 	unsigned short		datalen;	/* payload data length
@@ -193,7 +194,7 @@ struct key {
 
 extern struct key *key_alloc(struct key_type *type,
 			     const char *desc,
-			     uid_t uid, gid_t gid,
+			     kuid_t uid, kgid_t gid,
 			     const struct cred *cred,
 			     key_perm_t perm,
 			     unsigned long flags);
@@ -262,7 +263,7 @@ extern int key_link(struct key *keyring,
 extern int key_unlink(struct key *keyring,
 		      struct key *key);
 
-extern struct key *keyring_alloc(const char *description, uid_t uid, gid_t gid,
+extern struct key *keyring_alloc(const char *description, kuid_t uid, kgid_t gid,
 				 const struct cred *cred,
 				 unsigned long flags,
 				 struct key *dest);
diff --git a/init/Kconfig b/init/Kconfig
index fdabc51..d7f73bb 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -928,7 +928,6 @@ config UIDGID_CONVERTED
 	depends on SYSVIPC = n
 	depends on IMA = n
 	depends on EVM = n
-	depends on KEYS = n
 	depends on AUDIT = n
 	depends on AUDITSYSCALL = n
 	depends on TASKSTATS = n
diff --git a/security/keys/internal.h b/security/keys/internal.h
index 22ff052..8bbefc3 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -52,8 +52,7 @@ struct key_user {
 	atomic_t		usage;		/* for accessing qnkeys & qnbytes */
 	atomic_t		nkeys;		/* number of keys */
 	atomic_t		nikeys;		/* number of instantiated keys */
-	uid_t			uid;
-	struct user_namespace	*user_ns;
+	kuid_t			uid;
 	int			qnkeys;		/* number of keys allocated to this user */
 	int			qnbytes;	/* number of bytes allocated to this user */
 };
@@ -62,8 +61,7 @@ extern struct rb_root	key_user_tree;
 extern spinlock_t	key_user_lock;
 extern struct key_user	root_key_user;
 
-extern struct key_user *key_user_lookup(uid_t uid,
-					struct user_namespace *user_ns);
+extern struct key_user *key_user_lookup(kuid_t uid);
 extern void key_user_put(struct key_user *user);
 
 /*
diff --git a/security/keys/key.c b/security/keys/key.c
index 50d96d4..4289c5b 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -18,7 +18,6 @@
 #include <linux/workqueue.h>
 #include <linux/random.h>
 #include <linux/err.h>
-#include <linux/user_namespace.h>
 #include "internal.h"
 
 struct kmem_cache *key_jar;
@@ -52,7 +51,7 @@ void __key_check(const struct key *key)
  * Get the key quota record for a user, allocating a new record if one doesn't
  * already exist.
  */
-struct key_user *key_user_lookup(uid_t uid, struct user_namespace *user_ns)
+struct key_user *key_user_lookup(kuid_t uid)
 {
 	struct key_user *candidate = NULL, *user;
 	struct rb_node *parent = NULL;
@@ -67,13 +66,9 @@ try_again:
 		parent = *p;
 		user = rb_entry(parent, struct key_user, node);
 
-		if (uid < user->uid)
+		if (uid_lt(uid, user->uid))
 			p = &(*p)->rb_left;
-		else if (uid > user->uid)
-			p = &(*p)->rb_right;
-		else if (user_ns < user->user_ns)
-			p = &(*p)->rb_left;
-		else if (user_ns > user->user_ns)
+		else if (uid_gt(uid, user->uid))
 			p = &(*p)->rb_right;
 		else
 			goto found;
@@ -102,7 +97,6 @@ try_again:
 	atomic_set(&candidate->nkeys, 0);
 	atomic_set(&candidate->nikeys, 0);
 	candidate->uid = uid;
-	candidate->user_ns = get_user_ns(user_ns);
 	candidate->qnkeys = 0;
 	candidate->qnbytes = 0;
 	spin_lock_init(&candidate->lock);
@@ -131,7 +125,6 @@ void key_user_put(struct key_user *user)
 	if (atomic_dec_and_lock(&user->usage, &key_user_lock)) {
 		rb_erase(&user->node, &key_user_tree);
 		spin_unlock(&key_user_lock);
-		put_user_ns(user->user_ns);
 
 		kfree(user);
 	}
@@ -229,7 +222,7 @@ serial_exists:
  * key_alloc() calls don't race with module unloading.
  */
 struct key *key_alloc(struct key_type *type, const char *desc,
-		      uid_t uid, gid_t gid, const struct cred *cred,
+		      kuid_t uid, kgid_t gid, const struct cred *cred,
 		      key_perm_t perm, unsigned long flags)
 {
 	struct key_user *user = NULL;
@@ -253,16 +246,16 @@ struct key *key_alloc(struct key_type *type, const char *desc,
 	quotalen = desclen + type->def_datalen;
 
 	/* get hold of the key tracking for this user */
-	user = key_user_lookup(uid, cred->user_ns);
+	user = key_user_lookup(uid);
 	if (!user)
 		goto no_memory_1;
 
 	/* check that the user's quota permits allocation of another key and
 	 * its description */
 	if (!(flags & KEY_ALLOC_NOT_IN_QUOTA)) {
-		unsigned maxkeys = (uid == 0) ?
+		unsigned maxkeys = uid_eq(uid, GLOBAL_ROOT_UID) ?
 			key_quota_root_maxkeys : key_quota_maxkeys;
-		unsigned maxbytes = (uid == 0) ?
+		unsigned maxbytes = uid_eq(uid, GLOBAL_ROOT_UID) ?
 			key_quota_root_maxbytes : key_quota_maxbytes;
 
 		spin_lock(&user->lock);
@@ -380,7 +373,7 @@ int key_payload_reserve(struct key *key, size_t datalen)
 
 	/* contemplate the quota adjustment */
 	if (delta != 0 && test_bit(KEY_FLAG_IN_QUOTA, &key->flags)) {
-		unsigned maxbytes = (key->user->uid == 0) ?
+		unsigned maxbytes = uid_eq(key->user->uid, GLOBAL_ROOT_UID) ?
 			key_quota_root_maxbytes : key_quota_maxbytes;
 
 		spin_lock(&key->user->lock);
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 3364fbf..1ecc0f7 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -569,8 +569,8 @@ okay:
 	ret = snprintf(tmpbuf, PAGE_SIZE - 1,
 		       "%s;%d;%d;%08x;%s",
 		       key->type->name,
-		       key->uid,
-		       key->gid,
+		       from_kuid_munged(current_user_ns(), key->uid),
+		       from_kgid_munged(current_user_ns(), key->gid),
 		       key->perm,
 		       key->description ?: "");
 
@@ -766,15 +766,25 @@ error:
  *
  * If successful, 0 will be returned.
  */
-long keyctl_chown_key(key_serial_t id, uid_t uid, gid_t gid)
+long keyctl_chown_key(key_serial_t id, uid_t user, gid_t group)
 {
 	struct key_user *newowner, *zapowner = NULL;
 	struct key *key;
 	key_ref_t key_ref;
 	long ret;
+	kuid_t uid;
+	kgid_t gid;
+
+	uid = make_kuid(current_user_ns(), user);
+	gid = make_kgid(current_user_ns(), group);
+	ret = -EINVAL;
+	if ((user != (uid_t) -1) && !uid_valid(uid))
+		goto error;
+	if ((group != (gid_t) -1) && !gid_valid(gid))
+		goto error;
 
 	ret = 0;
-	if (uid == (uid_t) -1 && gid == (gid_t) -1)
+	if (user == (uid_t) -1 && group == (gid_t) -1)
 		goto error;
 
 	key_ref = lookup_user_key(id, KEY_LOOKUP_CREATE | KEY_LOOKUP_PARTIAL,
@@ -792,27 +802,27 @@ long keyctl_chown_key(key_serial_t id, uid_t uid, gid_t gid)
 
 	if (!capable(CAP_SYS_ADMIN)) {
 		/* only the sysadmin can chown a key to some other UID */
-		if (uid != (uid_t) -1 && key->uid != uid)
+		if (user != (uid_t) -1 && !uid_eq(key->uid, uid))
 			goto error_put;
 
 		/* only the sysadmin can set the key's GID to a group other
 		 * than one of those that the current process subscribes to */
-		if (gid != (gid_t) -1 && gid != key->gid && !in_group_p(gid))
+		if (group != (gid_t) -1 && !gid_eq(gid, key->gid) && !in_group_p(gid))
 			goto error_put;
 	}
 
 	/* change the UID */
-	if (uid != (uid_t) -1 && uid != key->uid) {
+	if (user != (uid_t) -1 && !uid_eq(uid, key->uid)) {
 		ret = -ENOMEM;
-		newowner = key_user_lookup(uid, current_user_ns());
+		newowner = key_user_lookup(uid);
 		if (!newowner)
 			goto error_put;
 
 		/* transfer the quota burden to the new user */
 		if (test_bit(KEY_FLAG_IN_QUOTA, &key->flags)) {
-			unsigned maxkeys = (uid == 0) ?
+			unsigned maxkeys = uid_eq(uid, GLOBAL_ROOT_UID) ?
 				key_quota_root_maxkeys : key_quota_maxkeys;
-			unsigned maxbytes = (uid == 0) ?
+			unsigned maxbytes = uid_eq(uid, GLOBAL_ROOT_UID) ?
 				key_quota_root_maxbytes : key_quota_maxbytes;
 
 			spin_lock(&newowner->lock);
@@ -846,7 +856,7 @@ long keyctl_chown_key(key_serial_t id, uid_t uid, gid_t gid)
 	}
 
 	/* change the GID */
-	if (gid != (gid_t) -1)
+	if (group != (gid_t) -1)
 		key->gid = gid;
 
 	ret = 0;
@@ -897,7 +907,7 @@ long keyctl_setperm_key(key_serial_t id, key_perm_t perm)
 	down_write(&key->sem);
 
 	/* if we're not the sysadmin, we can only change a key that we own */
-	if (capable(CAP_SYS_ADMIN) || key->uid == current_fsuid()) {
+	if (capable(CAP_SYS_ADMIN) || uid_eq(key->uid, current_fsuid())) {
 		key->perm = perm;
 		ret = 0;
 	}
@@ -1507,18 +1517,18 @@ long keyctl_session_to_parent(void)
 
 	/* the parent must have the same effective ownership and mustn't be
 	 * SUID/SGID */
-	if (pcred->uid	!= mycred->euid	||
-	    pcred->euid	!= mycred->euid	||
-	    pcred->suid	!= mycred->euid	||
-	    pcred->gid	!= mycred->egid	||
-	    pcred->egid	!= mycred->egid	||
-	    pcred->sgid	!= mycred->egid)
+	if (!uid_eq(pcred->uid,	 mycred->euid) ||
+	    !uid_eq(pcred->euid, mycred->euid) ||
+	    !uid_eq(pcred->suid, mycred->euid) ||
+	    !gid_eq(pcred->gid,	 mycred->egid) ||
+	    !gid_eq(pcred->egid, mycred->egid) ||
+	    !gid_eq(pcred->sgid, mycred->egid))
 		goto unlock;
 
 	/* the keyrings must have the same UID */
 	if ((pcred->tgcred->session_keyring &&
-	     pcred->tgcred->session_keyring->uid != mycred->euid) ||
-	    mycred->tgcred->session_keyring->uid != mycred->euid)
+	     !uid_eq(pcred->tgcred->session_keyring->uid, mycred->euid)) ||
+	    !uid_eq(mycred->tgcred->session_keyring->uid, mycred->euid))
 		goto unlock;
 
 	/* cancel an already pending keyring replacement */
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 81e7852..a5f5c4b 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -256,7 +256,7 @@ error:
 /*
  * Allocate a keyring and link into the destination keyring.
  */
-struct key *keyring_alloc(const char *description, uid_t uid, gid_t gid,
+struct key *keyring_alloc(const char *description, kuid_t uid, kgid_t gid,
 			  const struct cred *cred, unsigned long flags,
 			  struct key *dest)
 {
@@ -612,7 +612,7 @@ struct key *find_keyring_by_name(const char *name, bool skip_perm_check)
 				    &keyring_name_hash[bucket],
 				    type_data.link
 				    ) {
-			if (keyring->user->user_ns != current_user_ns())
+			if (!kuid_has_mapping(current_user_ns(), keyring->user->uid))
 				continue;
 
 			if (test_bit(KEY_FLAG_REVOKED, &keyring->flags))
diff --git a/security/keys/permission.c b/security/keys/permission.c
index 0b4d019..efcc0c8 100644
--- a/security/keys/permission.c
+++ b/security/keys/permission.c
@@ -36,33 +36,27 @@ int key_task_permission(const key_ref_t key_ref, const struct cred *cred,
 
 	key = key_ref_to_ptr(key_ref);
 
-	if (key->user->user_ns != cred->user_ns)
-		goto use_other_perms;
-
 	/* use the second 8-bits of permissions for keys the caller owns */
-	if (key->uid == cred->fsuid) {
+	if (uid_eq(key->uid, cred->fsuid)) {
 		kperm = key->perm >> 16;
 		goto use_these_perms;
 	}
 
 	/* use the third 8-bits of permissions for keys the caller has a group
 	 * membership in common with */
-	if (key->gid != -1 && key->perm & KEY_GRP_ALL) {
-		if (key->gid == cred->fsgid) {
+	if (gid_valid(key->gid) && key->perm & KEY_GRP_ALL) {
+		if (gid_eq(key->gid, cred->fsgid)) {
 			kperm = key->perm >> 8;
 			goto use_these_perms;
 		}
 
-		ret = groups_search(cred->group_info,
-				    make_kgid(current_user_ns(), key->gid));
+		ret = groups_search(cred->group_info, key->gid);
 		if (ret) {
 			kperm = key->perm >> 8;
 			goto use_these_perms;
 		}
 	}
 
-use_other_perms:
-
 	/* otherwise use the least-significant 8-bits */
 	kperm = key->perm;
 
diff --git a/security/keys/proc.c b/security/keys/proc.c
index 30d1ddf..217b685 100644
--- a/security/keys/proc.c
+++ b/security/keys/proc.c
@@ -88,14 +88,14 @@ __initcall(key_proc_init);
  */
 #ifdef CONFIG_KEYS_DEBUG_PROC_KEYS
 
-static struct rb_node *key_serial_next(struct rb_node *n)
+static struct rb_node *key_serial_next(struct seq_file *p, struct rb_node *n)
 {
-	struct user_namespace *user_ns = current_user_ns();
+	struct user_namespace *user_ns = seq_user_ns(p);
 
 	n = rb_next(n);
 	while (n) {
 		struct key *key = rb_entry(n, struct key, serial_node);
-		if (key->user->user_ns == user_ns)
+		if (kuid_has_mapping(user_ns, key->user->uid))
 			break;
 		n = rb_next(n);
 	}
@@ -107,9 +107,9 @@ static int proc_keys_open(struct inode *inode, struct file *file)
 	return seq_open(file, &proc_keys_ops);
 }
 
-static struct key *find_ge_key(key_serial_t id)
+static struct key *find_ge_key(struct seq_file *p, key_serial_t id)
 {
-	struct user_namespace *user_ns = current_user_ns();
+	struct user_namespace *user_ns = seq_user_ns(p);
 	struct rb_node *n = key_serial_tree.rb_node;
 	struct key *minkey = NULL;
 
@@ -132,7 +132,7 @@ static struct key *find_ge_key(key_serial_t id)
 		return NULL;
 
 	for (;;) {
-		if (minkey->user->user_ns == user_ns)
+		if (kuid_has_mapping(user_ns, minkey->user->uid))
 			return minkey;
 		n = rb_next(&minkey->serial_node);
 		if (!n)
@@ -151,7 +151,7 @@ static void *proc_keys_start(struct seq_file *p, loff_t *_pos)
 
 	if (*_pos > INT_MAX)
 		return NULL;
-	key = find_ge_key(pos);
+	key = find_ge_key(p, pos);
 	if (!key)
 		return NULL;
 	*_pos = key->serial;
@@ -168,7 +168,7 @@ static void *proc_keys_next(struct seq_file *p, void *v, loff_t *_pos)
 {
 	struct rb_node *n;
 
-	n = key_serial_next(v);
+	n = key_serial_next(p, v);
 	if (n)
 		*_pos = key_node_serial(n);
 	return n;
@@ -254,8 +254,8 @@ static int proc_keys_show(struct seq_file *m, void *v)
 		   atomic_read(&key->usage),
 		   xbuf,
 		   key->perm,
-		   key->uid,
-		   key->gid,
+		   from_kuid_munged(seq_user_ns(m), key->uid),
+		   from_kgid_munged(seq_user_ns(m), key->gid),
 		   key->type->name);
 
 #undef showflag
@@ -270,26 +270,26 @@ static int proc_keys_show(struct seq_file *m, void *v)
 
 #endif /* CONFIG_KEYS_DEBUG_PROC_KEYS */
 
-static struct rb_node *__key_user_next(struct rb_node *n)
+static struct rb_node *__key_user_next(struct user_namespace *user_ns, struct rb_node *n)
 {
 	while (n) {
 		struct key_user *user = rb_entry(n, struct key_user, node);
-		if (user->user_ns == current_user_ns())
+		if (kuid_has_mapping(user_ns, user->uid))
 			break;
 		n = rb_next(n);
 	}
 	return n;
 }
 
-static struct rb_node *key_user_next(struct rb_node *n)
+static struct rb_node *key_user_next(struct user_namespace *user_ns, struct rb_node *n)
 {
-	return __key_user_next(rb_next(n));
+	return __key_user_next(user_ns, rb_next(n));
 }
 
-static struct rb_node *key_user_first(struct rb_root *r)
+static struct rb_node *key_user_first(struct user_namespace *user_ns, struct rb_root *r)
 {
 	struct rb_node *n = rb_first(r);
-	return __key_user_next(n);
+	return __key_user_next(user_ns, n);
 }
 
 /*
@@ -309,10 +309,10 @@ static void *proc_key_users_start(struct seq_file *p, loff_t *_pos)
 
 	spin_lock(&key_user_lock);
 
-	_p = key_user_first(&key_user_tree);
+	_p = key_user_first(seq_user_ns(p), &key_user_tree);
 	while (pos > 0 && _p) {
 		pos--;
-		_p = key_user_next(_p);
+		_p = key_user_next(seq_user_ns(p), _p);
 	}
 
 	return _p;
@@ -321,7 +321,7 @@ static void *proc_key_users_start(struct seq_file *p, loff_t *_pos)
 static void *proc_key_users_next(struct seq_file *p, void *v, loff_t *_pos)
 {
 	(*_pos)++;
-	return key_user_next((struct rb_node *)v);
+	return key_user_next(seq_user_ns(p), (struct rb_node *)v);
 }
 
 static void proc_key_users_stop(struct seq_file *p, void *v)
@@ -334,13 +334,13 @@ static int proc_key_users_show(struct seq_file *m, void *v)
 {
 	struct rb_node *_p = v;
 	struct key_user *user = rb_entry(_p, struct key_user, node);
-	unsigned maxkeys = (user->uid == 0) ?
+	unsigned maxkeys = uid_eq(user->uid, GLOBAL_ROOT_UID) ?
 		key_quota_root_maxkeys : key_quota_maxkeys;
-	unsigned maxbytes = (user->uid == 0) ?
+	unsigned maxbytes = uid_eq(user->uid, GLOBAL_ROOT_UID) ?
 		key_quota_root_maxbytes : key_quota_maxbytes;
 
 	seq_printf(m, "%5u: %5d %d/%d %d/%d %d/%d\n",
-		   user->uid,
+		   from_kuid_munged(seq_user_ns(m), user->uid),
 		   atomic_read(&user->usage),
 		   atomic_read(&user->nkeys),
 		   atomic_read(&user->nikeys),
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 54339cf..a58f712 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -34,8 +34,7 @@ struct key_user root_key_user = {
 	.lock		= __SPIN_LOCK_UNLOCKED(root_key_user.lock),
 	.nkeys		= ATOMIC_INIT(2),
 	.nikeys		= ATOMIC_INIT(2),
-	.uid		= 0,
-	.user_ns	= &init_user_ns,
+	.uid		= GLOBAL_ROOT_UID,
 };
 
 /*
@@ -48,11 +47,13 @@ int install_user_keyrings(void)
 	struct key *uid_keyring, *session_keyring;
 	char buf[20];
 	int ret;
+	uid_t uid;
 
 	cred = current_cred();
 	user = cred->user;
+	uid = from_kuid(cred->user_ns, user->uid);
 
-	kenter("%p{%u}", user, user->uid);
+	kenter("%p{%u}", user, uid);
 
 	if (user->uid_keyring) {
 		kleave(" = 0 [exist]");
@@ -67,11 +68,11 @@ int install_user_keyrings(void)
 		 * - there may be one in existence already as it may have been
 		 *   pinned by a session, but the user_struct pointing to it
 		 *   may have been destroyed by setuid */
-		sprintf(buf, "_uid.%u", user->uid);
+		sprintf(buf, "_uid.%u", uid);
 
 		uid_keyring = find_keyring_by_name(buf, true);
 		if (IS_ERR(uid_keyring)) {
-			uid_keyring = keyring_alloc(buf, user->uid, (gid_t) -1,
+			uid_keyring = keyring_alloc(buf, user->uid, INVALID_GID,
 						    cred, KEY_ALLOC_IN_QUOTA,
 						    NULL);
 			if (IS_ERR(uid_keyring)) {
@@ -82,12 +83,12 @@ int install_user_keyrings(void)
 
 		/* get a default session keyring (which might also exist
 		 * already) */
-		sprintf(buf, "_uid_ses.%u", user->uid);
+		sprintf(buf, "_uid_ses.%u", uid);
 
 		session_keyring = find_keyring_by_name(buf, true);
 		if (IS_ERR(session_keyring)) {
 			session_keyring =
-				keyring_alloc(buf, user->uid, (gid_t) -1,
+				keyring_alloc(buf, user->uid, INVALID_GID,
 					      cred, KEY_ALLOC_IN_QUOTA, NULL);
 			if (IS_ERR(session_keyring)) {
 				ret = PTR_ERR(session_keyring);
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 000e750..66e2118 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -139,8 +139,8 @@ static int call_sbin_request_key(struct key_construction *cons,
 		goto error_link;
 
 	/* record the UID and GID */
-	sprintf(uid_str, "%d", cred->fsuid);
-	sprintf(gid_str, "%d", cred->fsgid);
+	sprintf(uid_str, "%d", from_kuid(&init_user_ns, cred->fsuid));
+	sprintf(gid_str, "%d", from_kgid(&init_user_ns, cred->fsgid));
 
 	/* we say which key is under construction */
 	sprintf(key_str, "%d", key->serial);
@@ -442,7 +442,7 @@ static struct key *construct_key_and_link(struct key_type *type,
 
 	kenter("");
 
-	user = key_user_lookup(current_fsuid(), current_user_ns());
+	user = key_user_lookup(current_fsuid());
 	if (!user)
 		return ERR_PTR(-ENOMEM);
 
-- 
1.7.5.4

