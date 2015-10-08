From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] bridge: add batch command support
Date: Wed,  7 Oct 2015 22:53:23 -0700
Message-ID: <1444283603-8084-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, wkok@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33204 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbbJHFxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 01:53:34 -0400
Received: by pacex6 with SMTP id ex6so44268165pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 22:53:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

This patch adds support to batch bridge commands.
Follows ip batch code.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/bridge.c   | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/bridge.8 | 11 +++++++++++
 2 files changed, 70 insertions(+)

diff --git a/bridge/bridge.c b/bridge/bridge.c
index eaf09c8..c028f6c 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -9,6 +9,7 @@
 #include <unistd.h>
 #include <sys/socket.h>
 #include <string.h>
+#include <errno.h>
 
 #include "SNAPSHOT.h"
 #include "utils.h"
@@ -23,6 +24,8 @@ int show_stats;
 int show_details;
 int compress_vlans;
 int timestamp;
+char *batch_file;
+int force;
 const char *_SL_;
 
 static void usage(void) __attribute__((noreturn));
@@ -31,6 +34,7 @@ static void usage(void)
 {
 	fprintf(stderr,
 "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
+"	bridge [ -force ] -batch filename\n"
 "where	OBJECT := { link | fdb | mdb | vlan | monitor }\n"
 "	OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] |\n"
 "		     -o[neline] | -t[imestamp] | -n[etns] name |\n"
@@ -71,6 +75,50 @@ static int do_cmd(const char *argv0, int argc, char **argv)
 	return -1;
 }
 
+static int batch(const char *name)
+{
+	char *line = NULL;
+	size_t len = 0;
+	int ret = EXIT_SUCCESS;
+
+	if (name && strcmp(name, "-") != 0) {
+		if (freopen(name, "r", stdin) == NULL) {
+			fprintf(stderr,
+				"Cannot open file \"%s\" for reading: %s\n",
+				name, strerror(errno));
+			return EXIT_FAILURE;
+		}
+	}
+
+	if (rtnl_open(&rth, 0) < 0) {
+		fprintf(stderr, "Cannot open rtnetlink\n");
+		return EXIT_FAILURE;
+	}
+
+	cmdlineno = 0;
+	while (getcmdline(&line, &len, stdin) != -1) {
+		char *largv[100];
+		int largc;
+
+		largc = makeargs(line, largv, 100);
+		if (largc == 0)
+			continue;       /* blank line */
+
+		if (do_cmd(largv[0], largc, largv)) {
+			fprintf(stderr, "Command failed %s:%d\n",
+				name, cmdlineno);
+			ret = EXIT_FAILURE;
+			if (!force)
+				break;
+		}
+	}
+	if (line)
+		free(line);
+
+	rtnl_close(&rth);
+	return ret;
+}
+
 int
 main(int argc, char **argv)
 {
@@ -123,6 +171,14 @@ main(int argc, char **argv)
 				exit(-1);
 		} else if (matches(opt, "-compressvlans") == 0) {
 			++compress_vlans;
+		} else if (matches(opt, "-force") == 0) {
+			++force;
+		} else if (matches(opt, "-batch") == 0) {
+			argc--;
+			argv++;
+			if (argc <= 1)
+				usage();
+			batch_file = argv[1];
 		} else {
 			fprintf(stderr,
 				"Option \"%s\" is unknown, try \"bridge help\".\n",
@@ -134,6 +190,9 @@ main(int argc, char **argv)
 
 	_SL_ = oneline ? "\\" : "\n";
 
+	if (batch_file)
+		return batch(batch_file);
+
 	if (rtnl_open(&rth, 0) < 0)
 		exit(1);
 
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 5347a56..d45c728 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -21,6 +21,7 @@ bridge \- show / manipulate bridge addresses and devices
 \fB\-V\fR[\fIersion\fR] |
 \fB\-s\fR[\fItatistics\fR] |
 \fB\-n\fR[\fIetns\fR] name }
+\fB\-b\fR[\fIatch\fR] filename }
 
 .ti -8
 .BR "bridge link set"
@@ -137,6 +138,16 @@ to
 .RI "-n[etns] " NETNS " [ " OPTIONS " ] " OBJECT " { " COMMAND " | "
 .BR help " }"
 
+.TP
+.BR "\-b", " \-batch " <FILENAME>
+Read commands from provided file or standard input and invoke them.
+First failure will cause termination of bridge command.
+
+.TP
+.BR "\-force"
+Don't terminate bridge command on errors in batch mode.
+If there were any errors during execution of the commands, the application
+return code will be non zero.
 
 .SH BRIDGE - COMMAND SYNTAX
 
-- 
1.9.1
