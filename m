From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2 2/2] tc class: Ignore if default class name file does not exist
Date: Tue, 17 Mar 2015 22:15:42 +0200
Message-ID: <1426623342-16470-3-git-send-email-vadim4j@gmail.com>
References: <1426623342-16470-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:35183 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbbCQU1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 16:27:31 -0400
Received: by labjg1 with SMTP id jg1so19030065lab.2
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 13:27:29 -0700 (PDT)
In-Reply-To: <1426623342-16470-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

If '-nm' specified that do not fail if there is no
default class names file in /etc/iproute2.

Changed default class name file cls_names -> tc_cls.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 tc/tc_util.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index feae439..1d3153d 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -21,6 +21,7 @@
 #include <arpa/inet.h>
 #include <string.h>
 #include <math.h>
+#include <errno.h>
 
 #include "utils.h"
 #include "names.h"
@@ -33,15 +34,25 @@
 
 static struct db_names *cls_names = NULL;
 
-#define NAMES_DB "/etc/iproute2/cls_names"
+#define NAMES_DB "/etc/iproute2/tc_cls"
 
 int cls_names_init(char *path)
 {
-	cls_names = db_names_alloc(path ?: NAMES_DB);
-	if (!cls_names) {
-		fprintf(stderr, "Error while opening class names file\n");
+	int ret;
+
+	cls_names = db_names_alloc();
+	if (!cls_names)
+		return -1;
+
+	ret = db_names_load(cls_names, path ?: NAMES_DB);
+	if (ret == -ENOENT && path) {
+		fprintf(stderr, "Can't open class names file: %s\n", path);
 		return -1;
 	}
+	if (ret) {
+		db_names_free(cls_names);
+		cls_names = NULL;
+	}
 
 	return 0;
 }
-- 
2.3.1
