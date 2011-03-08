From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 6/8] Phonet: provide pipe socket option to retrieve the pipe identifier
Date: Tue,  8 Mar 2011 15:57:04 +0200
Message-ID: <1299592626-18510-6-git-send-email-remi.denis-courmont@nokia.com>
References: <201103081556.18877.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:37540 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754976Ab1CHN5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 08:57:11 -0500
Received: from leon.remlab.com (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p28Dv8Ch006174
	for <netdev@vger.kernel.org>; Tue, 8 Mar 2011 15:57:10 +0200
In-Reply-To: <201103081556.18877.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User-space sometimes needs this information.

This replaces the buggy code in CONFIG_PHONET_PIPECTRLR case:
this was never used and error cases not handled correctly.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 Documentation/networking/phonet.txt |    7 ++++---
 include/linux/phonet.h              |    2 +-
 net/phonet/pep.c                    |   15 +++++++--------
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networ=
king/phonet.txt
index 24ad2ad..cacac96 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -181,6 +181,10 @@ The pipe protocol provides two socket options at t=
he SOL_PNPIPE level:
     interface index of the network interface created by PNPIPE_ENCAP,
     or zero if encapsulation is off.
=20
+  PNPIPE_HANDLE is a read-only integer value. It contains the underlyi=
ng
+    identifier ("pipe handle") of the pipe. This is only defined for
+    socket descriptors that are already connected or being connected.
+
=20
 Phonet Pipe-controller Implementation
 -------------------------------------
@@ -199,9 +203,6 @@ between itself and a remote pipe-end point (e.g. mo=
dem).
=20
 The implementation adds socket options at SOL_PNPIPE level:
=20
- PNPIPE_PIPE_HANDLE
-	It accepts an integer argument for setting value of pipe handle.
-
   PNPIPE_ENABLE accepts one integer value (int). If set to zero, the p=
ipe
     is disabled. If the value is non-zero, the pipe is enabled. If the=
 pipe
     is not (yet) connected, ENOTCONN is error is returned.
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 26c8df7..32a0965 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -36,7 +36,7 @@
 /* Socket options for SOL_PNPIPE level */
 #define PNPIPE_ENCAP		1
 #define PNPIPE_IFINDEX		2
-#define PNPIPE_PIPE_HANDLE	3
+#define PNPIPE_HANDLE		3
 #define PNPIPE_ENABLE           4
 /* unused slot */
=20
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index c0fab4c..abfb795 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -853,6 +853,7 @@ static int pep_sock_connect(struct sock *sk, struct=
 sockaddr *addr, int len)
=20
 	pn->pn_sk.dobject =3D pn_sockaddr_get_object(spn);
 	pn->pn_sk.resource =3D pn_sockaddr_get_resource(spn);
+	pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */
 	return pipe_handler_request(sk, PNS_PEP_CONNECT_REQ,
 					PN_PIPE_DISABLE, data, 4);
 }
@@ -909,14 +910,6 @@ static int pep_setsockopt(struct sock *sk, int lev=
el, int optname,
=20
 	lock_sock(sk);
 	switch (optname) {
-#ifdef CONFIG_PHONET_PIPECTRLR
-	case PNPIPE_PIPE_HANDLE:
-		if (val) {
-			pn->pipe_handle =3D val;
-			break;
-		}
-#endif
-
 	case PNPIPE_ENCAP:
 		if (val && val !=3D PNPIPE_ENCAP_IP) {
 			err =3D -EINVAL;
@@ -982,6 +975,12 @@ static int pep_getsockopt(struct sock *sk, int lev=
el, int optname,
 		val =3D pn->ifindex;
 		break;
=20
+	case PNPIPE_HANDLE:
+		val =3D pn->pipe_handle;
+		if (val =3D=3D PN_PIPE_INVALID_HANDLE)
+			return -EINVAL;
+		break;
+
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNPIPE_ENABLE:
 		val =3D sk->sk_state =3D=3D TCP_ESTABLISHED;
--=20
1.7.1

