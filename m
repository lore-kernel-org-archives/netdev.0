From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH v2 1/3] vxlan: silence one build warning
Date: Mon, 28 Oct 2013 14:01:48 +0800
Message-ID: <1382940110-10737-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
drivers/net/vxlan.c:2298:11: warning: =E2=80=98sock=E2=80=99 may be use=
d uninitialized in this function [-Wmaybe-uninitialized]
drivers/net/vxlan.c:2275:17: note: =E2=80=98sock=E2=80=99 was declared =
here
  LD      drivers/net/built-in.o

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/vxlan.c | 31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2ef5b62..019e1f4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2180,7 +2180,7 @@ static void vxlan_del_work(struct work_struct *wo=
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
@@ -2193,7 +2193,7 @@ static int create_v6_sock(struct net *net, __be16=
 port, struct socket **psock)
 	rc =3D sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (rc < 0) {
 		pr_debug("UDPv6 socket create failed\n");
-		return rc;
+		return ERR_PTR(rc);
 	}
=20
 	/* Put in proper namespace */
@@ -2208,28 +2208,27 @@ static int create_v6_sock(struct net *net, __be=
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
@@ -2244,7 +2243,7 @@ static int create_v4_sock(struct net *net, __be16=
 port, struct socket **psock)
 	rc =3D sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (rc < 0) {
 		pr_debug("UDP socket create failed\n");
-		return rc;
+		return ERR_PTR(rc);
 	}
=20
 	/* Put in proper namespace */
@@ -2257,13 +2256,12 @@ static int create_v4_sock(struct net *net, __be=
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
@@ -2274,7 +2272,6 @@ static struct vxlan_sock *vxlan_socket_create(str=
uct net *net, __be16 port,
 	struct vxlan_sock *vs;
 	struct socket *sock;
 	struct sock *sk;
-	int rc =3D 0;
 	unsigned int h;
=20
 	vs =3D kmalloc(sizeof(*vs), GFP_KERNEL);
@@ -2287,12 +2284,12 @@ static struct vxlan_sock *vxlan_socket_create(s=
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
+		return ERR_PTR(PTR_ERR(sock));
 	}
=20
 	vs->sock =3D sock;
--=20
1.7.11.7
