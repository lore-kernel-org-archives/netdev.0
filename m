From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: [PATCH v2 1/2] tipc: tipc_bcbearer_send(): simplify bearer selection
Date: Mon, 29 Apr 2013 16:13:39 +0200
Message-ID: <1367244820-29881-1-git-send-email-gerlando.falauto@keymile.com>
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, holger.brunck@keymile.com,
	Gerlando Falauto <gerlando.falauto@keymile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:51963 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758053Ab3D2OWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 10:22:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also some minor cosmetic improvements and comment style changes

Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
---
 net/tipc/bcast.c |   29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 2655c9f..be1f945 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -584,8 +584,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 {
 	int bp_index;
 
-	/*
-	 * Prepare broadcast link message for reliable transmission,
+	/* Prepare broadcast link message for reliable transmission,
 	 * if first time trying to send it;
 	 * preparation is skipped for broadcast link protocol messages
 	 * since they are sent in an unreliable manner and don't need it
@@ -610,31 +609,33 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 
 	for (bp_index = 0; bp_index < MAX_BEARERS; bp_index++) {
 		struct tipc_bearer *p = bcbearer->bpairs[bp_index].primary;
+		struct tipc_bearer *b = p;
 		struct tipc_bearer *s = bcbearer->bpairs[bp_index].secondary;
 
 		if (!p)
-			break;	/* no more bearers to try */
+			break;	/* No more bearers to try */
+
+		if (tipc_bearer_blocked(p)) {
+			if (!s || tipc_bearer_blocked(s))
+				continue; /* Can't use either bearer */
+			b = s;
+		}
 
-		tipc_nmap_diff(&bcbearer->remains, &p->nodes, &bcbearer->remains_new);
+		tipc_nmap_diff(&bcbearer->remains, &b->nodes,
+			&bcbearer->remains_new);
 		if (bcbearer->remains_new.count == bcbearer->remains.count)
-			continue;	/* bearer pair doesn't add anything */
+			continue;  /* Nothing added by bearer pair */
 
-		if (!tipc_bearer_blocked(p))
-			tipc_bearer_send(p, buf, &p->media->bcast_addr);
-		else if (s && !tipc_bearer_blocked(s))
-			/* unable to send on primary bearer */
-			tipc_bearer_send(s, buf, &s->media->bcast_addr);
-		else
-			/* unable to send on either bearer */
-			continue;
+		tipc_bearer_send(b, buf, &s->media->bcast_addr);
 
+		/* Swap bearers for next packet */
 		if (s) {
 			bcbearer->bpairs[bp_index].primary = s;
 			bcbearer->bpairs[bp_index].secondary = p;
 		}
 
 		if (bcbearer->remains_new.count == 0)
-			break;	/* all targets reached */
+			break;	/* All targets reached */
 
 		bcbearer->remains = bcbearer->remains_new;
 	}
-- 
1.7.10.1
