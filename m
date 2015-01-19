From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 repost 1/2] tc: push bpf common code into separate file
Date: Mon, 19 Jan 2015 16:56:29 +0100
Message-ID: <1421682990-11072-1-git-send-email-jiri@resnulli.us>
Cc: jhs@mojatatu.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:58221 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbASP4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 10:56:35 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so2435385wgh.6
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 07:56:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 tc/Makefile |   2 +-
 tc/f_bpf.c  | 136 +++++--------------------------------------------------
 tc/tc_bpf.c | 146 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tc/tc_bpf.h |  28 ++++++++++++
 4 files changed, 186 insertions(+), 126 deletions(-)
 create mode 100644 tc/tc_bpf.c
 create mode 100644 tc/tc_bpf.h

diff --git a/tc/Makefile b/tc/Makefile
index 9412094..15f68ce 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -1,5 +1,5 @@
 TCOBJ= tc.o tc_qdisc.o tc_class.o tc_filter.o tc_util.o \
-       tc_monitor.o m_police.o m_estimator.o m_action.o \
+       tc_monitor.o tc_bpf.o m_police.o m_estimator.o m_action.o \
        m_ematch.o emp_ematch.yacc.o emp_ematch.lex.o
 
 include ../Config
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 48635a7..e2af94e 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -26,6 +26,7 @@
 
 #include "utils.h"
 #include "tc_util.h"
