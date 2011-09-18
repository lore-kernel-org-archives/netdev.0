From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/28] tipc: Prevent broadcast link stalling when another node fails
Date: Sat, 17 Sep 2011 23:32:06 -0400
Message-ID: <1316316744-29514-11-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49976 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245Ab1IRDcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:48 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensure that broadcast link messages that have not been acknowledged
by a newly failed node do not get an implied acknowledgement until the
failed node is removed from the broadcast link's map of reachable nodes.

Previously, a race condition allowed a new broadcast link message to be
sent after the implicit acknowledgement processing was completed, but
before the map of reachable nodes was updated, resulting in the message
having an expected acknowledgement count that required the failed node
to explicitly acknowledge the message. Since this would never occur
the new message would remain in the broadcast link's transmit queue
forever, eventually causing the link to become congested and "stall".
Delaying the implicit acknowledgement processing until after the update
of the map of reachable nodes eliminates this race condition and prevents
stalling.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/node.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 810b395..d75432f 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -349,9 +349,9 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 			n_ptr->bclink.defragm = NULL;
 		}
 
+		tipc_nmap_remove(&tipc_bcast_nmap, n_ptr->addr);
 		tipc_bclink_acknowledge(n_ptr,
 					mod(n_ptr->bclink.acked + 10000));
-		tipc_nmap_remove(&tipc_bcast_nmap, n_ptr->addr);
 		if (n_ptr->addr < tipc_own_addr)
 			tipc_own_tag--;
 
-- 
1.7.4.4
