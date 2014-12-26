From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tc class: Show classes as ASCII graph
Date: Fri, 26 Dec 2014 02:10:06 +0200
Message-ID: <1419552606-21516-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:51816 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbaLZAUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2014 19:20:16 -0500
Received: by mail-la0-f43.google.com with SMTP id s18so8392975lam.16
        for <netdev@vger.kernel.org>; Thu, 25 Dec 2014 16:20:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added new '-g[raph]' option which shows classes in the graph view.

Meanwhile only generic stats info output is supported.

e.g.:

$ tc/tc -g class show dev tap0
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

$ tc/tc -g -s class show dev tap0
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
 tc/tc.c        |   5 +-
 tc/tc_class.c  | 167 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 tc/tc_common.h |   2 +
 3 files changed, 171 insertions(+), 3 deletions(-)

diff --git a/tc/tc.c b/tc/tc.c
index 9b50e74..25a1c68 100644
--- a/tc/tc.c
+++ b/tc/tc.c
@@ -34,8 +34,9 @@ int show_stats = 0;
 int show_details = 0;
 int show_raw = 0;
 int show_pretty = 0;
-int batch_mode = 0;
+int show_graph = 0;
 
+int batch_mode = 0;
 int resolve_hosts = 0;
 int use_iec = 0;
 int force = 0;
