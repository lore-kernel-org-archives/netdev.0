From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v2] tipc: fix connection abort during subscription cancel
Date: Wed, 27 Jan 2016 11:35:59 +0100
Message-ID: <1453890959-8238-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>,
	<ying.xue@windriver.com>, <richard.alpe@ericsson.com>,
	<anders.widell@ericsson.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:49428 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbcA0KgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 05:36:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 'commit 7fe8097cef5f ("tipc: fix nullpointer bug when subscribing
to events")', we terminate the connection if the subscription
creation fails.
In the same commit, the subscription creation result was based on
the value of the subscription pointer (set in the function) instead
of the return code.

Unfortunately, the same function tipc_subscrp_create() handles
subscription cancel request. For a subscription cancellation request,
the subscription pointer cannot be set. Thus if a subscriber has
several subscriptions and cancels any of them, the connection is
terminated.

In this commit, we terminate the connection based on the return value
of tipc_subscrp_create().
Fixes: commit 7fe8097cef5f ("tipc: fix nullpointer bug when subscribing to events")

Reviewed-by:  Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
v2:
 * Update variable subscriber to subscrb to fit the condition in single
   line as requested by Jon.


 net/tipc/subscr.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 350cca33ee0a..69ee2eeef968 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -289,15 +289,14 @@ static void tipc_subscrb_rcv_cb(struct net *net, int conid,
 				struct sockaddr_tipc *addr, void *usr_data,
 				void *buf, size_t len)
 {
-	struct tipc_subscriber *subscriber = usr_data;
+	struct tipc_subscriber *subscrb = usr_data;
 	struct tipc_subscription *sub = NULL;
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
-	tipc_subscrp_create(net, (struct tipc_subscr *)buf, subscriber, &sub);
-	if (sub)
-		tipc_nametbl_subscribe(sub);
-	else
-		tipc_conn_terminate(tn->topsrv, subscriber->conid);
+	if (tipc_subscrp_create(net, (struct tipc_subscr *)buf, subscrb, &sub))
+		return tipc_conn_terminate(tn->topsrv, subscrb->conid);
+
+	tipc_nametbl_subscribe(sub);
 }
 
 /* Handle one request to establish a new subscriber */
-- 
2.1.4
