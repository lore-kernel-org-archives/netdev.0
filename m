From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 9/9] tc: m_xt: Introduce get_xtables_target_opts()
Date: Fri, 10 Jun 2016 13:42:08 +0200
Message-ID: <1465558928-19657-10-git-send-email-phil@nwl.cc>
References: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50314 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293AbcFJLmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:42:53 -0400
In-Reply-To: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pulls common code from parse_ipt() and print_ipt() functions
together.

While here, also fix for incorrect use of the global 'optarg' variable
in print_ipt().

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 58 +++++++++++++++++++++++++++++-----------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index f449c9d1a6638..1224e4fe4bee6 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -116,6 +116,27 @@ static void set_lib_dir(void)
 
 }
 
+static int get_xtables_target_opts(struct xtables_globals *globals,
+				   struct xtables_target *m)
+{
+	struct option *opts;
+
+#if (XTABLES_VERSION_CODE >= 6)
+	opts = xtables_options_xfrm(globals->orig_opts,
+				    globals->opts,
+				    m->x6_options,
+				    &m->option_offset);
+#else
+	opts = xtables_merge_options(globals->opts,
+				     m->extra_opts,
+				     &m->option_offset);
+#endif
+	if (!opts)
+		return -1;
+	globals->opts = opts;
+	return 0;
+}
+
 static int parse_ipt(struct action_util *a, int *argc_p,
 		     char ***argv_p, int tca_id, struct nlmsghdr *n)
 {
@@ -129,7 +150,6 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	int size = 0;
 	int iok = 0, ok = 0;
 	__u32 hook = 0, index = 0;
-	struct option *opts = NULL;
 
 	/* copy tcipt_globals because .opts will be modified by iptables */
 	struct xtables_globals tmp_tcipt_globals = tcipt_globals;
@@ -163,21 +183,11 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 				printf(" %s error\n", m->name);
 				return -1;
 			}
-#if (XTABLES_VERSION_CODE >= 6)
-			opts = xtables_options_xfrm(tmp_tcipt_globals.orig_opts,
-						    tmp_tcipt_globals.opts,
-						    m->x6_options,
-						    &m->option_offset);
-#else
-			opts = xtables_merge_options(tmp_tcipt_globals.opts,
-						     m->extra_opts,
-						     &m->option_offset);
-#endif
-			if (opts == NULL) {
+
+			if (get_xtables_target_opts(&tmp_tcipt_globals, m) < 0) {
 				fprintf(stderr, " failed to find additional options for target %s\n\n", optarg);
 				return -1;
-			} else
-				tmp_tcipt_globals.opts = opts;
+			}
 			ok++;
 			break;
 
@@ -292,7 +302,6 @@ print_ipt(struct action_util *au, FILE * f, struct rtattr *arg)
 	struct xtables_target *m;
 	struct rtattr *tb[TCA_IPT_MAX + 1];
 	struct xt_entry_target *t = NULL;
-	struct option *opts = NULL;
 
 	if (arg == NULL)
 		return -1;
@@ -339,21 +348,12 @@ print_ipt(struct action_util *au, FILE * f, struct rtattr *arg)
 		return -1;
 	}
 
-#if (XTABLES_VERSION_CODE >= 6)
-	opts = xtables_options_xfrm(tmp_tcipt_globals.orig_opts,
-				    tmp_tcipt_globals.opts,
-				    m->x6_options,
-				    &m->option_offset);
-#else
-	opts = xtables_merge_options(tmp_tcipt_globals.opts,
-				     m->extra_opts,
-				     &m->option_offset);
-#endif
-	if (opts == NULL) {
-		fprintf(stderr, " failed to find additional options for target %s\n\n", optarg);
+	if (get_xtables_target_opts(&tmp_tcipt_globals, m) < 0) {
+		fprintf(stderr,
+		        " failed to find additional options for target %s\n\n",
+			t->u.user.name);
 		return -1;
-	} else
-		tmp_tcipt_globals.opts = opts;
+	}
 	fprintf(f, "\ttarget ");
 	m->print(NULL, m->t, 0);
 	if (tb[TCA_IPT_INDEX] == NULL) {
-- 
2.8.2
