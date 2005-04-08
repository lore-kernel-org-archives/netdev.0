From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 2/17] bonding: split bond creation into new function
Date: Fri, 8 Apr 2005 16:23:29 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081621030.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch moves the work of creating a new bond into a separate function,
instead of being inline in bonding_init. This function is non-static and
proto is added to the header, for use by the sysfs interface.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h linux-2.6.12-rc2/drivers/net/bonding/bonding.h
--- linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bonding.h	2005-04-07 14:05:31.000000000 -0700
@@ -247,6 +247,7 @@

  struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
  int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
+int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
  void bond_deinit(struct net_device *bond_dev);
  int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
  int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_main.c	2005-04-07 14:35:41.000000000 -0700
@@ -539,6 +539,7 @@
  static char *lacp_rate	= NULL;
  static int arp_interval = BOND_LINK_ARP_INTERV;
  static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
+struct bond_params bonding_defaults;

  module_param(max_bonds, int, 0);
  MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -4243,12 +4244,10 @@
   * Does not allocate but creates a /proc entry.
   * Allowed to fail.
   */
-static int __init bond_init(struct net_device *bond_dev, struct bond_params *params)
+static int bond_init(struct net_device *bond_dev, struct bond_params *params)
  {
-	struct bonding *bond = bond_dev->priv;
-
-	dprintk("Begin bond_init for %s\n", bond_dev->name);
-
+	struct bonding *bond;
+        bond = bond_dev->priv;
  	/* initialize rwlocks */
  	rwlock_init(&bond->lock);
  	rwlock_init(&bond->curr_slave_lock);
@@ -4612,20 +4723,70 @@
  	return 0;
  }

+/* Create a new bond based on the specified name and bonding parameters.
+ * Caller must NOT hold rtnl_lock; we need to release it here before we
+ * set up our sysfs entries.
+ */
+int bond_create(char *name, struct bond_params *params, struct bonding **newbond)
+{
+	struct net_device *bond_dev;
+	int res;
+
+	rtnl_lock();
+	bond_dev = alloc_netdev(sizeof(struct bonding), name, ether_setup);
+	if (!bond_dev) {
+		printk(KERN_ERR DRV_NAME 
+		       ": %s: eek! can't alloc netdev!\n",
+		       name);
+		res = -ENOMEM;
+		goto out_rtnl;
+	}
+
+	/* bond_init() must be called after dev_alloc_name() (for the
+	 * /proc files), but before register_netdevice(), because we
+	 * need to set function pointers.
+	 */
+ 
+	res = bond_init(bond_dev, params);
+	if (res < 0) {
+		goto out_netdev;
+	}
+
+	SET_MODULE_OWNER(bond_dev);
+
+	res = register_netdevice(bond_dev);
+	if (res < 0) {
+		goto out_bond;
+	}
+	if (newbond) 
+		*newbond = bond_dev->priv;
+
+	rtnl_unlock(); /* allows sysfs registration of net device */
+	res = bond_create_sysfs_entry(bond_dev->priv);
+	goto done;
+out_bond:
+	bond_deinit(bond_dev);
+out_netdev:
+	free_netdev(bond_dev);
+out_rtnl:
+	rtnl_unlock();
+done:
+	return res;
+}
+
  static int __init bonding_init(void)
  {
-	struct bond_params params;
  	int i;
  	int res;
+	char new_bond_name[8];  /* Enough room for 999 bonds at init. */

  	printk(KERN_INFO "%s", version);

-	res = bond_check_params(&params);
+	res = bond_check_params(&bonding_defaults);
  	if (res) {
-		return res;
+		goto out;
  	}

-	rtnl_lock();

  #ifdef CONFIG_PROC_FS
  	bond_create_proc_dir();
@@ -4632,41 +4723,12 @@
  #endif

  	for (i = 0; i < max_bonds; i++) {
-		struct net_device *bond_dev;
-
-		bond_dev = alloc_netdev(sizeof(struct bonding), "", ether_setup);
-		if (!bond_dev) {
-			res = -ENOMEM;
-			goto out_err;
-		}
-
-		res = dev_alloc_name(bond_dev, "bond%d");
-		if (res < 0) {
-			free_netdev(bond_dev);
-			goto out_err;
-		}
-
-		/* bond_init() must be called after dev_alloc_name() (for the
-		 * /proc files), but before register_netdevice(), because we
-		 * need to set function pointers.
-		 */
-		res = bond_init(bond_dev, &params);
-		if (res < 0) {
-			free_netdev(bond_dev);
-			goto out_err;
-		}
-
-		SET_MODULE_OWNER(bond_dev);
-
-		res = register_netdevice(bond_dev);
-		if (res < 0) {
-			bond_deinit(bond_dev);
-			free_netdev(bond_dev);
-			goto out_err;
-		}
+		sprintf(new_bond_name, "bond%d",i);
+		res = bond_create(new_bond_name,&bonding_defaults, NULL);
+		if (res)
+			goto err;
  	}

-	rtnl_unlock();
  	register_netdevice_notifier(&bond_netdev_notifier);

  	return 0;