+#include "tc_bpf.h"
 
 static void explain(void)
 {
@@ -44,130 +45,6 @@ static void explain(void)
 	fprintf(stderr, "NOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
-static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
-			    char **bpf_string, bool *need_release,
-			    const char separator)
-{
-	char sp;
-
-	if (from_file) {
-		size_t tmp_len, op_len = sizeof("65535 255 255 4294967295,");
-		char *tmp_string;
-		FILE *fp;
-
-		tmp_len = sizeof("4096,") + BPF_MAXINSNS * op_len;
-		tmp_string = malloc(tmp_len);
-		if (tmp_string == NULL)
-			return -ENOMEM;
-
-		memset(tmp_string, 0, tmp_len);
-
-		fp = fopen(arg, "r");
-		if (fp == NULL) {
-			perror("Cannot fopen");
-			free(tmp_string);
-			return -ENOENT;
-		}
-
-		if (!fgets(tmp_string, tmp_len, fp)) {
-			free(tmp_string);
-			fclose(fp);
-			return -EIO;
-		}
-
-		fclose(fp);
-
-		*need_release = true;
-		*bpf_string = tmp_string;
-	} else {
-		*need_release = false;
-		*bpf_string = arg;
-	}
-
-	if (sscanf(*bpf_string, "%hu%c", bpf_len, &sp) != 2 ||
-	    sp != separator) {
-		if (*need_release)
-			free(*bpf_string);
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-static int bpf_parse_ops(int argc, char **argv, struct nlmsghdr *n,
-			 bool from_file)
-{
-	char *bpf_string, *token, separator = ',';
-	struct sock_filter bpf_ops[BPF_MAXINSNS];
-	int ret = 0, i = 0;
-	bool need_release;
-	__u16 bpf_len = 0;
-
-	if (argc < 1)
-		return -EINVAL;
-	if (bpf_parse_string(argv[0], from_file, &bpf_len, &bpf_string,
-			     &need_release, separator))
-		return -EINVAL;
-	if (bpf_len == 0 || bpf_len > BPF_MAXINSNS) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	token = bpf_string;
-	while ((token = strchr(token, separator)) && (++token)[0]) {
-		if (i >= bpf_len) {
-			fprintf(stderr, "Real program length exceeds encoded "
-				"length parameter!\n");
-			ret = -EINVAL;
-			goto out;
-		}
-
-		if (sscanf(token, "%hu %hhu %hhu %u,",
-			   &bpf_ops[i].code, &bpf_ops[i].jt,
-			   &bpf_ops[i].jf, &bpf_ops[i].k) != 4) {
-			fprintf(stderr, "Error at instruction %d!\n", i);
-			ret = -EINVAL;
-			goto out;
-		}
-
-		i++;
-	}
-
-	if (i != bpf_len) {
-		fprintf(stderr, "Parsed program length is less than encoded"
-			"length parameter!\n");
-		ret = -EINVAL;
-		goto out;
-	}
-
-	addattr_l(n, MAX_MSG, TCA_BPF_OPS_LEN, &bpf_len, sizeof(bpf_len));
-	addattr_l(n, MAX_MSG, TCA_BPF_OPS, &bpf_ops,
-		  bpf_len * sizeof(struct sock_filter));
-out:
-	if (need_release)
-		free(bpf_string);
-
-	return ret;
-}
-
-static void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len)
-{
-	struct sock_filter *ops = (struct sock_filter *) RTA_DATA(bpf_ops);
-	int i;
-
-	if (len == 0)
-		return;
-
-	fprintf(f, "bytecode \'%u,", len);
-
-	for (i = 0; i < len - 1; i++)
-		fprintf(f, "%hu %hhu %hhu %u,", ops[i].code, ops[i].jt,
-			ops[i].jf, ops[i].k);
-
-	fprintf(f, "%hu %hhu %hhu %u\'\n", ops[i].code, ops[i].jt,
-		ops[i].jf, ops[i].k);
-}
-
 static int bpf_parse_opt(struct filter_util *qu, char *handle,
 			 int argc, char **argv, struct nlmsghdr *n)
 {
@@ -195,6 +72,10 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 	while (argc > 0) {
 		if (matches(*argv, "run") == 0) {
 			bool from_file;
+			struct sock_filter bpf_ops[BPF_MAXINSNS];
+			__u16 bpf_len;
+			int ret;
+
 			NEXT_ARG();
 			if (strcmp(*argv, "bytecode-file") == 0) {
 				from_file = true;
@@ -206,10 +87,15 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 				return -1;
 			}
 			NEXT_ARG();
-			if (bpf_parse_ops(argc, argv, n, from_file)) {
+			ret = bpf_parse_ops(argc, argv, bpf_ops, from_file);
+			if (ret < 0) {
 				fprintf(stderr, "Illegal \"bytecode\"\n");
 				return -1;
 			}
+			bpf_len = ret;
+			addattr16(n, MAX_MSG, TCA_BPF_OPS_LEN, bpf_len);
+			addattr_l(n, MAX_MSG, TCA_BPF_OPS, &bpf_ops,
+				  bpf_len * sizeof(struct sock_filter));
 		} else if (matches(*argv, "classid") == 0 ||
 			   strcmp(*argv, "flowid") == 0) {
 			unsigned handle;
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
new file mode 100644
index 0000000..c6901d6
--- /dev/null
+++ b/tc/tc_bpf.c
@@ -0,0 +1,146 @@
+/*
+ * tc_bpf.c	BPF common code
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Daniel Borkmann <dborkman@redhat.com>
+ *		Jiri Pirko <jiri@resnulli.us>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <stdbool.h>
+#include <errno.h>
+#include <linux/filter.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+
+#include "utils.h"
+#include "tc_util.h"
+#include "tc_bpf.h"
+
+int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
+		     char **bpf_string, bool *need_release,
+		     const char separator)
+{
+	char sp;
+
+	if (from_file) {
+		size_t tmp_len, op_len = sizeof("65535 255 255 4294967295,");
+		char *tmp_string;
+		FILE *fp;
+
+		tmp_len = sizeof("4096,") + BPF_MAXINSNS * op_len;
+		tmp_string = malloc(tmp_len);
+		if (tmp_string == NULL)
+			return -ENOMEM;
+
+		memset(tmp_string, 0, tmp_len);
+
+		fp = fopen(arg, "r");
+		if (fp == NULL) {
+			perror("Cannot fopen");
+			free(tmp_string);
+			return -ENOENT;
+		}
+
+		if (!fgets(tmp_string, tmp_len, fp)) {
+			free(tmp_string);
+			fclose(fp);
+			return -EIO;
+		}
+
+		fclose(fp);
+
+		*need_release = true;
+		*bpf_string = tmp_string;
+	} else {
+		*need_release = false;
+		*bpf_string = arg;
+	}
+
+	if (sscanf(*bpf_string, "%hu%c", bpf_len, &sp) != 2 ||
+	    sp != separator) {
+		if (*need_release)
+			free(*bpf_string);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int bpf_parse_ops(int argc, char **argv, struct sock_filter *bpf_ops,
+		  bool from_file)
+{
+	char *bpf_string, *token, separator = ',';
+	int ret = 0, i = 0;
+	bool need_release;
+	__u16 bpf_len = 0;
+
+	if (argc < 1)
+		return -EINVAL;
+	if (bpf_parse_string(argv[0], from_file, &bpf_len, &bpf_string,
+			     &need_release, separator))
+		return -EINVAL;
+	if (bpf_len == 0 || bpf_len > BPF_MAXINSNS) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	token = bpf_string;
+	while ((token = strchr(token, separator)) && (++token)[0]) {
+		if (i >= bpf_len) {
+			fprintf(stderr, "Real program length exceeds encoded "
+				"length parameter!\n");
+			ret = -EINVAL;
+			goto out;
+		}
+
+		if (sscanf(token, "%hu %hhu %hhu %u,",
+			   &bpf_ops[i].code, &bpf_ops[i].jt,
+			   &bpf_ops[i].jf, &bpf_ops[i].k) != 4) {
+			fprintf(stderr, "Error at instruction %d!\n", i);
+			ret = -EINVAL;
+			goto out;
+		}
+
+		i++;
+	}
+
+	if (i != bpf_len) {
+		fprintf(stderr, "Parsed program length is less than encoded"
+			"length parameter!\n");
+		ret = -EINVAL;
+		goto out;
+	}
+	ret = bpf_len;
+
+out:
+	if (need_release)
+		free(bpf_string);
+
+	return ret;
+}
+
+void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len)
+{
+	struct sock_filter *ops = (struct sock_filter *) RTA_DATA(bpf_ops);
+	int i;
+
+	if (len == 0)
+		return;
+
+	fprintf(f, "bytecode \'%u,", len);
+
+	for (i = 0; i < len - 1; i++)
+		fprintf(f, "%hu %hhu %hhu %u,", ops[i].code, ops[i].jt,
+			ops[i].jf, ops[i].k);
+
+	fprintf(f, "%hu %hhu %hhu %u\'\n", ops[i].code, ops[i].jt,
+		ops[i].jf, ops[i].k);
+}
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
new file mode 100644
index 0000000..08cca92
--- /dev/null
+++ b/tc/tc_bpf.h
@@ -0,0 +1,28 @@
+/*
+ * tc_bpf.h	BPF common code
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Daniel Borkmann <dborkman@redhat.com>
+ *		Jiri Pirko <jiri@resnulli.us>
+ */
+
+#ifndef _TC_BPF_H_
+#define _TC_BPF_H_ 1
+
+#include <stdio.h>
+#include <linux/filter.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+
+int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
+		     char **bpf_string, bool *need_release,
+		     const char separator);
+int bpf_parse_ops(int argc, char **argv, struct sock_filter *bpf_ops,
+		  bool from_file);
+void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
+
+#endif
-- 
1.9.3
