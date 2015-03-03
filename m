From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tc class: Show class names from file
Date: Tue,  3 Mar 2015 18:41:18 +0200
Message-ID: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:43191 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755628AbbCCQws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 11:52:48 -0500
Received: by wggy19 with SMTP id y19so41227593wgg.10
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 08:52:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

It is possible to use class names from file /etc/iproute2/cls_names
which tc will use when showing class info:

    # tc/tc -nm class show dev lo
	class htb 1:10 parent 1:1 leaf 10: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
	class htb 1:1 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
	class htb web#1:20 parent 1:1 leaf 20: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
	class htb 1:2 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
	class htb 1:30 parent 1:1 leaf 30: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
	class htb voip#1:40 parent 1:2 leaf 40: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
	class htb 1:50 parent 1:2 leaf 50: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
	class htb 1:60 parent 1:2 leaf 60: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b

or to specify via file path:

    # tc/tc -nm -cf /tmp/cls_names class show dev lo

Class names file contains simple "maj:min  name" structure:

1:20    web
1:40    voip

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/names.h |  25 +++++++++
 lib/Makefile    |   3 +-
 lib/names.c     | 156 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tc/tc.c         |  25 ++++++++-
 tc/tc_common.h  |   1 +
 tc/tc_util.c    |  48 ++++++++++++++---
 tc/tc_util.h    |   3 ++
 7 files changed, 252 insertions(+), 9 deletions(-)
 create mode 100644 include/names.h
 create mode 100644 lib/names.c

diff --git a/include/names.h b/include/names.h
new file mode 100644
index 0000000..4123d0b
--- /dev/null
+++ b/include/names.h
@@ -0,0 +1,25 @@
+#ifndef DB_NAMES_H_
+#define DB_NAMES_H_ 1
+
+#define IDNAME_MAX 256
+
+struct db_entry {
+	struct db_entry *next;
+	unsigned int id;
+	char *name;
+};
+
+struct db_names {
+	unsigned int size;
+	struct db_entry *cached;
+	struct db_entry **hash;
+	int max;
+};
+
+struct db_names *db_names_alloc(const char *path);
+void db_names_free(struct db_names *db);
+
+char *id_to_name(struct db_names *db, int id, char *name);
+int name_to_id(struct db_names *db, int *id, const char *name);
+
+#endif
diff --git a/lib/Makefile b/lib/Makefile
index 66f89f1..4c7cbc2 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -6,7 +6,8 @@ endif
 
 CFLAGS += -fPIC
 
-UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o namespace.o
+UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o namespace.o \
+	names.o
 
 NLOBJ=libgenl.o ll_map.o libnetlink.o
 
