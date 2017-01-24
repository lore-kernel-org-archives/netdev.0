From: Jeffy Chen <jeffy.chen@rock-chips.com>
Subject: [PATCH 3/3] Bluetooth: hidp: fix possible might sleep error in hidp_session_thread
Date: Tue, 24 Jan 2017 12:07:51 +0800
Message-ID: <1485230871-22828-3-git-send-email-jeffy.chen@rock-chips.com>
References: <1485230871-22828-1-git-send-email-jeffy.chen@rock-chips.com>
Cc: Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        Johan Hedberg <johan.hedberg@intel.com>,
        Peter Hurley <peter@hurleysoftware.com>,
        Jeffy Chen <jeffy.chen@rock-chips.com>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>
To: linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.132]:51582 "EHLO
        regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750709AbdAXEJf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 23:09:35 -0500
In-Reply-To: <1485230871-22828-1-git-send-email-jeffy.chen@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like hidp_session_thread has same pattern as the issue reported in
old rfcomm:

	while (1) {
		set_current_state(TASK_INTERRUPTIBLE);
		if (condition)
			break;
		// may call might_sleep here
		schedule();
	}
	__set_current_state(TASK_RUNNING);

Which fixed at:
	dfb2fae Bluetooth: Fix nested sleeps

So let's fix it at the same way, also follow the suggestion of:
https://lwn.net/Articles/628628/

Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
---

 net/bluetooth/hidp/core.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 0bec458..43d6e6a 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -36,6 +36,7 @@
 #define VERSION "1.2"
 
 static DECLARE_RWSEM(hidp_session_sem);
+static DECLARE_WAIT_QUEUE_HEAD(hidp_session_wq);
 static LIST_HEAD(hidp_session_list);
 
 static unsigned char hidp_keycode[256] = {
@@ -1068,12 +1069,15 @@ static int hidp_session_start_sync(struct hidp_session *session)
  * Wake up session thread and notify it to stop. This is asynchronous and
  * returns immediately. Call this whenever a runtime error occurs and you want
  * the session to stop.
- * Note: wake_up_process() performs any necessary memory-barriers for us.
  */
 static void hidp_session_terminate(struct hidp_session *session)
 {
 	atomic_inc(&session->terminate);
-	wake_up_process(session->task);
+
+	/* Ensure session->terminate is updated */
+	smp_mb__after_atomic();
+
+	wake_up_interruptible(&hidp_session_wq);
 }
 
 /*
@@ -1180,7 +1184,9 @@ static void hidp_session_run(struct hidp_session *session)
 	struct sock *ctrl_sk = session->ctrl_sock->sk;
 	struct sock *intr_sk = session->intr_sock->sk;
 	struct sk_buff *skb;
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
+	add_wait_queue(&hidp_session_wq, &wait);
 	for (;;) {
 		/*
 		 * This thread can be woken up two ways:
@@ -1188,12 +1194,10 @@ static void hidp_session_run(struct hidp_session *session)
 		 *    session->terminate flag and wakes this thread up.
 		 *  - Via modifying the socket state of ctrl/intr_sock. This
 		 *    thread is woken up by ->sk_state_changed().
-		 *
-		 * Note: set_current_state() performs any necessary
-		 * memory-barriers for us.
 		 */
-		set_current_state(TASK_INTERRUPTIBLE);
 
+		/* Ensure session->terminate is updated */
+		smp_mb__before_atomic();
 		if (atomic_read(&session->terminate))
 			break;
 
@@ -1227,11 +1231,14 @@ static void hidp_session_run(struct hidp_session *session)
 		hidp_process_transmit(session, &session->ctrl_transmit,
 				      session->ctrl_sock);
 
-		schedule();
+		wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
 	}
+	remove_wait_queue(&hidp_session_wq, &wait);
 
 	atomic_inc(&session->terminate);
-	set_current_state(TASK_RUNNING);
+
+	/* Ensure session->terminate is updated */
+	smp_mb__after_atomic();
 }
 
 /*
-- 
2.1.4
