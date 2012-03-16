From: Roberto De Ioris <roberto@unbit.it>
Subject: [PATCH 1/1] add SIOBKLGQ command to unix socket ioctl
Date: Fri, 16 Mar 2012 07:49:39 +0100
Message-ID: <1331880579-22416-1-git-send-email-roberto@unbit.it>
Cc: Roberto De Ioris <roberto@unbit.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lupo.unbit.it ([81.174.68.6]:39170 "EHLO smtp.unbit.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030278Ab2CPG6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 02:58:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Roberto De Ioris <roberto@unbit.it>
---
 include/linux/sockios.h |    1 +
 net/socket.c            |    1 +
 net/unix/af_unix.c      |   15 +++++++++++++++
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/sockios.h b/include/linux/sockios.h
index 7997a50..b179613 100644
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -23,6 +23,7 @@
 /* Linux-specific socket ioctls */
 #define SIOCINQ		FIONREAD
 #define SIOCOUTQ	TIOCOUTQ        /* output queue size (not sent + not acked) */
+#define SIOBKLGQ	0x8908
 
 /* Routing table calls. */
 #define SIOCADDRT	0x890B		/* add routing table entry	*/
diff --git a/net/socket.c b/net/socket.c
index 28a96af..d188f18 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -3186,6 +3186,7 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCSIFVLAN:
 	case SIOCADDDLCI:
 	case SIOCDELDLCI:
+	case SIOBKLGQ:
 		return sock_ioctl(file, cmd, arg);
 
 	case SIOCGIFFLAGS:
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 85d3bb7..d2797e9 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2095,6 +2095,21 @@ static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		amount = unix_outq_len(sk);
 		err = put_user(amount, (int __user *)arg);
 		break;
+	case SIOBKLGQ:
+		if (sk->sk_state != TCP_LISTEN) {
+			err = -EINVAL;
+			break;
+		}
+		if (sk->sk_type != SOCK_STREAM &&
+			sk->sk_type != SOCK_SEQPACKET) {
+			err = -EINVAL;
+			break;
+		}
+		spin_lock(&sk->sk_receive_queue.lock);
+		amount = (long) skb_queue_len(&sock->sk->sk_receive_queue);
+		spin_unlock(&sk->sk_receive_queue.lock);
+		err = put_user(amount, (int __user *)arg);
+		break;
 	case SIOCINQ:
 		amount = unix_inq_len(sk);
 		if (amount < 0)
-- 
1.7.9.1
