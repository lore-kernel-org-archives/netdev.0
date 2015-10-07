From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 2/5] once: make helper generic for calling functions once
Date: Thu,  8 Oct 2015 01:20:36 +0200
Message-ID: <9a27fef5de706382e07d92807a2acaad10055382.1444258406.git.daniel@iogearbox.net>
References: <cover.1444258405.git.daniel@iogearbox.net>
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37258 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbbJGXUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 19:20:48 -0400
In-Reply-To: <cover.1444258405.git.daniel@iogearbox.net>
In-Reply-To: <cover.1444258405.git.daniel@iogearbox.net>
References: <cover.1444258405.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

Make the get_random_once() helper generic enough, so that functions
in general would only be called once, where one user of this is then
net_get_random_once().

The only implementation specific call is to get_random_bytes(), all
the rest of this *_once() facility would be duplicated among different
subsystems otherwise. The new DO_ONCE() helper will be used by prandom()
later on, but might also be useful for other scenarios/subsystems as
well where a one-time initialization in often-called, possibly fast
path code could occur.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/once.h | 61 ++++++++++++++++++++++++++++++++++++++++------------
 lib/once.c           | 50 ++++++++++++++++++++++++------------------
 2 files changed, 76 insertions(+), 35 deletions(-)

diff --git a/include/linux/once.h b/include/linux/once.h
index 2a83b53..285f12c 100644
--- a/include/linux/once.h
+++ b/include/linux/once.h
@@ -4,21 +4,54 @@
 #include <linux/types.h>
 #include <linux/jump_label.h>
 
-bool __get_random_once(void *buf, int nbytes, bool *done,
-		       struct static_key *once_key);
+bool __do_once_start(bool *done, unsigned long *flags);
+void __do_once_done(bool *done, struct static_key *once_key,
+		    unsigned long *flags);
 
-#define get_random_once(buf, nbytes)					\
-	({								\
-		bool ___ret = false;					\
-		static bool ___done = false;				\
-		static struct static_key ___once_key =			\
-			STATIC_KEY_INIT_TRUE;				\
-		if (static_key_true(&___once_key))			\
-			___ret = __get_random_once((buf),		\
-						   (nbytes),		\
-						   &___done,		\
-						   &___once_key);	\
-		___ret;							\
+/* Call a function exactly once. The idea of DO_ONCE() is to perform
+ * a function call such as initialization of random seeds, etc, only
+ * once, where DO_ONCE() can live in the fast-path. After @func has
+ * been called with the passed arguments, the static key will patch
+ * out the condition into a nop. DO_ONCE() guarantees type safety of
+ * arguments!
+ *
+ * Not that the following is not equivalent ...
+ *
+ *   DO_ONCE(func, arg);
+ *   DO_ONCE(func, arg);
+ *
+ * ... to this version:
+ *
+ *   void foo(void)
+ *   {
+ *     DO_ONCE(func, arg);
+ *   }
+ *
+ *   foo();
+ *   foo();
+ *
+ * In case the one-time invocation could be triggered from multiple
+ * places, then a common helper function must be defined, so that only
+ * a single static key will be placed there!
+ */
+#define DO_ONCE(func, ...)						     \
+	({								     \
+		bool ___ret = false;					     \
+		static bool ___done = false;				     \
+		static struct static_key ___once_key = STATIC_KEY_INIT_TRUE; \
+		if (static_key_true(&___once_key)) {			     \
+			unsigned long ___flags;				     \
+			___ret = __do_once_start(&___done, &___flags);	     \
+			if (unlikely(___ret)) {				     \
+				func(__VA_ARGS__);			     \
+				__do_once_done(&___done, &___once_key,	     \
+					       &___flags);		     \
+			}						     \
+		}							     \
+		___ret;							     \
 	})
 
+#define get_random_once(buf, nbytes)					     \
+	DO_ONCE(get_random_bytes, (buf), (nbytes))
+
 #endif /* _LINUX_ONCE_H */
diff --git a/lib/once.c b/lib/once.c
index 2d5a7de..05c8604 100644
--- a/lib/once.c
+++ b/lib/once.c
@@ -3,52 +3,60 @@
 #include <linux/once.h>
 #include <linux/random.h>
 
-struct __random_once_work {
+struct once_work {
 	struct work_struct work;
 	struct static_key *key;
 };
 
-static void __random_once_deferred(struct work_struct *w)
+static void once_deferred(struct work_struct *w)
 {
-	struct __random_once_work *work;
+	struct once_work *work;
 
-	work = container_of(w, struct __random_once_work, work);
+	work = container_of(w, struct once_work, work);
 	BUG_ON(!static_key_enabled(work->key));
 	static_key_slow_dec(work->key);
 	kfree(work);
 }
 
-static void __random_once_disable_jump(struct static_key *key)
+static void once_disable_jump(struct static_key *key)
 {
-	struct __random_once_work *w;
+	struct once_work *w;
 
 	w = kmalloc(sizeof(*w), GFP_ATOMIC);
 	if (!w)
 		return;
 
-	INIT_WORK(&w->work, __random_once_deferred);
+	INIT_WORK(&w->work, once_deferred);
 	w->key = key;
 	schedule_work(&w->work);
 }
 
-bool __get_random_once(void *buf, int nbytes, bool *done,
-		       struct static_key *once_key)
-{
-	static DEFINE_SPINLOCK(lock);
-	unsigned long flags;
+static DEFINE_SPINLOCK(once_lock);
 
-	spin_lock_irqsave(&lock, flags);
+bool __do_once_start(bool *done, unsigned long *flags)
+	__acquires(once_lock)
+{
+	spin_lock_irqsave(&once_lock, *flags);
 	if (*done) {
-		spin_unlock_irqrestore(&lock, flags);
+		spin_unlock_irqrestore(&once_lock, *flags);
+		/* Keep sparse happy by restoring an even lock count on
+		 * this lock. In case we return here, we don't call into
+		 * __do_once_done but return early in the DO_ONCE() macro.
+		 */
+		__acquire(once_lock);
 		return false;
 	}
 
-	get_random_bytes(buf, nbytes);
-	*done = true;
-	spin_unlock_irqrestore(&lock, flags);
-
-	__random_once_disable_jump(once_key);
-
 	return true;
 }
-EXPORT_SYMBOL(__get_random_once);
+EXPORT_SYMBOL(__do_once_start);
+
+void __do_once_done(bool *done, struct static_key *once_key,
+		    unsigned long *flags)
+	__releases(once_lock)
+{
+	*done = true;
+	spin_unlock_irqrestore(&once_lock, *flags);
+	once_disable_jump(once_key);
+}
+EXPORT_SYMBOL(__do_once_done);
-- 
1.9.3
