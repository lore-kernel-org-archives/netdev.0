From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH iproute2 2/2] tipc: add the ability to get UDP bearer options
Date: Tue, 30 Aug 2016 10:37:00 +0200
Message-ID: <1472546220-23259-2-git-send-email-richard.alpe@ericsson.com>
References: <1472546220-23259-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
        Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:51477 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752548AbcH3Ihi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 04:37:38 -0400
In-Reply-To: <1472546220-23259-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this patch we introduce the ability to get UDP specific bearer
options such as remoteip, remoteport, localip and localport.

After some discussions on tipc-discussion on how to handle media
specific options we agreed to pass them after the media.

For media generic bearer options we already do:
$ tipc bearer get OPTION media MEDIA name|device NAME|DEVICE

For the UDP media specific bearer options we introduce in this path:
$ tipc bearer get media udp name NAME OPTION
such as
$ tipc bearer get media udp name NAME remoteip

This allows bash-completion to tab complete only appropriate options,
it makes more logical sense and it scales better. Even though it might
look a little different to the user.

In order to use the existing option parsing framework to do this we
add a flag (OPT_KEY) to the option parsing function.

If the UDP bearer has multiple remoteip addresses associated with it
(replicast) we handle the TIPC_NLA_UDP_MULTI_REMOTEIP flag and send
a TIPC_NL_UDP_GET_REMOTEIP query transparently to the user.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
---
 man/man8/tipc-bearer.8 |   5 +-
 tipc/bearer.c          | 272 +++++++++++++++++++++++++++++++++++++++++++------
 tipc/cmdl.c            |  15 ++-
 tipc/cmdl.h            |   7 ++
 tipc/link.c            |   8 +-
 tipc/media.c           |   4 +-
 6 files changed, 271 insertions(+), 40 deletions(-)

diff --git a/man/man8/tipc-bearer.8 b/man/man8/tipc-bearer.8
index 32be64d..d95b1e1 100644
--- a/man/man8/tipc-bearer.8
+++ b/man/man8/tipc-bearer.8
@@ -73,7 +73,7 @@ tipc-bearer \- show or modify TIPC bearers
 
 .ti -8
 .B tipc bearer get
-.RB "{ " "priority" " | " tolerance " | " window " } " media
+.RB "[ " "priority" " | " tolerance " | " window " ] " media
 .br
 .RB "{ { " eth " | " ib " } " device
 .IR "DEVICE" " }"
@@ -81,7 +81,8 @@ tipc-bearer \- show or modify TIPC bearers
 .br
 .RB "{ " udp
 .B name
-.IR NAME " }"
+.IR NAME
+.RB "[ " "localip " "| " "localport " "| " "remoteip " "| " "remoteport " "] }"
 .br
 
 .ti -8
diff --git a/tipc/bearer.c b/tipc/bearer.c
index a9fc1d2..8729dad 100644
--- a/tipc/bearer.c
+++ b/tipc/bearer.c
@@ -14,6 +14,7 @@
 #include <string.h>
 #include <netdb.h>
 #include <errno.h>
+#include <arpa/inet.h>
 
 #include <linux/tipc_netlink.h>
 #include <linux/tipc.h>
@@ -26,6 +27,15 @@
 #include "msg.h"
 #include "bearer.h"
 
