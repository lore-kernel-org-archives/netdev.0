From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/9] tc: m_xt: Fix segfault when adding multiple actions at once
Date: Fri, 10 Jun 2016 13:42:01 +0200
Message-ID: <1465558928-19657-3-git-send-email-phil@nwl.cc>
References: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36637 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752706AbcFJLmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:42:47 -0400
In-Reply-To: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this, the following call to tc would segfault:

| tc filter add dev d0 parent ffff: u32 match u32 0 0 \
| 	action xt -j MARK --set-mark 0x1 \
| 	action xt -j MARK --set-mark 0x1

The reason is basically the same as for 6e2e5ec28bad4 ("fix print_ipt:
segfault if more then one filter with action -j MARK.") but in
parse_ipt() instead of print_ipt().

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index 62ec6d7f18e73..45d86d66248d4 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -133,7 +133,9 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	__u32 hook = 0, index = 0;
 	struct option *opts = NULL;
 
-	xtables_init_all(&tcipt_globals, NFPROTO_IPV4);
+	/* copy tcipt_globals because .opts will be modified by iptables */
+	struct xtables_globals tmp_tcipt_globals = tcipt_globals;
+	xtables_init_all(&tmp_tcipt_globals, NFPROTO_IPV4);
 	set_lib_dir();
 
 	{
@@ -153,7 +155,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	}
 
 	while (1) {
-		c = getopt_long(argc, argv, "j:", tcipt_globals.opts, NULL);
+		c = getopt_long(argc, argv, "j:", tmp_tcipt_globals.opts, NULL);
 		if (c == -1)
 			break;
 		switch (c) {
@@ -166,12 +168,12 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 					return -1;
 				}
 #if (XTABLES_VERSION_CODE >= 6)
-			opts = xtables_options_xfrm(tcipt_globals.orig_opts,
-						    tcipt_globals.opts,
+			opts = xtables_options_xfrm(tmp_tcipt_globals.orig_opts,
+						    tmp_tcipt_globals.opts,
 						    m->x6_options,
 						    &m->option_offset);
 #else
-			opts = xtables_merge_options(tcipt_globals.opts,
+			opts = xtables_merge_options(tmp_tcipt_globals.opts,
 						     m->extra_opts,
 						     &m->option_offset);
 #endif
@@ -179,7 +181,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 				fprintf(stderr, " failed to find additional options for target %s\n\n", optarg);
 				return -1;
 			} else
-				tcipt_globals.opts = opts;
+				tmp_tcipt_globals.opts = opts;
 			} else {
 				fprintf(stderr, " failed to find target %s\n\n", optarg);
 				return -1;
-- 
2.8.2
