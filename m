From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 19/23] tipc: Handle broadcast attempt when no neighboring nodes exist
Date: Tue, 27 Dec 2011 12:39:38 -0500
Message-ID: <1325007582-31610-20-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39498 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775Ab1L0RkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:09 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Adds a check to detect when an attempt is made to send a message
via the broadcast link and no neighboring nodes are currently available
to receive it. Rather than wasting effort passing the message to the
broadcast link and broadcast bearer, who will only throw it away,
TIPC now frees the message immediately and reports success (i.e. the
message has been delivered to all available destinations).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 5ca8fdd..8f58df2 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -417,13 +417,19 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 
 	spin_lock_bh(&bc_lock);
 
+	if (!bclink->bcast_nodes.count) {
+		res = msg_data_sz(buf_msg(buf));
+		buf_discard(buf);
+		goto exit;
+	}
+
 	res = tipc_link_send_buf(bcl, buf);
 	if (likely(res > 0))
 		bclink_set_last_sent();
 
 	bcl->stats.queue_sz_counts++;
 	bcl->stats.accu_queue_sz += bcl->out_queue_size;
-
+exit:
 	spin_unlock_bh(&bc_lock);
 	return res;
 }
-- 
1.7.4.4
