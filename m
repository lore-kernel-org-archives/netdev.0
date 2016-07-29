From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 2/3] sctp_diag: export timer value only if it is active
Date: Fri, 29 Jul 2016 18:59:39 +0200
Message-ID: <1469811580-32429-3-git-send-email-phil@nwl.cc>
References: <1469811580-32429-1-git-send-email-phil@nwl.cc>
Cc: Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45543 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbcG2Q7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 12:59:54 -0400
In-Reply-To: <1469811580-32429-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since it is exported as unsigned value, userspace has no way detecting
whether it is negative or just very large. Therefore do this in kernel
space where it is a simple comparison.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/sctp/sctp_diag.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index f69edcf219e51..0ad6033a7330c 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -40,10 +40,12 @@ static void inet_diag_msg_sctpasoc_fill(struct inet_diag_msg *r,
 	}
 
 	r->idiag_state = asoc->state;
-	r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
-	r->idiag_retrans = asoc->rtx_data_chunks;
-	r->idiag_expires = jiffies_to_msecs(
-		asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] - jiffies);
+	if (asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] > jiffies) {
+		r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
+		r->idiag_retrans = asoc->rtx_data_chunks;
+		r->idiag_expires = jiffies_to_msecs(
+			asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] - jiffies);
+	}
 }
 
 static int inet_diag_msg_sctpladdrs_fill(struct sk_buff *skb,
-- 
2.8.2
