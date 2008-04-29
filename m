From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/8][BONDING]: Remove redundant argument from bond_create.
Date: Tue, 29 Apr 2008 19:01:23 +0400
Message-ID: <48173843.60405@openvz.org>
References: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41111 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754028AbYD2PFy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:05:54 -0400
In-Reply-To: <481735F4.30909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While we're fixing the bond_create, I hope it's OK to polish it
a bit after the fixes.

The third argument is NULL at the first caller and is ignored by
the second one, so remove it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 drivers/net/bonding/bond_main.c  |    7 ++-----
 drivers/net/bonding/bond_sysfs.c |    2 +-
 drivers/net/bonding/bonding.h    |    2 +-
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0907f43..c6661a9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4874,7 +4874,7 @@ static struct lock_class_key bonding_netdev_xmit_lock_key;
  * Caller must NOT hold rtnl_lock; we need to release it here before we
  * set up our sysfs entries.
  */
-int bond_create(char *name, struct bond_params *params, struct bonding **newbond)
+int bond_create(char *name, struct bond_params *params)
 {
 	struct net_device *bond_dev;
 	struct bonding *bond, *nxt;
@@ -4931,9 +4931,6 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 
 	lockdep_set_class(&bond_dev->_xmit_lock, &bonding_netdev_xmit_lock_key);
 
-	if (newbond)
-		*newbond = bond_dev->priv;
-
 	netif_carrier_off(bond_dev);
 
 	up_write(&bonding_rwsem);
@@ -4981,7 +4978,7 @@ static int __init bonding_init(void)
 	init_rwsem(&bonding_rwsem);
 
 	for (i = 0; i < max_bonds; i++) {
-		res = bond_create(NULL, &bonding_defaults, NULL);
+		res = bond_create(NULL, &bonding_defaults);
 		if (res)
 			goto err;
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 979c2d0..88de27f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -122,7 +122,7 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 	if (command[0] == '+') {
 		printk(KERN_INFO DRV_NAME
 			": %s is being created...\n", ifname);
-		rv = bond_create(ifname, &bonding_defaults, &bond);
+		rv = bond_create(ifname, &bonding_defaults);
 		if (rv) {
 			printk(KERN_INFO DRV_NAME ": Bond creation failed.\n");
 			res = rv;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a3c74e2..0ce7f4a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -301,7 +301,7 @@ static inline void bond_unset_master_alb_flags(struct bonding *bond)
 
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
+int bond_create(char *name, struct bond_params *params);
 void bond_destroy(struct bonding *bond);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
-- 
1.5.3.4

