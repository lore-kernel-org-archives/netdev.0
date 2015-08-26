From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net v3] sctp: donot reset the overall_error_count in SHUTDOWN_RECEIVE state
Date: Thu, 27 Aug 2015 04:52:20 +0800
Message-ID: <5b69e6d52b777923b9224315d11adbf9bd24077e.1440622340.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, davem@davemloft.net, vyasevic@redhat.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35264 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbbHZUw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 16:52:26 -0400
Received: by pacdd16 with SMTP id dd16so171696139pac.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 13:52:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f8d960524328 ("sctp: Enforce retransmission limit during shutdown")
fixed a problem with excessive retransmissions in the SHUTDOWN_PENDING by not
resetting the association overall_error_count.  This allowed the association
to better enforce assoc.max_retrans limit.

However, the same issue still exists when the association is in SHUTDOWN_RECEIVED
state.  In this state, HB-ACKs will continue to reset the overall_error_count
for the association would extend the lifetime of association unnecessarily.

This patch solves this by resetting the overall_error_count whenever the current
state is small then SCTP_STATE_SHUTDOWN_PENDING.  As a small side-effect, we
end up also handling SCTP_STATE_SHUTDOWN_ACK_SENT and SCTP_STATE_SHUTDOWN_SENT
states, but they are not really impacted because we disable Heartbeats in those
states.

Fixes: Commit f8d960524328 ("sctp: Enforce retransmission limit during shutdown")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_sideeffect.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index fef2acd..85e6f03 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -702,7 +702,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 	 * outstanding data and rely on the retransmission limit be reached
 	 * to shutdown the association.
 	 */
-	if (t->asoc->state != SCTP_STATE_SHUTDOWN_PENDING)
+	if (t->asoc->state < SCTP_STATE_SHUTDOWN_PENDING)
 		t->asoc->overall_error_count = 0;
 
 	/* Clear the hb_sent flag to signal that we had a good
-- 
2.1.0
