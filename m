From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 2/2] [NET] Change type of owner in sock_lock_t to int, rename
Date: Tue, 11 Sep 2007 14:01:33 -0400
Message-ID: <11895336943404-git-send-email-jheffner@psc.edu>
References: <11895336933187-git-send-email-jheffner@psc.edu>
 <11895336943821-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:52003 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758662AbXIKSPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 14:15:09 -0400
In-Reply-To: <11895336943821-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The type of owner in sock_lock_t is currently (struct sock_iocb *),
presumably for historical reasons.  It is never used as this type, only
tested as NULL or set to (void *)1.  For clarity, this changes it to type
int, and renames to owned, to avoid any possible type casting errors.

Signed-off-by: John Heffner <jheffner@psc.edu>
---
 include/net/sock.h |    7 +++----
 net/core/sock.c    |    6 +++---
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 802c670..5ed9fa4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -76,10 +76,9 @@
  * between user contexts and software interrupt processing, whereas the
  * mini-semaphore synchronizes multiple users amongst themselves.
  */
-struct sock_iocb;
 typedef struct {
 	spinlock_t		slock;
-	struct sock_iocb	*owner;
+	int			owned;
 	wait_queue_head_t	wq;
 	/*
 	 * We express the mutex-alike socket_lock semantics
@@ -737,7 +736,7 @@ static inline int sk_stream_wmem_schedule(struct sock *sk, int size)
  * Since ~2.3.5 it is also exclusive sleep lock serializing
  * accesses from user process context.
  */
-#define sock_owned_by_user(sk)	((sk)->sk_lock.owner)
+#define sock_owned_by_user(sk)	((sk)->sk_lock.owned)
 
 /*
  * Macro so as to not evaluate some arguments when
@@ -748,7 +747,7 @@ static inline int sk_stream_wmem_schedule(struct sock *sk, int size)
  */
 #define sock_lock_init_class_and_name(sk, sname, skey, name, key) 	\
 do {									\
-	sk->sk_lock.owner = NULL;					\
+	sk->sk_lock.owned = 0;					\
 	init_waitqueue_head(&sk->sk_lock.wq);				\
 	spin_lock_init(&(sk)->sk_lock.slock);				\
 	debug_check_no_locks_freed((void *)&(sk)->sk_lock,		\
diff --git a/net/core/sock.c b/net/core/sock.c
index cfed7d4..edbc562 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1575,9 +1575,9 @@ void fastcall lock_sock_nested(struct sock *sk, int subclass)
 {
 	might_sleep();
 	spin_lock_bh(&sk->sk_lock.slock);
-	if (sk->sk_lock.owner)
+	if (sk->sk_lock.owned)
 		__lock_sock(sk);
-	sk->sk_lock.owner = (void *)1;
+	sk->sk_lock.owned = 1;
 	spin_unlock(&sk->sk_lock.slock);
 	/*
 	 * The sk_lock has mutex_lock() semantics here:
@@ -1598,7 +1598,7 @@ void fastcall release_sock(struct sock *sk)
 	spin_lock_bh(&sk->sk_lock.slock);
 	if (sk->sk_backlog.tail)
 		__release_sock(sk);
-	sk->sk_lock.owner = NULL;
+	sk->sk_lock.owned = 0;
 	if (waitqueue_active(&sk->sk_lock.wq))
 		wake_up(&sk->sk_lock.wq);
 	spin_unlock_bh(&sk->sk_lock.slock);
-- 
1.5.3.rc7.30.g947ad2

