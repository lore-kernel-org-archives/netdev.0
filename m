From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH iproute2 net-next v1 2/7] tipc: add link
	monitor set threshold
Date: Mon, 12 Sep 2016 17:17:16 +0200
Message-ID: <1473693441-14254-3-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The command sets the activation threshold for the new
cluster ring supervision.
A sample usage is shown below:
$ tipc link monitor set threshold 4

$ tipc link monitor set -h
Usage: tipc monitor set PPROPERTY

PROPERTIES
 threshold SIZE - Set activation threshold for monitor

Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 tipc/link.c | 69 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 68 insertions(+), 1 deletion(-)

diff --git a/tipc/link.c b/tipc/link.c
index 8bdc98224d39..3469cd302469 100644
--- a/tipc/link.c
+++ b/tipc/link.c
@@ -489,6 +489,71 @@ static int cmd_link_set(struct nlmsghdr *nlh, const struct cmd *cmd,
 	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
 }
 
+static int cmd_link_mon_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
+				 struct cmdl *cmdl, void *data)
+{
+	int size;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *attrs;
+
+	if (cmdl->argc != cmdl->optind + 1) {
+		fprintf(stderr, "error, missing value\n");
+		return -EINVAL;
+	}
+	size = atoi(shift_cmdl(cmdl));
+
+	if (!(nlh = msg_init(buf, TIPC_NL_MON_SET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+	attrs = mnl_attr_nest_start(nlh, TIPC_NLA_MON);
+
+	mnl_attr_put_u32(nlh, TIPC_NLA_MON_ACTIVATION_THRESHOLD, size);
+
+	mnl_attr_nest_end(nlh, attrs);
+
+	return msg_doit(nlh, NULL, NULL);
+}
+
+static void cmd_link_mon_set_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s monitor set PPROPERTY\n\n"
+		"PROPERTIES\n"
+		" threshold SIZE	- Set monitor activation threshold\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_link_mon_set(struct nlmsghdr *nlh, const struct cmd *cmd,
+			    struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "threshold",	cmd_link_mon_set_prop,	NULL },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+static void cmd_link_mon_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s montior COMMAND [ARGS] ...\n\n"
+		"COMMANDS\n"
+		" set                  - Set monitor properties\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_link_mon(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+			void *data)
+{
+	const struct cmd cmds[] = {
+		{ "set",	cmd_link_mon_set,	cmd_link_mon_set_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
 void cmd_link_help(struct cmdl *cmdl)
 {
 	fprintf(stderr,
@@ -498,7 +563,8 @@ void cmd_link_help(struct cmdl *cmdl)
 		" list                  - List links\n"
 		" get                   - Get various link properties\n"
 		" set                   - Set various link properties\n"
-		" statistics            - Show or reset statistics\n",
+		" statistics            - Show or reset statistics\n"
+		" monitor               - Show or set link supervision\n",
 		cmdl->argv[0]);
 }
 
@@ -510,6 +576,7 @@ int cmd_link(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
 		{ "list",	cmd_link_list,	NULL },
 		{ "set",	cmd_link_set,	cmd_link_set_help },
 		{ "statistics", cmd_link_stat,	cmd_link_stat_help },
+		{ "monitor",	cmd_link_mon,	cmd_link_mon_help },
 		{ NULL }
 	};
 
-- 
2.1.4


------------------------------------------------------------------------------
