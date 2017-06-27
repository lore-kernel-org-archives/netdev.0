From: Jeffy Chen <jeffy.chen@rock-chips.com>
Subject: [RESEND PATCH v4 2/3] Bluetooth: cmtp: fix possible might sleep error in cmtp_session
Date: Tue, 27 Jun 2017 17:34:43 +0800
Message-ID: <1498556084-25346-2-git-send-email-jeffy.chen@rock-chips.com>
References: <1498556084-25346-1-git-send-email-jeffy.chen@rock-chips.com>
Cc: rvaswani@nvidia.com, briannorris@chromium.org,
        dmitry.torokhov@gmail.com, dianders@chromium.org, acho@suse.com,
        Jeffy Chen <jeffy.chen@rock-chips.com>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>
To: linux-kernel@vger.kernel.org, linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.130]:48404 "EHLO
        regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751569AbdF0Jfh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 05:35:37 -0400
In-Reply-To: <1498556084-25346-1-git-send-email-jeffy.chen@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like cmtp_session has same pattern as the issue reported in
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
Reviewed-by: Brian Norris <briannorris@chromium.org>
Reviewed-by: AL Yu-Chen Cho <acho@suse.com>

---

Changes in v4: None
Changes in v2:
Remove unnecessary memory barrier before wake_up_* functions.

 net/bluetooth/cmtp/core.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index 9e59b66..1152ce3 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -280,16 +280,16 @@ static int cmtp_session(void *arg)
 	struct cmtp_session *session = arg;
 	struct sock *sk = session->sock->sk;
 	struct sk_buff *skb;
-	wait_queue_t wait;
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
 	BT_DBG("session %p", session);
 
 	set_user_nice(current, -15);
 
-	init_waitqueue_entry(&wait, current);
 	add_wait_queue(sk_sleep(sk), &wait);
 	while (1) {
-		set_current_state(TASK_INTERRUPTIBLE);
+		/* Ensure session->terminate is updated */
+		smp_mb__before_atomic();
 
 		if (atomic_read(&session->terminate))
 			break;
@@ -306,9 +306,8 @@ static int cmtp_session(void *arg)
 
 		cmtp_process_transmit(session);
 
-		schedule();
+		wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
 	}
-	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(sk_sleep(sk), &wait);
 
 	down_write(&cmtp_session_sem);
@@ -393,7 +392,7 @@ int cmtp_add_connection(struct cmtp_connadd_req *req, struct socket *sock)
 		err = cmtp_attach_device(session);
 		if (err < 0) {
 			atomic_inc(&session->terminate);
-			wake_up_process(session->task);
+			wake_up_interruptible(sk_sleep(session->sock->sk));
 			up_write(&cmtp_session_sem);
 			return err;
 		}
@@ -431,7 +430,11 @@ int cmtp_del_connection(struct cmtp_conndel_req *req)
 
 		/* Stop session thread */
 		atomic_inc(&session->terminate);
-		wake_up_process(session->task);
+
+		/* Ensure session->terminate is updated */
+		smp_mb__after_atomic();
+
+		wake_up_interruptible(sk_sleep(session->sock->sk));
 	} else
 		err = -ENOENT;
 
-- 
2.1.4
