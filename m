From: "Lee A. Roberts" <lee.roberts@hp.com>
Subject: [PATCH v3 2/4] sctp: fix association hangs due to reneging packets below the cumulative TSN ACK point
Date: Thu, 28 Feb 2013 07:37:28 -0700
Message-ID: <1362062250-26749-3-git-send-email-lee.roberts@hp.com>
References: <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
Cc: linux-sctp@vger.kernel.org, lee.roberts@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:39241 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab3B1Ogg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 09:36:36 -0500
In-Reply-To: <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lee A. Roberts" <lee.roberts@hp.com>

In sctp_ulpq_renege_list(), do not renege packets below the
cumulative TSN ACK point.

Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
---
 net/sctp/ulpqueue.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index ada1746..63afddc 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -969,11 +969,16 @@ static __u16 sctp_ulpq_renege_list(struct sctp_ulpq *ulpq,
 
 	tsnmap = &ulpq->asoc->peer.tsn_map;
 
-	while ((skb = __skb_dequeue_tail(list)) != NULL) {
-		freed += skb_headlen(skb);
+	while ((skb = skb_peek_tail(list)) != NULL) {
 		event = sctp_skb2event(skb);
 		tsn = event->tsn;
 
+		/* Don't renege below the Cumulative TSN ACK Point. */
+		if (TSN_lte(tsn, sctp_tsnmap_get_ctsn(tsnmap)))
+			break;
+
+		__skb_unlink(skb, list);
+		freed += skb_headlen(skb);
 		sctp_ulpevent_free(event);
 		sctp_tsnmap_renege(tsnmap, tsn);
 		if (freed >= needed)
-- 
1.7.9.5
