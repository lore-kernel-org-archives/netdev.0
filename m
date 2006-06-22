From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 31/32] [TIPC] Get rid of dynamically allocated arrays in broadcast code.
Date: Thu, 22 Jun 2006 15:59:44 +0200
Message-ID: <1150984788496-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:45718 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030667AbWFVN7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:54 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This change improves an earlier change which replaced the large local
variable arrays used during broadcasting with dynamically allocated arrays.
The temporary arrays are now incoprorated into the multicast link data
structure.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/bcast.c |   41 +++++++++++++++++------------------------
 1 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 1633ef2..5412804 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -81,7 +81,14 @@ struct bcbearer_pair {
  * @bearer: (non-standard) broadcast bearer structure
  * @media: (non-standard) broadcast media structure
  * @bpairs: array of bearer pairs
- * @bpairs_temp: array of bearer pairs used during creation of "bpairs"
+ * @bpairs_temp: temporary array of bearer pairs used by tipc_bcbearer_sort()
+ * @remains: temporary node map used by tipc_bcbearer_send()
+ * @remains_new: temporary node map used tipc_bcbearer_send()
+ * 
+ * Note: The fields labelled "temporary" are incorporated into the bearer
+ * to avoid consuming potentially limited stack space through the use of
+ * large local variables within multicast routines.  Concurrent access is
+ * prevented through use of the spinlock "bc_lock".
  */
 
 struct bcbearer {
@@ -89,6 +96,8 @@ struct bcbearer {
 	struct media media;
 	struct bcbearer_pair bpairs[MAX_BEARERS];
 	struct bcbearer_pair bpairs_temp[TIPC_MAX_LINK_PRI + 1];
+	struct node_map remains;
+	struct node_map remains_new;
 };
 
 /**
@@ -551,12 +560,8 @@ static int tipc_bcbearer_send(struct sk_
 {
 	static int send_count = 0;
 
-	struct node_map *remains;
-	struct node_map *remains_new;
-	struct node_map *remains_tmp;
 	int bp_index;
 	int swap_time;
-	int err;
 
 	/* Prepare buffer for broadcasting (if first time trying to send it) */
 
@@ -577,9 +582,7 @@ static int tipc_bcbearer_send(struct sk_
 
 	/* Send buffer over bearers until all targets reached */
 	
-	remains = kmalloc(sizeof(struct node_map), GFP_ATOMIC);
-	remains_new = kmalloc(sizeof(struct node_map), GFP_ATOMIC);
-	*remains = tipc_cltr_bcast_nodes;
+	bcbearer->remains = tipc_cltr_bcast_nodes;
 
 	for (bp_index = 0; bp_index < MAX_BEARERS; bp_index++) {
 		struct bearer *p = bcbearer->bpairs[bp_index].primary;
@@ -588,8 +591,8 @@ static int tipc_bcbearer_send(struct sk_
 		if (!p)
 			break;	/* no more bearers to try */
 
-		tipc_nmap_diff(remains, &p->nodes, remains_new);
-		if (remains_new->count == remains->count)
+		tipc_nmap_diff(&bcbearer->remains, &p->nodes, &bcbearer->remains_new);
+		if (bcbearer->remains_new.count == bcbearer->remains.count)
 			continue;	/* bearer pair doesn't add anything */
 
 		if (!p->publ.blocked &&
@@ -607,27 +610,17 @@ swap:
 		bcbearer->bpairs[bp_index].primary = s;
 		bcbearer->bpairs[bp_index].secondary = p;
 update:
-		if (remains_new->count == 0) {
-			err = TIPC_OK;
-			goto out;
-		}
+		if (bcbearer->remains_new.count == 0)
+			return TIPC_OK;
 
-		/* swap map */
-		remains_tmp = remains;
-		remains = remains_new;
-		remains_new = remains_tmp;
+		bcbearer->remains = bcbearer->remains_new;
 	}
 	
 	/* Unable to reach all targets */
 
 	bcbearer->bearer.publ.blocked = 1;
 	bcl->stats.bearer_congs++;
-	err = ~TIPC_OK;
-
- out:
-	kfree(remains_new);
-	kfree(remains);
-	return err;
+	return ~TIPC_OK;
 }
 
 /**
-- 
1.4.0

