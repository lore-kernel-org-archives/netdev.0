From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 10/18]: Clean up initialization code
Date: Sun, 20 Jan 2008 18:11:31 +0100 (MET)
Message-ID: <20080120171131.7980.64712.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62359 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489AbYATRLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:32 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Clean up initialization code

- move module init/exit functions to end of file, remove some now unnecessary
  forward declarations
- remove some obvious comments
- clean up proc init function and move a proc-related printk there

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9829059db87d43bb24e82683e6bb4ed4a655fc39
tree d4a062fb2a45e299eae6ac7aa1de6e3e05e9ad31
parent 8798cc926478d29231ad48d5e0ff31e434660ddb
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100

 net/8021q/vlan.c     |  141 +++++++++++++++++++++-----------------------------
 net/8021q/vlanproc.c |   21 ++++---
 2 files changed, 70 insertions(+), 92 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 69a9e02..006d9a9 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -50,16 +50,6 @@ static char vlan_version[] = DRV_VERSION;
 static char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
 static char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
-static int vlan_device_event(struct notifier_block *, unsigned long, void *);
-static int vlan_ioctl_handler(struct net *net, void __user *);
-static int unregister_vlan_dev(struct net_device *, unsigned short );
-
-static struct notifier_block vlan_notifier_block = {
-	.notifier_call = vlan_device_event,
-};
-
-/* These may be changed at run-time through IOCTLs */
-
 /* Determines interface naming scheme. */
 unsigned short vlan_name_type = VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD;
 
@@ -70,79 +60,6 @@ static struct packet_type vlan_packet_type = {
 
 /* End of global variables definitions. */
 
-/*
- * Function vlan_proto_init (pro)
- *
- *    Initialize VLAN protocol layer,
- *
- */
-static int __init vlan_proto_init(void)
-{
-	int err;
-
-	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
-	pr_info("All bugs added by %s\n", vlan_buggyright);
-
-	/* proc file system initialization */
-	err = vlan_proc_init();
-	if (err < 0) {
-		pr_err("%s: can't create entry in proc filesystem!\n",
-		       __FUNCTION__);
-		return err;
-	}
-
-	dev_add_pack(&vlan_packet_type);
-
-	/* Register us to receive netdevice events */
-	err = register_netdevice_notifier(&vlan_notifier_block);
-	if (err < 0)
-		goto err1;
-
-	err = vlan_netlink_init();
-	if (err < 0)
-		goto err2;
-
-	vlan_ioctl_set(vlan_ioctl_handler);
-	return 0;
-
-err2:
-	unregister_netdevice_notifier(&vlan_notifier_block);
-err1:
-	vlan_proc_cleanup();
-	dev_remove_pack(&vlan_packet_type);
-	return err;
-}
-
-/*
- *     Module 'remove' entry point.
- *     o delete /proc/net/router directory and static entries.
- */
-static void __exit vlan_cleanup_module(void)
-{
-	int i;
-
-	vlan_ioctl_set(NULL);
-	vlan_netlink_fini();
-
-	/* Un-register us from receiving netdevice events */
-	unregister_netdevice_notifier(&vlan_notifier_block);
-
-	dev_remove_pack(&vlan_packet_type);
-
-	/* This table must be empty if there are no module
-	 * references left.
-	 */
-	for (i = 0; i < VLAN_GRP_HASH_SIZE; i++) {
-		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
-	}
-	vlan_proc_cleanup();
-
-	synchronize_net();
-}
-
-module_init(vlan_proto_init);
-module_exit(vlan_cleanup_module);
-
 /* Must be invoked with RCU read lock (no preempt) */
 static struct vlan_group *__vlan_find_group(int real_dev_ifindex)
 {
@@ -592,6 +509,10 @@ out:
 	return NOTIFY_DONE;
 }
 
+static struct notifier_block vlan_notifier_block __read_mostly = {
+	.notifier_call = vlan_device_event,
+};
+
 /*
  *	VLAN IOCTL handler.
  *	o execute requested action or pass command to the device driver
@@ -716,5 +637,59 @@ out:
 	return err;
 }
 
+static int __init vlan_proto_init(void)
+{
+	int err;
+
+	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
+	pr_info("All bugs added by %s\n", vlan_buggyright);
+
+	err = vlan_proc_init();
+	if (err < 0)
+		goto err1;
+
+	err = register_netdevice_notifier(&vlan_notifier_block);
+	if (err < 0)
+		goto err2;
+
+	err = vlan_netlink_init();
+	if (err < 0)
+		goto err3;
+
+	dev_add_pack(&vlan_packet_type);
+	vlan_ioctl_set(vlan_ioctl_handler);
+	return 0;
+
+err3:
+	unregister_netdevice_notifier(&vlan_notifier_block);
+err2:
+	vlan_proc_cleanup();
+err1:
+	return err;
+}
+
+static void __exit vlan_cleanup_module(void)
+{
+	unsigned int i;
+
+	vlan_ioctl_set(NULL);
+	vlan_netlink_fini();
+
+	unregister_netdevice_notifier(&vlan_notifier_block);
+
+	dev_remove_pack(&vlan_packet_type);
+
+	/* This table must be empty if there are no module references left. */
+	for (i = 0; i < VLAN_GRP_HASH_SIZE; i++)
+		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
+
+	vlan_proc_cleanup();
+
+	synchronize_net();
+}
+
+module_init(vlan_proto_init);
+module_exit(vlan_cleanup_module);
+
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 5da02e2..971e623 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -158,15 +158,18 @@ void vlan_proc_cleanup(void)
 int __init vlan_proc_init(void)
 {
 	proc_vlan_dir = proc_mkdir(name_root, init_net.proc_net);
-	if (proc_vlan_dir) {
-		proc_vlan_conf = create_proc_entry(name_conf,
-						   S_IFREG|S_IRUSR|S_IWUSR,
-						   proc_vlan_dir);
-		if (proc_vlan_conf) {
-			proc_vlan_conf->proc_fops = &vlan_fops;
-			return 0;
-		}
-	}
+	if (!proc_vlan_dir)
+		goto err;
+
+	proc_vlan_conf = create_proc_entry(name_conf, S_IFREG|S_IRUSR|S_IWUSR,
+					   proc_vlan_dir);
+	if (!proc_vlan_conf)
+		goto err;
+	proc_vlan_conf->proc_fops = &vlan_fops;
+	return 0;
+
+err:
+	pr_err("%s: can't create entry in proc filesystem!\n", __FUNCTION__);
 	vlan_proc_cleanup();
 	return -ENOBUFS;
 }
