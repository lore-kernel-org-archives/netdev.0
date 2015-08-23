From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net v2] sctp: donot reset the overall_error_count in SHUTDOWN_RECEIVE state
Date: Sun, 23 Aug 2015 19:30:15 +0800
Message-ID: <46eeeb896c5be2523e3d978d4a7ea9907d4301ee.1440329415.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, tgraf@infradead.org, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33037 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbbHWLaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 07:30:22 -0400
Received: by pacti10 with SMTP id ti10so2374031pac.0
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 04:30:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f8d960524 fix the 0 peer.rwnd issue in SHUTDOWN_PENDING state through
not reseting the overall_error_count when receive a heartbeat, but the same
issue also exists in SHUTDOWN_RECEIVE state.

so we change the condition to state < SCTP_STATE_SHUTDOWN_PENDING to reset the
overall_error_count when receive a heartbeat, which can avoid the issue happen
in SCTP_STATE_SHUTDOWN_RECEIVE.

as to SCTP_STATE_SHUTDOWN_ACK_SENT and SCTP_STATE_SHUTDOWN_SENT state, with
this patch, it will not be affected by the heartbeat, cause these two states
have been taken charge of by t2 timer.

Fixes: f8d960524 ("sctp: Enforce retransmission limit during shutdown")
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
