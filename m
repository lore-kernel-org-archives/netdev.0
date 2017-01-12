From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] atm: switch to the new wait API for vcc_sendmsg()
Date: Wed, 11 Jan 2017 21:02:02 -0800
Message-ID: <1484197322-958-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: mhocko@kernel.org, romieu@fr.zoreil.com, 3chas3@gmail.com,
        andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35602 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbdALFC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 00:02:28 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so1588401pfa.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 21:02:28 -0800 (PST)
In-Reply-To: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported a kernel warning for the blocking ops
in between prepare_to_wait() and schedule(), that is
alloc_tx().

Of course, the logic itself is suspicious, other sendmsg()
could handle skb allocation failure very well, not sure
why ATM has to wait for a successful one here. But probably
it is too late to change since the errno and behavior is
visible to user-space. So just leave the logic as it is.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/atm/common.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/atm/common.c b/net/atm/common.c
index 7ec3bbc..b672231 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -572,8 +572,8 @@ int vcc_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 
 int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 {
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct sock *sk = sock->sk;
-	DEFINE_WAIT(wait);
 	struct atm_vcc *vcc;
 	struct sk_buff *skb;
 	int eff, error;
@@ -605,14 +605,14 @@ int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 	}
 
 	eff = (size+3) & ~3; /* align to word boundary */
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+	add_wait_queue(sk_sleep(sk), &wait);
 	error = 0;
 	while (!(skb = alloc_tx(vcc, eff))) {
 		if (m->msg_flags & MSG_DONTWAIT) {
 			error = -EAGAIN;
 			break;
 		}
-		schedule();
+		wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
 		if (signal_pending(current)) {
 			error = -ERESTARTSYS;
 			break;
@@ -624,9 +624,8 @@ int vcc_sendmsg(struct socket *sock, struct msghdr *m, size_t size)
 			send_sig(SIGPIPE, current, 0);
 			break;
 		}
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	if (error)
 		goto out;
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
-- 
2.5.5
