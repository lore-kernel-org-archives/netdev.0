From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: [PATCH v5 2/3] tipc: tipc_bcbearer_send(): simplify bearer selection
Date: Thu,  2 May 2013 00:04:45 +0200
Message-ID: <1367445886-30879-2-git-send-email-gerlando.falauto@keymile.com>
References: <1367445886-30879-1-git-send-email-gerlando.falauto@keymile.com>
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, holger.brunck@keymile.com,
	Gerlando Falauto <gerlando.falauto@keymile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:41916 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434Ab3EAWFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 18:05:02 -0400
In-Reply-To: <1367445886-30879-1-git-send-email-gerlando.falauto@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
---
Changes from v4:
* Rebased on net-next 
* fixed bcast_addr (no longer within b->media)
Changes from v3: NONE
Changes from v2:
* Fixed non-bisectability; was tipc_bearer_send(b, buf, &s->media...)

 net/tipc/bcast.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 0e2f432..d9d848d 100644
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
-			tipc_bearer_send(p, buf, &p->bcast_addr);
-		else if (s && !tipc_bearer_blocked(s))
-			/* unable to send on primary bearer */
-			tipc_bearer_send(s, buf, &s->bcast_addr);
-		else
-			/* unable to send on either bearer */
-			continue;
+		tipc_bearer_send(b, buf, &b->bcast_addr);
 
 		/* Swap bearers for next packet */
 		if (s) {
-- 
1.7.10.1
