From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 5/5] [bonding] backport 2.6 changes to 2.4
Date: Wed, 30 Jul 2003 20:07:27 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307302007.27122.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Backported from 2.6:
Use a linked list to handle numerous bond devices instead of a static
array.

Also, fix handling of errors in bonding_init(): gracefully unregister
and deallocate all previously created bond devices.

Amir

diff -Nuarp linux-2.4.22-pre9/drivers/net/bonding/bond_main.c linux-2.4.22-pre9-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.22-pre9/drivers/net/bonding/bond_main.c	Wed Jul 30 19:14:10 2003
+++ linux-2.4.22-pre9-devel/drivers/net/bonding/bond_main.c	Wed Jul 30 19:14:11 2003
@@ -515,9 +515,7 @@ static struct bond_parm_tbl bond_lacp_tb
 {	NULL,		-1},
 };
 
-static int first_pass	= 1;
-static struct bonding *these_bonds =  NULL;
-static struct net_device *dev_bonds = NULL;
+static LIST_HEAD(bond_dev_list);
 
 MODULE_PARM(max_bonds, "i");
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -3495,47 +3493,13 @@ static int bond_read_proc(char *buf, cha
 static int bond_event(struct notifier_block *this, unsigned long event, 
 			void *ptr)
 {
-	struct bonding *this_bond = (struct bonding *)these_bonds;
-	struct bonding *last_bond;
 	struct net_device *event_dev = (struct net_device *)ptr;
+	struct net_device *master = event_dev->master;
 
-	/* while there are bonds configured */
-	while (this_bond != NULL) {
-		if (this_bond == event_dev->priv ) {
-			switch (event) {
-			case NETDEV_UNREGISTER:
-				/* 
-				 * remove this bond from a linked list of 
-				 * bonds 
-				 */
-				if (this_bond == these_bonds) {
-					these_bonds = this_bond->next_bond;
-				} else {
-					for (last_bond = these_bonds; 
-					     last_bond != NULL; 
-					     last_bond = last_bond->next_bond) {
-						if (last_bond->next_bond == 
-						    this_bond) {
-							last_bond->next_bond = 
-							this_bond->next_bond;
-						}
-					}
-				}
-				return NOTIFY_DONE;
-
-			default:
-				return NOTIFY_DONE;
-			}
-		} else if (this_bond->device == event_dev->master) {
-			switch (event) {
-			case NETDEV_UNREGISTER:
-				bond_release(this_bond->device, event_dev);
-				break;
-			}
-			return NOTIFY_DONE;
-		}
-		this_bond = this_bond->next_bond;
+	if ((event == NETDEV_UNREGISTER) && (master != NULL)) {
+		bond_release(master, event_dev);
 	}
+
 	return NOTIFY_DONE;
 }
 
@@ -3543,19 +3507,40 @@ static struct notifier_block bond_netdev
 	notifier_call: bond_event,
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
+		bond_deinit(dev);
+		unregister_netdev(dev);
+		kfree(dev);
+	}
+}
+
 static int __init bond_init(struct net_device *dev)
 {
-	bonding_t *bond, *this_bond, *last_bond;
+	struct bonding *bond;
 	int count;
 
 #ifdef BONDING_DEBUG
 	printk (KERN_INFO "Begin bond_init for %s\n", dev->name);
 #endif
-	bond = kmalloc(sizeof(struct bonding), GFP_KERNEL);
-	if (bond == NULL) {
-		return -ENOMEM;
-	}
-	memset(bond, 0, sizeof(struct bonding));
+	bond = dev->priv;
 
 	/* initialize rwlocks */
 	rwlock_init(&bond->lock);
@@ -3565,7 +3550,6 @@ static int __init bond_init(struct net_d
 	bond->current_slave = NULL;
 	bond->current_arp_slave = NULL;
 	bond->device = dev;
-	dev->priv = bond;
 
 	/* Initialize the device structure. */
 	switch (bond_mode) {
@@ -3590,7 +3574,6 @@ static int __init bond_init(struct net_d
 		break;
 	default:
 		printk(KERN_ERR "Unknown bonding mode %d\n", bond_mode);
-		kfree(bond);
 		return -EINVAL;
 	}
 
@@ -3599,14 +3582,6 @@ static int __init bond_init(struct net_d
 	dev->stop = bond_close;
 	dev->set_multicast_list = set_multicast_list;
 	dev->do_ioctl = bond_ioctl;
-
-	/* 
-	 * Fill in the fields of the device structure with ethernet-generic 
-	 * values. 
-	 */
-
-	ether_setup(dev);
-
 	dev->set_mac_address = bond_set_mac_address;
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_MASTER|IFF_MULTICAST;
@@ -3640,7 +3615,6 @@ static int __init bond_init(struct net_d
 	if (bond->bond_proc_dir == NULL) {
 		printk(KERN_ERR "%s: Cannot init /proc/net/%s/\n", 
 			dev->name, dev->name);
-		kfree(bond);
 		return -ENOMEM;
 	}
 	bond->bond_proc_dir->owner = THIS_MODULE;
@@ -3652,25 +3626,12 @@ static int __init bond_init(struct net_d
 		printk(KERN_ERR "%s: Cannot init /proc/net/%s/info\n", 
 			dev->name, dev->name);
 		remove_proc_entry(dev->name, proc_net);
-		kfree(bond);
 		return -ENOMEM;
 	}
 	bond->bond_proc_info_file->owner = THIS_MODULE;
 #endif /* CONFIG_PROC_FS */
 
-	if (first_pass == 1) {
-		these_bonds = bond;
-		register_netdevice_notifier(&bond_netdev_notifier);
-		first_pass = 0;
-	} else {
-		last_bond = these_bonds;
-		this_bond = these_bonds->next_bond;
-		while (this_bond != NULL) {
-			last_bond = this_bond;
-			this_bond = this_bond->next_bond;
-		}
-		last_bond->next_bond = bond;
-	} 
+	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
 }
@@ -3710,9 +3671,6 @@ static int __init bonding_init(void)
 	int no;
 	int err;
 
-	/* Find a name for this unit */
-	static struct net_device *dev_bond = NULL;
-
 	printk(KERN_INFO "%s", version);
 
 	/*
@@ -3763,12 +3721,6 @@ static int __init bonding_init(void)
 		       max_bonds, 1, INT_MAX, BOND_DEFAULT_MAX_BONDS);
 		max_bonds = BOND_DEFAULT_MAX_BONDS;
 	}
-	dev_bond = dev_bonds = kmalloc(max_bonds*sizeof(struct net_device), 
-					GFP_KERNEL);
-	if (dev_bond == NULL) {
-		return -ENOMEM;
-	}
-	memset(dev_bonds, 0, max_bonds*sizeof(struct net_device));
 
 	if (miimon < 0) {
 		printk(KERN_WARNING 
@@ -3959,47 +3911,62 @@ static int __init bonding_init(void)
 		primary = NULL;
 	}
 
+	rtnl_lock();
 
+	err = 0;
 	for (no = 0; no < max_bonds; no++) {
-		dev_bond->init = bond_init;
-	
-		err = dev_alloc_name(dev_bond,"bond%d");
+		struct net_device *dev;
+
+		dev = alloc_netdev(sizeof(struct bonding), "", ether_setup);
+		if (!dev) {
+			err = -ENOMEM;
+			goto out_err;
+		}
+
+		err = dev_alloc_name(dev, "bond%d");
+		if (err < 0) {
+			kfree(dev);
+			goto out_err;
+		}
+
+		/* bond_init() must be called after alloc_net_dev() (for the
+		 * /proc files), but before register_netdevice(), because we
+		 * need to set function pointers.
+		 */
+		err = bond_init(dev);
+		if (err < 0) {
+			kfree(dev);
+			goto out_err;
+		}
+
+		SET_MODULE_OWNER(dev);
+
+		err = register_netdevice(dev);
 		if (err < 0) {
-			kfree(dev_bonds);
-			return err;
+			bond_deinit(dev);
+			kfree(dev);
+			goto out_err;
 		}
-		SET_MODULE_OWNER(dev_bond);
-		if (register_netdev(dev_bond) != 0) {
-			kfree(dev_bonds);
-			return -EIO;
-		}	
-		dev_bond++;
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
-	struct net_device *dev_bond = dev_bonds;
-	struct bonding *bond;
-	int no;
-
 	unregister_netdevice_notifier(&bond_netdev_notifier);
-		 
-	for (no = 0; no < max_bonds; no++) {
-
-#ifdef CONFIG_PROC_FS
-		bond = (struct bonding *) dev_bond->priv;
-		remove_proc_entry("info", bond->bond_proc_dir);
-		remove_proc_entry(dev_bond->name, proc_net);
-#endif
-		unregister_netdev(dev_bond);
-		kfree(dev_bond->priv);
-
-		dev_bond->priv = NULL;
-		dev_bond++;
-	}
-	kfree(dev_bonds);
+	bond_free_all();
 }
 
 module_init(bonding_init);
diff -Nuarp linux-2.4.22-pre9/drivers/net/bonding/bonding.h linux-2.4.22-pre9-devel/drivers/net/bonding/bonding.h
--- linux-2.4.22-pre9/drivers/net/bonding/bonding.h	Wed Jul 30 19:14:10 2003
+++ linux-2.4.22-pre9-devel/drivers/net/bonding/bonding.h	Wed Jul 30 19:14:11 2003
@@ -104,7 +104,7 @@ typedef struct bonding {
 	struct proc_dir_entry *bond_proc_dir;
 	struct proc_dir_entry *bond_proc_info_file;
 #endif /* CONFIG_PROC_FS */
-	struct bonding *next_bond;
+	struct list_head bond_list;
 	struct net_device *device;
 	struct dev_mc_list *mc_list;
 	unsigned short flags;
