From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] ipv4: fib_trie: Use tnode_get_child_rcu() and
	node_parent_rcu() in lookups
Date: Tue, 14 Jul 2009 23:20:32 +0200
Message-ID: <20090714212032.GB7952@ami.dom.local>
References: <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <4A4FF40B.5090003@itcare.pl> <20090705162003.GA19477@ami.dom.local> <20090705173208.GB19477@ami.dom.local> <20090705213232.GG8943@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:34950 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756525AbZGNVUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 17:20:46 -0400
Received: by bwz28 with SMTP id 28so1046649bwz.37
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 14:20:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090705213232.GG8943@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While looking for other fib_trie problems reported by Pawel Staszewski
I noticed there are a few uses of tnode_get_child() and node_parent()
in lookups instead of their rcu versions.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
(this patch was prepared on top of my 2 today's fib_trie patches)

diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c	2009-07-14 20:40:39.000000000 +0200
+++ b/net/ipv4/fib_trie.c	2009-07-14 22:41:26.000000000 +0200
@@ -1465,7 +1465,7 @@ static int fn_trie_lookup(struct fib_tab
 			cindex = tkey_extract_bits(mask_pfx(key, current_prefix_length),
 						   pos, bits);
 
-		n = tnode_get_child(pn, cindex);
+		n = tnode_get_child_rcu(pn, cindex);
 
 		if (n == NULL) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -1600,7 +1600,7 @@ backtrace:
 		if (chopped_off <= pn->bits) {
 			cindex &= ~(1 << (chopped_off-1));
 		} else {
-			struct tnode *parent = node_parent((struct node *) pn);
+			struct tnode *parent = node_parent_rcu((struct node *) pn);
 			if (!parent)
 				goto failed;
 
@@ -1813,7 +1813,7 @@ static struct leaf *trie_firstleaf(struc
 static struct leaf *trie_nextleaf(struct leaf *l)
 {
 	struct node *c = (struct node *) l;
-	struct tnode *p = node_parent(c);
+	struct tnode *p = node_parent_rcu(c);
 
 	if (!p)
 		return NULL;	/* trie with just one leaf */
