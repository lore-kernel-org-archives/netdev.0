From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/4] [SCTP]: Fix panic's when receiving fragmented SCTP
	control chunks.
Date: Fri, 05 May 2006 12:14:45 -0700
Message-ID: <1146856485.7861.35.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:41943 "EHLO e6.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751714AbWEETOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 15:14:45 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k45JEjhK031315
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 15:14:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k45JEiHm213926
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 15:14:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k45JEiZG001892
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 15:14:44 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Fix panic's when receiving fragmented SCTP control chunks.

Use pskb_pull() to handle incoming COOKIE_ECHO and HEARTBEAT chunks that
are received as skb's with fragment list.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/sctp/sm_statefuns.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 6834032..27514f3 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -636,8 +636,9 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(co
 	 */
         chunk->subh.cookie_hdr =
 		(struct sctp_signed_cookie *)chunk->skb->data;
-	skb_pull(chunk->skb,
-		 ntohs(chunk->chunk_hdr->length) - sizeof(sctp_chunkhdr_t));
+	if (!pskb_pull(chunk->skb, ntohs(chunk->chunk_hdr->length) -
+					 sizeof(sctp_chunkhdr_t)))
+		goto nomem;
 
 	/* 5.1 D) Upon reception of the COOKIE ECHO chunk, Endpoint
 	 * "Z" will reply with a COOKIE ACK chunk after building a TCB
@@ -965,7 +966,8 @@ sctp_disposition_t sctp_sf_beat_8_3(cons
 	 */
 	chunk->subh.hb_hdr = (sctp_heartbeathdr_t *) chunk->skb->data;
 	paylen = ntohs(chunk->chunk_hdr->length) - sizeof(sctp_chunkhdr_t);
-	skb_pull(chunk->skb, paylen);
+	if (!pskb_pull(chunk->skb, paylen))
+		goto nomem;
 
 	reply = sctp_make_heartbeat_ack(asoc, chunk,
 					chunk->subh.hb_hdr, paylen);
@@ -1860,8 +1862,9 @@ sctp_disposition_t sctp_sf_do_5_2_4_dupc
 	 * are in good shape.
 	 */
         chunk->subh.cookie_hdr = (struct sctp_signed_cookie *)chunk->skb->data;
-	skb_pull(chunk->skb, ntohs(chunk->chunk_hdr->length) -
-		 sizeof(sctp_chunkhdr_t));
+	if (!pskb_pull(chunk->skb, ntohs(chunk->chunk_hdr->length) -
+					sizeof(sctp_chunkhdr_t)))
+		goto nomem;
 
 	/* In RFC 2960 5.2.4 3, if both Verification Tags in the State Cookie
 	 * of a duplicate COOKIE ECHO match the Verification Tags of the


