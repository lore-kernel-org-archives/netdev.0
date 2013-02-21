From: "Roberts, Lee A." <lee.roberts@hp.com>
Subject: [PATCH 2/4] sctp: fix association hangs due to reneging packets
 below the cumulative TSN ACK point
Date: Thu, 21 Feb 2013 16:44:31 +0000
Message-ID: <D64EC45690EF85409BA6C4730E0162244310DEFE@G4W3231.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:25707 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754947Ab3BUQqY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 11:46:24 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lee A. Roberts <lee.roberts@hp.com>

Resolve SCTP association hangs observed during SCTP stress
testing.  Observable symptoms include communications hangs
with data being held in the association reassembly and/or lobby
(ordering) queues.  Close examination of reassembly queue shows
missing packets.

In sctp_ulpq_renege_list(), do not renege packets below the
cumulative TSN ACK point.

Patch applies to linux-3.8 kernel.

Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
---
 net/sctp/ulpqueue.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff -uprN -X linux-3.8-vanilla/Documentation/dontdiff linux-3.8-SCTP+1/net/sctp/ulpqueue.c linux-3.8-SCTP+2/net/sctp/ulpqueue.c
--- linux-3.8-SCTP+1/net/sctp/ulpqueue.c	2013-02-18 16:58:34.000000000 -0700
+++ linux-3.8-SCTP+2/net/sctp/ulpqueue.c	2013-02-21 07:39:40.888281496 -0700
@@ -969,11 +969,16 @@ static __u16 sctp_ulpq_renege_list(struc
 
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
