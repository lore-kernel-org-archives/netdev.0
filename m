From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 04/12] Fix up various problems in netbug script.
Date: Fri, 12 Oct 2007 10:56:39 +0200
Message-ID: <1192179407-22461-4-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
 <1192179407-22461-2-git-send-email-andreas@fatal.se>
 <1192179407-22461-3-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?utf-8?q?Javier=20Fern=C3=A1ndez-Sanguino=20Pe=C3=B1a?=
	<jfs@computer.org>, Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38401 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386AbXJLI5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:57:36 -0400
In-Reply-To: <1192179407-22461-3-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Javier Fern=C3=A1ndez-Sanguino Pe=C3=B1a <jfs@computer.org>

=46ix race conditions and temporary file symlink attacks.
See http://bugs.debian.org/289541

Additional improvements by Allard Hoeve <allard@byte.nl> and others.
See http://bugs.debian.org/313540, http://bugs.debian.org/313541,
and http://bugs.debian.org/313544.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 misc/netbug |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/misc/netbug b/misc/netbug
index 6d13c8e..7b6ecea 100644
--- a/misc/netbug
+++ b/misc/netbug
@@ -1,23 +1,16 @@
 #! /bin/bash
=20
+set -e
+
 echo -n "Send network configuration summary to [ENTER means kuznet@ms2=
=2Einr.ac.ru] "
 IFS=3D"" read mail || exit 1
 [ -z "$mail" ] && mail=3Dkuznet@ms2.inr.ac.ru
=20
+netbug=3D`mktemp -d -t netbug.XXXXXX` || (echo "$0: Cannot create temp=
orary directory" >&2; exit 1; )
+netbugtar=3D`tempfile -d $netbug --suffix=3Dtar.gz` || (echo "$0: Cann=
ot create temporary file" >&2; exit 1; )
+tmppath=3D$netbug
+trap "/bin/rm -rf $netbug $netbugtar" 0 1 2 3 13 15
=20
-netbug=3D""
-while [ "$netbug" =3D "" ]; do
-	netbug=3D`echo netbug.$$.$RANDOM`
-	if [ -e /tmp/$netbug ]; then
-		netbug=3D""
-	fi
-done
-
-tmppath=3D/tmp/$netbug
-
-trap "rm -rf $tmppath $tmppath.tar.gz" 0 SIGINT
-
-mkdir $tmppath
 mkdir $tmppath/net
=20
 cat /proc/slabinfo > $tmppath/slabinfo
@@ -44,9 +37,8 @@ if [ -e /proc/net/tcp6 ]; then
 fi
=20
 cd /tmp
-tar c $netbug | gzip -9c > $netbug.tar.gz
-
-uuencode $netbug.tar.gz $netbug.tar.gz | mail -s $netbug "$mail"
+tar c $tmppath | gzip -9c > $netbugtar
+uuencode $netbugtar $netbugtar | mail -s $netbug "$mail"
=20
 echo "Sending to <$mail>; subject is $netbug"
=20
--=20
1.5.3.4

