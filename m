From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 26/27] net: expose the master link to sysfs, and remove it from bond
Date: Wed, 25 Sep 2013 09:20:31 +0200
Message-ID: <1380093632-1842-27-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753653Ab3IYHVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:21:18 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
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
    v4  -> v5
    No change.
    
    v3  -> v4:
    Convert the logic to the new functions, which don't have the bool upper
    argument.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    No changes.

 drivers/net/bonding/bond_sysfs.c | 20 +++-----------------
 net/core/dev.c                   | 19 +++++++++++++++++--
 2 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 04d95d6..1c57246 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -172,24 +172,11 @@ int bond_create_slave_symlinks(struct net_device *master,
 			       struct net_device *slave)
 {
 	char linkname[IFNAMSIZ+7];
-	int ret = 0;
 
-	/* first, create a link from the slave back to the master */
-	ret = sysfs_create_link(&(slave->dev.kobj), &(master->dev.kobj),
-				"master");
-	if (ret)
-		return ret;
-	/* next, create a link from the master to the slave */
+	/* create a link from the master to the slave */
 	sprintf(linkname, "slave_%s", slave->name);
-	ret = sysfs_create_link(&(master->dev.kobj), &(slave->dev.kobj),
-				linkname);
-
-	/* free the master link created earlier in case of error */
-	if (ret)
-		sysfs_remove_link(&(slave->dev.kobj), "master");
-
-	return ret;
-
+	return sysfs_create_link(&(master->dev.kobj), &(slave->dev.kobj),
+				 linkname);
 }
 
 void bond_destroy_slave_symlinks(struct net_device *master,
@@ -197,7 +184,6 @@ void bond_destroy_slave_symlinks(struct net_device *master,
 {
 	char linkname[IFNAMSIZ+7];
 
-	sysfs_remove_link(&(slave->dev.kobj), "master");
 	sprintf(linkname, "slave_%s", slave->name);
 	sysfs_remove_link(&(master->dev.kobj), linkname);
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index acc1181..de443ee 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4584,6 +4584,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 					void *private, bool master)
 {
 	struct netdev_adjacent *adj;
+	int ret;
 
 	adj = __netdev_find_adj(dev, adj_dev, dev_list);
 
@@ -4606,12 +4607,23 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 		 adj_dev->name, dev->name, adj_dev->name);
 
 	/* Ensure that master link is always the first item in list. */
-	if (master)
+	if (master) {
+		ret = sysfs_create_link(&(dev->dev.kobj),
+					&(adj_dev->dev.kobj), "master");
+		if (ret)
+			goto free_adj;
+
 		list_add_rcu(&adj->list, dev_list);
-	else
+	} else {
 		list_add_tail_rcu(&adj->list, dev_list);
+	}
 
 	return 0;
+
+free_adj:
+	kfree(adj);
+
+	return ret;
 }
 
 void __netdev_adjacent_dev_remove(struct net_device *dev,
@@ -4635,6 +4647,9 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
 		return;
 	}
 
+	if (adj->master)
+		sysfs_remove_link(&(dev->dev.kobj), "master");
+
 	list_del_rcu(&adj->list);
 	pr_debug("dev_put for %s, because link removed from %s to %s\n",
 		 adj_dev->name, dev->name, adj_dev->name);
-- 
1.8.4
