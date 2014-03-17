From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 32/38] netfilter: connlimit: improve packet-to-closed-connection logic
Date: Mon, 17 Mar 2014 13:42:52 +0100
Message-ID: <1395060178-11833-33-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59531 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933066AbaCQMnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:50 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Instead of freeing the entry from our list and then adding
it back again in the 'packet to closing connection' case just keep the
matching entry around.  Also drop the found_ct != NULL test as
nf_ct_tuplehash_to_ctrack is just container_of().

Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connlimit.c |   23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 6988818..d4c6db1 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -112,29 +112,22 @@ static int count_hlist(struct net *net,
 	hlist_for_each_entry_safe(conn, n, head, node) {
 		found    = nf_conntrack_find_get(net, NF_CT_DEFAULT_ZONE,
 						 &conn->tuple);
-		found_ct = NULL;
+		if (found == NULL) {
+			hlist_del(&conn->node);
+			kfree(conn);
+			continue;
+		}
 
-		if (found != NULL)
-			found_ct = nf_ct_tuplehash_to_ctrack(found);
+		found_ct = nf_ct_tuplehash_to_ctrack(found);
 
-		if (found_ct != NULL &&
-		    nf_ct_tuple_equal(&conn->tuple, tuple) &&
-		    !already_closed(found_ct))
+		if (nf_ct_tuple_equal(&conn->tuple, tuple)) {
 			/*
 			 * Just to be sure we have it only once in the list.
 			 * We should not see tuples twice unless someone hooks
 			 * this into a table without "-p tcp --syn".
 			 */
 			addit = false;
-
-		if (found == NULL) {
-			/* this one is gone */
-			hlist_del(&conn->node);
-			kfree(conn);
-			continue;
-		}
-
-		if (already_closed(found_ct)) {
+		} else if (already_closed(found_ct)) {
 			/*
 			 * we do not care about connections which are
 			 * closed already -> ditch it
-- 
1.7.10.4
