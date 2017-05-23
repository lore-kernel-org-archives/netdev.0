From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc: m_xt: Prevent a segfault in libipt
Date: Tue, 23 May 2017 15:40:57 +0200
Message-ID: <20170523134057.23775-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Phil Sutter <psutter@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50681 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967803AbdEWNlK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 09:41:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <psutter@redhat.com>

This happens with NAT targets, such as SNAT, DNAT and MASQUERADE. These
are still not usable with this patch, but at least tc doesn't crash
anymore when one tries to use them.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index e59df8e10afef..ad52d239caf61 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -146,6 +146,9 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 		     char ***argv_p, int tca_id, struct nlmsghdr *n)
 {
 	struct xtables_target *m = NULL;
+#if XTABLES_VERSION_CODE >= 6
+	struct ipt_entry fw = {};
+#endif
 	struct rtattr *tail;
 
 	int c;
@@ -206,7 +209,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 		default:
 #if XTABLES_VERSION_CODE >= 6
 			if (m != NULL && m->x6_parse != NULL) {
-				xtables_option_tpcall(c, argv, 0, m, NULL);
+				xtables_option_tpcall(c, argv, 0, m, &fw);
 #else
 			if (m != NULL && m->parse != NULL) {
 				m->parse(c - m->option_offset, argv, 0,
-- 
2.11.0
