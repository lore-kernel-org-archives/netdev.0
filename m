From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH 3/3] macsec: cipher and icvlen can be set separately
Date: Tue, 26 Jul 2016 11:03:20 +0200
Message-ID: <fbb38ddebb8b80dee3ac3fb6fd8ceecd03d4ff9c.1469520298.git.dcaratti@redhat.com>
References: <cover.1469520298.git.dcaratti@redhat.com>
Cc: Phil Sutter <phil@nwl.cc>, Sabrina Dubroca <sd@queasysnail.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755064AbcGZJEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 05:04:33 -0400
In-Reply-To: <cover.1469520298.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since kernel driver has valid default values for 'cipher' and 'icvlen',
there is no need for requiring users to specify both of them when a new
link is added. Also, prompt an error message and exit with appropriate
exit status in case of unsupported cipher suite.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 ip/ipmacsec.c         | 52 +++++++++++++++++----------------------------------
 man/man8/ip-link.8.in |  6 ++++++
 man/man8/ip-macsec.8  |  4 ++--
 3 files changed, 25 insertions(+), 37 deletions(-)

diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index 34ba341..329be00 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -1071,34 +1071,6 @@ static void macsec_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	}
 }
 
-
-static int do_cipher_suite(struct cipher_args *cipher, int *argcp,
-			   char ***argvp)
-{
-	char **argv = *argvp;
-	int argc = *argcp;
-
-	if (argc == 0)
-		return -1;
-
-	if (strcmp(*argv, "default") == 0 ||
-	    strcmp(*argv, "gcm-aes-128") == 0 ||
-	    strcmp(*argv, "GCM-AES-128") == 0)
-		cipher->id = MACSEC_DEFAULT_CIPHER_ID;
-	NEXT_ARG();
-
-	if (strcmp(*argv, "icvlen") == 0) {
-		NEXT_ARG();
-		if (cipher->icv_len != 0)
-			duparg2("icvlen", "icvlen");
-		get_icvlen(&cipher->icv_len, *argv);
-	}
-	*argcp = argc;
-	*argvp = argv;
-
-	return 0;
-}
-
 static bool check_txsc_flags(bool es, bool scb, bool sci)
 {
 	if (sci && (es || scb))
@@ -1112,7 +1084,8 @@ static void usage(FILE *f)
 {
 	fprintf(f,
 		"Usage: ... macsec [ port PORT | sci SCI ]\n"
-		"                  [ cipher CIPHER_SUITE ]\n"
+		"                  [ cipher { default | gcm-aes-128 } ]\n"
+		"                  [ icvlen { 8..16 } ]\n"
 		"                  [ encrypt { on | off } ]\n"
 		"                  [ send_sci { on | off } ]\n"
 		"                  [ end_station { on | off } ]\n"
@@ -1122,7 +1095,6 @@ static void usage(FILE *f)
 		"                  [ validate { strict | check | disabled } ]\n"
 		"                  [ encodingsa { 0..3 } ]\n"
 		);
-	fprintf(f, "CIPHER_SUITE := [ default = gcm-aes-128 ] icvlen { 8..32 }\n");
 }
 
 static int macsec_parse_opt(struct link_util *lu, int argc, char **argv,
@@ -1154,11 +1126,21 @@ static int macsec_parse_opt(struct link_util *lu, int argc, char **argv,
 
 	while (argc > 0) {
 		if (strcmp(*argv, "cipher") == 0) {
+			NEXT_ARG();
 			if (cipher.id)
-				duparg2("cipher", "cipher");
+				duparg("cipher", *argv);
+			if (strcmp(*argv, "default") == 0 ||
+			    strcmp(*argv, "gcm-aes-128") == 0 ||
+			    strcmp(*argv, "GCM-AES-128") == 0)
+				cipher.id = MACSEC_DEFAULT_CIPHER_ID;
+			else
+				invarg("expected: default or gcm-aes-128",
+				       *argv);
+		} else if (strcmp(*argv, "icvlen") == 0) {
 			NEXT_ARG();
-			if (do_cipher_suite(&cipher, &argc, &argv))
-				return -1;
+			if (cipher.icv_len)
+				duparg("icvlen", *argv);
+			get_icvlen(&cipher.icv_len, *argv);
 		} else if (strcmp(*argv, "encrypt") == 0) {
 			NEXT_ARG();
 			int i;
@@ -1264,12 +1246,12 @@ static int macsec_parse_opt(struct link_util *lu, int argc, char **argv,
 		return -1;
 	}
 
-	if (cipher.id) {
+	if (cipher.id)
 		addattr_l(hdr, MACSEC_BUFLEN, IFLA_MACSEC_CIPHER_SUITE,
 			  &cipher.id, sizeof(cipher.id));
+	if (cipher.icv_len)
 		addattr_l(hdr, MACSEC_BUFLEN, IFLA_MACSEC_ICV_LEN,
 			  &cipher.icv_len, sizeof(cipher.icv_len));
-	}
 
 	if (replay_protect != -1) {
 		addattr32(hdr, MACSEC_BUFLEN, IFLA_MACSEC_WINDOW, window);
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ad49c9d..f4782ee 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -923,6 +923,8 @@ the following additional arguments are supported:
 ] [
 .BI cipher " CIPHER_SUITE"
 ] [
+.BR icvlen " { "
+.IR 8..16 " } ] ["
 .BR encrypt " {"
 .BR on " | " off " } ] [ "
 .BR send_sci " { " on " | " off " } ] ["
@@ -950,6 +952,10 @@ the following additional arguments are supported:
 - defines the cipher suite to use.
 
 .sp
+.BI icvlen " LENGTH "
+- sets the length of the Integrity Check Value (ICV).
+
+.sp
 .BR "encrypt on " or " encrypt off"
 - switches between authenticated encryption, or authenticity mode only.
 
diff --git a/man/man8/ip-macsec.8 b/man/man8/ip-macsec.8
index f928c43..105aeec 100644
--- a/man/man8/ip-macsec.8
+++ b/man/man8/ip-macsec.8
@@ -7,8 +7,8 @@ ip-macsec \- MACsec device configuration
 .BI port " PORT"
 |
 .BI sci  " SCI"
-] [ [
-.BR cipher " { " default " | " gcm-aes-128 " } ] "
+] [
+.BR cipher " { " default " | " gcm-aes-128 " } ] ["
 .BI icvlen " ICVLEN"
 ] [
 .BR encrypt " { " on " | " off " } ] ["
-- 
2.5.5
