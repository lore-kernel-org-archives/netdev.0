From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.72] use alloc_netdev in bonding driver
Date: Tue, 17 Jun 2003 11:35:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617113510.5ae6a5a9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chad Tindel <ctindel@users.sourceforge.net>,
   Jay Vosburgh
 <fubar@us.ibm.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch replaces the allocation of an array of bonding device structures with
allocating net_device's through alloc_netdev.  The net_device, statistics, and net_device
are created with one allocation via alloc_netdev.

The driver was keeping track of bond device's through both an array (bond_devs) and a
linked list (these_bonds).  It was much simpler just to have one list_head and put the
entries on as they are created.  Should be easy to get rid of the max_bonds parameter
and dynamically add devices as needed in the future.  The previous code for bond_event
was one of those places that did the right thing in the hardest way possible.

Added locking to the /proc interface because if device's are ever dynamically added that
will be needed, and there is a small race during initialization today.

Tested on 8-way with e1000 by enslave, moving data, unregistering the ether driver, 
and removing the bond driver.

diff -Nru a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Tue Jun 17 11:05:31 2003
+++ b/drivers/net/bonding/bond_main.c	Tue Jun 17 11:05:31 2003
@@ -497,9 +497,7 @@
 {	NULL,		-1},
 };
 
-static int first_pass	= 1;
-static struct bonding *these_bonds =  NULL;
-static struct net_device *dev_bonds = NULL;
+static LIST_HEAD(bond_dev_list);
 
 MODULE_PARM(max_bonds, "i");
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -3408,7 +3406,7 @@
 
 static int bond_get_info(char *buf, char **start, off_t offset, int length)
 {
-	bonding_t *bond = these_bonds;
+	bonding_t *bond;
 	int len = 0;
 	off_t begin = 0;
 	u16 link;
@@ -3416,7 +3414,8 @@
 
 	len += sprintf(buf + len, "%s\n", version);
 
-	while (bond != NULL) {
+	read_lock(&dev_base_lock);
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
 		/*
 		 * This function locks the mutex, so we can't lock it until 
 		 * afterwards
@@ -3526,93 +3525,48 @@
 			len = 0;
 		}
 
-
-		bond = bond->next_bond;
 	}
+	read_unlock(&dev_base_lock);
+
 	return len;
 }
 
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
+	if (event == NETDEV_UNREGISTER && master != NULL) 
+		bond_release(master, event_dev);
 
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
-	}
 	return NOTIFY_DONE;
 }
 
 static struct notifier_block bond_netdev_notifier = {
-	notifier_call: bond_event,
+	.notifier_call = bond_event,
 };
 
 static int __init bond_init(struct net_device *dev)
 {
-	bonding_t *bond, *this_bond, *last_bond;
+	bonding_t *bond;
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
 	rwlock_init(&bond->ptrlock);
 	
-	bond->stats = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
-	if (bond->stats == NULL) {
-		kfree(bond);
-		return -ENOMEM;
-	}
-	memset(bond->stats, 0, sizeof(struct net_device_stats));
-
+	/* space is reserved for stats in alloc_netdev call. */
+	bond->stats = (struct net_device_stats *)(bond + 1);
 	bond->next = bond->prev = (slave_t *)bond;
 	bond->current_slave = NULL;
 	bond->current_arp_slave = NULL;
 	bond->device = dev;
-	dev->priv = bond;
 
 	/* Initialize the device structure. */
 	switch (bond_mode) {
@@ -3637,8 +3591,6 @@
 		break;
 	default:
 		printk(KERN_ERR "Unknown bonding mode %d\n", bond_mode);
-		kfree(bond->stats);
-		kfree(bond);
 		return -EINVAL;
 	}
 
@@ -3648,13 +3600,6 @@
 	dev->set_multicast_list = set_multicast_list;
 	dev->do_ioctl = bond_ioctl;
 
-	/* 
-	 * Fill in the fields of the device structure with ethernet-generic 
-	 * values. 
-	 */
-
-	ether_setup(dev);
-
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_MASTER|IFF_MULTICAST;
 #ifdef CONFIG_NET_FASTROUTE
@@ -3687,8 +3632,6 @@
 	if (bond->bond_proc_dir == NULL) {
 		printk(KERN_ERR "%s: Cannot init /proc/net/%s/\n", 
 			dev->name, dev->name);
-		kfree(bond->stats);
-		kfree(bond);
 		return -ENOMEM;
 	}
 	bond->bond_proc_dir->owner = THIS_MODULE;
@@ -3700,27 +3643,13 @@
 		printk(KERN_ERR "%s: Cannot init /proc/net/%s/info\n", 
 			dev->name, dev->name);
 		remove_proc_entry(dev->name, proc_net);
-		kfree(bond->stats);
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
 
@@ -3753,15 +3682,11 @@
 	return -1;
 }
 
-
 static int __init bonding_init(void)
 {
 	int no;
 	int err;
 
-	/* Find a name for this unit */
-	static struct net_device *dev_bond = NULL;
-
 	printk(KERN_INFO "%s", version);
 
 	/*
@@ -3812,12 +3737,6 @@
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
@@ -4005,48 +3924,50 @@
 		primary = NULL;
 	}
 
+	register_netdevice_notifier(&bond_netdev_notifier);
 
 	for (no = 0; no < max_bonds; no++) {
-		dev_bond->init = bond_init;
-	
-		err = dev_alloc_name(dev_bond,"bond%d");
-		if (err < 0) {
-			kfree(dev_bonds);
+		struct net_device *dev;
+		char name[IFNAMSIZ];
+
+		snprintf(name, IFNAMSIZ, "bond%d", no);
+
+		dev = alloc_netdev(sizeof(bonding_t) 
+				   + sizeof(struct net_device_stats),
+				   name, ether_setup);
+		if (!dev)
+			return -ENOMEM;
+
+		dev->init = bond_init;
+		SET_MODULE_OWNER(dev);
+
+		if ( (err = register_netdev(dev)) ) {
+#ifdef BONDING_DEBUG
+			printk(KERN_INFO "%s: register_netdev failed %d\n",
+			       dev->name, err);
+#endif
+			kfree(dev);
 			return err;
-		}
-		SET_MODULE_OWNER(dev_bond);
-		if (register_netdev(dev_bond) != 0) {
-			kfree(dev_bonds);
-			return -EIO;
 		}	
-		dev_bond++;
 	}
 	return 0;
 }
 
 static void __exit bonding_exit(void)
 {
-	struct net_device *dev_bond = dev_bonds;
-	struct bonding *bond;
-	int no;
+	struct bonding *bond, *nxt;
 
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 		 
-	for (no = 0; no < max_bonds; no++) {
-
+	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+		struct net_device *dev = bond->device;
 #ifdef CONFIG_PROC_FS
-		bond = (struct bonding *) dev_bond->priv;
 		remove_proc_entry("info", bond->bond_proc_dir);
-		remove_proc_entry(dev_bond->name, proc_net);
+		remove_proc_entry(dev->name, proc_net);
 #endif
-		unregister_netdev(dev_bond);
-		kfree(bond->stats);
-		kfree(dev_bond->priv);
-		
-		dev_bond->priv = NULL;
-		dev_bond++;
+		unregister_netdev(dev);
+		kfree(dev);
 	}
-	kfree(dev_bonds);
 }
 
 module_init(bonding_init);
diff -Nru a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Tue Jun 17 11:05:31 2003
+++ b/drivers/net/bonding/bonding.h	Tue Jun 17 11:05:31 2003
@@ -104,7 +104,7 @@
 	struct proc_dir_entry *bond_proc_dir;
 	struct proc_dir_entry *bond_proc_info_file;
 #endif /* CONFIG_PROC_FS */
-	struct bonding *next_bond;
+	struct list_head bond_list;
 	struct net_device *device;
 	struct dev_mc_list *mc_list;
 	unsigned short flags;
