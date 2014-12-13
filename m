From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 3/4] bridge: Allow to easy change network namespace
Date: Sat, 13 Dec 2014 19:55:33 +0200
Message-ID: <1418493334-23142-4-git-send-email-vadim4j@gmail.com>
References: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:55896 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbaLMSFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2014 13:05:35 -0500
Received: by mail-la0-f53.google.com with SMTP id gm9so7434846lab.40
        for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 10:05:33 -0800 (PST)
In-Reply-To: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added new '-netns' option to simplify executing following cmd:

    ip netns exec NETNS bridge OPTIONS COMMAND OBJECT

    to

    bridge -n[etns] NETNS OPTIONS COMMAND OBJECT

e.g.:

    bridge -net vnet0 fdb

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 bridge/Makefile   |  4 ++++
 bridge/bridge.c   |  7 ++++++-
 man/man8/bridge.8 | 23 ++++++++++++++++++++++-
 3 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/bridge/Makefile b/bridge/Makefile
index 1fb8320..9800753 100644
--- a/bridge/Makefile
+++ b/bridge/Makefile
@@ -2,6 +2,10 @@ BROBJ = bridge.o fdb.o monitor.o link.o mdb.o vlan.o
 
 include ../Config
 
+ifeq ($(IP_CONFIG_SETNS),y)
+	CFLAGS += -DHAVE_SETNS
+endif
+
 all: bridge
 
 bridge: $(BROBJ) $(LIBNETLINK) 
diff --git a/bridge/bridge.c b/bridge/bridge.c
index ee08f90..5fcc552 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -13,6 +13,7 @@
 #include "SNAPSHOT.h"
 #include "utils.h"
 #include "br_common.h"
+#include "namespace.h"
 
 struct rtnl_handle rth = { .fd = -1 };
 int preferred_family = AF_UNSPEC;
@@ -31,7 +32,7 @@ static void usage(void)
 "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "where  OBJECT := { link | fdb | mdb | vlan | monitor }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] |\n"
-"                    -o[neline] | -t[imestamp] \n");
+"                    -o[neline] | -t[imestamp] | -n[etns] name }\n");
 	exit(-1);
 }
 
@@ -112,6 +113,10 @@ main(int argc, char **argv)
 			preferred_family = AF_INET;
 		} else if (strcmp(opt, "-6") == 0) {
 			preferred_family = AF_INET6;
+		} else if (matches(opt, "-netns") == 0) {
+			NEXT_ARG();
+			if (netns_switch(argv[1]))
+				exit(-1);
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"bridge help\".\n", opt);
 			exit(-1);
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index af31d41..cb3fb46 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -19,7 +19,8 @@ bridge \- show / manipulate bridge addresses and devices
 .ti -8
 .IR OPTIONS " := { "
 \fB\-V\fR[\fIersion\fR] |
-\fB\-s\fR[\fItatistics\fR] }
+\fB\-s\fR[\fItatistics\fR] |
+\fB\-n\fR[\fIetns\fR] name }
 
 .ti -8
 .BR "bridge link set"
@@ -112,6 +113,26 @@ output more information.  If this option
 is given multiple times, the amount of information increases.
 As a rule, the information is statistics or some time values.
 
+.TP
+.BR "\-n" , " \-net" , " \-netns " <NETNS>
+switches
+.B bridge
+to the specified network namespace
+.IR NETNS .
+Actually it just simplifies executing of:
+
+.B ip netns exec
+.IR NETNS
+.B bridge
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
+to
+
+.B bridge
+.RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
 
 .SH BRIDGE - COMMAND SYNTAX
 
-- 
2.1.3
