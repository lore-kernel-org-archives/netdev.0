From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tc class: Don't fail if there is no default names file
Date: Tue, 17 Mar 2015 15:41:06 +0200
Message-ID: <1426599666-8968-1-git-send-email-vadim4j@gmail.com>
Cc: daniel@iogearbox.net, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:33501 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbbCQNwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 09:52:50 -0400
Received: by ladw1 with SMTP id w1so9159524lad.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 06:52:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added the following changes in one patch:

1) Split db_names_init into alloc & load funcs

2) Added checks for out of memory with new alloc helpers

3) Ignore if there is no default class names file

3) Changed default class names path cls_names -> tc_cls

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/names.h |  3 ++-
 include/utils.h |  4 ++++
 lib/names.c     | 69 +++++++++++++++++++++++++++++++++++++++------------------
 lib/utils.c     | 26 ++++++++++++++++++++++
 tc/tc_util.c    | 19 ++++++++++++----
 5 files changed, 95 insertions(+), 26 deletions(-)

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
diff --git a/include/utils.h b/include/utils.h
index 9151c4f..4bb1bf0 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -172,4 +172,8 @@ extern int do_each_netns(int (*func)(char *nsname, void *arg), void *arg,
 
 char *int_to_str(int val, char *buf);
 
+void *xmalloc(size_t size);
+void xfree(void *ptr);
+char *xstrdup(char *str);
+
 #endif /* __UTILS_H__ */
diff --git a/lib/names.c b/lib/names.c
index 93933f7..63f1b9a 100644
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
+	db = xmalloc(sizeof(*db));
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
 
-		entry = malloc(sizeof(*entry));
+		entry = xmalloc(sizeof(*entry));
+		if (!entry)
+			goto Exit;
+
+		entry->name = xstrdup(namebuf);
+		if (!entry->name) {
+			xfree(entry);
+			goto Exit;
+		}
+
 		entry->id   = id;
-		entry->name = strdup(namebuf);
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
@@ -105,20 +124,24 @@ void db_names_free(struct db_names *db)
 		while (entry) {
 			struct db_entry *next = entry->next;
 
-			free(entry->name);
-			free(entry);
+			xfree(entry->name);
+			xfree(entry);
 			entry = next;
 		}
 	}
 
-	free(db->hash);
-	free(db);
+	xfree(db->hash);
+	xfree(db);
 }
 
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
diff --git a/lib/utils.c b/lib/utils.c
index 9cda268..d119a69 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -904,3 +904,29 @@ char *int_to_str(int val, char *buf)
 	sprintf(buf, "%d", val);
 	return buf;
 }
+
+void *xmalloc(size_t size)
+{
+	void *ptr = malloc(size);
+	if (!ptr)
+		fprintf(stderr, "xmalloc: Out of memory\n");
+
+	return ptr;
+}
+
+void xfree(void *ptr)
+{
+	if (!ptr)
+		fprintf(stderr, "xfree: ptr is NULL\n");
+	else
+		free(ptr);
+}
+
+char *xstrdup(char *str)
+{
+	char *ptr = strdup(str);
+	if (!ptr)
+		fprintf(stderr, "xstrdup: Out of memory\n");
+
+	return ptr;
+}
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
