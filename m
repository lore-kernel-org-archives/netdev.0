From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: [PATCH] atm/svc: Fix blocking in wait loop
Date: Tue, 12 Aug 2014 08:12:26 -0400
Message-ID: <20140812081226.0fb0534e@thirdoffive.cmf.nrl.navy.mil>
References: <20140805214624.GA9973@localhost>
	<20140807151741.GP19379@twins.programming.kicks-ass.net>
	<20140807125948.2b7f1472@thirdoffive.cmf.nrl.navy.mil>
	<20140807172514.GY9918@twins.programming.kicks-ass.net>
	<20140807172901.GH3588@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, lkp@01.org,
	linux-atm-general@lists.sourceforge.net, davem@davemloft.net
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140807172901.GH3588@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One should not call blocking primitives inside a wait loop, since both
require task_struct::state to sleep, so the inner will destroy the
outer state.

sigd_enq() will possibly sleep for alloc_skb().  Move sigd_enq() before
prepare_to_wait() to avoid sleeping while waiting interruptibly.  You do
not actually need to call sigd_enq() after the initial prepare_to_wait()
because we test the termination condition before calling schedule().

Based on suggestions from Peter Zijlstra.

Signed-off-by: Chas Williams <chas@cmf.n4rl.navy.mil>
Acked-by: Peter Zijlstra <peterz@infradead.org>
---
 net/atm/svc.c | 60 +++++++++++++++++++++++++++++++----------------------------
 1 file changed, 32 insertions(+), 28 deletions(-)

diff --git a/net/atm/svc.c b/net/atm/svc.c
index d8e5d0c2..1ba23f5 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -50,12 +50,12 @@ static void svc_disconnect(struct atm_vcc *vcc)
 
 	pr_debug("%p\n", vcc);
 	if (test_bit(ATM_VF_REGIS, &vcc->flags)) {
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(vcc, as_close, NULL, NULL, NULL);
-		while (!test_bit(ATM_VF_RELEASED, &vcc->flags) && sigd) {
+		for (;;) {
+			prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
+			if (test_bit(ATM_VF_RELEASED, &vcc->flags) || !sigd)
+				break;
 			schedule();
-			prepare_to_wait(sk_sleep(sk), &wait,
-					TASK_UNINTERRUPTIBLE);
 		}
 		finish_wait(sk_sleep(sk), &wait);
 	}
@@ -126,11 +126,12 @@ static int svc_bind(struct socket *sock, struct sockaddr *sockaddr,
 	}
 	vcc->local = *addr;
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc, as_bind, NULL, NULL, &vcc->local);
-	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
-		schedule();
+	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
+		if (!test_bit(ATM_VF_WAITING, &vcc->flags) || !sigd)
+			break;
+		schedule();
 	}
 	finish_wait(sk_sleep(sk), &wait);
 	clear_bit(ATM_VF_REGIS, &vcc->flags); /* doesn't count */
@@ -202,15 +203,14 @@ static int svc_connect(struct socket *sock, struct sockaddr *sockaddr,
 		}
 		vcc->remote = *addr;
 		set_bit(ATM_VF_WAITING, &vcc->flags);
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		sigd_enq(vcc, as_connect, NULL, NULL, &vcc->remote);
 		if (flags & O_NONBLOCK) {
-			finish_wait(sk_sleep(sk), &wait);
 			sock->state = SS_CONNECTING;
 			error = -EINPROGRESS;
 			goto out;
 		}
 		error = 0;
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 			schedule();
 			if (!signal_pending(current)) {
@@ -297,11 +297,12 @@ static int svc_listen(struct socket *sock, int backlog)
 		goto out;
 	}
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc, as_listen, NULL, NULL, &vcc->local);
-	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
-		schedule();
+	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
+		if (!test_bit(ATM_VF_WAITING, &vcc->flags) || !sigd)
+			break;
+		schedule();
 	}
 	finish_wait(sk_sleep(sk), &wait);
 	if (!sigd) {
@@ -387,15 +388,15 @@ static int svc_accept(struct socket *sock, struct socket *newsock, int flags)
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
 		set_bit(ATM_VF_WAITING, &new_vcc->flags);
-		prepare_to_wait(sk_sleep(sk_atm(new_vcc)), &wait,
-				TASK_UNINTERRUPTIBLE);
 		sigd_enq(new_vcc, as_accept, old_vcc, NULL, NULL);
-		while (test_bit(ATM_VF_WAITING, &new_vcc->flags) && sigd) {
+		for (;;) {
+			prepare_to_wait(sk_sleep(sk_atm(new_vcc)), &wait,
+					TASK_UNINTERRUPTIBLE);
+			if (!test_bit(ATM_VF_WAITING, &new_vcc->flags) || !sigd)
+				break;
 			release_sock(sk);
 			schedule();
 			lock_sock(sk);
-			prepare_to_wait(sk_sleep(sk_atm(new_vcc)), &wait,
-					TASK_UNINTERRUPTIBLE);
 		}
 		finish_wait(sk_sleep(sk_atm(new_vcc)), &wait);
 		if (!sigd) {
@@ -433,12 +434,14 @@ int svc_change_qos(struct atm_vcc *vcc, struct atm_qos *qos)
 	DEFINE_WAIT(wait);
 
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq2(vcc, as_modify, NULL, NULL, &vcc->local, qos, 0);
-	while (test_bit(ATM_VF_WAITING, &vcc->flags) &&
-	       !test_bit(ATM_VF_RELEASED, &vcc->flags) && sigd) {
-		schedule();
+	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
+		if (!test_bit(ATM_VF_WAITING, &vcc->flags) ||
+		    test_bit(ATM_VF_RELEASED, &vcc->flags) || !sigd) {
+			break;
+		}
+		schedule();
 	}
 	finish_wait(sk_sleep(sk), &wait);
 	if (!sigd)
@@ -529,18 +532,18 @@ static int svc_addparty(struct socket *sock, struct sockaddr *sockaddr,
 
 	lock_sock(sk);
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	sigd_enq(vcc, as_addparty, NULL, NULL,
 		 (struct sockaddr_atmsvc *) sockaddr);
 	if (flags & O_NONBLOCK) {
-		finish_wait(sk_sleep(sk), &wait);
 		error = -EINPROGRESS;
 		goto out;
 	}
 	pr_debug("added wait queue\n");
-	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
-		schedule();
+	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		if (!test_bit(ATM_VF_WAITING, &vcc->flags) || !sigd)
+			break;
+		schedule();
 	}
 	finish_wait(sk_sleep(sk), &wait);
 	error = xchg(&sk->sk_err_soft, 0);
@@ -558,11 +561,12 @@ static int svc_dropparty(struct socket *sock, int ep_ref)
 
 	lock_sock(sk);
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	sigd_enq2(vcc, as_dropparty, NULL, NULL, NULL, NULL, ep_ref);
-	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
-		schedule();
+	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		if (!test_bit(ATM_VF_WAITING, &vcc->flags) || !sigd)
+			break;
+		schedule();
 	}
 	finish_wait(sk_sleep(sk), &wait);
 	if (!sigd) {
-- 
1.9.3
