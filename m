From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] net: add validation for the socket syscall protocol argument
Date: Mon, 14 Dec 2015 22:03:39 +0100
Message-ID: <1450127019-26920-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:44008 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932080AbbLNVDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:03:51 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 6CC4D20AA3
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 16:03:50 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E9=83=AD=E6=B0=B8=E5=88=9A reported that one could simply crash the ke=
rnel as root by
using a simple program:

	int socket_fd;
	struct sockaddr_in addr;
	addr.sin_port =3D 0;
	addr.sin_addr.s_addr =3D INADDR_ANY;
	addr.sin_family =3D 10;

	socket_fd =3D socket(10,3,0x40000000);
	connect(socket_fd , &addr,16);

AF_INET, AF_INET6 sockets actually only support 8-bit protocol
identifiers. inet_sock's skc_protocol field thus is sized accordingly,
thus larger protocol identifiers simply cut off the higher bits and
store a zero in the protocol fields.

This could lead to e.g. NULL function pointer because as a result of
the cut off inet_num is zero and we call down to inet_autobind, which
is NULL for raw sockets.

kernel: Call Trace:
kernel:  [<ffffffff816db90e>] ? inet_autobind+0x2e/0x70
kernel:  [<ffffffff816db9a4>] inet_dgram_connect+0x54/0x80
kernel:  [<ffffffff81645069>] SYSC_connect+0xd9/0x110
kernel:  [<ffffffff810ac51b>] ? ptrace_notify+0x5b/0x80
kernel:  [<ffffffff810236d8>] ? syscall_trace_enter_phase2+0x108/0x200
kernel:  [<ffffffff81645e0e>] SyS_connect+0xe/0x10
kernel:  [<ffffffff81779515>] tracesys_phase2+0x84/0x89

I found no particular commit which introduced this problem.

CVE: CVE-2015-8543
Cc: Cong Wang <cwang@twopensource.com>
Reported-by: =E9=83=AD=E6=B0=B8=E5=88=9A <guoyonggang@360.cn>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2)
* remove the generic negative check in __sock_create and audit more cal=
lers:
  ax25, decnet, irda turncated the protocol value before writing it int=
o
  the socket. Check for that and return -EINVAL (thanks, Cong!).

 include/net/sock.h     | 1 +
 net/ax25/af_ax25.c     | 3 +++
 net/decnet/af_decnet.c | 3 +++
 net/ipv4/af_inet.c     | 3 +++
 net/ipv6/af_inet6.c    | 3 +++
 net/irda/af_irda.c     | 3 +++
 6 files changed, 16 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index eaef41433d7a3d..c4205e0a3a2d28 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -403,6 +403,7 @@ struct sock {
 				sk_no_check_rx : 1,
 				sk_userlocks : 4,
 				sk_protocol  : 8,
+#define SK_PROTOCOL_MAX U8_MAX
 				sk_type      : 16;
 	kmemcheck_bitfield_end(flags);
 	int			sk_wmem_queued;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index ae3a47f9d1d529..fbd0acf80b1323 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -805,6 +805,9 @@ static int ax25_create(struct net *net, struct sock=
et *sock, int protocol,
 	struct sock *sk;
 	ax25_cb *ax25;
=20
+	if (protocol < 0 || protocol > SK_PROTOCOL_MAX)
+		return -EINVAL;
+
 	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
=20
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index eebf5ac8ce18ab..13d6b1a6e0fc2b 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -678,6 +678,9 @@ static int dn_create(struct net *net, struct socket=
 *sock, int protocol,
 {
 	struct sock *sk;
=20
+	if (protocol < 0 || protocol > SK_PROTOCOL_MAX)
+		return -EINVAL;
+
 	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
=20
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 11c4ca13ec3b04..5c5db6636704da 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -257,6 +257,9 @@ static int inet_create(struct net *net, struct sock=
et *sock, int protocol,
 	int try_loading_module =3D 0;
 	int err;
=20
+	if (protocol < 0 || protocol >=3D IPPROTO_MAX)
+		return -EINVAL;
+
 	sock->state =3D SS_UNCONNECTED;
=20
 	/* Look for the requested type/protocol pair. */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 8ec0df75f1c4f8..9f5137cd604e51 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -109,6 +109,9 @@ static int inet6_create(struct net *net, struct soc=
ket *sock, int protocol,
 	int try_loading_module =3D 0;
 	int err;
=20
+	if (protocol < 0 || protocol >=3D IPPROTO_MAX)
+		return -EINVAL;
+
 	/* Look for the requested type/protocol pair. */
 lookup_protocol:
 	err =3D -ESOCKTNOSUPPORT;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index e6aa48b5395c67..923abd6b306407 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1086,6 +1086,9 @@ static int irda_create(struct net *net, struct so=
cket *sock, int protocol,
 	struct sock *sk;
 	struct irda_sock *self;
=20
+	if (protocol < 0 || protocol > SK_PROTOCOL_MAX)
+		return -EINVAL;
+
 	if (net !=3D &init_net)
 		return -EAFNOSUPPORT;
=20
--=20
2.5.0
