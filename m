From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 2/2] [bonding 2.6] fix creation of /proc/net/bonding dir
Date: Thu, 20 Nov 2003 19:56:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311201956.35783.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix the creation of the /proc/net/bonding dir.
Patch is against 2.6.

Amir


diff -Naurp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Sun Nov  2 15:06:08 2003
+++ b/drivers/net/bonding/bond_main.c	Sun Nov  2 15:06:18 2003
@@ -3573,6 +3573,62 @@ static void bond_destroy_proc_info(struc
 		bond->bond_proc_file = NULL;
 	}
 }
+
+/* Create the bonding directory under /proc/net, if doesn't exist yet.
+ * Caller must hold rtnl_lock.
+ */
+static void bond_create_proc_dir(void)
+{
+	int len = strlen(DRV_NAME);
+
+	for (bond_proc_dir = proc_net->subdir; bond_proc_dir;
+	     bond_proc_dir = bond_proc_dir->next) {
+		if ((bond_proc_dir->namelen == len) &&
+		    !memcmp(bond_proc_dir->name, DRV_NAME, len)) {
+			break;
+		}
+	}
+
+	if (!bond_proc_dir) {
+		bond_proc_dir = proc_mkdir(DRV_NAME, proc_net);
+		if (bond_proc_dir) {
+			bond_proc_dir->owner = THIS_MODULE;
+		} else {
+			printk(KERN_WARNING DRV_NAME
+				": Warning: cannot create /proc/net/%s\n",
+				DRV_NAME);
+		}
+	}
+}
+
+/* Destroy the bonding directory under /proc/net, if empty.
+ * Caller must hold rtnl_lock.
+ */
+static void bond_destroy_proc_dir(void)
+{
+	struct proc_dir_entry *de;
+
+	if (!bond_proc_dir) {
+		return;
+	}
+
+	/* verify that the /proc dir is empty */
+	for (de = bond_proc_dir->subdir; de; de = de->next) {
+		/* ignore . and .. */
+		if (*(de->name) != '.') {
+			break;
+		}
+	}
+
+	if (de) {
+		if (bond_proc_dir->owner == THIS_MODULE) {
+			bond_proc_dir->owner = NULL;
+		}
+	} else {
+		remove_proc_entry(DRV_NAME, proc_net);
+		bond_proc_dir = NULL;
+	}
+}
 #endif /* CONFIG_PROC_FS */
 
 /*
@@ -3828,6 +3884,9 @@ static struct notifier_block bond_netdev
 	.notifier_call = bond_netdev_event,
 };
 
+/* De-initialize device specific data.
+ * Caller must hold rtnl_lock.
+ */
 static inline void bond_deinit(struct net_device *dev)
 {
 	struct bonding *bond = dev->priv;
@@ -3839,6 +3898,9 @@ static inline void bond_deinit(struct ne
 #endif
 }
 
+/* Unregister and free all bond devices.
+ * Caller must hold rtnl_lock.
+ */
 static void bond_free_all(void)
 {
 	struct bonding *bond, *nxt;
@@ -3846,16 +3908,13 @@ static void bond_free_all(void)
 	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
 		struct net_device *dev = bond->device;
 
-		unregister_netdev(dev);
+		unregister_netdevice(dev);
 		bond_deinit(dev);
 		free_netdev(dev);
 	}
 
 #ifdef CONFIG_PROC_FS
-	if (bond_proc_dir) {
-		remove_proc_entry(DRV_NAME, proc_net);
-		bond_proc_dir = NULL;
-	}
+	bond_destroy_proc_dir();
 #endif
 }
 
@@ -4233,18 +4292,12 @@ static int __init bonding_init(void)
 		primary = NULL;
 	}
 
+	rtnl_lock();
+
 #ifdef CONFIG_PROC_FS
-	bond_proc_dir = proc_mkdir(DRV_NAME, proc_net);
-	if (bond_proc_dir == NULL)  {
-		printk(KERN_WARNING
-		       "bonding_init(): can not create /proc/net/" DRV_NAME);
-	} else {
-		bond_proc_dir->owner = THIS_MODULE;
-	}
+	bond_create_proc_dir();
 #endif
 
-	rtnl_lock();
-
 	err = 0;
 	for (no = 0; no < max_bonds; no++) {
 		struct net_device *dev;
@@ -4287,18 +4340,21 @@ static int __init bonding_init(void)
 	return 0;
 
 out_err:
-	rtnl_unlock();
-
 	/* free and unregister all bonds that were successfully added */
 	bond_free_all();
 
+	rtnl_unlock();
+
 	return err;
 }
 
 static void __exit bonding_exit(void)
 {
 	unregister_netdevice_notifier(&bond_netdev_notifier);
+
+	rtnl_lock();
 	bond_free_all();
+	rtnl_unlock();
 }
 
 module_init(bonding_init);
