From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 1/3] security: keys: Replace time_t/timespec with time64_t
Date: Wed,  9 Aug 2017 10:51:30 +0800
Message-ID: <a67995987cef9817e226d0887f26a7de48bca3b3.1502246502.git.baolin.wang@linaro.org>
References: <cover.1502246501.git.baolin.wang@linaro.org>
Cc: james.l.morris@oracle.com, serge@hallyn.com,
        marc.dionne@auristor.com, dan.carpenter@oracle.com,
        Jason@zx2c4.com, arnd@arndb.de, broonie@kernel.org,
        keyrings@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        baolin.wang@linaro.org
To: dhowells@redhat.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502246501.git.baolin.wang@linaro.org>
In-Reply-To: <cover.1502246501.git.baolin.wang@linaro.org>
References: <cover.1502246501.git.baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 'struct key' will use 'time_t' which we try to remove in the
kernel, since 'time_t' is not year 2038 safe on 32bit systems.
Also the 'struct keyring_search_context' will use 'timespec' type
to record current time, which is also not year 2038 safe on 32bit
systems.

Thus this patch replaces 'time_t' with 'time64_t' which is year 2038
safe for 'struct key', and replace 'timespec' with 'time64_t' for the
'struct keyring_search_context', since we only look at the the seconds
part of 'timespec' variable. Moreover we also change the codes where
using the 'time_t' and 'timespec', and we can get current time by
ktime_get_real_seconds() instead of current_kernel_time(), and use
'TIME64_MAX' macro to initialize the 'time64_t' type variable.

Especially in proc.c file, we have replaced 'unsigned long' and 'timespec'
type with 'u64' and 'time64_t' type to save the timeout value, which means
user will get one 'u64' type timeout value by issuing proc_keys_show()
function.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 include/linux/key.h          |    7 ++++---
 security/keys/gc.c           |   20 ++++++++++----------
 security/keys/internal.h     |    8 ++++----
 security/keys/key.c          |   19 ++++++-------------
 security/keys/keyring.c      |   18 +++++++++---------
 security/keys/permission.c   |    3 +--
 security/keys/proc.c         |   20 ++++++++++----------
 security/keys/process_keys.c |    2 +-
 8 files changed, 45 insertions(+), 52 deletions(-)

diff --git a/include/linux/key.h b/include/linux/key.h
index 0441141..6d10f84 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -24,6 +24,7 @@
 #include <linux/atomic.h>
 #include <linux/assoc_array.h>
 #include <linux/refcount.h>
+#include <linux/time64.h>
 
 #ifdef __KERNEL__
 #include <linux/uidgid.h>
