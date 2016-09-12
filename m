From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH iproute2 net-next v1 5/7] tipc: refractor
	bearer to facilitate link monitor
Date: Mon, 12 Sep 2016 17:17:19 +0200
Message-ID: <1473693441-14254-6-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

In this commit, we:
1. Export print_bearer_media()
2. Move the bearer name handling from nl_add_bearer_name() into
   a new function cmd_get_unique_bearer_name().

These exported functions will be used by link monitor used in
subsequent commits.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 tipc/bearer.c | 75 +++++++++++++++++++++++++++++++++++------------------------
 tipc/bearer.h |  4 ++++
 2 files changed, 48 insertions(+), 31 deletions(-)

diff --git a/tipc/bearer.c b/tipc/bearer.c
index 8729dad4a060..810344f672af 100644
--- a/tipc/bearer.c
+++ b/tipc/bearer.c
@@ -45,7 +45,7 @@ static void _print_bearer_opts(void)
 		" window                - Bearer link window\n");
 }
 
-static void _print_bearer_media(void)
+void print_bearer_media(void)
 {
 	fprintf(stderr,
 		"\nMEDIA\n"
@@ -192,14 +192,28 @@ static int nl_add_udp_enable_opts(struct nlmsghdr *nlh, struct opt *opts,
 }
 
 static int nl_add_bearer_name(struct nlmsghdr *nlh, const struct cmd *cmd,
-			   struct cmdl *cmdl, struct opt *opts,
-			   struct tipc_sup_media sup_media[])
+			      struct cmdl *cmdl, struct opt *opts,
+			      const struct tipc_sup_media *sup_media)
+{
+	char bname[TIPC_MAX_BEARER_NAME];
+	int err;
+
+	if ((err = cmd_get_unique_bearer_name(cmd, cmdl, opts, bname, sup_media)))
+		return err;
+
+	mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, bname);
+	return 0;
+}
+
+int cmd_get_unique_bearer_name(const struct cmd *cmd, struct cmdl *cmdl,
+			       struct opt *opts, char *bname,
+			       const struct tipc_sup_media *sup_media)
 {
-	char id[TIPC_MAX_BEARER_NAME];
 	char *media;
 	char *identifier;
 	struct opt *opt;
-	struct tipc_sup_media *entry;
+	const struct tipc_sup_media *entry;
+
 
 	if (!(opt = get_opt(opts, "media"))) {
 		if (help_flag)
@@ -219,13 +233,12 @@ static int nl_add_bearer_name(struct nlmsghdr *nlh, const struct cmd *cmd,
 				(entry->help)(cmdl, media);
 			else
 				fprintf(stderr, "error, missing bearer %s\n",
-						entry->identifier);
+					entry->identifier);
 			return -EINVAL;
 		}
 
 		identifier = opt->val;
-		snprintf(id, sizeof(id), "%s:%s", media, identifier);
-		mnl_attr_put_strz(nlh, TIPC_NLA_BEARER_NAME, id);
+		snprintf(bname, TIPC_MAX_BEARER_NAME, "%s:%s", media, identifier);
 
 		return 0;
 	}
@@ -270,13 +283,13 @@ static int udp_bearer_add(struct nlmsghdr *nlh, struct opt *opts,
 
 		if ((err = getaddrinfo(ip, remport, &hints, &addr))) {
 			fprintf(stderr, "UDP address error: %s\n",
-					gai_strerror(err));
+				gai_strerror(err));
 			freeaddrinfo(addr);
 			return err;
 		}
 
 		mnl_attr_put(nlh, TIPC_NLA_UDP_REMOTE, addr->ai_addrlen,
-				addr->ai_addr);
+			     addr->ai_addr);
 		freeaddrinfo(addr);
 	} else {
 		fprintf(stderr, "error, missing remoteip\n");
@@ -302,7 +315,7 @@ static int cmd_bearer_add_media(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ "media",		OPT_KEYVAL,	NULL },
 		{ NULL }
 	};
-	struct tipc_sup_media sup_media[] = {
+	const struct tipc_sup_media sup_media[] = {
 		{ "udp",	"name",		cmd_bearer_add_udp_help},
 		{ NULL, },
 	};
@@ -366,7 +379,7 @@ static void cmd_bearer_enable_help(struct cmdl *cmdl)
 		" domain DOMAIN         - Discovery domain\n"
 		" priority PRIORITY     - Bearer priority\n",
 		cmdl->argv[0]);
-	_print_bearer_media();
+	print_bearer_media();
 }
 
 static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
@@ -389,9 +402,9 @@ static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
-		{ "udp",	"name",		cmd_bearer_enable_udp_help},
-		{ "eth",	"device",	cmd_bearer_enable_l2_help },
-		{ "ib",		"device",	cmd_bearer_enable_l2_help },
+		{ "udp",        "name",         cmd_bearer_enable_udp_help},
+		{ "eth",        "device",       cmd_bearer_enable_l2_help },
+		{ "ib",         "device",       cmd_bearer_enable_l2_help },
 		{ NULL, },
 	};
 
