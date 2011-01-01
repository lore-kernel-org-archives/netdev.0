From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/20] tipc: Eliminate use of user registry by topology service
Date: Fri, 31 Dec 2010 23:59:21 -0500
Message-ID: <1293857975-30267-7-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53275 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076Ab1AAFAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:04 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Simplifies TIPC's network topology service so that it no longer registers
its ports with the user registry, since the service doesn't take advantage
of any of the registry's capabilities.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/subscr.c |   26 ++++++++++----------------
 1 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 23f43d0..21abf17 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -36,7 +36,7 @@
 
 #include "core.h"
 #include "name_table.h"
-#include "user_reg.h"
+#include "port.h"
 #include "subscr.h"
 
 /**
@@ -64,7 +64,6 @@ struct subscriber {
  */
 
 struct top_srv {
-	u32 user_ref;
 	u32 setup_port;
 	atomic_t subscription_count;
 	struct list_head subscriber_list;
@@ -494,7 +493,7 @@ static void subscr_named_msg_event(void *usr_handle,
 
 	/* Create server port & establish connection to subscriber */
 
-	tipc_createport(topsrv.user_ref,
+	tipc_createport(0,
 			subscriber,
 			importance,
 			NULL,
@@ -549,13 +548,7 @@ int tipc_subscr_start(void)
 	INIT_LIST_HEAD(&topsrv.subscriber_list);
 
 	spin_lock_bh(&topsrv.lock);
-	res = tipc_attach(&topsrv.user_ref);
-	if (res) {
-		spin_unlock_bh(&topsrv.lock);
-		return res;
-	}
-
-	res = tipc_createport(topsrv.user_ref,
+	res = tipc_createport(0,
 			      NULL,
 			      TIPC_CRITICAL_IMPORTANCE,
 			      NULL,
@@ -570,16 +563,17 @@ int tipc_subscr_start(void)
 		goto failed;
 
 	res = tipc_nametbl_publish_rsv(topsrv.setup_port, TIPC_NODE_SCOPE, &seq);
-	if (res)
+	if (res) {
+		tipc_deleteport(topsrv.setup_port);
+		topsrv.setup_port = 0;
 		goto failed;
+	}
 
 	spin_unlock_bh(&topsrv.lock);
 	return 0;
 
 failed:
 	err("Failed to create subscription service\n");
-	tipc_detach(topsrv.user_ref);
-	topsrv.user_ref = 0;
 	spin_unlock_bh(&topsrv.lock);
 	return res;
 }
@@ -590,8 +584,10 @@ void tipc_subscr_stop(void)
 	struct subscriber *subscriber_temp;
 	spinlock_t *subscriber_lock;
 
-	if (topsrv.user_ref) {
+	if (topsrv.setup_port) {
 		tipc_deleteport(topsrv.setup_port);
+		topsrv.setup_port = 0;
+
 		list_for_each_entry_safe(subscriber, subscriber_temp,
 					 &topsrv.subscriber_list,
 					 subscriber_list) {
@@ -600,7 +596,5 @@ void tipc_subscr_stop(void)
 			subscr_terminate(subscriber);
 			spin_unlock_bh(subscriber_lock);
 		}
-		tipc_detach(topsrv.user_ref);
-		topsrv.user_ref = 0;
 	}
 }
-- 
1.7.3.3

