From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 04/21] net: expose the master link to sysfs, and remove it from bond
Date: Mon,  2 Sep 2013 23:39:08 +0200
Message-ID: <1378157965-17537-5-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759113Ab3IBVjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:20 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
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
 drivers/net/bonding/bond_sysfs.c | 12 +-----------
 net/core/dev.c                   |  9 +++++++++
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 0f539de..5715277 100644
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
index fc5c5a1..7eecf35 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4580,6 +4580,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					bool upper, void *private)
 {
 	struct netdev_adjacent *adj, *neigh = NULL;
+	int ret;
 
 	adj = __netdev_find_adj(dev, adj_dev, upper, false);
 
@@ -4636,6 +4637,12 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
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
 				     &dev->neighbour_dev_list.upper);
@@ -4716,6 +4723,8 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 			 adj_dev->name, upper ? "upper" : "lower", dev->name,
 			 adj_dev->name);
 		list_del_rcu(&neighbour->list);
+		if (neighbour->master && upper)
+			sysfs_remove_link(&(dev->dev.kobj), "master");
 		dev_put(adj_dev);
 		kfree_rcu(neighbour, rcu);
 	}
-- 
1.8.4
