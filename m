From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/4] sctp: Fix to handle SHUTDOWN in SHUTDOWN-PENDING state
Date: Tue, 21 Oct 2008 22:08:46 -0400
Message-ID: <1224641327-11913-4-git-send-email-vladislav.yasevich@hp.com>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:31827 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbYJVCI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 22:08:58 -0400
In-Reply-To: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

If SHUTDOWN is received in SHUTDOWN-PENDING state, enpoint should enter
the SHUTDOWN-RECEIVED state and check the Cumulative TSN Ack field of
the SHUTDOWN chunk (RFC 4960 Section 9.2). If the SHUTDOWN chunk can
acknowledge all of the send DATA chunks, SHUTDOWN-ACK should be sent.

But now endpoint just silently discarded the SHUTDOWN chunk.

SHUTDOWN received in SHUTDOWN-PENDING state can happend when the last
SACK is lost by network, or the SHUTDOWN chunk can acknowledge all of
the received DATA chunks. The packet sequence(SACK lost) is like this:

Endpoint A                       Endpoint B       ULP
(ESTABLISHED)                    (ESTABLISHED)

               <-----------      DATA
                                             <--- shutdown
                                 Enter SHUTDOWN-PENDING state
  SACK         ----lost---->

  SHUTDOWN(*1) ------------>

               <-----------      SHUTDOWN-ACK

 (*1) silently discarded now.

This patch fix to handle SHUTDOWN in SHUTDOWN-PENDING state as the same
as ESTABLISHED state.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_statetable.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index dd4ddc4..a5b5590 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -266,7 +266,7 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 	/* SCTP_STATE_ESTABLISHED */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_9_2_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
-	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	TYPE_SCTP_FUNC(sctp_sf_do_9_2_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_9_2_shutdown_ack), \
 	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
-- 
1.5.3.5

