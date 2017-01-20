From: Jeffy Chen <jeffy.chen@rock-chips.com>
Subject: [PATCH] Bluetooth: hidp: might sleep error in hidp_session_thread
Date: Fri, 20 Jan 2017 21:52:08 +0800
Message-ID: <1484920328-20522-1-git-send-email-jeffy.chen@rock-chips.com>
Cc: Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        Jeffy Chen <jeffy.chen@rock-chips.com>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>
To: linux-bluetooth@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[   39.044329] do not call blocking ops when !TASK_RUNNING; state=1 set
at [<ffffffbffc290358>] hidp_session_thread+0x110/0x568 [hidp]
...
[   40.159664] Call trace:
[   40.162122] [<ffffffc00024ae08>] __might_sleep+0x64/0x90
[   40.167443] [<ffffffc00080568c>] lock_sock_nested+0x30/0x78
[   40.173047] [<ffffffbffc1b3ca0>] l2cap_sock_sendmsg+0x90/0xf0
[bluetooth]
[   40.179842] [<ffffffc0008012c4>] sock_sendmsg+0x4c/0x68
[   40.185072] [<ffffffc000801414>] kernel_sendmsg+0x54/0x68
[   40.190477] [<ffffffbffc28f4d0>] hidp_send_frame+0x78/0xa0 [hidp]
[   40.196574] [<ffffffbffc28f53c>] hidp_process_transmit+0x44/0x98
[hidp]
[   40.203191] [<ffffffbffc2905ac>] hidp_session_thread+0x364/0x568
[hidp]

Following (https://lwn.net/Articles/628628/).

Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
---

 net/bluetooth/hidp/core.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 0bec458..bfd3fb8 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -1180,7 +1180,9 @@ static void hidp_session_run(struct hidp_session *session)
 	struct sock *ctrl_sk = session->ctrl_sock->sk;
 	struct sock *intr_sk = session->intr_sock->sk;
 	struct sk_buff *skb;
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
+	add_wait_queue(sk_sleep(intr_sk), &wait);
 	for (;;) {
 		/*
 		 * This thread can be woken up two ways:
@@ -1188,12 +1190,10 @@ static void hidp_session_run(struct hidp_session *session)
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
 
@@ -1227,11 +1227,14 @@ static void hidp_session_run(struct hidp_session *session)
 		hidp_process_transmit(session, &session->ctrl_transmit,
 				      session->ctrl_sock);
 
-		schedule();
+		wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
 	}
+	remove_wait_queue(sk_sleep(intr_sk), &wait);
 
 	atomic_inc(&session->terminate);
-	set_current_state(TASK_RUNNING);
+
+	/* Ensure session->terminate is updated */
+	smp_mb__after_atomic();
 }
 
 /*
-- 
2.1.4
