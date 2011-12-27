From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 21/23] tipc: Flush unsent broadcast messages when contact with last node is lost
Date: Tue, 27 Dec 2011 12:39:40 -0500
Message-ID: <1325007582-31610-22-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39509 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775Ab1L0RkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:11 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Adds code to release any unsent broadcast messages in the broadcast link
transmit queue if TIPC loses contact with its only neighboring node.
Previously, a broadcast link that was in the congested state would hold
on to the unsent messages, even though the messages were now undeliverable.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index dd990b0..4609819 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -252,7 +252,17 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 
 	while (crs && less_eq(buf_seqno(crs), acked)) {
 		next = crs->next;
-		bcbuf_decr_acks(crs);
+
+		if (crs != bcl->next_out)
+			bcbuf_decr_acks(crs);
+		else if (bclink->bcast_nodes.count)
+			break;
+		else {
+			bcbuf_set_acks(crs, 0);
+			bcl->next_out = next;
+			bclink_set_last_sent();
+		}
+
 		if (bcbuf_acks(crs) == 0) {
 			bcl->first_out = next;
 			bcl->out_queue_size--;
-- 
1.7.4.4
