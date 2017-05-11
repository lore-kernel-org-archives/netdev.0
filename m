From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: make macro tipc_wait_for_cond() smp safe
Date: Thu, 11 May 2017 20:28:15 +0200
Message-ID: <1494527295-20646-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:53814 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933972AbdEKS20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 14:28:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro tipc_wait_for_cond() is embedding the macro sk_wait_event()
to fulfil its task. The latter, in turn, is evaluating the stated
condition outside the socket lock context. This is problematic if
the condition is accessing non-trivial data structures which may be
altered by incoming interrupts, as is the case with the cong_links()
linked list, used by socket to keep track of the current set of
congested links. We sometimes see crashes when this list is accessed
by a condition function at the same time as a SOCK_WAKEUP interrupt
is removing an element from the list.

We fix this by expanding selected parts of sk_wait_event() into the
outer macro, while ensuring that all evaluations of a given condition
are performed under socket lock protection.

Fixes: commit 365ad353c256 ("tipc: reduce risk of user starvation
during link congestion")

Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 0d4f2f4..1b92b72 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -362,25 +362,25 @@ static int tipc_sk_sock_err(struct socket *sock, long *timeout)
 	return 0;
 }
 
-#define tipc_wait_for_cond(sock_, timeout_, condition_)			\
-({								        \
-	int rc_ = 0;							\
-	int done_ = 0;							\
-									\
-	while (!(condition_) && !done_) {				\
-		struct sock *sk_ = sock->sk;				\
-		DEFINE_WAIT_FUNC(wait_, woken_wake_function);		\
-									\
-		rc_ = tipc_sk_sock_err(sock_, timeout_);		\
-		if (rc_)						\
-			break;						\
-		prepare_to_wait(sk_sleep(sk_), &wait_,			\
-				TASK_INTERRUPTIBLE);			\
-		done_ = sk_wait_event(sk_, timeout_,			\
-				      (condition_), &wait_);		\
-		remove_wait_queue(sk_sleep(sk_), &wait_);		\
-	}								\
-	rc_;								\
+#define tipc_wait_for_cond(sock_, timeo_, condition_)			       \
+({                                                                             \
+	struct sock *sk_;						       \
+	int rc_;							       \
+									       \
+	while ((rc_ = !(condition_))) {					       \
+		DEFINE_WAIT_FUNC(wait_, woken_wake_function);	               \
+		sk_ = (sock_)->sk;					       \
+		rc_ = tipc_sk_sock_err((sock_), timeo_);		       \
+		if (rc_)						       \
+			break;						       \
+		prepare_to_wait(sk_sleep(sk_), &wait_, TASK_INTERRUPTIBLE);    \
+		release_sock(sk_);					       \
+		*(timeo_) = wait_woken(&wait_, TASK_INTERRUPTIBLE, *(timeo_)); \
+		sched_annotate_sleep();				               \
+		lock_sock(sk_);						       \
+		remove_wait_queue(sk_sleep(sk_), &wait_);		       \
+	}								       \
+	rc_;								       \
 })
 
 /**
-- 
2.1.4
