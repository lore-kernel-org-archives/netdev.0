From: igorm@etf.rs
Subject: [PATCH net-next] net: ipv4: Optimize check_leaf function
Date: Tue, 28 Aug 2012 10:52:17 +0200
Message-ID: <1346143938-17167-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:60391 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203Ab2H1IxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Aug 2012 04:53:07 -0400
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

If the found tos is smaller then our tos,
don't pass through all the entries in fib_alias
list to find the match.
Directly jump to the last entry in the list, and check if the
tos value is 0.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/ipv4/fib_trie.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3c820da..ec45621 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1366,8 +1366,14 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 			struct fib_info *fi = fa->fa_info;
 			int nhsel, err;
 
-			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
-				continue;
+			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos) {
+				if (fa->fa_tos < flp->flowi4_tos) {
+					fa = list_entry_rcu(li->falh.prev, struct fib_alias, fa_list);
+					if (fa->fa_tos)
+						break;
+				} else
+					continue;
+			}
 			if (fi->fib_dead)
 				continue;
 			if (fa->fa_info->fib_scope < flp->flowi4_scope)
-- 
1.7.9.5
