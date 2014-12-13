From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 2/4] ip: Allow to easy change network namespace
Date: Sat, 13 Dec 2014 19:55:32 +0200
Message-ID: <1418493334-23142-3-git-send-email-vadim4j@gmail.com>
References: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34174 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145AbaLMSFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2014 13:05:35 -0500
Received: by mail-lb0-f174.google.com with SMTP id 10so7356897lbg.19
        for <netdev@vger.kernel.org>; Sat, 13 Dec 2014 10:05:32 -0800 (PST)
In-Reply-To: <1418493334-23142-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added new '-netns' option to simplify executing following cmd:

    ip netns exec NETNS ip OPTIONS COMMAND OBJECT

    to

    ip -n[etns] NETNS OPTIONS COMMAND OBJECT

e.g.:

    ip -net vnet0 link add br0 type bridge
    ip -n vnet0 link

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ip.c       |  7 ++++++-
 man/man8/ip.8 | 23 ++++++++++++++++++++++-
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/ip/ip.c b/ip/ip.c
index 5f759d5..96e64a3 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -22,6 +22,7 @@
 #include "SNAPSHOT.h"
 #include "utils.h"
 #include "ip_common.h"
+#include "namespace.h"
 
 int preferred_family = AF_UNSPEC;
 int human_readable = 0;
@@ -54,7 +55,7 @@ static void usage(void)
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
 "                    -o[neline] | -t[imestamp] | -b[atch] [filename] |\n"
-"                    -rc[vbuf] [size]}\n");
+"                    -rc[vbuf] [size] | -n[etns] name }\n");
 	exit(-1);
 }
 
@@ -262,6 +263,10 @@ int main(int argc, char **argv)
 			rcvbuf = size;
 		} else if (matches(opt, "-help") == 0) {
 			usage();
+		} else if (matches(opt, "-netns") == 0) {
+			NEXT_ARG();
+			if (netns_switch(argv[1]))
+				exit(-1);
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"ip -help\".\n", opt);
 			exit(-1);
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 2d42e98..0bae59e 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -31,7 +31,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 \fB\-r\fR[\fIesolve\fR] |
 \fB\-f\fR[\fIamily\fR] {
 .BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
-\fB\-o\fR[\fIneline\fR] }
+\fB\-o\fR[\fIneline\fR] |
+\fB\-n\fR[\fIetns\fR] name }
 
 
 .SH OPTIONS
@@ -134,6 +135,26 @@ the output.
 use the system's name resolver to print DNS names instead of
 host addresses.
 
+.TP
+.BR "\-n" , " \-net" , " \-netns " <NETNS>
+switches
+.B ip
+to the specified network namespace
+.IR NETNS .
+Actually it just simplifies executing of:
+
+.B ip netns exec
+.IR NETNS
+.B ip
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
+to
+
+.B ip
+.RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+
 .SH IP - COMMAND SYNTAX
 
 .SS
-- 
2.1.3
