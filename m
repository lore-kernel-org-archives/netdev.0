From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/3] netconsole: make all dynamic netconsoles share a mutex
Date: Fri,  1 May 2015 14:33:39 -0400
Message-ID: <1430505220-25160-3-git-send-email-tj@kernel.org>
References: <1430505220-25160-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: davem@davemloft.net, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:33469 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbbEASdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:33:52 -0400
In-Reply-To: <1430505220-25160-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, each dynamic netconsole_target uses its own separate mutex
to synchronize the configuration operations.  This patch replaces the
per-netconsole_target mutexes with a single mutex -
dynamic_netconsole_mutex.  The reduced granularity doesn't hurt
anything, the code is minutely simpler and this'd allow adding
operations which should be synchronized across all dynamic
netconsoles.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 09d4e12..d9f0f85 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -105,13 +105,13 @@ struct netconsole_target {
 	struct config_item	item;
 #endif
 	bool			enabled;
-	struct mutex		mutex;
 	struct netpoll		np;
 };
 
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
 
 static struct configfs_subsystem netconsole_subsys;
+static DEFINE_MUTEX(dynamic_netconsole_mutex);
 
 static int __init dynamic_netconsole_init(void)
 {
@@ -185,7 +185,6 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
-	mutex_init(&nt->mutex);
 	eth_broadcast_addr(nt->np.remote_mac);
 
 	/* Parse parameters and setup netpoll */
@@ -562,10 +561,10 @@ static ssize_t netconsole_target_attr_store(struct config_item *item,
 	struct netconsole_target_attr *na =
 		container_of(attr, struct netconsole_target_attr, attr);
 
-	mutex_lock(&nt->mutex);
+	mutex_lock(&dynamic_netconsole_mutex);
 	if (na->store)
 		ret = na->store(nt, buf, count);
-	mutex_unlock(&nt->mutex);
+	mutex_unlock(&dynamic_netconsole_mutex);
 
 	return ret;
 }
@@ -604,7 +603,6 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
-	mutex_init(&nt->mutex);
 	eth_broadcast_addr(nt->np.remote_mac);
 
 	/* Initialize the config_item member */
-- 
2.1.0
