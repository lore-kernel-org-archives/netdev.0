From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 2/6] Phonet: implement per-socket destination/peer address
Date: Fri, 25 Feb 2011 11:14:57 +0200
Message-ID: <1298625301-13909-2-git-send-email-remi.denis-courmont@nokia.com>
References: <201102251113.41620.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:30591 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191Ab1BYJOW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 04:14:22 -0500
Received: from leon.remlab.com (helruo-dhcp021243.ntc.nokia.com [172.21.21.243])
	by mgw-da01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p1P9EHG1005431
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:14:20 +0200
In-Reply-To: <201102251113.41620.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    1 +
 net/phonet/af_phonet.c      |   19 ++++++++++++++-----
 net/phonet/socket.c         |    4 ++--
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index 5395e09..68e5097 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -36,6 +36,7 @@
 struct pn_sock {
 	struct sock	sk;
 	u16		sobject;
+	u16		dobject;
 	u8		resource;
 };
=20
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 1072b2c..30cc676 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -110,6 +110,7 @@ static int pn_socket_create(struct net *net, struct=
 socket *sock, int protocol,
 	sk->sk_protocol =3D protocol;
 	pn =3D pn_sk(sk);
 	pn->sobject =3D 0;
+	pn->dobject =3D 0;
 	pn->resource =3D 0;
 	sk->sk_prot->init(sk);
 	err =3D 0;
@@ -242,8 +243,18 @@ int pn_skb_send(struct sock *sk, struct sk_buff *s=
kb,
 	struct net_device *dev;
 	struct pn_sock *pn =3D pn_sk(sk);
 	int err;
-	u16 src;
-	u8 daddr =3D pn_sockaddr_get_addr(target), saddr =3D PN_NO_ADDR;
+	u16 src, dst;
+	u8 daddr, saddr, res;
+
+	src =3D pn->sobject;
+	if (target !=3D NULL) {
+		dst =3D pn_sockaddr_get_object(target);
+		res =3D pn_sockaddr_get_resource(target);
+	} else {
+		dst =3D pn->dobject;
+		res =3D pn->resource;
+	}
+	daddr =3D pn_addr(dst);
=20
 	err =3D -EHOSTUNREACH;
 	if (sk->sk_bound_dev_if)
@@ -271,12 +282,10 @@ int pn_skb_send(struct sock *sk, struct sk_buff *=
skb,
 	if (saddr =3D=3D PN_NO_ADDR)
 		goto drop;
=20
-	src =3D pn->sobject;
 	if (!pn_addr(src))
 		src =3D pn_object(saddr, pn_obj(src));
=20
-	err =3D pn_send(skb, dev, pn_sockaddr_get_object(target),
-			src, pn_sockaddr_get_resource(target), 0);
+	err =3D pn_send(skb, dev, dst, src, res, 0);
 	dev_put(dev);
 	return err;
=20
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index ceb5143..65a0333 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -633,8 +633,8 @@ static int pn_sock_seq_show(struct seq_file *seq, v=
oid *v)
=20
 		seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu "
 			"%d %p %d%n",
-			sk->sk_protocol, pn->sobject, 0, pn->resource,
-			sk->sk_state,
+			sk->sk_protocol, pn->sobject, pn->dobject,
+			pn->resource, sk->sk_state,
 			sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
 			sock_i_uid(sk), sock_i_ino(sk),
 			atomic_read(&sk->sk_refcnt), sk,
--=20
1.7.1

