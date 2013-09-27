From: =?UTF-8?B?RnJhbsOnb2lzIENhY2hlcmV1bA==?= <f.cachereul@init-sys.com>
Subject: [PATCH next] l2tp: add support for IPv4-mapped IPv6 addresses
Date: Fri, 27 Sep 2013 13:17:33 +0200
Message-ID: <5245694D.3070105@init-sys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:56017 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750956Ab3I0LXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 07:23:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 mapped addresses cause kernel panic.
The patch juste check whether the IPv6 address is an IPv4 mapped
address. If so, use IPv4 API instead of IPv6.

Signed-off-by: Fran=C3=A7ois CACHEREUL <f.cachereul@alphalink.fr>
---
 net/l2tp/l2tp_core.c |   28 ++++++++++++++++++++++++----
 net/l2tp/l2tp_core.h |    3 +++
 2 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index feae495..731aa40 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -496,6 +496,7 @@ out:
 static inline int l2tp_verify_udp_checksum(struct sock *sk,
 					   struct sk_buff *skb)
 {
+	struct l2tp_tunnel *tunnel =3D (struct l2tp_tunnel *)sk->sk_user_data=
;
 	struct udphdr *uh =3D udp_hdr(skb);
 	u16 ulen =3D ntohs(uh->len);
 	__wsum psum;
@@ -504,7 +505,7 @@ static inline int l2tp_verify_udp_checksum(struct s=
ock *sk,
 		return 0;
=20
 #if IS_ENABLED(CONFIG_IPV6)
-	if (sk->sk_family =3D=3D PF_INET6) {
+	if (sk->sk_family =3D=3D PF_INET6 && !tunnel->v4mapped) {
 		if (!uh->check) {
 			LIMIT_NETDEBUG(KERN_INFO "L2TP: IPv6: checksum is 0\n");
 			return 1;
@@ -1128,7 +1129,7 @@ static int l2tp_xmit_core(struct l2tp_session *se=
ssion, struct sk_buff *skb,
 	/* Queue the packet to IP for output */
 	skb->local_df =3D 1;
 #if IS_ENABLED(CONFIG_IPV6)
-	if (skb->sk->sk_family =3D=3D PF_INET6)
+	if (skb->sk->sk_family =3D=3D PF_INET6 && !tunnel->v4mapped)
 		error =3D inet6_csk_xmit(skb, NULL);
 	else
 #endif
@@ -1255,7 +1256,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, s=
truct sk_buff *skb, int hdr_len
=20
 		/* Calculate UDP checksum if configured to do so */
 #if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family =3D=3D PF_INET6)
+		if (sk->sk_family =3D=3D PF_INET6 && !tunnel->v4mapped)
 			l2tp_xmit_ipv6_csum(sk, skb, udp_len);
 		else
 #endif
@@ -1620,6 +1621,10 @@ int l2tp_tunnel_create(struct net *net, int fd, =
int version, u32 tunnel_id, u32
 	int err;
 	struct socket *sock =3D NULL;
 	struct sock *sk =3D NULL;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct inet_sock *inet =3D NULL;
+	struct ipv6_pinfo *np =3D NULL;
+#endif
 	struct l2tp_net *pn;
 	enum l2tp_encap_type encap =3D L2TP_ENCAPTYPE_UDP;
=20
@@ -1704,6 +1709,21 @@ int l2tp_tunnel_create(struct net *net, int fd, =
int version, u32 tunnel_id, u32
 	if (cfg !=3D NULL)
 		tunnel->debug =3D cfg->debug;
=20
+#if IS_ENABLED(CONFIG_IPV6)
+	np =3D inet6_sk(sk);
+	if (sk->sk_family =3D=3D PF_INET6 &&
+	    ipv6_addr_v4mapped(&np->saddr) &&
+	    ipv6_addr_v4mapped(&np->daddr)) {
+		tunnel->v4mapped =3D true;
+		inet =3D inet_sk(sk);
+		inet->inet_saddr =3D np->saddr.s6_addr32[3];
+		inet->inet_rcv_saddr =3D np->rcv_saddr.s6_addr32[3];
+		inet->inet_daddr =3D np->daddr.s6_addr32[3];
+	} else {
+		tunnel->v4mapped =3D false;
+	}
+#endif
+
 	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
 	tunnel->encap =3D encap;
 	if (encap =3D=3D L2TP_ENCAPTYPE_UDP) {
@@ -1712,7 +1732,7 @@ int l2tp_tunnel_create(struct net *net, int fd, i=
nt version, u32 tunnel_id, u32
 		udp_sk(sk)->encap_rcv =3D l2tp_udp_encap_recv;
 		udp_sk(sk)->encap_destroy =3D l2tp_udp_encap_destroy;
 #if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family =3D=3D PF_INET6)
+		if (sk->sk_family =3D=3D PF_INET6 && !tunnel->v4mapped)
 			udpv6_encap_enable();
 		else
 #endif
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 66a559b..6f251cb 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -194,6 +194,9 @@ struct l2tp_tunnel {
 	struct sock		*sock;		/* Parent socket */
 	int			fd;		/* Parent fd, if tunnel socket
 						 * was created by userspace */
+#if IS_ENABLED(CONFIG_IPV6)
+	bool			v4mapped;
+#endif
=20
 	struct work_struct	del_work;
=20
--=20
1.7.10.4
