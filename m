From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net v2] sctp: start t5 timer only when peer.rwnd is 0 and local.state is SHUTDOWN_PENDING
Date: Sun, 23 Aug 2015 19:30:40 +0800
Message-ID: <e5d77a8d7c30ccbcc113506837ae7b8e90625046.1440329440.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, tgraf@infradead.org, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34704 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbbHWLaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 07:30:46 -0400
Received: by padfa11 with SMTP id fa11so3834613pad.1
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 04:30:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when A sends a data to B, then A close() and enter into SHUTDOWN_PENDING state,
if B neither claim his rwnd is 0 nor send SACK for this data, A will keep
retransmitting this data util t5 timeout, Max.Retrans times can't work anymore,
which is bad.

if B's rwnd is not 0, it should send abord after Max.Retrans times, only when
B's rwnd == 0 and A's retransmitting beyonds Max.Retrans times, A will start
t5 timer, which is also commit f8d960524 means, but it lacks the condition
peer.rwnd == 0.

Fixes: f8d960524 ("sctp: Enforce retransmission limit during shutdown")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_statefuns.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3ee27b7..deb9eab 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5412,7 +5412,8 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
 	SCTP_INC_STATS(net, SCTP_MIB_T3_RTX_EXPIREDS);
 
 	if (asoc->overall_error_count >= asoc->max_retrans) {
-		if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
+		if (!q->asoc->peer.rwnd &&
+		    asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
 			/*
 			 * We are here likely because the receiver had its rwnd
 			 * closed for a while and we have not been able to
-- 
2.1.0
