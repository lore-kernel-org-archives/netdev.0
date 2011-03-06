From: Adam Majer <adamm@zombino.com>
Subject: [PATCH 1/2] Issue NETDEV_CHANGE notification when bridge changes
 state
Date: Sat, 5 Mar 2011 23:18:33 -0600
Message-ID: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


IPv6 address autoconfiguration relies on an UP interface to processes
traffic normally. A bridge that is UP enters LEARNING state and this
state "eats" any Router Advertising packets sent to the
bridge. Issuing a NETDEV_CHANGE notification on the bridge interface
when it changes state allows autoconfiguration code to retry
querying router information.

Signed-off-by: Adam Majer <adamm@zombino.com>
---
 net/bridge/br_if.c      |   20 ++++++++++++++++++++
 net/bridge/br_private.h |    2 ++
 net/bridge/br_stp.c     |    2 ++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index d9d1e2b..9604d52 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -25,6 +25,22 @@
 
 #include "br_private.h"
 
+
+/*
+ * Notifies that the bridge has changed state
+ */
+static void br_port_change_notifier_handler(struct work_struct *work)
+{
+	struct net_bridge *br = container_of(work,
+					     struct net_bridge,
+					     change_notification_worker);
+
+	rtnl_lock();
+	netdev_state_change(br->dev);
+	rtnl_unlock();
+}
+
+
 /*
  * Determine initial path cost based on speed.
  * using recommendations from 802.1d standard
@@ -163,6 +179,7 @@ static void del_br(struct net_bridge *br, struct list_head *head)
 {
 	struct net_bridge_port *p, *n;
 
+	flush_work(&br->change_notification_worker);
 	list_for_each_entry_safe(p, n, &br->port_list, list) {
 		del_nbp(p);
 	}
@@ -203,6 +220,9 @@ static struct net_device *new_bridge_dev(struct net *net, const char *name)
 
 	memcpy(br->group_addr, br_group_address, ETH_ALEN);
 
+	INIT_WORK(&br->change_notification_worker,
+		  &br_port_change_notifier_handler);
+
 	br->feature_mask = dev->features;
 	br->stp_enabled = BR_NO_STP;
 	br->designated_root = br->bridge_id;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4e1b620..7f8ef41 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -179,6 +179,8 @@ struct net_bridge
 	struct list_head		port_list;
 	struct net_device		*dev;
 
+	struct work_struct		change_notification_worker;
+
 	struct br_cpu_netstats __percpu *stats;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 57186d8..b5be3e3 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -296,6 +296,8 @@ void br_topology_change_detection(struct net_bridge *br)
 {
 	int isroot = br_is_root_bridge(br);
 
+	queue_work(system_long_wq, &br->change_notification_worker);
+
 	if (br->stp_enabled != BR_KERNEL_STP)
 		return;
 
-- 
1.7.2.3
