From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH iproute2 2/2] tipc: refactor bearer
	identification
Date: Tue, 9 Aug 2016 10:34:30 +0200
Message-ID: <1470731670-12723-2-git-send-email-richard.alpe@ericsson.com>
References: <1470731670-12723-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1470731670-12723-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Introduce a generic function (nl_add_bearer_name()) that identifies a
bearer and adds it to an existing netlink message. This reduces code
complexity and makes the code a little bit easier to maintain.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
---
 tipc/bearer.c | 312 ++++++++++++++++++++--------------------------------------
 tipc/cmdl.h   |   6 ++
 2 files changed, 114 insertions(+), 204 deletions(-)

diff --git a/tipc/bearer.c b/tipc/bearer.c
index 30b54d9..018bc0d 100644
--- a/tipc/bearer.c
+++ b/tipc/bearer.c
@@ -29,7 +29,7 @@
 static void _print_bearer_opts(void)
 {
 	fprintf(stderr,
-		"\nOPTIONS\n"
+		"OPTIONS\n"
 		" priority              - Bearer link priority\n"
 		" tolerance             - Bearer link tolerance\n"
 		" window                - Bearer link window\n");
@@ -44,43 +44,27 @@ static void _print_bearer_media(void)
 		" eth                   - Ethernet\n");
 }
 
-static void cmd_bearer_enable_l2_help(struct cmdl *cmdl)
+static void cmd_bearer_enable_l2_help(struct cmdl *cmdl, char *media)
 {
 	fprintf(stderr,
-		"Usage: %s bearer enable media MEDIA device DEVICE [OPTIONS]\n"
+		"Usage: %s bearer enable media %s device DEVICE [OPTIONS]\n"
 		"\nOPTIONS\n"
 		" domain DOMAIN         - Discovery domain\n"
 		" priority PRIORITY     - Bearer priority\n",
-		cmdl->argv[0]);
+		cmdl->argv[0], media);
 }
 
-static void cmd_bearer_enable_udp_help(struct cmdl *cmdl)
+static void cmd_bearer_enable_udp_help(struct cmdl *cmdl, char *media)
 {
 	fprintf(stderr,
-		"Usage: %s bearer enable media udp name NAME localip IP [OPTIONS]\n"
+		"Usage: %s bearer enable media %s name NAME localip IP [OPTIONS]\n"
 		"\nOPTIONS\n"
 		" domain DOMAIN         - Discovery domain\n"
 		" priority PRIORITY     - Bearer priority\n"
 		" localport PORT        - Local UDP port (default 6118)\n"
 		" remoteip IP           - Remote IP address\n"
 		" remoteport IP         - Remote UDP port (default 6118)\n",
-		cmdl->argv[0]);
-}
-
-static int enable_l2_bearer(struct nlmsghdr *nlh, struct opt *opts,
-			    struct cmdl *cmdl)
-{
-	struct opt *opt;
-	char id[TIPC_MAX_BEARER_NAME];
-
-	if (!(opt = get_opt(opts, "device"))) {
-		fprintf(stderr, "error: missing bearer device\n");
-		return -EINVAL;
-	}
-	snprintf(id, sizeof(id), "eth:%s", opt->val);
-	mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, id);
-
-	return 0;
+		cmdl->argv[0], media);
 }
 
 static int get_netid_cb(const struct nlmsghdr *nlh, void *data)
@@ -123,8 +107,8 @@ static int generate_multicast(short af, char *buf, int bufsize)
 	return 0;
 }
 
