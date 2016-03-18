From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: do not update a_rwnd if we are not issuing a sack
Date: Fri, 18 Mar 2016 18:39:18 -0300
Message-ID: <1458337159-22792-3-git-send-email-marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932364AbcCRVjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 17:39:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SACK can be lost pretty much elsewhere, but if its allocation fail,
we know we are not sending it, so it is better to revert a_rwnd to its
previous value as this may give it a chance to issue a window update
later.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/sm_sideeffect.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 3c22c41a2bc2dc128d651f64b1a81036be22b9b3..7fe56d0acabf66cfd8fe29dfdb45f7620b470ac7 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -215,10 +215,14 @@ static int sctp_gen_sack(struct sctp_association *asoc, int force,
 		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
 				SCTP_TO(SCTP_EVENT_TIMEOUT_SACK));
 	} else {
+		__u32 old_a_rwnd = asoc->a_rwnd;
+
 		asoc->a_rwnd = asoc->rwnd;
 		sack = sctp_make_sack(asoc);
-		if (!sack)
+		if (!sack) {
+			asoc->a_rwnd = old_a_rwnd;
 			goto nomem;
+		}
 
 		asoc->peer.sack_needed = 0;
 		asoc->peer.sack_cnt = 0;
-- 
2.5.0
