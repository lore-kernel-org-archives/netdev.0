From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch/iputils] use proper loop constructs rather than goto's
Date: Wed, 20 Dec 2006 10:17:54 -0500
Message-ID: <200612201017.54707.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_iQViFdYs9cN7ul3"
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:44601 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965131AbWLTPRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 10:17:44 -0500
Received: from home.wh0rd.org (pool-141-154-225-206.bos.east.verizon.net [141.154.225.206])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 67E2D649C2
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 15:17:43 +0000 (UTC)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_iQViFdYs9cN7ul3
Content-Type: multipart/signed;
  boundary="nextPart1429267.B6zCm0yvdT";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1429267.B6zCm0yvdT
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

a bunch of places in the tracepath code use goto's rather than real loop co=
de,=20
or goto's to jump out of loop's ... some versions (like gcc-3.3.x iirc, old=
er=20
admittedly) would miscompile this and it's cleaner anyways to just use real=
=20
loops

the attached patch isnt applicable as is (style changes required mostly) as=
 i=20
just want to see if people will accept it or the answer is "upgrade your gc=
c=20
to like 4.1.x"
=2Dmike

--nextPart1429267.B6zCm0yvdT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFiVQiK9sYciBdMQMRAg/6AJ43m0vMEpfyAX9PLtilEM7rBH+dsQCfapmU
xb2fvUDbb/+oRJSeGP8ngxY=
=iH51
-----END PGP SIGNATURE-----

--nextPart1429267.B6zCm0yvdT--

--Boundary-00=_iQViFdYs9cN7ul3
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iputils-use-proper-loops.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="iputils-use-proper-loops.patch"

use proper looping code rather than labels/gotos as some versions of
gcc may miscompile the code.

Signed-off-by: Robert Moss <robmoss@gentoo.org>
Signed-off-by: Mike Frysinger <robmoss@gentoo.org>

diff --git a/tracepath.c b/tracepath.c
index c3f6f74..7ff85a2 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -77,7 +77,7 @@ int recverr(int fd, int ttl)
 	int progress = -1;
 	int broken_router;
 	
-restart:
+       while (1) {
 	memset(&rcvbuf, -1, sizeof(rcvbuf));
 	iov.iov_base = &rcvbuf;
 	iov.iov_len = sizeof(rcvbuf);
@@ -94,7 +94,7 @@ restart:
 	if (res < 0) {
 		if (errno == EAGAIN)
 			return progress;
-		goto restart;
+		continue;
 	}
 
 	progress = mtu;
@@ -217,7 +217,7 @@ restart:
 		perror("NET ERROR");
 		return 0;
 	}
-	goto restart;
+       }
 }
 
 int probe_ttl(int fd, int ttl)
@@ -228,7 +228,6 @@ int probe_ttl(int fd, int ttl)
 
 	memset(sndbuf,0,mtu);
 
-restart:
 	for (i=0; i<10; i++) {
 		int res;
 
@@ -244,7 +243,8 @@ restart:
 		if (res==0)
 			return 0;
 		if (res > 0)
-			goto restart;
+			i = 0;
+			continue;
 	}
 	hisptr = (hisptr + 1)&63;
 
diff --git a/tracepath6.c b/tracepath6.c
index 23d6a8c..6d2a95b 100644
--- a/tracepath6.c
+++ b/tracepath6.c
@@ -71,7 +71,7 @@ int recverr(int fd, int ttl)
 	int progress = -1;
 	int broken_router;
 
-restart:
+       while (1) {
 	memset(&rcvbuf, -1, sizeof(rcvbuf));
 	iov.iov_base = &rcvbuf;
 	iov.iov_len = sizeof(rcvbuf);
@@ -88,7 +88,7 @@ restart:
 	if (res < 0) {
 		if (errno == EAGAIN)
 			return progress;
-		goto restart;
+		continue;
 	}
 
 	progress = 2;
@@ -233,34 +233,29 @@ restart:
 		perror("NET ERROR");
 		return 0;
 	}
-	goto restart;
+       }
 }
 
 int probe_ttl(int fd, int ttl)
 {
-	int i;
+	int i=0, res;
 	char sndbuf[mtu];
 	struct probehdr *hdr = (struct probehdr*)sndbuf;
 
-restart:
-
-	for (i=0; i<10; i++) {
-		int res;
-
-		hdr->ttl = ttl;
-		gettimeofday(&hdr->tv, NULL);
-		if (send(fd, sndbuf, mtu-overhead, 0) > 0)
-			break;
-		res = recverr(fd, ttl);
-		if (res==0)
-			return 0;
-		if (res > 0)
-			goto restart;
-	}
-
-	if (i<10) {
-		int res;
-
+	while (i<10) {
+		for (i=0; i<10; i++) {
+			hdr->ttl = ttl;
+			gettimeofday(&hdr->tv, NULL);
+			if (send(fd, sndbuf, mtu-overhead, 0) > 0)
+				break;
+			res = recverr(fd, ttl);
+			if (res==0)
+				return 0;
+			if (res > 0) {
+				i = 0;
+				continue;
+			}
+		}
 		data_wait(fd);
 		if (recv(fd, sndbuf, sizeof(sndbuf), MSG_DONTWAIT) > 0) {
 			printf("%2d?: reply received 8)\n", ttl);
@@ -268,7 +263,7 @@ restart:
 		}
 		res = recverr(fd, ttl);
 		if (res == 1)
-			goto restart;
+			continue;
 		return res;
 	}
 

--Boundary-00=_iQViFdYs9cN7ul3--
