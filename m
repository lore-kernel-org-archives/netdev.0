From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/5] net: move net_get_random_once to lib
Date: Thu,  8 Oct 2015 01:20:35 +0200
Message-ID: <0c4ba1bd57bebe9d4cf2cd7a7fdcb2655fe642e9.1444258405.git.daniel@iogearbox.net>
References: <cover.1444258405.git.daniel@iogearbox.net>
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37255 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbbJGXUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 19:20:47 -0400
In-Reply-To: <cover.1444258405.git.daniel@iogearbox.net>
In-Reply-To: <cover.1444258405.git.daniel@iogearbox.net>
References: <cover.1444258405.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

There's no good reason why users outside of networking should not
be using this facility, f.e. for initializing their seeds.

Therefore, make it accessible from there as get_random_once().

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/net.h  | 21 ++++----------------
 include/linux/once.h | 24 +++++++++++++++++++++++
 lib/Makefile         |  3 ++-
 lib/once.c           | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/utils.c     | 49 -----------------------------------------------
 5 files changed, 84 insertions(+), 67 deletions(-)
 create mode 100644 include/linux/once.h
 create mode 100644 lib/once.c

diff --git a/include/linux/net.h b/include/linux/net.h
index 049d4b0..70ac5e2 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -24,7 +24,8 @@
 #include <linux/fcntl.h>	/* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/kmemcheck.h>
 #include <linux/rcupdate.h>
-#include <linux/jump_label.h>
+#include <linux/once.h>
+
 #include <uapi/linux/net.h>
 
 struct poll_table_struct;
@@ -250,22 +251,8 @@ do {								\
 	} while (0)
 #endif
 
-bool __net_get_random_once(void *buf, int nbytes, bool *done,
-			   struct static_key *done_key);
-
-#define net_get_random_once(buf, nbytes)				\
-	({								\
-		bool ___ret = false;					\
-		static bool ___done = false;				\
-		static struct static_key ___once_key =			\
-			STATIC_KEY_INIT_TRUE;				\
-		if (static_key_true(&___once_key))			\
-			___ret = __net_get_random_once(buf,		\
-						       nbytes,		\
-						       &___done,	\
-						       &___once_key);	\
-		___ret;							\
-	})
+#define net_get_random_once(buf, nbytes)			\
+	get_random_once((buf), (nbytes))
 
 int kernel_sendmsg(struct socket *sock, struct msghdr *msg, struct kvec *vec,
 		   size_t num, size_t len);
diff --git a/include/linux/once.h b/include/linux/once.h
new file mode 100644
index 0000000..2a83b53
--- /dev/null
+++ b/include/linux/once.h
@@ -0,0 +1,24 @@
+#ifndef _LINUX_ONCE_H
+#define _LINUX_ONCE_H
+
+#include <linux/types.h>
+#include <linux/jump_label.h>
+
+bool __get_random_once(void *buf, int nbytes, bool *done,
+		       struct static_key *once_key);
+
+#define get_random_once(buf, nbytes)					\
+	({								\
+		bool ___ret = false;					\
+		static bool ___done = false;				\
+		static struct static_key ___once_key =			\
+			STATIC_KEY_INIT_TRUE;				\
+		if (static_key_true(&___once_key))			\
+			___ret = __get_random_once((buf),		\
+						   (nbytes),		\
+						   &___done,		\
+						   &___once_key);	\
+		___ret;							\
+	})
+
+#endif /* _LINUX_ONCE_H */
diff --git a/lib/Makefile b/lib/Makefile
index 13a7c6a..8de3b01 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -26,7 +26,8 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 bust_spinlocks.o kasprintf.o bitmap.o scatterlist.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iov_iter.o clz_ctz.o \
 	 bsearch.o find_bit.o llist.o memweight.o kfifo.o \
-	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o
+	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o \
+	 once.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += hexdump.o
diff --git a/lib/once.c b/lib/once.c
new file mode 100644
index 0000000..2d5a7de
--- /dev/null
+++ b/lib/once.c
@@ -0,0 +1,54 @@
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/once.h>
+#include <linux/random.h>
+
+struct __random_once_work {
+	struct work_struct work;
+	struct static_key *key;
+};
+
+static void __random_once_deferred(struct work_struct *w)
+{
+	struct __random_once_work *work;
+
+	work = container_of(w, struct __random_once_work, work);
+	BUG_ON(!static_key_enabled(work->key));
+	static_key_slow_dec(work->key);
+	kfree(work);
+}
+
+static void __random_once_disable_jump(struct static_key *key)
+{
+	struct __random_once_work *w;
+
+	w = kmalloc(sizeof(*w), GFP_ATOMIC);
+	if (!w)
+		return;
+
+	INIT_WORK(&w->work, __random_once_deferred);
+	w->key = key;
+	schedule_work(&w->work);
+}
+
+bool __get_random_once(void *buf, int nbytes, bool *done,
+		       struct static_key *once_key)
+{
+	static DEFINE_SPINLOCK(lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&lock, flags);
+	if (*done) {
+		spin_unlock_irqrestore(&lock, flags);
+		return false;
+	}
+
+	get_random_bytes(buf, nbytes);
+	*done = true;
+	spin_unlock_irqrestore(&lock, flags);
+
+	__random_once_disable_jump(once_key);
+
+	return true;
+}
+EXPORT_SYMBOL(__get_random_once);
diff --git a/net/core/utils.c b/net/core/utils.c
index 3dffce9..3d17ca8 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -348,52 +348,3 @@ void inet_proto_csum_replace_by_diff(__sum16 *sum, struct sk_buff *skb,
 	}
 }
 EXPORT_SYMBOL(inet_proto_csum_replace_by_diff);
-
-struct __net_random_once_work {
-	struct work_struct work;
-	struct static_key *key;
-};
-
-static void __net_random_once_deferred(struct work_struct *w)
-{
-	struct __net_random_once_work *work =
-		container_of(w, struct __net_random_once_work, work);
-	BUG_ON(!static_key_enabled(work->key));
-	static_key_slow_dec(work->key);
-	kfree(work);
-}
-
-static void __net_random_once_disable_jump(struct static_key *key)
-{
-	struct __net_random_once_work *w;
-
-	w = kmalloc(sizeof(*w), GFP_ATOMIC);
-	if (!w)
-		return;
-
-	INIT_WORK(&w->work, __net_random_once_deferred);
-	w->key = key;
-	schedule_work(&w->work);
-}
-
-bool __net_get_random_once(void *buf, int nbytes, bool *done,
-			   struct static_key *once_key)
-{
-	static DEFINE_SPINLOCK(lock);
-	unsigned long flags;
-
-	spin_lock_irqsave(&lock, flags);
-	if (*done) {
-		spin_unlock_irqrestore(&lock, flags);
-		return false;
-	}
-
-	get_random_bytes(buf, nbytes);
-	*done = true;
-	spin_unlock_irqrestore(&lock, flags);
-
-	__net_random_once_disable_jump(once_key);
-
-	return true;
-}
-EXPORT_SYMBOL(__net_get_random_once);
-- 
1.9.3