-static int enable_udp_bearer(struct nlmsghdr *nlh, struct opt *opts,
-			     struct cmdl *cmdl)
+static int nl_add_udp_enable_opts(struct nlmsghdr *nlh, struct opt *opts,
+				  struct cmdl *cmdl)
 {
 	int err;
 	struct opt *opt;
@@ -134,7 +118,6 @@ static int enable_udp_bearer(struct nlmsghdr *nlh, struct opt *opts,
 	char *remport = "6118";
 	char *locip = NULL;
 	char *remip = NULL;
-	char name[TIPC_MAX_BEARER_NAME];
 	struct addrinfo *loc = NULL;
 	struct addrinfo *rem = NULL;
 	struct addrinfo hints = {
@@ -142,22 +125,9 @@ static int enable_udp_bearer(struct nlmsghdr *nlh, struct opt *opts,
 		.ai_socktype = SOCK_DGRAM
 	};
 
-	if (help_flag) {
-		cmd_bearer_enable_udp_help(cmdl);
-		/* TODO find a better error code? */
-		return -EINVAL;
-	}
-
-	if (!(opt = get_opt(opts, "name"))) {
-		fprintf(stderr, "error, udp bearer name missing\n");
-		cmd_bearer_enable_udp_help(cmdl);
-		return -EINVAL;
-	}
-	snprintf(name, sizeof(name), "udp:%s", opt->val);
-
 	if (!(opt = get_opt(opts, "localip"))) {
 		fprintf(stderr, "error, udp bearer localip missing\n");
-		cmd_bearer_enable_udp_help(cmdl);
+		cmd_bearer_enable_udp_help(cmdl, "udp");
 		return -EINVAL;
 	}
 	locip = opt->val;
@@ -197,8 +167,6 @@ static int enable_udp_bearer(struct nlmsghdr *nlh, struct opt *opts,
 		return -EINVAL;
 	}
 
-	mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, name);
-
 	nest = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER_UDP_OPTS);
 	mnl_attr_put(nlh, TIPC_NLA_UDP_LOCAL, loc->ai_addrlen, loc->ai_addr);
 	mnl_attr_put(nlh, TIPC_NLA_UDP_REMOTE, rem->ai_addrlen, rem->ai_addr);
@@ -210,6 +178,50 @@ static int enable_udp_bearer(struct nlmsghdr *nlh, struct opt *opts,
 	return 0;
 }
 
+static int nl_add_bearer_name(struct nlmsghdr *nlh, const struct cmd *cmd,
+			   struct cmdl *cmdl, struct opt *opts,
+			   struct tipc_sup_media sup_media[])
+{
+	char id[TIPC_MAX_BEARER_NAME];
+	char *media;
+	char *identifier;
+	struct opt *opt;
+	struct tipc_sup_media *entry;
+
+	if (!(opt = get_opt(opts, "media"))) {
+		if (help_flag)
+			(cmd->help)(cmdl);
+		else
+			fprintf(stderr, "error, missing bearer media\n");
+		return -EINVAL;
+	}
+	media = opt->val;
+
+	for (entry = sup_media; entry->media; entry++) {
+		if (strcmp(entry->media, media))
+			continue;
+
+		if (!(opt = get_opt(opts, entry->identifier))) {
+			if (help_flag)
+				(entry->help)(cmdl, media);
+			else
+				fprintf(stderr, "error, missing bearer %s\n",
+						entry->identifier);
+			return -EINVAL;
+		}
+
+		identifier = opt->val;
+		snprintf(id, sizeof(id), "%s:%s", media, identifier);
+		mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, id);
+
+		return 0;
+	}
+
+	fprintf(stderr, "error, invalid media type %s\n", media);
+
+	return -EINVAL;
+}
+
 static void cmd_bearer_enable_help(struct cmdl *cmdl)
 {
 	fprintf(stderr,
@@ -228,7 +240,6 @@ static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
 	struct opt *opt;
 	struct nlattr *nest;
 	char buf[MNL_SOCKET_BUFFER_SIZE];
-	char *media;
 	struct opt opts[] = {
 		{ "device",		NULL },
 		{ "domain",		NULL },
@@ -241,6 +252,12 @@ static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ "remoteport",		NULL },
 		{ NULL }
 	};
+	struct tipc_sup_media sup_media[] = {
+		{ "udp",	"name",		cmd_bearer_enable_udp_help},
+		{ "eth",	"device",	cmd_bearer_enable_l2_help },
+		{ "ib",		"device",	cmd_bearer_enable_l2_help },
+		{ NULL, },
+	};
 
 	if (parse_opts(opts, cmdl) < 0) {
 		if (help_flag)
@@ -248,15 +265,6 @@ static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
 		return -EINVAL;
 	}
 
-	if (!(opt = get_opt(opts, "media"))) {
-		if (help_flag)
-			(cmd->help)(cmdl);
-		else
-			fprintf(stderr, "error, missing bearer media\n");
-		return -EINVAL;
-	}
-	media = opt->val;
-
 	if (!(nlh = msg_init(buf, TIPC_NL_BEARER_ENABLE))) {
 		fprintf(stderr, "error: message initialisation failed\n");
 		return -1;
@@ -274,72 +282,31 @@ static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
 		mnl_attr_nest_end(nlh, props);
 	}
 
-	if (strcmp(media, "udp") == 0) {
-		if (help_flag) {
-			cmd_bearer_enable_udp_help(cmdl);
-			return -EINVAL;
-		}
-		if ((err = enable_udp_bearer(nlh, opts, cmdl)))
-			return err;
-	} else if ((strcmp(media, "eth") == 0) || (strcmp(media, "udp") == 0)) {
-		if (help_flag) {
-			cmd_bearer_enable_l2_help(cmdl);
-			return -EINVAL;
-		}
-		if ((err = enable_l2_bearer(nlh, opts, cmdl)))
+	err = nl_add_bearer_name(nlh, cmd, cmdl, opts, sup_media);
+	if (err)
+		return err;
+
+	opt = get_opt(opts, "media");
+	if (strcmp(opt->val, "udp") == 0) {
+		err = nl_add_udp_enable_opts(nlh, opts, cmdl);
+		if (err)
 			return err;
-	} else {
-		fprintf(stderr, "error, invalid media type \"%s\"\n", media);
-		return -EINVAL;
 	}
-
 	mnl_attr_nest_end(nlh, nest);
 
 	return msg_doit(nlh, NULL, NULL);
 }
 
-static int add_l2_bearer(struct nlmsghdr *nlh, struct opt *opts)
-{
-	struct opt *opt;
-	char id[TIPC_MAX_BEARER_NAME];
-
-	if (!(opt = get_opt(opts, "device"))) {
-		fprintf(stderr, "error: missing bearer device\n");
-		return -EINVAL;
-	}
-	snprintf(id, sizeof(id), "eth:%s", opt->val);
-
-	mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, id);
-
-	return 0;
-}
-
-static int add_udp_bearer(struct nlmsghdr *nlh, struct opt *opts)
-{
-	struct opt *opt;
-	char id[TIPC_MAX_BEARER_NAME];
-
-	if (!(opt = get_opt(opts, "name"))) {
-		fprintf(stderr, "error: missing bearer name\n");
-		return -EINVAL;
-	}
-	snprintf(id, sizeof(id), "udp:%s", opt->val);
-
-	mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, id);
-
-	return 0;
-}
-
-static void cmd_bearer_disable_l2_help(struct cmdl *cmdl)
+static void cmd_bearer_disable_l2_help(struct cmdl *cmdl, char *media)
 {
-	fprintf(stderr, "Usage: %s bearer disable media udp device DEVICE\n",
-		cmdl->argv[0]);
+	fprintf(stderr, "Usage: %s bearer disable media %s device DEVICE\n",
+		cmdl->argv[0], media);
 }
 
