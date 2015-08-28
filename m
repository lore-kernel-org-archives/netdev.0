From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the rdma tree with the net-next tree
Date: Fri, 28 Aug 2015 11:26:50 +1000
Message-ID: <20150828112650.50b2ae58@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matan Barak <matanb@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Doug Ledford <dledford@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Doug,

Today's linux-next merge of the rdma tree got a conflict in:

  net/core/dev.c

between commit:

  0e4ead9d7b36 ("net: introduce change upper device notifier change info")

from the net-next tree and commit:

  133b5b93c734 ("net: Add info for NETDEV_CHANGEUPPER event")

from the rdma tree.

They are doing very similar things, but not identical.

I fixed it up (see bottom of email and the below extra patch) and can
carry the fix as necessary (no action is required unless something more
correct is supplied, of course).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 28 Aug 2015 11:14:38 +1000
Subject: [PATCH] net: merge change upper notifier changes

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/infiniband/core/roce_gid_mgmt.c | 12 ++++++------
 include/linux/netdevice.h               | 23 +++++++++--------------
 2 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/drivers/infiniband/core/roce_gid_mgmt.c b/drivers/infiniband/core/roce_gid_mgmt.c
index 6eecdfbf3aef..69e2ffa35d91 100644
--- a/drivers/infiniband/core/roce_gid_mgmt.c
+++ b/drivers/infiniband/core/roce_gid_mgmt.c
@@ -529,7 +529,7 @@ static const struct netdev_event_work_cmd add_cmd = {
 static const struct netdev_event_work_cmd add_cmd_upper_ips = {
 	.cb = add_netdev_upper_ips, .filter = is_eth_port_of_netdev};
 
-static void netdevice_event_changeupper(struct netdev_changeupper_info *changeupper_info,
+static void netdevice_event_changeupper(struct netdev_notifier_changeupper_info *changeupper_info,
 					struct netdev_event_work_cmd *cmds)
 {
 	static const struct netdev_event_work_cmd upper_ips_del_cmd = {
@@ -540,15 +540,15 @@ static void netdevice_event_changeupper(struct netdev_changeupper_info *changeup
 	if (changeupper_info->event ==
 	    NETDEV_CHANGEUPPER_UNLINK) {
 		cmds[0] = upper_ips_del_cmd;
-		cmds[0].ndev = changeupper_info->upper;
+		cmds[0].ndev = changeupper_info->upper_dev;
 		cmds[1] = add_cmd;
 	} else if (changeupper_info->event ==
 		   NETDEV_CHANGEUPPER_LINK) {
 		cmds[0] = bonding_default_del_cmd;
-		cmds[0].ndev = changeupper_info->upper;
+		cmds[0].ndev = changeupper_info->upper_dev;
 		cmds[1] = add_cmd_upper_ips;
-		cmds[1].ndev = changeupper_info->upper;
-		cmds[1].filter_ndev = changeupper_info->upper;
+		cmds[1].ndev = changeupper_info->upper_dev;
+		cmds[1].filter_ndev = changeupper_info->upper_dev;
 	}
 }
 
@@ -590,7 +590,7 @@ static int netdevice_event(struct notifier_block *this, unsigned long event,
 
 	case NETDEV_CHANGEUPPER:
 		netdevice_event_changeupper(
-			container_of(ptr, struct netdev_changeupper_info, info),
+			container_of(ptr, struct netdev_notifier_changeupper_info, info),
 			cmds);
 		break;
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0aa7d19ac85e..4ce420487d07 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2115,13 +2115,22 @@ struct netdev_notifier_change_info {
 	unsigned int flags_changed;
 };
 
+enum netdev_changeupper_event {
+	NETDEV_CHANGEUPPER_LINK,
+	NETDEV_CHANGEUPPER_UNLINK,
+};
+
 struct netdev_notifier_changeupper_info {
 	struct netdev_notifier_info info; /* must be first */
+	enum netdev_changeupper_event event;
 	struct net_device *upper_dev; /* new upper dev */
 	bool master; /* is upper dev master */
 	bool linking; /* is the nofication for link or unlink */
 };
 
+void netdev_changeupper_info_change(struct net_device *dev,
+				    struct netdev_notifier_changeupper_info *info);
+
 static inline void netdev_notifier_info_init(struct netdev_notifier_info *info,
 					     struct net_device *dev)
 {
@@ -3606,20 +3615,6 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 				    netdev_features_t features);
 
-enum netdev_changeupper_event {
-	NETDEV_CHANGEUPPER_LINK,
-	NETDEV_CHANGEUPPER_UNLINK,
-};
-
-struct netdev_changeupper_info {
-	struct netdev_notifier_info	info; /* must be first */
-	enum netdev_changeupper_event	event;
-	struct net_device		*upper;
-};
-
-void netdev_changeupper_info_change(struct net_device *dev,
-				    struct netdev_changeupper_info *info);
-
 struct netdev_bonding_info {
 	ifslave	slave;
 	ifbond	master;
-- 
2.5.0



-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/core/dev.c
index a8e6cf4298d3,6e6f14e5d44f..000000000000
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@@ -5330,10 -5320,6 +5330,11 @@@ static int __netdev_upper_dev_link(stru
  	if (master && netdev_master_upper_dev_get(dev))
  		return -EBUSY;
  
++	changeupper_info.event = NETDEV_CHANGEUPPER_LINK;
 +	changeupper_info.upper_dev = upper_dev;
 +	changeupper_info.master = master;
 +	changeupper_info.linking = true;
 +
  	ret = __netdev_adjacent_dev_link_neighbour(dev, upper_dev, private,
  						   master);
  	if (ret)
@@@ -5468,14 -5456,10 +5469,15 @@@ EXPORT_SYMBOL(netdev_master_upper_dev_l
  void netdev_upper_dev_unlink(struct net_device *dev,
  			     struct net_device *upper_dev)
  {
 +	struct netdev_notifier_changeupper_info changeupper_info;
  	struct netdev_adjacent *i, *j;
 -	struct netdev_changeupper_info changeupper_info;
  	ASSERT_RTNL();
  
++	changeupper_info.event = NETDEV_CHANGEUPPER_UNLINK;
 +	changeupper_info.upper_dev = upper_dev;
 +	changeupper_info.master = netdev_master_upper_dev_get(dev) == upper_dev;
 +	changeupper_info.linking = false;
 +
  	__netdev_adjacent_dev_unlink_neighbour(dev, upper_dev);
  
  	/* Here is the tricky part. We must remove all dev's lower
