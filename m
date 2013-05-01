From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: [PATCH v4 3/3] tipc: pskb_copy() buffers when sending on more than one bearer
Date: Wed,  1 May 2013 19:49:17 +0200
Message-ID: <1367430557-11843-3-git-send-email-gerlando.falauto@keymile.com>
References: <1367430557-11843-1-git-send-email-gerlando.falauto@keymile.com>
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, holger.brunck@keymile.com,
	Gerlando Falauto <gerlando.falauto@keymile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:58532 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab3EARtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 13:49:33 -0400
In-Reply-To: <1367430557-11843-1-git-send-email-gerlando.falauto@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending packets, TIPC bearers use skb_clone() before writing their
hardware header. This will however NOT copy the data buffer.
So when the same packet is sent over multiple bearers (to reach multiple
nodes), the same socket buffer data will be treated by multiple
tipc_media drivers which will write their own hardware header through
dev_hard_header().
Most of the time this is not a problem, because by the time the
packet is processed by the second media, it has already been sent over
the first one. However, when the first transmission is delayed (e.g.
because of insufficient bandwidth or through a shaper), the next bearer
will overwrite the hardware header, resulting in the packet being sent:
a) with the wrong source address, when bearers of the same type,
e.g. ethernet, are involved
b) with a completely corrupt header, or even dropped, when bearers of
different types are involved.

So when the same socket buffer is to be sent multiple times, send a
pskb_copy() instead (from the second instance on), and release it
afterwards (the bearer will skb_clone() it anyway).

Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
---
Changes from v3: NONE
Changes from v2:
* Rebased

 net/tipc/bcast.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index c8f572f..a8e574d 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -611,6 +611,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		struct tipc_bearer *p = bcbearer->bpairs[bp_index].primary;
 		struct tipc_bearer *s = bcbearer->bpairs[bp_index].secondary;
 		struct tipc_bearer *b = p;
+		struct sk_buff *tbuf;
 
 		if (!p)
 			break; /* No more bearers to try */
@@ -626,7 +627,17 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		if (bcbearer->remains_new.count == bcbearer->remains.count)
 			continue; /* Nothing added by bearer pair */
 
-		tipc_bearer_send(b, buf, &b->media->bcast_addr);
+		if (bp_index == 0) {
+			/* Use original buffer for first bearer */
+			tipc_bearer_send(b, buf, &b->media->bcast_addr);
+		} else {
+			/* Avoid concurrent buffer access */
+			tbuf = pskb_copy(buf, GFP_ATOMIC);
+			if (!tbuf)
+				break;
+			tipc_bearer_send(b, tbuf, &b->media->bcast_addr);
+			kfree_skb(tbuf); /* Bearer keeps a clone */
+		}
 
 		/* Swap bearers for next packet */
 		if (s) {
-- 
1.7.10.1
