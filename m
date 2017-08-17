From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 7/7] tc/m_gact: Drop dead code
Date: Thu, 17 Aug 2017 19:09:31 +0200
Message-ID: <20170817170931.24089-8-phil@nwl.cc>
References: <20170817170931.24089-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46129 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdHQRLz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:11:55 -0400
In-Reply-To: <20170817170931.24089-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of 'ok' variable in parse_gact() is ineffective: The second
conditional increments it either if *argv is 'gact' or if
parse_action_control() doesn't fail (in which case exit() is called).
So this is effectively an unconditional increment and since no decrement
happens anywhere, all remaining checks for 'ok != 0' can be dropped.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_gact.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/tc/m_gact.c b/tc/m_gact.c
index 1a2583372c34e..df143c9e0953e 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -76,7 +76,6 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 {
 	int argc = *argc_p;
 	char **argv = *argv_p;
-	int ok = 0;
 	struct tc_gact p = { 0 };
 #ifdef CONFIG_GACT_PROB
 	int rd = 0;
@@ -89,17 +88,14 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 
 
 	if (matches(*argv, "gact") == 0) {
-		ok++;
 		argc--;
 		argv++;
-	} else {
-		if (parse_action_control(&argc, &argv, &p.action, false) == -1)
-			usage();
-		ok++;
+	} else if (parse_action_control(&argc, &argv, &p.action, false) == -1) {
+		usage();	/* does not return */
 	}
 
 #ifdef CONFIG_GACT_PROB
-	if (ok && argc > 0) {
+	if (argc > 0) {
 		if (matches(*argv, "random") == 0) {
 			rd = 1;
 			NEXT_ARG();
@@ -142,15 +138,11 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 			}
 			argc--;
 			argv++;
-			ok++;
 		} else if (matches(*argv, "help") == 0) {
 				usage();
 		}
 	}
 
-	if (!ok)
-		return -1;
-
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
 	addattr_l(n, MAX_MSG, TCA_GACT_PARMS, &p, sizeof(p));
-- 
2.13.1
