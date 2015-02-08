From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Show stats from specified network namespace
Date: Sun,  8 Feb 2015 08:58:43 +0200
Message-ID: <1423378723-29449-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:65194 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbbBHHJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 02:09:43 -0500
Received: by mail-lb0-f177.google.com with SMTP id p9so24596413lbv.8
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2015 23:09:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added new '-N NSNAME, --net=NSNAME' option to show socket stats
from the specified network namespace name.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ss.8 | 3 +++
 misc/Makefile | 4 ++++
 misc/ss.c     | 9 ++++++++-
 3 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 450649a..b7fbaef 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -84,6 +84,9 @@ context of the creating process, however the context shown will reflect
 any policy role, type and/or range transition rules applied,
 and is therefore a useful reference.
 .TP
+.B \-N NSNAME, \-\-net=NSNAME
+Switch to the specified network namespace name.
+.TP
 .B \-b, \-\-bpf
 Show socket BPF filters (only administrators are allowed to get these information).
 .TP
diff --git a/misc/Makefile b/misc/Makefile
index 004bcc3..b7ecba9 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -10,6 +10,10 @@ ifeq ($(HAVE_SELINUX),y)
 	CFLAGS += $(shell pkg-config --cflags libselinux) -DHAVE_SELINUX
 endif
 
+ifeq ($(IP_CONFIG_SETNS),y)
+	CFLAGS += -DHAVE_SETNS
+endif
+
 all: $(TARGETS)
 
 ss: $(SSOBJ)
diff --git a/misc/ss.c b/misc/ss.c
index 7fc0a99..0a6a65e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -31,6 +31,7 @@
 #include "rt_names.h"
 #include "ll_map.h"
 #include "libnetlink.h"
+#include "namespace.h"
 #include "SNAPSHOT.h"
 
 #include <linux/tcp.h>
@@ -3246,6 +3247,7 @@ static void _usage(FILE *dest)
 "   -b, --bpf           show bpf filter socket information\n"
 "   -Z, --context       display process SELinux security contexts\n"
 "   -z, --contexts      display process and socket SELinux security contexts\n"
+"   -N, --net           switch to the specified network namespace name\n"
 "\n"
 "   -4, --ipv4          display only IP version 4 sockets\n"
 "   -6, --ipv6          display only IP version 6 sockets\n"
@@ -3345,6 +3347,7 @@ static const struct option long_opts[] = {
 	{ "help", 0, 0, 'h' },
 	{ "context", 0, 0, 'Z' },
 	{ "contexts", 0, 0, 'z' },
+	{ "net", 1, 0, 'N' },
 	{ 0 }
 
 };
@@ -3360,7 +3363,7 @@ int main(int argc, char *argv[])
 	struct filter dbs_filter = {};
 	int state_filter = 0;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vVzZ",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vVzZN:",
 				 long_opts, NULL)) != EOF) {
 		switch(ch) {
 		case 'n':
@@ -3532,6 +3535,10 @@ int main(int argc, char *argv[])
 			show_proc_ctx++;
 			user_ent_hash_build();
 			break;
+		case 'N':
+			if (netns_switch(optarg))
+				exit(1);
+			break;
 		case 'h':
 		case '?':
 			help();
-- 
2.2.2
