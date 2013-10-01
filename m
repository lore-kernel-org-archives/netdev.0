From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH 1/2] net, vxlan Fix compile warning [v4]
Date: Tue,  1 Oct 2013 09:24:36 -0400
Message-ID: <1380633877-24034-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Prarit Bhargava <prarit@redhat.com>, jpirko@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560Ab3JANYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 09:24:41 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r91DOe9t000533
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 1 Oct 2013 09:24:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix a unintialized variable warning.

drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
drivers/net/vxlan.c:2240:11: error: =E2=80=98sock=E2=80=99 may be used =
uninitialized in this function [-Werror=3Dmaybe-uninitialized]
  vs->sock =3D sock;
           ^
drivers/net/vxlan.c:2217:17: note: =E2=80=98sock=E2=80=99 was declared =
here
  struct socket *sock;
                 ^
[v2]: davem suggested resolving this by making create_v{4,6}_sock() ret=
urn an err
pointer.
[v3]: Ben Hutchings pointed out a missed conversion

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
Cc: jpirko@redhat.com
---
 drivers/net/vxlan.c |   31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d1292fe..cdc78b4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2182,7 +2182,7 @@ static void vxlan_del_work(struct work_struct *wo=
rk)
  * could be used for both IPv4 and IPv6 communications, but
  * users may set bindv6only=3D1.
  */
-static int create_v6_sock(struct net *net, __be16 port, struct socket =
**psock)
+static struct socket *create_v6_sock(struct net *net, __be16 port)
 {
 	struct sock *sk;
 	struct socket *sock;
@@ -2195,7 +2195,7 @@ static int create_v6_sock(struct net *net, __be16=
 port, struct socket **psock)
 	rc =3D sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (rc < 0) {
 		pr_debug("UDPv6 socket create failed\n");
-		return rc;
+		return ERR_PTR(rc);
 	}
=20
 	/* Put in proper namespace */
@@ -2210,28 +2210,27 @@ static int create_v6_sock(struct net *net, __be=
16 port, struct socket **psock)
 		pr_debug("bind for UDPv6 socket %pI6:%u (%d)\n",
 			 &vxlan_addr.sin6_addr, ntohs(vxlan_addr.sin6_port), rc);
 		sk_release_kernel(sk);
-		return rc;
+		return ERR_PTR(rc);
 	}
 	/* At this point, IPv6 module should have been loaded in
 	 * sock_create_kern().
 	 */
 	BUG_ON(!ipv6_stub);
=20
-	*psock =3D sock;
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop =3D 0;
-	return 0;
+	return sock;
 }
=20
 #else
=20
-static int create_v6_sock(struct net *net, __be16 port, struct socket =
**psock)
+static struct socket *create_v6_sock(struct net *net, __be16 port)
 {
-		return -EPFNOSUPPORT;
+		return ERR_PTR(-EPFNOSUPPORT);
 }
 #endif
=20
-static int create_v4_sock(struct net *net, __be16 port, struct socket =
**psock)
+static struct socket *create_v4_sock(struct net *net, __be16 port)
 {
 	struct sock *sk;
 	struct socket *sock;
@@ -2246,7 +2245,7 @@ static int create_v4_sock(struct net *net, __be16=
 port, struct socket **psock)
 	rc =3D sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (rc < 0) {
 		pr_debug("UDP socket create failed\n");
-		return rc;
+		return ERR_PTR(rc);
 	}
=20
 	/* Put in proper namespace */
@@ -2259,13 +2258,12 @@ static int create_v4_sock(struct net *net, __be=
16 port, struct socket **psock)
 		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
 			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
 		sk_release_kernel(sk);
-		return rc;
+		return ERR_PTR(rc);
 	}
=20
-	*psock =3D sock;
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop =3D 0;
-	return 0;
+	return sock;
 }
=20
 /* Create new listen socket if needed */
@@ -2276,7 +2274,6 @@ static struct vxlan_sock *vxlan_socket_create(str=
uct net *net, __be16 port,
 	struct vxlan_sock *vs;
 	struct socket *sock;
 	struct sock *sk;
-	int rc =3D 0;
 	unsigned int h;
=20
 	vs =3D kmalloc(sizeof(*vs), GFP_KERNEL);
@@ -2289,12 +2286,12 @@ static struct vxlan_sock *vxlan_socket_create(s=
truct net *net, __be16 port,
 	INIT_WORK(&vs->del_work, vxlan_del_work);
=20
 	if (ipv6)
-		rc =3D create_v6_sock(net, port, &sock);
+		sock =3D create_v6_sock(net, port);
 	else
-		rc =3D create_v4_sock(net, port, &sock);
-	if (rc < 0) {
+		sock =3D create_v4_sock(net, port);
+	if (IS_ERR(sock)) {
 		kfree(vs);
-		return ERR_PTR(rc);
+		return ERR_CAST(sock);
 	}
=20
 	vs->sock =3D sock;
--=20
1.7.9.3