-static void cmd_bearer_disable_udp_help(struct cmdl *cmdl)
+static void cmd_bearer_disable_udp_help(struct cmdl *cmdl, char *media)
 {
-	fprintf(stderr, "Usage: %s bearer disable media udp name NAME\n",
-		cmdl->argv[0]);
+	fprintf(stderr, "Usage: %s bearer disable media %s name NAME\n",
+		cmdl->argv[0], media);
 }
 
 static void cmd_bearer_disable_help(struct cmdl *cmdl)
@@ -353,7 +320,6 @@ static int cmd_bearer_disable(struct nlmsghdr *nlh, const struct cmd *cmd,
 			      struct cmdl *cmdl, void *data)
 {
 	int err;
-	char *media;
 	char buf[MNL_SOCKET_BUFFER_SIZE];
 	struct nlattr *nest;
 	struct opt *opt;
@@ -363,6 +329,12 @@ static int cmd_bearer_disable(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ "media",		NULL },
 		{ NULL }
 	};
+	struct tipc_sup_media sup_media[] = {
+		{ "udp",	"name",		cmd_bearer_disable_udp_help},
+		{ "eth",	"device",	cmd_bearer_disable_l2_help },
+		{ "ib",		"device",	cmd_bearer_disable_l2_help },
+		{ NULL, },
+	};
 
 	if (parse_opts(opts, cmdl) < 0) {
 		if (help_flag)
@@ -370,40 +342,15 @@ static int cmd_bearer_disable(struct nlmsghdr *nlh, const struct cmd *cmd,
 		return -EINVAL;
 	}
 
-	if (!(opt = get_opt(opts, "media"))) {
-		if (help_flag)
-			(cmd->help)(cmdl);
-		else
-			fprintf(stderr, "error, missing bearer media\n");
-		return -EINVAL;
-	}
-	media = opt->val;
-
 	if (!(nlh = msg_init(buf, TIPC_NL_BEARER_DISABLE))) {
 		fprintf(stderr, "error, message initialisation failed\n");
 		return -1;
 	}
 
 	nest = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER);
