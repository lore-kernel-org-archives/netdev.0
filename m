From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/4] sctp: Correctly start rtx timer on new packet transmissions.
Date: Thu, 22 Jan 2009 17:36:06 -0500
Message-ID: <1232663768-4028-3-git-send-email-vladislav.yasevich@hp.com>
References: <1232663768-4028-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:2094 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758808AbZAVWgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:36:11 -0500
In-Reply-To: <1232663768-4028-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 62aeaff5ccd96462b7077046357a6d7886175a57
(sctp: Start T3-RTX timer when fast retransmitting lowest TSN)
introduced a regression where it was possible to forcibly
restart the sctp retransmit timer at the transmission of any
new chunk.  This resulted in much longer timeout times and
sometimes hung sctp connections.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/outqueue.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 247ebc9..bc411c8 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -929,7 +929,6 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 		}
 
 		/* Finally, transmit new packets.  */
-		start_timer = 0;
 		while ((chunk = sctp_outq_dequeue_data(q)) != NULL) {
 			/* RFC 2960 6.5 Every DATA chunk MUST carry a valid
 			 * stream identifier.
@@ -1028,7 +1027,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 			list_add_tail(&chunk->transmitted_list,
 				      &transport->transmitted);
 
-			sctp_transport_reset_timers(transport, start_timer-1);
+			sctp_transport_reset_timers(transport, 0);
 
 			q->empty = 0;
 
-- 
1.5.3.5

