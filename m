From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: [PATCH v3 2/3] tipc: tipc_bcbearer_send(): simplify bearer selection
Date: Tue, 30 Apr 2013 09:33:18 +0200
Message-ID: <1367307199-10577-2-git-send-email-gerlando.falauto@keymile.com>
References: <1367244820-29881-1-git-send-email-gerlando.falauto@keymile.com>
 <1367307199-10577-1-git-send-email-gerlando.falauto@keymile.com>
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, holger.brunck@keymile.com,
	Gerlando Falauto <gerlando.falauto@keymile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:56047 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162Ab3D3HjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 03:39:01 -0400
In-Reply-To: <1367307199-10577-1-git-send-email-gerlando.falauto@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
---
Changes from v2:
* Fixed non-bisectability; was tipc_bearer_send(b, buf, &s->media...)

 net/tipc/bcast.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 8438e01..c8f572f 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -610,23 +610,23 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 	for (bp_index = 0; bp_index < MAX_BEARERS; bp_index++) {
 		struct tipc_bearer *p = bcbearer->bpairs[bp_index].primary;
 		struct tipc_bearer *s = bcbearer->bpairs[bp_index].secondary;
+		struct tipc_bearer *b = p;
 
 		if (!p)
 			break; /* No more bearers to try */
 
-		tipc_nmap_diff(&bcbearer->remains, &p->nodes,
+		if (tipc_bearer_blocked(p)) {
+			if (!s || tipc_bearer_blocked(s))
+				continue; /* Can't use either bearer */
+			b = s;
+		}
+
+		tipc_nmap_diff(&bcbearer->remains, &b->nodes,
 			       &bcbearer->remains_new);
 		if (bcbearer->remains_new.count == bcbearer->remains.count)
 			continue; /* Nothing added by bearer pair */
 
-		if (!tipc_bearer_blocked(p))
-			tipc_bearer_send(p, buf, &p->media->bcast_addr);
-		else if (s && !tipc_bearer_blocked(s))
-			/* unable to send on primary bearer */
-			tipc_bearer_send(s, buf, &s->media->bcast_addr);
-		else
-			/* unable to send on either bearer */
-			continue;
+		tipc_bearer_send(b, buf, &b->media->bcast_addr);
 
 		/* Swap bearers for next packet */
 		if (s) {
-- 
1.7.10.1