@@ -449,7 +462,7 @@ static void cmd_bearer_disable_help(struct cmdl *cmdl)
 {
 	fprintf(stderr, "Usage: %s bearer disable media MEDIA ARGS...\n",
 		cmdl->argv[0]);
-	_print_bearer_media();
+	print_bearer_media();
 }
 
 static int cmd_bearer_disable(struct nlmsghdr *nlh, const struct cmd *cmd,
@@ -465,9 +478,9 @@ static int cmd_bearer_disable(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
-		{ "udp",	"name",		cmd_bearer_disable_udp_help},
-		{ "eth",	"device",	cmd_bearer_disable_l2_help },
-		{ "ib",		"device",	cmd_bearer_disable_l2_help },
+		{ "udp",        "name",         cmd_bearer_disable_udp_help},
+		{ "eth",        "device",       cmd_bearer_disable_l2_help },
+		{ "ib",         "device",       cmd_bearer_disable_l2_help },
 		{ NULL, },
 	};
 
@@ -497,7 +510,7 @@ static void cmd_bearer_set_help(struct cmdl *cmdl)
 	fprintf(stderr, "Usage: %s bearer set OPTION media MEDIA ARGS...\n",
 		cmdl->argv[0]);
 	_print_bearer_opts();
-	_print_bearer_media();
+	print_bearer_media();
 }
 
 static void cmd_bearer_set_udp_help(struct cmdl *cmdl, char *media)
@@ -516,7 +529,7 @@ static void cmd_bearer_set_l2_help(struct cmdl *cmdl, char *media)
 }
 
 static int cmd_bearer_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
-			 struct cmdl *cmdl, void *data)
+			       struct cmdl *cmdl, void *data)
 {
 	int err;
 	int val;
@@ -531,9 +544,9 @@ static int cmd_bearer_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
-		{ "udp",	"name",		cmd_bearer_set_udp_help},
-		{ "eth",	"device",	cmd_bearer_set_l2_help },
-		{ "ib",		"device",	cmd_bearer_set_l2_help },
+		{ "udp",        "name",         cmd_bearer_set_udp_help},
+		{ "eth",        "device",       cmd_bearer_set_l2_help },
+		{ "ib",         "device",       cmd_bearer_set_l2_help },
 		{ NULL, },
 	};
 
@@ -592,7 +605,7 @@ static void cmd_bearer_get_help(struct cmdl *cmdl)
 	fprintf(stderr, "Usage: %s bearer get [OPTION] media MEDIA ARGS...\n",
 		cmdl->argv[0]);
 	_print_bearer_opts();
-	_print_bearer_media();
+	print_bearer_media();
 }
 
 static void cmd_bearer_get_udp_help(struct cmdl *cmdl, char *media)
@@ -639,7 +652,7 @@ static int bearer_dump_udp_cb(const struct nlmsghdr *nlh, void *data)
 		struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *) addr;
 
 		if (!inet_ntop(AF_INET6, &ipv6->sin6_addr, straddr,
-					sizeof(straddr))) {
+			       sizeof(straddr))) {
 			fprintf(stderr, "error, parsing IPv6 addr\n");
 			return MNL_CB_ERROR;
 		}
@@ -705,7 +718,7 @@ static int bearer_get_udp_cb(const struct nlmsghdr *nlh, void *data)
 		switch (cb_data->prop) {
 		case UDP_PROP_IP:
 			if (!inet_ntop(AF_INET6, &ipv6->sin6_addr, straddr,
-						sizeof(straddr))) {
+				       sizeof(straddr))) {
 				fprintf(stderr, "error, parsing IPv6 addr\n");
 				return MNL_CB_ERROR;
 			}
@@ -769,7 +782,7 @@ static int cmd_bearer_get_media(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
-		{ "udp",	"name",		cmd_bearer_get_udp_help},
+		{ "udp",        "name",         cmd_bearer_get_udp_help},
 		{ NULL, },
 	};
 
@@ -844,9 +857,9 @@ static int cmd_bearer_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 		{ NULL }
 	};
 	struct tipc_sup_media sup_media[] = {
-		{ "udp",	"name",		cmd_bearer_get_udp_help},
-		{ "eth",	"device",	cmd_bearer_get_l2_help },
-		{ "ib",		"device",	cmd_bearer_get_l2_help },
+		{ "udp",        "name",         cmd_bearer_get_udp_help},
+		{ "eth",        "device",       cmd_bearer_get_l2_help },
+		{ "ib",         "device",       cmd_bearer_get_l2_help },
 		{ NULL, },
 	};
 
diff --git a/tipc/bearer.h b/tipc/bearer.h
index 9459d65ebb5f..c0d099630b27 100644
--- a/tipc/bearer.h
+++ b/tipc/bearer.h
@@ -19,4 +19,8 @@ extern int help_flag;
 int cmd_bearer(struct nlmsghdr *nlh, const struct cmd *cmd, struct cmdl *cmdl, void *data);
 void cmd_bearer_help(struct cmdl *cmdl);
 
+void print_bearer_media(void);
+int cmd_get_unique_bearer_name(const struct cmd *cmd, struct cmdl *cmdl,
+			       struct opt *opts, char *bname,
+			       const struct tipc_sup_media *sup_media);
 #endif
-- 
2.1.4


------------------------------------------------------------------------------
