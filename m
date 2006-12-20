From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch] handle pktgen setup in newer kernels in iputils/ipg
Date: Wed, 20 Dec 2006 10:09:03 -0500
Message-ID: <200612201009.04138.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_QIViFzf+MbU8EpN"
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:55020 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965119AbWLTPJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 10:09:01 -0500
Received: from home.wh0rd.org (pool-141-154-225-206.bos.east.verizon.net [141.154.225.206])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 2944B6476B
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 15:08:54 +0000 (UTC)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_QIViFzf+MbU8EpN
Content-Type: multipart/signed;
  boundary="nextPart1989247.H7Xo9HdZQs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1989247.H7Xo9HdZQs
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

the ipg script only works with the old "pg3" module and not the new "pktgen=
"=20
module ... attached patch updates the ipg script to support both
=2Dmike

--nextPart1989247.H7Xo9HdZQs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFiVIQK9sYciBdMQMRAthTAJ9gYoMQqag09jocyhA2Ia1wVmgJUgCdGH9k
DYIxuuJhsQBZ1GljiAErlDs=
=TQtq
-----END PGP SIGNATURE-----

--nextPart1989247.H7Xo9HdZQs--

--Boundary-00=_QIViFzf+MbU8EpN
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iputils-ipg-tweaks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="iputils-ipg-tweaks.patch"

Only load modules if kernel supports modules and try a little bit
harder to locate the pg directory in /proc with newer kernels.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>

--- a/ipg
+++ b/ipg
@@ -1,21 +1,32 @@
 #! /bin/bash
 
-modprobe pg3
+if [ -e /proc/modules ] ; then
+	modprobe pg3 >& /dev/null
+	modprobe pktgen >& /dev/null
+fi
+
+for PGDEV in /proc/net/pg /proc/net/pktgen/pg0 / ; do
+	[ -e ${PGDEV} ] && break
+done
+if [ "${PGDEV}" = "/" ] ; then
+	echo "Could not locate pg in /proc/net" 1>&2
+	exit 1
+fi
 
 function pgset() {
     local result
 
-    echo $1 > /proc/net/pg
+    echo $1 > ${PGDEV}
 
-    result=`cat /proc/net/pg | fgrep "Result: OK:"`
+    result=`cat ${PGDEV} | fgrep "Result: OK:"`
     if [ "$result" = "" ]; then
-         cat /proc/net/pg | fgrep Result:
+         cat ${PGDEV} | fgrep Result:
     fi
 }
 
 function pg() {
-    echo inject > /proc/net/pg
-    cat /proc/net/pg
+    echo inject > ${PGDEV}
+    cat ${PGDEV}
 }
 
 pgset "odev eth0"

--Boundary-00=_QIViFzf+MbU8EpN--
