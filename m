From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 1/2] tc, ingress: clean up ingress handling a bit
Date: Tue, 12 Jan 2016 01:42:19 +0100
Message-ID: <04a0a8e8ba21a775c17218340bec7dae4becf968.1452558352.git.daniel@iogearbox.net>
References: <cover.1452558352.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59858 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761421AbcALAmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 19:42:23 -0500
In-Reply-To: <cover.1452558352.git.daniel@iogearbox.net>
In-Reply-To: <cover.1452558352.git.daniel@iogearbox.net>
References: <cover.1452558352.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean it up a bit, we can also get rid of some ugly ifdefs as in our case
TC_H_INGRESS is always defined.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/q_ingress.c | 20 +++++---------------
 tc/tc_qdisc.c  | 11 +++--------
 2 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/tc/q_ingress.c b/tc/q_ingress.c
index 30b24e7..c3c9b40 100644
--- a/tc/q_ingress.c
+++ b/tc/q_ingress.c
@@ -1,5 +1,4 @@
 /*
- *
  * q_ingress.c             INGRESS.
  *
  *              This program is free software; you can redistribute it and/or
@@ -8,20 +7,9 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Authors:    J Hadi Salim
- *
- * This is here just in case it is needed
- * useless right now; might be useful in the future
- *
  */
 
 #include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <syslog.h>
-#include <fcntl.h>
-#include <sys/socket.h>
-#include <netinet/in.h>
-#include <arpa/inet.h>
 #include <string.h>
 
 #include "utils.h"
@@ -29,10 +17,11 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... ingress \n");
+	fprintf(stderr, "Usage: ... ingress\n");
 }
 
-static int ingress_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
+static int ingress_parse_opt(struct qdisc_util *qu, int argc, char **argv,
+			     struct nlmsghdr *n)
 {
 	while (argc > 0) {
 		if (strcmp(*argv, "handle") == 0) {
@@ -49,7 +38,8 @@ static int ingress_parse_opt(struct qdisc_util *qu, int argc, char **argv, struc
 	return 0;
 }
 
-static int ingress_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
+static int ingress_print_opt(struct qdisc_util *qu, FILE *f,
+			     struct rtattr *opt)
 {
 	fprintf(f, "---------------- ");
 	return 0;
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index c31ae8d..96b8085 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -91,20 +91,17 @@ static int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 				return -1;
 			}
 			req.t.tcm_parent = TC_H_ROOT;
-#ifdef TC_H_INGRESS
 		} else if (strcmp(*argv, "ingress") == 0) {
 			if (req.t.tcm_parent) {
 				fprintf(stderr, "Error: \"ingress\" is a duplicate parent ID\n");
 				return -1;
 			}
 			req.t.tcm_parent = TC_H_INGRESS;
-			strncpy(k, "ingress", sizeof(k)-1);
+			strncpy(k, "ingress", sizeof(k) - 1);
 			q = get_qdisc_kind(k);
-			req.t.tcm_handle = 0xffff0000;
-
-			argc--; argv++;
+			req.t.tcm_handle = TC_H_MAKE(TC_H_INGRESS, 0);
+			NEXT_ARG_FWD();
 			break;
-#endif
 		} else if (strcmp(*argv, "parent") == 0) {
 			__u32 handle;
 			NEXT_ARG();
@@ -291,14 +288,12 @@ static int tc_qdisc_list(int argc, char **argv)
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
 			strncpy(d, *argv, sizeof(d)-1);
-#ifdef TC_H_INGRESS
                 } else if (strcmp(*argv, "ingress") == 0) {
                              if (t.tcm_parent) {
                                      fprintf(stderr, "Duplicate parent ID\n");
                                      usage();
                              }
                              t.tcm_parent = TC_H_INGRESS;
-#endif
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
-- 
1.9.3
