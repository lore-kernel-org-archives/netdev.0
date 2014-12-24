From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v3] tc: Show classes in tree view
Date: Wed, 24 Dec 2014 02:46:16 +0200
Message-ID: <1419381976-23986-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:46090 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbaLXA4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 19:56:25 -0500
Received: by mail-lb0-f170.google.com with SMTP id 10so6201367lbg.29
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 16:56:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added new '-t[ree]' which shows classes dependency
in the tree view. Meanwhile only generic stats info
is supported.

e.g.:

$ tc/tc -t class show dev tap0
+---(1:2) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
|    +---(1:40) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
|    +---(1:50) htb rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
|    |    +---(1:51) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
|    |
|    +---(1:60) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
|
+---(1:1) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
     +---(1:10) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
     +---(1:20) htb prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
     +---(1:30) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b

$ tc/tc -t -s class show dev tap0
+---(1:2) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
|    |    Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
|    |    rate 0bit 0pps backlog 0b 0p requeues 0
|    |
|    +---(1:40) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
|    |          Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
|    |          rate 0bit 0pps backlog 0b 0p requeues 0
|    |
|    +---(1:50) htb rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
|    |    |     Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
|    |    |     rate 0bit 0pps backlog 0b 0p requeues 0
|    |    |
|    |    +---(1:51) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
|    |               Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
|    |               rate 0bit 0pps backlog 0b 0p requeues 0
|    |
|    +---(1:60) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
|               Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
|               rate 0bit 0pps backlog 0b 0p requeues 0
|
+---(1:1) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
     |    Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
     |    rate 0bit 0pps backlog 0b 0p requeues 0
     |
     +---(1:10) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
     |          Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
     |          rate 0bit 0pps backlog 0b 0p requeues 0
     |
     +---(1:20) htb prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
     |          Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
     |          rate 0bit 0pps backlog 0b 0p requeues 0
     |
     +---(1:30) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
                Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
                rate 0bit 0pps backlog 0b 0p requeues 0

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
Changes v3:
    Fixed wrong brackets style

Changes v2:
    Removed "Date:" from commit message which was added by mistake.

Changes RFC -> PATCH:
    #1 get rid of INIT_HLIST_NODE
    #2 added sample output to commit message
    #3 use "show_tree=1" instead of "show_tree++"
    #4 no need update include/hlist.h (because of #1)
    #5 changed a little tree output: parentheses around class id instead of qdisc name

 tc/tc.c        |   5 +-
 tc/tc_class.c  | 161 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 tc/tc_common.h |   2 +
 3 files changed, 165 insertions(+), 3 deletions(-)

diff --git a/tc/tc.c b/tc/tc.c
index 9b50e74..30950a6 100644
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
+			show_tree = 1;
 		} else if (matches(argv[1], "-Version") == 0) {
 			printf("tc utility, iproute2-ss%s\n", SNAPSHOT);
 			return 0;
diff --git a/tc/tc_class.c b/tc/tc_class.c
index e56bf07..f155294 100644
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
 
@@ -148,13 +164,145 @@ int filter_ifindex;
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
+static void tree_cls_indent(char *buf, struct cls_node *cls, int is_newline,
+		int add_spaces)
+{
+	char spaces[100] = {0};
+
+	while (cls && cls->cls_parent) {
+		cls->cls_parent->cls_right = cls;
+		cls = cls->cls_parent;
+	}
+	while (cls && cls->cls_right) {
+		if (cls->hlist.next)
+			strcat(buf, "|    ");
+		else
+			strcat(buf, "     ");
+
+		cls = cls->cls_right;
+	}
+
+	if (is_newline) {
+		if (cls->hlist.next && cls->childs_count)
+			strcat(buf, "|    |");
+		else if (cls->hlist.next)
+			strcat(buf, "|     ");
+		else if (cls->childs_count)
+			strcat(buf, "     |");
+		else if (!cls->hlist.next)
+			strcat(buf, "      ");
+	}
+	if (add_spaces > 0) {
+		sprintf(spaces, "%-*s", add_spaces, "");
+		strcat(buf, spaces);
+	}
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
+				hlist_add_head(c, &childs);
+				cls->childs_count++;
+				child->cls_parent = cls;
+			}
+		}
+
+		tree_cls_indent(buf, cls, 0, 0);
+
+		print_tc_classid(cls_id_str, sizeof(cls_id_str), cls->handle);
+		sprintf(str, "+---(%s)", cls_id_str);
+		strcat(buf, str);
+
+		parse_rtattr(tb, TCA_MAX, cls->attr, cls->attr_len);
+
+		if (tb[TCA_KIND] == NULL) {
+			strcat(buf, " [unknown qdisc kind] ");
+		} else {
+			const char *kind = rta_getattr_str(tb[TCA_KIND]);
+
+			sprintf(str, " %s ", kind);
+			strcat(buf, str);
+			fprintf(fp, "%s", buf);
+			buf[0] = '\0';
+
+			q = get_qdisc_kind(kind);
+			if (q && q->print_copt) {
+				q->print_copt(q, fp, tb[TCA_OPTIONS]);
+			}
+			if (q && show_stats) {
+				int cls_indent = strlen(q->id) - 2 +
+					strlen(cls_id_str);
+				struct rtattr *xstats = NULL;
+
+				tree_cls_indent(buf, cls, 1, cls_indent);
+
+				if (tb[TCA_STATS] || tb[TCA_STATS2]) {
+					fprintf(fp, "\n");
+					print_tcstats_attr(fp, tb, buf, &xstats);
+					buf[0] = '\0';
+				}
+				if (cls->hlist.next || cls->childs_count) {
+					strcat(buf, "\n");
+					tree_cls_indent(buf, cls, 1, 0);
+				}
+			}
+		}
+		free(cls->attr);
+		fprintf(fp, "%s\n", buf);
+		buf[0] = '\0';
+
+		tree_cls_show(fp, buf, &childs, level + 1);
+		if (!cls->hlist.next) {
+			tree_cls_indent(buf, cls, 0, 0);
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
 
@@ -167,13 +315,18 @@ int print_class(const struct sockaddr_nl *who,
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
@@ -236,6 +389,7 @@ static int tc_class_list(int argc, char **argv)
 {
 	struct tcmsg t;
 	char d[16];
+	char buf[1024] = {0};
 
 	memset(&t, 0, sizeof(t));
 	t.tcm_family = AF_UNSPEC;
@@ -306,6 +460,9 @@ static int tc_class_list(int argc, char **argv)
 		return 1;
 	}
 
+	if (show_tree)
+		tree_cls_show(stdout, &buf[0], &root_cls_list, 0);
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
