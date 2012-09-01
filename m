From: =?UTF-8?q?Dave=20T=C3=A4ht?= <dave.taht@bufferbloat.net>
Subject: [PATCH] codel: reduce default maxpacket and reinitialize upon re-entering drop state
Date: Sat,  1 Sep 2012 11:50:57 -0700
Message-ID: <1346525457-31481-1-git-send-email-dave.taht@bufferbloat.net>
Cc: Dave Taht <dave.taht@bufferbloat.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.bufferbloat.net ([149.20.54.82]:56847 "EHLO
	huchra.bufferbloat.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab2IATBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2012 15:01:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Taht <dave.taht@bufferbloat.net>

The minimum size packet in a queue is 64, not 256.

Also, as ethtool can be used to remove tso/gso/ufo, the last seen
maxpacket can vary considerably in size (e.g. 64k). So reset it
on re-entering the drop scheduler to the most recent packet size,
and let it grow again naturally.

Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
---
 include/net/codel.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index 389cf62..0b0ac5e 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -170,7 +170,7 @@ static void codel_vars_init(struct codel_vars *vars)
 
 static void codel_stats_init(struct codel_stats *stats)
 {
-	stats->maxpacket = 256;
+	stats->maxpacket = 64;
 }
 
 /*
@@ -333,6 +333,7 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 			 */
 			codel_Newton_step(vars);
 		} else {
+			stats->maxpacket = skb ? qdisc_pkt_len(skb) : 64;
 			vars->count = 1;
 			vars->rec_inv_sqrt = ~0U >> REC_INV_SQRT_SHIFT;
 		}
-- 
1.7.9.5
