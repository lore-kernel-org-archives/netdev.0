From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 6/7] tc/m_xt: Fix for potential string buffer overflows
Date: Thu, 17 Aug 2017 19:09:31 +0200
Message-ID: <20170817170932.24659-7-phil@nwl.cc>
References: <20170817170932.24659-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37495 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753346AbdHQRKO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:10:14 -0400
In-Reply-To: <20170817170932.24659-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Use strncpy() when writing to target->t->u.user.name and make sure the
  final byte remains untouched (xtables_calloc() set it to zero).
- 'tname' length sanitization was completely wrong: If it's length
  exceeded the 16 bytes available in 'k', passing a length value of 16
  to strncpy() would overwrite the previously NULL'ed 'k[15]'. Also, the
  sanitization has to happen if 'tname' is exactly 16 bytes long as
  well.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index ad52d239caf61..9218b14594403 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -95,7 +95,8 @@ build_st(struct xtables_target *target, struct xt_entry_target *t)
 	if (t == NULL) {
 		target->t = xtables_calloc(1, size);
 		target->t->u.target_size = size;
-		strcpy(target->t->u.user.name, target->name);
+		strncpy(target->t->u.user.name, target->name,
+			sizeof(target->t->u.user.name) - 1);
 		target->t->u.user.revision = target->revision;
 
 		if (target->init != NULL)
@@ -277,8 +278,8 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	}
 	fprintf(stdout, " index %d\n", index);
 
-	if (strlen(tname) > 16) {
-		size = 16;
+	if (strlen(tname) >= 16) {
+		size = 15;
 		k[15] = 0;
 	} else {
 		size = 1 + strlen(tname);
-- 
2.13.1
