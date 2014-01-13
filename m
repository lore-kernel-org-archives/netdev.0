From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 2/2] bonding: rename the dev upper link if the master's,
 name changed
Date: Mon, 13 Jan 2014 21:08:43 +0800
Message-ID: <52D3E55B.8080401@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:3056 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbaAMNMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 08:12:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_maste_rename() will rename the links for slave dev's upper dev link,
if faild, it will rollback and rename the new name to old name for slave dev.

Add a new parameter called name to save the old bonding name in struct bonding.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 35 +++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h   |  1 +
 2 files changed, 36 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4b8c58b..8c044c0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2799,11 +2799,41 @@ re_arm:
 
 /*-------------------------- netdev event handling --------------------------*/
 
+static int bond_master_rename(struct bonding *bond)
+{
+	struct slave *slave;
+	struct list_head *iter;
+	char ori_linkname[IFNAMSIZ + 7], new_linkname[IFNAMSIZ + 7];
+	int err = 0;
+
+	sprintf(ori_linkname, "upper_%s", bond->name);
+	sprintf(new_linkname, "upper_%s", bond->dev->name);
+
+	bond_for_each_slave(bond, slave, iter) {
+
+		err = netdev_upper_dev_rename(slave->dev, bond->dev, ori_linkname,
+					new_linkname);
+		if (err) {
+			pr_err("slave %s unable to rename link %s to %s.\n",
+			       slave->dev->name, bond->name, bond->dev->name);
+			break;
+		}
+	}
+	if (!err)
+		strlcpy(bond->name, bond->dev->name, IFNAMSIZ);
+	return err;
+}
 /*
  * Change device name
  */
 static int bond_event_changename(struct bonding *bond)
 {
+	/* If a rename fails, the rollback will cause another
+	 * rename call with the existing name.
+	 */
+	if (bond_master_rename(bond))
+		return NOTIFY_BAD;
+
 	bond_remove_proc_entry(bond);
 	bond_create_proc_entry(bond);
 
@@ -4418,6 +4448,7 @@ unsigned int bond_get_num_tx_queues(void)
 int bond_create(struct net *net, const char *name)
 {
 	struct net_device *bond_dev;
+	struct bonding *bond;
 	int res;
 
 	rtnl_lock();
@@ -4438,6 +4469,10 @@ int bond_create(struct net *net, const char *name)
 
 	netif_carrier_off(bond_dev);
 
+	bond = netdev_priv(bond_dev);
+
+	strlcpy(bond->name, bond_dev->name, IFNAMSIZ);
+
 	rtnl_unlock();
 	if (res < 0)
 		bond_destructor(bond_dev);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a9f4f9f..d279f3a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -232,6 +232,7 @@ struct bonding {
 	struct   proc_dir_entry *proc_entry;
 	char     proc_file_name[IFNAMSIZ];
 #endif /* CONFIG_PROC_FS */
+	char	 name[IFNAMSIZ];
 	struct   list_head bond_list;
 	u32      rr_tx_counter;
 	struct   ad_bond_info ad_info;
-- 
1.8.0
