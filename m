From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/16] tipc: convert config_lock from spinlock to mutex
Date: Mon, 17 Jun 2013 10:54:45 -0400
Message-ID: <1371480891-5264-11-git-send-email-paul.gortmaker@windriver.com>
References: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42760 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874Ab3FQOzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 10:55:19 -0400
In-Reply-To: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

As the configuration server is now running under process context,
it's unnecessary for us to have a spinlock serializing the TIPC
configuration process. Instead, we replace it with a mutex lock,
which gives us more freedom. For instance, we can now call
pre-emptable functions within the protected area.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 4887ae0..c301a9a 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -42,7 +42,7 @@
 
 #define REPLY_TRUNCATED "<truncated>\n"
 
-static DEFINE_SPINLOCK(config_lock);
+static DEFINE_MUTEX(config_mutex);
 static struct tipc_server cfgsrv;
 
 static const void *req_tlv_area;	/* request message TLV area */
@@ -181,18 +181,7 @@ static struct sk_buff *cfg_set_own_addr(void)
 	if (tipc_own_addr)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (cannot change node address once assigned)");
-
-	/*
-	 * Must temporarily release configuration spinlock while switching into
-	 * networking mode as it calls tipc_eth_media_start(), which may sleep.
-	 * Releasing the lock is harmless as other locally-issued configuration
-	 * commands won't occur until this one completes, and remotely-issued
-	 * configuration commands can't be received until a local configuration
-	 * command to enable the first bearer is received and processed.
-	 */
-	spin_unlock_bh(&config_lock);
 	tipc_core_start_net(addr);
-	spin_lock_bh(&config_lock);
 	return tipc_cfg_reply_none();
 }
 
@@ -248,7 +237,7 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 {
 	struct sk_buff *rep_tlv_buf;
 
-	spin_lock_bh(&config_lock);
+	mutex_lock(&config_mutex);
 
 	/* Save request and reply details in a well-known location */
 	req_tlv_area = request_area;
@@ -377,7 +366,7 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 
 	/* Return reply buffer */
 exit:
-	spin_unlock_bh(&config_lock);
+	mutex_unlock(&config_mutex);
 	return rep_tlv_buf;
 }
 
-- 
1.8.1.2
