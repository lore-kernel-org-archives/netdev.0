From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 4/4] bonding: add rtnl lock and remove read lock
 for bond sysfs
Date: Sun, 29 Sep 2013 19:45:38 +0800
Message-ID: <524812E2.5020805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:4243 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab3I2LqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 07:46:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_for_each_slave() will not be protected by read_lock(),
only protected by rtnl_lock(), so need to replace read_lock()
with rtnl_lock().

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 30 +++++++++++++++++-------------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index e06c644..2ba1114 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -179,7 +179,9 @@ static ssize_t bonding_show_slaves(struct device *d,
 	struct slave *slave;
 	int res = 0;
 
-	read_lock(&bond->lock);
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	bond_for_each_slave(bond, slave, iter) {
 		if (res > (PAGE_SIZE - IFNAMSIZ)) {
 			/* not enough space for another interface name */
@@ -190,7 +192,9 @@ static ssize_t bonding_show_slaves(struct device *d,
 		}
 		res += sprintf(buf + res, "%s ", slave->dev->name);
 	}
-	read_unlock(&bond->lock);
+
+	rtnl_unlock();
+
 	if (res)
 		buf[res-1] = '\n'; /* eat the leftover space */
 
@@ -628,6 +632,9 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 	unsigned long *targets_rx;
 	int ind, i, j, ret = -EINVAL;
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	targets = bond->params.arp_targets;
 	newtarget = in_aton(buf + 1);
 	/* look for adds */
@@ -701,6 +708,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 
 	ret = count;
 out:
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(arp_ip_target, S_IRUGO | S_IWUSR , bonding_show_arp_targets, bonding_store_arp_targets);
@@ -1469,7 +1477,6 @@ static ssize_t bonding_show_queue_id(struct device *d,
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, iter) {
 		if (res > (PAGE_SIZE - IFNAMSIZ - 6)) {
 			/* not enough space for another interface_name:queue_id pair */
@@ -1481,9 +1488,9 @@ static ssize_t bonding_show_queue_id(struct device *d,
 		res += sprintf(buf + res, "%s:%d ",
 			       slave->dev->name, slave->queue_id);
 	}
-	read_unlock(&bond->lock);
 	if (res)
 		buf[res-1] = '\n'; /* eat the leftover space */
+
 	rtnl_unlock();
 
 	return res;
@@ -1532,8 +1539,6 @@ static ssize_t bonding_store_queue_id(struct device *d,
 	if (!sdev)
 		goto err_no_cmd;
 
-	read_lock(&bond->lock);
-
 	/* Search for thes slave and check for duplicate qids */
 	update_slave = NULL;
 	bond_for_each_slave(bond, slave, iter) {
@@ -1544,23 +1549,20 @@ static ssize_t bonding_store_queue_id(struct device *d,
 			 */
 			update_slave = slave;
 		else if (qid && qid == slave->queue_id) {
-			goto err_no_cmd_unlock;
+			goto err_no_cmd;
 		}
 	}
 
 	if (!update_slave)
-		goto err_no_cmd_unlock;
+		goto err_no_cmd;
 
 	/* Actually set the qids for the slave */
 	update_slave->queue_id = qid;
 
-	read_unlock(&bond->lock);
 out:
 	rtnl_unlock();
 	return ret;
 
-err_no_cmd_unlock:
-	read_unlock(&bond->lock);
 err_no_cmd:
 	pr_info("invalid input for queue_id set for %s.\n",
 		bond->dev->name);
@@ -1593,6 +1595,9 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 	struct list_head *iter;
 	struct slave *slave;
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no all_slaves_active value specified.\n",
 		       bond->dev->name);
@@ -1612,7 +1617,6 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 		goto out;
 	}
 
-	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, iter) {
 		if (!bond_is_active_slave(slave)) {
 			if (new_value)
@@ -1621,8 +1625,8 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 				slave->inactive = 1;
 		}
 	}
-	read_unlock(&bond->lock);
 out:
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
-- 
1.8.2.1
