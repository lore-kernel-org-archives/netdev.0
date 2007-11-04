From: Patrick McHardy <kaber@trash.net>
Subject: [NETLINK]: Fix unicast timeouts
Date: Sun, 04 Nov 2007 17:52:56 +0100
Message-ID: <472DF8E8.2030204@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070009030505050503040204"
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41067 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbXKDQ4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2007 11:56:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070009030505050503040204
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------070009030505050503040204
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETLINK]: Fix unicast timeouts

Commit ed6dcf4a in the history.git tree broke netlink_unicast timeouts by
moving the schedule_timeout() call to a new function that doesn't propagate
the remaining timeout back to the caller. This means on each retry we start
with the full timeout again.

ipc/mqueue.c seems to actually want to wait indefinitely so this behaviour
is retained.

Cc: Manfred Spraul <manfred@colorfullife.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 251299cd3683f06b5b690e6a3bdd14133303ab2a
tree 3fd85bdae19d5f29efe09c328fa2defac9facd6b
parent b4f555081fdd27d13e6ff39d455d5aefae9d2c0c
author Patrick McHardy <kaber@trash.net> Sun, 04 Nov 2007 17:52:19 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 04 Nov 2007 17:52:19 +0100

 include/linux/netlink.h  |    2 +-
 ipc/mqueue.c             |    6 ++++--
 net/netlink/af_netlink.c |   10 +++++-----
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 7c1f3b1..d5bfaba 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -192,7 +192,7 @@ extern int netlink_unregister_notifier(struct notifier_block *nb);
 /* finegrained unicast helpers: */
 struct sock *netlink_getsockbyfilp(struct file *filp);
 int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
-		long timeo, struct sock *ssk);
+		      long *timeo, struct sock *ssk);
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index bfa274b..1e04cd4 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -1010,6 +1010,8 @@ asmlinkage long sys_mq_notify(mqd_t mqdes,
 			return -EINVAL;
 		}
 		if (notification.sigev_notify == SIGEV_THREAD) {
+			long timeo;
+
 			/* create the notify skb */
 			nc = alloc_skb(NOTIFY_COOKIE_LEN, GFP_KERNEL);
 			ret = -ENOMEM;
@@ -1038,8 +1040,8 @@ retry:
 				goto out;
 			}
 
-			ret = netlink_attachskb(sock, nc, 0,
-					MAX_SCHEDULE_TIMEOUT, NULL);
+			timeo = MAX_SCHEDULE_TIMEOUT;
+			ret = netlink_attachskb(sock, nc, 0, &timeo, NULL);
 			if (ret == 1)
 		       		goto retry;
 			if (ret) {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2601712..415c972 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -752,7 +752,7 @@ struct sock *netlink_getsockbyfilp(struct file *filp)
  * 1: repeat lookup - reference dropped while waiting for socket memory.
  */
 int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
-		long timeo, struct sock *ssk)
+		      long *timeo, struct sock *ssk)
 {
 	struct netlink_sock *nlk;
 
@@ -761,7 +761,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
 	    test_bit(0, &nlk->state)) {
 		DECLARE_WAITQUEUE(wait, current);
-		if (!timeo) {
+		if (!*timeo) {
 			if (!ssk || netlink_is_kernel(ssk))
 				netlink_overrun(sk);
 			sock_put(sk);
@@ -775,7 +775,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
 		if ((atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
 		     test_bit(0, &nlk->state)) &&
 		    !sock_flag(sk, SOCK_DEAD))
-			timeo = schedule_timeout(timeo);
+			*timeo = schedule_timeout(*timeo);
 
 		__set_current_state(TASK_RUNNING);
 		remove_wait_queue(&nlk->wait, &wait);
@@ -783,7 +783,7 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
 
 		if (signal_pending(current)) {
 			kfree_skb(skb);
-			return sock_intr_errno(timeo);
+			return sock_intr_errno(*timeo);
 		}
 		return 1;
 	}
@@ -877,7 +877,7 @@ retry:
 	if (netlink_is_kernel(sk))
 		return netlink_unicast_kernel(sk, skb);
 
-	err = netlink_attachskb(sk, skb, nonblock, timeo, ssk);
+	err = netlink_attachskb(sk, skb, nonblock, &timeo, ssk);
 	if (err == 1)
 		goto retry;
 	if (err)

--------------070009030505050503040204--
