From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 4/6] tipc: drop subscriber connection id invalidation
Date: Tue, 4 Mar 2014 09:05:41 +0100
Message-ID: <1393920343-4134-5-git-send-email-erik.hugne@ericsson.com>
References: <1393920343-4134-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg20.ericsson.net ([193.180.251.50]:49876 "EHLO
	sessmg20.mgmt.ericsson.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756548AbaCDIFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 03:05:16 -0500
In-Reply-To: <1393920343-4134-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

When a topology server subscriber is disconnected, the associated
connection id is set to zero. A check vs zero is then done in the
subscription timeout function to see if the subscriber have been
shut down. This is unnecessary, because all subscription timers
will be cancelled when a subscriber terminates. Setting the
connection id to zero is actually harmful because id zero is the
identity of the topology server listening socket, and can cause a
race that leads to this socket being closed instead.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/subscr.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index a6a6a26..89d0f23 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -153,14 +153,6 @@ static void subscr_timeout(struct tipc_subscription *sub)
 	/* The spin lock per subscriber is used to protect its members */
 	spin_lock_bh(&subscriber->lock);
 
-	/* Validate if the connection related to the subscriber is
-	 * closed (in case subscriber is terminating)
-	 */
-	if (subscriber->conid == 0) {
-		spin_unlock_bh(&subscriber->lock);
-		return;
-	}
-
 	/* Validate timeout (in case subscription is being cancelled) */
 	if (sub->timeout == TIPC_WAIT_FOREVER) {
 		spin_unlock_bh(&subscriber->lock);
@@ -215,9 +207,6 @@ static void subscr_release(struct tipc_subscriber *subscriber)
 
 	spin_lock_bh(&subscriber->lock);
 
-	/* Invalidate subscriber reference */
-	subscriber->conid = 0;
-
 	/* Destroy any existing subscriptions for subscriber */
 	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
 				 subscription_list) {
-- 
1.8.3.2
