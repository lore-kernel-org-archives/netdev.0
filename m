From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 4/4] tc: Allow to easy change network namespace
Date: Sat, 13 Dec 2014 19:55:34 +0200
Message-ID: <1418493334-23142-5-git-send-email-vadim4j@gmail.com>
References: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:33324 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbaLMSFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2014 13:05:37 -0500
Received: by mail-lb0-f180.google.com with SMTP id l4so7268811lbv.39
        for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 10:05:35 -0800 (PST)
In-Reply-To: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added new '-netns' option to simplify executing following cmd:

    ip netns exec NETNS tc OPTIONS COMMAND OBJECT

    to

    tc -n[etns] NETNS OPTIONS COMMAND OBJECT

e.g.:

    tc -net vnet0 qdisc

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/tc.8 | 65 +++++++++++++++++++++++++++++++++++++++++++++--------------
 tc/Makefile   |  5 +++++
 tc/tc.c       |  8 +++++++-
 3 files changed, 62 insertions(+), 16 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 8d794de..d8f974f 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -2,7 +2,9 @@
 .SH NAME
 tc \- show / manipulate traffic control settings
 .SH SYNOPSIS
-.B tc qdisc [ add | change | replace | link | delete ] dev
+.B tc
+.RI "[ " OPTIONS " ]"
+.B qdisc [ add | change | replace | link | delete ] dev
 DEV
 .B
 [ parent
@@ -13,7 +15,9 @@ qdisc-id ] qdisc
 [ qdisc specific parameters ]
 .P
 
-.B tc class [ add | change | replace | delete ] dev
+.B tc
+.RI "[ " OPTIONS " ]"
+.B class [ add | change | replace | delete ] dev
 DEV
 .B parent
 qdisc-id
@@ -22,7 +26,9 @@ class-id ] qdisc
 [ qdisc specific parameters ]
 .P
 
-.B tc filter [ add | change | replace | delete ] dev
+.B tc
+.RI "[ " OPTIONS " ]"
+.B filter [ add | change | replace | delete ] dev
 DEV
 .B [ parent
 qdisc-id
@@ -35,21 +41,28 @@ priority filtertype
 flow-id
 
 .B tc
+.RI "[ " OPTIONS " ]"
 .RI "[ " FORMAT " ]"
 .B qdisc show [ dev
 DEV
 .B ]
 .P
 .B tc
+.RI "[ " OPTIONS " ]"
 .RI "[ " FORMAT " ]"
 .B class show dev
 DEV
 .P
-.B tc filter show dev
+.B tc
+.RI "[ " OPTIONS " ]"
+.B filter show dev
 DEV
 
 .P
-.B tc [ -force ] -b\fR[\fIatch\fR] \fB[ filename ]
+.ti 8
+.IR OPTIONS " := {"
+\fB[ -force ] -b\fR[\fIatch\fR] \fB[ filename ] \fR|
+\fB[ \fB-n\fR[\fIetns\fR] name \fB] \fR}
 
 .ti 8
 .IR FORMAT " := {"
@@ -407,6 +420,38 @@ link
 Only available for qdiscs and performs a replace where the node
 must exist already.
 
+.SH OPTIONS
+
+.TP
+.BR "\-b", " \-b filename", " \-batch", " \-batch filename"
+read commands from provided file or standard input and invoke them.
+First failure will cause termination of tc.
+
+.TP
+.BR "\-force"
+don't terminate tc on errors in batch mode.
+If there were any errors during execution of the commands, the application return code will be non zero.
+
+.TP
+.BR "\-n" , " \-net" , " \-netns " <NETNS>
+switches
+.B tc
+to the specified network namespace
+.IR NETNS .
+Actually it just simplifies executing of:
+
+.B ip netns exec
+.IR NETNS
+.B tc
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
+to
+
+.B tc
+.RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
 .SH FORMAT
 The show command has additional formatting options:
 
@@ -430,16 +475,6 @@ decode filter offset and mask values to equivalent filter commands based on TCP/
 .BR "\-iec"
 print rates in IEC units (ie. 1K = 1024).
 
-.TP
-.BR "\-b", " \-b filename", " \-batch", " \-batch filename"
-read commands from provided file or standard input and invoke them.
-First failure will cause termination of tc.
-
-.TP
-.BR "\-force"
-don't terminate tc on errors in batch mode.
-If there were any errors during execution of the commands, the application return code will be non zero.
-
 .SH HISTORY
 .B tc
 was written by Alexey N. Kuznetsov and added in Linux 2.2.
diff --git a/tc/Makefile b/tc/Makefile
index 1ab36c6..536ed88 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -3,6 +3,11 @@ TCOBJ= tc.o tc_qdisc.o tc_class.o tc_filter.o tc_util.o \
        m_ematch.o emp_ematch.yacc.o emp_ematch.lex.o
 
 include ../Config
+
+ifeq ($(IP_CONFIG_SETNS),y)
+	CFLAGS += -DHAVE_SETNS
+endif
+
 SHARED_LIBS ?= y
 
 TCMODULES :=
diff --git a/tc/tc.c b/tc/tc.c
index 9b50e74..ea4ba10 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -29,6 +29,7 @@
 #include "utils.h"
 #include "tc_util.h"
 #include "tc_common.h"
+#include "namespace.h"
 
 int show_stats = 0;
 int show_details = 0;
@@ -185,7 +186,8 @@ static void usage(void)
 	fprintf(stderr, "Usage: tc [ OPTIONS ] OBJECT { COMMAND | help }\n"
 			"       tc [-force] -batch filename\n"
 	                "where  OBJECT := { qdisc | class | filter | action | monitor }\n"
-	                "       OPTIONS := { -s[tatistics] | -d[etails] | -r[aw] | -p[retty] | -b[atch] [filename] }\n");
+	                "       OPTIONS := { -s[tatistics] | -d[etails] | -r[aw] | -p[retty] | -b[atch] [filename] | "
+			"-n[etns] name }\n");
 }
 
 static int do_cmd(int argc, char **argv)
@@ -293,6 +295,10 @@ int main(int argc, char **argv)
 			if (argc <= 1)
 				usage();
 			batch_file = argv[1];
+		} else if (matches(argv[1], "-netns") == 0) {
+			NEXT_ARG();
+			if (netns_switch(argv[1]))
+				return -1;
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"tc -help\".\n", argv[1]);
 			return -1;
-- 
2.1.3
