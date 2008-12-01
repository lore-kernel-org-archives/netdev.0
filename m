From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net-next] Phonet: basic net namespace support
Date: Mon,  1 Dec 2008 14:37:21 +0200
Message-ID: <1228135041-22241-2-git-send-email-remi.denis-courmont@nokia.com>
References: <200812011436.25064.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:27902 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550AbYLAMhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 07:37:43 -0500
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mB1Cb4me006412
	for <netdev@vger.kernel.org>; Mon, 1 Dec 2008 06:37:41 -0600
In-Reply-To: <200812011436.25064.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    2 +-
 include/net/phonet/pn_dev.h |    2 +-
 net/phonet/af_phonet.c      |    8 +-------
 net/phonet/pn_dev.c         |    6 ++++--
 net/phonet/socket.c         |   11 +++++++----
 5 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index c6a2451..057b0a8 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -46,7 +46,7 @@ static inline struct pn_sock *pn_sk(struct sock *sk)
=20
 extern const struct proto_ops phonet_dgram_ops;
=20
-struct sock *pn_find_sock_by_sa(const struct sockaddr_pn *sa);
+struct sock *pn_find_sock_by_sa(struct net *net, const struct sockaddr=
_pn *sa);
 void phonet_get_local_port_range(int *min, int *max);
 void pn_sock_hash(struct sock *sk);
 void pn_sock_unhash(struct sock *sk);
diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index bbd2a83..aa1c59a 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -43,7 +43,7 @@ struct net_device *phonet_device_get(struct net *net)=
;
 int phonet_address_add(struct net_device *dev, u8 addr);
 int phonet_address_del(struct net_device *dev, u8 addr);
 u8 phonet_address_get(struct net_device *dev, u8 addr);
-int phonet_address_lookup(u8 addr);
+int phonet_address_lookup(struct net *net, u8 addr);
=20
 #define PN_NO_ADDR	0xff
=20
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 9d211f1..13cb323 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -67,9 +67,6 @@ static int pn_socket_create(struct net *net, struct s=
ocket *sock, int protocol)
 	struct phonet_protocol *pnp;
 	int err;
=20
-	if (net !=3D &init_net)
-		return -EAFNOSUPPORT;
-
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
=20
@@ -352,9 +349,6 @@ static int phonet_rcv(struct sk_buff *skb, struct n=
et_device *dev,
 	struct sockaddr_pn sa;
 	u16 len;
=20
-	if (dev_net(dev) !=3D &init_net)
-		goto out;
-
 	/* check we have at least a full Phonet header */
 	if (!pskb_pull(skb, sizeof(struct phonethdr)))
 		goto out;
@@ -373,7 +367,7 @@ static int phonet_rcv(struct sk_buff *skb, struct n=
et_device *dev,
 	if (pn_sockaddr_get_addr(&sa) =3D=3D 0)
 		goto out; /* currently, we cannot be device 0 */
=20
-	sk =3D pn_find_sock_by_sa(&sa);
+	sk =3D pn_find_sock_by_sa(dev_net(dev), &sa);
 	if (sk =3D=3D NULL) {
 		if (can_respond(skb)) {
 			send_obj_unreachable(skb);
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 53be9fc..ab3b91e 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -76,7 +76,7 @@ struct net_device *phonet_device_get(struct net *net)
 		dev =3D pnd->netdev;
 		BUG_ON(!dev);
=20
-		if (dev_net(dev) =3D=3D net &&
+		if (net_eq(dev_net(dev), net) &&
 			(dev->reg_state =3D=3D NETREG_REGISTERED) &&
 			((pnd->netdev->flags & IFF_UP)) =3D=3D IFF_UP)
 			break;
@@ -140,12 +140,14 @@ u8 phonet_address_get(struct net_device *dev, u8 =
addr)
 	return addr;
 }
=20
-int phonet_address_lookup(u8 addr)
+int phonet_address_lookup(struct net *net, u8 addr)
 {
 	struct phonet_device *pnd;
=20
 	spin_lock_bh(&pndevs.lock);
 	list_for_each_entry(pnd, &pndevs.list, list) {
+		if (!net_eq(dev_net(pnd->netdev), net))
+			continue;
 		/* Don't allow unregistering devices! */
 		if ((pnd->netdev->reg_state !=3D NETREG_REGISTERED) ||
 				((pnd->netdev->flags & IFF_UP)) !=3D IFF_UP)
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index d817401..c75aa5c 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -57,7 +57,7 @@ static struct  {
  * Find address based on socket address, match only certain fields.
  * Also grab sock if it was found. Remember to sock_put it later.
  */
-struct sock *pn_find_sock_by_sa(const struct sockaddr_pn *spn)
+struct sock *pn_find_sock_by_sa(struct net *net, const struct sockaddr=
_pn *spn)
 {
 	struct hlist_node *node;
 	struct sock *sknode;
@@ -71,6 +71,8 @@ struct sock *pn_find_sock_by_sa(const struct sockaddr=
_pn *spn)
 		struct pn_sock *pn =3D pn_sk(sknode);
 		BUG_ON(!pn->sobject); /* unbound socket */
=20
+		if (!net_eq(sock_net(sknode), net))
+			continue;
 		if (pn_port(obj)) {
 			/* Look up socket by port */
 			if (pn_port(pn->sobject) !=3D pn_port(obj))
@@ -130,7 +132,7 @@ static int pn_socket_bind(struct socket *sock, stru=
ct sockaddr *addr, int len)
=20
 	handle =3D pn_sockaddr_get_object((struct sockaddr_pn *)addr);
 	saddr =3D pn_addr(handle);
-	if (saddr && phonet_address_lookup(saddr))
+	if (saddr && phonet_address_lookup(sock_net(sk), saddr))
 		return -EADDRNOTAVAIL;
=20
 	lock_sock(sk);
@@ -361,6 +363,7 @@ static DEFINE_MUTEX(port_mutex);
 int pn_sock_get_port(struct sock *sk, unsigned short sport)
 {
 	static int port_cur;
+	struct net *net =3D sock_net(sk);
 	struct pn_sock *pn =3D pn_sk(sk);
 	struct sockaddr_pn try_sa;
 	struct sock *tmpsk;
@@ -381,7 +384,7 @@ int pn_sock_get_port(struct sock *sk, unsigned shor=
t sport)
 				port_cur =3D pmin;
=20
 			pn_sockaddr_set_port(&try_sa, port_cur);
-			tmpsk =3D pn_find_sock_by_sa(&try_sa);
+			tmpsk =3D pn_find_sock_by_sa(net, &try_sa);
 			if (tmpsk =3D=3D NULL) {
 				sport =3D port_cur;
 				goto found;
@@ -391,7 +394,7 @@ int pn_sock_get_port(struct sock *sk, unsigned shor=
t sport)
 	} else {
 		/* try to find specific port */
 		pn_sockaddr_set_port(&try_sa, sport);
-		tmpsk =3D pn_find_sock_by_sa(&try_sa);
+		tmpsk =3D pn_find_sock_by_sa(net, &try_sa);
 		if (tmpsk =3D=3D NULL)
 			/* No sock there! We can use that port... */
 			goto found;
--=20
1.5.4.3

