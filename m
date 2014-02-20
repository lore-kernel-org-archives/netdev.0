From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net 2/2] tipc: make bearer set up in module insertion stage
Date: Thu, 20 Feb 2014 11:32:50 +0800
Message-ID: <1392867171-31020-3-git-send-email-ying.xue@windriver.com>
References: <1392867171-31020-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>, <wangweidong1@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35918 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907AbaBTDdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 22:33:16 -0500
In-Reply-To: <1392867171-31020-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Accidentally a side effect is involved by commit 6e967adf7(tipc:
relocate common functions from media to bearer). Now tipc stack
handler of receiving packets from netdevices as well as netdevice
notification handler are registered when bearer is enabled rather
than tipc module initialization stage, but the two handlers are
both unregistered in tipc module exit phase. If tipc module is
inserted and then immediately removed, the following warning
message will appear:

"dev_remove_pack: ffffffffa0380940 not found"

This is because in module insertion stage tipc stack packet handler
is not registered at all, but in module exit phase dev_remove_pack()
needs to remove it. Of course, dev_remove_pack() cannot find tipc
protocol handler from the kernel protocol handler list so that the
warning message is printed out.

But if registering the two handlers is adjusted from enabling bearer
phase into inserting module stage, the warning message will be
eliminated. Due to this change, tipc_core_start_net() and
tipc_core_stop_net() can be deleted as well.

Reported-by: Wang Weidong <wangweidong1@huawei.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    7 ++++++-
 net/tipc/config.c |    2 +-
 net/tipc/core.c   |   38 +++++++++-----------------------------
 net/tipc/core.h   |    1 -
 4 files changed, 16 insertions(+), 32 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index a38c899..574b861 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -610,8 +610,13 @@ static struct notifier_block notifier = {
 
 int tipc_bearer_setup(void)
 {
+	int err;
+
+	err = register_netdevice_notifier(&notifier);
+	if (err)
+		return err;
 	dev_add_pack(&tipc_packet_type);
-	return register_netdevice_notifier(&notifier);
+	return 0;
 }
 
 void tipc_bearer_cleanup(void)
diff --git a/net/tipc/config.c b/net/tipc/config.c
index c301a9a..e74eef2 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -181,7 +181,7 @@ static struct sk_buff *cfg_set_own_addr(void)
 	if (tipc_own_addr)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (cannot change node address once assigned)");
-	tipc_core_start_net(addr);
+	tipc_net_start(addr);
 	return tipc_cfg_reply_none();
 }
 
diff --git a/net/tipc/core.c b/net/tipc/core.c
index cfd9cc1..80c2064 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -77,37 +77,13 @@ struct sk_buff *tipc_buf_acquire(u32 size)
 }
 
 /**
- * tipc_core_stop_net - shut down TIPC networking sub-systems
- */
-static void tipc_core_stop_net(void)
-{
-	tipc_net_stop();
-	tipc_bearer_cleanup();
-}
-
-/**
- * start_net - start TIPC networking sub-systems
- */
-int tipc_core_start_net(unsigned long addr)
-{
-	int res;
-
-	tipc_net_start(addr);
-	res = tipc_bearer_setup();
-	if (res < 0)
-		goto err;
-	return res;
-
-err:
-	tipc_core_stop_net();
-	return res;
-}
-
-/**
  * tipc_core_stop - switch TIPC from SINGLE NODE to NOT RUNNING mode
  */
 static void tipc_core_stop(void)
 {
+	tipc_handler_stop();
+	tipc_net_stop();
+	tipc_bearer_cleanup();
 	tipc_netlink_stop();
 	tipc_cfg_stop();
 	tipc_subscr_stop();
@@ -158,7 +134,13 @@ static int tipc_core_start(void)
 	if (err)
 		goto out_cfg;
 
+	err = tipc_bearer_setup();
+	if (err)
+		goto out_bearer;
+
 	return 0;
+out_bearer:
+	tipc_cfg_stop();
 out_cfg:
 	tipc_subscr_stop();
 out_subscr:
@@ -203,8 +185,6 @@ static int __init tipc_init(void)
 
 static void __exit tipc_exit(void)
 {
-	tipc_handler_stop();
-	tipc_core_stop_net();
 	tipc_core_stop();
 	pr_info("Deactivated\n");
 }
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 5569d96..4dfe137 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -90,7 +90,6 @@ extern int tipc_random __read_mostly;
 /*
  * Routines available to privileged subsystems
  */
-int tipc_core_start_net(unsigned long);
 int tipc_handler_start(void);
 void tipc_handler_stop(void);
 int tipc_netlink_start(void);
-- 
1.7.9.5
