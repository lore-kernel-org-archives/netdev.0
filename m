From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH iproute2 net-next v1 6/7] tipc: add link
	monitor list
Date: Mon, 12 Sep 2016 17:17:20 +0200
Message-ID: <1473693441-14254-7-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

In this commit, we list the monitor attributes. By default it lists
the attributes for all bearers, otherwise the specified bearer.

A sample usage is shown below:
$ tipc link monitor list

bearer eth:data0
node          status monitored generation applied_node_status [non_applied_node:status]
1.1.1         up     direct    16         UU []
1.1.2         up     direct    16         UU []
1.1.3         up     direct    16         UU []

bearer eth:data1
node          status monitored generation applied_node_status [non_applied_node:status]
1.1.1         up     direct    2          UU []
1.1.2         up     direct    3          UU []
1.1.3         up     direct    3          UU []

$ tipc link monitor list media eth device data0

bearer eth:data0
node          status monitored generation applied_node_status [non_applied_node:status]
1.1.1         up     direct    16         UU []
1.1.2         up     direct    16         UU []
1.1.3         up     direct    16         UU []

$ tipc link monitor list -h
Usage: tipc monitor list [ media MEDIA ARGS...]

MEDIA
 udp                   - User Datagram Protocol
 ib                    - Infiniband
 eth                   - Ethernet

Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 tipc/link.c | 237 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 237 insertions(+)

diff --git a/tipc/link.c b/tipc/link.c
index df93409f2173..0b5c0491a35f 100644
--- a/tipc/link.c
+++ b/tipc/link.c
@@ -22,6 +22,7 @@
 #include "cmdl.h"
 #include "msg.h"
 #include "link.h"