diff --git a/lib/names.c b/lib/names.c
new file mode 100644
index 0000000..93933f7
--- /dev/null
+++ b/lib/names.c
@@ -0,0 +1,156 @@
+/*
+ * names.c		db names
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ */
+
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+
+#include "names.h"
+
+#define MAX_ENTRIES  256
+#define NAME_MAX_LEN 512
+
+static int read_id_name(FILE *fp, int *id, char *name)
+{
+	char buf[NAME_MAX_LEN];
+	int min, maj;
+
+	while (fgets(buf, sizeof(buf), fp)) {
+		char *p = buf;
+
+		while (*p == ' ' || *p == '\t')
+			p++;
+
+		if (*p == '#' || *p == '\n' || *p == 0)
+			continue;
+
+		if (sscanf(p, "%x:%x %s\n", &maj, &min, name) == 3) {
+			*id = (maj << 16) | min;
+		} else if (sscanf(p, "%x:%x %s #", &maj, &min, name) == 3) {
+			*id = (maj << 16) | min;
+		} else if (sscanf(p, "0x%x %s\n", id, name) != 2 &&
+				sscanf(p, "0x%x %s #", id, name) != 2 &&
+				sscanf(p, "%d %s\n", id, name) != 2 &&
+				sscanf(p, "%d %s #", id, name) != 2) {
+			strcpy(name, p);
+			return -1;
+		}
+		return 1;
+	}
+
+	return 0;
+}
+
+struct db_names *db_names_alloc(const char *path)
+{
+	struct db_names *db;
+	struct db_entry *entry;
+	FILE *fp;
+	int id;
+	char namebuf[NAME_MAX_LEN] = {0};
+	int ret;
+
+	fp = fopen(path, "r");
+	if (!fp) {
+		fprintf(stderr, "Can't open file: %s\n", path);
+		return NULL;
+	}
+
+	db = malloc(sizeof(*db));
+	memset(db, 0, sizeof(*db));
+
+	db->size = MAX_ENTRIES;
+	db->hash = malloc(sizeof(struct db_entry *) * db->size);
+	memset(db->hash, 0, sizeof(struct db_entry *) * db->size);
+
+	while ((ret = read_id_name(fp, &id, &namebuf[0]))) {
+		if (ret == -1) {
+			fprintf(stderr, "Database %s is corrupted at %s\n",
+					path, namebuf);
+			fclose(fp);
+			return NULL;
+		}
+
+		if (id < 0)
+			continue;
+
+		entry = malloc(sizeof(*entry));
+		entry->id   = id;
+		entry->name = strdup(namebuf);
+		entry->next = db->hash[id & (db->size - 1)];
+		db->hash[id & (db->size - 1)] = entry;
+	}
+
+	fclose(fp);
+	return db;
+}
+
+void db_names_free(struct db_names *db)
+{
+	int i;
+
+	if (!db)
+		return;
+
+	for (i = 0; i < db->size; i++) {
+		struct db_entry *entry = db->hash[i];
+
+		while (entry) {
+			struct db_entry *next = entry->next;
+
+			free(entry->name);
+			free(entry);
+			entry = next;
+		}
+	}
+
+	free(db->hash);
+	free(db);
+}
+
+char *id_to_name(struct db_names *db, int id, char *name)
+{
+	struct db_entry *entry = db->hash[id & (db->size - 1)];
+
+	while (entry && entry->id != id)
+		entry = entry->next;
+
+	if (entry) {
+		strncpy(name, entry->name, IDNAME_MAX);
+		return name;
+	}
+
+	snprintf(name, IDNAME_MAX, "%d", id);
+	return NULL;
+}
+
+int name_to_id(struct db_names *db, int *id, const char *name)
+{
+	struct db_entry *entry;
+	int i;
+
+	if (db->cached && strcmp(db->cached->name, name) == 0) {
+		*id = db->cached->id;
+		return 0;
+	}
+
+	for (i = 0; i < db->size; i++) {
+		entry = db->hash[i];
+		while (entry && strcmp(entry->name, name))
+			entry = entry->next;
+		if (entry) {
+			db->cached = entry;
+			*id = entry->id;
+			return 0;
+		}
+	}
+
+	return -1;
+}
diff --git a/tc/tc.c b/tc/tc.c
index 9380305..22c3be4 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -41,6 +41,10 @@ int batch_mode = 0;
 int resolve_hosts = 0;
 int use_iec = 0;
 int force = 0;
+bool use_names = false;
+
+static char *conf_file;
+
 struct rtnl_handle rth;
 
 static void *BODY = NULL;	/* cached handle dlopen(NULL) */
@@ -188,7 +192,8 @@ static void usage(void)
 			"       tc [-force] -batch filename\n"
 	                "where  OBJECT := { qdisc | class | filter | action | monitor }\n"
 	                "       OPTIONS := { -s[tatistics] | -d[etails] | -r[aw] | -p[retty] | -b[atch] [filename] | "
-			"-n[etns] name }\n");
+			"-n[etns] name |\n"
+			"                    -nm | -nam[es] | { -cf | -conf } path }\n");
 }
 
 static int do_cmd(int argc, char **argv)
@@ -293,7 +298,7 @@ int main(int argc, char **argv)
 			return 0;
 		} else if (matches(argv[1], "-force") == 0) {
 			++force;
-		} else 	if (matches(argv[1], "-batch") == 0) {
+		} else if (matches(argv[1], "-batch") == 0) {
 			argc--;	argv++;
 			if (argc <= 1)
 				usage();
@@ -302,6 +307,13 @@ int main(int argc, char **argv)
 			NEXT_ARG();
 			if (netns_switch(argv[1]))
 				return -1;
+		} else if (matches(argv[1], "-names") == 0 ||
+				matches(argv[1], "-nm") == 0) {
+			use_names = true;
+		} else if (matches(argv[1], "-cf") == 0 ||
+				matches(argv[1], "-conf") == 0) {
+			NEXT_ARG();
+			conf_file = argv[1];
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"tc -help\".\n", argv[1]);
 			return -1;
