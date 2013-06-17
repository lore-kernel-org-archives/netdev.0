From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/16] tipc: remove dev_base_lock use from enable_bearer
Date: Mon, 17 Jun 2013 10:54:51 -0400
Message-ID: <1371480891-5264-17-git-send-email-paul.gortmaker@windriver.com>
References: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42772 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936Ab3FQOzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 10:55:24 -0400
In-Reply-To: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Convert enable_bearer() to RCU locking with dev_get_by_name().

Based on a similar changeset in commit 840a185d ["aoe: remove
dev_base_lock use from aoecmd_cfg_pkts()"] -- quoting that:

  "dev_base_lock is the legacy way to lock the device list,
   and is planned to disappear. (writers hold RTNL, readers
   hold RCU lock)"

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c | 13 ++-----------
 net/tipc/ib_media.c  | 13 ++-----------
 2 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index c1aa37f..40ea40c 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -162,8 +162,7 @@ static void setup_bearer(struct work_struct *work)
  */
 static int enable_bearer(struct tipc_bearer *tb_ptr)
 {
-	struct net_device *dev = NULL;
-	struct net_device *pdev = NULL;
+	struct net_device *dev;
 	struct eth_bearer *eb_ptr = &eth_bearers[0];
 	struct eth_bearer *stop = &eth_bearers[MAX_ETH_BEARERS];
 	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
@@ -178,15 +177,7 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	}
 
 	/* Find device with specified name */
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, pdev) {
-		if (!strncmp(pdev->name, driver_name, IFNAMSIZ)) {
-			dev = pdev;
-			dev_hold(dev);
-			break;
-		}
-	}
-	read_unlock(&dev_base_lock);
+	dev = dev_get_by_name(&init_net, driver_name);
 	if (!dev)
 		return -ENODEV;
 
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index baa9df4..ad2e1ec 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -155,8 +155,7 @@ static void setup_bearer(struct work_struct *work)
  */
 static int enable_bearer(struct tipc_bearer *tb_ptr)
 {
-	struct net_device *dev = NULL;
-	struct net_device *pdev = NULL;
+	struct net_device *dev;
 	struct ib_bearer *ib_ptr = &ib_bearers[0];
 	struct ib_bearer *stop = &ib_bearers[MAX_IB_BEARERS];
 	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
@@ -171,15 +170,7 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	}
 
 	/* Find device with specified name */
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, pdev) {
-		if (!strncmp(pdev->name, driver_name, IFNAMSIZ)) {
-			dev = pdev;
-			dev_hold(dev);
-			break;
-		}
-	}
-	read_unlock(&dev_base_lock);
+	dev = dev_get_by_name(&init_net, driver_name);
 	if (!dev)
 		return -ENODEV;
 
-- 
1.8.1.2
