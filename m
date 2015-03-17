From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 2/2] tc class: Ignore if default class name file does not exist
Date: Tue, 17 Mar 2015 18:52:04 +0200
Message-ID: <1426611124-2295-3-git-send-email-vadim4j@gmail.com>
References: <1426611124-2295-1-git-send-email-vadim4j@gmail.com>
Cc: daniel@iogearbox.net, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:36829 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932098AbbCQRD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 13:03:57 -0400
Received: by lbcds1 with SMTP id ds1so11821458lbc.3
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 10:03:55 -0700 (PDT)
In-Reply-To: <1426611124-2295-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

If '-nm' specified then do not fail if there is no
default class names file in /etc/iproute2.

Changed default class name file cls_names -> tc_cls.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 tc/tc_util.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index feae439..5213e9e 100644
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
+	int ret = -1;
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
