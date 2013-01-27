From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2] ip/iptunnel: Extend TOS syntax
Date: Sun, 27 Jan 2013 18:04:59 -0500
Message-ID: <1359327899-8153-2-git-send-email-david.ward@ll.mit.edu>
References: <1359327899-8153-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Timo Teras <timo.teras@iki.fi>, David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:50433 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753044Ab3A0Xdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 18:33:36 -0500
In-Reply-To: <1359327899-8153-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'inherit/STRING' or 'inherit/00..ff' syntax indicates that the
TOS field of tunneled packets should be copied from the original IP
header, but for non-IP packets the value STRING or 00..ff should be
used instead. (This syntax is already used by 'ip tunnel show'.)

Also clarify the man page and the command usage text (particularly
that the TOS is not specified as a decimal number).

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 ip/iptunnel.c        |   15 +++++++++++----
 man/man8/ip-tunnel.8 |   34 +++++++++++++++++++++-------------
 2 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 0cf6cf8..f8b91ba 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -41,7 +41,7 @@ static void usage(void)
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
-	fprintf(stderr, "       TOS  := { NUMBER | inherit }\n");
+	fprintf(stderr, "       TOS  := { STRING | 00..ff | inherit | inherit/STRING | inherit/00..ff }\n");
 	fprintf(stderr, "       TTL  := { 1..255 | inherit }\n");
 	fprintf(stderr, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
 	exit(-1);
@@ -188,14 +188,21 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 		} else if (strcmp(*argv, "tos") == 0 ||
 			   strcmp(*argv, "tclass") == 0 ||
 			   matches(*argv, "dsfield") == 0) {
+			char *dsfield;
 			__u32 uval;
 			NEXT_ARG();
+			dsfield = *argv;
+			strsep(&dsfield, "/");
 			if (strcmp(*argv, "inherit") != 0) {
-				if (rtnl_dsfield_a2n(&uval, *argv))
-					invarg("bad TOS value", *argv);
-				p->iph.tos = uval;
+				dsfield = *argv;
+				p->iph.tos = 0;
 			} else
 				p->iph.tos = 1;
+			if (dsfield) {
+				if (rtnl_dsfield_a2n(&uval, dsfield))
+					invarg("bad TOS value", *argv);
+				p->iph.tos |= uval;
+			}
 		} else {
 			if (strcmp(*argv, "name") == 0) {
 				NEXT_ARG();
diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index 37ba542..b408517 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -47,7 +47,6 @@ ip-tunnel - tunnel configuration
 .RB "[ [" no "]" pmtudisc " ]"
 .RB "[ " dev
 .IR PHYS_DEV " ]"
-.RB "[ " "dscp inherit" " ]"
 
 .ti -8
 .IR MODE " := "
@@ -58,8 +57,12 @@ ip-tunnel - tunnel configuration
 .BR any " }"
 
 .ti -8
-.IR TOS " := { " NUMBER " |"
-.BR inherit " }"
+.IR TOS " := { " STRING " | " 00 ".." ff " |"
+.BR inherit " |"
+.BI "inherit/" STRING
+.R " |"
+.BI "inherit/" 00 ".." ff
+.R " }"
 
 .ti -8
 .IR ELIM " := {"
@@ -132,11 +135,21 @@ The default value for IPv6 tunnels is:
 .BI dsfield " T"
 .TP
 .BI tclass " T"
-set a fixed TOS (or traffic class in IPv6)
-.I T
-on tunneled packets.
-The default value is:
-.BR "inherit" .
+set the type of service (IPv4) or traffic class (IPv6) field on
+tunneled packets, which can be specified as either a two-digit
+hex value (e.g. c0) or a predefined string (e.g. internet).
+The value
+.B inherit
+causes the field to be copied from the original IP header. The
+values
+.BI "inherit/" STRING
+or
+.BI "inherit/" 00 ".." ff
+will set the field to
+.I STRING
+or
+.IR 00 ".." ff
+when tunneling non-IP packets. The default value is 00.
 
 .TP
 .BI dev " NAME"
@@ -202,11 +215,6 @@ flag is equivalent to the combination
 .B It isn't work. Don't use it.
 
 .TP
-.BR "dscp inherit"
-.RB ( " only IPv6 tunnels " )
-Inherit DS field between inner and outer header.
-
-.TP
 .BI encaplim " ELIM"
 .RB ( " only IPv6 tunnels " )
 set a fixed encapsulation limit.  Default is 4.
-- 
1.7.1
