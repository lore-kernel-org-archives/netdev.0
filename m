From: <richard.alpe@ericsson.com>
Subject: [PATCH iproute2] tipc: add new TIPC configuration tool
Date: Thu, 7 May 2015 15:07:36 +0200
Message-ID: <1431004056-6282-2-git-send-email-richard.alpe@ericsson.com>
References: <1431004056-6282-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:59974 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbEGNLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 09:11:35 -0400
In-Reply-To: <1431004056-6282-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

tipc is a user-space configuration tool for TIPC (Transparent
Inter-process Communication). It utilizes the TIPC netlink API in the
kernel to fetch data or perform actions.

The tipc tool has somewhat similar syntax to the ip tool meaning that
users of the ip tool should not feel that unfamiliar with this tool.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 Makefile         |   2 +-
 tipc/.gitignore  |   1 +
 tipc/Makefile    |  19 ++
 tipc/README      |  63 +++++
 tipc/bearer.c    | 725 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tipc/bearer.h    |  22 ++
 tipc/cmdl.c      | 127 ++++++++++
 tipc/cmdl.h      |  46 ++++
 tipc/link.c      | 520 +++++++++++++++++++++++++++++++++++++++
 tipc/link.h      |  21 ++
 tipc/media.c     | 260 ++++++++++++++++++++
 tipc/media.h     |  21 ++
 tipc/misc.c      |  35 +++
 tipc/misc.h      |  19 ++
 tipc/msg.c       | 170 +++++++++++++
 tipc/msg.h       |  20 ++
 tipc/nametable.c | 109 +++++++++
 tipc/nametable.h |  21 ++
 tipc/node.c      | 267 ++++++++++++++++++++
 tipc/node.h      |  21 ++
 tipc/socket.c    | 140 +++++++++++
 tipc/socket.h    |  21 ++
 tipc/tipc.c      |  96 ++++++++
 23 files changed, 2745 insertions(+), 1 deletion(-)
 create mode 100644 tipc/.gitignore
 create mode 100644 tipc/Makefile
 create mode 100644 tipc/README
 create mode 100644 tipc/bearer.c
 create mode 100644 tipc/bearer.h
 create mode 100644 tipc/cmdl.c
 create mode 100644 tipc/cmdl.h
 create mode 100644 tipc/link.c
 create mode 100644 tipc/link.h
 create mode 100644 tipc/media.c
 create mode 100644 tipc/media.h
 create mode 100644 tipc/misc.c
 create mode 100644 tipc/misc.h
 create mode 100644 tipc/msg.c
 create mode 100644 tipc/msg.h
 create mode 100644 tipc/nametable.c
 create mode 100644 tipc/nametable.h
 create mode 100644 tipc/node.c
 create mode 100644 tipc/node.h
 create mode 100644 tipc/socket.c
 create mode 100644 tipc/socket.h
 create mode 100644 tipc/tipc.c

diff --git a/Makefile b/Makefile
index b794f08..2e91c32 100644
--- a/Makefile
+++ b/Makefile
@@ -39,7 +39,7 @@ WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
 CFLAGS := $(WFLAGS) $(CCOPTS) -I../include $(DEFINES) $(CFLAGS)
 YACCFLAGS = -d -t -v
 
-SUBDIRS=lib ip tc bridge misc netem genl man
+SUBDIRS=lib ip tc bridge misc netem genl tipc man
 
 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
 LDLIBS += $(LIBNETLINK)
