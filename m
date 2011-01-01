From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/20] tipc: Eliminate use of user registry by configuration service
Date: Fri, 31 Dec 2010 23:59:20 -0500
Message-ID: <1293857975-30267-6-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53255 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab1AAFAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:02 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Simplifies TIPC's configuration service so that it no longer registers
its port with the user registry, since the service doesn't take advantage
of any of the registry's capabilities.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c |   26 +++++++-------------------
 1 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index bc51210..322367b 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -38,15 +38,9 @@
 #include "port.h"
 #include "link.h"
 #include "name_table.h"
-#include "user_reg.h"
 #include "config.h"
 
-struct manager {
-	u32 user_ref;
-	u32 port_ref;
-};
-
-static struct manager mng = { 0};
+static u32 config_port_ref;
 
 static DEFINE_SPINLOCK(config_lock);
 
@@ -506,20 +500,16 @@ int tipc_cfg_init(void)
 	struct tipc_name_seq seq;
 	int res;
 
-	res = tipc_attach(&mng.user_ref);
-	if (res)
-		goto failed;
-
-	res = tipc_createport(mng.user_ref, NULL, TIPC_CRITICAL_IMPORTANCE,
+	res = tipc_createport(0, NULL, TIPC_CRITICAL_IMPORTANCE,
 			      NULL, NULL, NULL,
 			      NULL, cfg_named_msg_event, NULL,
-			      NULL, &mng.port_ref);
+			      NULL, &config_port_ref);
 	if (res)
 		goto failed;
 
 	seq.type = TIPC_CFG_SRV;
 	seq.lower = seq.upper = tipc_own_addr;
-	res = tipc_nametbl_publish_rsv(mng.port_ref, TIPC_ZONE_SCOPE, &seq);
+	res = tipc_nametbl_publish_rsv(config_port_ref, TIPC_ZONE_SCOPE, &seq);
 	if (res)
 		goto failed;
 
@@ -527,15 +517,13 @@ int tipc_cfg_init(void)
 
 failed:
 	err("Unable to create configuration service\n");
-	tipc_detach(mng.user_ref);
-	mng.user_ref = 0;
 	return res;
 }
 
 void tipc_cfg_stop(void)
 {
-	if (mng.user_ref) {
-		tipc_detach(mng.user_ref);
-		mng.user_ref = 0;
+	if (config_port_ref) {
+		tipc_deleteport(config_port_ref);
+		config_port_ref = 0;
 	}
 }
-- 
1.7.3.3

