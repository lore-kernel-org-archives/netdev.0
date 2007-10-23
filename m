From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Consolidate sctp_ulpq_renege_xxx functions
Date: Tue, 23 Oct 2007 19:17:22 +0400
Message-ID: <471E1082.8010607@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	lksctp-developers@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54978 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbXJWPRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 11:17:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both are equal, except for the list to be traversed.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index b937095..4be92d0 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -908,8 +908,8 @@ void sctp_ulpq_skip(struct sctp_ulpq *ulpq, __u16 sid, __u16 ssn)
 	return;
 }
 
-/* Renege 'needed' bytes from the ordering queue. */
-static __u16 sctp_ulpq_renege_order(struct sctp_ulpq *ulpq, __u16 needed)
+static __u16 sctp_ulpq_renege_list(struct sctp_ulpq *ulpq,
+		struct sk_buff_head *list, __u16 needed)
 {
 	__u16 freed = 0;
 	__u32 tsn;
@@ -919,7 +919,7 @@ static __u16 sctp_ulpq_renege_order(struct sctp_ulpq *ulpq, __u16 needed)
 
 	tsnmap = &ulpq->asoc->peer.tsn_map;
 
-	while ((skb = __skb_dequeue_tail(&ulpq->lobby)) != NULL) {
+	while ((skb = __skb_dequeue_tail(list)) != NULL) {
 		freed += skb_headlen(skb);
 		event = sctp_skb2event(skb);
 		tsn = event->tsn;
@@ -933,30 +933,16 @@ static __u16 sctp_ulpq_renege_order(struct sctp_ulpq *ulpq, __u16 needed)
 	return freed;
 }
 
+/* Renege 'needed' bytes from the ordering queue. */
+static __u16 sctp_ulpq_renege_order(struct sctp_ulpq *ulpq, __u16 needed)
+{
+	return sctp_ulpq_renege_list(ulpq, &ulpq->lobby, needed);
+}
+
 /* Renege 'needed' bytes from the reassembly queue. */
 static __u16 sctp_ulpq_renege_frags(struct sctp_ulpq *ulpq, __u16 needed)
 {
-	__u16 freed = 0;
-	__u32 tsn;
-	struct sk_buff *skb;
-	struct sctp_ulpevent *event;
-	struct sctp_tsnmap *tsnmap;
-
-	tsnmap = &ulpq->asoc->peer.tsn_map;
-
-	/* Walk backwards through the list, reneges the newest tsns. */
-	while ((skb = __skb_dequeue_tail(&ulpq->reasm)) != NULL) {
-		freed += skb_headlen(skb);
-		event = sctp_skb2event(skb);
-		tsn = event->tsn;
-
-		sctp_ulpevent_free(event);
-		sctp_tsnmap_renege(tsnmap, tsn);
-		if (freed >= needed)
-			return freed;
-	}
-
-	return freed;
+	return sctp_ulpq_renege_list(ulpq, &ulpq->reasm, needed);
 }
 
 /* Partial deliver the first message as there is pressure on rwnd. */
