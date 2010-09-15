From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: resource routing backend
Date: Thu, 16 Sep 2010 01:30:11 +0300
Message-ID: <1284589815-28302-1-git-send-email-remi@remlab.net>
References: <d214bd6716258777ce8b1023208bc347@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36520 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753699Ab0IOWaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 18:30:17 -0400
In-Reply-To: <d214bd6716258777ce8b1023208bc347@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

When both destination device and object are nul, Phonet routes the
packet according to the resource field. In fact, this is the most
common pattern when sending Phonet "request" packets. In this case,
the packet is delivered to whichever endpoint (socket) has
registered the resource.

This adds a new table so that Linux processes can register their
Phonet sockets to Phonet resources, if they have adequate privileges.

(Namespace support is not implemented at the moment.)

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    5 ++
 net/phonet/socket.c         |   88 +++++++++++++++++++++++++++++++++++=
++++++++
 2 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index 7b11407..d5df797 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -54,6 +54,11 @@ void pn_sock_hash(struct sock *sk);
 void pn_sock_unhash(struct sock *sk);
 int pn_sock_get_port(struct sock *sk, unsigned short sport);
=20
+struct sock *pn_find_sock_by_res(struct net *net, u8 res);
+int pn_sock_bind_res(struct sock *sock, u8 res);
+int pn_sock_unbind_res(struct sock *sk, u8 res);
+void pn_sock_unbind_all_res(struct sock *sk);
+
 int pn_skb_send(struct sock *sk, struct sk_buff *skb,
 		const struct sockaddr_pn *target);
=20
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 7c91f73..4c29a23 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -565,3 +565,91 @@ const struct file_operations pn_sock_seq_fops =3D =
{
 	.release =3D seq_release_net,
 };
 #endif
+
+static struct  {
+	struct sock *sk[256];
+} pnres;
+
+/*
+ * Find and hold socket based on resource.
+ */
+struct sock *pn_find_sock_by_res(struct net *net, u8 res)
+{
+	struct sock *sk;
+
+	if (!net_eq(net, &init_net))
+		return NULL;
+
+	rcu_read_lock();
+	sk =3D rcu_dereference(pnres.sk[res]);
+	if (sk)
+		sock_hold(sk);
+	rcu_read_unlock();
+	return sk;
+}
+
+static DEFINE_MUTEX(resource_mutex);
+
+int pn_sock_bind_res(struct sock *sk, u8 res)
+{
+	int ret =3D -EADDRINUSE;
+
+	if (!net_eq(sock_net(sk), &init_net))
+		return -ENOIOCTLCMD;
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	if (pn_socket_autobind(sk->sk_socket))
+		return -EAGAIN;
+
+	mutex_lock(&resource_mutex);
+	if (pnres.sk[res] =3D=3D NULL) {
+		sock_hold(sk);
+		rcu_assign_pointer(pnres.sk[res], sk);
+		ret =3D 0;
+	}
+	mutex_unlock(&resource_mutex);
+	return ret;
+}
+
+int pn_sock_unbind_res(struct sock *sk, u8 res)
+{
+	int ret =3D -ENOENT;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	mutex_lock(&resource_mutex);
+	if (pnres.sk[res] =3D=3D sk) {
+		rcu_assign_pointer(pnres.sk[res], NULL);
+		ret =3D 0;
+	}
+	mutex_unlock(&resource_mutex);
+
+	if (ret =3D=3D 0) {
+		synchronize_rcu();
+		sock_put(sk);
+	}
+	return ret;
+}
+
+void pn_sock_unbind_all_res(struct sock *sk)
+{
+	unsigned res, match =3D 0;
+
+	mutex_lock(&resource_mutex);
+	for (res =3D 0; res < 256; res++) {
+		if (pnres.sk[res] =3D=3D sk) {
+			rcu_assign_pointer(pnres.sk[res], NULL);
+			match++;
+		}
+	}
+	mutex_unlock(&resource_mutex);
+
+	if (match =3D=3D 0)
+		return;
+	synchronize_rcu();
+	while (match > 0) {
+		sock_put(sk);
+		match--;
+	}
+}
--=20
1.7.0.4

