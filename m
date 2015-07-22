From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 1/2] ipv4: fib_select_default should match the prefix
Date: Wed, 22 Jul 2015 10:43:22 +0300
Message-ID: <1437551003-25537-2-git-send-email-ja@ssi.bg>
References: <1437551003-25537-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38474 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755895AbbGVHoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 03:44:24 -0400
In-Reply-To: <1437551003-25537-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_trie starting from 4.1 can link fib aliases from
different prefixes in same list. Make sure the alternative
gateways are in same table and for same prefix (0) by
checking tb_id and fa_slen.

Fixes: 79e5ad2ceb00 ("fib_trie: Remove leaf_info")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/fib_semantics.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c7358ea..e107958 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1207,12 +1207,17 @@ void fib_select_default(struct fib_result *res)
 	struct fib_info *fi = NULL, *last_resort = NULL;
 	struct hlist_head *fa_head = res->fa_head;
 	struct fib_table *tb = res->table;
+	u8 slen = 32 - res->prefixlen;
 	int order = -1, last_idx = -1;
 	struct fib_alias *fa;
 
 	hlist_for_each_entry_rcu(fa, fa_head, fa_list) {
 		struct fib_info *next_fi = fa->fa_info;
 
+		if (fa->fa_slen != slen)
+			continue;
+		if (fa->tb_id != tb->tb_id)
+			continue;
 		if (next_fi->fib_scope != res->scope ||
 		    fa->fa_type != RTN_UNICAST)
 			continue;
-- 
1.9.3
