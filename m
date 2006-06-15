From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 6/6][SCTP]: Fix persistent slowdown in sctp when a gap ack
	consumes rx buffer.
Date: Thu, 15 Jun 2006 15:46:35 -0700
Message-ID: <1150411595.6028.36.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:8614 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750712AbWFOWrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 18:47:22 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5FMlLN9020054
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5FMlLqc289298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5FMlLo2010817
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:21 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Fix persistent slowdown in sctp when a gap ack consumes rx buffer.

In the event that our entire receive buffer is full with a series of
chunks that represent a single gap-ack, and then we accept a chunk
(or chunks) that fill in the gap between the ctsn and the first gap,
we renege chunks from the end of the buffer, which effectively does
nothing but move our gap to the end of our received tsn stream. This
does little but move our missing tsns down stream a little, and, if the
sender is sending sufficiently large retransmit frames, the result is a
perpetual slowdown which can never be recovered from, since the only
chunk that can be accepted to allow progress in the tsn stream necessitates
that a new gap be created to make room for it. This leads to a constant
need for retransmits, and subsequent receiver stalls. The fix I've come up
with is to deliver the frame without reneging if we have a full receive
buffer and the receiving sockets sk_receive_queue is empty(indicating that
the receive buffer is being blocked by a missing tsn).

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/sctp/sm_statefuns.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5293,10 +5293,18 @@ static int sctp_eat_data(const struct sc
 	 * seems a bit troublesome in that frag_point varies based on
 	 * PMTU.  In cases, such as loopback, this might be a rather
 	 * large spill over.
+	 * NOTE: If we have a full receive buffer here, we only renege if
+	 * our receiver can still make progress without the tsn being
+	 * received. We do this because in the event that the associations
+	 * receive queue is empty we are filling a leading gap, and since
+	 * reneging moves the gap to the end of the tsn stream, we are likely
+	 * to stall again very shortly. Avoiding the renege when we fill a
+	 * leading gap is a good heuristic for avoiding such steady state
+	 * stalls.
 	 */
 	if (!asoc->rwnd || asoc->rwnd_over ||
 	    (datalen > asoc->rwnd + asoc->frag_point) ||
-	    rcvbuf_over) {
+	    (rcvbuf_over && (!skb_queue_len(&sk->sk_receive_queue)))) {
 
 		/* If this is the next TSN, consider reneging to make
 		 * room.   Note: Playing nice with a confused sender.  A