@@ -278,6 +279,8 @@ int main(int argc, char **argv)
 			++show_raw;
 		} else if (matches(argv[1], "-pretty") == 0) {
 			++show_pretty;
+		} else if (matches(argv[1], "-graph") == 0) {
+			show_graph = 1;
 		} else if (matches(argv[1], "-Version") == 0) {
 			printf("tc utility, iproute2-ss%s\n", SNAPSHOT);
 			return 0;
diff --git a/tc/tc_class.c b/tc/tc_class.c
index ba7869b..877048a 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -24,6 +24,21 @@
 #include "utils.h"
 #include "tc_util.h"
 #include "tc_common.h"
+#include "hlist.h"
+
+struct graph_node {
+	struct hlist_node hlist;
+	__u32 id;
+	__u32 parent_id;
+	struct graph_node *parent_node;
+	struct graph_node *right_node;
+	void *data;
+	int data_len;
+	int nodes_count;
+};
+
+static struct hlist_head cls_list = {};
+static struct hlist_head root_cls_list = {};
 
 static void usage(void);
 
@@ -148,13 +163,152 @@ int filter_ifindex;
 __u32 filter_qdisc;
 __u32 filter_classid;
 
+static void graph_node_add(__u32 parent_id, __u32 id, void *data,
+		int len)
+{
+	struct graph_node *node = malloc(sizeof(struct graph_node));
+
+	memset(node, 0, sizeof(*node));
+	node->id         = id;
+	node->parent_id  = parent_id;
+
+	if (data && len) {
+		node->data       = malloc(len);
+		node->data_len   = len;
+		memcpy(node->data, data, len);
+	}
+
+	if (parent_id == TC_H_ROOT)
+		hlist_add_head(&node->hlist, &root_cls_list);
+	else
+		hlist_add_head(&node->hlist, &cls_list);
+}
+
+static void graph_indent(char *buf, struct graph_node *node, int is_newline,
+		int add_spaces)
+{
+	char spaces[100] = {0};
+
+	while (node && node->parent_node) {
+		node->parent_node->right_node = node;
+		node = node->parent_node;
+	}
+	while (node && node->right_node) {
+		if (node->hlist.next)
+			strcat(buf, "|    ");
+		else
+			strcat(buf, "     ");
+
+		node = node->right_node;
+	}
+
+	if (is_newline) {
+		if (node->hlist.next && node->nodes_count)
+			strcat(buf, "|    |");
+		else if (node->hlist.next)
+			strcat(buf, "|     ");
+		else if (node->nodes_count)
+			strcat(buf, "     |");
+		else if (!node->hlist.next)
+			strcat(buf, "      ");
+	}
+	if (add_spaces > 0) {
+		sprintf(spaces, "%-*s", add_spaces, "");
+		strcat(buf, spaces);
+	}
+}
+
+static void graph_cls_show(FILE *fp, char *buf, struct hlist_head *root_list,
+		int level)
+{
+	struct hlist_node *n, *tmp_cls;
+	char cls_id_str[256] = {};
+	struct rtattr *tb[TCA_MAX + 1] = {};
+	struct qdisc_util *q;
+	char str[100] = {};
+
+	hlist_for_each_safe(n, tmp_cls, root_list) {
+		struct hlist_node *c, *tmp_chld;
+		struct hlist_head children = {};
+		struct graph_node *cls = container_of(n, struct graph_node,
+				hlist);
+
+		hlist_for_each_safe(c, tmp_chld, &cls_list) {
+			struct graph_node *child = container_of(c,
+					struct graph_node, hlist);
+
+			if (cls->id == child->parent_id) {
+				hlist_del(c);
+				hlist_add_head(c, &children);
+				cls->nodes_count++;
+				child->parent_node = cls;
+			}
+		}
+
+		graph_indent(buf, cls, 0, 0);
+
+		print_tc_classid(cls_id_str, sizeof(cls_id_str), cls->id);
+		sprintf(str, "+---(%s)", cls_id_str);
+		strcat(buf, str);
+
+		parse_rtattr(tb, TCA_MAX, (struct rtattr *)cls->data,
+				cls->data_len);
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
+				struct rtattr *stats = NULL;
+
+				graph_indent(buf, cls, 1, cls_indent);
+
+				if (tb[TCA_STATS] || tb[TCA_STATS2]) {
+					fprintf(fp, "\n");
+					print_tcstats_attr(fp, tb, buf, &stats);
+					buf[0] = '\0';
+				}
+				if (cls->hlist.next || cls->nodes_count) {
+					strcat(buf, "\n");
+					graph_indent(buf, cls, 1, 0);
+				}
+			}
+		}
+		free(cls->data);
+		fprintf(fp, "%s\n", buf);
+		buf[0] = '\0';
+
+		graph_cls_show(fp, buf, &children, level + 1);
+		if (!cls->hlist.next) {
+			graph_indent(buf, cls, 0, 0);
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
+	struct rtattr *tb[TCA_MAX + 1] = {};
 	struct qdisc_util *q;
 	char abuf[256];
 
@@ -167,13 +321,18 @@ int print_class(const struct sockaddr_nl *who,
 		fprintf(stderr, "Wrong len %d\n", len);
 		return -1;
 	}
+
+	if (show_graph) {
+		graph_node_add(t->tcm_parent, t->tcm_handle, TCA_RTA(t), len);
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
@@ -236,6 +395,7 @@ static int tc_class_list(int argc, char **argv)
 {
 	struct tcmsg t;
 	char d[16];
+	char buf[1024] = {0};
 
 	memset(&t, 0, sizeof(t));
 	t.tcm_family = AF_UNSPEC;
@@ -306,6 +466,9 @@ static int tc_class_list(int argc, char **argv)
 		return 1;
 	}
 
+	if (show_graph)
+		graph_cls_show(stdout, &buf[0], &root_cls_list, 0);
+
 	return 0;
 }
 
diff --git a/tc/tc_common.h b/tc/tc_common.h
index 4f88856..ea16f7f 100644
--- a/tc/tc_common.h
+++ b/tc/tc_common.h
@@ -19,3 +19,5 @@ extern int parse_estimator(int *p_argc, char ***p_argv, struct tc_estimator *est
 struct tc_sizespec;
 extern int parse_size_table(int *p_argc, char ***p_argv, struct tc_sizespec *s);
 extern int check_size_table_opts(struct tc_sizespec *s);
+
+extern int show_graph;
-- 
2.1.3
