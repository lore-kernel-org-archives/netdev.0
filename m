From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 07/16] netconsole: factor out alloc_netconsole_target()
Date: Thu, 16 Apr 2015 19:03:44 -0400
Message-ID: <1429225433-11946-8-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:34146 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbbDPXE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:04:29 -0400
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_param_target() and make_netconsole_target() were duplicating the
same allocation and init logic.  Factor it out to
alloc_netconsole_target().

This is pure reorganization.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 09d4e12..17692b8 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -167,19 +167,17 @@ static void netconsole_target_put(struct netconsole_target *nt)
 
 #endif	/* CONFIG_NETCONSOLE_DYNAMIC */
 
-/* Allocate new target (from boot/module param) and setup netpoll for it */
-static struct netconsole_target *alloc_param_target(char *target_config)
+/*
+ * Allocate and initialize with defaults.  Note that these targets get
+ * their config_item fields zeroed-out.
+ */
+static struct netconsole_target *alloc_netconsole_target(void)
 {
-	int err = -ENOMEM;
 	struct netconsole_target *nt;
 
-	/*
-	 * Allocate and initialize with defaults.
-	 * Note that these targets get their config_item fields zeroed-out.
-	 */
 	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
 	if (!nt)
-		goto fail;
+		return NULL;
 
 	nt->np.name = "netconsole";
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
@@ -188,6 +186,19 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	mutex_init(&nt->mutex);
 	eth_broadcast_addr(nt->np.remote_mac);
 
+	return nt;
+}
+
+/* Allocate new target (from boot/module param) and setup netpoll for it */
+static struct netconsole_target *alloc_param_target(char *target_config)
+{
+	int err = -ENOMEM;
+	struct netconsole_target *nt;
+
+	nt = alloc_netconsole_target();
+	if (!nt)
+		goto fail;
+
 	/* Parse parameters and setup netpoll */
 	err = netpoll_parse_options(&nt->np, target_config);
 	if (err)
@@ -592,21 +603,10 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	unsigned long flags;
 	struct netconsole_target *nt;
 
-	/*
-	 * Allocate and initialize with defaults.
-	 * Target is disabled at creation (!enabled).
-	 */
-	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
+	nt = alloc_netconsole_target();
 	if (!nt)
 		return ERR_PTR(-ENOMEM);
 
-	nt->np.name = "netconsole";
-	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
-	nt->np.local_port = 6665;
-	nt->np.remote_port = 6666;
-	mutex_init(&nt->mutex);
-	eth_broadcast_addr(nt->np.remote_mac);
-
 	/* Initialize the config_item member */
 	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
 
-- 
2.1.0
