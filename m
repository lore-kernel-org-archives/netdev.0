From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 02/11] net: llc: fix a setting of error value to size_t
Date: Fri, 23 Oct 2015 14:10:27 +0200
Message-ID: <1445602236-24130-3-git-send-email-clabbe.montjoie@gmail.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@ghostprotocols.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable copied is a size_t, so setting a negative value to it is
invalid.
The patch add an "err" variable for getting the error code.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 net/llc/af_llc.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 8dab4e5..79b915d 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -719,9 +719,10 @@ static int llc_ui_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	unsigned long used;
 	int target;	/* Read at least this many bytes */
 	long timeo;
+	int err = 0;
 
 	lock_sock(sk);
-	copied = -ENOTCONN;
+	err = -ENOTCONN;
 	if (unlikely(sk->sk_type == SOCK_STREAM && sk->sk_state == TCP_LISTEN))
 		goto out;
 
@@ -745,9 +746,8 @@ static int llc_ui_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		 * and move it down to the bottom of the loop
 		 */
 		if (signal_pending(current)) {
-			if (copied)
-				break;
-			copied = timeo ? sock_intr_errno(timeo) : -EAGAIN;
+			if (!copied)
+				err = timeo ? sock_intr_errno(timeo) : -EAGAIN;
 			break;
 		}
 
@@ -775,7 +775,7 @@ static int llc_ui_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 				break;
 
 			if (sk->sk_err) {
-				copied = sock_error(sk);
+				err = sock_error(sk);
 				break;
 			}
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
@@ -787,13 +787,15 @@ static int llc_ui_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 					 * This occurs when user tries to read
 					 * from never connected socket.
 					 */
-					copied = -ENOTCONN;
+					err = -ENOTCONN;
+					copied = 0;
 					break;
 				}
 				break;
 			}
 			if (!timeo) {
-				copied = -EAGAIN;
+				err = -EAGAIN;
+				copied = 0;
 				break;
 			}
 		}
@@ -823,7 +825,7 @@ static int llc_ui_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			if (rc) {
 				/* Exception. Bailout! */
 				if (!copied)
-					copied = -EFAULT;
+					err = -EFAULT;
 				break;
 			}
 		}
@@ -850,6 +852,8 @@ static int llc_ui_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 
 out:
 	release_sock(sk);
+	if (err)
+		return err;
 	return copied;
 copy_uaddr:
 	if (uaddr != NULL && skb != NULL) {
-- 
2.4.10