+#define UDP_PROP_IP 1
+#define UDP_PROP_PORT 2
+
+struct cb_data {
+	int attr;
+	int prop;
+	struct nlmsghdr *nlh;
+};
+
 static void _print_bearer_opts(void)
 {
 	fprintf(stderr,
@@ -57,14 +67,17 @@ static void cmd_bearer_enable_l2_help(struct cmdl *cmdl, char *media)
 static void cmd_bearer_enable_udp_help(struct cmdl *cmdl, char *media)
 {
 	fprintf(stderr,
-		"Usage: %s bearer enable media %s name NAME localip IP [OPTIONS]\n"
-		"\nOPTIONS\n"
+		"Usage: %s bearer enable [OPTIONS] media %s name NAME localip IP [UDP OPTIONS]\n\n",
+		cmdl->argv[0], media);
+	fprintf(stderr,
+		"OPTIONS\n"
 		" domain DOMAIN         - Discovery domain\n"
-		" priority PRIORITY     - Bearer priority\n"
+		" priority PRIORITY     - Bearer priority\n\n");
+	fprintf(stderr,
+		"UDP OPTIONS\n"
 		" localport PORT        - Local UDP port (default 6118)\n"
 		" remoteip IP           - Remote IP address\n"
-		" remoteport IP         - Remote UDP port (default 6118)\n",
-		cmdl->argv[0], media);
+		" remoteport PORT       - Remote UDP port (default 6118)\n");
 }
 
 static int get_netid_cb(const struct nlmsghdr *nlh, void *data)
@@ -283,10 +296,10 @@ static int cmd_bearer_add_media(struct nlmsghdr *nlh, const struct cmd *cmd,
 	struct opt *opt;
 	struct nlattr *attrs;
 	struct opt opts[] = {
-		{ "remoteip",		NULL },
-		{ "remoteport",		NULL },
-		{ "name",		NULL },
-		{ "media",		NULL },
+		{ "remoteip",		OPT_KEYVAL,	NULL },
+		{ "remoteport",		OPT_KEYVAL,	NULL },
+		{ "name",		OPT_KEYVAL,	NULL },
+		{ "media",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
@@ -364,15 +377,15 @@ static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
 	struct nlattr *nest;
 	char buf[MNL_SOCKET_BUFFER_SIZE];
 	struct opt opts[] = {
-		{ "device",		NULL },
-		{ "domain",		NULL },
-		{ "localip",		NULL },
-		{ "localport",		NULL },
-		{ "media",		NULL },
-		{ "name",		NULL },
-		{ "priority",		NULL },
-		{ "remoteip",		NULL },
-		{ "remoteport",		NULL },
+		{ "device",		OPT_KEYVAL,	NULL },
+		{ "domain",		OPT_KEYVAL,	NULL },
+		{ "localip",		OPT_KEYVAL,	NULL },
+		{ "localport",		OPT_KEYVAL,	NULL },
+		{ "media",		OPT_KEYVAL,	NULL },
+		{ "name",		OPT_KEYVAL,	NULL },
+		{ "priority",		OPT_KEYVAL,	NULL },
+		{ "remoteip",		OPT_KEYVAL,	NULL },
+		{ "remoteport",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
@@ -446,9 +459,9 @@ static int cmd_bearer_disable(struct nlmsghdr *nlh, const struct cmd *cmd,
 	char buf[MNL_SOCKET_BUFFER_SIZE];
 	struct nlattr *nest;
 	struct opt opts[] = {
-		{ "device",		NULL },
-		{ "name",		NULL },
-		{ "media",		NULL },
+		{ "device",		OPT_KEYVAL,	NULL },
+		{ "name",		OPT_KEYVAL,	NULL },
+		{ "media",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
@@ -512,9 +525,9 @@ static int cmd_bearer_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	struct nlattr *props;
 	struct nlattr *attrs;
 	struct opt opts[] = {
-		{ "device",		NULL },
-		{ "media",		NULL },
-		{ "name",		NULL },
+		{ "device",		OPT_KEYVAL,	NULL },
+		{ "media",		OPT_KEYVAL,	NULL },
+		{ "name",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
@@ -576,7 +589,7 @@ static int cmd_bearer_set(struct nlmsghdr *nlh, const struct cmd *cmd,
 
 static void cmd_bearer_get_help(struct cmdl *cmdl)
 {
-	fprintf(stderr, "Usage: %s bearer get OPTION media MEDIA ARGS...\n",
+	fprintf(stderr, "Usage: %s bearer get [OPTION] media MEDIA ARGS...\n",
 		cmdl->argv[0]);
 	_print_bearer_opts();
 	_print_bearer_media();
@@ -584,8 +597,14 @@ static void cmd_bearer_get_help(struct cmdl *cmdl)
 
 static void cmd_bearer_get_udp_help(struct cmdl *cmdl, char *media)
 {
-	fprintf(stderr, "Usage: %s bearer get OPTION media %s name NAME\n\n",
+	fprintf(stderr, "Usage: %s bearer get [OPTION] media %s name NAME [UDP OPTIONS]\n\n",
 		cmdl->argv[0], media);
+	fprintf(stderr,
+		"UDP OPTIONS\n"
+		" remoteip              - Remote ip address\n"
+		" remoteport            - Remote port\n"
+		" localip               - Local ip address\n"
+		" localport             - Local port\n\n");
 	_print_bearer_opts();
 }
 
@@ -597,6 +616,115 @@ static void cmd_bearer_get_l2_help(struct cmdl *cmdl, char *media)
 	_print_bearer_opts();
 }
 
+
+static int bearer_dump_udp_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct sockaddr_storage *addr;
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_UDP_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+
+	if (!info[TIPC_NLA_UDP_REMOTE])
+		return MNL_CB_ERROR;
+
+	addr = mnl_attr_get_payload(info[TIPC_NLA_UDP_REMOTE]);
+
+	if (addr->ss_family == AF_INET) {
+		struct sockaddr_in *ipv4 = (struct sockaddr_in *) addr;
+
+		printf("%s\n", inet_ntoa(ipv4->sin_addr));
+	} else if (addr->ss_family == AF_INET6) {
+		char straddr[INET6_ADDRSTRLEN];
+		struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *) addr;
+
+		if (!inet_ntop(AF_INET6, &ipv6->sin6_addr, straddr,
+					sizeof(straddr))) {
+			fprintf(stderr, "error, parsing IPv6 addr\n");
+			return MNL_CB_ERROR;
+		}
+		printf("%s\n", straddr);
+
+	} else {
+		return MNL_CB_ERROR;
+	}
+
+	return MNL_CB_OK;
+}
+
+static int bearer_get_udp_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct cb_data *cb_data = (struct cb_data *) data;
+	struct sockaddr_storage *addr;
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1] = {};
+	struct nlattr *opts[TIPC_NLA_UDP_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_BEARER])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_BEARER], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_BEARER_UDP_OPTS])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(attrs[TIPC_NLA_BEARER_UDP_OPTS], parse_attrs, opts);
+	if (!opts[TIPC_NLA_UDP_LOCAL])
+		return MNL_CB_ERROR;
+
+	if ((cb_data->attr == TIPC_NLA_UDP_REMOTE) &&
+	    (cb_data->prop == UDP_PROP_IP) &&
+	    opts[TIPC_NLA_UDP_MULTI_REMOTEIP]) {
+		struct genlmsghdr *genl = mnl_nlmsg_get_payload(cb_data->nlh);
+
+		genl->cmd = TIPC_NL_UDP_GET_REMOTEIP;
+		return msg_dumpit(cb_data->nlh, bearer_dump_udp_cb, NULL);
+	}
+
+	addr = mnl_attr_get_payload(opts[cb_data->attr]);
+
+	if (addr->ss_family == AF_INET) {
+		struct sockaddr_in *ipv4 = (struct sockaddr_in *) addr;
+
+		switch (cb_data->prop) {
+		case UDP_PROP_IP:
+			printf("%s\n", inet_ntoa(ipv4->sin_addr));
+			break;
+		case UDP_PROP_PORT:
+			printf("%u\n", ntohs(ipv4->sin_port));
+			break;
+		default:
+			return MNL_CB_ERROR;
+		}
+
+	} else if (addr->ss_family == AF_INET6) {
+		char straddr[INET6_ADDRSTRLEN];
+		struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *) addr;
+
+		switch (cb_data->prop) {
+		case UDP_PROP_IP:
+			if (!inet_ntop(AF_INET6, &ipv6->sin6_addr, straddr,
+						sizeof(straddr))) {
+				fprintf(stderr, "error, parsing IPv6 addr\n");
+				return MNL_CB_ERROR;
+			}
+			printf("%s\n", straddr);
+			break;
+		case UDP_PROP_PORT:
+			printf("%u\n", ntohs(ipv6->sin6_port));
+			break;
+		default:
+			return MNL_CB_ERROR;
+		}
+
+	} else {
+		return MNL_CB_ERROR;
+	}
+
+	return MNL_CB_OK;
+}
+
 static int bearer_get_cb(const struct nlmsghdr *nlh, void *data)
 {
 	int *prop = data;
@@ -622,6 +750,86 @@ static int bearer_get_cb(const struct nlmsghdr *nlh, void *data)
 	return MNL_CB_OK;
 }
 
+static int cmd_bearer_get_media(struct nlmsghdr *nlh, const struct cmd *cmd,
+				struct cmdl *cmdl, void *data)
+{
+	int err;
+	char *media;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct opt *opt;
+	struct cb_data cb_data = {0};
+	struct nlattr *attrs;
+	struct opt opts[] = {
+		{ "localip",		OPT_KEY,	NULL },
+		{ "localport",		OPT_KEY,	NULL },
+		{ "remoteip",		OPT_KEY,	NULL },
+		{ "remoteport",		OPT_KEY,	NULL },
+		{ "name",		OPT_KEYVAL,	NULL },
+		{ "media",		OPT_KEYVAL,	NULL },
+		{ NULL }
+	};
+	struct tipc_sup_media sup_media[] = {
+		{ "udp",	"name",		cmd_bearer_get_udp_help},
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
+	if (help_flag) {
+		cmd_bearer_get_udp_help(cmdl, media);
+		return -EINVAL;
+	}
+	if (strcmp(media, "udp") != 0) {
+		fprintf(stderr, "error, no \"%s\" media specific options\n", media);
+		return -EINVAL;
+	}
+	if (!(opt = get_opt(opts, "name"))) {
+		fprintf(stderr, "error, missing media name\n");
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_BEARER_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	attrs = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER);
+	err = nl_add_bearer_name(nlh, cmd, cmdl, opts, sup_media);
+	if (err)
+		return err;
+	mnl_attr_nest_end(nlh, attrs);
+	cb_data.nlh = nlh;
+
+	if (has_opt(opts, "localip")) {
+		cb_data.attr = TIPC_NLA_UDP_LOCAL;
+		cb_data.prop = UDP_PROP_IP;
+		return msg_doit(nlh, bearer_get_udp_cb, &cb_data);
+	} else if (has_opt(opts, "localport")) {
+		cb_data.attr = TIPC_NLA_UDP_LOCAL;
+		cb_data.prop = UDP_PROP_PORT;
+		return msg_doit(nlh, bearer_get_udp_cb, &cb_data);
+	} else if (has_opt(opts, "remoteip")) {
+		cb_data.attr = TIPC_NLA_UDP_REMOTE;
+		cb_data.prop = UDP_PROP_IP;
+		return msg_doit(nlh, bearer_get_udp_cb, &cb_data);
+	} else if (has_opt(opts, "remoteport")) {
+		cb_data.attr = TIPC_NLA_UDP_REMOTE;
+		cb_data.prop = UDP_PROP_PORT;
+		return msg_doit(nlh, bearer_get_udp_cb, &cb_data);
+	}
+	fprintf(stderr, "error, missing UDP option\n");
+	return -EINVAL;
+}
+
 static int cmd_bearer_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 			       struct cmdl *cmdl, void *data)
 {
@@ -630,9 +838,9 @@ static int cmd_bearer_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	char buf[MNL_SOCKET_BUFFER_SIZE];
 	struct nlattr *attrs;
 	struct opt opts[] = {
-		{ "device",		NULL },
-		{ "media",		NULL },
-		{ "name",		NULL },
+		{ "device",		OPT_KEYVAL,	NULL },
+		{ "media",		OPT_KEYVAL,	NULL },
+		{ "name",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
@@ -642,6 +850,11 @@ static int cmd_bearer_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ NULL, },
 	};
 
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
 	if (strcmp(cmd->cmd, "priority") == 0)
 		prop = TIPC_NLA_PROP_PRIO;
 	else if ((strcmp(cmd->cmd, "tolerance") == 0))
@@ -675,6 +888,7 @@ static int cmd_bearer_get(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ "priority",	cmd_bearer_get_prop,	cmd_bearer_get_help },
 		{ "tolerance",	cmd_bearer_get_prop,	cmd_bearer_get_help },
 		{ "window",	cmd_bearer_get_prop,	cmd_bearer_get_help },
+		{ "media",	cmd_bearer_get_media,	cmd_bearer_get_help },
 		{ NULL }
 	};
 
diff --git a/tipc/cmdl.c b/tipc/cmdl.c
index b816f7d..4a2f4fd 100644
--- a/tipc/cmdl.c
+++ b/tipc/cmdl.c
@@ -62,6 +62,11 @@ struct opt *get_opt(struct opt *opts, char *key)
 	return NULL;
 }
 
+bool has_opt(struct opt *opts, char *key)
+{
+	return get_opt(opts, key) ? true : false;
+}
+
 char *shift_cmdl(struct cmdl *cmdl)
 {
 	int next;
@@ -80,7 +85,7 @@ int parse_opts(struct opt *opts, struct cmdl *cmdl)
 	int i;
 	int cnt = 0;
 
-	for (i = cmdl->optind; i < cmdl->argc; i += 2) {
+	for (i = cmdl->optind; i < cmdl->argc; i++) {
 		struct opt *o;
 
 		o = find_opt(opts, cmdl->argv[i]);
@@ -89,9 +94,13 @@ int parse_opts(struct opt *opts, struct cmdl *cmdl)
 					cmdl->argv[i]);
 			return -EINVAL;
 		}
+		if (o->flag & OPT_KEYVAL) {
+			cmdl->optind++;
+			i++;
+		}
 		cnt++;
-		o->val = cmdl->argv[i + 1];
-		cmdl->optind += 2;
+		o->val = cmdl->argv[i];
+		cmdl->optind++;
 	}
 
 	return cnt;
diff --git a/tipc/cmdl.h b/tipc/cmdl.h
index d4795cf..d37239f 100644
--- a/tipc/cmdl.h
+++ b/tipc/cmdl.h
@@ -16,6 +16,11 @@
 
 extern int help_flag;
 
+enum {
+	OPT_KEY			= (1 << 0),
+	OPT_KEYVAL		= (1 << 1),
+};
+
 struct cmdl {
 	int optind;
 	int argc;
@@ -37,10 +42,12 @@ struct cmd {
 
 struct opt {
 	const char *key;
+	uint16_t flag;
 	char *val;
 };
 
 struct opt *get_opt(struct opt *opts, char *key);
+bool has_opt(struct opt *opts, char *key);
 int parse_opts(struct opt *opts, struct cmdl *cmdl);
 char *shift_cmdl(struct cmdl *cmdl);
 
diff --git a/tipc/link.c b/tipc/link.c
index 89fb4ff..061b1c5 100644
--- a/tipc/link.c
+++ b/tipc/link.c
@@ -98,7 +98,7 @@ static int cmd_link_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	char buf[MNL_SOCKET_BUFFER_SIZE];
 	struct opt *opt;
 	struct opt opts[] = {
-		{ "link",		NULL },
+		{ "link",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 
@@ -169,7 +169,7 @@ static int cmd_link_stat_reset(struct nlmsghdr *nlh, const struct cmd *cmd,
 	struct opt *opt;
 	struct nlattr *nest;
 	struct opt opts[] = {
-		{ "link",		NULL },
+		{ "link",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 
@@ -365,7 +365,7 @@ static int cmd_link_stat_show(struct nlmsghdr *nlh, const struct cmd *cmd,
 	char buf[MNL_SOCKET_BUFFER_SIZE];
 	struct opt *opt;
 	struct opt opts[] = {
-		{ "link",		NULL },
+		{ "link",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 
@@ -429,7 +429,7 @@ static int cmd_link_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	struct nlattr *attrs;
 	struct opt *opt;
 	struct opt opts[] = {
-		{ "link",	NULL },
+		{ "link",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 
diff --git a/tipc/media.c b/tipc/media.c
index a902ab7..6e10c7e 100644
--- a/tipc/media.c
+++ b/tipc/media.c
@@ -93,7 +93,7 @@ static int cmd_media_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	struct nlattr *nest;
 	struct opt *opt;
 	struct opt opts[] = {
-		{ "media",		NULL },
+		{ "media",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 
@@ -173,7 +173,7 @@ static int cmd_media_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	struct nlattr *attrs;
 	struct opt *opt;
 	struct opt opts[] = {
-		{ "media",		NULL },
+		{ "media",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
 
-- 
2.1.4
