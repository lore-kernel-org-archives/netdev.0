From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH iproute2 net-next v1 3/7] tipc: add link
	monitor get threshold
Date: Mon, 12 Sep 2016 17:17:17 +0200
Message-ID: <1473693441-14254-4-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

The command prints the monitor activation threshold.
A sample usage is shown below:
$ tipc link monitor get threshold
32

$ tipc link monitor get -h
Usage: tipc monitor get PPROPERTY

PROPERTIES
 threshold      - Get monitor activation threshold

Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 tipc/link.c | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 55 insertions(+), 1 deletion(-)

diff --git a/tipc/link.c b/tipc/link.c
index 3469cd302469..3f0c32106772 100644
--- a/tipc/link.c
+++ b/tipc/link.c
@@ -534,12 +534,65 @@ static int cmd_link_mon_set(struct nlmsghdr *nlh, const struct cmd *cmd,
 	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
 }
 
+static void cmd_link_mon_get_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s monitor get PPROPERTY \n\n"
+		"PROPERTIES\n"
+		" threshold 	- Get monitor activation threshold\n",
+		cmdl->argv[0]);
+}
+
+static int link_mon_get_cb(const struct nlmsghdr *nlh, void *data)
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
+	if (!attrs[TIPC_NLA_MON_ACTIVATION_THRESHOLD])
+		return MNL_CB_ERROR;
+
+	printf("%u\n",
+	       mnl_attr_get_u32(attrs[TIPC_NLA_MON_ACTIVATION_THRESHOLD]));
+
+	return MNL_CB_OK;
+}
+
+static int cmd_link_mon_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
+				 struct cmdl *cmdl, void *data)
+{
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (!(nlh = msg_init(buf, TIPC_NL_MON_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_doit(nlh,	link_mon_get_cb,	NULL);
+}
+
+static int cmd_link_mon_get(struct nlmsghdr *nlh, const struct cmd *cmd,
+			    struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "threshold",	cmd_link_mon_get_prop,	NULL},
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
 static void cmd_link_mon_help(struct cmdl *cmdl)
 {
 	fprintf(stderr,
 		"Usage: %s montior COMMAND [ARGS] ...\n\n"
 		"COMMANDS\n"
-		" set                  - Set monitor properties\n",
+		" set			- Set monitor properties\n"
+		" get			- Get monitor properties\n",
 		cmdl->argv[0]);
 }
 
@@ -548,6 +601,7 @@ static int cmd_link_mon(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl
 {
 	const struct cmd cmds[] = {
 		{ "set",	cmd_link_mon_set,	cmd_link_mon_set_help },
+		{ "get",	cmd_link_mon_get,	cmd_link_mon_get_help },
 		{ NULL }
 	};
 
-- 
2.1.4


------------------------------------------------------------------------------
