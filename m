From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/16] tipc: take lock while updating node network address
Date: Fri, 20 Apr 2012 17:05:20 -0400
Message-ID: <1334955924-907-13-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62202 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475Ab2DTVFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:40 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

The routine that changes the node's network address now takes TIPC's
network lock in write mode while the main address variable and associated
data structures are being changed; this is needed to ensure that the
link subsystem won't attempt to send a message off-node until the sending
port's message header template has been updated with the node's new
network address.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/net.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index d4531b0..5fab4ff 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -178,11 +178,12 @@ int tipc_net_start(u32 addr)
 	tipc_subscr_stop();
 	tipc_cfg_stop();
 
+	write_lock_bh(&tipc_net_lock);
 	tipc_own_addr = addr;
 	tipc_named_reinit();
 	tipc_port_reinit();
-
 	tipc_bclink_init();
+	write_unlock_bh(&tipc_net_lock);
 
 	tipc_k_signal((Handler)tipc_subscr_start, 0);
 	tipc_k_signal((Handler)tipc_cfg_init, 0);
-- 
1.7.9.3
