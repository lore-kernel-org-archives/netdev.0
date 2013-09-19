From: =?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
Subject: [PATCH] Confirm success for each tc -batch command
Date: Thu, 19 Sep 2013 12:13:42 +0200
Message-ID: <1379585622-1570-1-git-send-email-ppisar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <shemminger@vyatta.com>,
	=?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752348Ab3ISKNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 06:13:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If `tc -force -batch' is fed by a controlling program from a pipe,
it's not possible to recognize when a command has been processes
successfully.

This patch adds an optional `-OK' option to the tc(8) tool, so `tc
-force -OK -batch' will print "OK\n" to standard output on each
successfully completed tc command.

Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
---
 man/man8/tc.8 | 8 +++++++-
 tc/tc.c       | 8 +++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index e0acfeb..583eae2 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -49,7 +49,7 @@ DEV
 DEV
=20
 .P
-.B tc [ -force ] -b\fR[\fIatch\fR] \fB[ filename ]
+.B tc [ -force ] [ -OK ] -b\fR[\fIatch\fR] \fB[ filename ]
=20
 .ti 8
 .IR FORMAT " :=3D {"
@@ -440,6 +440,12 @@ First failure will cause termination of tc.
 don't terminate tc on errors in batch mode.
 If there were any errors during execution of the commands, the applica=
tion return code will be non zero.
=20
+.TP
+.BR "\-OK"
+in batch mode, print
+.B OK
+and a new line on standard output after each successfully interpreted =
command.
+
 .SH HISTORY
 .B tc
 was written by Alexey N. Kuznetsov and added in Linux 2.2.
diff --git a/tc/tc.c b/tc/tc.c
index 9b50e74..b43bb47 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -39,6 +39,7 @@ int batch_mode =3D 0;
 int resolve_hosts =3D 0;
 int use_iec =3D 0;
 int force =3D 0;
+int ok =3D 0;
 struct rtnl_handle rth;
=20
 static void *BODY =3D NULL;	/* cached handle dlopen(NULL) */
@@ -183,7 +184,7 @@ noexist:
 static void usage(void)
 {
 	fprintf(stderr, "Usage: tc [ OPTIONS ] OBJECT { COMMAND | help }\n"
-			"       tc [-force] -batch filename\n"
+			"       tc [-force] [-OK] -batch filename\n"
 	                "where  OBJECT :=3D { qdisc | class | filter | action=
 | monitor }\n"
 	                "       OPTIONS :=3D { -s[tatistics] | -d[etails] | -=
r[aw] | -p[retty] | -b[atch] [filename] }\n");
 }
@@ -251,6 +252,9 @@ static int batch(const char *name)
 			ret =3D 1;
 			if (!force)
 				break;
+		} else if (ok) {
+			printf("OK\n");
+			fflush(stdout);
 		}
 	}
 	if (line)
@@ -288,6 +292,8 @@ int main(int argc, char **argv)
 			return 0;
 		} else if (matches(argv[1], "-force") =3D=3D 0) {
 			++force;
+		} else if (matches(argv[1], "-OK") =3D=3D 0) {
+			++ok;
 		} else 	if (matches(argv[1], "-batch") =3D=3D 0) {
 			argc--;	argv++;
 			if (argc <=3D 1)
--=20
1.8.3.1
