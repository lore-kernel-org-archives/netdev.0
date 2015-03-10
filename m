From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] fib_trie: Address possible NULL pointer
 dereference in resize
Date: Tue, 10 Mar 2015 14:39:34 -0700
Message-ID: <20150310213929.2235.18452.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dan.carpenter@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129AbbCJVjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 17:39:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the inflate call failed it would return NULL.  As a result tp would be
set to NULL and cause use to trigger a NULL pointer dereference in
should_halve if the inflate failed on the first attempt.

In order to prevent this we should decrement max_work before we actually
attempt to inflate as this will force us to exit before attempting to halve
a node we should have inflated.  In order to keep things symmetric between
inflate and halve I went ahead and also moved the decrement of max_work for
the halve case as well so we take care of that before we actually attempt
to halve the tnode.

Fixes: 88bae714 ("fib_trie: Add key vector to root, return parent key_vector in resize")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 44cab1d..83290be 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -830,7 +830,7 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 	/* Double as long as the resulting node has a number of
 	 * nonempty nodes that are above the threshold.
 	 */
-	while (should_inflate(tp, tn) && max_work) {
+	while (should_inflate(tp, tn) && max_work--) {
 		tp = inflate(t, tn);
 		if (!tp) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -839,7 +839,6 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 			break;
 		}
 
-		max_work--;
 		tn = get_child(tp, cindex);
 	}
 
@@ -850,7 +849,7 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 	/* Halve as long as the number of empty children in this
 	 * node is above threshold.
 	 */
-	while (should_halve(tp, tn) && max_work) {
+	while (should_halve(tp, tn) && max_work--) {
 		tp = halve(t, tn);
 		if (!tp) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -859,7 +858,6 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 			break;
 		}
 
-		max_work--;
 		tn = get_child(tp, cindex);
 	}
 
