From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/15] tipc: Add missing broadcast link lock when sending NACK
Date: Mon,  6 Feb 2012 19:52:39 -0500
Message-ID: <1328575968-20643-7-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50177 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756051Ab2BGAxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:12 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensures that any attempt to send a NACK message over TIPC's broadcast
link has exclusive access to the link's main data structures, to prevent
interference with a simultaneous attempt to send other broadcast link
traffic (such as application-generated multicast messages).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 8eb87b1..7342abc 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -340,8 +340,10 @@ static void bclink_send_nack(struct tipc_node *n_ptr)
 		msg_set_bcgap_to(msg, n_ptr->bclink.gap_to);
 		msg_set_bcast_tag(msg, tipc_own_tag);
 
+		spin_lock_bh(&bc_lock);
 		tipc_bearer_send(&bcbearer->bearer, buf, NULL);
 		bcl->stats.sent_nacks++;
+		spin_unlock_bh(&bc_lock);
 		buf_discard(buf);
 
 		/*
-- 
1.7.9
