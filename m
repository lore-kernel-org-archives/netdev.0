From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/23] tipc: Do timely cleanup of disabled Ethernet bearer resources
Date: Tue, 27 Dec 2011 12:39:32 -0500
Message-ID: <1325007582-31610-14-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39459 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754806Ab1L0RkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:04 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies Ethernet bearer disable logic to break the association between
the bearer and its device driver at the time the bearer is disabled,
rather than when the TIPC module is unloaded. This allows the array
entry used by the disabled bearer to be re-used if the same bearer (or
a different one) is subsequently enabled.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c |   39 +++++++++++++++++++++++++++------------
 1 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 23bf67b..236155c 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -46,12 +46,14 @@
  * @bearer: ptr to associated "generic" bearer structure
  * @dev: ptr to associated Ethernet network device
  * @tipc_packet_type: used in binding TIPC to Ethernet driver
+ * @cleanup: work item used when disabling bearer
  */
 
 struct eth_bearer {
 	struct tipc_bearer *bearer;
 	struct net_device *dev;
 	struct packet_type tipc_packet_type;
+	struct work_struct cleanup;
 };
 
 static struct media eth_media_info;
@@ -192,16 +194,36 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 }
 
 /**
+ * cleanup_bearer - break association between Ethernet bearer and interface
+ *
+ * This routine must be invoked from a work queue because it can sleep.
+ */
+
+static void cleanup_bearer(struct work_struct *work)
+{
+	struct eth_bearer *eb_ptr =
+		container_of(work, struct eth_bearer, cleanup);
+
+	dev_remove_pack(&eb_ptr->tipc_packet_type);
+	dev_put(eb_ptr->dev);
+	eb_ptr->dev = NULL;
+}
+
+/**
  * disable_bearer - detach TIPC bearer from an Ethernet interface
  *
- * We really should do dev_remove_pack() here, but this function can not be
- * called at tasklet level. => Use eth_bearer->bearer as a flag to throw away
- * incoming buffers, & postpone dev_remove_pack() to eth_media_stop() on exit.
+ * Mark Ethernet bearer as inactive so that incoming buffers are thrown away,
+ * then get worker thread to complete bearer cleanup.  (Can't do cleanup
+ * here because cleanup code needs to sleep and caller holds spinlocks.)
  */
 
 static void disable_bearer(struct tipc_bearer *tb_ptr)
 {
-	((struct eth_bearer *)tb_ptr->usr_handle)->bearer = NULL;
+	struct eth_bearer *eb_ptr = (struct eth_bearer *)tb_ptr->usr_handle;
+
+	eb_ptr->bearer = NULL;
+	INIT_WORK(&eb_ptr->cleanup, cleanup_bearer);
+	schedule_work(&eb_ptr->cleanup);
 }
 
 /**
@@ -369,18 +391,11 @@ int tipc_eth_media_start(void)
 
 void tipc_eth_media_stop(void)
 {
-	int i;
-
 	if (!eth_started)
 		return;
 
+	flush_scheduled_work();
 	unregister_netdevice_notifier(&notifier);
-	for (i = 0; i < MAX_ETH_BEARERS ; i++) {
-		if (eth_bearers[i].dev) {
-			dev_remove_pack(&eth_bearers[i].tipc_packet_type);
-			dev_put(eth_bearers[i].dev);
-		}
-	}
 	memset(&eth_bearers, 0, sizeof(eth_bearers));
 	eth_started = 0;
 }
-- 
1.7.4.4
