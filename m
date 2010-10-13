From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib_trie: use fls() instead of open coded loop
Date: Wed, 13 Oct 2010 18:56:11 +0200
Message-ID: <1286988971.3876.974.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55799 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab0JMQ4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 12:56:16 -0400
Received: by wyb28 with SMTP id 28so1251380wyb.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 09:56:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_table_lookup() might use fls() to speedup an open coded loop.

Noticed while doing a profile analysis.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_trie.c |   16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 271c89b..31494f3 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1384,8 +1384,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
 	t_key cindex = 0;
 	int current_prefix_length = KEYLENGTH;
 	struct tnode *cn;
-	t_key node_prefix, key_prefix, pref_mismatch;
-	int mp;
+	t_key pref_mismatch;
 
 	rcu_read_lock();
 
@@ -1500,10 +1499,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
 		 * matching prefix.
 		 */
 
-		node_prefix = mask_pfx(cn->key, cn->pos);
-		key_prefix = mask_pfx(key, cn->pos);
-		pref_mismatch = key_prefix^node_prefix;
-		mp = 0;
+		pref_mismatch = mask_pfx(cn->key ^ key, cn->pos);
 
 		/*
 		 * In short: If skipped bits in this node do not match
@@ -1511,13 +1507,9 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
 		 * state.directly.
 		 */
 		if (pref_mismatch) {
-			while (!(pref_mismatch & (1<<(KEYLENGTH-1)))) {
-				mp++;
-				pref_mismatch = pref_mismatch << 1;
-			}
-			key_prefix = tkey_extract_bits(cn->key, mp, cn->pos-mp);
+			int mp = KEYLENGTH - fls(pref_mismatch);
 
-			if (key_prefix != 0)
+			if (tkey_extract_bits(cn->key, mp, cn->pos - mp) != 0)
 				goto backtrace;
 
 			if (current_prefix_length >= cn->pos)