diff --git a/tipc/.gitignore b/tipc/.gitignore
new file mode 100644
index 0000000..39ed83d
--- /dev/null
+++ b/tipc/.gitignore
@@ -0,0 +1 @@
+tipc
diff --git a/tipc/Makefile b/tipc/Makefile
new file mode 100644
index 0000000..4bda8c5
--- /dev/null
+++ b/tipc/Makefile
@@ -0,0 +1,19 @@
+TIPCOBJ=bearer.o \
+    cmdl.o link.o \
+    media.o misc.o \
+    msg.o nametable.o \
+    node.o socket.o \
+    tipc.o
+
+TARGETS=tipc
+LDLIBS += -lmnl
+
+all: $(TARGETS) $(LIBS)
+
+tipc: $(TIPCOBJ)
+
+install: all
+	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
+
+clean:
+	rm -f $(TIPCOBJ) $(TARGETS)
diff --git a/tipc/README b/tipc/README
new file mode 100644
index 0000000..578a0b7
--- /dev/null
+++ b/tipc/README
@@ -0,0 +1,63 @@
+DESIGN DECISIONS
+----------------
+
+HELP
+~~~~
+--help or -h is used for help. We do not reserve the bare word "help", which
+for example the ip command does. Reserving a bare word like help quickly
+becomes cumbersome to handle in the code. It might be simple to handle
+when it's passed early in the command chain like "ip addr help". But when
+the user tries to pass "help" further down this requires manual checks and
+special treatment. For example, at the time of writing this tool, it's
+possible to create a vlan named "help" with the ip tool, but it's impossible
+to remove it, the command just shows help. This is an effect of treating
+bare words specially.
+
+Help texts are not dynamically generated. That is, we do not pass datastructures
+like command list or option lists and print them dynamically. This is
+intentional. There is always that exception and when it comes to help texts
+these exceptions are normally neglected at the expence of usability.
+
+KEY-VALUE
+~~~~~~~~~
+All options are key-values. There are both drawbacks and benefits to this.
+The main drawback is that it becomes more to write for the user and
+information might seem redundant. The main benefits is scalability and code
+simplification. Consistency is important.
+
+Consider this.
+1. tipc link set priority PRIO link LINK
+2. tipc link set LINK priority PRIO
+
+Link might seem redundant in (1). However, if the command should live for many
+years and be able to evolve example (2) limits the set command to only work on a
+single link with no ability to extend. As an example, lets say we introduce
+grouping on the kernel side.
+
+1. tipc link set priority PRIO group GROUP
+2. tipc link set ??? priority PRIO group GROUP
+
+2. breaks, we can't extend the command to cover a group.
+
+PARSING
+~~~~~~~
+Commands are single words. As an example, all words in "tipc link list" are
+commands. Options are key-values that can be given in any order. In
+"tipc link set priority PRIO link LINK" "tipc link set" are commands while
+priority and link are options. Meaning that they can be given like
+"tipc link set link LINK priority PRIO".
+
+Abbreviation matching works for both command and options. Meaning that
+"tipc link set priority PRIO link LINK" could be given as
+"tipc l s p PRIO l LINK" and "tipc link list" as "tipc l l".
+
+MEMORY
+~~~~~~
+The tool strives to avoid allocating memory on the heap. Most (if not all)
+memory allocations are on the stack.
+
+RETURNING
+~~~~~~~~~
+The tool could throw exit() deep down in functions but doing so always seems
+to limit the program in the long run. So we output the error and return an
+appropriate error code upon failure.
diff --git a/tipc/bearer.c b/tipc/bearer.c
new file mode 100644
index 0000000..33295f9
--- /dev/null
+++ b/tipc/bearer.c
@@ -0,0 +1,725 @@
+/*
+ * bearer.c	TIPC bearer functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <netdb.h>
+#include <errno.h>
+
+#include <linux/tipc_netlink.h>
+#include <linux/tipc.h>
+#include <linux/genetlink.h>
+
+#include <libmnl/libmnl.h>
+#include <sys/socket.h>
+
+#include "cmdl.h"
+#include "msg.h"
+#include "bearer.h"
+
+static void _print_bearer_opts(void)
+{
+	fprintf(stderr,
+		"\nOPTIONS\n"
+		" priority              - Bearer link priority\n"
+		" tolerance             - Bearer link tolerance\n"
+		" window                - Bearer link window\n");
+}
+
+static void _print_bearer_media(void)
+{
+	fprintf(stderr,
+		"\nMEDIA\n"
+		" udp                   - User Datagram Protocol\n"
+		" ib                    - Infiniband\n"
+		" eth                   - Ethernet\n");
+}
+
+static void cmd_bearer_enable_l2_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s bearer enable media MEDIA device DEVICE [OPTIONS]\n"
+		"\nOPTIONS\n"
+		" domain DOMAIN         - Discovery domain\n"
+		" priority PRIORITY     - Bearer priority\n",
+		cmdl->argv[0]);
+}
+
+static void cmd_bearer_enable_udp_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s bearer enable media udp name NAME localip IP [OPTIONS]\n"
+		"\nOPTIONS\n"
+		" domain DOMAIN         - Discovery domain\n"
+		" priority PRIORITY     - Bearer priority\n"
+		" localport PORT        - Local UDP port (default 6118)\n"
+		" remoteip IP           - Remote IP address\n"
+		" remoteport IP         - Remote UDP port (default 6118)\n",
+		cmdl->argv[0]);
+}
+
+static int enable_l2_bearer(struct nlmsghdr *nlh, struct opt *opts,
+			    struct cmdl *cmdl)
+{
+	struct opt *opt;
+	char id[TIPC_MAX_BEARER_NAME];
+
+	if (!(opt = get_opt(opts, "device"))) {
+		fprintf(stderr, "error: missing bearer device\n");
+		return -EINVAL;
+	}
+	snprintf(id, sizeof(id), "eth:%s", opt->val);
+	mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, id);
+
+	return 0;
+}
+
+static int get_netid_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_NET_MAX + 1] = {};
+	int *netid = (int*)data;
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_NET])
+		return MNL_CB_ERROR;
+	mnl_attr_parse_nested(info[TIPC_NLA_NET], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_NET_ID])
+		return MNL_CB_ERROR;
+	*netid = mnl_attr_get_u32(attrs[TIPC_NLA_NET_ID]);
+
+	return MNL_CB_OK;
+}
+
+static int generate_multicast(short af, char *buf, int bufsize)
+{
+	int netid;
+	char mnl_msg[MNL_SOCKET_BUFFER_SIZE];
+	struct nlmsghdr *nlh;
+
+	if (!(nlh = msg_init(mnl_msg, TIPC_NL_NET_GET))) {
+		fprintf(stderr, "error, message initialization failed\n");
+		return -1;
+	}
+	if (msg_dumpit(nlh, get_netid_cb, &netid)) {
+		fprintf(stderr, "error, failed to fetch TIPC network id from kernel\n");
+		return -EINVAL;
+	}
+	if (af == AF_INET)
+		snprintf(buf, bufsize, "228.0.%u.%u", (netid>>8) & 0xFF, netid & 0xFF);
+	else
+		snprintf(buf, bufsize, "ff02::%u", netid);
+
+	return 0;
+}
+
+static int enable_udp_bearer(struct nlmsghdr *nlh, struct opt *opts,
+			     struct cmdl *cmdl)
+{
+	int err;
+	struct opt *opt;
+	struct nlattr *nest;
+	char buf[INET6_ADDRSTRLEN];
+	char *locport = "6118";
+	char *remport = "6118";
+	char *locip = NULL;
+	char *remip = NULL;
+	char name[TIPC_MAX_BEARER_NAME];
+	struct addrinfo *loc = NULL;
+	struct addrinfo *rem = NULL;
+	struct addrinfo hints = {
+		.ai_family = AF_UNSPEC,
+		.ai_socktype = SOCK_DGRAM
+	};
+
+	if (help_flag) {
+		cmd_bearer_enable_udp_help(cmdl);
+		/* TODO find a better error code? */
+		return -EINVAL;
+	}
+
+	if (!(opt = get_opt(opts, "name"))) {
+		fprintf(stderr, "error, udp bearer name missing\n");
+		cmd_bearer_enable_udp_help(cmdl);
+		return -EINVAL;
+	}
+	snprintf(name, sizeof(name), "udp:%s", opt->val);
+
+	if (!(opt = get_opt(opts, "localip"))) {
+		fprintf(stderr, "error, udp bearer localip missing\n");
+		cmd_bearer_enable_udp_help(cmdl);
+		return -EINVAL;
+	}
+	locip = opt->val;
+
+	if ((opt = get_opt(opts, "remoteip")))
+		remip = opt->val;
+
+	if ((opt = get_opt(opts, "localport")))
+		locport = opt->val;
+
+	if ((opt = get_opt(opts, "remoteport")))
+		remport = opt->val;
+
+	if ((err = getaddrinfo(locip, locport, &hints, &loc))) {
+		fprintf(stderr, "UDP local address error: %s\n",
+			gai_strerror(err));
+		return err;
+	}
+
+	if (!remip) {
+		if (generate_multicast(loc->ai_family, buf, sizeof(buf))) {
+			fprintf(stderr, "Failed to generate multicast address\n");
+			return -EINVAL;
+		}
+		remip = buf;
+	}
+
+	if ((err = getaddrinfo(remip, remport, &hints, &rem))) {
+		fprintf(stderr, "UDP remote address error: %s\n",
+			gai_strerror(err));
+		freeaddrinfo(loc);
+		return err;
+	}
+
+	if (rem->ai_family != loc->ai_family) {
+		fprintf(stderr, "UDP local and remote AF mismatch\n");
+		return -EINVAL;
+	}
+
+	mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, name);
+
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER_UDP_OPTS);
+	mnl_attr_put(nlh, TIPC_NLA_UDP_LOCAL, loc->ai_addrlen, loc->ai_addr);
+	mnl_attr_put(nlh, TIPC_NLA_UDP_REMOTE, rem->ai_addrlen, rem->ai_addr);
+	mnl_attr_nest_end(nlh, nest);
+
+	freeaddrinfo(rem);
+	freeaddrinfo(loc);
+
+	return 0;
+}
+
+static void cmd_bearer_enable_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s bearer enable [OPTIONS] media MEDIA ARGS...\n\n"
+		"OPTIONS\n"
+		" domain DOMAIN         - Discovery domain\n"
+		" priority PRIORITY     - Bearer priority\n",
+		cmdl->argv[0]);
+	_print_bearer_media();
+}
+
+static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
+			     struct cmdl *cmdl, void *data)
+{
+	int err;
+	struct opt *opt;
+	struct nlattr *nest;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	char *media;
+	struct opt opts[] = {
+		{ "device",		NULL },
+		{ "domain",		NULL },
+		{ "localip",		NULL },
+		{ "localport",		NULL },
+		{ "media",		NULL },
+		{ "name",		NULL },
+		{ "priority",		NULL },
+		{ "remoteip",		NULL },
+		{ "remoteport",		NULL },
+		{ NULL }
+	};
+
+	if (parse_opts(opts, cmdl) < 0) {
+		if (help_flag)
+			(cmd->help)(cmdl);
+		return -EINVAL;
+	}
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
+	if (!(nlh = msg_init(buf, TIPC_NL_BEARER_ENABLE))) {
+		fprintf(stderr, "error: message initialisation failed\n");
+		return -1;
+	}
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER);
+
+	if ((opt = get_opt(opts, "domain")))
+		mnl_attr_put_u32(nlh, TIPC_NLA_BEARER_DOMAIN, atoi(opt->val));
+
+	if ((opt = get_opt(opts, "priority"))) {
+		struct nlattr *props;
+
+		props = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER_PROP);
+		mnl_attr_put_u32(nlh, TIPC_NLA_PROP_PRIO, atoi(opt->val));
+		mnl_attr_nest_end(nlh, props);
+	}
+
+	if (strcmp(media, "udp") == 0) {
+		if (help_flag) {
+			cmd_bearer_enable_udp_help(cmdl);
+			return -EINVAL;
+		}
+		if ((err = enable_udp_bearer(nlh, opts, cmdl)))
+			return err;
+	} else if ((strcmp(media, "eth") == 0) || (strcmp(media, "udp") == 0)) {
+		if (help_flag) {
+			cmd_bearer_enable_l2_help(cmdl);
+			return -EINVAL;
+		}
+		if ((err = enable_l2_bearer(nlh, opts, cmdl)))
+			return err;
+	} else {
+		fprintf(stderr, "error, invalid media type \"%s\"\n", media);
+		return -EINVAL;
+	}
+
+	mnl_attr_nest_end(nlh, nest);
+
+	return msg_doit(nlh, NULL, NULL);
+}
+
+static int add_l2_bearer(struct nlmsghdr *nlh, struct opt *opts)
+{
+	struct opt *opt;
+	char id[TIPC_MAX_BEARER_NAME];
+
+	if (!(opt = get_opt(opts, "device"))) {
+		fprintf(stderr, "error: missing bearer device\n");
+		return -EINVAL;
+	}
+	snprintf(id, sizeof(id), "eth:%s", opt->val);
+
+	mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, id);
+
+	return 0;
+}
+
+static int add_udp_bearer(struct nlmsghdr *nlh, struct opt *opts)
+{
+	struct opt *opt;
+	char id[TIPC_MAX_BEARER_NAME];
+
+	if (!(opt = get_opt(opts, "name"))) {
+		fprintf(stderr, "error: missing bearer name\n");
+		return -EINVAL;
+	}
+	snprintf(id, sizeof(id), "udp:%s", opt->val);
+
+	mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, id);
+
+	return 0;
+}
+
+static void cmd_bearer_disable_l2_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s bearer disable media udp device DEVICE\n",
+		cmdl->argv[0]);
+}
+
+static void cmd_bearer_disable_udp_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s bearer disable media udp name NAME\n",
+		cmdl->argv[0]);
+}
+
+static void cmd_bearer_disable_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s bearer disable media MEDIA ARGS...\n",
+		cmdl->argv[0]);
+	_print_bearer_media();
+}
+
+static int cmd_bearer_disable(struct nlmsghdr *nlh, const struct cmd *cmd,
+			      struct cmdl *cmdl, void *data)
+{
+	int err;
+	char *media;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *nest;
+	struct opt *opt;
+	struct opt opts[] = {
+		{ "device",		NULL },
+		{ "name",		NULL },
+		{ "media",		NULL },
+		{ NULL }
+	};
+
+	if (parse_opts(opts, cmdl) < 0) {
+		if (help_flag)
+			(cmd->help)(cmdl);
+		return -EINVAL;
+	}
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
+	if (!(nlh = msg_init(buf, TIPC_NL_BEARER_DISABLE))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER);
+
+	if (strcmp(media, "udp") == 0) {
+		if (help_flag) {
+			cmd_bearer_disable_udp_help(cmdl);
+			return -EINVAL;
+		}
+		if ((err = add_udp_bearer(nlh, opts)))
+			return err;
+	} else if ((strcmp(media, "eth") == 0) || (strcmp(media, "udp") == 0)) {
+		if (help_flag) {
+			cmd_bearer_disable_l2_help(cmdl);
+			return -EINVAL;
+		}
+		if ((err = add_l2_bearer(nlh, opts)))
+			return err;
+	} else {
+		fprintf(stderr, "error, invalid media type \"%s\"\n", media);
+		return -EINVAL;
+	}
+	mnl_attr_nest_end(nlh, nest);
+
+	return msg_doit(nlh, NULL, NULL);
+
+}
+
+static void cmd_bearer_set_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s bearer set [OPTIONS] media MEDIA ARGS...\n",
+		cmdl->argv[0]);
+	_print_bearer_opts();
+	_print_bearer_media();
+}
+
+static void cmd_bearer_set_udp_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s bearer set [OPTIONS] media udp name NAME\n\n",
+		cmdl->argv[0]);
+	_print_bearer_opts();
+}
+
+static void cmd_bearer_set_l2_help(struct cmdl *cmdl, char *media)
+{
+	fprintf(stderr,
+		"Usage: %s bearer set [OPTION]... media %s device DEVICE\n",
+		cmdl->argv[0], media);
+	_print_bearer_opts();
+}
+
+static int cmd_bearer_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
+			 struct cmdl *cmdl, void *data)
+{
+	int err;
+	int val;
+	int prop;
+	char *media;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *props;
+	struct nlattr *attrs;
+	struct opt *opt;
+	struct opt opts[] = {
+		{ "device",		NULL },
+		{ "media",		NULL },
+		{ "name",		NULL },
+		{ NULL }
+	};
+
+	if (strcmp(cmd->cmd, "priority") == 0)
+		prop = TIPC_NLA_PROP_PRIO;
+	else if ((strcmp(cmd->cmd, "tolerance") == 0))
+		prop = TIPC_NLA_PROP_TOL;
+	else if ((strcmp(cmd->cmd, "window") == 0))
+		prop = TIPC_NLA_PROP_WIN;
+	else
+		return -EINVAL;
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (cmdl->optind >= cmdl->argc) {
+		fprintf(stderr, "error, missing value\n");
+		return -EINVAL;
+	}
+	val = atoi(shift_cmdl(cmdl));
+
+	if (parse_opts(opts, cmdl) < 0)
+		return -EINVAL;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_BEARER_SET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+	attrs = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER);
+
+	props = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER_PROP);
+	mnl_attr_put_u32(nlh, prop, val);
+	mnl_attr_nest_end(nlh, props);
+
+	if (!(opt = get_opt(opts, "media"))) {
+		fprintf(stderr, "error, missing media\n");
+		return -EINVAL;
+	}
+	media = opt->val;
+
+	if (strcmp(media, "udp") == 0) {
+		if (help_flag) {
+			cmd_bearer_set_udp_help(cmdl);
+			return -EINVAL;
+		}
+		if ((err = add_udp_bearer(nlh, opts)))
+			return err;
+	} else if ((strcmp(media, "eth") == 0) || (strcmp(media, "udp") == 0)) {
+		if (help_flag) {
+			cmd_bearer_set_l2_help(cmdl, media);
+			return -EINVAL;
+		}
+		if ((err = add_l2_bearer(nlh, opts)))
+			return err;
+	} else {
+		fprintf(stderr, "error, invalid media type \"%s\"\n", media);
+		return -EINVAL;
+	}
+	mnl_attr_nest_end(nlh, attrs);
+
+	return msg_doit(nlh, NULL, NULL);
+}
+
+static int cmd_bearer_set(struct nlmsghdr *nlh, const struct cmd *cmd,
+			  struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "priority",	cmd_bearer_set_prop,	cmd_bearer_set_help },
+		{ "tolerance",	cmd_bearer_set_prop,	cmd_bearer_set_help },
+		{ "window",	cmd_bearer_set_prop,	cmd_bearer_set_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+static void cmd_bearer_get_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s bearer get [OPTIONS] media MEDIA ARGS...\n",
+		cmdl->argv[0]);
+	_print_bearer_opts();
+	_print_bearer_media();
+}
+
+static void cmd_bearer_get_udp_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s bearer get [OPTIONS] media udp name NAME\n\n",
+		cmdl->argv[0]);
+	_print_bearer_opts();
+}
+
+static void cmd_bearer_get_l2_help(struct cmdl *cmdl, char *media)
+{
+	fprintf(stderr,
+		"Usage: %s bearer get [OPTION]... media %s device DEVICE\n",
+		cmdl->argv[0], media);
+	_print_bearer_opts();
+}
+
+static int bearer_get_cb(const struct nlmsghdr *nlh, void *data)
+{
+	int *prop = data;
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1] = {};
+	struct nlattr *props[TIPC_NLA_PROP_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_BEARER])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_BEARER], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_BEARER_PROP])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(attrs[TIPC_NLA_BEARER_PROP], parse_attrs, props);
+	if (!props[*prop])
+		return MNL_CB_ERROR;
+
+	printf("%u\n", mnl_attr_get_u32(props[*prop]));
+
+	return MNL_CB_OK;
+}
+
+static int cmd_bearer_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
+			       struct cmdl *cmdl, void *data)
+{
+	int err;
+	int prop;
+	char *media;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *attrs;
+	struct opt *opt;
+	struct opt opts[] = {
+		{ "device",		NULL },
+		{ "media",		NULL },
+		{ "name",		NULL },
+		{ NULL }
+	};
+
+	if (strcmp(cmd->cmd, "priority") == 0)
+		prop = TIPC_NLA_PROP_PRIO;
+	else if ((strcmp(cmd->cmd, "tolerance") == 0))
+		prop = TIPC_NLA_PROP_TOL;
+	else if ((strcmp(cmd->cmd, "window") == 0))
+		prop = TIPC_NLA_PROP_WIN;
+	else
+		return -EINVAL;
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (parse_opts(opts, cmdl) < 0)
+		return -EINVAL;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_BEARER_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	if (!(opt = get_opt(opts, "media"))) {
+		fprintf(stderr, "error, missing media\n");
+		return -EINVAL;
+	}
+	media = opt->val;
+
+	attrs = mnl_attr_nest_start(nlh, TIPC_NLA_BEARER);
+	if (strcmp(media, "udp") == 0) {
+		if (help_flag) {
+			cmd_bearer_get_udp_help(cmdl);
+			return -EINVAL;
+		}
+		if ((err = add_udp_bearer(nlh, opts)))
+			return err;
+	} else if ((strcmp(media, "eth") == 0) || (strcmp(media, "udp") == 0)) {
+		if (help_flag) {
+			cmd_bearer_get_l2_help(cmdl, media);
+			return -EINVAL;
+		}
+		if ((err = add_l2_bearer(nlh, opts)))
+			return err;
+	} else {
+		fprintf(stderr, "error, invalid media type \"%s\"\n", media);
+		return -EINVAL;
+	}
+	mnl_attr_nest_end(nlh, attrs);
+
+	return msg_doit(nlh, bearer_get_cb, &prop);
+}
+
+static int cmd_bearer_get(struct nlmsghdr *nlh, const struct cmd *cmd,
+			  struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "priority",	cmd_bearer_get_prop,	cmd_bearer_get_help },
+		{ "tolerance",	cmd_bearer_get_prop,	cmd_bearer_get_help },
+		{ "window",	cmd_bearer_get_prop,	cmd_bearer_get_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+static int bearer_list_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_BEARER]) {
+		fprintf(stderr, "No bearer in netlink response\n");
+		return MNL_CB_ERROR;
+	}
+
+	mnl_attr_parse_nested(info[TIPC_NLA_BEARER], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_BEARER_NAME]) {
+		fprintf(stderr, "Bearer name missing in netlink response\n");
+		return MNL_CB_ERROR;
+	}
+
+	printf("%s\n", mnl_attr_get_str(attrs[TIPC_NLA_BEARER_NAME]));
+
+	return MNL_CB_OK;
+}
+
+static int cmd_bearer_list(struct nlmsghdr *nlh, const struct cmd *cmd,
+			   struct cmdl *cmdl, void *data)
+{
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (help_flag) {
+		fprintf(stderr, "Usage: %s bearer list\n", cmdl->argv[0]);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_BEARER_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_dumpit(nlh, bearer_list_cb, NULL);
+}
+
+void cmd_bearer_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s bearer COMMAND [ARGS] ...\n"
+		"\n"
+		"COMMANDS\n"
+		" enable                - Enable a bearer\n"
+		" disable               - Disable a bearer\n"
+		" set                   - Set various bearer properties\n"
+		" get                   - Get various bearer properties\n"
+		" list                  - List bearers\n", cmdl->argv[0]);
+}
+
+int cmd_bearer(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+	       void *data)
+{
+	const struct cmd cmds[] = {
+		{ "disable",	cmd_bearer_disable,	cmd_bearer_disable_help },
+		{ "enable",	cmd_bearer_enable,	cmd_bearer_enable_help },
+		{ "get",	cmd_bearer_get,		cmd_bearer_get_help },
+		{ "list",	cmd_bearer_list,	NULL },
+		{ "set",	cmd_bearer_set,		cmd_bearer_set_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
diff --git a/tipc/bearer.h b/tipc/bearer.h
new file mode 100644
index 0000000..9459d65
--- /dev/null
+++ b/tipc/bearer.h
@@ -0,0 +1,22 @@
+/*
+ * bearer.h	TIPC bearer functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_BEARER_H
+#define _TIPC_BEARER_H
+
+#include "cmdl.h"
+
+extern int help_flag;
+
+int cmd_bearer(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl, void *data);
+void cmd_bearer_help(struct cmdl *cmdl);
+
+#endif
diff --git a/tipc/cmdl.c b/tipc/cmdl.c
new file mode 100644
index 0000000..b816f7d
--- /dev/null
+++ b/tipc/cmdl.c
@@ -0,0 +1,127 @@
+/*
+ * cmdl.c	Framework for handling command line options.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <string.h>
+#include <errno.h>
+
+#include <libmnl/libmnl.h>
+
+#include "cmdl.h"
+
+const struct cmd *find_cmd(const struct cmd *cmds, char *str)
+{
+	const struct cmd *c;
+	const struct cmd *match = NULL;
+
+	for (c = cmds; c->cmd; c++) {
+		if (strstr(c->cmd, str) != c->cmd)
+			continue;
+		if (match)
+			return NULL;
+		match = c;
+	}
+
+	return match;
+}
+
+static struct opt *find_opt(struct opt *opts, char *str)
+{
+	struct opt *o;
+	struct opt *match = NULL;
+
+	for (o = opts; o->key; o++) {
+		if (strstr(o->key, str) != o->key)
+			continue;
+		if (match)
+			return NULL;
+
+		match = o;
+	}
+
+	return match;
+}
+
+struct opt *get_opt(struct opt *opts, char *key)
+{
+	struct opt *o;
+
+	for (o = opts; o->key; o++) {
+		if (strcmp(o->key, key) == 0 && o->val)
+			return o;
+	}
+
+	return NULL;
+}
+
+char *shift_cmdl(struct cmdl *cmdl)
+{
+	int next;
+
+	if (cmdl->optind < cmdl->argc)
+		next = (cmdl->optind)++;
+	else
+		next = cmdl->argc;
+
+	return cmdl->argv[next];
+}
+
+/* Returns the number of options parsed or a negative error code upon failure */
+int parse_opts(struct opt *opts, struct cmdl *cmdl)
+{
+	int i;
+	int cnt = 0;
+
+	for (i = cmdl->optind; i < cmdl->argc; i += 2) {
+		struct opt *o;
+
+		o = find_opt(opts, cmdl->argv[i]);
+		if (!o) {
+			fprintf(stderr, "error, invalid option \"%s\"\n",
+					cmdl->argv[i]);
+			return -EINVAL;
+		}
+		cnt++;
+		o->val = cmdl->argv[i + 1];
+		cmdl->optind += 2;
+	}
+
+	return cnt;
+}
+
+int run_cmd(struct nlmsghdr *nlh, const struct cmd *caller,
+	    const struct cmd *cmds, struct cmdl *cmdl, void *data)
+{
+	char *name;
+	const struct cmd *cmd;
+
+	if ((cmdl->optind) >= cmdl->argc) {
+		if (caller->help)
+			(caller->help)(cmdl);
+		return -EINVAL;
+	}
+	name = cmdl->argv[cmdl->optind];
+	(cmdl->optind)++;
+
+	cmd = find_cmd(cmds, name);
+	if (!cmd) {
+		/* Show help about last command if we don't find this one */
+		if (help_flag && caller->help) {
+			(caller->help)(cmdl);
+		} else {
+			fprintf(stderr, "error, invalid command \"%s\"\n", name);
+			fprintf(stderr, "use --help for command help\n");
+		}
+		return -EINVAL;
+	}
+
+	return (cmd->func)(nlh, cmd, cmdl, data);
+}
diff --git a/tipc/cmdl.h b/tipc/cmdl.h
new file mode 100644
index 0000000..9f2666f
--- /dev/null
+++ b/tipc/cmdl.h
@@ -0,0 +1,46 @@
+/*
+ * cmdl.h	Framework for handling command line options.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_CMDL_H
+#define _TIPC_CMDL_H
+
+#include <libmnl/libmnl.h>
+
+extern int help_flag;
+
+struct cmdl {
+	int optind;
+	int argc;
+	char **argv;
+};
+
+struct cmd {
+	const char *cmd;
+	int (*func)(struct nlmsghdr *nlh, const struct cmd *cmd,
+		    struct cmdl *cmdl, void *data);
+	void (*help)(struct cmdl *cmdl);
+};
+
+struct opt {
+	const char *key;
+	char *val;
+};
+
+struct opt *get_opt(struct opt *opts, char *key);
+int parse_opts(struct opt *opts, struct cmdl *cmdl);
+char *shift_cmdl(struct cmdl *cmdl);
+
+int run_cmd(struct nlmsghdr *nlh, const struct cmd *caller,
+	    const struct cmd *cmds, struct cmdl *cmdl, void *data);
+
+const struct cmd *find_cmd(const struct cmd *cmds, char *str);
+
+#endif
diff --git a/tipc/link.c b/tipc/link.c
new file mode 100644
index 0000000..89fb4ff
--- /dev/null
+++ b/tipc/link.c
@@ -0,0 +1,520 @@
+/*
+ * link.c	TIPC link functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+
+#include <linux/tipc_netlink.h>
+#include <linux/tipc.h>
+#include <linux/genetlink.h>
+#include <libmnl/libmnl.h>
+
+#include "cmdl.h"
+#include "msg.h"
+#include "link.h"
+
+static int link_list_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_LINK_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_LINK])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_LINK], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_LINK_NAME])
+		return MNL_CB_ERROR;
+
+	printf("%s: ", mnl_attr_get_str(attrs[TIPC_NLA_LINK_NAME]));
+
+	if (attrs[TIPC_NLA_LINK_UP])
+		printf("up\n");
+	else
+		printf("down\n");
+
+	return MNL_CB_OK;
+}
+
+static int cmd_link_list(struct nlmsghdr *nlh, const struct cmd *cmd,
+			 struct cmdl *cmdl, void *data)
+{
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (help_flag) {
+		fprintf(stderr, "Usage: %s link list\n", cmdl->argv[0]);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_LINK_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_dumpit(nlh, link_list_cb, NULL);
+}
+
+static int link_get_cb(const struct nlmsghdr *nlh, void *data)
+{
+	int *prop = data;
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_LINK_MAX + 1] = {};
+	struct nlattr *props[TIPC_NLA_PROP_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_LINK])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_LINK], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_LINK_PROP])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(attrs[TIPC_NLA_LINK_PROP], parse_attrs, props);
+	if (!props[*prop])
+		return MNL_CB_ERROR;
+
+	printf("%u\n", mnl_attr_get_u32(props[*prop]));
+
+	return MNL_CB_OK;
+}
+
+
+static int cmd_link_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
+			     struct cmdl *cmdl, void *data)
+{
+	int prop;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct opt *opt;
+	struct opt opts[] = {
+		{ "link",		NULL },
+		{ NULL }
+	};
+
+	if (strcmp(cmd->cmd, "priority") == 0)
+		prop = TIPC_NLA_PROP_PRIO;
+	else if ((strcmp(cmd->cmd, "tolerance") == 0))
+		prop = TIPC_NLA_PROP_TOL;
+	else if ((strcmp(cmd->cmd, "window") == 0))
+		prop = TIPC_NLA_PROP_WIN;
+	else
+		return -EINVAL;
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (parse_opts(opts, cmdl) < 0)
+		return -EINVAL;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_LINK_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	if (!(opt = get_opt(opts, "link"))) {
+		fprintf(stderr, "error, missing link\n");
+		return -EINVAL;
+	}
+	mnl_attr_put_strz(nlh, TIPC_NLA_LINK_NAME, opt->val);
+
+	return msg_doit(nlh, link_get_cb, &prop);
+}
+
+static void cmd_link_get_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s link get PPROPERTY link LINK\n\n"
+		"PROPERTIES\n"
+		" tolerance             - Get link tolerance\n"
+		" priority              - Get link priority\n"
+		" window                - Get link window\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_link_get(struct nlmsghdr *nlh, const struct cmd *cmd,
+			struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "priority",	cmd_link_get_prop,	cmd_link_get_help },
+		{ "tolerance",	cmd_link_get_prop,	cmd_link_get_help },
+		{ "window",	cmd_link_get_prop,	cmd_link_get_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+static void cmd_link_stat_reset_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s link stat reset link LINK\n\n", cmdl->argv[0]);
+}
+
+static int cmd_link_stat_reset(struct nlmsghdr *nlh, const struct cmd *cmd,
+			       struct cmdl *cmdl, void *data)
+{
+	char *link;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct opt *opt;
+	struct nlattr *nest;
+	struct opt opts[] = {
+		{ "link",		NULL },
+		{ NULL }
+	};
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (parse_opts(opts, cmdl) != 1) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_LINK_RESET_STATS))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	if (!(opt = get_opt(opts, "link"))) {
+		fprintf(stderr, "error, missing link\n");
+		return -EINVAL;
+	}
+	link = opt->val;
+
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_LINK);
+	mnl_attr_put_strz(nlh, TIPC_NLA_LINK_NAME, link);
+	mnl_attr_nest_end(nlh, nest);
+
+	return msg_doit(nlh, NULL, NULL);
+}
+
+static uint32_t perc(uint32_t count, uint32_t total)
+{
+	return (count * 100 + (total / 2)) / total;
+}
+
+static int _show_link_stat(struct nlattr *attrs[], struct nlattr *prop[],
+			   struct nlattr *stats[])
+{
+	uint32_t proft;
+
+	if (attrs[TIPC_NLA_LINK_ACTIVE])
+		printf("  ACTIVE");
+	else if (attrs[TIPC_NLA_LINK_UP])
+		printf("  STANDBY");
+	else
+		printf("  DEFUNCT");
+
+	printf("  MTU:%u  Priority:%u  Tolerance:%u ms  Window:%u packets\n",
+	       mnl_attr_get_u32(attrs[TIPC_NLA_LINK_MTU]),
+	       mnl_attr_get_u32(prop[TIPC_NLA_PROP_PRIO]),
+	       mnl_attr_get_u32(prop[TIPC_NLA_PROP_TOL]),
+	       mnl_attr_get_u32(prop[TIPC_NLA_PROP_WIN]));
+
+	printf("  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
+	       mnl_attr_get_u32(attrs[TIPC_NLA_LINK_RX]) -
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_INFO]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_FRAGMENTS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_FRAGMENTED]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_BUNDLES]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_BUNDLED]));
+
+	printf("  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
+	       mnl_attr_get_u32(attrs[TIPC_NLA_LINK_TX]) -
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_INFO]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_FRAGMENTS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_FRAGMENTED]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_BUNDLES]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_BUNDLED]));
+
+	proft = mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_PROF_TOT]);
+	printf("  TX profile sample:%u packets  average:%u octets\n",
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_CNT]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_TOT]) / proft);
+
+	printf("  0-64:%u%% -256:%u%% -1024:%u%% -4096:%u%% "
+	       "-16384:%u%% -32768:%u%% -66000:%u%%\n",
+	       perc(mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P0]), proft),
+	       perc(mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P1]), proft),
+	       perc(mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P2]), proft),
+	       perc(mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P3]), proft),
+	       perc(mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P4]), proft),
+	       perc(mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P5]), proft),
+	       perc(mnl_attr_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P6]), proft));
+
+	printf("  RX states:%u probes:%u naks:%u defs:%u dups:%u\n",
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_STATES]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_PROBES]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_NACKS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_DEFERRED]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_DUPLICATES]));
+
+	printf("  TX states:%u probes:%u naks:%u acks:%u dups:%u\n",
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_STATES]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_PROBES]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_NACKS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_ACKS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RETRANSMITTED]));
+
+	printf("  Congestion link:%u  Send queue max:%u avg:%u\n",
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_LINK_CONGS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_MAX_QUEUE]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_AVG_QUEUE]));
+
+	return MNL_CB_OK;
+}
+
+static int _show_bc_link_stat(struct nlattr *prop[], struct nlattr *stats[])
+{
+	printf("  Window:%u packets\n",
+	       mnl_attr_get_u32(prop[TIPC_NLA_PROP_WIN]));
+
+	printf("  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_INFO]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_FRAGMENTS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_FRAGMENTED]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_BUNDLES]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_BUNDLED]));
+
+	printf("  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_INFO]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_FRAGMENTS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_FRAGMENTED]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_BUNDLES]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_BUNDLED]));
+
+	printf("  RX naks:%u defs:%u dups:%u\n",
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_NACKS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RX_DEFERRED]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_DUPLICATES]));
+
+	printf("  TX naks:%u acks:%u dups:%u\n",
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_NACKS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_TX_ACKS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_RETRANSMITTED]));
+
+	printf("  Congestion link:%u  Send queue max:%u avg:%u\n",
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_LINK_CONGS]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_MAX_QUEUE]),
+	       mnl_attr_get_u32(stats[TIPC_NLA_STATS_AVG_QUEUE]));
+
+	return MNL_CB_OK;
+}
+
+static int link_stat_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	const char *name;
+	const char *link = data;
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_LINK_MAX + 1] = {};
+	struct nlattr *prop[TIPC_NLA_PROP_MAX + 1] = {};
+	struct nlattr *stats[TIPC_NLA_STATS_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_LINK])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_LINK], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_LINK_NAME] || !attrs[TIPC_NLA_LINK_PROP] ||
+	    !attrs[TIPC_NLA_LINK_STATS])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(attrs[TIPC_NLA_LINK_PROP], parse_attrs, prop);
+	mnl_attr_parse_nested(attrs[TIPC_NLA_LINK_STATS], parse_attrs, stats);
+
+	name = mnl_attr_get_str(attrs[TIPC_NLA_LINK_NAME]);
+
+	/* If a link is passed, skip all but that link */
+	if (link && (strcmp(name, link) != 0))
+		return MNL_CB_OK;
+
+	if (attrs[TIPC_NLA_LINK_BROADCAST]) {
+		printf("Link <%s>\n", name);
+		return _show_bc_link_stat(prop, stats);
+	}
+
+	printf("\nLink <%s>\n", name);
+
+	return _show_link_stat(attrs, prop, stats);
+}
+
+static void cmd_link_stat_show_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s link stat show [ link LINK ]\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_link_stat_show(struct nlmsghdr *nlh, const struct cmd *cmd,
+			      struct cmdl *cmdl, void *data)
+{
+	char *link = NULL;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct opt *opt;
+	struct opt opts[] = {
+		{ "link",		NULL },
+		{ NULL }
+	};
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_LINK_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	if (parse_opts(opts, cmdl) < 0)
+		return -EINVAL;
+
+	if ((opt = get_opt(opts, "link")))
+		link = opt->val;
+
+	return msg_dumpit(nlh, link_stat_show_cb, link);
+}
+
+static void cmd_link_stat_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s link stat COMMAND [ARGS]\n\n"
+		"COMMANDS:\n"
+		" reset                 - Reset link statistics for link\n"
+		" show                  - Get link priority\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_link_stat(struct nlmsghdr *nlh, const struct cmd *cmd,
+			 struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "reset",	cmd_link_stat_reset,	cmd_link_stat_reset_help },
+		{ "show",	cmd_link_stat_show,	cmd_link_stat_show_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+static void cmd_link_set_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s link set PPROPERTY link LINK\n\n"
+		"PROPERTIES\n"
+		" tolerance TOLERANCE   - Set link tolerance\n"
+		" priority PRIORITY     - Set link priority\n"
+		" window WINDOW         - Set link window\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_link_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
+			     struct cmdl *cmdl, void *data)
+{
+	int val;
+	int prop;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *props;
+	struct nlattr *attrs;
+	struct opt *opt;
+	struct opt opts[] = {
+		{ "link",	NULL },
+		{ NULL }
+	};
+
+	if (strcmp(cmd->cmd, "priority") == 0)
+		prop = TIPC_NLA_PROP_PRIO;
+	else if ((strcmp(cmd->cmd, "tolerance") == 0))
+		prop = TIPC_NLA_PROP_TOL;
+	else if ((strcmp(cmd->cmd, "window") == 0))
+		prop = TIPC_NLA_PROP_WIN;
+	else
+		return -EINVAL;
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (cmdl->optind >= cmdl->argc) {
+		fprintf(stderr, "error, missing value\n");
+		return -EINVAL;
+	}
+	val = atoi(shift_cmdl(cmdl));
+
+	if (parse_opts(opts, cmdl) < 0)
+		return -EINVAL;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_LINK_SET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+	attrs = mnl_attr_nest_start(nlh, TIPC_NLA_LINK);
+
+	if (!(opt = get_opt(opts, "link"))) {
+		fprintf(stderr, "error, missing link\n");
+		return -EINVAL;
+	}
+	mnl_attr_put_strz(nlh, TIPC_NLA_LINK_NAME, opt->val);
+
+	props = mnl_attr_nest_start(nlh, TIPC_NLA_LINK_PROP);
+	mnl_attr_put_u32(nlh, prop, val);
+	mnl_attr_nest_end(nlh, props);
+
+	mnl_attr_nest_end(nlh, attrs);
+
+	return msg_doit(nlh, link_get_cb, &prop);
+
+	return 0;
+}
+
+static int cmd_link_set(struct nlmsghdr *nlh, const struct cmd *cmd,
+			struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "priority",	cmd_link_set_prop,	cmd_link_set_help },
+		{ "tolerance",	cmd_link_set_prop,	cmd_link_set_help },
+		{ "window",	cmd_link_set_prop,	cmd_link_set_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+void cmd_link_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s link COMMAND [ARGS] ...\n"
+		"\n"
+		"COMMANDS\n"
+		" list                  - List links\n"
+		" get                   - Get various link properties\n"
+		" set                   - Set various link properties\n"
+		" statistics            - Show or reset statistics\n",
+		cmdl->argv[0]);
+}
+
+int cmd_link(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+	     void *data)
+{
+	const struct cmd cmds[] = {
+		{ "get",	cmd_link_get,	cmd_link_get_help },
+		{ "list",	cmd_link_list,	NULL },
+		{ "set",	cmd_link_set,	cmd_link_set_help },
+		{ "statistics", cmd_link_stat,	cmd_link_stat_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
diff --git a/tipc/link.h b/tipc/link.h
new file mode 100644
index 0000000..6dc95e5
--- /dev/null
+++ b/tipc/link.h
@@ -0,0 +1,21 @@
+/*
+ * link.c	TIPC link functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_LINK_H
+#define _TIPC_LINK_H
+
+extern int help_flag;
+
+int cmd_link(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+	     void *data);
+void cmd_link_help(struct cmdl *cmdl);
+
+#endif
diff --git a/tipc/media.c b/tipc/media.c
new file mode 100644
index 0000000..a902ab7
--- /dev/null
+++ b/tipc/media.c
@@ -0,0 +1,260 @@
+/*
+ * media.c	TIPC link functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+
+#include <linux/tipc_netlink.h>
+#include <linux/tipc.h>
+#include <linux/genetlink.h>
+#include <libmnl/libmnl.h>
+
+#include "cmdl.h"
+#include "msg.h"
+#include "media.h"
+
+static int media_list_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_MEDIA_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_MEDIA])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_MEDIA], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_MEDIA_NAME])
+		return MNL_CB_ERROR;
+
+	printf("%s\n", mnl_attr_get_str(attrs[TIPC_NLA_MEDIA_NAME]));
+
+	return MNL_CB_OK;
+}
+
+static int cmd_media_list(struct nlmsghdr *nlh, const struct cmd *cmd,
+			 struct cmdl *cmdl, void *data)
+{
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (help_flag) {
+		fprintf(stderr, "Usage: %s media list\n", cmdl->argv[0]);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_MEDIA_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_dumpit(nlh, media_list_cb, NULL);
+}
+
+static int media_get_cb(const struct nlmsghdr *nlh, void *data)
+{
+	int *prop = data;
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_MEDIA_MAX + 1] = {};
+	struct nlattr *props[TIPC_NLA_PROP_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_MEDIA])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_MEDIA], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_MEDIA_PROP])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(attrs[TIPC_NLA_MEDIA_PROP], parse_attrs, props);
+	if (!props[*prop])
+		return MNL_CB_ERROR;
+
+	printf("%u\n", mnl_attr_get_u32(props[*prop]));
+
+	return MNL_CB_OK;
+}
+
+static int cmd_media_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
+			      struct cmdl *cmdl, void *data)
+{
+	int prop;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *nest;
+	struct opt *opt;
+	struct opt opts[] = {
+		{ "media",		NULL },
+		{ NULL }
+	};
+
+	if (strcmp(cmd->cmd, "priority") == 0)
+		prop = TIPC_NLA_PROP_PRIO;
+	else if ((strcmp(cmd->cmd, "tolerance") == 0))
+		prop = TIPC_NLA_PROP_TOL;
+	else if ((strcmp(cmd->cmd, "window") == 0))
+		prop = TIPC_NLA_PROP_WIN;
+	else
+		return -EINVAL;
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (parse_opts(opts, cmdl) < 0)
+		return -EINVAL;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_MEDIA_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	if (!(opt = get_opt(opts, "media"))) {
+		fprintf(stderr, "error, missing media\n");
+		return -EINVAL;
+	}
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_MEDIA);
+	mnl_attr_put_strz(nlh, TIPC_NLA_MEDIA_NAME, opt->val);
+	mnl_attr_nest_end(nlh, nest);
+
+	return msg_doit(nlh, media_get_cb, &prop);
+}
+
+static void cmd_media_get_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s media get PPROPERTY media MEDIA\n\n"
+		"PROPERTIES\n"
+		" tolerance             - Get media tolerance\n"
+		" priority              - Get media priority\n"
+		" window                - Get media window\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_media_get(struct nlmsghdr *nlh, const struct cmd *cmd,
+			struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "priority",	cmd_media_get_prop,	cmd_media_get_help },
+		{ "tolerance",	cmd_media_get_prop,	cmd_media_get_help },
+		{ "window",	cmd_media_get_prop,	cmd_media_get_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+static void cmd_media_set_help(struct cmdl *cmdl)
+{
+	fprintf(stderr, "Usage: %s media set PPROPERTY media MEDIA\n\n"
+		"PROPERTIES\n"
+		" tolerance TOLERANCE   - Set media tolerance\n"
+		" priority PRIORITY     - Set media priority\n"
+		" window WINDOW         - Set media window\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_media_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
+			 struct cmdl *cmdl, void *data)
+{
+	int val;
+	int prop;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *props;
+	struct nlattr *attrs;
+	struct opt *opt;
+	struct opt opts[] = {
+		{ "media",		NULL },
+		{ NULL }
+	};
+
+	if (strcmp(cmd->cmd, "priority") == 0)
+		prop = TIPC_NLA_PROP_PRIO;
+	else if ((strcmp(cmd->cmd, "tolerance") == 0))
+		prop = TIPC_NLA_PROP_TOL;
+	else if ((strcmp(cmd->cmd, "window") == 0))
+		prop = TIPC_NLA_PROP_WIN;
+	else
+		return -EINVAL;
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (cmdl->optind >= cmdl->argc) {
+		fprintf(stderr, "error, missing value\n");
+		return -EINVAL;
+	}
+	val = atoi(shift_cmdl(cmdl));
+
+	if (parse_opts(opts, cmdl) < 0)
+		return -EINVAL;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_MEDIA_SET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+	attrs = mnl_attr_nest_start(nlh, TIPC_NLA_MEDIA);
+
+	if (!(opt = get_opt(opts, "media"))) {
+		fprintf(stderr, "error, missing media\n");
+		return -EINVAL;
+	}
+	mnl_attr_put_strz(nlh, TIPC_NLA_MEDIA_NAME, opt->val);
+
+	props = mnl_attr_nest_start(nlh, TIPC_NLA_MEDIA_PROP);
+	mnl_attr_put_u32(nlh, prop, val);
+	mnl_attr_nest_end(nlh, props);
+
+	mnl_attr_nest_end(nlh, attrs);
+
+	return msg_doit(nlh, NULL, NULL);
+}
+
+static int cmd_media_set(struct nlmsghdr *nlh, const struct cmd *cmd,
+			 struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "priority",	cmd_media_set_prop,	cmd_media_set_help },
+		{ "tolerance",	cmd_media_set_prop,	cmd_media_set_help },
+		{ "window",	cmd_media_set_prop,	cmd_media_set_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+void cmd_media_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s media COMMAND [ARGS] ...\n"
+		"\n"
+		"Commands:\n"
+		" list                  - List active media types\n"
+		" get                   - Get various media properties\n"
+		" set                   - Set various media properties\n",
+		cmdl->argv[0]);
+}
+
+int cmd_media(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+	     void *data)
+{
+	const struct cmd cmds[] = {
+		{ "get",	cmd_media_get,	cmd_media_get_help },
+		{ "list",	cmd_media_list,	NULL },
+		{ "set",	cmd_media_set,	cmd_media_set_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
diff --git a/tipc/media.h b/tipc/media.h
new file mode 100644
index 0000000..8584af7
--- /dev/null
+++ b/tipc/media.h
@@ -0,0 +1,21 @@
+/*
+ * media.h	TIPC link functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_MEDIA_H
+#define _TIPC_MEDIA_H
+
+extern int help_flag;
+
+int cmd_media(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+	     void *data);
+void cmd_media_help(struct cmdl *cmdl);
+
+#endif
diff --git a/tipc/misc.c b/tipc/misc.c
new file mode 100644
index 0000000..8091222
--- /dev/null
+++ b/tipc/misc.c
@@ -0,0 +1,35 @@
+/*
+ * misc.c	Miscellaneous TIPC helper functions.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <stdint.h>
+#include <linux/tipc.h>
+
+#include "misc.h"
+
+#define IN_RANGE(val, low, high) ((val) <= (high) && (val) >= (low))
+
+uint32_t str2addr(char *str)
+{
+	unsigned int z, c, n;
+	char dummy;
+
+	if (sscanf(str, "%u.%u.%u%c", &z, &c, &n, &dummy) != 3) {
+		fprintf(stderr, "invalid network address, syntax: Z.C.N\n");
+		return 0;
+	}
+
+	if (IN_RANGE(z, 0, 255) && IN_RANGE(c, 0, 4095) && IN_RANGE(n, 0, 4095))
+		return tipc_addr(z, c, n);
+
+	fprintf(stderr, "invalid network address \"%s\"\n", str);
+	return 0;
+}
diff --git a/tipc/misc.h b/tipc/misc.h
new file mode 100644
index 0000000..585df74
--- /dev/null
+++ b/tipc/misc.h
@@ -0,0 +1,19 @@
+/*
+ * misc.h	Miscellaneous TIPC helper functions.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_MISC_H
+#define _TIPC_MISC_H
+
+#include <stdint.h>
+
+uint32_t str2addr(char *str);
+
+#endif
diff --git a/tipc/msg.c b/tipc/msg.c
new file mode 100644
index 0000000..22c2222
--- /dev/null
+++ b/tipc/msg.c
@@ -0,0 +1,170 @@
+/*
+ * msg.c	Messaging (netlink) helper functions.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <time.h>
+#include <errno.h>
+
+#include <linux/tipc_netlink.h>
+#include <linux/tipc.h>
+#include <linux/genetlink.h>
+#include <libmnl/libmnl.h>
+
+#include "msg.h"
+
+int parse_attrs(const struct nlattr *attr, void *data)
+{
+	const struct nlattr **tb = data;
+	int type = mnl_attr_get_type(attr);
+
+	tb[type] = attr;
+
+	return MNL_CB_OK;
+}
+
+static int family_id_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[CTRL_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	int *id = data;
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, tb);
+	if (!tb[CTRL_ATTR_FAMILY_ID])
+		return MNL_CB_ERROR;
+
+	*id = mnl_attr_get_u16(tb[CTRL_ATTR_FAMILY_ID]);
+
+	return MNL_CB_OK;
+}
+
+static struct mnl_socket *msg_send(struct nlmsghdr *nlh)
+{
+	int ret;
+	struct mnl_socket *nl;
+
+	nl = mnl_socket_open(NETLINK_GENERIC);
+	if (nl == NULL) {
+		perror("mnl_socket_open");
+		return NULL;
+	}
+
+	ret = mnl_socket_bind(nl, 0, MNL_SOCKET_AUTOPID);
+	if (ret < 0) {
+		perror("mnl_socket_bind");
+		return NULL;
+	}
+
+	ret = mnl_socket_sendto(nl, nlh, nlh->nlmsg_len);
+	if (ret < 0) {
+		perror("mnl_socket_send");
+		return NULL;
+	}
+
+	return nl;
+}
+
+static int msg_recv(struct mnl_socket *nl, mnl_cb_t callback, void *data, int seq)
+{
+	int ret;
+	unsigned int portid;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	portid = mnl_socket_get_portid(nl);
+
+	ret = mnl_socket_recvfrom(nl, buf, sizeof(buf));
+	while (ret > 0) {
+		ret = mnl_cb_run(buf, ret, seq, portid, callback, data);
+		if (ret <= 0)
+			break;
+		ret = mnl_socket_recvfrom(nl, buf, sizeof(buf));
+	}
+	if (ret == -1)
+		perror("error");
+
+	mnl_socket_close(nl);
+
+	return ret;
+}
+
+static int msg_query(struct nlmsghdr *nlh, mnl_cb_t callback, void *data)
+{
+	unsigned int seq;
+	struct mnl_socket *nl;
+
+	seq = time(NULL);
+	nlh->nlmsg_seq = seq;
+
+	nl = msg_send(nlh);
+	if (!nl)
+		return -ENOTSUP;
+
+	return msg_recv(nl, callback, data, seq);
+}
+
+static int get_family(void)
+{
+	int err;
+	int nl_family;
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *genl;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	nlh = mnl_nlmsg_put_header(buf);
+	nlh->nlmsg_type	= GENL_ID_CTRL;
+	nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
+
+	genl = mnl_nlmsg_put_extra_header(nlh, sizeof(struct genlmsghdr));
+	genl->cmd = CTRL_CMD_GETFAMILY;
+	genl->version = 1;
+
+	mnl_attr_put_u32(nlh, CTRL_ATTR_FAMILY_ID, GENL_ID_CTRL);
+	mnl_attr_put_strz(nlh, CTRL_ATTR_FAMILY_NAME, TIPC_GENL_V2_NAME);
+
+	if ((err = msg_query(nlh, family_id_cb, &nl_family)))
+		return err;
+
+	return nl_family;
+}
+
+int msg_doit(struct nlmsghdr *nlh, mnl_cb_t callback, void *data)
+{
+	nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
+	return msg_query(nlh, callback, data);
+}
+
+int msg_dumpit(struct nlmsghdr *nlh, mnl_cb_t callback, void *data)
+{
+	nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_DUMP;
+	return msg_query(nlh, callback, data);
+}
+
+struct nlmsghdr *msg_init(char *buf, int cmd)
+{
+	int family;
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *genl;
+
+	family = get_family();
+	if (family <= 0) {
+		fprintf(stderr,
+			"Unable to get TIPC nl family id (module loaded?)\n");
+		return NULL;
+	}
+
+	nlh = mnl_nlmsg_put_header(buf);
+	nlh->nlmsg_type	= family;
+
+	genl = mnl_nlmsg_put_extra_header(nlh, sizeof(struct genlmsghdr));
+	genl->cmd = cmd;
+	genl->version = 1;
+
+	return nlh;
+}
diff --git a/tipc/msg.h b/tipc/msg.h
new file mode 100644
index 0000000..41fd1ad
--- /dev/null
+++ b/tipc/msg.h
@@ -0,0 +1,20 @@
+/*
+ * msg.h	Messaging (netlink) helper functions.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_MSG_H
+#define _TIPC_MSG_H
+
+struct nlmsghdr *msg_init(char *buf, int cmd);
+int msg_doit(struct nlmsghdr *nlh, mnl_cb_t callback, void *data);
+int msg_dumpit(struct nlmsghdr *nlh, mnl_cb_t callback, void *data);
+int parse_attrs(const struct nlattr *attr, void *data);
+
+#endif
diff --git a/tipc/nametable.c b/tipc/nametable.c
new file mode 100644
index 0000000..770a644
--- /dev/null
+++ b/tipc/nametable.c
@@ -0,0 +1,109 @@
+/*
+ * nametable.c	TIPC nametable functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <errno.h>
+
+#include <linux/tipc_netlink.h>
+#include <linux/tipc.h>
+#include <linux/genetlink.h>
+#include <libmnl/libmnl.h>
+
+#include "cmdl.h"
+#include "msg.h"
+#include "nametable.h"
+
+#define PORTID_STR_LEN 45 /* Four u32 and five delimiter chars */
+
+static int nametable_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	int *iteration = data;
+	char port_id[PORTID_STR_LEN];
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_NAME_TABLE_MAX + 1] = {};
+	struct nlattr *publ[TIPC_NLA_PUBL_MAX + 1] = {};
+	const char *scope[] = { "", "zone", "cluster", "node" };
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_NAME_TABLE])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_NAME_TABLE], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_NAME_TABLE_PUBL])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(attrs[TIPC_NLA_NAME_TABLE_PUBL], parse_attrs, publ);
+	if (!publ[TIPC_NLA_NAME_TABLE_PUBL])
+		return MNL_CB_ERROR;
+
+	if (!*iteration)
+		printf("%-10s %-10s %-10s %-26s %-10s\n",
+		       "Type", "Lower", "Upper", "Port Identity",
+		       "Publication Scope");
+	(*iteration)++;
+
+	snprintf(port_id, sizeof(port_id), "<%u.%u.%u:%u>",
+		 tipc_zone(mnl_attr_get_u32(publ[TIPC_NLA_PUBL_NODE])),
+		 tipc_cluster(mnl_attr_get_u32(publ[TIPC_NLA_PUBL_NODE])),
+		 tipc_node(mnl_attr_get_u32(publ[TIPC_NLA_PUBL_NODE])),
+		 mnl_attr_get_u32(publ[TIPC_NLA_PUBL_REF]));
+
+	printf("%-10u %-10u %-10u %-26s %-12u",
+	       mnl_attr_get_u32(publ[TIPC_NLA_PUBL_TYPE]),
+	       mnl_attr_get_u32(publ[TIPC_NLA_PUBL_LOWER]),
+	       mnl_attr_get_u32(publ[TIPC_NLA_PUBL_UPPER]),
+	       port_id,
+	       mnl_attr_get_u32(publ[TIPC_NLA_PUBL_KEY]));
+
+	printf("%s\n", scope[mnl_attr_get_u32(publ[TIPC_NLA_PUBL_SCOPE])]);
+
+	return MNL_CB_OK;
+}
+
+static int cmd_nametable_show(struct nlmsghdr *nlh, const struct cmd *cmd,
+			      struct cmdl *cmdl, void *data)
+{
+	int iteration = 0;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (help_flag) {
+		fprintf(stderr, "Usage: %s nametable show\n", cmdl->argv[0]);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_NAME_TABLE_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_dumpit(nlh, nametable_show_cb, &iteration);
+}
+
+void cmd_nametable_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s nametable COMMAND\n\n"
+		"COMMANDS\n"
+		" show                  - Show nametable\n",
+		cmdl->argv[0]);
+}
+
+int cmd_nametable(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+		  void *data)
+{
+	const struct cmd cmds[] = {
+		{ "show",	cmd_nametable_show,	NULL },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
diff --git a/tipc/nametable.h b/tipc/nametable.h
new file mode 100644
index 0000000..e0473e1
--- /dev/null
+++ b/tipc/nametable.h
@@ -0,0 +1,21 @@
+/*
+ * nametable.h	TIPC nametable functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_NAMETABLE_H
+#define _TIPC_NAMETABLE_H
+
+extern int help_flag;
+
+void cmd_nametable_help(struct cmdl *cmdl);
+int cmd_nametable(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+		  void *data);
+
+#endif
diff --git a/tipc/node.c b/tipc/node.c
new file mode 100644
index 0000000..163fb74
--- /dev/null
+++ b/tipc/node.c
@@ -0,0 +1,267 @@
+/*
+ * node.c	TIPC node functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+
+#include <linux/tipc_netlink.h>
+#include <linux/tipc.h>
+#include <linux/genetlink.h>
+#include <libmnl/libmnl.h>
+
+#include "cmdl.h"
+#include "msg.h"
+#include "misc.h"
+#include "node.h"
+
+static int node_list_cb(const struct nlmsghdr *nlh, void *data)
+{
+	uint32_t addr;
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_NODE_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_NODE])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_NODE], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_NODE_ADDR])
+		return MNL_CB_ERROR;
+
+	addr = mnl_attr_get_u32(attrs[TIPC_NLA_NODE_ADDR]);
+	printf("<%u.%u.%u>: ",
+		tipc_zone(addr),
+		tipc_cluster(addr),
+		tipc_node(addr));
+
+	if (attrs[TIPC_NLA_NODE_UP])
+		printf("up\n");
+	else
+		printf("down\n");
+
+	return MNL_CB_OK;
+}
+
+static int cmd_node_list(struct nlmsghdr *nlh, const struct cmd *cmd,
+			 struct cmdl *cmdl, void *data)
+{
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (help_flag) {
+		fprintf(stderr, "Usage: %s node list\n", cmdl->argv[0]);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_NODE_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_dumpit(nlh, node_list_cb, NULL);
+}
+
+static int cmd_node_set_addr(struct nlmsghdr *nlh, const struct cmd *cmd,
+			     struct cmdl *cmdl, void *data)
+{
+	char *str;
+	uint32_t addr;
+	struct nlattr *nest;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (cmdl->argc != cmdl->optind + 1) {
+		fprintf(stderr, "Usage: %s node set address ADDRESS\n",
+			cmdl->argv[0]);
+		return -EINVAL;
+	}
+
+	str = shift_cmdl(cmdl);
+	addr = str2addr(str);
+	if (!addr)
+		return -1;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_NET_SET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_NET);
+	mnl_attr_put_u32(nlh, TIPC_NLA_NET_ADDR, addr);
+	mnl_attr_nest_end(nlh, nest);
+
+	return msg_doit(nlh, NULL, NULL);
+}
+
+static int cmd_node_get_addr(struct nlmsghdr *nlh, const struct cmd *cmd,
+			     struct cmdl *cmdl, void *data)
+{
+	int sk;
+	socklen_t sz = sizeof(struct sockaddr_tipc);
+	struct sockaddr_tipc addr;
+
+	if (!(sk = socket(AF_TIPC, SOCK_RDM, 0))) {
+		fprintf(stderr, "opening TIPC socket: %s\n", strerror(errno));
+		return -1;
+	}
+
+	if (getsockname(sk, (struct sockaddr *)&addr, &sz) < 0) {
+		fprintf(stderr, "getting TIPC socket address: %s\n",
+			strerror(errno));
+		close(sk);
+		return -1;
+	}
+	close(sk);
+
+	printf("<%u.%u.%u>\n",
+		tipc_zone(addr.addr.id.node),
+		tipc_cluster(addr.addr.id.node),
+		tipc_node(addr.addr.id.node));
+
+	return 0;
+}
+
+static int netid_get_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_NET_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_NET])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_NET], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_NET_ID])
+		return MNL_CB_ERROR;
+
+	printf("%u\n", mnl_attr_get_u32(attrs[TIPC_NLA_NET_ID]));
+
+	return MNL_CB_OK;
+}
+
+static int cmd_node_get_netid(struct nlmsghdr *nlh, const struct cmd *cmd,
+			      struct cmdl *cmdl, void *data)
+{
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_NET_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_dumpit(nlh, netid_get_cb, NULL);
+}
+
+static int cmd_node_set_netid(struct nlmsghdr *nlh, const struct cmd *cmd,
+			      struct cmdl *cmdl, void *data)
+{
+	int netid;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *nest;
+
+	if (help_flag) {
+		(cmd->help)(cmdl);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_NET_SET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	if (cmdl->argc != cmdl->optind + 1) {
+		fprintf(stderr, "Usage: %s node set netid NETID\n",
+			cmdl->argv[0]);
+		return -EINVAL;
+	}
+	netid = atoi(shift_cmdl(cmdl));
+
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_NET);
+	mnl_attr_put_u32(nlh, TIPC_NLA_NET_ID, netid);
+	mnl_attr_nest_end(nlh, nest);
+
+	return msg_doit(nlh, NULL, NULL);
+}
+
+static void cmd_node_set_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s node set PROPERTY\n\n"
+		"PROPERTIES\n"
+		" address ADDRESS       - Set local address\n"
+		" netid NETID           - Set local netid\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_node_set(struct nlmsghdr *nlh, const struct cmd *cmd,
+			struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "address",	cmd_node_set_addr,	NULL },
+		{ "netid",	cmd_node_set_netid,	NULL },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+static void cmd_node_get_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s node get PROPERTY\n\n"
+		"PROPERTIES\n"
+		" address               - Get local address\n"
+		" netid                 - Get local netid\n",
+		cmdl->argv[0]);
+}
+
+static int cmd_node_get(struct nlmsghdr *nlh, const struct cmd *cmd,
+			struct cmdl *cmdl, void *data)
+{
+	const struct cmd cmds[] = {
+		{ "address",	cmd_node_get_addr,	NULL },
+		{ "netid",	cmd_node_get_netid,	NULL },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
+
+void cmd_node_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s media COMMAND [ARGS] ...\n\n"
+		"COMMANDS\n"
+		" list                  - List remote nodes\n"
+		" get                   - Get local node parameters\n"
+		" set                   - Set local node parameters\n",
+		cmdl->argv[0]);
+}
+
+int cmd_node(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+	     void *data)
+{
+	const struct cmd cmds[] = {
+		{ "list",	cmd_node_list,	NULL },
+		{ "get",	cmd_node_get,	cmd_node_get_help },
+		{ "set",	cmd_node_set,	cmd_node_set_help },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
diff --git a/tipc/node.h b/tipc/node.h
new file mode 100644
index 0000000..afee1fd
--- /dev/null
+++ b/tipc/node.h
@@ -0,0 +1,21 @@
+/*
+ * node.h	TIPC node functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_NODE_H
+#define _TIPC_NODE_H
+
+extern int help_flag;
+
+int cmd_node(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+	     void *data);
+void cmd_node_help(struct cmdl *cmdl);
+
+#endif
diff --git a/tipc/socket.c b/tipc/socket.c
new file mode 100644
index 0000000..48ba821
--- /dev/null
+++ b/tipc/socket.c
@@ -0,0 +1,140 @@
+/*
+ * socket.c	TIPC socket functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <errno.h>
+
+#include <linux/tipc.h>
+#include <linux/tipc_netlink.h>
+#include <linux/genetlink.h>
+#include <libmnl/libmnl.h>
+
+#include "cmdl.h"
+#include "msg.h"
+#include "socket.h"
+
+#define PORTID_STR_LEN 45 /* Four u32 and five delimiter chars */
+
+static int publ_list_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_SOCK_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_PUBL])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_PUBL], parse_attrs, attrs);
+
+	printf("  bound to {%u,%u,%u}\n",
+	       mnl_attr_get_u32(attrs[TIPC_NLA_PUBL_TYPE]),
+	       mnl_attr_get_u32(attrs[TIPC_NLA_PUBL_LOWER]),
+	       mnl_attr_get_u32(attrs[TIPC_NLA_PUBL_UPPER]));
+
+	return MNL_CB_OK;
+}
+
+static int publ_list(uint32_t sock)
+{
+	struct nlmsghdr *nlh;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+	struct nlattr *nest;
+
+	if (!(nlh = msg_init(buf, TIPC_NL_PUBL_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	nest = mnl_attr_nest_start(nlh, TIPC_NLA_SOCK);
+	mnl_attr_put_u32(nlh, TIPC_NLA_SOCK_REF, sock);
+	mnl_attr_nest_end(nlh, nest);
+
+	return msg_dumpit(nlh, publ_list_cb, NULL);
+}
+
+static int sock_list_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct nlattr *info[TIPC_NLA_MAX + 1] = {};
+	struct nlattr *attrs[TIPC_NLA_SOCK_MAX + 1] = {};
+
+	mnl_attr_parse(nlh, sizeof(*genl), parse_attrs, info);
+	if (!info[TIPC_NLA_SOCK])
+		return MNL_CB_ERROR;
+
+	mnl_attr_parse_nested(info[TIPC_NLA_SOCK], parse_attrs, attrs);
+	if (!attrs[TIPC_NLA_SOCK_REF])
+		return MNL_CB_ERROR;
+
+	printf("socket %u\n", mnl_attr_get_u32(attrs[TIPC_NLA_SOCK_REF]));
+
+	if (attrs[TIPC_NLA_SOCK_CON]) {
+		uint32_t node;
+		struct nlattr *con[TIPC_NLA_CON_MAX + 1] = {};
+
+		mnl_attr_parse_nested(attrs[TIPC_NLA_SOCK_CON], parse_attrs, con);
+		node = mnl_attr_get_u32(con[TIPC_NLA_CON_NODE]);
+
+		printf("  connected to <%u.%u.%u:%u>", tipc_zone(node),
+			tipc_cluster(node), tipc_node(node),
+			mnl_attr_get_u32(con[TIPC_NLA_CON_SOCK]));
+
+		if (con[TIPC_NLA_CON_FLAG])
+			printf(" via {%u,%u}\n",
+				mnl_attr_get_u32(con[TIPC_NLA_CON_TYPE]),
+				mnl_attr_get_u32(con[TIPC_NLA_CON_INST]));
+		else
+			printf("\n");
+	} else if (attrs[TIPC_NLA_SOCK_HAS_PUBL]) {
+		publ_list(mnl_attr_get_u32(attrs[TIPC_NLA_SOCK_REF]));
+	}
+
+	return MNL_CB_OK;
+}
+
+static int cmd_socket_list(struct nlmsghdr *nlh, const struct cmd *cmd,
+			   struct cmdl *cmdl, void *data)
+{
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	if (help_flag) {
+		fprintf(stderr, "Usage: %s socket list\n", cmdl->argv[0]);
+		return -EINVAL;
+	}
+
+	if (!(nlh = msg_init(buf, TIPC_NL_SOCK_GET))) {
+		fprintf(stderr, "error, message initialisation failed\n");
+		return -1;
+	}
+
+	return msg_dumpit(nlh, sock_list_cb, NULL);
+}
+
+void cmd_socket_help(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Usage: %s socket COMMAND\n\n"
+		"Commands:\n"
+		" list                  - List sockets (ports)\n",
+		cmdl->argv[0]);
+}
+
+int cmd_socket(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+		  void *data)
+{
+	const struct cmd cmds[] = {
+		{ "list",	cmd_socket_list,	NULL },
+		{ NULL }
+	};
+
+	return run_cmd(nlh, cmd, cmds, cmdl, NULL);
+}
diff --git a/tipc/socket.h b/tipc/socket.h
new file mode 100644
index 0000000..9d1b648
--- /dev/null
+++ b/tipc/socket.h
@@ -0,0 +1,21 @@
+/*
+ * socket.h	TIPC socket functionality.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#ifndef _TIPC_SOCKET_H
+#define _TIPC_SOCKET_H
+
+extern int help_flag;
+
+void cmd_socket_help(struct cmdl *cmdl);
+int cmd_socket(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl,
+		  void *data);
+
+#endif
diff --git a/tipc/tipc.c b/tipc/tipc.c
new file mode 100644
index 0000000..4439805
--- /dev/null
+++ b/tipc/tipc.c
@@ -0,0 +1,96 @@
+/*
+ * tipc.	TIPC utility frontend.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Richard Alpe <richard.alpe@ericsson.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <getopt.h>
+#include <unistd.h>
+
+#include "bearer.h"
+#include "link.h"
+#include "nametable.h"
+#include "socket.h"
+#include "media.h"
+#include "node.h"
+#include "cmdl.h"
+
+int help_flag;
+
+static void about(struct cmdl *cmdl)
+{
+	fprintf(stderr,
+		"Transparent Inter-Process Communication Protocol\n"
+		"Usage: %s [OPTIONS] COMMAND [ARGS] ...\n"
+		"\n"
+		"Options:\n"
+		" -h, --help \t\tPrint help for last given command\n"
+		"\n"
+		"Commands:\n"
+		" bearer                - Show or modify bearers\n"
+		" link                  - Show or modify links\n"
+		" media                 - Show or modify media\n"
+		" nametable             - Show nametable\n"
+		" node                  - Show or modify node related parameters\n"
+		" socket                - Show sockets\n",
+		cmdl->argv[0]);
+}
+
+int main(int argc, char *argv[])
+{
+	int i;
+	int res;
+	struct cmdl cmdl;
+	const struct cmd cmd = {"tipc", NULL, about};
+	struct option long_options[] = {
+		{"help", no_argument, 0, 'h'},
+		{0, 0, 0, 0}
+	};
+	const struct cmd cmds[] = {
+		{ "bearer",	cmd_bearer,	cmd_bearer_help},
+		{ "link",	cmd_link,	cmd_link_help},
+		{ "media",	cmd_media,	cmd_media_help},
+		{ "nametable",	cmd_nametable,	cmd_nametable_help},
+		{ "node",	cmd_node,	cmd_node_help},
+		{ "socket",	cmd_socket,	cmd_socket_help},
+		{ NULL }
+	};
+
+	do {
+		int option_index = 0;
+
+		i = getopt_long(argc, argv, "h", long_options, &option_index);
+
+		switch (i) {
+		case 'h':
+			/*
+			 * We want the help for the last command, so we flag
+			 * here in order to print later.
+			 */
+			help_flag = 1;
+			break;
+		case -1:
+			/* End of options */
+			break;
+		default:
+			/* Invalid option, error msg is printed by getopts */
+			return 1;
+		}
+	} while (i != -1);
+
+	cmdl.optind = optind;
+	cmdl.argc = argc;
+	cmdl.argv = argv;
+
+	if ((res = run_cmd(NULL, &cmd, cmds, &cmdl, NULL)) != 0)
+		return 1;
+
+	return 0;
+}
-- 
2.1.4
