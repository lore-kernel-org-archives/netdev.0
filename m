From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 26/27] net: expose the master link to sysfs, and remove it from bond
Date: Tue, 10 Sep 2013 22:58:10 +0200
Message-ID: <1378846691-9717-27-git-send-email-vfalico@redhat.com>
References: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255Ab3IJU6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 16:58:54 -0400
In-Reply-To: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we can have only one master upper neighbour, so it would be
useful to create a symlink to it in the sysfs device directory, the way
that bonding now does it, for every device. Lower devices from
bridge/team/etc will automagically get it, so we could rely on it.

Also, remove the same functionality from bonding.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    No changes.

 drivers/net/bonding/bond_sysfs.c | 12 +-----------
 net/core/dev.c                   |  9 +++++++++
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 5d40889..fd178a4 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -174,20 +174,11 @@ int bond_create_slave_symlinks(struct net_device *master,
 	char linkname[IFNAMSIZ+7];
 	int ret = 0;
 
-	/* first, create a link from the slave back to the master */
-	ret = sysfs_create_link(&(slave->dev.kobj), &(master->dev.kobj),
-				"master");
-	if (ret)
-		return ret;
-	/* next, create a link from the master to the slave */
+	/* create a link from the master to the slave */
 	sprintf(linkname, "slave_%s", slave->name);
 	ret = sysfs_create_link(&(master->dev.kobj), &(slave->dev.kobj),
 				linkname);
 
-	/* free the master link created earlier in case of error */
-	if (ret)
-		sysfs_remove_link(&(slave->dev.kobj), "master");
-
 	return ret;
 
 }
@@ -197,7 +188,6 @@ void bond_destroy_slave_symlinks(struct net_device *master,
 {
 	char linkname[IFNAMSIZ+7];
 
-	sysfs_remove_link(&(slave->dev.kobj), "master");
 	sprintf(linkname, "slave_%s", slave->name);
 	sysfs_remove_link(&(master->dev.kobj), linkname);
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index d58ca53..27ca03f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4638,6 +4638,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					bool upper, void *private)
 {
 	struct netdev_adjacent *adj, *neigh = NULL;
+	int ret;
 
 	adj = __netdev_find_adj(dev, adj_dev, upper, false);
 
@@ -4693,6 +4694,12 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 	/* Ensure that master upper link is always the first item in list. */
 	if (master) {
+		ret = sysfs_create_link(&(dev->dev.kobj), &(adj_dev->dev.kobj), "master");
+		if (ret) {
+			kfree(neigh);
+			kfree(adj);
+			return ret;
+		}
 		if (neigh)
 			list_add_rcu(&neigh->list,
 				     &dev->adj_list.upper);
@@ -4749,6 +4756,8 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 		pr_debug("dev_put for %s, because of %s link removed from %s to %s (neighbour)\n",
 			 adj_dev->name, upper ? "upper" : "lower", dev->name,
 			 adj_dev->name);
+		if (neighbour->master && upper)
+			sysfs_remove_link(&(dev->dev.kobj), "master");
 		list_del_rcu(&neighbour->list);
 		dev_put(adj_dev);
 		kfree_rcu(neighbour, rcu);
-- 
1.8.4