-
-	if (strcmp(media, "udp") == 0) {
-		if (help_flag) {
-			cmd_bearer_disable_udp_help(cmdl);
-			return -EINVAL;
-		}
-		if ((err = add_udp_bearer(nlh, opts)))
-			return err;
-	} else if ((strcmp(media, "eth") == 0) || (strcmp(media, "udp") == 0)) {
-		if (help_flag) {
-			cmd_bearer_disable_l2_help(cmdl);
-			return -EINVAL;
-		}
-		if ((err = add_l2_bearer(nlh, opts)))
-			return err;
-	} else {
-		fprintf(stderr, "error, invalid media type \"%s\"\n", media);
-		return -EINVAL;
-	}
+	err = nl_add_bearer_name(nlh, cmd, cmdl, opts, sup_media);
+	if (err)
+		return err;
 	mnl_attr_nest_end(nlh, nest);
 
 	return msg_doit(nlh, NULL, NULL);
@@ -418,10 +365,10 @@ static void cmd_bearer_set_help(struct cmdl *cmdl)
 	_print_bearer_media();
 }
 
-static void cmd_bearer_set_udp_help(struct cmdl *cmdl)
+static void cmd_bearer_set_udp_help(struct cmdl *cmdl, char *media)
 {
-	fprintf(stderr, "Usage: %s bearer set OPTION media udp name NAME\n\n",
-		cmdl->argv[0]);
+	fprintf(stderr, "Usage: %s bearer set OPTION media %s name NAME\n\n",
+		cmdl->argv[0], media);
 	_print_bearer_opts();
 }
 
@@ -439,17 +386,21 @@ static int cmd_bearer_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	int err;
 	int val;
 	int prop;
-	char *media;
 	char buf[MNL_SOCKET_BUFFER_SIZE];
 	struct nlattr *props;
 	struct nlattr *attrs;
-	struct opt *opt;
 	struct opt opts[] = {
 		{ "device",		NULL },
 		{ "media",		NULL },
 		{ "name",		NULL },
 		{ NULL }
 	};
+	struct tipc_sup_media sup_media[] = {
+		{ "udp",	"name",		cmd_bearer_set_udp_help},
+		{ "eth",	"device",	cmd_bearer_set_l2_help },
+		{ "ib",		"device",	cmd_bearer_set_l2_help },
+		{ NULL, },
+	};
 
 	if (strcmp(cmd->cmd, "priority") == 0)
 		prop = TIPC_NLA_PROP_PRIO;
@@ -460,11 +411,6 @@ static int cmd_bearer_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	else
 		return -EINVAL;
 
-	if (help_flag) {
-		(cmd->help)(cmdl);
-		return -EINVAL;
-	}
-
 	if (cmdl->optind >= cmdl->argc) {
 		fprintf(stderr, "error, missing value\n");
 		return -EINVAL;
@@ -484,30 +430,10 @@ static int cmd_bearer_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	mnl_attr_put_u32(nlh, prop, val);
 	mnl_attr_nest_end(nlh, props);
 
-	if (!(opt = get_opt(opts, "media"))) {
-		fprintf(stderr, "error, missing media\n");
-		return -EINVAL;
-	}
-	media = opt->val;
+	err = nl_add_bearer_name(nlh, cmd, cmdl, opts, sup_media);
+	if (err)
+		return err;
 
-	if (strcmp(media, "udp") == 0) {
-		if (help_flag) {
-			cmd_bearer_set_udp_help(cmdl);
-			return -EINVAL;
-		}
-		if ((err = add_udp_bearer(nlh, opts)))
-			return err;
-	} else if ((strcmp(media, "eth") == 0) || (strcmp(media, "udp") == 0)) {
-		if (help_flag) {
-			cmd_bearer_set_l2_help(cmdl, media);
-			return -EINVAL;
-		}
-		if ((err = add_l2_bearer(nlh, opts)))
-			return err;
-	} else {
-		fprintf(stderr, "error, invalid media type \"%s\"\n", media);
-		return -EINVAL;
-	}
 	mnl_attr_nest_end(nlh, attrs);
 
 	return msg_doit(nlh, NULL, NULL);
@@ -534,17 +460,17 @@ static void cmd_bearer_get_help(struct cmdl *cmdl)
 	_print_bearer_media();
 }
 
