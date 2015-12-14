From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] net: add validation for the socket syscall protocol argument
Date: Mon, 14 Dec 2015 17:17:49 +0100
Message-ID: <1450109869-23769-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39405 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751155AbbLNQR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 11:17:57 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id D8CB6207F0
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:17:55 -0500 (EST)
Received: from z.com (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id 71F86C016D5
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:17:55 -0500 (EST)
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
Reported-by: =E9=83=AD=E6=B0=B8=E5=88=9A <guoyonggang@360.cn>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/af_inet.c  | 3 +++
 net/ipv6/af_inet6.c | 3 +++
 net/socket.c        | 3 +++
 3 files changed, 9 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 11c4ca1..cfb4496 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -257,6 +257,9 @@ static int inet_create(struct net *net, struct sock=
et *sock, int protocol,
 	int try_loading_module =3D 0;
 	int err;
=20
+	if (protocol >=3D IPPROTO_MAX)
+		return -EINVAL;
+
 	sock->state =3D SS_UNCONNECTED;
=20
 	/* Look for the requested type/protocol pair. */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 8ec0df7..9fb093c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -109,6 +109,9 @@ static int inet6_create(struct net *net, struct soc=
ket *sock, int protocol,
 	int try_loading_module =3D 0;
 	int err;
=20
+	if (protocol >=3D IPPROTO_MAX)
+		return -EINVAL;
+
 	/* Look for the requested type/protocol pair. */
 lookup_protocol:
 	err =3D -ESOCKTNOSUPPORT;
diff --git a/net/socket.c b/net/socket.c
index 456fadb..d2f3d49 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1098,6 +1098,9 @@ int __sock_create(struct net *net, int family, in=
t type, int protocol,
 		return -EAFNOSUPPORT;
 	if (type < 0 || type >=3D SOCK_MAX)
 		return -EINVAL;
+	/* upper bound should be tested by per-protocol .create callbacks */
+	if (protocol < 0)
+		return -EINVAL;
=20
 	/* Compatibility.
=20
--=20
2.5.0
