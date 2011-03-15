From: kaber@trash.net
Subject: [PATCH 02/37] netfilter: x_tables: misuse of try_then_request_module
Date: Tue, 15 Mar 2011 20:43:42 +0100
Message-ID: <1300218257-26953-3-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49419 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755392Ab1COTo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:26 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Since xt_find_match() returns ERR_PTR(xx) on error not NULL,
the macro try_then_request_module won't work correctly here.
The macro expects its first argument will be zero if condition
fails. But ERR_PTR(-ENOENT) is not zero.

The correct solution is to propagate the error value
back.

Found by inspection, and compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/x_tables.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 0a77d2f..271eed3 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -183,7 +183,7 @@ EXPORT_SYMBOL(xt_unregister_matches);
 /*
  * These are weird, but module loading must not be done with mutex
  * held (since they will register), and we have to have a single
- * function to use try_then_request_module().
+ * function to use.
  */
 
 /* Find match, grabs ref.  Returns ERR_PTR() on error. */
@@ -221,9 +221,13 @@ xt_request_find_match(uint8_t nfproto, const char *name, uint8_t revision)
 {
 	struct xt_match *match;
 
-	match = try_then_request_module(xt_find_match(nfproto, name, revision),
-					"%st_%s", xt_prefix[nfproto], name);
-	return (match != NULL) ? match : ERR_PTR(-ENOENT);
+	match = xt_find_match(nfproto, name, revision);
+	if (IS_ERR(match)) {
+		request_module("%st_%s", xt_prefix[nfproto], name);
+		match = xt_find_match(nfproto, name, revision);
+	}
+
+	return match;
 }
 EXPORT_SYMBOL_GPL(xt_request_find_match);
 
@@ -261,9 +265,13 @@ struct xt_target *xt_request_find_target(u8 af, const char *name, u8 revision)
 {
 	struct xt_target *target;
 
-	target = try_then_request_module(xt_find_target(af, name, revision),
-					 "%st_%s", xt_prefix[af], name);
-	return (target != NULL) ? target : ERR_PTR(-ENOENT);
+	target = xt_find_target(af, name, revision);
+	if (IS_ERR(target)) {
+		request_module("%st_%s", xt_prefix[af], name);
+		target = xt_find_target(af, name, revision);
+	}
+
+	return target;
 }
 EXPORT_SYMBOL_GPL(xt_request_find_target);
 
-- 
1.7.2.3

