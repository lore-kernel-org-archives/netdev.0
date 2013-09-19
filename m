From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH 1/2] net, vxlan Fix compile warning [v3]
Date: Thu, 19 Sep 2013 09:04:54 -0400
Message-ID: <1379595894-23200-1-git-send-email-prarit@redhat.com>
References: <1379449581.1644.17.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Prarit Bhargava <prarit@redhat.com>, jpirko@redhat.com,
	davem@davemloft.net, stephen@networkplumber.org,
	bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54676 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753391Ab3ISNFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 09:05:12 -0400
In-Reply-To: <1379449581.1644.17.camel@bwh-desktop.uk.level5networks.com>
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
Cc: davem@davemloft.net
Cc: stephen@networkplumber.org
Cc: bhutchings@solarflare.com
---
 drivers/net/vxlan.c |   31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bf64b41..0583d45 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2184,7 +2184,7 @@ static void vxlan_del_work(struct work_struct *wo=
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
@@ -2197,7 +2197,7 @@ static int create_v6_sock(struct net *net, __be16=
 port, struct socket **psock)
 	rc =3D sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (rc < 0) {
 		pr_debug("UDPv6 socket create failed\n");
-		return rc;
+		return ERR_PTR(rc);
 	}
=20
 	/* Put in proper namespace */
@@ -2212,28 +2212,27 @@ static int create_v6_sock(struct net *net, __be=
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
@@ -2248,7 +2247,7 @@ static int create_v4_sock(struct net *net, __be16=
 port, struct socket **psock)
 	rc =3D sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (rc < 0) {
 		pr_debug("UDP socket create failed\n");
-		return rc;
+		return ERR_PTR(rc);
 	}
=20
 	/* Put in proper namespace */
@@ -2261,13 +2260,12 @@ static int create_v4_sock(struct net *net, __be=
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
@@ -2278,7 +2276,6 @@ static struct vxlan_sock *vxlan_socket_create(str=
uct net *net, __be16 port,
 	struct vxlan_sock *vs;
 	struct socket *sock;
 	struct sock *sk;
-	int rc =3D 0;
 	unsigned int h;
=20
 	vs =3D kmalloc(sizeof(*vs), GFP_KERNEL);
@@ -2291,12 +2288,12 @@ static struct vxlan_sock *vxlan_socket_create(s=
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
