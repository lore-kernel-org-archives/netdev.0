From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/6] sock: Introduce the SO_PEEK_OFF sock option
Date: Tue, 21 Feb 2012 21:31:34 +0400
Message-ID: <4F43D4F6.6030104@parallels.com>
References: <4F43D49E.3010401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6341 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754049Ab2BURbn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 12:31:43 -0500
In-Reply-To: <4F43D49E.3010401@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one specifies where to start MSG_PEEK-ing queue data from. When
set to negative value means that MSG_PEEK works as ususally -- peeks
from the head of the queue always.

When some bytes are peeked from queue and the peeking offset is non
negative it is moved forward so that the next peek will return next
portion of data.

When non-peeking recvmsg occurs and the peeking offset is non negative
is is moved backward so that the next peek will still peek the proper
data (i.e. the one that would have been picked if there were no non
peeking recv in between).

The offset is set using per-proto opteration to let the protocol handle
the locking issues and to check whether the peeking offset feature is
supported by the protocol the socket belongs to.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/asm-generic/socket.h |    1 +
 include/linux/net.h          |    1 +
 include/net/sock.h           |   25 +++++++++++++++++++++++++
 net/core/sock.c              |   13 +++++++++++++
 4 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 49c1704..832c270 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -66,5 +66,6 @@
 #define SO_RXQ_OVFL             40
 
 #define SO_WIFI_STATUS		41
+#define SO_PEEK_OFF		42
 #define SCM_WIFI_STATUS	SO_WIFI_STATUS
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/net.h b/include/linux/net.h
index b299230..be60c7f 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -206,6 +206,7 @@ struct proto_ops {
 				      int offset, size_t size, int flags);
 	ssize_t 	(*splice_read)(struct socket *sock,  loff_t *ppos,
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
+	void		(*set_peek_off)(struct sock *sk, int val);
 };
 
 #define DECLARE_SOCKADDR(type, dst, src)	\
diff --git a/include/net/sock.h b/include/net/sock.h
index 91c1c8b..9c0553b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -357,6 +357,7 @@ struct sock {
 	struct page		*sk_sndmsg_page;
 	struct sk_buff		*sk_send_head;
 	__u32			sk_sndmsg_off;
+	__s32			sk_peek_off;
 	int			sk_write_pending;
 #ifdef CONFIG_SECURITY
 	void			*sk_security;
@@ -373,6 +374,30 @@ struct sock {
 	void                    (*sk_destruct)(struct sock *sk);
 };
 
+static inline int sk_peek_offset(struct sock *sk, int flags)
+{
+	if ((flags & MSG_PEEK) && (sk->sk_peek_off >= 0))
+		return sk->sk_peek_off;
+	else
+		return 0;
+}
+
+static inline void sk_peek_offset_bwd(struct sock *sk, int val)
+{
+	if (sk->sk_peek_off >= 0) {
+		if (sk->sk_peek_off >= val)
+			sk->sk_peek_off -= val;
+		else
+			sk->sk_peek_off = 0;
+	}
+}
+
+static inline void sk_peek_offset_fwd(struct sock *sk, int val)
+{
+	if (sk->sk_peek_off >= 0)
+		sk->sk_peek_off += val;
+}
+
 /*
  * Hashed lists helper routines
  */
diff --git a/net/core/sock.c b/net/core/sock.c
index 02f8dfe..19942d4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -793,6 +793,12 @@ set_rcvbuf:
 		sock_valbool_flag(sk, SOCK_WIFI_STATUS, valbool);
 		break;
 
+	case SO_PEEK_OFF:
+		if (sock->ops->set_peek_off)
+			sock->ops->set_peek_off(sk, val);
+		else
+			ret = -EOPNOTSUPP;
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1018,6 +1024,12 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = !!sock_flag(sk, SOCK_WIFI_STATUS);
 		break;
 
+	case SO_PEEK_OFF:
+		if (!sock->ops->set_peek_off)
+			return -EOPNOTSUPP;
+
+		v.val = sk->sk_peek_off;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -2092,6 +2104,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	sk->sk_sndmsg_page	=	NULL;
 	sk->sk_sndmsg_off	=	0;
+	sk->sk_peek_off		=	-1;
 
 	sk->sk_peer_pid 	=	NULL;
 	sk->sk_peer_cred	=	NULL;
-- 
1.5.5.6
