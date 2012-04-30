From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/10] tipc: Enhance re-initialization of network topology service
Date: Mon, 30 Apr 2012 18:37:02 -0400
Message-ID: <1335825428-16053-5-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45982 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757325Ab2D3WhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:18 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Streamlines the job of re-initializing TIPC's network topology service
when a node's network address is first assigned. Rather than destroying
the topology server port and breaking its connections to existing
subscribers, TIPC now simply lets the service continue running (since
the change to the port identifier of each port used by the topology
service no longer impacts the flow of messages between the service and
its subscribers).

This enhancement means that applications that utilize the topology
service prior to the assignment of TIPC's network address no longer need
to re-establish their subscriptions when the address is finally assigned.

However, it is worth noting that any subsequent events for existing
subscriptions report the new port identifier of the publishing port,
rather than the original port identifier. (For example, a name that was
previously reported as being published by <0.0.0:ref> may be subsequently
withdrawn by <Z.C.N:ref>.)

This doesn't impact any of the existing known userspace in tipc-utils,
since (a) TIPC continues to treat references to the original port ID
correctly and (b) normal use cases assign an address before active use.

However if there does happen to be some rare/custom application out
there that was relying on this, they can simply bypass the enhancement
by issuing a subscription to {0,0} and break its connection to the
topology service, if an associated withdrawal event occurs.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/net.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index f4a490b..7c236c8 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -175,8 +175,6 @@ int tipc_net_start(u32 addr)
 {
 	char addr_string[16];
 
-	tipc_subscr_stop();
-
 	write_lock_bh(&tipc_net_lock);
 	tipc_own_addr = addr;
 	tipc_named_reinit();
@@ -184,7 +182,6 @@ int tipc_net_start(u32 addr)
 	tipc_bclink_init();
 	write_unlock_bh(&tipc_net_lock);
 
-	tipc_k_signal((Handler)tipc_subscr_start, 0);
 	tipc_cfg_reinit();
 
 	info("Started in network mode\n");
-- 
1.7.9.6
