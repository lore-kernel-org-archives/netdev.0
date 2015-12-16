From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH] af_unix: Revert 'lock_interruptible' in stream receive code
Date: Wed, 16 Dec 2015 20:09:25 +0000
Message-ID: <877fke6tqi.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With b3ca9b02b00704053a38bfe4c31dbbb9c13595d0, the AF_UNIX SOCK_STREAM
receive code was changed from using mutex_lock(&u->readlock) to
mutex_lock_interruptible(&u->readlock) to prevent signals from being
delayed for an indefinite time if a thread sleeping on the mutex
happened to be selected for handling the signal. But this was never a
problem with the stream receive code (as opposed to its datagram
counterpart) as that never went to sleep waiting for new messages with the
mutex held and thus, wouldn't cause secondary readers to block on the
mutex waiting for the sleeping primary reader. As the interruptible
locking makes the code more complicated in exchange for no benefit,
change it back to using mutex_lock.

Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---

Considering that the datagram receive routine also doesn't go the sleep
with the mutex held anymore, the 37ab4fa7844a044dc21fde45e2a0fc2f3c3b6490
change to unix_autobind is now similarly purposeless.

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 1c3c1f3..b1314c0 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2263,14 +2263,7 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
 	/* Lock the socket to prevent queue disordering
 	 * while sleeps in memcpy_tomsg
 	 */
-	err = mutex_lock_interruptible(&u->readlock);
-	if (unlikely(err)) {
-		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
-		 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
-		 */
-		err = noblock ? -EAGAIN : -ERESTARTSYS;
-		goto out;
-	}
+	mutex_lock(&u->readlock);
 
 	if (flags & MSG_PEEK)
 		skip = sk_peek_offset(sk, flags);
@@ -2314,12 +2307,12 @@ again:
 			timeo = unix_stream_data_wait(sk, timeo, last,
 						      last_len);
 
-			if (signal_pending(current) ||
-			    mutex_lock_interruptible(&u->readlock)) {
+			if (signal_pending(current)) {
 				err = sock_intr_errno(timeo);
 				goto out;
 			}
 
+			mutex_lock(&u->readlock);
 			continue;
 unlock:
 			unix_state_unlock(sk);
