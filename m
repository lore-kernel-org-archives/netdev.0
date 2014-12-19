From: Vadim Kochan <vadim4j@gmail.com>
Subject: [RFC iproute2] tc: Show classes in tree view
Date: Fri, 19 Dec 2014 13:43:01 +0200
Message-ID: <1418989381-6492-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:61814 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbaLSLxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 06:53:05 -0500
Received: by mail-la0-f47.google.com with SMTP id hz20so696827lab.34
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 03:53:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added new '-t[ree]' which shows classes dependency
in the tree view.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/hlist.h |   6 ++
 tc/tc.c         |   5 +-
 tc/tc_class.c   | 170 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 tc/tc_common.h  |   2 +
 4 files changed, 180 insertions(+), 3 deletions(-)

diff --git a/include/hlist.h b/include/hlist.h
index 4e8de9e..dd3e606 100644
--- a/include/hlist.h
+++ b/include/hlist.h
@@ -53,4 +53,10 @@ static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
 	     pos;							\
 	     pos = hlist_entry_safe((pos)->member.next, typeof(*(pos)), member))
 
+static inline void INIT_HLIST_NODE(struct hlist_node *h)
+{
+	h->next = NULL;
+	h->pprev = NULL;
+}
+
 #endif /* __HLIST_H__ */
diff --git a/tc/tc.c b/tc/tc.c
index 9b50e74..a7986c1 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -34,8 +34,9 @@ int show_stats = 0;
 int show_details = 0;
 int show_raw = 0;
 int show_pretty = 0;
-int batch_mode = 0;
+int show_tree = 0;
 
+int batch_mode = 0;
 int resolve_hosts = 0;
 int use_iec = 0;
 int force = 0;
