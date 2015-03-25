From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v4] tc class: Ignore if default class name file does not exist
Date: Wed, 25 Mar 2015 05:14:37 +0200
Message-ID: <1427253277-7250-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34124 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbbCYD0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 23:26:31 -0400
Received: by lbbsy1 with SMTP id sy1so8466856lbb.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 20:26:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

If '-nm' specified that do not fail if there is no
default class names file in /etc/iproute2.

Changed default class name file cls_names -> tc_cls.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/names.h |  3 ++-
 lib/names.c     | 59 +++++++++++++++++++++++++++++++++++++++++----------------
 tc/tc_util.c    | 19 +++++++++++++++----
 3 files changed, 60 insertions(+), 21 deletions(-)

diff --git a/include/names.h b/include/names.h
index 4123d0b..6fed581 100644
--- a/include/names.h
+++ b/include/names.h
@@ -16,7 +16,8 @@ struct db_names {
 	int max;
 };
 
-struct db_names *db_names_alloc(const char *path);
+struct db_names *db_names_alloc(void);
+int db_names_load(struct db_names *db, const char *path);
 void db_names_free(struct db_names *db);
 
 char *id_to_name(struct db_names *db, int id, char *name);
diff --git a/lib/names.c b/lib/names.c
index 93933f7..3b5b0b1 100644
--- a/lib/names.c
+++ b/lib/names.c
@@ -11,8 +11,10 @@
 #include <stdio.h>
 #include <string.h>
 #include <stdlib.h>
+#include <errno.h>
 
 #include "names.h"
+#include "utils.h"
 
 #define MAX_ENTRIES  256
 #define NAME_MAX_LEN 512
@@ -48,48 +50,65 @@ static int read_id_name(FILE *fp, int *id, char *name)
 	return 0;
 }
 
-struct db_names *db_names_alloc(const char *path)
+struct db_names *db_names_alloc(void)
 {
 	struct db_names *db;
-	struct db_entry *entry;
-	FILE *fp;
-	int id;
-	char namebuf[NAME_MAX_LEN] = {0};
-	int ret;
 
-	fp = fopen(path, "r");
-	if (!fp) {
-		fprintf(stderr, "Can't open file: %s\n", path);
+	db = malloc(sizeof(*db));
+	if (!db)
 		return NULL;
-	}
 
-	db = malloc(sizeof(*db));
 	memset(db, 0, sizeof(*db));
 
 	db->size = MAX_ENTRIES;
 	db->hash = malloc(sizeof(struct db_entry *) * db->size);
 	memset(db->hash, 0, sizeof(struct db_entry *) * db->size);
 
+	return db;
+}
+
+int db_names_load(struct db_names *db, const char *path)
+{
+	struct db_entry *entry;
+	FILE *fp;
+	int id;
+	char namebuf[NAME_MAX_LEN] = {0};
+	int ret = -1;
+
+	fp = fopen(path, "r");
+	if (!fp)
+		return -ENOENT;
+
 	while ((ret = read_id_name(fp, &id, &namebuf[0]))) {
 		if (ret == -1) {
 			fprintf(stderr, "Database %s is corrupted at %s\n",
 					path, namebuf);
-			fclose(fp);
-			return NULL;
+			goto Exit;
 		}
+		ret = -1;
 
 		if (id < 0)
 			continue;
 
 		entry = malloc(sizeof(*entry));
-		entry->id   = id;
+		if (!entry)
+			goto Exit;
+
 		entry->name = strdup(namebuf);
+		if (!entry->name) {
+			free(entry);
+			goto Exit;
+		}
+
+		entry->id   = id;
 		entry->next = db->hash[id & (db->size - 1)];
 		db->hash[id & (db->size - 1)] = entry;
 	}
+	ret = 0;
 
+Exit:
 	fclose(fp);
-	return db;
+	return ret;
 }
 
 void db_names_free(struct db_names *db)
@@ -117,8 +136,12 @@ void db_names_free(struct db_names *db)
 
 char *id_to_name(struct db_names *db, int id, char *name)
 {
-	struct db_entry *entry = db->hash[id & (db->size - 1)];
+	struct db_entry *entry;
+
+	if (!db)
+		return NULL;
 
+	entry = db->hash[id & (db->size - 1)];
 	while (entry && entry->id != id)
 		entry = entry->next;
 
@@ -136,6 +159,9 @@ int name_to_id(struct db_names *db, int *id, const char *name)
 	struct db_entry *entry;
 	int i;
 
+	if (!db)
+		return -1;
+
 	if (db->cached && strcmp(db->cached->name, name) == 0) {
 		*id = db->cached->id;
 		return 0;
@@ -145,6 +171,7 @@ int name_to_id(struct db_names *db, int *id, const char *name)
 		entry = db->hash[i];
 		while (entry && strcmp(entry->name, name))
 			entry = entry->next;
+
 		if (entry) {
 			db->cached = entry;
 			*id = entry->id;
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
