From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/10] tipc: Optimize re-initialization of configuration service
Date: Mon, 30 Apr 2012 18:36:59 -0400
Message-ID: <1335825428-16053-2-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35012 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757128Ab2D3WhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:14 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Streamlines the job of re-initializing TIPC's configuration service
when a node's network address is first assigned. Rather than destroying
the configuration server port and then recreating it, TIPC now simply
withdraws the existing {0,<0.0.0>} name publication and creates a new
{0,<Z.C.N>} name publication that identifies the node's network address
to interested subscribers.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c |   15 +++++++++++++++
 net/tipc/config.h |    1 +
 net/tipc/net.c    |    3 +--
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index f5458ed..a4988cd 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -489,6 +489,21 @@ failed:
 	return res;
 }
 
+void tipc_cfg_reinit(void)
+{
+	struct tipc_name_seq seq;
+	int res;
+
+	seq.type = TIPC_CFG_SRV;
+	seq.lower = seq.upper = 0;
+	tipc_withdraw(config_port_ref, TIPC_ZONE_SCOPE, &seq);
+
+	seq.lower = seq.upper = tipc_own_addr;
+	res = tipc_publish(config_port_ref, TIPC_ZONE_SCOPE, &seq);
+	if (res)
+		err("Unable to reinitialize configuration service\n");
+}
+
 void tipc_cfg_stop(void)
 {
 	if (config_port_ref) {
diff --git a/net/tipc/config.h b/net/tipc/config.h
index 80da6eb..1f252f3 100644
--- a/net/tipc/config.h
+++ b/net/tipc/config.h
@@ -66,6 +66,7 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd,
 				int headroom);
 
 int  tipc_cfg_init(void);
+void tipc_cfg_reinit(void);
 void tipc_cfg_stop(void);
 
 #endif
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 5fab4ff..f4a490b 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -176,7 +176,6 @@ int tipc_net_start(u32 addr)
 	char addr_string[16];
 
 	tipc_subscr_stop();
-	tipc_cfg_stop();
 
 	write_lock_bh(&tipc_net_lock);
 	tipc_own_addr = addr;
@@ -186,7 +185,7 @@ int tipc_net_start(u32 addr)
 	write_unlock_bh(&tipc_net_lock);
 
 	tipc_k_signal((Handler)tipc_subscr_start, 0);
-	tipc_k_signal((Handler)tipc_cfg_init, 0);
+	tipc_cfg_reinit();
 
 	info("Started in network mode\n");
 	info("Own node address %s, network identity %u\n",
-- 
1.7.9.6
