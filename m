From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] fib_trie: Correctly handle case of key == 0 in
 leaf_walk_rcu
Date: Tue, 10 Mar 2015 11:25:41 -0700
Message-ID: <20150310182512.1320.1169.stgit@ahduyck-vm-fedora20>
References: <20150310170746.GA1743@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sd@queasysnail.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49795 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbbCJSZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 14:25:48 -0400
In-Reply-To: <20150310170746.GA1743@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case of a trie that had no tnodes with a key of 0 the initial
look-up would fail resulting in an out-of-bounds cindex on the first tnode.
This resulted in an entire trie being skipped.

In order resolve this I have updated the cindex logic in the initial
look-up so that if the key is zero we will always traverse the child zero
path.

Fixes: 8be33e95 ("fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf")
Reported-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index fcfa982..44cab1d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1530,7 +1530,7 @@ static struct key_vector *leaf_walk_rcu(struct key_vector **tn, t_key key)
 	do {
 		/* record parent and next child index */
 		pn = n;
-		cindex = get_index(key, pn);
+		cindex = key ? get_index(key, pn) : 0;
 
 		if (cindex >> pn->bits)
 			break;
