From: "Lee A. Roberts" <lee.roberts@hp.com>
Subject: [PATCH v2 3/4] sctp: fix association hangs due to errors when reneging events from the ordering queue
Date: Wed, 27 Feb 2013 11:54:32 -0700
Message-ID: <1361991273-30578-4-git-send-email-lee.roberts@hp.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Cc: lee.roberts@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:26961 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760754Ab3B0Sxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 13:53:47 -0500
Received: from g5t0030.atlanta.hp.com (g5t0030.atlanta.hp.com [16.228.8.142])
	by g5t0006.atlanta.hp.com (Postfix) with ESMTP id 6DB4BC07C
	for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 18:53:46 +0000 (UTC)
In-Reply-To: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lee A. Roberts" <lee.roberts@hp.com>

Resolve SCTP association hangs observed during SCTP stress
testing.  Observable symptoms include communications hangs
with data being held in the association reassembly and/or lobby
(ordering) queues.  Close examination of reassembly queue shows
missing packets.

In sctp_ulpq_renege_list(), events being reneged from the
ordering queue may correspond to multiple TSNs.  Identify
all affected packets; sum freed space and renege from the
tsnmap.

Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
---
 net/sctp/ulpqueue.c |   26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 63afddc..f221fbb 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -962,8 +962,8 @@ static __u16 sctp_ulpq_renege_list(struct sctp_ulpq *ulpq,
 		struct sk_buff_head *list, __u16 needed)
 {
 	__u16 freed = 0;
-	__u32 tsn;
-	struct sk_buff *skb;
+	__u32 tsn, last_tsn;
+	struct sk_buff *skb, *flist, *last;
 	struct sctp_ulpevent *event;
 	struct sctp_tsnmap *tsnmap;
 
@@ -977,10 +977,28 @@ static __u16 sctp_ulpq_renege_list(struct sctp_ulpq *ulpq,
 		if (TSN_lte(tsn, sctp_tsnmap_get_ctsn(tsnmap)))
 			break;
 
-		__skb_unlink(skb, list);
+		/* Events in ordering queue may have multiple fragments
+		 * corresponding to additional TSNs.  Sum the total
+		 * freed space; find the last TSN.
+		 */
 		freed += skb_headlen(skb);
+		flist = skb_shinfo(skb)->frag_list;
+		for (last = flist; flist; flist = flist->next) {
+			last = flist;
+			freed += skb_headlen(last);
+		}
+		if (last)
+			last_tsn = sctp_skb2event(last)->tsn;
+		else
+			last_tsn = tsn;
+
+		/* Unlink the event, then renege all applicable TSNs. */
+		__skb_unlink(skb, list);
 		sctp_ulpevent_free(event);
-		sctp_tsnmap_renege(tsnmap, tsn);
+		while (TSN_lte(tsn, last_tsn)) {
+			sctp_tsnmap_renege(tsnmap, tsn);
+			tsn++;
+		}
 		if (freed >= needed)
 			return freed;
 	}
-- 
1.7.9.5
