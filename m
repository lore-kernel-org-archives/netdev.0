From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] fib_trie: Fix regression in handling of
 inflate/halve failure
Date: Mon, 23 Mar 2015 11:51:53 -0700
Message-ID: <20150323185142.1079.79248.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44517 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120AbbCWSvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 14:51:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I updated the code to address a possible null pointer dereference in
resize I ended up reverting an exception handling fix for the suffix length
in the event that inflate or halve failed.  This change is meant to correct
that by reverting the earlier fix and instead simply getting the parent
again after inflate has been completed to avoid the possible null pointer
issue.

Fixes: ddb4b9a13 ("fib_trie: Address possible NULL pointer dereference in resize")
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e3b4aee..2c7c299 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -830,7 +830,7 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 	/* Double as long as the resulting node has a number of
 	 * nonempty nodes that are above the threshold.
 	 */
-	while (should_inflate(tp, tn) && max_work--) {
+	while (should_inflate(tp, tn) && max_work) {
 		tp = inflate(t, tn);
 		if (!tp) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -839,17 +839,21 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 			break;
 		}
 
+		max_work--;
 		tn = get_child(tp, cindex);
 	}
 
+	/* update parent in case inflate failed */
+	tp = node_parent(tn);
+
 	/* Return if at least one inflate is run */
 	if (max_work != MAX_WORK)
-		return node_parent(tn);
+		return tp;
 
 	/* Halve as long as the number of empty children in this
 	 * node is above threshold.
 	 */
-	while (should_halve(tp, tn) && max_work--) {
+	while (should_halve(tp, tn) && max_work) {
 		tp = halve(t, tn);
 		if (!tp) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -858,6 +862,7 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 			break;
 		}
 
+		max_work--;
 		tn = get_child(tp, cindex);
 	}
 
@@ -865,7 +870,7 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 	if (should_collapse(tn))
 		return collapse(t, tn);
 
-	/* update parent in case inflate or halve failed */
+	/* update parent in case halve failed */
 	tp = node_parent(tn);
 
 	/* Return if at least one deflate was run */
