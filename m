From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 8/10] [bonding 2.6] fix error handling in init code
Date: Thu, 4 Sep 2003 20:45:27 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042045.27041.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:10 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:11 2003
@@ -3470,8 +3470,9 @@ static int bond_event(struct notifier_bl
 	struct net_device *event_dev = (struct net_device *)ptr;
 	struct net_device *master = event_dev->master;
 
-	if (event == NETDEV_UNREGISTER && master != NULL) 
+	if ((event == NETDEV_UNREGISTER) && (master != NULL)) {
 		bond_release(master, event_dev);
+	}
 
 	return NOTIFY_DONE;
 }
@@ -3480,9 +3481,34 @@ static struct notifier_block bond_netdev
 	.notifier_call = bond_event,
 };
 
+static void bond_deinit(struct net_device *dev)
+{
+	struct bonding *bond = dev->priv;
+
+	list_del(&bond->bond_list);
+
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry("info", bond->bond_proc_dir);
+	remove_proc_entry(dev->name, proc_net);
+#endif
+}
+
+static void bond_free_all(void)
+{
+	struct bonding *bond, *nxt;
+
+	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+		struct net_device *dev = bond->device;
+
+		unregister_netdev(dev);
+		bond_deinit(dev);
+		kfree(dev);
+	}
+}
+
 static int __init bond_init(struct net_device *dev)
 {
-	bonding_t *bond;
+	struct bonding *bond;
 	int count;
 
 #ifdef BONDING_DEBUG
@@ -3613,6 +3639,7 @@ bond_parse_parm(char *mode_arg, struct b
 	return -1;
 }
 
+
 static int __init bonding_init(void)
 {
 	int no;
@@ -3858,49 +3885,62 @@ static int __init bonding_init(void)
 		primary = NULL;
 	}
 
-	register_netdevice_notifier(&bond_netdev_notifier);
+	rtnl_lock();
 
+	err = 0;
 	for (no = 0; no < max_bonds; no++) {
 		struct net_device *dev;
-		char name[IFNAMSIZ];
 
-		snprintf(name, IFNAMSIZ, "bond%d", no);
+		dev = alloc_netdev(sizeof(struct bonding), "", ether_setup);
+		if (!dev) {
+			err = -ENOMEM;
+			goto out_err;
+		}
 
-		dev = alloc_netdev(sizeof(struct bonding),
-				   name, ether_setup);
-		if (!dev)
-			return -ENOMEM;
+		err = dev_alloc_name(dev, "bond%d");
+		if (err < 0) {
+			kfree(dev);
+			goto out_err;
+		}
+
+		/* bond_init() must be called after dev_alloc_name() (for the
+		 * /proc files), but before register_netdevice(), because we
+		 * need to set function pointers.
+		 */
+		err = bond_init(dev);
+		if (err < 0) {
+			kfree(dev);
+			goto out_err;
+		}
 
-		dev->init = bond_init;
 		SET_MODULE_OWNER(dev);
 
-		if ( (err = register_netdev(dev)) ) {
-#ifdef BONDING_DEBUG
-			printk(KERN_INFO "%s: register_netdev failed %d\n",
-			       dev->name, err);
-#endif
+		err = register_netdevice(dev);
+		if (err < 0) {
+			bond_deinit(dev);
 			kfree(dev);
-			return err;
-		}	
+			goto out_err;
+		}
 	}
+
+	rtnl_unlock();
+	register_netdevice_notifier(&bond_netdev_notifier);
+
 	return 0;
+
+out_err:
+	rtnl_unlock();
+
+	/* free and unregister all bonds that were successfully added */
+	bond_free_all();
+
+	return err;
 }
 
 static void __exit bonding_exit(void)
 {
-	struct bonding *bond, *nxt;
-
 	unregister_netdevice_notifier(&bond_netdev_notifier);
-		 
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
-		struct net_device *dev = bond->device;
-#ifdef CONFIG_PROC_FS
-		remove_proc_entry("info", bond->bond_proc_dir);
-		remove_proc_entry(dev->name, proc_net);
-#endif
-		unregister_netdev(dev);
-		free_netdev(dev);
-	}
+	bond_free_all();
 }
 
 module_init(bonding_init);
