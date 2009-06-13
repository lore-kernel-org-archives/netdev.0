From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/9] bonding: network device names are case sensative
Date: Fri, 12 Jun 2009 22:02:50 -0700
Message-ID: <20090613050422.104536022@vyatta.com>
References: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49232 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751703AbZFMFGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:16 -0400
Content-Disposition: inline; filename=bond-casesensative.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding device acts unlike all other Linux network device functions
in that it ignores case of device names. The developer must have come
from windows!

Cleanup the management of names and use standard routines where possible.
Flag places where bonding device still doesn't work right with network
namespaces.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_main.c	2009-06-12 21:46:22.182394769 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-06-12 21:46:35.170615781 -0700
@@ -5064,19 +5064,16 @@ static void bond_set_lockdep_class(struc
 int bond_create(const char *name)
 {
 	struct net_device *bond_dev;
-	struct bonding *bond;
 	int res;
 
 	rtnl_lock();
 	/* Check to see if the bond already exists. */
-	if (name) {
-		list_for_each_entry(bond, &bond_dev_list, bond_list)
-			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
-				pr_err(DRV_NAME ": cannot add bond %s;"
-				       " it already exists\n", name);
-				res = -EPERM;
-				goto out_rtnl;
-			}
+	/* FIXME: pass netns from caller */
+	if (name && __dev_get_by_name(&init_net, name)) {
+		pr_err(DRV_NAME ": cannot add bond %s; already exists\n",
+		       name);
+		res = -EEXIST;
+		goto out_rtnl;
 	}
 
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
--- a/drivers/net/bonding/bond_sysfs.c	2009-06-12 21:46:34.113395362 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-12 21:46:35.171609407 -0700
@@ -68,6 +68,17 @@ static ssize_t bonding_show_bonds(struct
 	return res;
 }
 
+static struct net_device *bond_get_by_name(const char *ifname)
+{
+	struct bonding *bond;
+
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+		if (strncmp(bond->dev->name, ifname, IFNAMSIZ) == 0)
+			return bond->dev;
+	}
+	return NULL;
+}
+
 /*
  * "store" function for the bond_masters attribute.  This is what
  * creates and deletes entire bonds.
@@ -82,7 +93,6 @@ static ssize_t bonding_store_bonds(struc
 	char command[IFNAMSIZ + 1] = {0, };
 	char *ifname;
 	int rv, res = count;
-	struct bonding *bond;
 
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
 	ifname = command + 1;
@@ -98,41 +108,35 @@ static ssize_t bonding_store_bonds(struc
 			pr_info(DRV_NAME ": Bond creation failed.\n");
 			res = rv;
 		}
-		goto out;
-	}
+	} else if (command[0] == '-') {
+		struct net_device *bond_dev;
 
-	if (command[0] == '-') {
 		rtnl_lock();
+		bond_dev = bond_get_by_name(ifname);
+		if (bond_dev) {
+			pr_info(DRV_NAME ": %s is being deleted...\n",
+				ifname);
+			unregister_netdevice(bond_dev);
+		} else {
+			pr_err(DRV_NAME ": unable to delete non-existent %s\n",
+			       ifname);
+			res = -ENODEV;
+		}
+		rtnl_unlock();
+	} else
+		goto err_no_cmd;
 
-		list_for_each_entry(bond, &bond_dev_list, bond_list)
-			if (strnicmp(bond->dev->name, ifname, IFNAMSIZ) == 0) {
-				pr_info(DRV_NAME
-					": %s is being deleted...\n",
-					bond->dev->name);
-				unregister_netdevice(bond->dev);
-				goto out_unlock;
-			}
-
-		pr_err(DRV_NAME
-			": unable to delete non-existent bond %s\n", ifname);
-		res = -ENODEV;
-		goto out_unlock;
-	}
+	/* Always return either count or an error.  If you return 0, you'll
+	 * get called forever, which is bad.
+	 */
+	return res;
 
 err_no_cmd:
 	pr_err(DRV_NAME ": no command found in bonding_masters."
 	       " Use +ifname or -ifname.\n");
 	return -EPERM;
-
-out_unlock:
-	rtnl_unlock();
-
-	/* Always return either count or an error.  If you return 0, you'll
-	 * get called forever, which is bad.
-	 */
-out:
-	return res;
 }
+
 /* class attribute for bond_masters file.  This ends up in /sys/class/net */
 static CLASS_ATTR(bonding_masters,  S_IWUSR | S_IRUGO,
 		  bonding_show_bonds, bonding_store_bonds);
@@ -233,29 +237,16 @@ static ssize_t bonding_store_slaves(stru
 
 		/* Got a slave name in ifname.  Is it already in the list? */
 		found = 0;
-		read_lock(&bond->lock);
-		bond_for_each_slave(bond, slave, i)
-			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
-				pr_err(DRV_NAME
-				       ": %s: Interface %s is already enslaved!\n",
-				       bond->dev->name, ifname);
-				ret = -EPERM;
-				read_unlock(&bond->lock);
-				goto out;
-			}
 
-		read_unlock(&bond->lock);
-		pr_info(DRV_NAME ": %s: Adding slave %s.\n",
-		       bond->dev->name, ifname);
-		dev = dev_get_by_name(&init_net, ifname);
+		/* FIXME: get netns from sysfs object */
+		dev = __dev_get_by_name(&init_net, ifname);
 		if (!dev) {
 			pr_info(DRV_NAME
 			       ": %s: Interface %s does not exist!\n",
 			       bond->dev->name, ifname);
-			ret = -EPERM;
+			ret = -ENODEV;
 			goto out;
-		} else
-			dev_put(dev);
+		}
 
 		if (dev->flags & IFF_UP) {
 			pr_err(DRV_NAME
@@ -265,6 +256,22 @@ static ssize_t bonding_store_slaves(stru
 			ret = -EPERM;
 			goto out;
 		}
+
+		read_lock(&bond->lock);
+		bond_for_each_slave(bond, slave, i)
+			if (slave->dev == dev) {
+				pr_err(DRV_NAME
+				       ": %s: Interface %s is already enslaved!\n",
+				       bond->dev->name, ifname);
+				ret = -EPERM;
+				read_unlock(&bond->lock);
+				goto out;
+			}
+		read_unlock(&bond->lock);
+
+		pr_info(DRV_NAME ": %s: Adding slave %s.\n",
+			bond->dev->name, ifname);
+
 		/* If this is the first slave, then we need to set
 		   the master's hardware address to be the same as the
 		   slave's. */

-- 

