From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 2/2] lib names: Add helper func for parse id and name from file
Date: Sat,  6 Dec 2014 04:05:12 +0200
Message-ID: <1417831512-19452-3-git-send-email-vadim4j@gmail.com>
References: <1417831512-19452-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:51079 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbaLFCPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 21:15:02 -0500
Received: by mail-la0-f48.google.com with SMTP id gf13so1590233lab.21
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 18:15:01 -0800 (PST)
In-Reply-To: <1417831512-19452-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 lib/rt_names.c | 68 +++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 39 insertions(+), 29 deletions(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index e6a1e01..2f14723 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -27,43 +27,62 @@
 #define CONFDIR "/etc/iproute2"
 #endif
 
+#define NAME_MAX_LEN 512
+
 struct rtnl_hash_entry {
 	struct rtnl_hash_entry *next;
 	const char *		name;
 	unsigned int		id;
 };
 
+static int fread_id_name(FILE *fp, int *id, char *namebuf)
+{
+	char buf[NAME_MAX_LEN];
+	while (fgets(buf, sizeof(buf), fp)) {
+		char *p = buf;
+
+		while (*p == ' ' || *p == '\t')
+			p++;
+
+		if (*p == '#' || *p == '\n' || *p == 0)
+			continue;
+
+		if (sscanf(p, "0x%x %s\n", id, namebuf) != 2 &&
+				sscanf(p, "0x%x %s #", id, namebuf) != 2 &&
+				sscanf(p, "%d %s\n", id, namebuf) != 2 &&
+				sscanf(p, "%d %s #", id, namebuf) != 2) {
+			strcpy(namebuf, p);
+			return -1;
+		}
+		return 1;
+	}
+	return 0;
+}
+
 static void
 rtnl_hash_initialize(const char *file, struct rtnl_hash_entry **hash, int size)
 {
 	struct rtnl_hash_entry *entry;
-	char buf[512];
 	FILE *fp;
+	int id;
+	char namebuf[NAME_MAX_LEN] = {0};
+	int ret;
 
 	fp = fopen(file, "r");
 	if (!fp)
 		return;
-	while (fgets(buf, sizeof(buf), fp)) {
-		char *p = buf;
-		int id;
-		char namebuf[512];
 
-		while (*p == ' ' || *p == '\t')
-			p++;
-		if (*p == '#' || *p == '\n' || *p == 0)
-			continue;
-		if (sscanf(p, "0x%x %s\n", &id, namebuf) != 2 &&
-		    sscanf(p, "0x%x %s #", &id, namebuf) != 2 &&
-		    sscanf(p, "%d %s\n", &id, namebuf) != 2 &&
-		    sscanf(p, "%d %s #", &id, namebuf) != 2) {
+	while ((ret = fread_id_name(fp, &id, &namebuf[0]))) {
+		if (ret == -1) {
 			fprintf(stderr, "Database %s is corrupted at %s\n",
-				file, p);
+					file, namebuf);
 			fclose(fp);
 			return;
 		}
 
 		if (id<0)
 			continue;
+
 		entry = malloc(sizeof(*entry));
 		entry->id   = id;
 		entry->name = strdup(namebuf);
@@ -75,31 +94,22 @@ rtnl_hash_initialize(const char *file, struct rtnl_hash_entry **hash, int size)
 
 static void rtnl_tab_initialize(const char *file, char **tab, int size)
 {
-	char buf[512];
 	FILE *fp;
+	int id;
+	char namebuf[NAME_MAX_LEN] = {0};
+	int ret;
 
 	fp = fopen(file, "r");
 	if (!fp)
 		return;
-	while (fgets(buf, sizeof(buf), fp)) {
-		char *p = buf;
-		int id;
-		char namebuf[512];
 
-		while (*p == ' ' || *p == '\t')
-			p++;
-		if (*p == '#' || *p == '\n' || *p == 0)
-			continue;
-		if (sscanf(p, "0x%x %s\n", &id, namebuf) != 2 &&
-		    sscanf(p, "0x%x %s #", &id, namebuf) != 2 &&
-		    sscanf(p, "%d %s\n", &id, namebuf) != 2 &&
-		    sscanf(p, "%d %s #", &id, namebuf) != 2) {
+	while ((ret = fread_id_name(fp, &id, &namebuf[0]))) {
+		if (ret == -1) {
 			fprintf(stderr, "Database %s is corrupted at %s\n",
-				file, p);
+					file, namebuf);
 			fclose(fp);
 			return;
 		}
-
 		if (id<0 || id>size)
 			continue;
 
-- 
2.1.3
