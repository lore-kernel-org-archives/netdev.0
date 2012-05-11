From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Do not use dead fib_info entries.
Date: Thu, 10 May 2012 22:17:15 -0400 (EDT)
Message-ID: <20120510.221715.297338661038042732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgen.pronenko@sonymobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758485Ab2EKCRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 22:17:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Due to RCU lookups and RCU based release, fib_info objects can
be found during lookup which have fi->fib_dead set.

We must ignore these entries, otherwise we risk dereferencing
the parts of the entry which are being torn down.

Reported-by: Yevgen Pronenko <yevgen.pronenko@sonymobile.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_trie.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index bce36f1..30b88d7 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1370,6 +1370,8 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 
 			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
 				continue;
+			if (fi->fib_dead)
+				continue;
 			if (fa->fa_info->fib_scope < flp->flowi4_scope)
 				continue;
 			fib_alias_accessed(fa);
-- 
1.7.10.1
