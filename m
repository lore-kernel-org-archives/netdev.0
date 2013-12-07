From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net: unix: allow set_peek_off to fail
Date: Sat,  7 Dec 2013 17:26:27 -0500
Message-ID: <1386455187-28597-1-git-send-email-sasha.levin@oracle.com>
Cc: edumazet@google.com, netdev@vger.kernel.org, xemul@parallels.com,
	linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

unix_dgram_recvmsg() will hold the readlock of the socket until recv
is complete.

In the same time, we may try to setsockopt(SO_PEEK_OFF) which will hang until
unix_dgram_recvmsg() will complete (which can take a while) without allowing
us to break out of it, triggering a hung task spew.

Instead, allow set_peek_off to fail, this way userspace will not hang.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/net.h |    2 +-
 net/core/sock.c     |    2 +-
 net/unix/af_unix.c  |    8 ++++++--
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 4bcee94..69be3e6 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -181,7 +181,7 @@ struct proto_ops {
 				      int offset, size_t size, int flags);
 	ssize_t 	(*splice_read)(struct socket *sock,  loff_t *ppos,
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
-	void		(*set_peek_off)(struct sock *sk, int val);
+	int		(*set_peek_off)(struct sock *sk, int val);
 };
 
 #define DECLARE_SOCKADDR(type, dst, src)	\
diff --git a/net/core/sock.c b/net/core/sock.c
index ab20ed9..5393b4b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -882,7 +882,7 @@ set_rcvbuf:
 
 	case SO_PEEK_OFF:
 		if (sock->ops->set_peek_off)
-			sock->ops->set_peek_off(sk, val);
+			ret = sock->ops->set_peek_off(sk, val);
 		else
 			ret = -EOPNOTSUPP;
 		break;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 01625cc..a0ca162 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -530,13 +530,17 @@ static int unix_seqpacket_sendmsg(struct kiocb *, struct socket *,
 static int unix_seqpacket_recvmsg(struct kiocb *, struct socket *,
 				  struct msghdr *, size_t, int);
 
-static void unix_set_peek_off(struct sock *sk, int val)
+static int unix_set_peek_off(struct sock *sk, int val)
 {
 	struct unix_sock *u = unix_sk(sk);
 
-	mutex_lock(&u->readlock);
+	if (mutex_lock_interruptible(&u->readlock))
+		return -EINTR;
+
 	sk->sk_peek_off = val;
 	mutex_unlock(&u->readlock);
+
+	return 0;
 }
 
 
-- 
1.7.10.4
