From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/20] tipc: Convert fatal broadcast sanity check to non-fatal check
Date: Fri, 24 Jun 2011 18:07:08 -0400
Message-ID: <1308953247-25266-2-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34337 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440Ab1FXWHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:39 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies the existing broadcast link sanity check that detects an
attempt to send a message off-node when there are no available
destinations so that it no longer causes a kernel panic; instead,
the check now issues a warning and stack trace and then returns
without sending the message anywhere.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index fa68d1e..759b318 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -552,12 +552,16 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 	if (likely(!msg_non_seq(buf_msg(buf)))) {
 		struct tipc_msg *msg;
 
-		assert(tipc_bcast_nmap.count != 0);
 		bcbuf_set_acks(buf, tipc_bcast_nmap.count);
 		msg = buf_msg(buf);
 		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tipc_net_id);
 		bcl->stats.sent_info++;
+
+		if (WARN_ON(!tipc_bcast_nmap.count)) {
+			dump_stack();
+			return 0;
+		}
 	}
 
 	/* Send buffer over bearers until all targets reached */
-- 
1.7.4.4

