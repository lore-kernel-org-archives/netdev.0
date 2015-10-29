From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] Confirm success for each tc -batch command
Date: Thu, 29 Oct 2015 13:09:56 +0100
Message-ID: <1446120596-10399-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:50346 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbbJ2MJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 08:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If `tc -force -batch' is fed by a controlling program from a pipe,
it's not possible to recognize when a command has been processes
successfully.

This patch adds an optional `-OK' option to the tc(8) tool, so `tc
-force -OK -batch' will print "OK\n" to standard output on each
successfully completed tc command.

Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc.8 | 8 +++++++-
 tc/tc.c       | 8 +++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 700b960..4c5c079 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -61,7 +61,7 @@ DEV
 .P
 .ti 8
 .IR OPTIONS " :=3D {"
-\fB[ -force ] -b\fR[\fIatch\fR] \fB[ filename ] \fR|
+\fB[ -force ] [ -OK ] -b\fR[\fIatch\fR] \fB[ filename ] \fR|
 \fB[ \fB-n\fR[\fIetns\fR] name \fB] \fR|
 \fB[ \fB-nm \fR| \fB-nam\fR[\fIes\fR] \fB] \fR|
 \fB[ \fR{ \fB-cf \fR| \fB-c\fR[\fIonf\fR] \fR} \fB[ filename ] \fB] \f=
R}
@@ -588,6 +588,12 @@ don't terminate tc on errors in batch mode.
 If there were any errors during execution of the commands, the applica=
tion return code will be non zero.
=20
 .TP
+.BR "\-OK"
+in batch mode, print
+.B OK
+and a new line on standard output after each successfully interpreted =
command.
+
+.TP
 .BR "\-n" , " \-net" , " \-netns " <NETNS>
 switches
 .B tc
diff --git a/tc/tc.c b/tc/tc.c
index 1707867..2918da0 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -43,6 +43,7 @@ int resolve_hosts =3D 0;
 int use_iec =3D 0;
 int force =3D 0;
 bool use_names =3D false;
+int ok =3D 0;
=20
 static char *conf_file;
=20
@@ -190,7 +191,7 @@ noexist:
 static void usage(void)
 {
 	fprintf(stderr, "Usage: tc [ OPTIONS ] OBJECT { COMMAND | help }\n"
-			"       tc [-force] -batch filename\n"
+			"       tc [-force] [-OK] -batch filename\n"
 	                "where  OBJECT :=3D { qdisc | class | filter | action=
 | monitor | exec }\n"
 	                "       OPTIONS :=3D { -s[tatistics] | -d[etails] | -=
r[aw] | -p[retty] | -b[atch] [filename] | "
 			"-n[etns] name |\n"
@@ -257,6 +258,9 @@ static int batch(const char *name)
 			ret =3D 1;
 			if (!force)
 				break;
+		} else if (ok) {
+			printf("OK\n");
+			fflush(stdout);
 		}
 	}
 	if (line)
@@ -296,6 +300,8 @@ int main(int argc, char **argv)
 			return 0;
 		} else if (matches(argv[1], "-force") =3D=3D 0) {
 			++force;
+		} else if (matches(argv[1], "-OK") =3D=3D 0) {
+			++ok;
 		} else if (matches(argv[1], "-batch") =3D=3D 0) {
 			argc--;	argv++;
 			if (argc <=3D 1)
--=20
2.1.2
