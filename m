From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/5] once: make helper generic for calling function once
Date: Wed,  7 Oct 2015 15:43:53 +0200
Message-ID: <68b03e7c018609b0b56e74346e3f22ac0ad67f28.1444224502.git.daniel@iogearbox.net>
References: <cover.1444224502.git.daniel@iogearbox.net>
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45113 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbbJGNoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 09:44:01 -0400
In-Reply-To: <cover.1444224502.git.daniel@iogearbox.net>
In-Reply-To: <cover.1444224502.git.daniel@iogearbox.net>
References: <cover.1444224502.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

Make the get_random_once() helper generic enough, so that functions
in general would only be called once, where one user of this is then
net_get_random_once().

The only implementation specific call is to get_random_bytes(), all
the rest of this *_once() facility would be duplicated among different
subsystems otherwise. The new do_once() helper will be used by prandom()
later on, but might also be useful for other scenarios as well where a
one-time initialization in often-called, possibly fast-path code could
occur.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/once.h | 25 ++++++++++++++++++-------
 lib/once.c           | 34 +++++++++++++++++++++-------------
 2 files changed, 39 insertions(+), 20 deletions(-)

diff --git a/include/linux/once.h b/include/linux/once.h
index 2a83b53..f7a51d5 100644
--- a/include/linux/once.h
+++ b/include/linux/once.h
@@ -3,22 +3,33 @@
 
 #include <linux/types.h>
 #include <linux/jump_label.h>
+#include <linux/uio.h>
 
-bool __get_random_once(void *buf, int nbytes, bool *done,
-		       struct static_key *once_key);
+bool __do_once(void (*func)(void *arg), void *arg, bool *done,
+	       struct static_key *once_key);
 
-#define get_random_once(buf, nbytes)					\
+#define do_once(func, arg)						\
 	({								\
 		bool ___ret = false;					\
 		static bool ___done = false;				\
 		static struct static_key ___once_key =			\
 			STATIC_KEY_INIT_TRUE;				\
 		if (static_key_true(&___once_key))			\
-			___ret = __get_random_once((buf),		\
-						   (nbytes),		\
-						   &___done,		\
-						   &___once_key);	\
+			___ret = __do_once((func), (arg),		\
+					   &___done,			\
+					   &___once_key);		\
 		___ret;							\
 	})
 
+void get_random_once_kvec(void *arg);
+
+#define get_random_once(buf, nbytes)					\
+	({								\
+		struct kvec __v = {					\
+			.iov_base = (buf),				\
+			.iov_len = (nbytes),				\
+		};							\
+		do_once(get_random_once_kvec, &__v);			\
+	})
+
 #endif /* _LINUX_ONCE_H */
diff --git a/lib/once.c b/lib/once.c
index 2d5a7de..1e62944 100644
--- a/lib/once.c
+++ b/lib/once.c
@@ -3,36 +3,36 @@
 #include <linux/once.h>
 #include <linux/random.h>
 
-struct __random_once_work {
+struct __once_work {
 	struct work_struct work;
 	struct static_key *key;
 };
 
-static void __random_once_deferred(struct work_struct *w)
+static void __once_deferred(struct work_struct *w)
 {
-	struct __random_once_work *work;
+	struct __once_work *work;
 
-	work = container_of(w, struct __random_once_work, work);
+	work = container_of(w, struct __once_work, work);
 	BUG_ON(!static_key_enabled(work->key));
 	static_key_slow_dec(work->key);
 	kfree(work);
 }
 
-static void __random_once_disable_jump(struct static_key *key)
+static void __once_disable_jump(struct static_key *key)
 {
-	struct __random_once_work *w;
+	struct __once_work *w;
 
 	w = kmalloc(sizeof(*w), GFP_ATOMIC);
 	if (!w)
 		return;
 
-	INIT_WORK(&w->work, __random_once_deferred);
+	INIT_WORK(&w->work, __once_deferred);
 	w->key = key;
 	schedule_work(&w->work);
 }
 
-bool __get_random_once(void *buf, int nbytes, bool *done,
-		       struct static_key *once_key)
+bool __do_once(void (*func)(void *arg), void *arg, bool *done,
+	       struct static_key *once_key)
 {
 	static DEFINE_SPINLOCK(lock);
 	unsigned long flags;
@@ -43,12 +43,20 @@ bool __get_random_once(void *buf, int nbytes, bool *done,
 		return false;
 	}
 
-	get_random_bytes(buf, nbytes);
+	func(arg);
 	*done = true;
 	spin_unlock_irqrestore(&lock, flags);
 
-	__random_once_disable_jump(once_key);
-
+	__once_disable_jump(once_key);
 	return true;
 }
-EXPORT_SYMBOL(__get_random_once);
+EXPORT_SYMBOL(__do_once);
+
+/* Helper function for once users. */
+void get_random_once_kvec(void *arg)
+{
+	struct kvec *v = arg;
+
+	get_random_bytes(v->iov_base, v->iov_len);
+}
+EXPORT_SYMBOL(get_random_once_kvec);
-- 
1.9.3
