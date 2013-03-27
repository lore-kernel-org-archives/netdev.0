From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [net-next PATCH] [RFC] net: add option to enable error queue packets waking select
Date: Wed, 27 Mar 2013 15:00:28 -0700
Message-ID: <20130327220028.13267.89112.stgit@jekeller-hub.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>,
	Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38414 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774Ab3C0WAa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 18:00:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when a socket receives something on the error queue it only wakes up
the socket on select if it is in the "read" list, that is the socket has
something to read. It is useful also to wake the socket if it is in the error
list, which would enable software to wait on error queue packets without waking
up for regular data on the socket. The main use case is for receiving
timestamped transmit packets which return the timestamp to the socket via the
error queue. This enables an application to select on the socket for the error
queue only instead of for the regular traffic.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 include/net/sock.h                |    1 +
 include/uapi/asm-generic/socket.h |    2 ++
 net/core/datagram.c               |    5 ++++-
 net/core/sock.c                   |    8 ++++++++
 net/unix/af_unix.c                |    5 ++++-
 5 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 14f6e9d..08f05f9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -667,6 +667,7 @@ enum sock_flags {
 		     * user-space instead.
 		     */
 	SOCK_FILTER_LOCKED, /* Filter cannot be changed anymore */
+	SOCK_SELECT_ERR_QUEUE, /* Wake select on error queue */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 4ef3acb..c5d2e3a 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -74,4 +74,6 @@
 
 #define SO_LOCK_FILTER		44
 
+#define SO_SELECT_ERR_QUEUE	45
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 368f9c3..f7d7b64 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -748,8 +748,11 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 	mask = 0;
 
 	/* exceptional events? */
-	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue)) {
 		mask |= POLLERR;
+		if (sock_flag(sk, SOCK_SELECT_ERR_QUEUE))
+			mask |= POLLPRI;
+	}
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
diff --git a/net/core/sock.c b/net/core/sock.c
index a19e728..2ff5f36 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -907,6 +907,10 @@ set_rcvbuf:
 		sock_valbool_flag(sk, SOCK_NOFCS, valbool);
 		break;
 
+	case SO_SELECT_ERR_QUEUE:
+		sock_valbool_flag(sk, SOCK_SELECT_ERR_QUEUE, valbool);
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1160,6 +1164,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sock_flag(sk, SOCK_FILTER_LOCKED);
 		break;
 
+	case SO_SELECT_ERR_QUEUE:
+		v.val = sock_flag(sk, SOCK_SELECT_ERR_QUEUE);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51be64f..f435555 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2196,8 +2196,11 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	mask = 0;
 
 	/* exceptional events? */
-	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue)) {
 		mask |= POLLERR;
+		if (sock_flag(sk, SOCK_SELECT_ERR_QUEUE))
+			mask |= POLLPRI;
+	}
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
 	if (sk->sk_shutdown == SHUTDOWN_MASK)
