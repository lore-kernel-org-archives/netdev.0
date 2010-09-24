From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 2/5] AF_UNIX: enable/disable multicast with getsockopt/setsockopt
Date: Fri, 24 Sep 2010 18:25:13 +0100
Message-ID: <1285349116-17529-2-git-send-email-alban.crequy@collabora.co.uk>
References: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbus@freedesktop.org, Alban Crequy <alban.crequy@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Multicast can be enabled or disabled after a socket is allocated but this
cannot be changed once the socket is bound or connected.

Userspace applications can enable multicast on an Unix stream socket:
  sockfd = socket(AF_UNIX, SOCK_STREAM, 0);
  #define UNIX_MULTICAST 1
  val = 1;
  len = sizeof(val);
  ret = setsockopt(sockfd, 0, UNIX_MULTICAST, &val, len);

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 include/net/af_unix.h |    4 +++
 net/unix/af_unix.c    |   57 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 20725e2..4c77c69 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -40,6 +40,9 @@ struct unix_skb_parms {
 				spin_lock_nested(&unix_sk(s)->lock, \
 				SINGLE_DEPTH_NESTING)
 
+/* UNIX socket options */
+#define UNIX_MULTICAST	1	/* Enable multicast Unix sockets */
+
 #ifdef __KERNEL__
 /* The AF_UNIX socket */
 struct unix_sock {
@@ -56,6 +59,7 @@ struct unix_sock {
 	spinlock_t		lock;
 	unsigned int		gc_candidate : 1;
 	unsigned int		gc_maybe_cycle : 1;
+	unsigned int		multicast : 1;
 	struct socket_wq	peer_wq;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 47d9f77..c766e88 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1501,13 +1501,66 @@ out:
 static int unix_stream_setsockopt(struct socket *sock, int level, int optname,
 				  char __user *optval, unsigned int optlen)
 {
-	return -EOPNOTSUPP;
+	struct unix_sock *u = unix_sk(sock->sk);
+	int val;
+	int err = 0;
+
+	if (optlen < sizeof(int))
+		return -EINVAL;
+
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+
+	switch (optname) {
+	case UNIX_MULTICAST:
+		/* Multicast feature can only be changed when the socket is
+		 * not used yet */
+		if (u->addr || sock->sk->sk_state != TCP_CLOSE)
+			return -EINVAL;
+
+		if (val != 0) {
+			u->multicast = 1;
+		} else {
+			u->multicast = 0;
+		}
+		break;
+
+	default:
+		err = -ENOPROTOOPT;
+		break;
+	}
+
+	return err;
 }
 
 int unix_stream_getsockopt(struct socket *sock, int level, int optname,
 			   char __user *optval, int __user *optlen)
 {
-	return -EOPNOTSUPP;
+	struct unix_sock *u = unix_sk(sock->sk);
+	int val, len;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+
+	len = min_t(unsigned int, len, sizeof(int));
+
+	if (len < 0)
+		return -EINVAL;
+
+	switch (optname) {
+	case UNIX_MULTICAST:
+		val = u->multicast;
+		break;
+
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+	return 0;
 }
 
 
-- 
1.7.1
