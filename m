From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] change /proc/bond0/info to /proc/bonding/bond0
Date: Fri, 22 Aug 2003 13:03:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030822130317.06d130d9.shemminger@osdl.org>
References: <20030821165258.45f1ec53.shemminger@osdl.org>
	<Mutt.LNX.4.44.0308221016320.993-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chad Tindel <ctindel@users.sourceforge.net>,
   Jay Vosburgh <fubar@us.ibm.com>, "David S. Miller" <davem@redhat.com>,
   Jeff Garzik <jgarzik@pobox.com>, <bonding-devel@lists.sourceforge.net>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0308221016320.993-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Aug 2003 10:17:07 +1000 (EST)
James Morris <jmorris@intercode.com.au> wrote:

> On Thu, 21 Aug 2003, Stephen Hemminger wrote:
> 
> > The name "/proc/net/bond0/info" is kind of unconventional, but now
> > changing that in a almost stable release would be bad.  Better choice
> > would be "/proc/net/bonding/bond0".
> 
> I'm not sure it's too late to do this.

Changes the name of the /proc entry on 2.6.0-test3 with my earlier
patch.  Also, documentation and comments are updated.

This version will work if the /proc creation fails; a warning is printed
but see no reason to prevent module from loading.

diff -Nru a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
--- a/Documentation/networking/bonding.txt	Fri Aug 22 13:00:24 2003
+++ b/Documentation/networking/bonding.txt	Fri Aug 22 13:00:24 2003
@@ -529,7 +529,7 @@
 ----------------------------
 The bonding driver information files reside in the /proc/net/bond* directories.
 
-Sample contents of /proc/net/bond0/info after the driver is loaded with 
+Sample contents of /proc/net/bonding/bond0 after the driver is loaded with 
 parameters of mode=0 and miimon=1000 is shown below.
  
         Bonding Mode: load balancing (round-robin)
diff -Nru a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Fri Aug 22 13:00:24 2003
+++ b/drivers/net/bonding/bond_main.c	Fri Aug 22 13:00:24 2003
@@ -119,7 +119,7 @@
  *
  * 2001/6/01 - Chad N. Tindel <ctindel at ieee dot org>
  *     - Added /proc support for getting bond and slave information.
- *       Information is in /proc/net/<bond device>/info. 
+ *       Information is in /proc/net/bonding/<bond device>
  *     - Changed the locking when calling bond_close to prevent deadlock.
  *
  * 2001/8/05 - Janice Girouard <girouard at us.ibm.com>
@@ -501,6 +501,7 @@
 };
 
 static LIST_HEAD(bond_dev_list);
+static struct proc_dir_entry *bond_proc_dir;
 
 MODULE_PARM(max_bonds, "i");
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -3607,27 +3608,21 @@
 	}
 
 #ifdef CONFIG_PROC_FS
-	bond->bond_proc_dir = proc_mkdir(dev->name, proc_net);
-	if (bond->bond_proc_dir == NULL) {
-		printk(KERN_ERR "%s: Cannot init /proc/net/%s/\n", 
-			dev->name, dev->name);
-		return -ENOMEM;
-	}
-	bond->bond_proc_dir->owner = THIS_MODULE;
-
-	bond->bond_proc_info_file = 
-		create_proc_entry("info", 0, bond->bond_proc_dir);
-	if (bond->bond_proc_info_file == NULL) {
-		printk(KERN_ERR "%s: Cannot init /proc/net/%s/info\n", 
-			dev->name, dev->name);
-		remove_proc_entry(dev->name, proc_net);
-		return -ENOMEM;
+	if (bond_proc_dir) {
+		bond->bond_proc_file = create_proc_entry(dev->name,
+							 S_IRUGO, 
+							 bond_proc_dir);
+		if (bond->bond_proc_file == NULL) {
+			printk(KERN_WARNING "%s: Cannot create "
+			       "/proc/net/bonding/%s\n", 
+			       dev->name, dev->name);
+		} else {
+			bond->bond_proc_file->data = bond;
+			bond->bond_proc_file->proc_fops = &bond_info_fops;
+		}
 	}
-	bond->bond_proc_info_file->data = bond;
-	bond->bond_proc_info_file->proc_fops = &bond_info_fops;
 #endif /* CONFIG_PROC_FS */
 
-
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 	return 0;
 }
@@ -3908,6 +3903,15 @@
 
 	register_netdevice_notifier(&bond_netdev_notifier);
 
+#ifdef CONFIG_PROC_FS
+	bond_proc_dir = proc_mkdir("bonding", proc_net);
+	if (bond_proc_dir == NULL) 
+		printk(KERN_WARNING "bonding_init(): can not create "
+		       "/proc/net/bonding");
+	else 
+		bond_proc_dir->owner = THIS_MODULE;
+#endif
+
 	for (no = 0; no < max_bonds; no++) {
 		struct net_device *dev;
 		char name[IFNAMSIZ];
@@ -3943,13 +3947,15 @@
 		 
 	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
 		struct net_device *dev = bond->device;
-#ifdef CONFIG_PROC_FS
-		remove_proc_entry("info", bond->bond_proc_dir);
-		remove_proc_entry(dev->name, proc_net);
-#endif
+
+		if (bond_proc_dir)
+			remove_proc_entry(dev->name, bond_proc_dir);
 		unregister_netdev(dev);
 		free_netdev(dev);
 	}
+
+	if (bond_proc_dir)
+		remove_proc_entry("bonding", proc_net);
 }
 
 module_init(bonding_init);
diff -Nru a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Fri Aug 22 13:00:24 2003
+++ b/drivers/net/bonding/bonding.h	Fri Aug 22 13:00:24 2003
@@ -101,8 +101,7 @@
 	struct timer_list arp_timer;
 	struct net_device_stats *stats;
 #ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *bond_proc_dir;
-	struct proc_dir_entry *bond_proc_info_file;
+	struct proc_dir_entry *bond_proc_file;
 #endif /* CONFIG_PROC_FS */
 	struct list_head bond_list;
 	struct net_device *device;
