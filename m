From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] tipc: Increase frequency of load distribution over broadcast
 link
Date: Mon, 15 Mar 2010 14:02:24 -0400
Message-ID: <20100315180223.GC24528@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@tuxdriver.com,
	allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51604 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933721Ab0COSC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 14:02:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forward port commit 29eb572941501c40ac6e62dbc5043bf9ee76ee56
from git://tipc.cslab.ericsson.net/pub/git/people/allan/tipc.git

Origional commit message:
Increase frequency of load distribution over broadcast link

This patch enhances the behavior of TIPC's broadcast link so that it
alternates between redundant bearers (if available) after every
message sent, rather than after every 10 messages.  This change helps
to speed up delivery of retransmitted messages by ensuring that
they are not sent repeatedly over a bearer that is no longer working,
but not yet recognized as failed.

Tested by myself in the latest net-2.6 tree using the tipc sanity test suite

Origionally-signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


bcast.c |   35 ++++++++++++++---------------------
1 file changed, 14 insertions(+), 21 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index a3bfd40..90a0519 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -558,10 +558,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 			      struct tipc_bearer *unused1,
 			      struct tipc_media_addr *unused2)
 {
-	static int send_count = 0;
-
 	int bp_index;
-	int swap_time;
 
 	/* Prepare buffer for broadcasting (if first time trying to send it) */
 
@@ -575,11 +572,6 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		msg_set_mc_netid(msg, tipc_net_id);
 	}
 
-	/* Determine if bearer pairs should be swapped following this attempt */
-
-	if ((swap_time = (++send_count >= 10)))
-		send_count = 0;
-
 	/* Send buffer over bearers until all targets reached */
 
 	bcbearer->remains = tipc_cltr_bcast_nodes;
@@ -595,21 +587,22 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		if (bcbearer->remains_new.count == bcbearer->remains.count)
 			continue;	/* bearer pair doesn't add anything */
 
-		if (!p->publ.blocked &&
-		    !p->media->send_msg(buf, &p->publ, &p->media->bcast_addr)) {
-			if (swap_time && s && !s->publ.blocked)
-				goto swap;
-			else
-				goto update;
+		if (p->publ.blocked ||
+		    p->media->send_msg(buf, &p->publ, &p->media->bcast_addr)) {
+			/* unable to send on primary bearer */
+			if (!s || s->publ.blocked ||
+			    s->media->send_msg(buf, &s->publ,
+					       &s->media->bcast_addr)) {
+				/* unable to send on either bearer */
+				continue;
+			}
+		}
+
+		if (s) {
+			bcbearer->bpairs[bp_index].primary = s;
+			bcbearer->bpairs[bp_index].secondary = p;
 		}
 
-		if (!s || s->publ.blocked ||
-		    s->media->send_msg(buf, &s->publ, &s->media->bcast_addr))
-			continue;	/* unable to send using bearer pair */
-swap:
-		bcbearer->bpairs[bp_index].primary = s;
-		bcbearer->bpairs[bp_index].secondary = p;
-update:
 		if (bcbearer->remains_new.count == 0)
 			return 0;
 
