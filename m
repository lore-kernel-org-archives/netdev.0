From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 2/2] sctp: fasthandoff with ASCONF at server-node
Date: Wed, 9 Nov 2011 01:23:15 +0900
Message-ID: <32B0E489-560D-4FC8-88C2-FBD490D9E45C@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:55331 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751437Ab1KHQb5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 11:31:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 0c0019a3d219bd900bedbadfa6a3b3733d9ca49c Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Fri, 17 Jun 2011 11:22:35 +0900
Subject: [PATCH 2/2] sctp: fasthandoff with ASCONF at server-node

Retransmit chunks to newly confirmed destination when ASCONF and
HEARTBEAT negotiation has success with a single-homed peer.

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
 net/sctp/sm_sideeffect.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 76388b0..1ff51c9 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -666,6 +666,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 				  struct sctp_chunk *chunk)
 {
 	sctp_sender_hb_info_t *hbinfo;
+	int was_unconfirmed = 0;
 
 	/* 8.3 Upon the receipt of the HEARTBEAT ACK, the sender of the
 	 * HEARTBEAT should clear the error counter of the destination
@@ -692,9 +693,11 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 	/* Mark the destination transport address as active if it is not so
 	 * marked.
 	 */
-	if ((t->state == SCTP_INACTIVE) || (t->state == SCTP_UNCONFIRMED))
+	if ((t->state == SCTP_INACTIVE) || (t->state == SCTP_UNCONFIRMED)) {
+		was_unconfirmed = 1;
 		sctp_assoc_control_transport(asoc, t, SCTP_TRANSPORT_UP,
 					     SCTP_HEARTBEAT_SUCCESS);
+	}
 
 	/* The receiver of the HEARTBEAT ACK should also perform an
 	 * RTT measurement for that destination transport address
@@ -712,6 +715,9 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 	/* Update the heartbeat timer.  */
 	if (!mod_timer(&t->hb_timer, sctp_transport_timeout(t)))
 		sctp_transport_hold(t);
+
+	if (was_unconfirmed && asoc->peer.transport_count == 1)
+		sctp_transport_immediate_rtx(t);
 }
 
 
-- 
1.7.3.2