@@ -157,10 +158,10 @@ struct key {
 	struct key_user		*user;		/* owner of this key */
 	void			*security;	/* security data for this key */
 	union {
-		time_t		expiry;		/* time at which key expires (or 0) */
-		time_t		revoked_at;	/* time at which key was revoked */
+		time64_t	expiry;		/* time at which key expires (or 0) */
+		time64_t	revoked_at;	/* time at which key was revoked */
 	};
-	time_t			last_used_at;	/* last time used for LRU keyring discard */
+	time64_t		last_used_at;	/* last time used for LRU keyring discard */
 	kuid_t			uid;
 	kgid_t			gid;
 	key_perm_t		perm;		/* access permissions */
diff --git a/security/keys/gc.c b/security/keys/gc.c
index 87cb260..c99700e 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -32,7 +32,7 @@
 static void key_gc_timer_func(unsigned long);
 static DEFINE_TIMER(key_gc_timer, key_gc_timer_func, 0, 0);
 
-static time_t key_gc_next_run = LONG_MAX;
+static time64_t key_gc_next_run = TIME64_MAX;
 static struct key_type *key_gc_dead_keytype;
 
 static unsigned long key_gc_flags;
@@ -53,12 +53,12 @@ struct key_type key_type_dead = {
  * Schedule a garbage collection run.
  * - time precision isn't particularly important
  */
-void key_schedule_gc(time_t gc_at)
+void key_schedule_gc(time64_t gc_at)
 {
 	unsigned long expires;
-	time_t now = current_kernel_time().tv_sec;
+	time64_t now = ktime_get_real_seconds();
 
-	kenter("%ld", gc_at - now);
+	kenter("%lld", gc_at - now);
 
 	if (gc_at <= now || test_bit(KEY_GC_REAP_KEYTYPE, &key_gc_flags)) {
 		kdebug("IMMEDIATE");
@@ -87,7 +87,7 @@ void key_schedule_gc_links(void)
 static void key_gc_timer_func(unsigned long data)
 {
 	kenter("");
-	key_gc_next_run = LONG_MAX;
+	key_gc_next_run = TIME64_MAX;
 	key_schedule_gc_links();
 }
 
@@ -184,11 +184,11 @@ static void key_garbage_collector(struct work_struct *work)
 
 	struct rb_node *cursor;
 	struct key *key;
-	time_t new_timer, limit;
+	time64_t new_timer, limit;
 
 	kenter("[%lx,%x]", key_gc_flags, gc_state);
 
-	limit = current_kernel_time().tv_sec;
+	limit = ktime_get_real_seconds();
 	if (limit > key_gc_delay)
 		limit -= key_gc_delay;
 	else
@@ -204,7 +204,7 @@ static void key_garbage_collector(struct work_struct *work)
 		gc_state |= KEY_GC_REAPING_DEAD_1;
 	kdebug("new pass %x", gc_state);
 
-	new_timer = LONG_MAX;
+	new_timer = TIME64_MAX;
 
 	/* As only this function is permitted to remove things from the key
 	 * serial tree, if cursor is non-NULL then it will always point to a
@@ -235,7 +235,7 @@ static void key_garbage_collector(struct work_struct *work)
 
 		if (gc_state & KEY_GC_SET_TIMER) {
 			if (key->expiry > limit && key->expiry < new_timer) {
-				kdebug("will expire %x in %ld",
+				kdebug("will expire %x in %lld",
 				       key_serial(key), key->expiry - limit);
 				new_timer = key->expiry;
 			}
@@ -276,7 +276,7 @@ static void key_garbage_collector(struct work_struct *work)
 	 */
 	kdebug("pass complete");
 
-	if (gc_state & KEY_GC_SET_TIMER && new_timer != (time_t)LONG_MAX) {
+	if (gc_state & KEY_GC_SET_TIMER && new_timer != (time64_t)TIME64_MAX) {
 		new_timer += key_gc_delay;
 		key_schedule_gc(new_timer);
 	}
diff --git a/security/keys/internal.h b/security/keys/internal.h
index 91bc621..e23ffbc 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -130,7 +130,7 @@ struct keyring_search_context {
 	int			skipped_ret;
 	bool			possessed;
 	key_ref_t		result;
-	struct timespec		now;
+	time64_t		now;
 };
 
 extern bool key_default_cmp(const struct key *key,
@@ -169,10 +169,10 @@ extern key_ref_t lookup_user_key(key_serial_t id, unsigned long flags,
 
 extern struct work_struct key_gc_work;
 extern unsigned key_gc_delay;
-extern void keyring_gc(struct key *keyring, time_t limit);
+extern void keyring_gc(struct key *keyring, time64_t limit);
 extern void keyring_restriction_gc(struct key *keyring,
 				   struct key_type *dead_type);
-extern void key_schedule_gc(time_t gc_at);
+extern void key_schedule_gc(time64_t gc_at);
 extern void key_schedule_gc_links(void);
 extern void key_gc_keytype(struct key_type *ktype);
 
@@ -211,7 +211,7 @@ extern struct key *request_key_auth_new(struct key *target,
 /*
  * Determine whether a key is dead.
  */
-static inline bool key_is_dead(const struct key *key, time_t limit)
+static inline bool key_is_dead(const struct key *key, time64_t limit)
 {
 	return
 		key->flags & ((1 << KEY_FLAG_DEAD) |
diff --git a/security/keys/key.c b/security/keys/key.c
index 83da68d..291a67c 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -556,7 +556,6 @@ int key_reject_and_link(struct key *key,
 			struct key *authkey)
 {
 	struct assoc_array_edit *edit;
-	struct timespec now;
 	int ret, awaken, link_ret = 0;
 
 	key_check(key);
@@ -582,8 +581,7 @@ int key_reject_and_link(struct key *key,
 		smp_wmb();
 		set_bit(KEY_FLAG_NEGATIVE, &key->flags);
 		set_bit(KEY_FLAG_INSTANTIATED, &key->flags);
-		now = current_kernel_time();
-		key->expiry = now.tv_sec + timeout;
+		key->expiry = ktime_get_real_seconds() + timeout;
 		key_schedule_gc(key->expiry + key_gc_delay);
 
 		if (test_and_clear_bit(KEY_FLAG_USER_CONSTRUCT, &key->flags))
@@ -699,16 +697,13 @@ struct key_type *key_type_lookup(const char *type)
 
 void key_set_timeout(struct key *key, unsigned timeout)
 {
-	struct timespec now;
-	time_t expiry = 0;
+	time64_t expiry = 0;
 
 	/* make the changes with the locks held to prevent races */
 	down_write(&key->sem);
 
-	if (timeout > 0) {
-		now = current_kernel_time();
-		expiry = now.tv_sec + timeout;
-	}
+	if (timeout > 0)
+		expiry = ktime_get_real_seconds() + timeout;
 
 	key->expiry = expiry;
 	key_schedule_gc(key->expiry + key_gc_delay);
@@ -1007,8 +1002,7 @@ int key_update(key_ref_t key_ref, const void *payload, size_t plen)
  */
 void key_revoke(struct key *key)
 {
-	struct timespec now;
-	time_t time;
+	time64_t time;
 
 	key_check(key);
 
@@ -1023,8 +1017,7 @@ void key_revoke(struct key *key)
 		key->type->revoke(key);
 
 	/* set the death time to no more than the expiry time */
-	now = current_kernel_time();
-	time = now.tv_sec;
+	time = ktime_get_real_seconds();
 	if (key->revoked_at == 0 || key->revoked_at > time) {
 		key->revoked_at = time;
 		key_schedule_gc(key->revoked_at + key_gc_delay);
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index de81793..2d82088 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -576,7 +576,7 @@ static int keyring_search_iterator(const void *object, void *iterator_data)
 			goto skipped;
 		}
 
-		if (key->expiry && ctx->now.tv_sec >= key->expiry) {
+		if (key->expiry && ctx->now >= key->expiry) {
 			if (!(ctx->flags & KEYRING_SEARCH_SKIP_EXPIRED))
 				ctx->result = ERR_PTR(-EKEYEXPIRED);
 			kleave(" = %d [expire]", ctx->skipped_ret);
@@ -837,10 +837,10 @@ static bool search_nested_keyrings(struct key *keyring,
 	key = key_ref_to_ptr(ctx->result);
 	key_check(key);
 	if (!(ctx->flags & KEYRING_SEARCH_NO_UPDATE_TIME)) {
-		key->last_used_at = ctx->now.tv_sec;
-		keyring->last_used_at = ctx->now.tv_sec;
+		key->last_used_at = ctx->now;
+		keyring->last_used_at = ctx->now;
 		while (sp > 0)
-			stack[--sp].keyring->last_used_at = ctx->now.tv_sec;
+			stack[--sp].keyring->last_used_at = ctx->now;
 	}
 	kleave(" = true");
 	return true;
@@ -901,7 +901,7 @@ key_ref_t keyring_search_aux(key_ref_t keyring_ref,
 	}
 
 	rcu_read_lock();
-	ctx->now = current_kernel_time();
+	ctx->now = ktime_get_real_seconds();
 	if (search_nested_keyrings(keyring, ctx))
 		__key_get(key_ref_to_ptr(ctx->result));
 	rcu_read_unlock();
@@ -1147,7 +1147,7 @@ struct key *find_keyring_by_name(const char *name, bool skip_perm_check)
 			 * (ie. it has a zero usage count) */
 			if (!refcount_inc_not_zero(&keyring->usage))
 				continue;
-			keyring->last_used_at = current_kernel_time().tv_sec;
+			keyring->last_used_at = ktime_get_real_seconds();
 			goto out;
 		}
 	}
@@ -1487,7 +1487,7 @@ static void keyring_revoke(struct key *keyring)
 static bool keyring_gc_select_iterator(void *object, void *iterator_data)
 {
 	struct key *key = keyring_ptr_to_key(object);
-	time_t *limit = iterator_data;
+	time64_t *limit = iterator_data;
 
 	if (key_is_dead(key, *limit))
 		return false;
@@ -1498,7 +1498,7 @@ static bool keyring_gc_select_iterator(void *object, void *iterator_data)
 static int keyring_gc_check_iterator(const void *object, void *iterator_data)
 {
 	const struct key *key = keyring_ptr_to_key(object);
-	time_t *limit = iterator_data;
+	time64_t *limit = iterator_data;
 
 	key_check(key);
 	return key_is_dead(key, *limit);
@@ -1510,7 +1510,7 @@ static int keyring_gc_check_iterator(const void *object, void *iterator_data)
  * Not called with any locks held.  The keyring's key struct will not be
  * deallocated under us as only our caller may deallocate it.
  */
-void keyring_gc(struct key *keyring, time_t limit)
+void keyring_gc(struct key *keyring, time64_t limit)
 {
 	int result;
 
diff --git a/security/keys/permission.c b/security/keys/permission.c
index 732cc0b..507b1d41 100644
--- a/security/keys/permission.c
+++ b/security/keys/permission.c
@@ -100,8 +100,7 @@ int key_validate(const struct key *key)
 
 	/* check it hasn't expired */
 	if (key->expiry) {
-		struct timespec now = current_kernel_time();
-		if (now.tv_sec >= key->expiry)
+		if (ktime_get_real_seconds() >= key->expiry)
 			return -EKEYEXPIRED;
 	}
 
diff --git a/security/keys/proc.c b/security/keys/proc.c
index bf08d02..95c8720 100644
--- a/security/keys/proc.c
+++ b/security/keys/proc.c
@@ -178,8 +178,8 @@ static int proc_keys_show(struct seq_file *m, void *v)
 {
 	struct rb_node *_p = v;
 	struct key *key = rb_entry(_p, struct key, serial_node);
-	struct timespec now;
-	unsigned long timo;
+	time64_t now;
+	u64 timo;
 	key_ref_t key_ref, skey_ref;
 	char xbuf[16];
 	int rc;
@@ -216,28 +216,28 @@ static int proc_keys_show(struct seq_file *m, void *v)
 	if (rc < 0)
 		return 0;
 
-	now = current_kernel_time();
+	now = ktime_get_real_seconds();
 
 	rcu_read_lock();
 
 	/* come up with a suitable timeout value */
 	if (key->expiry == 0) {
 		memcpy(xbuf, "perm", 5);
-	} else if (now.tv_sec >= key->expiry) {
+	} else if (now >= key->expiry) {
 		memcpy(xbuf, "expd", 5);
 	} else {
-		timo = key->expiry - now.tv_sec;
+		timo = key->expiry - now;
 
 		if (timo < 60)
-			sprintf(xbuf, "%lus", timo);
+			sprintf(xbuf, "%llus", timo);
 		else if (timo < 60*60)
-			sprintf(xbuf, "%lum", timo / 60);
+			sprintf(xbuf, "%llum", div_u64(timo, 60));
 		else if (timo < 60*60*24)
-			sprintf(xbuf, "%luh", timo / (60*60));
+			sprintf(xbuf, "%lluh", div_u64(timo, 60 * 60));
 		else if (timo < 60*60*24*7)
-			sprintf(xbuf, "%lud", timo / (60*60*24));
+			sprintf(xbuf, "%llud", div_u64(timo, 60 * 60 * 24));
 		else
-			sprintf(xbuf, "%luw", timo / (60*60*24*7));
+			sprintf(xbuf, "%lluw", div_u64(timo, 60 * 60 * 24 * 7));
 	}
 
 #define showflag(KEY, LETTER, FLAG) \
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 86bced9..c691e09 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -736,7 +736,7 @@ key_ref_t lookup_user_key(key_serial_t id, unsigned long lflags,
 	if (ret < 0)
 		goto invalid_key;
 
-	key->last_used_at = current_kernel_time().tv_sec;
+	key->last_used_at = ktime_get_real_seconds();
 
 error:
 	put_cred(ctx.cred);
-- 
1.7.9.5