+#include "bearer.h"
 
 static int link_list_cb(const struct nlmsghdr *nlh, void *data)
 {
@@ -558,6 +559,240 @@ static int cmd_link_mon_summary(struct nlmsghdr *nlh, const struct cmd *cmd,
 	return msg_dumpit(nlh, link_mon_summary_cb, NULL);
 }
 
+#define STATUS_WIDTH 7
+#define MAX_NODE_WIDTH 14 /* 255.4095.4095 */
+#define MAX_DOM_GEN_WIDTH 11 /* 65535 */
+#define DIRECTLY_MON_WIDTH 10
+
+#define APPL_NODE_STATUS_WIDTH 5
+
+static int map_get(uint64_t up_map, int i)
+{
+	return (up_map & (1 << i)) >> i;
+}
+
+/* print the applied members, since we know the the members
+ * are listed in ascending order, we print only the state */
+static void link_mon_print_applied(uint16_t applied, uint64_t up_map)
+{
+	int i;
+	char state;
+
+	for (i = 0; i < applied; i++) {
+		/* print the delimiter for every -n- entry */
+		if (i && !(i % APPL_NODE_STATUS_WIDTH))
+			printf(",");
+
+		state = map_get(up_map, i) ? 'U' : 'D';
+		printf("%c", state);
+	}
+}
+
+/* print the non applied members, since we dont know
+ * the members, we print them along with the state */
+static void link_mon_print_non_applied(uint16_t applied, uint16_t member_cnt,
+				       uint64_t up_map,  uint32_t *members)
+{
+	int i;
+	char state;
+
+	printf(" [");
+	for (i = applied; i < member_cnt; i++) {
+		char addr_str[16];
+
+		/* print the delimiter for every entry */
+		if (i != applied)
+			printf(",");
+
+		sprintf(addr_str, "%u.%u.%u:", tipc_zone(members[i]),
+			tipc_cluster(members[i]), tipc_node(members[i]));
+		state = map_get(up_map, i) ? 'U' : 'D';
+		printf("%s%c", addr_str, state);
+	}
+	printf("]");
+}
+
+static void link_mon_print_peer_state(const uint32_t addr, const char *status,
+				      const char *monitored,
+				      const uint32_t dom_gen)
+{
+	char addr_str[16];
+
+	sprintf(addr_str, "%u.%u.%u", tipc_zone(addr), tipc_cluster(addr),
+		tipc_node(addr));
+
+	printf("%-*s", MAX_NODE_WIDTH, addr_str);
+	printf("%-*s", STATUS_WIDTH, status);
+	printf("%-*s", DIRECTLY_MON_WIDTH, monitored);
+	printf("%-*u", MAX_DOM_GEN_WIDTH, dom_gen);
+}
+
+static int link_mon_peer_list_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *attrs[TIPC_NLA_MON_PEER_MAX + 1] = {};
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	uint16_t member_cnt;
+	uint32_t applied;
+	uint32_t dom_gen;
+	uint64_t up_map;
+	char status[16];
+	char monitored[16];
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_MON_PEER])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_MON_PEER], parse_attrs, attrs);
+
+	(attrs[TIPC_NLA_MON_PEER_LOCAL] || attrs[TIPC_NLA_MON_PEER_HEAD]) ?
+		strcpy(monitored, "direct") :
+		strcpy(monitored, "indirect");
+
+	attrs[TIPC_NLA_MON_PEER_UP] ?
+		strcpy(status, "up") :
+		strcpy(status, "down");
+
+	dom_gen = attrs[TIPC_NLA_MON_PEER_DOMGEN] ?
+		mnl_attr_get_u32(attrs[TIPC_NLA_MON_PEER_DOMGEN]) : 0;
+
+	link_mon_print_peer_state(mnl_attr_get_u32(attrs[TIPC_NLA_MON_PEER_ADDR]),
+				  status, monitored, dom_gen);
+
+	applied = mnl_attr_get_u32(attrs[TIPC_NLA_MON_PEER_APPLIED]);
+
+	if (!applied)
+		goto exit;
+
+	up_map = mnl_attr_get_u64(attrs[TIPC_NLA_MON_PEER_UPMAP]);
+
+	member_cnt = mnl_attr_get_payload_len(attrs[TIPC_NLA_MON_PEER_MEMBERS]);
+
+	/* each tipc address occupies 4 bytes of payload, hence compensate it */
+	member_cnt /= sizeof(uint32_t);
+
+	link_mon_print_applied(applied, up_map);
+
+	link_mon_print_non_applied(applied, member_cnt, up_map,
+				   mnl_attr_get_payload(attrs[TIPC_NLA_MON_PEER_MEMBERS]));
+
+exit:
+	printf("\n");
+
+	return MNL_CB_OK;
+}
+
+static int link_mon_peer_list(uint32_t mon_ref)
+{
+	struct nlmsghdr *nlh;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *nest;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_MON_PEER_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_MON);
+	mnl_attr_put_u32(nlh, TIPC_NLA_MON_REF, mon_ref);
+	mnl_attr_nest_end(nlh, nest);
+
+	return msg_dumpit(nlh, link_mon_peer_list_cb, NULL);
+}
+
+static int link_mon_list_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_MON_MAX + 1] = {};
+	char *req_bearer = data;
+	const char *bname;
+	const char *title = "node          status monitored generation "
+			    "applied_node_status [non_applied_node:status]";
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_MON])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_MON], parse_attrs, attrs);
+
+	bname = mnl_attr_get_str(attrs[TIPC_NLA_MON_BEARER_NAME]);
+
+	if (*req_bearer && (strcmp(req_bearer, bname) != 0))
+		return MNL_CB_OK;
+
+	printf("\nbearer %s\n", bname);
+	printf("%s\n", title);
+
+	if (mnl_attr_get_u32(attrs[TIPC_NLA_MON_PEERCNT]))
+		link_mon_peer_list(mnl_attr_get_u32(attrs[TIPC_NLA_MON_REF]));
+
+	return MNL_CB_OK;
+}
+
+static void cmd_link_mon_list_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s monitor list [ media MEDIA ARGS...] \n\n",
+		cmdl->argv[0]);
+	print_bearer_media();
+}
+
+static void cmd_link_mon_list_l2_help(struct cmdl *cmdl, char *media)
+{
+	fprintf(stderr,
+		"Usage: %s monitor list media %s device DEVICE [OPTIONS]\n",
+		cmdl->argv[0], media);
+}
+
+static void cmd_link_mon_list_udp_help(struct cmdl *cmdl, char *media)
+{
+	fprintf(stderr,
+		"Usage: %s monitor list media udp name NAME \n\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_link_mon_list(struct nlmsghdr *nlh, const struct cmd *cmd,
+			     struct cmdl *cmdl, void *data)
+{
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	char bname[TIPC_MAX_BEARER_NAME] = {0};
+	struct opt opts[] = {
+		{ "media",	OPT_KEYVAL,	NULL },
+		{ "device",	OPT_KEYVAL,	NULL },
+		{ "name",	OPT_KEYVAL,	NULL },
+		{ NULL }
+	};
+	struct tipc_sup_media sup_media[] = {
+		{ "udp",        "name",         cmd_link_mon_list_udp_help},
+		{ "eth",        "device",       cmd_link_mon_list_l2_help },
+		{ "ib",         "device",       cmd_link_mon_list_l2_help },
+		{ NULL, },
+	};
+
+	int err;
+
+	if (parse_opts(opts, cmdl) < 0)
+		return -EINVAL;
+
+	if (get_opt(opts, "media")) {
+		if ((err = cmd_get_unique_bearer_name(cmd, cmdl, opts, bname,
+						      sup_media)))
+			return err;
+	}
+
+	if (help_flag) {
+		cmd->help(cmdl);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_MON_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_dumpit(nlh, link_mon_list_cb, bname);
+}
+
 static void cmd_link_mon_set_help(struct cmdl *cmdl)
 {
 	fprintf(stderr, "Usage: %s monitor set PPROPERTY\n\n"
@@ -636,6 +871,7 @@ static void cmd_link_mon_help(struct cmdl *cmdl)
 		"COMMANDS\n"
 		" set			- Set monitor properties\n"
 		" get			- Get monitor properties\n"
+		" list			- List all cluster members\n"
 		" summary		- Show local node monitor summary\n",
 		cmdl->argv[0]);
 }
@@ -646,6 +882,7 @@ static int cmd_link_mon(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl
 	const struct cmd cmds[] = {
 		{ "set",	cmd_link_mon_set,	cmd_link_mon_set_help },
 		{ "get",	cmd_link_mon_get,	cmd_link_mon_get_help },
+		{ "list",	cmd_link_mon_list,	cmd_link_mon_list_help },
 		{ "summary",	cmd_link_mon_summary,	NULL },
 		{ NULL }
 	};
-- 
2.1.4


------------------------------------------------------------------------------
