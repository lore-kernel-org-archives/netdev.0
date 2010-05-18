From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: make bonding_store_slaves simpler
Date: Tue, 18 May 2010 17:46:39 +0200
Message-ID: <20100518154638.GF2878@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752893Ab0ERPqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 11:46:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes bonding_store_slaves function nicer and easier to understand.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c |   66 ++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 41 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 7911438..a4cbaf7 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -211,7 +211,8 @@ static ssize_t bonding_show_slaves(struct device *d,
 /*
  * Set the slaves in the current bond.  The bond interface must be
  * up for this to succeed.
- * This function is largely the same flow as bonding_update_bonds().
+ * This is supposed to be only thin wrapper for bond_enslave and bond_release.
+ * All hard work should be done there.
  */
 static ssize_t bonding_store_slaves(struct device *d,
 				    struct device_attribute *attr,
@@ -219,9 +220,8 @@ static ssize_t bonding_store_slaves(struct device *d,
 {
 	char command[IFNAMSIZ + 1] = { 0, };
 	char *ifname;
-	int i, res, ret = count;
-	struct slave *slave;
-	struct net_device *dev = NULL;
+	int res, ret = count;
+	struct net_device *dev;
 	struct bonding *bond = to_bond(d);
 
 	/* Quick sanity check -- is the bond interface up? */
@@ -230,8 +230,6 @@ static ssize_t bonding_store_slaves(struct device *d,
 			   bond->dev->name);
 	}
 
-	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */
-
 	if (!rtnl_trylock())
 		return restart_syscall();
 
@@ -241,19 +239,17 @@ static ssize_t bonding_store_slaves(struct device *d,
 	    !dev_valid_name(ifname))
 		goto err_no_cmd;
 
-	if (command[0] == '+') {
-
-		/* Got a slave name in ifname. */
-
-		dev = __dev_get_by_name(dev_net(bond->dev), ifname);
-		if (!dev) {
-			pr_info("%s: Interface %s does not exist!\n",
-				bond->dev->name, ifname);
-			ret = -ENODEV;
-			goto out;
-		}
+	dev = __dev_get_by_name(dev_net(bond->dev), ifname);
+	if (!dev) {
+		pr_info("%s: Interface %s does not exist!\n",
+			bond->dev->name, ifname);
+		ret = -ENODEV;
+		goto out;
+	}
 
-		pr_info("%s: Adding slave %s.\n", bond->dev->name, ifname);
+	switch (command[0]) {
+	case '+':
+		pr_info("%s: Adding slave %s.\n", bond->dev->name, dev->name);
 
 		/* If this is the first slave, then we need to set
 		   the master's hardware address to be the same as the
@@ -263,33 +259,21 @@ static ssize_t bonding_store_slaves(struct device *d,
 			       dev->addr_len);
 
 		res = bond_enslave(bond->dev, dev);
-		if (res)
-			ret = res;
+		break;
 
-		goto out;
-	}
+	case '-':
+		pr_info("%s: Removing slave %s.\n", bond->dev->name, dev->name);
+		res = bond_release(bond->dev, dev);
+		break;
 
-	if (command[0] == '-') {
-		dev = NULL;
-		bond_for_each_slave(bond, slave, i)
-			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
-				dev = slave->dev;
-				break;
-			}
-		if (dev) {
-			pr_info("%s: Removing slave %s\n",
-				bond->dev->name, dev->name);
-			res = bond_release(bond->dev, dev);
-			if (res)
-				ret = res;
-		} else {
-			pr_err("unable to remove non-existent slave %s for bond %s.\n",
-			       ifname, bond->dev->name);
-			ret = -ENODEV;
-		}
-		goto out;
+	default:
+		goto err_no_cmd;
 	}
 
+	if (res)
+		ret = res;
+	goto out;
+
 err_no_cmd:
 	pr_err("no command found in slaves file for bond %s. Use +ifname or -ifname.\n",
 	       bond->dev->name);
-- 
1.6.6.1

