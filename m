From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH iproute2 1/2] tipc: introduce bearer add
	for remoteip
Date: Tue, 30 Aug 2016 10:36:59 +0200
Message-ID: <1472546220-23259-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Introduce the ability to add remote IP addresses to an existing UDP
bearer. On the kernel side, adding a "remoteip" to an existing bearer
puts the bearer in "replicast" mode where TIPC multicast messages are
send out to each configured remoteip using unicast. This is required
for TIPC UDP bearers to work in environments where IP multicast is
disabled.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
---
 man/man8/tipc-bearer.8 |  24 ++++++++++
 tipc/bearer.c          | 125 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 149 insertions(+)

diff --git a/man/man8/tipc-bearer.8 b/man/man8/tipc-bearer.8
index 488305a..32be64d 100644
--- a/man/man8/tipc-bearer.8
+++ b/man/man8/tipc-bearer.8
@@ -11,6 +11,11 @@ tipc-bearer \- show or modify TIPC bearers
 .in +8
 
 .ti -8
+.B tipc bearer add media udp name
+.IB "NAME " "remoteip " REMOTEIP
+.br
+
+.ti -8
 .B tipc bearer enable
 .RB "[ " domain
 .IR DOMAIN " ]"
@@ -196,6 +201,25 @@ IP is specified the
 .B udp
 bearer runs in point-to-point mode.
 
+Multiple
+.B remoteip
+addresses can be added via the
+.B bearer add
+command. Adding one or more unicast
+.B remoteip
+addresses to an existing
+.B udp
+bearer puts the bearer in replicast mode where IP
+multicast is emulated by sending multiple unicast messages to each configured
+.B remoteip.
+When a peer sees a TIPC discovery message from an unknown peer the peer address
+is automatically added to the
+.B remoteip
+(replicast) list, thus only one side of
+a link needs to be manually configured. A
+.B remoteip
+address cannot be added to a multicast bearer.
+
 .TP
 .BI "remoteport " REMOTEPORT
 .br
diff --git a/tipc/bearer.c b/tipc/bearer.c
index 05dabe6..a9fc1d2 100644
--- a/tipc/bearer.c
+++ b/tipc/bearer.c
@@ -222,6 +222,129 @@ static int nl_add_bearer_name(struct nlmsghdr *nlh, const struct cmd *cmd,
 	return -EINVAL;
 }
 
+static void cmd_bearer_add_udp_help(struct cmdl *cmdl, char *media)
+{
+	fprintf(stderr, "Usage: %s bearer add media %s name NAME remoteip REMOTEIP\n\n",
+		cmdl->argv[0], media);
+}
+
+static void cmd_bearer_add_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s bearer add media udp name NAME remoteip REMOTEIP\n",
+		cmdl->argv[0]);
+}
+
+static int udp_bearer_add(struct nlmsghdr *nlh, struct opt *opts,
+			  struct cmdl *cmdl)
+{
+	int err;
+	struct opt *opt;
+	struct nlattr *opts_nest;
+	char *remport = "6118";
+
+	opts_nest = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER_UDP_OPTS);
+
+	if ((opt = get_opt(opts, "remoteport")))
+		remport = opt->val;
+
+	if ((opt = get_opt(opts, "remoteip"))) {
+		char *ip = opt->val;
+		struct addrinfo *addr = NULL;
+		struct addrinfo hints = {
+			.ai_family = AF_UNSPEC,
+			.ai_socktype = SOCK_DGRAM
+		};
+
+		if ((err = getaddrinfo(ip, remport, &hints, &addr))) {
+			fprintf(stderr, "UDP address error: %s\n",
+					gai_strerror(err));
+			freeaddrinfo(addr);
+			return err;
+		}
+
+		mnl_attr_put(nlh, TIPC_NLA_UDP_REMOTE, addr->ai_addrlen,
+				addr->ai_addr);
+		freeaddrinfo(addr);
+	} else {
+		fprintf(stderr, "error, missing remoteip\n");
+		return -EINVAL;
+	}
+	mnl_attr_nest_end(nlh, opts_nest);
+
+	return 0;
+}
+
+static int cmd_bearer_add_media(struct nlmsghdr *nlh, const struct cmd *cmd,
+				struct cmdl *cmdl, void *data)
+{
+	int err;
+	char *media;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct opt *opt;
+	struct nlattr *attrs;
+	struct opt opts[] = {
+		{ "remoteip",		NULL },
+		{ "remoteport",		NULL },
+		{ "name",		NULL },
+		{ "media",		NULL },
+		{ NULL }
+	};
+	struct tipc_sup_media sup_media[] = {
+		{ "udp",	"name",		cmd_bearer_add_udp_help},
+		{ NULL, },
+	};
+
+	/* Rewind optind to include media in the option list */
+	cmdl->optind--;
+	if (parse_opts(opts, cmdl) < 0)
+		return -EINVAL;
+
+	if (!(opt = get_opt(opts, "media"))) {
+		fprintf(stderr, "error, missing media value\n");
+		return -EINVAL;
+	}
+	media = opt->val;
+
+	if (strcmp(media, "udp") != 0) {
+		fprintf(stderr, "error, no \"%s\" media specific options available\n",
+			media);
+		return -EINVAL;
+	}
+	if (!(opt = get_opt(opts, "name"))) {
+		fprintf(stderr, "error, missing media name\n");
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_BEARER_ADD))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	attrs = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER);
+	err = nl_add_bearer_name(nlh, cmd, cmdl, opts, sup_media);
+	if (err)
+		return err;
+
+	err = udp_bearer_add(nlh, opts, cmdl);
+	if (err)
+		return err;
+
+	mnl_attr_nest_end(nlh, attrs);
+
+	return msg_doit(nlh, NULL, NULL);
+}
+
+static int cmd_bearer_add(struct nlmsghdr *nlh, const struct cmd *cmd,
+			  struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "media",	cmd_bearer_add_media,	cmd_bearer_add_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
 static void cmd_bearer_enable_help(struct cmdl *cmdl)
 {
 	fprintf(stderr,
@@ -605,6 +728,7 @@ void cmd_bearer_help(struct cmdl *cmdl)
 		"Usage: %s bearer COMMAND [ARGS] ...\n"
 		"\n"
 		"COMMANDS\n"
+		" add			- Add data to existing bearer\n"
 		" enable                - Enable a bearer\n"
 		" disable               - Disable a bearer\n"
 		" set                   - Set various bearer properties\n"
@@ -616,6 +740,7 @@ int cmd_bearer(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
 	       void *data)
 {
 	const struct cmd cmds[] = {
+		{ "add",	cmd_bearer_add,		cmd_bearer_add_help },
 		{ "disable",	cmd_bearer_disable,	cmd_bearer_disable_help },
 		{ "enable",	cmd_bearer_enable,	cmd_bearer_enable_help },
 		{ "get",	cmd_bearer_get,		cmd_bearer_get_help },
-- 
2.1.4


------------------------------------------------------------------------------
