From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [next-next PATCH 3/7] fib_trie: Fall back to slen update on
 inflate/halve failure
Date: Thu, 22 Jan 2015 15:51:20 -0800
Message-ID: <20150122235120.5779.51785.stgit@ahduyck-vm-fedora20>
References: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371AbbAVXvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 18:51:22 -0500
In-Reply-To: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change corrects an issue where if inflate or halve fails we were
exiting the resize function without at least updating the slen for the
node.  To correct this I have moved the update of max_size into the while
loop so that it is only decremented on a successful call to either inflate
or halve.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 7e90317..80892f5 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -752,7 +752,7 @@ static void resize(struct trie *t, struct tnode *tn)
 {
 	struct tnode *tp = node_parent(tn), *n = NULL;
 	struct tnode __rcu **cptr;
-	int max_work;
+	int max_work = MAX_WORK;
 
 	pr_debug("In tnode_resize %p inflate_threshold=%d threshold=%d\n",
 		 tn, inflate_threshold, halve_threshold);
@@ -775,8 +775,7 @@ static void resize(struct trie *t, struct tnode *tn)
 	/* Double as long as the resulting node has a number of
 	 * nonempty nodes that are above the threshold.
 	 */
-	max_work = MAX_WORK;
-	while (should_inflate(tp, tn) && max_work--) {
+	while (should_inflate(tp, tn) && max_work) {
 		if (inflate(t, tn)) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			this_cpu_inc(t->stats->resize_node_skipped);
@@ -784,6 +783,7 @@ static void resize(struct trie *t, struct tnode *tn)
 			break;
 		}
 
+		max_work--;
 		tn = rtnl_dereference(*cptr);
 	}
 
@@ -794,8 +794,7 @@ static void resize(struct trie *t, struct tnode *tn)
 	/* Halve as long as the number of empty children in this
 	 * node is above threshold.
 	 */
-	max_work = MAX_WORK;
-	while (should_halve(tp, tn) && max_work--) {
+	while (should_halve(tp, tn) && max_work) {
 		if (halve(t, tn)) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			this_cpu_inc(t->stats->resize_node_skipped);
@@ -803,6 +802,7 @@ static void resize(struct trie *t, struct tnode *tn)
 			break;
 		}
 
+		max_work--;
 		tn = rtnl_dereference(*cptr);
 	}
 
