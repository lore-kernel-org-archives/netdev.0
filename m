From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: fix race for port number in concurrent bind()
Date: Wed, 23 Sep 2009 16:17:10 +0300
Message-ID: <1253711831-7947-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:54407 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750861AbZIWNRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 09:17:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Allocating a port number to a socket and hashing that socket shall be
an atomic operation with regards to other port allocation. Otherwise,
we could allocate a port that is already being allocated to another
socket.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/socket.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 7a4ee39..07aa9f0 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -113,6 +113,8 @@ void pn_sock_unhash(struct sock *sk)
 }
 EXPORT_SYMBOL(pn_sock_unhash);
=20
+static DEFINE_MUTEX(port_mutex);
+
 static int pn_socket_bind(struct socket *sock, struct sockaddr *addr, =
int len)
 {
 	struct sock *sk =3D sock->sk;
@@ -140,9 +142,11 @@ static int pn_socket_bind(struct socket *sock, str=
uct sockaddr *addr, int len)
 		err =3D -EINVAL; /* attempt to rebind */
 		goto out;
 	}
+	WARN_ON(sk_hashed(sk));
+	mutex_lock(&port_mutex);
 	err =3D sk->sk_prot->get_port(sk, pn_port(handle));
 	if (err)
-		goto out;
+		goto out_port;
=20
 	/* get_port() sets the port, bind() sets the address if applicable */
 	pn->sobject =3D pn_object(saddr, pn_port(pn->sobject));
@@ -150,6 +154,8 @@ static int pn_socket_bind(struct socket *sock, stru=
ct sockaddr *addr, int len)
=20
 	/* Enable RX on the socket */
 	sk->sk_prot->hash(sk);
+out_port:
+	mutex_unlock(&port_mutex);
 out:
 	release_sock(sk);
 	return err;
@@ -357,8 +363,6 @@ const struct proto_ops phonet_stream_ops =3D {
 };
 EXPORT_SYMBOL(phonet_stream_ops);
=20
-static DEFINE_MUTEX(port_mutex);
-
 /* allocate port for a socket */
 int pn_sock_get_port(struct sock *sk, unsigned short sport)
 {
@@ -370,9 +374,7 @@ int pn_sock_get_port(struct sock *sk, unsigned shor=
t sport)
=20
 	memset(&try_sa, 0, sizeof(struct sockaddr_pn));
 	try_sa.spn_family =3D AF_PHONET;
-
-	mutex_lock(&port_mutex);
-
+	WARN_ON(!mutex_is_locked(&port_mutex));
 	if (!sport) {
 		/* search free port */
 		int port, pmin, pmax;
@@ -401,8 +403,6 @@ int pn_sock_get_port(struct sock *sk, unsigned shor=
t sport)
 		else
 			sock_put(tmpsk);
 	}
-	mutex_unlock(&port_mutex);
-
 	/* the port must be in use already */
 	return -EADDRINUSE;
=20
--=20
1.6.0.4

