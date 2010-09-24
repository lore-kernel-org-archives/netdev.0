From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 3/5] AF_UNIX: implement connect() on multicast Unix stream socket
Date: Fri, 24 Sep 2010 18:25:14 +0100
Message-ID: <1285349116-17529-3-git-send-email-alban.crequy@collabora.co.uk>
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

All multicast peers use connect() without any bound socket.

Multicast Unix socket addresses and non-multicast Unix socket addresses live in
the same namespace. An userspace application cannot connect() a non-multicast
socket if the address is already used for multicast sockets.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 net/unix/af_unix.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index c766e88..a8d9de7 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1064,9 +1064,20 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 restart:
 	/*  Find listening sock. */
 	other = unix_find_other(net, sunaddr, addr_len, sk->sk_type, hash, &err);
-	if (!other)
+	if (!other && !u->multicast)
 		goto out;
 
+	if (other && u->multicast) {
+		err = -ECONNREFUSED;
+		goto out;
+	}
+
+	if (u->multicast) {
+		sock->state = SS_CONNECTED;
+		sk->sk_state  = TCP_ESTABLISHED;
+		return 0;
+	}
+
 	/* Latch state of peer */
 	unix_state_lock(other);
 
@@ -1567,6 +1578,7 @@ int unix_stream_getsockopt(struct socket *sock, int level, int optname,
 static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			       struct msghdr *msg, size_t len)
 {
+	struct unix_sock *u = unix_sk(sock->sk);
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
@@ -1591,12 +1603,18 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (msg->msg_namelen) {
 		err = sk->sk_state == TCP_ESTABLISHED ? -EISCONN : -EOPNOTSUPP;
 		goto out_err;
-	} else {
+	} else if (!u->multicast) {
 		sunaddr = NULL;
 		err = -ENOTCONN;
 		other = unix_peer(sk);
 		if (!other)
 			goto out_err;
+	} else {
+		sunaddr = NULL;
+		err = -ENOTCONN;
+		other = NULL; /* FIXME: get the list of other connection */
+		if (!other)
+			goto out_err;
 	}
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN)
-- 
1.7.1
