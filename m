From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] once: switch to new jump label API
Date: Mon, 21 Aug 2017 16:42:41 -0700
Message-ID: <20170821234241.88438-1-ebiggers3@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jason Baron <jbaron@akamai.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Eric Biggers <ebiggers@google.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Switch the DO_ONCE() macro from the deprecated jump label API to the new
one.  The new one is more readable, and for DO_ONCE() it also makes the
generated code more icache-friendly: now the one-time initialization
code is placed out-of-line at the jump target, rather than at the inline
fallthrough case.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/linux/once.h | 6 +++---
 lib/once.c           | 8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/once.h b/include/linux/once.h
index 9c98aaa87cbc..724724918e8b 100644
--- a/include/linux/once.h
+++ b/include/linux/once.h
@@ -5,7 +5,7 @@
 #include <linux/jump_label.h>
 
 bool __do_once_start(bool *done, unsigned long *flags);
-void __do_once_done(bool *done, struct static_key *once_key,
+void __do_once_done(bool *done, struct static_key_true *once_key,
 		    unsigned long *flags);
 
 /* Call a function exactly once. The idea of DO_ONCE() is to perform
@@ -38,8 +38,8 @@ void __do_once_done(bool *done, struct static_key *once_key,
 	({								     \
 		bool ___ret = false;					     \
 		static bool ___done = false;				     \
-		static struct static_key ___once_key = STATIC_KEY_INIT_TRUE; \
-		if (static_key_true(&___once_key)) {			     \
+		static DEFINE_STATIC_KEY_TRUE(___once_key);		     \
+		if (static_branch_unlikely(&___once_key)) {		     \
 			unsigned long ___flags;				     \
 			___ret = __do_once_start(&___done, &___flags);	     \
 			if (unlikely(___ret)) {				     \
diff --git a/lib/once.c b/lib/once.c
index 05c8604627eb..831c5a6b0bb2 100644
--- a/lib/once.c
+++ b/lib/once.c
@@ -5,7 +5,7 @@
 
 struct once_work {
 	struct work_struct work;
-	struct static_key *key;
+	struct static_key_true *key;
 };
 
 static void once_deferred(struct work_struct *w)
@@ -14,11 +14,11 @@ static void once_deferred(struct work_struct *w)
 
 	work = container_of(w, struct once_work, work);
 	BUG_ON(!static_key_enabled(work->key));
-	static_key_slow_dec(work->key);
+	static_branch_disable(work->key);
 	kfree(work);
 }
 
-static void once_disable_jump(struct static_key *key)
+static void once_disable_jump(struct static_key_true *key)
 {
 	struct once_work *w;
 
@@ -51,7 +51,7 @@ bool __do_once_start(bool *done, unsigned long *flags)
 }
 EXPORT_SYMBOL(__do_once_start);
 
-void __do_once_done(bool *done, struct static_key *once_key,
+void __do_once_done(bool *done, struct static_key_true *once_key,
 		    unsigned long *flags)
 	__releases(once_lock)
 {
-- 
2.14.1.480.gb18f417b89-goog
