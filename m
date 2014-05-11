From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] net: avoid dependency of net_get_random_once on nop patching
Date: Sun, 11 May 2014 22:59:30 +0200
Message-ID: <1399841970-869-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:60516 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751438AbaEKU7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 16:59:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_get_random_once depends on the static keys infrastructure to patch =
up
the branch to the slow path during boot. This was realized by abusing t=
he
static keys api and defining a new initializer to not enable the call
site while still indicating that the branch point should get patched
up. This was needed to have the fast path considered likely by gcc.

The static key initialization during boot up normally walks through all
the registered keys and either patches in ideal nops or enables the jum=
p
site but omitted that step on x86 if ideal nops where already placed at
static_key branch points. Thus net_get_random_once branches not always
became active.

This patch switches net_get_random_once to the ordinary static_key
api and thus places the kernel fast path in the - by gcc considered -
unlikely path.  Microbenchmarks on Intel and AMD x86-64 showed that
the unlikely path actually beats the likely path in terms of cycle cost
and that different nop patterns did not make much difference, thus this
switch should not be noticeable.

=46ixes: a48e42920ff38b ("net: introduce new macro net_get_random_once"=
)
Reported-by: Tuomas R=C3=A4s=C3=A4nen <tuomasjjrasanen@tjjr.fi>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
This patch is also material for stable, thanks!

 include/linux/net.h | 15 ++++-----------
 net/core/utils.c    |  8 ++++----
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 94734a6..17d8339 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -248,24 +248,17 @@ do {								\
 bool __net_get_random_once(void *buf, int nbytes, bool *done,
 			   struct static_key *done_key);
=20
-#ifdef HAVE_JUMP_LABEL
-#define ___NET_RANDOM_STATIC_KEY_INIT ((struct static_key) \
-		{ .enabled =3D ATOMIC_INIT(0), .entries =3D (void *)1 })
-#else /* !HAVE_JUMP_LABEL */
-#define ___NET_RANDOM_STATIC_KEY_INIT STATIC_KEY_INIT_FALSE
-#endif /* HAVE_JUMP_LABEL */
-
 #define net_get_random_once(buf, nbytes)				\
 	({								\
 		bool ___ret =3D false;					\
 		static bool ___done =3D false;				\
-		static struct static_key ___done_key =3D			\
-			___NET_RANDOM_STATIC_KEY_INIT;			\
-		if (!static_key_true(&___done_key))			\
+		static struct static_key ___once_key =3D			\
+			STATIC_KEY_INIT_TRUE;				\
+		if (static_key_true(&___once_key))			\
 			___ret =3D __net_get_random_once(buf,		\
 						       nbytes,		\
 						       &___done,	\
-						       &___done_key);	\
+						       &___once_key);	\
 		___ret;							\
 	})
=20
diff --git a/net/core/utils.c b/net/core/utils.c
index 2f737bf..eed3433 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -348,8 +348,8 @@ static void __net_random_once_deferred(struct work_=
struct *w)
 {
 	struct __net_random_once_work *work =3D
 		container_of(w, struct __net_random_once_work, work);
-	if (!static_key_enabled(work->key))
-		static_key_slow_inc(work->key);
+	BUG_ON(!static_key_enabled(work->key));
+	static_key_slow_dec(work->key);
 	kfree(work);
 }
=20
@@ -367,7 +367,7 @@ static void __net_random_once_disable_jump(struct s=
tatic_key *key)
 }
=20
 bool __net_get_random_once(void *buf, int nbytes, bool *done,
-			   struct static_key *done_key)
+			   struct static_key *once_key)
 {
 	static DEFINE_SPINLOCK(lock);
 	unsigned long flags;
@@ -382,7 +382,7 @@ bool __net_get_random_once(void *buf, int nbytes, b=
ool *done,
 	*done =3D true;
 	spin_unlock_irqrestore(&lock, flags);
=20
-	__net_random_once_disable_jump(done_key);
+	__net_random_once_disable_jump(once_key);
=20
 	return true;
 }
--=20
1.9.0
