From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] [IPV4] fib_trie: Fix lookup error return
Date: Thu, 10 Jul 2008 14:23:37 +0100
Message-ID: <20080710132336.GO28029@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: William Boughton <bill@boughton.de>, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:58842 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754026AbYGJNXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 09:23:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit a07f5f508a4d9728c8e57d7f66294bf5b254ff7f "[IPV4] fib_trie: style
cleanup", the changes to check_leaf() and fn_trie_lookup() were wrong - where
fn_trie_lookup() would previously return a negative error value from
check_leaf(), it now returns 0.
 
Now fn_trie_lookup() doesn't appear to care about plen, so we can revert
check_leaf() to returning the error value.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Tested-by: William Boughton <bill@boughton.de>
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 394db9c..43ed894 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1357,17 +1357,17 @@ static int check_leaf(struct trie *t, struct leaf *l,
 			t->stats.semantic_match_miss++;
 #endif
 		if (err <= 0)
-			return plen;
+			return err;
 	}
 
-	return -1;
+	return 1;
 }
 
 static int fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
 			  struct fib_result *res)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
-	int plen, ret = 0;
+	int ret;
 	struct node *n;
 	struct tnode *pn;
 	int pos, bits;
@@ -1391,10 +1391,7 @@ static int fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
 
 	/* Just a leaf? */
 	if (IS_LEAF(n)) {
-		plen = check_leaf(t, (struct leaf *)n, key, flp, res);
-		if (plen < 0)
-			goto failed;
-		ret = 0;
+		ret = check_leaf(t, (struct leaf *)n, key, flp, res);
 		goto found;
 	}
 
@@ -1419,11 +1416,9 @@ static int fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
 		}
 
 		if (IS_LEAF(n)) {
-			plen = check_leaf(t, (struct leaf *)n, key, flp, res);
-			if (plen < 0)
+			ret = check_leaf(t, (struct leaf *)n, key, flp, res);
+			if (ret > 0)
 				goto backtrace;
-
-			ret = 0;
 			goto found;
 		}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
