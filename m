From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 7/10] [bonding 2.6] Consolidate /proc code, add CHANGENAME handler
Date: Thu, 11 Sep 2003 17:41:49 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111741.49076.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:33 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:34 2003
@@ -3466,6 +3466,45 @@ static int bond_read_proc(char *buf, cha
 #endif /* CONFIG_PROC_FS */
 
 
+static int bond_create_proc_info(struct bonding *bond)
+{
+#ifdef CONFIG_PROC_FS
+	struct net_device *dev = bond->device;
+
+	bond->bond_proc_dir = proc_mkdir(dev->name, proc_net);
+	if (bond->bond_proc_dir == NULL) {
+		printk(KERN_ERR "%s: Cannot init /proc/net/%s/\n",
+			dev->name, dev->name);
+		return -ENOMEM;
+	}
+	bond->bond_proc_dir->owner = THIS_MODULE;
+
+	bond->bond_proc_info_file =
+		create_proc_read_entry("info", 0, bond->bond_proc_dir,
+					bond_read_proc, bond);
+	if (bond->bond_proc_info_file == NULL) {
+		printk(KERN_ERR "%s: Cannot init /proc/net/%s/info\n",
+			dev->name, dev->name);
+		remove_proc_entry(dev->name, proc_net);
+		return -ENOMEM;
+	}
+	bond->bond_proc_info_file->owner = THIS_MODULE;
+
+	memcpy(bond->procdir_name, dev->name, IFNAMSIZ);
+#endif /* CONFIG_PROC_FS */
+	return 0;
+}
+
+static void bond_destroy_proc_info(struct bonding *bond)
+{
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry("info", bond->bond_proc_dir);
+	remove_proc_entry(bond->procdir_name, proc_net);
+	memset(bond->procdir_name, 0, IFNAMSIZ);
+	bond->bond_proc_dir = NULL;
+#endif /* CONFIG_PROC_FS */
+}
+
 /*
  * Change HW address
  *
@@ -3614,10 +3653,7 @@ static void bond_deinit(struct net_devic
 
 	list_del(&bond->bond_list);
 
-#ifdef CONFIG_PROC_FS
-	remove_proc_entry("info", bond->bond_proc_dir);
-	remove_proc_entry(dev->name, proc_net);
-#endif
+	bond_destroy_proc_info(bond);
 }
 
 static void bond_free_all(void)
@@ -3633,10 +3669,15 @@ static void bond_free_all(void)
 	}
 }
 
+/*
+ * Does not allocate but creates a /proc entry.
+ * Allowed to fail.
+ */
 static int __init bond_init(struct net_device *dev)
 {
 	struct bonding *bond;
 	int count;
+	int err = 0;
 
 #ifdef BONDING_DEBUG
 	printk (KERN_INFO "Begin bond_init for %s\n", dev->name);
@@ -3715,30 +3756,26 @@ static int __init bond_init(struct net_d
 		printk("out ARP monitoring\n");
 	}
 
-#ifdef CONFIG_PROC_FS
-	bond->bond_proc_dir = proc_mkdir(dev->name, proc_net);
-	if (bond->bond_proc_dir == NULL) {
-		printk(KERN_ERR "%s: Cannot init /proc/net/%s/\n", 
-			dev->name, dev->name);
-		return -ENOMEM;
+	err = bond_create_proc_info(bond);
+	if (err) {
+		printk(KERN_ERR "%s: Failed to create proc entry\n",
+			dev->name);
+		return err;
 	}
-	bond->bond_proc_dir->owner = THIS_MODULE;
 
-	bond->bond_proc_info_file = 
-		create_proc_read_entry("info", 0, bond->bond_proc_dir,
-					bond_read_proc, bond);
-	if (bond->bond_proc_info_file == NULL) {
-		printk(KERN_ERR "%s: Cannot init /proc/net/%s/info\n", 
-			dev->name, dev->name);
-		remove_proc_entry(dev->name, proc_net);
-		return -ENOMEM;
-	}
-	bond->bond_proc_info_file->owner = THIS_MODULE;
-#endif /* CONFIG_PROC_FS */
+	/* Future:
+	 * If anything fails beyond this point
+	 * make sure to destroy the proc entry
+	 */
 
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
+/*
+err_out:
+	bond_destroy_proc_info(bond);
+	return err;
+*/
 }
 
 /*
diff -Nuarp a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Thu Sep 11 16:48:33 2003
+++ b/drivers/net/bonding/bonding.h	Thu Sep 11 16:48:34 2003
@@ -103,6 +103,7 @@ typedef struct bonding {
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *bond_proc_dir;
 	struct proc_dir_entry *bond_proc_info_file;
+	char procdir_name[IFNAMSIZ];
 #endif /* CONFIG_PROC_FS */
 	struct list_head bond_list;
 	struct net_device *device;
