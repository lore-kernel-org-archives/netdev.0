From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [PATCH v3 1/2] Revert "vsock: Fix blocking ops call in prepare_to_wait"
Date: Tue, 22 Mar 2016 17:05:51 +0100
Message-ID: <1458662752-2415-2-git-send-email-imbrenda@linux.vnet.ibm.com>
References: <1458662752-2415-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Cc: labbott@fedoraproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458662752-2415-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 5988818008257ca42010d6b43a3e0e48afec9898 ("vsock: Fix
blocking ops call in prepare_to_wait")

The commit reverted with this patch caused us to potentially miss wakeups.
Since the condition is not checked between the prepare_to_wait and the
schedule(), if a wakeup happens after the condition is checked but before
the sleep happens, we will miss it. ( A description of the problem can be
found here: http://www.makelinux.net/ldd3/chp-6-sect-2 ).

By reverting the patch, the behaviour is still incorrect (since we
shouldn't sleep between the prepare_to_wait and the schedule) but at least
it will not miss wakeups.

The next patch in the series actually fixes the behaviour.

Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
---
 net/vmw_vsock/af_vsock.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index bbe65dc..7fd1220 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1557,6 +1557,8 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 	if (err < 0)
 		goto out;
 
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+
 	while (total_written < len) {
 		ssize_t written;
 
@@ -1576,9 +1578,7 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 				goto out_wait;
 
 			release_sock(sk);
-			prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 			timeout = schedule_timeout(timeout);
-			finish_wait(sk_sleep(sk), &wait);
 			lock_sock(sk);
 			if (signal_pending(current)) {
 				err = sock_intr_errno(timeout);
@@ -1588,6 +1588,8 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 				goto out_wait;
 			}
 
+			prepare_to_wait(sk_sleep(sk), &wait,
+					TASK_INTERRUPTIBLE);
 		}
 
 		/* These checks occur both as part of and after the loop
@@ -1633,6 +1635,7 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 out_wait:
 	if (total_written > 0)
 		err = total_written;
+	finish_wait(sk_sleep(sk), &wait);
 out:
 	release_sock(sk);
 	return err;
@@ -1713,6 +1716,7 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	if (err < 0)
 		goto out;
 
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 
 	while (1) {
 		s64 ready = vsock_stream_has_data(vsk);
@@ -1723,7 +1727,7 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			 */
 
 			err = -ENOMEM;
-			goto out;
+			goto out_wait;
 		} else if (ready > 0) {
 			ssize_t read;
 
@@ -1746,7 +1750,7 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 					vsk, target, read,
 					!(flags & MSG_PEEK), &recv_data);
 			if (err < 0)
-				goto out;
+				goto out_wait;
 
 			if (read >= target || flags & MSG_PEEK)
 				break;
@@ -1769,9 +1773,7 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 				break;
 
 			release_sock(sk);
-			prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 			timeout = schedule_timeout(timeout);
-			finish_wait(sk_sleep(sk), &wait);
 			lock_sock(sk);
 
 			if (signal_pending(current)) {
@@ -1781,6 +1783,9 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 				err = -EAGAIN;
 				break;
 			}
+
+			prepare_to_wait(sk_sleep(sk), &wait,
+					TASK_INTERRUPTIBLE);
 		}
 	}
 
@@ -1811,6 +1816,8 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		err = copied;
 	}
 
+out_wait:
+	finish_wait(sk_sleep(sk), &wait);
 out:
 	release_sock(sk);
 	return err;
-- 
1.9.1
