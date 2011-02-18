From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/7] ipv4: Avoid use of signed integers in fib_trie code.
Date: Thu, 17 Feb 2011 16:12:07 -0800 (PST)
Message-ID: <20110217.161207.241915777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57127
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754960Ab1BRALb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:11:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3417024C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 16:12:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


GCC emits all kinds of crazy zero extensions when we go from signed
int, to unsigned short, etc. etc.

This transformation has to be legal because:

1) In tkey_extract_bits() in mask_pfx(), the values are used to
   perform shifts, on which negative values are undefined by C.

2) In fib_table_lookup() we perform comparisons with unsigned
   values, constants, and additions.  None of which should
   encounter negative values.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_trie.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1eae90b..edf3b09 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -217,12 +217,12 @@ static inline int tnode_child_length(const struct tnode *tn)
 	return 1 << tn->bits;
 }
 
-static inline t_key mask_pfx(t_key k, unsigned short l)
+static inline t_key mask_pfx(t_key k, unsigned int l)
 {
 	return (l == 0) ? 0 : k >> (KEYLENGTH-l) << (KEYLENGTH-l);
 }
 
-static inline t_key tkey_extract_bits(t_key a, int offset, int bits)
+static inline t_key tkey_extract_bits(t_key a, unsigned int offset, unsigned int bits)
 {
 	if (offset < KEYLENGTH)
 		return ((t_key)(a << offset)) >> (KEYLENGTH - bits);
@@ -1378,11 +1378,11 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
 	int ret;
 	struct rt_trie_node *n;
 	struct tnode *pn;
-	int pos, bits;
+	unsigned int pos, bits;
 	t_key key = ntohl(flp->fl4_dst);
-	int chopped_off;
+	unsigned int chopped_off;
 	t_key cindex = 0;
-	int current_prefix_length = KEYLENGTH;
+	unsigned int current_prefix_length = KEYLENGTH;
 	struct tnode *cn;
 	t_key pref_mismatch;
 
-- 
1.7.4.1

