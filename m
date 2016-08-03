From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v2 2/3] sctp_diag: export timer value only if it is active
Date: Wed,  3 Aug 2016 23:23:12 +0200
Message-ID: <1470259393-22861-3-git-send-email-phil@nwl.cc>
References: <1470259393-22861-1-git-send-email-phil@nwl.cc>
Cc: Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51814 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758441AbcHCVXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 17:23:50 -0400
In-Reply-To: <1470259393-22861-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since it is exported as unsigned value, userspace has no way detecting
whether it is negative or just very large. Therefore do this in kernel
space where it is a simple comparison.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Introduce local variable to shorten long lines.
- Use timer_pending() to decide whether to export the timer value.
- Export the primary path's value instead of garbage.
- If not exporting, zero fields to not confuse userspace.
---
 net/sctp/sctp_diag.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index f69edcf219e51..f728ef04a7b2d 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -13,6 +13,7 @@ static void inet_diag_msg_sctpasoc_fill(struct inet_diag_msg *r,
 {
 	union sctp_addr laddr, paddr;
 	struct dst_entry *dst;
+	struct timer_list *t3_rtx = &asoc->peer.primary_path->T3_rtx_timer;
 
 	laddr = list_entry(asoc->base.bind_addr.address_list.next,
 			   struct sctp_sockaddr_entry, list)->a;
@@ -40,10 +41,15 @@ static void inet_diag_msg_sctpasoc_fill(struct inet_diag_msg *r,
 	}
 
 	r->idiag_state = asoc->state;
-	r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
-	r->idiag_retrans = asoc->rtx_data_chunks;
-	r->idiag_expires = jiffies_to_msecs(
-		asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] - jiffies);
+	if (timer_pending(t3_rtx)) {
+		r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
+		r->idiag_retrans = asoc->rtx_data_chunks;
+		r->idiag_expires = jiffies_to_msecs(t3_rtx->expires - jiffies);
+	} else {
+		r->idiag_timer = 0;
+		r->idiag_retrans = 0;
+		r->idiag_expires = 0;
+	}
 }
 
 static int inet_diag_msg_sctpladdrs_fill(struct sk_buff *skb,
-- 
2.8.2
