From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH] net: sctp: confirm route during forward progress
Date: Tue,  9 Jul 2013 16:17:04 +0200
Message-ID: <1373379424-5843-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, nhorman@tuxdriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873Ab3GIORS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jul 2013 10:17:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix has been proposed originally by Vlad Yasevich. He says:

  When SCTP makes forward progress (receives a SACK that acks new chunks,
  renegs, or answeres 0-window probes) or when HB-ACK arrives, mark
  the route as confirmed so we don't unnecessarily send NUD probes.

Having a simple SCTP client/server that exchange data chunks every 1sec,
without this patch ARP requests are sent periodically every 40-60sec.
With this fix applied, an ARP request is only done once right at the
"session" beginning. Also, when clearing the related ARP cache entry
manually during the session, a new request is correctly done. I have
only "backported" this to net-next and tested that it works, so full
credit goes to Vlad.

Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Applies to net-next.

 net/sctp/outqueue.c      |    9 +++++++++
 net/sctp/sm_sideeffect.c |    6 ++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index cb80a8e..ef9e2bb 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1334,6 +1334,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 	__u8 restart_timer = 0;
 	int bytes_acked = 0;
 	int migrate_bytes = 0;
+	bool forward_progress = false;
 
 	sack_ctsn = ntohl(sack->cum_tsn_ack);
 
@@ -1400,6 +1401,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 				bytes_acked += sctp_data_size(tchunk);
 				if (!tchunk->transport)
 					migrate_bytes += sctp_data_size(tchunk);
+				forward_progress = true;
 			}
 
 			if (TSN_lte(tsn, sack_ctsn)) {
@@ -1413,6 +1415,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 				 * current RTO.
 				 */
 				restart_timer = 1;
+				forward_progress = true;
 
 				if (!tchunk->tsn_gap_acked) {
 					/*
@@ -1503,6 +1506,7 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 			 */
 			transport->error_count = 0;
 			transport->asoc->overall_error_count = 0;
+			forward_progress = true;
 
 			/*
 			 * While in SHUTDOWN PENDING, we may have started
@@ -1576,6 +1580,11 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 				       jiffies + transport->rto))
 				sctp_transport_hold(transport);
 		}
+
+		if (forward_progress) {
+			if (transport->dst)
+				dst_confirm(transport->dst);
+		}
 	}
 
 	list_splice(&tlist, transmitted_queue);
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index cf6f845..9da6885 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -730,6 +730,12 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 		sctp_assoc_control_transport(asoc, t, SCTP_TRANSPORT_UP,
 					     SCTP_HEARTBEAT_SUCCESS);
 
+	/* HB-ACK was received for a the proper HB.  Consider this
+	 * forward progress.
+	 */
+	if (t->dst)
+		dst_confirm(t->dst);
+
 	/* The receiver of the HEARTBEAT ACK should also perform an
 	 * RTT measurement for that destination transport address
 	 * using the time value carried in the HEARTBEAT ACK chunk.
-- 
1.7.1
