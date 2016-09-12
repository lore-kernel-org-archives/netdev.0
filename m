From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH iproute2 net-next v1 4/7] tipc: add link monitor summary
Date: Mon, 12 Sep 2016 17:17:18 +0200
Message-ID: <1473693441-14254-5-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:60468 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933180AbcILPRi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 11:17:38 -0400
In-Reply-To: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The monitor summary command prints the basic attributes
specific to the local node.
A sample usage is shown below:
$ tipc link monitor summary
bearer eth:data0
    table_generation 15
    cluster_size 8
    algorithm overlapping-ring

bearer eth:data1
    table_generation 15
    cluster_size 8
    algorithm overlapping-ring

$ tipc link monitor summary -h
Usage: tipc monitor summary

Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 tipc/link.c | 47 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 46 insertions(+), 1 deletion(-)

diff --git a/tipc/link.c b/tipc/link.c
index 3f0c32106772..df93409f2173 100644
--- a/tipc/link.c
+++ b/tipc/link.c
@@ -515,6 +515,49 @@ static int cmd_link_mon_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	return msg_doit(nlh, NULL, NULL);
 }
 
+static int link_mon_summary_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_MON_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_MON])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_MON], parse_attrs, attrs);
+
+	printf("\nbearer %s\n",
+		mnl_attr_get_str(attrs[TIPC_NLA_MON_BEARER_NAME]));
+
+	printf("    table_generation %u\n",
+	       mnl_attr_get_u32(attrs[TIPC_NLA_MON_LISTGEN]));
+	printf("    cluster_size %u\n",
+		mnl_attr_get_u32(attrs[TIPC_NLA_MON_PEERCNT]));
+	printf("    algorithm %s\n",
+		attrs[TIPC_NLA_MON_ACTIVE] ? "overlapping-ring" : "full-mesh");
+
+	return MNL_CB_OK;
+}
+
+static int cmd_link_mon_summary(struct nlmsghdr *nlh, const struct cmd *cmd,
+				struct cmdl *cmdl, void *data)
+{
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (help_flag) {
+		fprintf(stderr,	"Usage: %s monitor summary\n", cmdl->argv[0]);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_MON_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_dumpit(nlh, link_mon_summary_cb, NULL);
+}
+
 static void cmd_link_mon_set_help(struct cmdl *cmdl)
 {
 	fprintf(stderr, "Usage: %s monitor set PPROPERTY\n\n"
@@ -592,7 +635,8 @@ static void cmd_link_mon_help(struct cmdl *cmdl)
 		"Usage: %s montior COMMAND [ARGS] ...\n\n"
 		"COMMANDS\n"
 		" set			- Set monitor properties\n"
-		" get			- Get monitor properties\n",
+		" get			- Get monitor properties\n"
+		" summary		- Show local node monitor summary\n",
 		cmdl->argv[0]);
 }
 
@@ -602,6 +646,7 @@ static int cmd_link_mon(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl
 	const struct cmd cmds[] = {
 		{ "set",	cmd_link_mon_set,	cmd_link_mon_set_help },
 		{ "get",	cmd_link_mon_get,	cmd_link_mon_get_help },
+		{ "summary",	cmd_link_mon_summary,	NULL },
 		{ NULL }
 	};
 
-- 
2.1.4