@@ -323,8 +335,17 @@ int main(int argc, char **argv)
 		exit(1);
 	}
 
+	if (use_names && cls_names_init(conf_file)) {
+		ret = -1;
+		goto Exit;
+	}
+
 	ret = do_cmd(argc-1, argv+1);
+Exit:
 	rtnl_close(&rth);
 
+	if (use_names)
+		cls_names_uninit();
+
 	return ret;
 }
diff --git a/tc/tc_common.h b/tc/tc_common.h
index ea16f7f..96a0e20 100644
--- a/tc/tc_common.h
+++ b/tc/tc_common.h
@@ -21,3 +21,4 @@ extern int parse_size_table(int *p_argc, char ***p_argv, struct tc_sizespec *s);
 extern int check_size_table_opts(struct tc_sizespec *s);
 
 extern int show_graph;
+extern bool use_names;
diff --git a/tc/tc_util.c b/tc/tc_util.c
index f1fca0a..feae439 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -23,12 +23,34 @@
 #include <math.h>
 
 #include "utils.h"
+#include "names.h"
 #include "tc_util.h"
+#include "tc_common.h"
 
 #ifndef LIBDIR
 #define LIBDIR "/usr/lib"
 #endif
 
+static struct db_names *cls_names = NULL;
+
+#define NAMES_DB "/etc/iproute2/cls_names"
+
+int cls_names_init(char *path)
+{
+	cls_names = db_names_alloc(path ?: NAMES_DB);
+	if (!cls_names) {
+		fprintf(stderr, "Error while opening class names file\n");
+		return -1;
+	}
+
+	return 0;
+}
+
+void cls_names_uninit(void)
+{
+	db_names_free(cls_names);
+}
+
 const char *get_tc_lib(void)
 {
 	const char *lib_dir;
@@ -97,20 +119,34 @@ ok:
 
 int print_tc_classid(char *buf, int len, __u32 h)
 {
+	char handle[40] = {};
+
 	if (h == TC_H_ROOT)
-		sprintf(buf, "root");
+		sprintf(handle, "root");
 	else if (h == TC_H_UNSPEC)
-		snprintf(buf, len, "none");
+		snprintf(handle, len, "none");
 	else if (TC_H_MAJ(h) == 0)
-		snprintf(buf, len, ":%x", TC_H_MIN(h));
+		snprintf(handle, len, ":%x", TC_H_MIN(h));
 	else if (TC_H_MIN(h) == 0)
-		snprintf(buf, len, "%x:", TC_H_MAJ(h)>>16);
+		snprintf(handle, len, "%x:", TC_H_MAJ(h) >> 16);
 	else
-		snprintf(buf, len, "%x:%x", TC_H_MAJ(h)>>16, TC_H_MIN(h));
+		snprintf(handle, len, "%x:%x", TC_H_MAJ(h) >> 16, TC_H_MIN(h));
+
+	if (use_names) {
+		char clname[IDNAME_MAX] = {};
+
+		if (id_to_name(cls_names, h, clname))
+			snprintf(buf, len, "%s#%s", clname, handle);
+		else
+			snprintf(buf, len, "%s", handle);
+	} else {
+		snprintf(buf, len, "%s", handle);
+	}
+
 	return 0;
 }
 
-char * sprint_tc_classid(__u32 h, char *buf)
+char *sprint_tc_classid(__u32 h, char *buf)
 {
 	if (print_tc_classid(buf, SPRINT_BSIZE-1, h))
 		strcpy(buf, "???");
diff --git a/tc/tc_util.h b/tc/tc_util.h
index d418367..1be1b50 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -100,4 +100,7 @@ extern int  parse_action(int *, char ***, int, struct nlmsghdr *);
 extern void print_tm(FILE *f, const struct tcf_t *tm);
 extern int prio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt);
 
+extern int cls_names_init(char *path);
+extern void cls_names_uninit(void);
+
 #endif
-- 
2.2.2
