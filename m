From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/3] sk: Introduce the shutdown user-to-mask routine
Date: Tue, 23 Oct 2012 20:22:50 +0400
Message-ID: <5086C45A.4030703@parallels.com>
References: <5086C36B.6060508@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20804 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754531Ab2JWQWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 12:22:54 -0400
In-Reply-To: <5086C36B.6060508@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sys_shutdown "how" argument is converted into kernel-side mask
with a trick -- the "how++" does proper bits conversion. And since
this is a trick, it's commented in the respective places.

When there will be sk_shutdown reporting mechanism it will be natural
to report not the kernel-side mask, but the values known by userspace
(this "how" thing), i.e. we'll have to do the reciprocal trick.

I propose to encapsulate both tricks in helpers, here's the user to
kernel one.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 include/net/sock.h |   18 ++++++++++++++++++
 net/ipv4/af_inet.c |    7 +++----
 net/iucv/af_iucv.c |    5 ++---
 net/unix/af_unix.c |    9 ++-------
 4 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c945fba..c42c115 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1265,6 +1265,24 @@ void sk_prot_clear_portaddr_nulls(struct sock *sk, int size);
 #define RCV_SHUTDOWN	1
 #define SEND_SHUTDOWN	2
 
+static inline int shutdown_u2mask(int uhow)
+{
+	/*
+	 * map
+	 * 	SHUT_RD -> RCV_SHUTDOWN
+	 * 	SHUT_WR -> SEND_SHUTDOWN
+	 * 	SHUT_RDWR -> SHUTDOWN_MASK
+	 *
+	 * or report 0 on error
+	 */
+
+	uhow++;
+	if (uhow & ~SHUTDOWN_MASK)
+		uhow = 0;
+
+	return uhow;
+}
+
 #define SOCK_SNDBUF_LOCK	1
 #define SOCK_RCVBUF_LOCK	2
 #define SOCK_BINDADDR_LOCK	4
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 766c596..3b3940c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -825,10 +825,9 @@ int inet_shutdown(struct socket *sock, int how)
 	/* This should really check to make sure
 	 * the socket is a TCP socket. (WHY AC...)
 	 */
-	how++; /* maps 0->1 has the advantage of making bit 1 rcvs and
-		       1->2 bit 2 snds.
-		       2->3 */
-	if ((how & ~SHUTDOWN_MASK) || !how)	/* MAXINT->0 */
+
+	how = shutdown_u2mask(how);
+	if (!how)
 		return -EINVAL;
 
 	lock_sock(sk);
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index cd6f7a9..308024c 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1497,9 +1497,8 @@ static int iucv_sock_shutdown(struct socket *sock, int how)
 	struct iucv_message txmsg;
 	int err = 0;
 
-	how++;
-
-	if ((how & ~SHUTDOWN_MASK) || !how)
+	how = shutdown_u2mask(how);
+	if (!how)
 		return -EINVAL;
 
 	lock_sock(sk);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5b5c876..14543f2 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2057,14 +2057,9 @@ static int unix_shutdown(struct socket *sock, int mode)
 	struct sock *sk = sock->sk;
 	struct sock *other;
 
-	if (mode < SHUT_RD || mode > SHUT_RDWR)
+	mode = shutdown_u2mask(mode);
+	if (!mode)
 		return -EINVAL;
-	/* This maps:
-	 * SHUT_RD   (0) -> RCV_SHUTDOWN  (1)
-	 * SHUT_WR   (1) -> SEND_SHUTDOWN (2)
-	 * SHUT_RDWR (2) -> SHUTDOWN_MASK (3)
-	 */
-	++mode;
 
 	unix_state_lock(sk);
 	sk->sk_shutdown |= mode;
-- 
1.7.6.5