-static void cmd_bearer_get_udp_help(struct cmdl *cmdl)
+static void cmd_bearer_get_udp_help(struct cmdl *cmdl, char *media)
 {
-	fprintf(stderr, "Usage: %s bearer get OPTION media udp name NAME\n\n",
-		cmdl->argv[0]);
+	fprintf(stderr, "Usage: %s bearer get OPTION media %s name NAME\n\n",
+		cmdl->argv[0], media);
 	_print_bearer_opts();
 }
 
 static void cmd_bearer_get_l2_help(struct cmdl *cmdl, char *media)
 {
 	fprintf(stderr,
-		"Usage: %s bearer get [OPTION]... media %s device DEVICE\n",
+		"Usage: %s bearer get OPTION media %s device DEVICE\n",
 		cmdl->argv[0], media);
 	_print_bearer_opts();
 }
@@ -579,16 +505,20 @@ static int cmd_bearer_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 {
 	int err;
 	int prop;
-	char *media;
 	char buf[MNL_SOCKET_BUFFER_SIZE];
 	struct nlattr *attrs;
-	struct opt *opt;
 	struct opt opts[] = {
 		{ "device",		NULL },
 		{ "media",		NULL },
 		{ "name",		NULL },
 		{ NULL }
 	};
+	struct tipc_sup_media sup_media[] = {
+		{ "udp",	"name",		cmd_bearer_get_udp_help},
+		{ "eth",	"device",	cmd_bearer_get_l2_help },
+		{ "ib",		"device",	cmd_bearer_get_l2_help },
+		{ NULL, },
+	};
 
 	if (strcmp(cmd->cmd, "priority") == 0)
 		prop = TIPC_NLA_PROP_PRIO;
@@ -599,11 +529,6 @@ static int cmd_bearer_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	else
 		return -EINVAL;
 
-	if (help_flag) {
-		(cmd->help)(cmdl);
-		return -EINVAL;
-	}
-
 	if (parse_opts(opts, cmdl) < 0)
 		return -EINVAL;
 
@@ -612,31 +537,10 @@ static int cmd_bearer_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 		return -1;
 	}
 
-	if (!(opt = get_opt(opts, "media"))) {
-		fprintf(stderr, "error, missing media\n");
-		return -EINVAL;
-	}
-	media = opt->val;
-
 	attrs = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER);
-	if (strcmp(media, "udp") == 0) {
-		if (help_flag) {
-			cmd_bearer_get_udp_help(cmdl);
-			return -EINVAL;
-		}
-		if ((err = add_udp_bearer(nlh, opts)))
-			return err;
-	} else if ((strcmp(media, "eth") == 0) || (strcmp(media, "udp") == 0)) {
-		if (help_flag) {
-			cmd_bearer_get_l2_help(cmdl, media);
-			return -EINVAL;
-		}
-		if ((err = add_l2_bearer(nlh, opts)))
-			return err;
-	} else {
-		fprintf(stderr, "error, invalid media type \"%s\"\n", media);
-		return -EINVAL;
-	}
+	err = nl_add_bearer_name(nlh, cmd, cmdl, opts, sup_media);
+	if (err)
+		return err;
 	mnl_attr_nest_end(nlh, attrs);
 
 	return msg_doit(nlh, bearer_get_cb, &prop);
diff --git a/tipc/cmdl.h b/tipc/cmdl.h
index 9f2666f..d4795cf 100644
--- a/tipc/cmdl.h
+++ b/tipc/cmdl.h
@@ -22,6 +22,12 @@ struct cmdl {
 	char **argv;
 };
 
+struct tipc_sup_media {
+	char *media;
+	char *identifier;
+	void (*help)(struct cmdl *cmdl, char *media);
+};
+
 struct cmd {
 	const char *cmd;
 	int (*func)(struct nlmsghdr *nlh, const struct cmd *cmd,
-- 
2.1.4


------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity 
planning reports. http://sdm.link/zohodev2dev
