From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] iproute2: Auto-detect the presence of setns in libc
Date: Fri, 15 Jul 2011 17:26:59 -0700
Message-ID: <m1mxgfkr3g.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Dan McGee <dan@archlinux.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59900 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab1GPA1F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 20:27:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If libc has setns present use that version instead of
rolling the syscall wrapper by hand.

Dan McGee found the following compile error:

    gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include
    -DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\"   -c -o ipnetns.o ipne=
tns.c
    ipnetns.c:31:12: error: static declaration of =E2=80=98setns=E2=80=99=
 follows non-static
    declaration
    /usr/include/bits/sched.h:93:12: note: previous declaration of =E2=80=
=98setns=E2=80=99
    was here
    make[1]: *** [ipnetns.o] Error 1

Reported-by:  Dan McGee <dan@archlinux.org>
Tested-by:  Dan McGee <dan@archlinux.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 configure    |   24 ++++++++++++++++++++++++
 ip/Makefile  |    6 ++++++
 ip/ipnetns.c |    2 ++
 3 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index 69797ab..cfcc82a 100755
--- a/configure
+++ b/configure
@@ -163,6 +163,27 @@ check_ipt_lib_dir()
 	echo "not found!"
 }
=20
+check_setns()
+{
+cat >/tmp/setnstest.c <<EOF
+#include <sched.h>
+int main(int argc, char **argv)=20
+{
+	(void)setns(0,0);
+	return 0;
+}
+EOF
+gcc -I$INCLUDE -o /tmp/setnstest /tmp/setnstest.c >/dev/null 2>&1
+if [ $? -eq 0 ]
+then
+	echo "IP_CONFIG_SETNS:=3Dy" >>Config
+	echo "yes"
+else
+	echo "no"
+fi
+rm -f /tmp/setnstest.c /tmp/setnstest
+}
+
 echo "# Generated config based on" $INCLUDE >Config
=20
 echo "TC schedulers"
@@ -178,3 +199,6 @@ check_ipt
=20
 echo -n "iptables modules directory: "
 check_ipt_lib_dir
+
+echo -n "libc has setns: "
+check_setns
diff --git a/ip/Makefile b/ip/Makefile
index 2ee4e7c..8d03993 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -7,6 +7,12 @@ IPOBJ=3Dip.o ipaddress.o ipaddrlabel.o iproute.o iprul=
e.o ipnetns.o \
=20
 RTMONOBJ=3Drtmon.o
=20
+include ../Config
+
+ifeq ($(IP_CONFIG_SETNS),y)
+	CFLAGS +=3D -DHAVE_SETNS
+endif
+
 ALLOBJ=3D$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=3Difcfg rtpr routel routef
 TARGETS=3Dip rtmon
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index db7007c..dff3497 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -28,6 +28,7 @@
 #define MNT_DETACH	0x00000002	/* Just detach from the tree */
 #endif /* MNT_DETACH */
=20
+#ifndef HAVE_SETNS
 static int setns(int fd, int nstype)
 {
 #ifdef __NR_setns
@@ -37,6 +38,7 @@ static int setns(int fd, int nstype)
 	return -1;
 #endif
 }
+#endif /* HAVE_SETNS */
=20
=20
 static int touch(const char *path, mode_t mode)
--=20
1.7.5.1.217.g4e3aa

