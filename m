From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/4] sctp: Add check for the TSN field of the SHUTDOWN chunk
Date: Tue, 21 Oct 2008 22:08:45 -0400
Message-ID: <1224641327-11913-3-git-send-email-vladislav.yasevich@hp.com>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:32730 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbYJVCIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 22:08:54 -0400
In-Reply-To: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

If SHUTDOWN chunk is received Cumulative TSN Ack beyond the max tsn currently
send, SHUTDOWN chunk be accepted and the association will be broken. New data
is send, but after received SACK it will be drop because TSN in SACK is less
than the Cumulative TSN, data will be retrans again and again even if correct
SACK is received.

The packet sequence is like this:

Endpoint A                       Endpoint B       ULP
(ESTABLISHED)                    (ESTABLISHED)

               <-----------      DATA (TSN=x-1)

               <-----------      DATA (TSN=x)

  SHUTDOWN     ----------->      (Now Cumulative TSN=x+1000)
  (TSN=x+1000)
               <-----------      DATA (TSN=x+1)

  SACK         ----------->      drop the SACK
  (TSN=x+1)
               <-----------      DATA (TSN=x+1)(retrans)

This patch fix this problem by terminating the association and respond to
the sender with an ABORT.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statefuns.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index d4c3fbc..12f6217 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2544,6 +2544,7 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown(const struct sctp_endpoint *ep,
 	sctp_shutdownhdr_t *sdh;
 	sctp_disposition_t disposition;
 	struct sctp_ulpevent *ev;
+	__u32 ctsn;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -2558,6 +2559,14 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown(const struct sctp_endpoint *ep,
 	sdh = (sctp_shutdownhdr_t *)chunk->skb->data;
 	skb_pull(chunk->skb, sizeof(sctp_shutdownhdr_t));
 	chunk->subh.shutdown_hdr = sdh;
+	ctsn = ntohl(sdh->cum_tsn_ack);
+
+	/* If Cumulative TSN Ack beyond the max tsn currently
+	 * send, terminating the association and respond to the
+	 * sender with an ABORT.
+	 */
+	if (!TSN_lt(ctsn, asoc->next_tsn))
+		return sctp_sf_violation_ctsn(ep, asoc, type, arg, commands);
 
 	/* API 5.3.1.5 SCTP_SHUTDOWN_EVENT
 	 * When a peer sends a SHUTDOWN, SCTP delivers this notification to
-- 
1.5.3.5

