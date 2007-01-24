From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Fix the fib trie iterator to work with a single entry routing tables
Date: Wed, 24 Jan 2007 12:56:25 -0700
Message-ID: <m17ivc19na.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <robert.olsson@its.uu.se>, davem@davemloft.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:54037 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbXAXT47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 14:56:59 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In a kernel with trie routing enabled I had a simple routing setup
with only a single route to the outside world and no default
route. "ip route table list main" showed my the route just fine but
/proc/net/route was an empty file.  What was going on?

Thinking it was a bug in something I did and I looked deeper.  Eventually
I setup a second route and everything looked correct, huh?  Finally I
realized that the it was just the iterator pair in fib_trie_get_first,
fib_trie_get_next just could not handle a routing table with a single entry.

So to save myself and others further confusion, here is a simple fix for
the fib proc iterator so it works even when there is only a single route
in a routing table.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/fib_trie.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index cfb249c..13307c0 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1989,6 +1989,10 @@ static struct node *fib_trie_get_next(struct fib_trie_iter *iter)
 	unsigned cindex = iter->index;
 	struct tnode *p;
 
+	/* A single entry routing table */
+	if (!tn)
+		return NULL;
+
 	pr_debug("get_next iter={node=%p index=%d depth=%d}\n",
 		 iter->tnode, iter->index, iter->depth);
 rescan:
@@ -2037,11 +2041,18 @@ static struct node *fib_trie_get_first(struct fib_trie_iter *iter,
 	if(!iter)
 		return NULL;
 
-	if (n && IS_TNODE(n)) {
-		iter->tnode = (struct tnode *) n;
-		iter->trie = t;
-		iter->index = 0;
-		iter->depth = 1;
+	if (n) {
+		if (IS_TNODE(n)) {
+			iter->tnode = (struct tnode *) n;
+			iter->trie = t;
+			iter->index = 0;
+			iter->depth = 1;
+		} else {
+			iter->tnode = NULL;
+			iter->trie  = t;
+			iter->index = 0;
+			iter->depth = 0;
+		}
 		return n;
 	}
 	return NULL;
-- 
1.4.4.1.g278f

