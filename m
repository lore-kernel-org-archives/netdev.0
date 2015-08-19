From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: start t5 timer only when peer.rwnd == 0 and in SHUTDOWN_PENDING
Date: Wed, 19 Aug 2015 12:39:06 +0800
Message-ID: <b28d94a321679707da72c7a1d52fc49fbb3bcea3.1439959146.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, tgraf@infradead.org, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33457 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbbHSEjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 00:39:09 -0400
Received: by pdrh1 with SMTP id h1so76853094pdr.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 21:39:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when A send a data to B, A close() to be in SHUTDOWN_PENDING state,
but B neither claim his rwnd is 0 nor SACK this data, then A keep
retransmiting this data. it should send abord after Max.Retrans
times, only when peer.rwnd == 0 and more than Max.Retrans times, it
will start t5 timer.

Fixes: f8d960524 ("sctp: Enforce retransmission limit during shutdown")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_statefuns.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3ee27b7..7d9380c 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5412,7 +5412,8 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
 	SCTP_INC_STATS(net, SCTP_MIB_T3_RTX_EXPIREDS);
 
 	if (asoc->overall_error_count >= asoc->max_retrans) {
-		if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
+		if (!q->asoc->peer.rwnd &&
+			asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
 			/*
 			 * We are here likely because the receiver had its rwnd
 			 * closed for a while and we have not been able to
-- 
2.1.0
