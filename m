From: "Lee A. Roberts" <lee.roberts@hp.com>
Subject: [PATCH 2/4] sctp: fix association hangs due to reneging packets below the cumulative TSN ACK point
Date: Tue, 26 Feb 2013 07:36:14 -0700
Message-ID: <1361889376-22171-3-git-send-email-lee.roberts@hp.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Cc: lee.roberts@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:12745 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab3BZOf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 09:35:28 -0500
Received: from g5t0030.atlanta.hp.com (g5t0030.atlanta.hp.com [16.228.8.142])
	by g5t0006.atlanta.hp.com (Postfix) with ESMTP id 7DF70C6BE
	for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 14:35:27 +0000 (UTC)
In-Reply-To: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lee A. Roberts" <lee.roberts@hp.com>

Resolve SCTP association hangs observed during SCTP stress
testing.  Observable symptoms include communications hangs
with data being held in the association reassembly and/or lobby
(ordering) queues.  Close examination of reassembly queue shows
missing packets.

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
