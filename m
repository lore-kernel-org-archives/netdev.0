From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/7] bonding: move active_slave setting into separate function
Date: Fri, 18 Oct 2013 17:43:35 +0200
Message-ID: <1382111019-1102-4-git-send-email-jiri@resnulli.us>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:45707 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756464Ab3JRPnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:43:46 -0400
Received: by mail-ea0-f169.google.com with SMTP id k11so2103107eaj.14
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:43:45 -0700 (PDT)
In-Reply-To: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do a bit of refactoring on the way.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_options.c | 69 +++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c   | 74 +++++++-------------------------------
 drivers/net/bonding/bonding.h      |  1 +
 3 files changed, 83 insertions(+), 61 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 294b766..09af5d1 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -12,6 +12,9 @@
 
 #include <linux/errno.h>
 #include <linux/if.h>
+#include <linux/netdevice.h>
+#include <linux/rwlock.h>
+#include <linux/rcupdate.h>
 #include "bonding.h"
 
 static bool bond_mode_is_valid(int mode)
@@ -53,3 +56,69 @@ int bond_option_mode_set(struct bonding *bond, int mode)
 	bond->params.mode = mode;
 	return 0;
 }
+
+int bond_option_active_slave_set(struct bonding *bond,
+				 struct net_device *slave_dev)
+{
+	int ret = 0;
+
+	if (slave_dev) {
+		if (!netif_is_bond_slave(slave_dev)) {
+			pr_err("Device %s is not bonding slave.\n",
+			       slave_dev->name);
+			return -EINVAL;
+		}
+
+		if (bond->dev != netdev_master_upper_dev_get(slave_dev)) {
+			pr_err("%s: Device %s is not our slave.\n",
+			       bond->dev->name, slave_dev->name);
+			return -EINVAL;
+		}
+	}
+
+	if (!USES_PRIMARY(bond->params.mode)) {
+		pr_err("%s: Unable to change active slave; %s is in mode %d\n",
+		       bond->dev->name, bond->dev->name, bond->params.mode);
+		return -EINVAL;
+	}
+
+	block_netpoll_tx();
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
+	/* check to see if we are clearing active */
+	if (!slave_dev) {
+		pr_info("%s: Clearing current active slave.\n",
+		bond->dev->name);
+		rcu_assign_pointer(bond->curr_active_slave, NULL);
+		bond_select_active_slave(bond);
+	} else {
+		struct slave *old_active = bond->curr_active_slave;
+		struct slave *new_active = bond_slave_get_rtnl(slave_dev);
+
+		BUG_ON(!new_active);
+
+		if (new_active == old_active) {
+			/* do nothing */
+			pr_info("%s: %s is already the current active slave.\n",
+				bond->dev->name, new_active->dev->name);
+		} else {
+			if (old_active && (new_active->link == BOND_LINK_UP) &&
+			    IS_UP(new_active->dev)) {
+				pr_info("%s: Setting %s as active slave.\n",
+					bond->dev->name, new_active->dev->name);
+				bond_change_active_slave(bond, new_active);
+			} else {
+				pr_err("%s: Could not set %s as active slave; either %s is down or the link is down.\n",
+				       bond->dev->name, new_active->dev->name,
+				       new_active->dev->name);
+				ret = -EINVAL;
+			}
+		}
+	}
+
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+	unblock_netpoll_tx();
+	return ret;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index c234cec..abd2600 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1235,81 +1235,33 @@ static ssize_t bonding_store_active_slave(struct device *d,
 					  struct device_attribute *attr,
 					  const char *buf, size_t count)
 {
-	struct slave *slave, *old_active, *new_active;
+	int ret;
 	struct bonding *bond = to_bond(d);
-	struct list_head *iter;
 	char ifname[IFNAMSIZ];
+	struct net_device *dev;
 
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	old_active = new_active = NULL;
-	block_netpoll_tx();
-	read_lock(&bond->lock);
-	write_lock_bh(&bond->curr_slave_lock);
-
-	if (!USES_PRIMARY(bond->params.mode)) {
-		pr_info("%s: Unable to change active slave; %s is in mode %d\n",
-			bond->dev->name, bond->dev->name, bond->params.mode);
-		goto out;
-	}
-
 	sscanf(buf, "%15s", ifname); /* IFNAMSIZ */
-
-	/* check to see if we are clearing active */
 	if (!strlen(ifname) || buf[0] == '\n') {
-		pr_info("%s: Clearing current active slave.\n",
-			bond->dev->name);
-		rcu_assign_pointer(bond->curr_active_slave, NULL);
-		bond_select_active_slave(bond);
-		goto out;
-	}
-
-	bond_for_each_slave(bond, slave, iter) {
-		if (strncmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
-			old_active = bond->curr_active_slave;
-			new_active = slave;
-			if (new_active == old_active) {
-				/* do nothing */
-				pr_info("%s: %s is already the current"
-					" active slave.\n",
-					bond->dev->name,
-					slave->dev->name);
-				goto out;
-			} else {
-				if ((new_active) &&
-				    (old_active) &&
-				    (new_active->link == BOND_LINK_UP) &&
-				    IS_UP(new_active->dev)) {
-					pr_info("%s: Setting %s as active"
-						" slave.\n",
-						bond->dev->name,
-						slave->dev->name);
-					bond_change_active_slave(bond,
-								 new_active);
-				} else {
-					pr_info("%s: Could not set %s as"
-						" active slave; either %s is"
-						" down or the link is down.\n",
-						bond->dev->name,
-						slave->dev->name,
-						slave->dev->name);
-				}
-				goto out;
-			}
+		dev = NULL;
+	} else {
+		dev = __dev_get_by_name(dev_net(bond->dev), ifname);
+		if (!dev) {
+			ret = -ENODEV;
+			goto out;
 		}
 	}
 
-	pr_info("%s: Unable to set %.*s as active slave.\n",
-		bond->dev->name, (int)strlen(buf) - 1, buf);
- out:
-	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
-	unblock_netpoll_tx();
+	ret = bond_option_active_slave_set(bond, dev);
+	if (!ret)
+		ret = count;
 
+ out:
 	rtnl_unlock();
 
-	return count;
+	return ret;
 
 }
 static DEVICE_ATTR(active_slave, S_IRUGO | S_IWUSR,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 7446849..686759d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -427,6 +427,7 @@ unsigned int bond_get_num_tx_queues(void);
 int bond_netlink_init(void);
 void bond_netlink_fini(void);
 int bond_option_mode_set(struct bonding *bond, int mode);
+int bond_option_active_slave_set(struct bonding *bond, struct net_device *slave_dev);
 
 struct bond_net {
 	struct net *		net;	/* Associated network namespace */
-- 
1.8.3.1