@@ -278,6 +279,8 @@ int main(int argc, char **argv)
 			++show_raw;
 		} else if (matches(argv[1], "-pretty") == 0) {
 			++show_pretty;
+		} else if (matches(argv[1], "-tree") == 0) {
+			++show_tree;
 		} else if (matches(argv[1], "-Version") == 0) {
 			printf("tc utility, iproute2-ss%s\n", SNAPSHOT);
 			return 0;
diff --git a/tc/tc_class.c b/tc/tc_class.c
index e56bf07..a14944c 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -24,6 +24,22 @@
 #include "utils.h"
 #include "tc_util.h"
 #include "tc_common.h"
+#include "hlist.h"
+
+struct cls_node {
+	struct hlist_node hlist;
+	__u32 handle;
+	__u32 parent;
+	int level;
+	struct cls_node *cls_parent;
+	struct cls_node *cls_right;
+	struct rtattr *attr;
+	int attr_len;
+	int childs_count;
+};
+
+static struct hlist_head cls_list = {};
+static struct hlist_head root_cls_list = {};
 
 static void usage(void);
 
@@ -148,13 +164,152 @@ int filter_ifindex;
 __u32 filter_qdisc;
 __u32 filter_classid;
 
+static void tree_cls_add(__u32 parent, __u32 handle, struct rtattr *attr, int len)
+{
+	struct cls_node *cls = malloc(sizeof(struct cls_node));
+
+	memset(cls, 0, sizeof(*cls));
+	cls->handle    = handle;
+	cls->parent    = parent;
+	cls->attr      = malloc(len);
+	cls->attr_len  = len;
+
+	memcpy(cls->attr, attr, len);
+
+	if (parent == TC_H_ROOT)
+		hlist_add_head(&cls->hlist, &root_cls_list);
+	else
+		hlist_add_head(&cls->hlist, &cls_list);
+}
+
+static void tree_cls_indent(char *buf, struct cls_node *cls, int new_line)
+{
+	while (cls && cls->cls_parent) {
+		cls->cls_parent->cls_right = cls;
+		cls = cls->cls_parent;
+	}
+	while (cls && cls->cls_right)
+	{
+		if (cls->hlist.next)
+			strcat(buf, "|   ");
+		else
+			strcat(buf, "    ");
+
+		cls = cls->cls_right;
+	}
+
+	if (new_line) {
+		if (cls->hlist.next && cls->childs_count)
+			strcat(buf, "|   |");
+		else if (cls->hlist.next)
+			strcat(buf, "|    ");
+		else if (cls->childs_count)
+			strcat(buf, "    |");
+		else if (!cls->hlist.next)
+			strcat(buf, "     ");
+	}
+}
+
+static void tree_cls_newline(char *buf, struct cls_node *cls, int indent)
+{
+	char str[100] = {};
+
+	tree_cls_indent(buf, cls, 1);
+	sprintf(str, "%-*s", indent, "");
+	strcat(buf, str);
+}
+
+static void tree_cls_show(FILE *fp, char *buf, struct hlist_head *root_list, int level)
+{
+	struct hlist_node *n, *tmp_cls;
+	char cls_id_str[256] = {};
+	struct rtattr * tb[TCA_MAX+1] = {};
+	struct qdisc_util *q;
+	char str[100] = {};
+
+	hlist_for_each_safe(n, tmp_cls, root_list) {
+		struct hlist_node *c, *tmp_chld;
+		struct hlist_head childs = {};
+		struct cls_node *cls = container_of(n, struct cls_node, hlist);
+
+		hlist_for_each_safe(c, tmp_chld, &cls_list) {
+			struct cls_node *child = container_of(c, struct cls_node, hlist);
+
+			if (cls->handle == child->parent) {
+				hlist_del(c);
+				INIT_HLIST_NODE(c);
+				hlist_add_head(c, &childs);
+				cls->childs_count++;
+				child->cls_parent = cls;
+			}
+		}
+
+		tree_cls_indent(buf, cls, 0);
+
+		print_tc_classid(cls_id_str, sizeof(cls_id_str), cls->handle);
+		sprintf(str, "+---%s", cls_id_str);
+		strcat(buf, str);
+
+		parse_rtattr(tb, TCA_MAX, cls->attr, cls->attr_len);
+
+		if (tb[TCA_KIND] == NULL) {
+			strcat(buf, "(none)");
+		} else {
+			q = get_qdisc_kind(rta_getattr_str(tb[TCA_KIND]));
+			if (q) {
+				sprintf(str, "(%s) ", q->id);
+				strcat(buf, str);
+				fprintf(fp, "%s", buf);
+				buf[0] = '\0';
+				if (q->print_copt) {
+					q->print_copt(q, fp, tb[TCA_OPTIONS]);
+				}
+			}
+			if (q && show_stats)
+			{
+				int cls_indent = strlen(q->id) + 2 +
+					strlen(cls_id_str);
+				struct rtattr *xstats = NULL;
+
+				buf[0] = '\0';
+				tree_cls_newline(buf, cls, cls_indent);
+
+				if (tb[TCA_STATS] || tb[TCA_STATS2]) {
+					fprintf(fp, "\n");
+					print_tcstats_attr(fp, tb, buf, &xstats);
+					buf[0] = '\0';
+				}
+
+				if (cls->hlist.next || cls->childs_count)
+				{
+					strcat(buf, "\n");
+					tree_cls_indent(buf, cls, 1);
+				}
+			}
+		}
+		free(cls->attr);
+		fprintf(fp, "%s\n", buf);
+		buf[0] = '\0';
+
+		tree_cls_show(fp, buf, &childs, level + 1);
+		if (!cls->hlist.next) {
+			tree_cls_indent(buf, cls, 0);
+			strcat(buf, "\n");
+		}
+
+		fprintf(fp, "%s", buf);
+		buf[0] = '\0';
+		free(cls);
+	}
+}
+
 int print_class(const struct sockaddr_nl *who,
 		       struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
 	struct tcmsg *t = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
-	struct rtattr * tb[TCA_MAX+1];
+	struct rtattr * tb[TCA_MAX+1] = {};
 	struct qdisc_util *q;
 	char abuf[256];
 
@@ -167,13 +322,18 @@ int print_class(const struct sockaddr_nl *who,
 		fprintf(stderr, "Wrong len %d\n", len);
 		return -1;
 	}
+
+	if (show_tree) {
+		tree_cls_add(t->tcm_parent, t->tcm_handle, TCA_RTA(t), len);
+		return 0;
+	}
+
 	if (filter_qdisc && TC_H_MAJ(t->tcm_handle^filter_qdisc))
 		return 0;
 
 	if (filter_classid && t->tcm_handle != filter_classid)
 		return 0;
 
-	memset(tb, 0, sizeof(tb));
 	parse_rtattr(tb, TCA_MAX, TCA_RTA(t), len);
 
 	if (tb[TCA_KIND] == NULL) {
@@ -306,6 +466,12 @@ static int tc_class_list(int argc, char **argv)
 		return 1;
 	}
 
+	if (show_tree)
+	{
+		char buf[1024];
+		tree_cls_show(stdout, &buf[0], &root_cls_list, 0);
+	}
+
 	return 0;
 }
 
diff --git a/tc/tc_common.h b/tc/tc_common.h
index 4f88856..0ee009b 100644
--- a/tc/tc_common.h
+++ b/tc/tc_common.h
@@ -19,3 +19,5 @@ extern int parse_estimator(int *p_argc, char ***p_argv, struct tc_estimator *est
 struct tc_sizespec;
 extern int parse_size_table(int *p_argc, char ***p_argv, struct tc_sizespec *s);
 extern int check_size_table_opts(struct tc_sizespec *s);
+
+extern int show_tree;
-- 
2.1.3
