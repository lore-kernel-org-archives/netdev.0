From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: proc: revert proc_net_fops_create/proc_net_remove
 removal
Date: Fri, 8 Mar 2013 16:56:35 +0300
Message-ID: <20130308135635.GA1078@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:41084 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934104Ab3CHN4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 08:56:41 -0500
Received: by mail-ea0-f179.google.com with SMTP id f15so189120eak.10
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 05:56:39 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Revert the following patches:

	4fc1a601f147abe3bfb4d70fe718110ed21953e1 "net: proc: fix build failed when procfs is not configured"
	c2399059a389ba686fa7f45d8913a708914752c4 "net: proc: remove proc_net_remove"
	ece31ffd539e8e2b586b1ca5f50bc4f4591e3893 "net: proc: change proc_net_remove to remove_proc_entry"
	b4278c961aca320839964e23cfc7906ff61af0c2 "net: proc: remove proc_net_fops_create"
	d4beaa66add8aebf83ab16d2fde4e4de8dac36df "net: proc: change proc_net_fops_create to proc_create"

Their collective rationale is completely bogus:

	> some modules such as bonding use proc_create
	> to create proc entries under /proc/net/, and other modules
	> such as ipv4 use proc_net_fops_create.

	That's because conversion is not 100% complete.

	> proc_net_remove is only used to remove proc entries
	> that under /proc/net,

	This is coincidence.

	> it's not a general function for
	> removing proc entries of netns.

	Yes, it is.

	> if we want to remove
	> some proc entries which under /proc/net/stat/, we still
	> need to call remove_proc_entry.

	proc_net_remove() parses subdirectories just fine, i. e.
	"proc_net_remove(net, "stat/foo")" should work.
	Nobody bothered to do this.

proc_net_fops_create/proc_net_remove also hide implementation detail, namely,
->proc_net existense.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index f1b7e24..7b69591 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -276,7 +276,7 @@ static int cn_init(void)
 
 	cn_already_initialized = 1;
 
-	proc_create("connector", S_IRUGO, init_net.proc_net, &cn_file_ops);
+	proc_net_fops_create(&init_net, "connector", S_IRUGO, &cn_file_ops);
 
 	return 0;
 }
@@ -287,7 +287,7 @@ static void cn_fini(void)
 
 	cn_already_initialized = 0;
 
-	remove_proc_entry("connector", init_net.proc_net);
+	proc_net_remove(&init_net, "connector");
 
 	cn_queue_free_dev(dev->cbdev);
 	netlink_kernel_release(dev->nls);
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 02de6c8..c2e5497 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -586,8 +586,7 @@ static int bpq_device_event(struct notifier_block *this,unsigned long event, voi
 static int __init bpq_init_driver(void)
 {
 #ifdef CONFIG_PROC_FS
-	if (!proc_create("bpqether", S_IRUGO, init_net.proc_net,
-			 &bpq_info_fops)) {
+	if (!proc_net_fops_create(&init_net, "bpqether", S_IRUGO, &bpq_info_fops)) {
 		printk(KERN_ERR
 			"bpq: cannot create /proc/net/bpqether entry.\n");
 		return -ENOENT;
@@ -611,7 +610,7 @@ static void __exit bpq_cleanup_driver(void)
 
 	unregister_netdevice_notifier(&bpq_dev_notifier);
 
-	remove_proc_entry("bpqether", init_net.proc_net);
+	proc_net_remove(&init_net, "bpqether");
 
 	rtnl_lock();
 	while (!list_empty(&bpq_devices)) {
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index bc1d521..1b4a47b 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -2118,7 +2118,7 @@ static int __init scc_init_driver (void)
 	}
 	rtnl_unlock();
 
-	proc_create("z8530drv", 0, init_net.proc_net, &scc_net_seq_fops);
+	proc_net_fops_create(&init_net, "z8530drv", 0, &scc_net_seq_fops);
 
 	return 0;
 }
@@ -2173,7 +2173,7 @@ static void __exit scc_cleanup_driver(void)
 	if (Vector_Latch)
 		release_region(Vector_Latch, 1);
 
-	remove_proc_entry("z8530drv", init_net.proc_net);
+	proc_net_remove(&init_net, "z8530drv");
 }
 
 MODULE_AUTHOR("Joerg Reuter <jreuter@yaina.de>");
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 4cf8f10..c6645f1 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -1167,7 +1167,7 @@ static int __init yam_init_driver(void)
 	yam_timer.expires = jiffies + HZ / 100;
 	add_timer(&yam_timer);
 
-	proc_create("yam", S_IRUGO, init_net.proc_net, &yam_info_fops);
+	proc_net_fops_create(&init_net, "yam", S_IRUGO, &yam_info_fops);
 	return 0;
  error:
 	while (--i >= 0) {
@@ -1199,7 +1199,7 @@ static void __exit yam_cleanup_driver(void)
 		kfree(p);
 	}
 
-	remove_proc_entry("yam", init_net.proc_net);
+	proc_net_remove(&init_net, "yam");
 }
 
 /* --------------------------------------------------------------------- */
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index bb07ba9..20f31d0 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -1134,7 +1134,7 @@ static __net_init int pppoe_init_net(struct net *net)
 
 	rwlock_init(&pn->hash_lock);
 
-	pde = proc_create("pppoe", S_IRUGO, net->proc_net, &pppoe_seq_fops);
+	pde = proc_net_fops_create(net, "pppoe", S_IRUGO, &pppoe_seq_fops);
 #ifdef CONFIG_PROC_FS
 	if (!pde)
 		return -ENOMEM;
@@ -1145,7 +1145,7 @@ static __net_init int pppoe_init_net(struct net *net)
 
 static __net_exit void pppoe_exit_net(struct net *net)
 {
-	remove_proc_entry("pppoe", net->proc_net);
+	proc_net_remove(net, "pppoe");
 }
 
 static struct pernet_operations pppoe_net_ops = {
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index b4ac657..75df0d7 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -177,6 +177,20 @@ const struct file_operations proc_net_operations = {
 	.readdir	= proc_tgid_net_readdir,
 };
 
+
+struct proc_dir_entry *proc_net_fops_create(struct net *net,
+	const char *name, umode_t mode, const struct file_operations *fops)
+{
+	return proc_create(name, mode, net->proc_net, fops);
+}
+EXPORT_SYMBOL_GPL(proc_net_fops_create);
+
+void proc_net_remove(struct net *net, const char *name)
+{
+	remove_proc_entry(name, net->proc_net);
+}
+EXPORT_SYMBOL_GPL(proc_net_remove);
+
 static __net_init int proc_net_ns_init(struct net *net)
 {
 	struct proc_dir_entry *netd, *net_statd;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 8307f2f..3c22538 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -176,6 +176,9 @@ static inline struct proc_dir_entry *create_proc_read_entry(const char *name,
 	return res;
 }
  
+extern struct proc_dir_entry *proc_net_fops_create(struct net *net,
+	const char *name, umode_t mode, const struct file_operations *fops);
+extern void proc_net_remove(struct net *net, const char *name);
 extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 	struct proc_dir_entry *parent);
 
@@ -186,15 +189,21 @@ extern int proc_alloc_inum(unsigned int *pino);
 extern void proc_free_inum(unsigned int inum);
 #else
 
+#define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
+static inline void proc_net_remove(struct net *net, const char *name) {}
+
 static inline void proc_flush_task(struct task_struct *task)
 {
 }
 
 static inline struct proc_dir_entry *create_proc_entry(const char *name,
 	umode_t mode, struct proc_dir_entry *parent) { return NULL; }
-
-#define proc_create(name, mode, parent, fops)  ({ (void)(mode), NULL; })
-
+static inline struct proc_dir_entry *proc_create(const char *name,
+	umode_t mode, struct proc_dir_entry *parent,
+	const struct file_operations *proc_fops)
+{
+	return NULL;
+}
 static inline struct proc_dir_entry *proc_create_data(const char *name,
 	umode_t mode, struct proc_dir_entry *parent,
 	const struct file_operations *proc_fops, void *data)
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index dc526ec..4de77ea 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -131,7 +131,7 @@ void vlan_proc_cleanup(struct net *net)
 		remove_proc_entry(name_conf, vn->proc_vlan_dir);
 
 	if (vn->proc_vlan_dir)
-		remove_proc_entry(name_root, net->proc_net);
+		proc_net_remove(net, name_root);
 
 	/* Dynamically added entries should be cleaned up as their vlan_device
 	 * is removed, so we should not have to take care of it here...
diff --git a/net/atm/proc.c b/net/atm/proc.c
index 6ac35ff..2518b5f 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -460,7 +460,7 @@ static void atm_proc_dirs_remove(void)
 		if (e->dirent)
 			remove_proc_entry(e->name, atm_proc_root);
 	}
-	remove_proc_entry("atm", init_net.proc_net);
+	proc_net_remove(&init_net, "atm");
 }
 
 int __init atm_proc_init(void)
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 7b11f8b..282c66a 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1987,10 +1987,9 @@ static int __init ax25_init(void)
 	dev_add_pack(&ax25_packet_type);
 	register_netdevice_notifier(&ax25_dev_notifier);
 
-	proc_create("ax25_route", S_IRUGO, init_net.proc_net,
-		    &ax25_route_fops);
-	proc_create("ax25", S_IRUGO, init_net.proc_net, &ax25_info_fops);
-	proc_create("ax25_calls", S_IRUGO, init_net.proc_net, &ax25_uid_fops);
+	proc_net_fops_create(&init_net, "ax25_route", S_IRUGO, &ax25_route_fops);
+	proc_net_fops_create(&init_net, "ax25", S_IRUGO, &ax25_info_fops);
+	proc_net_fops_create(&init_net, "ax25_calls", S_IRUGO, &ax25_uid_fops);
 out:
 	return rc;
 }
@@ -2004,9 +2003,9 @@ MODULE_ALIAS_NETPROTO(PF_AX25);
 
 static void __exit ax25_exit(void)
 {
-	remove_proc_entry("ax25_route", init_net.proc_net);
-	remove_proc_entry("ax25", init_net.proc_net);
-	remove_proc_entry("ax25_calls", init_net.proc_net);
+	proc_net_remove(&init_net, "ax25_route");
+	proc_net_remove(&init_net, "ax25");
+	proc_net_remove(&init_net, "ax25_calls");
 
 	unregister_netdevice_notifier(&ax25_dev_notifier);
 
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index d3ee69b..5355df6 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -641,7 +641,7 @@ int bt_procfs_init(struct module* module, struct net *net, const char *name,
 	sk_list->fops.llseek    = seq_lseek;
 	sk_list->fops.release   = seq_release_private;
 
-	pde = proc_create(name, 0, net->proc_net, &sk_list->fops);
+	pde = proc_net_fops_create(net, name, 0, &sk_list->fops);
 	if (!pde)
 		return -ENOMEM;
 
@@ -652,7 +652,7 @@ int bt_procfs_init(struct module* module, struct net *net, const char *name,
 
 void bt_procfs_cleanup(struct net *net, const char *name)
 {
-	remove_proc_entry(name, net->proc_net);
+	proc_net_remove(net, name);
 }
 #else
 int bt_procfs_init(struct module* module, struct net *net, const char *name,
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 5dcb200..28e12d1 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1633,7 +1633,7 @@ static void __exit bcm_module_exit(void)
 	can_proto_unregister(&bcm_can_proto);
 
 	if (proc_dir)
-		remove_proc_entry("can-bcm", init_net.proc_net);
+		proc_net_remove(&init_net, "can-bcm");
 }
 
 module_init(bcm_module_init);
diff --git a/net/can/proc.c b/net/can/proc.c
index 1ab8c88..e21e133 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -530,5 +530,5 @@ void can_remove_proc(void)
 		can_remove_proc_readentry(CAN_PROC_RCVLIST_SFF);
 
 	if (can_dir)
-		remove_proc_entry("can", init_net.proc_net);
+		proc_net_remove(&init_net, "can");
 }
diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 3174f19..3a16bfe 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -304,12 +304,11 @@ static int __net_init dev_proc_net_init(struct net *net)
 {
 	int rc = -ENOMEM;
 
-	if (!proc_create("dev", S_IRUGO, net->proc_net, &dev_seq_fops))
+	if (!proc_net_fops_create(net, "dev", S_IRUGO, &dev_seq_fops))
 		goto out;
-	if (!proc_create("softnet_stat", S_IRUGO, net->proc_net,
-			 &softnet_seq_fops))
+	if (!proc_net_fops_create(net, "softnet_stat", S_IRUGO, &softnet_seq_fops))
 		goto out_dev;
-	if (!proc_create("ptype", S_IRUGO, net->proc_net, &ptype_seq_fops))
+	if (!proc_net_fops_create(net, "ptype", S_IRUGO, &ptype_seq_fops))
 		goto out_softnet;
 
 	if (wext_proc_init(net))
@@ -318,11 +317,11 @@ static int __net_init dev_proc_net_init(struct net *net)
 out:
 	return rc;
 out_ptype:
-	remove_proc_entry("ptype", net->proc_net);
+	proc_net_remove(net, "ptype");
 out_softnet:
-	remove_proc_entry("softnet_stat", net->proc_net);
+	proc_net_remove(net, "softnet_stat");
 out_dev:
-	remove_proc_entry("dev", net->proc_net);
+	proc_net_remove(net, "dev");
 	goto out;
 }
 
@@ -330,9 +329,9 @@ static void __net_exit dev_proc_net_exit(struct net *net)
 {
 	wext_proc_exit(net);
 
-	remove_proc_entry("ptype", net->proc_net);
-	remove_proc_entry("softnet_stat", net->proc_net);
-	remove_proc_entry("dev", net->proc_net);
+	proc_net_remove(net, "ptype");
+	proc_net_remove(net, "softnet_stat");
+	proc_net_remove(net, "dev");
 }
 
 static struct pernet_operations __net_initdata dev_proc_ops = {
@@ -387,14 +386,14 @@ static const struct file_operations dev_mc_seq_fops = {
 
 static int __net_init dev_mc_net_init(struct net *net)
 {
-	if (!proc_create("dev_mcast", 0, net->proc_net, &dev_mc_seq_fops))
+	if (!proc_net_fops_create(net, "dev_mcast", 0, &dev_mc_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
 
 static void __net_exit dev_mc_net_exit(struct net *net)
 {
-	remove_proc_entry("dev_mcast", net->proc_net);
+	proc_net_remove(net, "dev_mcast");
 }
 
 static struct pernet_operations __net_initdata dev_mc_net_ops = {
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6048fc1..2201e69 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3650,7 +3650,7 @@ static int __net_init pg_net_init(struct net *net)
 remove_entry:
 	remove_proc_entry(PGCTRL, pn->proc_dir);
 remove:
-	remove_proc_entry(PG_PROC_DIR, pn->net->proc_net);
+	proc_net_remove(pn->net, PG_PROC_DIR);
 	return ret;
 }
 
@@ -3676,7 +3676,7 @@ static void __net_exit pg_net_exit(struct net *net)
 	}
 
 	remove_proc_entry(PGCTRL, pn->proc_dir);
-	remove_proc_entry(PG_PROC_DIR, pn->net->proc_net);
+	proc_net_remove(pn->net, PG_PROC_DIR);
 }
 
 static struct pernet_operations pg_net_ops = {
diff --git a/net/core/sock.c b/net/core/sock.c
index b261a79..0c89410 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2838,7 +2838,7 @@ static const struct file_operations proto_seq_fops = {
 
 static __net_init int proto_init_net(struct net *net)
 {
-	if (!proc_create("protocols", S_IRUGO, net->proc_net, &proto_seq_fops))
+	if (!proc_net_fops_create(net, "protocols", S_IRUGO, &proto_seq_fops))
 		return -ENOMEM;
 
 	return 0;
@@ -2846,7 +2846,7 @@ static __net_init int proto_init_net(struct net *net)
 
 static __net_exit void proto_exit_net(struct net *net)
 {
-	remove_proc_entry("protocols", net->proc_net);
+	proc_net_remove(net, "protocols");
 }
 
 
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 4c6bdf9..0a8d6eb 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -171,7 +171,7 @@ static __init int dccpprobe_init(void)
 	spin_lock_init(&dccpw.lock);
 	if (kfifo_alloc(&dccpw.fifo, bufsize, GFP_KERNEL))
 		return ret;
-	if (!proc_create(procname, S_IRUSR, init_net.proc_net, &dccpprobe_fops))
+	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &dccpprobe_fops))
 		goto err0;
 
 	ret = setup_jprobe();
@@ -181,7 +181,7 @@ static __init int dccpprobe_init(void)
 	pr_info("DCCP watch registered (port=%d)\n", port);
 	return 0;
 err1:
-	remove_proc_entry(procname, init_net.proc_net);
+	proc_net_remove(&init_net, procname);
 err0:
 	kfifo_free(&dccpw.fifo);
 	return ret;
@@ -191,7 +191,7 @@ module_init(dccpprobe_init);
 static __exit void dccpprobe_exit(void)
 {
 	kfifo_free(&dccpw.fifo);
-	remove_proc_entry(procname, init_net.proc_net);
+	proc_net_remove(&init_net, procname);
 	unregister_jprobe(&dccp_send_probe);
 
 }
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index c21f200..ae06bd3 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2381,7 +2381,7 @@ static int __init decnet_init(void)
 	dev_add_pack(&dn_dix_packet_type);
 	register_netdevice_notifier(&dn_dev_notifier);
 
-	proc_create("decnet", S_IRUGO, init_net.proc_net, &dn_socket_seq_fops);
+	proc_net_fops_create(&init_net, "decnet", S_IRUGO, &dn_socket_seq_fops);
 	dn_register_sysctl();
 out:
 	return rc;
@@ -2410,7 +2410,7 @@ static void __exit decnet_exit(void)
 	dn_neigh_cleanup();
 	dn_fib_cleanup();
 
-	remove_proc_entry("decnet", init_net.proc_net);
+	proc_net_remove(&init_net, "decnet");
 
 	proto_unregister(&dn_proto);
 
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index c8da116..e47ba9f 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1412,7 +1412,7 @@ void __init dn_dev_init(void)
 	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL, NULL);
 	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr, NULL);
 
-	proc_create("decnet_dev", S_IRUGO, init_net.proc_net, &dn_dev_seq_fops);
+	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
 
 #ifdef CONFIG_SYSCTL
 	{
@@ -1433,7 +1433,7 @@ void __exit dn_dev_cleanup(void)
 	}
 #endif /* CONFIG_SYSCTL */
 
-	remove_proc_entry("decnet_dev", init_net.proc_net);
+	proc_net_remove(&init_net, "decnet_dev");
 
 	dn_dev_devices_off();
 }
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index f8637f9..856636a 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -590,12 +590,11 @@ static const struct file_operations dn_neigh_seq_fops = {
 void __init dn_neigh_init(void)
 {
 	neigh_table_init(&dn_neigh_table);
-	proc_create("decnet_neigh", S_IRUGO, init_net.proc_net,
-		    &dn_neigh_seq_fops);
+	proc_net_fops_create(&init_net, "decnet_neigh", S_IRUGO, &dn_neigh_seq_fops);
 }
 
 void __exit dn_neigh_cleanup(void)
 {
-	remove_proc_entry("decnet_neigh", init_net.proc_net);
+	proc_net_remove(&init_net, "decnet_neigh");
 	neigh_table_clear(&dn_neigh_table);
 }
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 5ac0e15..1550028 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1901,8 +1901,7 @@ void __init dn_route_init(void)
 
 	dn_dst_ops.gc_thresh = (dn_rt_hash_mask + 1);
 
-	proc_create("decnet_cache", S_IRUGO, init_net.proc_net,
-		    &dn_rt_cache_seq_fops);
+	proc_net_fops_create(&init_net, "decnet_cache", S_IRUGO, &dn_rt_cache_seq_fops);
 
 #ifdef CONFIG_DECNET_ROUTER
 	rtnl_register(PF_DECnet, RTM_GETROUTE, dn_cache_getroute,
@@ -1918,7 +1917,7 @@ void __exit dn_route_cleanup(void)
 	del_timer(&dn_route_timer);
 	dn_run_flush(0);
 
-	remove_proc_entry("decnet_cache", init_net.proc_net);
+	proc_net_remove(&init_net, "decnet_cache");
 	dst_entries_destroy(&dn_dst_ops);
 }
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index fea4929..ded146b 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1405,14 +1405,14 @@ static const struct file_operations arp_seq_fops = {
 
 static int __net_init arp_net_init(struct net *net)
 {
-	if (!proc_create("arp", S_IRUGO, net->proc_net, &arp_seq_fops))
+	if (!proc_net_fops_create(net, "arp", S_IRUGO, &arp_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
 
 static void __net_exit arp_net_exit(struct net *net)
 {
-	remove_proc_entry("arp", net->proc_net);
+	proc_net_remove(net, "arp");
 }
 
 static struct pernet_operations arp_net_ops = {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ff06b75..c13dc76 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2598,31 +2598,31 @@ static const struct file_operations fib_route_fops = {
 
 int __net_init fib_proc_init(struct net *net)
 {
-	if (!proc_create("fib_trie", S_IRUGO, net->proc_net, &fib_trie_fops))
+	if (!proc_net_fops_create(net, "fib_trie", S_IRUGO, &fib_trie_fops))
 		goto out1;
 
-	if (!proc_create("fib_triestat", S_IRUGO, net->proc_net,
-			 &fib_triestat_fops))
+	if (!proc_net_fops_create(net, "fib_triestat", S_IRUGO,
+				  &fib_triestat_fops))
 		goto out2;
 
-	if (!proc_create("route", S_IRUGO, net->proc_net, &fib_route_fops))
+	if (!proc_net_fops_create(net, "route", S_IRUGO, &fib_route_fops))
 		goto out3;
 
 	return 0;
 
 out3:
-	remove_proc_entry("fib_triestat", net->proc_net);
+	proc_net_remove(net, "fib_triestat");
 out2:
-	remove_proc_entry("fib_trie", net->proc_net);
+	proc_net_remove(net, "fib_trie");
 out1:
 	return -ENOMEM;
 }
 
 void __net_exit fib_proc_exit(struct net *net)
 {
-	remove_proc_entry("fib_trie", net->proc_net);
-	remove_proc_entry("fib_triestat", net->proc_net);
-	remove_proc_entry("route", net->proc_net);
+	proc_net_remove(net, "fib_trie");
+	proc_net_remove(net, "fib_triestat");
+	proc_net_remove(net, "route");
 }
 
 #endif /* CONFIG_PROC_FS */
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index d8c2327..736ab70 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2646,25 +2646,24 @@ static int __net_init igmp_net_init(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
-	pde = proc_create("igmp", S_IRUGO, net->proc_net, &igmp_mc_seq_fops);
+	pde = proc_net_fops_create(net, "igmp", S_IRUGO, &igmp_mc_seq_fops);
 	if (!pde)
 		goto out_igmp;
-	pde = proc_create("mcfilter", S_IRUGO, net->proc_net,
-			  &igmp_mcf_seq_fops);
+	pde = proc_net_fops_create(net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
 	if (!pde)
 		goto out_mcfilter;
 	return 0;
 
 out_mcfilter:
-	remove_proc_entry("igmp", net->proc_net);
+	proc_net_remove(net, "igmp");
 out_igmp:
 	return -ENOMEM;
 }
 
 static void __net_exit igmp_net_exit(struct net *net)
 {
-	remove_proc_entry("mcfilter", net->proc_net);
-	remove_proc_entry("igmp", net->proc_net);
+	proc_net_remove(net, "mcfilter");
+	proc_net_remove(net, "igmp");
 }
 
 static struct pernet_operations igmp_net_ops = {
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 98cbc68..a2e50ae 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1394,7 +1394,7 @@ static int __init ip_auto_config(void)
 	unsigned int i;
 
 #ifdef CONFIG_PROC_FS
-	proc_create("pnp", S_IRUGO, init_net.proc_net, &pnp_seq_fops);
+	proc_net_fops_create(&init_net, "pnp", S_IRUGO, &pnp_seq_fops);
 #endif /* CONFIG_PROC_FS */
 
 	if (!ic_enable)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5f95b3a..7085b9b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2703,16 +2703,16 @@ static int __net_init ipmr_net_init(struct net *net)
 
 #ifdef CONFIG_PROC_FS
 	err = -ENOMEM;
-	if (!proc_create("ip_mr_vif", 0, net->proc_net, &ipmr_vif_fops))
+	if (!proc_net_fops_create(net, "ip_mr_vif", 0, &ipmr_vif_fops))
 		goto proc_vif_fail;
-	if (!proc_create("ip_mr_cache", 0, net->proc_net, &ipmr_mfc_fops))
+	if (!proc_net_fops_create(net, "ip_mr_cache", 0, &ipmr_mfc_fops))
 		goto proc_cache_fail;
 #endif
 	return 0;
 
 #ifdef CONFIG_PROC_FS
 proc_cache_fail:
-	remove_proc_entry("ip_mr_vif", net->proc_net);
+	proc_net_remove(net, "ip_mr_vif");
 proc_vif_fail:
 	ipmr_rules_exit(net);
 #endif
@@ -2723,8 +2723,8 @@ fail:
 static void __net_exit ipmr_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	remove_proc_entry("ip_mr_cache", net->proc_net);
-	remove_proc_entry("ip_mr_vif", net->proc_net);
+	proc_net_remove(net, "ip_mr_cache");
+	proc_net_remove(net, "ip_mr_vif");
 #endif
 	ipmr_rules_exit(net);
 }
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index f2ca127..9682b36 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -417,12 +417,12 @@ static int __net_init ip_conntrack_net_init(struct net *net)
 {
 	struct proc_dir_entry *proc, *proc_exp, *proc_stat;
 
-	proc = proc_create("ip_conntrack", 0440, net->proc_net, &ct_file_ops);
+	proc = proc_net_fops_create(net, "ip_conntrack", 0440, &ct_file_ops);
 	if (!proc)
 		goto err1;
 
-	proc_exp = proc_create("ip_conntrack_expect", 0440, net->proc_net,
-			       &ip_exp_file_ops);
+	proc_exp = proc_net_fops_create(net, "ip_conntrack_expect", 0440,
+					&ip_exp_file_ops);
 	if (!proc_exp)
 		goto err2;
 
@@ -433,9 +433,9 @@ static int __net_init ip_conntrack_net_init(struct net *net)
 	return 0;
 
 err3:
-	remove_proc_entry("ip_conntrack_expect", net->proc_net);
+	proc_net_remove(net, "ip_conntrack_expect");
 err2:
-	remove_proc_entry("ip_conntrack", net->proc_net);
+	proc_net_remove(net, "ip_conntrack");
 err1:
 	return -ENOMEM;
 }
@@ -443,8 +443,8 @@ err1:
 static void __net_exit ip_conntrack_net_exit(struct net *net)
 {
 	remove_proc_entry("ip_conntrack", net->proc_net_stat);
-	remove_proc_entry("ip_conntrack_expect", net->proc_net);
-	remove_proc_entry("ip_conntrack", net->proc_net);
+	proc_net_remove(net, "ip_conntrack_expect");
+	proc_net_remove(net, "ip_conntrack");
 }
 
 static struct pernet_operations ip_conntrack_net_ops = {
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 2e91006..dc454cc 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -889,7 +889,7 @@ static int ping_proc_register(struct net *net)
 	struct proc_dir_entry *p;
 	int rc = 0;
 
-	p = proc_create("icmp", S_IRUGO, net->proc_net, &ping_seq_fops);
+	p = proc_net_fops_create(net, "icmp", S_IRUGO, &ping_seq_fops);
 	if (!p)
 		rc = -ENOMEM;
 	return rc;
@@ -897,7 +897,7 @@ static int ping_proc_register(struct net *net)
 
 static void ping_proc_unregister(struct net *net)
 {
-	remove_proc_entry("icmp", net->proc_net);
+	proc_net_remove(net, "icmp");
 }
 
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 32030a2..8de53e1 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -471,29 +471,28 @@ static const struct file_operations netstat_seq_fops = {
 
 static __net_init int ip_proc_init_net(struct net *net)
 {
-	if (!proc_create("sockstat", S_IRUGO, net->proc_net,
-			 &sockstat_seq_fops))
+	if (!proc_net_fops_create(net, "sockstat", S_IRUGO, &sockstat_seq_fops))
 		goto out_sockstat;
-	if (!proc_create("netstat", S_IRUGO, net->proc_net, &netstat_seq_fops))
+	if (!proc_net_fops_create(net, "netstat", S_IRUGO, &netstat_seq_fops))
 		goto out_netstat;
-	if (!proc_create("snmp", S_IRUGO, net->proc_net, &snmp_seq_fops))
+	if (!proc_net_fops_create(net, "snmp", S_IRUGO, &snmp_seq_fops))
 		goto out_snmp;
 
 	return 0;
 
 out_snmp:
-	remove_proc_entry("netstat", net->proc_net);
+	proc_net_remove(net, "netstat");
 out_netstat:
-	remove_proc_entry("sockstat", net->proc_net);
+	proc_net_remove(net, "sockstat");
 out_sockstat:
 	return -ENOMEM;
 }
 
 static __net_exit void ip_proc_exit_net(struct net *net)
 {
-	remove_proc_entry("snmp", net->proc_net);
-	remove_proc_entry("netstat", net->proc_net);
-	remove_proc_entry("sockstat", net->proc_net);
+	proc_net_remove(net, "snmp");
+	proc_net_remove(net, "netstat");
+	proc_net_remove(net, "sockstat");
 }
 
 static __net_initdata struct pernet_operations ip_proc_ops = {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index dd44e0a..63a0aab 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -1046,7 +1046,7 @@ static const struct file_operations raw_seq_fops = {
 
 static __net_init int raw_init_net(struct net *net)
 {
-	if (!proc_create("raw", S_IRUGO, net->proc_net, &raw_seq_fops))
+	if (!proc_net_fops_create(net, "raw", S_IRUGO, &raw_seq_fops))
 		return -ENOMEM;
 
 	return 0;
@@ -1054,7 +1054,7 @@ static __net_init int raw_init_net(struct net *net)
 
 static __net_exit void raw_exit_net(struct net *net)
 {
-	remove_proc_entry("raw", net->proc_net);
+	proc_net_remove(net, "raw");
 }
 
 static __net_initdata struct pernet_operations raw_net_ops = {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6e28514..fce785c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -380,8 +380,8 @@ static int __net_init ip_rt_do_proc_init(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
-	pde = proc_create("rt_cache", S_IRUGO, net->proc_net,
-			  &rt_cache_seq_fops);
+	pde = proc_net_fops_create(net, "rt_cache", S_IRUGO,
+			&rt_cache_seq_fops);
 	if (!pde)
 		goto err1;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4a8ec45..c83a788 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2615,7 +2615,7 @@ EXPORT_SYMBOL(tcp_proc_register);
 
 void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 {
-	remove_proc_entry(afinfo->name, net->proc_net);
+	proc_net_remove(net, afinfo->name);
 }
 EXPORT_SYMBOL(tcp_proc_unregister);
 
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index d4943f6..4526fe6 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -234,7 +234,7 @@ static __init int tcpprobe_init(void)
 	if (!tcp_probe.log)
 		goto err0;
 
-	if (!proc_create(procname, S_IRUSR, init_net.proc_net, &tcpprobe_fops))
+	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &tcpprobe_fops))
 		goto err0;
 
 	ret = register_jprobe(&tcp_jprobe);
@@ -244,7 +244,7 @@ static __init int tcpprobe_init(void)
 	pr_info("probe registered (port=%d) bufsize=%u\n", port, bufsize);
 	return 0;
  err1:
-	remove_proc_entry(procname, init_net.proc_net);
+	proc_net_remove(&init_net, procname);
  err0:
 	kfree(tcp_probe.log);
 	return ret;
@@ -253,7 +253,7 @@ module_init(tcpprobe_init);
 
 static __exit void tcpprobe_exit(void)
 {
-	remove_proc_entry(procname, init_net.proc_net);
+	proc_net_remove(&init_net, procname);
 	unregister_jprobe(&tcp_jprobe);
 	kfree(tcp_probe.log);
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 265c42c..39a5e7a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2122,7 +2122,7 @@ EXPORT_SYMBOL(udp_proc_register);
 
 void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo)
 {
-	remove_proc_entry(afinfo->name, net->proc_net);
+	proc_net_remove(net, afinfo->name);
 }
 EXPORT_SYMBOL(udp_proc_unregister);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f2c7e61..30a1b21 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3319,14 +3319,14 @@ static const struct file_operations if6_fops = {
 
 static int __net_init if6_proc_net_init(struct net *net)
 {
-	if (!proc_create("if_inet6", S_IRUGO, net->proc_net, &if6_fops))
+	if (!proc_net_fops_create(net, "if_inet6", S_IRUGO, &if6_fops))
 		return -ENOMEM;
 	return 0;
 }
 
 static void __net_exit if6_proc_net_exit(struct net *net)
 {
-	remove_proc_entry("if_inet6", net->proc_net);
+       proc_net_remove(net, "if_inet6");
 }
 
 static struct pernet_operations if6_proc_net_ops = {
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 5a80f15..921b8b3 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -509,7 +509,7 @@ static const struct file_operations ac6_seq_fops = {
 
 int __net_init ac6_proc_init(struct net *net)
 {
-	if (!proc_create("anycast6", S_IRUGO, net->proc_net, &ac6_seq_fops))
+	if (!proc_net_fops_create(net, "anycast6", S_IRUGO, &ac6_seq_fops))
 		return -ENOMEM;
 
 	return 0;
@@ -517,7 +517,7 @@ int __net_init ac6_proc_init(struct net *net)
 
 void ac6_proc_exit(struct net *net)
 {
-	remove_proc_entry("anycast6", net->proc_net);
+	proc_net_remove(net, "anycast6");
 }
 #endif
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index b973ed3..a7da2f4 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -806,15 +806,15 @@ static const struct file_operations ip6fl_seq_fops = {
 
 static int __net_init ip6_flowlabel_proc_init(struct net *net)
 {
-	if (!proc_create("ip6_flowlabel", S_IRUGO, net->proc_net,
-			 &ip6fl_seq_fops))
+	if (!proc_net_fops_create(net, "ip6_flowlabel",
+				  S_IRUGO, &ip6fl_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
 
 static void __net_exit ip6_flowlabel_proc_fini(struct net *net)
 {
-	remove_proc_entry("ip6_flowlabel", net->proc_net);
+	proc_net_remove(net, "ip6_flowlabel");
 }
 #else
 static inline int ip6_flowlabel_proc_init(struct net *net)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 96bfb4e..351ce98 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1359,9 +1359,9 @@ static int __net_init ip6mr_net_init(struct net *net)
 
 #ifdef CONFIG_PROC_FS
 	err = -ENOMEM;
-	if (!proc_create("ip6_mr_vif", 0, net->proc_net, &ip6mr_vif_fops))
+	if (!proc_net_fops_create(net, "ip6_mr_vif", 0, &ip6mr_vif_fops))
 		goto proc_vif_fail;
-	if (!proc_create("ip6_mr_cache", 0, net->proc_net, &ip6mr_mfc_fops))
+	if (!proc_net_fops_create(net, "ip6_mr_cache", 0, &ip6mr_mfc_fops))
 		goto proc_cache_fail;
 #endif
 
@@ -1369,7 +1369,7 @@ static int __net_init ip6mr_net_init(struct net *net)
 
 #ifdef CONFIG_PROC_FS
 proc_cache_fail:
-	remove_proc_entry("ip6_mr_vif", net->proc_net);
+	proc_net_remove(net, "ip6_mr_vif");
 proc_vif_fail:
 	ip6mr_rules_exit(net);
 #endif
@@ -1380,8 +1380,8 @@ fail:
 static void __net_exit ip6mr_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	remove_proc_entry("ip6_mr_cache", net->proc_net);
-	remove_proc_entry("ip6_mr_vif", net->proc_net);
+	proc_net_remove(net, "ip6_mr_cache");
+	proc_net_remove(net, "ip6_mr_vif");
 #endif
 	ip6mr_rules_exit(net);
 }
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bfa6cc3..3a2849f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2599,10 +2599,10 @@ static int __net_init igmp6_proc_init(struct net *net)
 	int err;
 
 	err = -ENOMEM;
-	if (!proc_create("igmp6", S_IRUGO, net->proc_net, &igmp6_mc_seq_fops))
+	if (!proc_net_fops_create(net, "igmp6", S_IRUGO, &igmp6_mc_seq_fops))
 		goto out;
-	if (!proc_create("mcfilter6", S_IRUGO, net->proc_net,
-			 &igmp6_mcf_seq_fops))
+	if (!proc_net_fops_create(net, "mcfilter6", S_IRUGO,
+				  &igmp6_mcf_seq_fops))
 		goto out_proc_net_igmp6;
 
 	err = 0;
@@ -2610,14 +2610,14 @@ out:
 	return err;
 
 out_proc_net_igmp6:
-	remove_proc_entry("igmp6", net->proc_net);
+	proc_net_remove(net, "igmp6");
 	goto out;
 }
 
 static void __net_exit igmp6_proc_exit(struct net *net)
 {
-	remove_proc_entry("mcfilter6", net->proc_net);
-	remove_proc_entry("igmp6", net->proc_net);
+	proc_net_remove(net, "mcfilter6");
+	proc_net_remove(net, "igmp6");
 }
 #else
 static inline int igmp6_proc_init(struct net *net)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index bbbe53a..745a320 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -295,11 +295,11 @@ int snmp6_unregister_dev(struct inet6_dev *idev)
 
 static int __net_init ipv6_proc_init_net(struct net *net)
 {
-	if (!proc_create("sockstat6", S_IRUGO, net->proc_net,
-			 &sockstat6_seq_fops))
+	if (!proc_net_fops_create(net, "sockstat6", S_IRUGO,
+			&sockstat6_seq_fops))
 		return -ENOMEM;
 
-	if (!proc_create("snmp6", S_IRUGO, net->proc_net, &snmp6_seq_fops))
+	if (!proc_net_fops_create(net, "snmp6", S_IRUGO, &snmp6_seq_fops))
 		goto proc_snmp6_fail;
 
 	net->mib.proc_net_devsnmp6 = proc_mkdir("dev_snmp6", net->proc_net);
@@ -308,17 +308,17 @@ static int __net_init ipv6_proc_init_net(struct net *net)
 	return 0;
 
 proc_dev_snmp6_fail:
-	remove_proc_entry("snmp6", net->proc_net);
+	proc_net_remove(net, "snmp6");
 proc_snmp6_fail:
-	remove_proc_entry("sockstat6", net->proc_net);
+	proc_net_remove(net, "sockstat6");
 	return -ENOMEM;
 }
 
 static void __net_exit ipv6_proc_exit_net(struct net *net)
 {
-	remove_proc_entry("sockstat6", net->proc_net);
-	remove_proc_entry("dev_snmp6", net->proc_net);
-	remove_proc_entry("snmp6", net->proc_net);
+	proc_net_remove(net, "sockstat6");
+	proc_net_remove(net, "dev_snmp6");
+	proc_net_remove(net, "snmp6");
 }
 
 static struct pernet_operations ipv6_proc_ops = {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 330b5e7..9cbc011 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1291,7 +1291,7 @@ static const struct file_operations raw6_seq_fops = {
 
 static int __net_init raw6_init_net(struct net *net)
 {
-	if (!proc_create("raw6", S_IRUGO, net->proc_net, &raw6_seq_fops))
+	if (!proc_net_fops_create(net, "raw6", S_IRUGO, &raw6_seq_fops))
 		return -ENOMEM;
 
 	return 0;
@@ -1299,7 +1299,7 @@ static int __net_init raw6_init_net(struct net *net)
 
 static void __net_exit raw6_exit_net(struct net *net)
 {
-	remove_proc_entry("raw6", net->proc_net);
+	proc_net_remove(net, "raw6");
 }
 
 static struct pernet_operations raw6_net_ops = {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e5fe004..8c663e4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2994,8 +2994,8 @@ static void __net_exit ip6_route_net_exit(struct net *net)
 static int __net_init ip6_route_net_init_late(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	proc_create("ipv6_route", 0, net->proc_net, &ipv6_route_proc_fops);
-	proc_create("rt6_stats", S_IRUGO, net->proc_net, &rt6_stats_seq_fops);
+	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
+	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
 #endif
 	return 0;
 }
@@ -3003,8 +3003,8 @@ static int __net_init ip6_route_net_init_late(struct net *net)
 static void __net_exit ip6_route_net_exit_late(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	remove_proc_entry("ipv6_route", net->proc_net);
-	remove_proc_entry("rt6_stats", net->proc_net);
+	proc_net_remove(net, "ipv6_route");
+	proc_net_remove(net, "rt6_stats");
 #endif
 }
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 556fdaf..ace8212 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3739,7 +3739,7 @@ static int __net_init pfkey_init_proc(struct net *net)
 {
 	struct proc_dir_entry *e;
 
-	e = proc_create("pfkey", 0, net->proc_net, &pfkey_proc_ops);
+	e = proc_net_fops_create(net, "pfkey", 0, &pfkey_proc_ops);
 	if (e == NULL)
 		return -ENOMEM;
 
@@ -3748,7 +3748,7 @@ static int __net_init pfkey_init_proc(struct net *net)
 
 static void __net_exit pfkey_exit_proc(struct net *net)
 {
-	remove_proc_entry("pfkey", net->proc_net);
+	proc_net_remove(net, "pfkey");
 }
 #else
 static inline int pfkey_init_proc(struct net *net)
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 6a53371..044e9e1 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1784,8 +1784,7 @@ static __net_init int pppol2tp_init_net(struct net *net)
 	struct proc_dir_entry *pde;
 	int err = 0;
 
-	pde = proc_create("pppol2tp", S_IRUGO, net->proc_net,
-			  &pppol2tp_proc_fops);
+	pde = proc_net_fops_create(net, "pppol2tp", S_IRUGO, &pppol2tp_proc_fops);
 	if (!pde) {
 		err = -ENOMEM;
 		goto out;
@@ -1797,7 +1796,7 @@ out:
 
 static __net_exit void pppol2tp_exit_net(struct net *net)
 {
-	remove_proc_entry("pppol2tp", net->proc_net);
+	proc_net_remove(net, "pppol2tp");
 }
 
 static struct pernet_operations pppol2tp_net_ops = {
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 0b779d7..9713e6e 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -605,12 +605,12 @@ int __net_init ip_vs_app_net_init(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	INIT_LIST_HEAD(&ipvs->app_list);
-	proc_create("ip_vs_app", 0, net->proc_net, &ip_vs_app_fops);
+	proc_net_fops_create(net, "ip_vs_app", 0, &ip_vs_app_fops);
 	return 0;
 }
 
 void __net_exit ip_vs_app_net_cleanup(struct net *net)
 {
 	unregister_ip_vs_app(net, NULL /* all */);
-	remove_proc_entry("ip_vs_app", net->proc_net);
+	proc_net_remove(net, "ip_vs_app");
 }
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 704e514..b1d164e 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1283,8 +1283,8 @@ int __net_init ip_vs_conn_net_init(struct net *net)
 
 	atomic_set(&ipvs->conn_count, 0);
 
-	proc_create("ip_vs_conn", 0, net->proc_net, &ip_vs_conn_fops);
-	proc_create("ip_vs_conn_sync", 0, net->proc_net, &ip_vs_conn_sync_fops);
+	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
+	proc_net_fops_create(net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
 	return 0;
 }
 
@@ -1292,8 +1292,8 @@ void __net_exit ip_vs_conn_net_cleanup(struct net *net)
 {
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(net);
-	remove_proc_entry("ip_vs_conn", net->proc_net);
-	remove_proc_entry("ip_vs_conn_sync", net->proc_net);
+	proc_net_remove(net, "ip_vs_conn");
+	proc_net_remove(net, "ip_vs_conn_sync");
 }
 
 int __init ip_vs_conn_init(void)
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c68198b..ec664cb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3800,10 +3800,10 @@ int __net_init ip_vs_control_net_init(struct net *net)
 
 	spin_lock_init(&ipvs->tot_stats.lock);
 
-	proc_create("ip_vs", 0, net->proc_net, &ip_vs_info_fops);
-	proc_create("ip_vs_stats", 0, net->proc_net, &ip_vs_stats_fops);
-	proc_create("ip_vs_stats_percpu", 0, net->proc_net,
-		    &ip_vs_stats_percpu_fops);
+	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
+	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
+	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
+			     &ip_vs_stats_percpu_fops);
 
 	if (ip_vs_control_net_init_sysctl(net))
 		goto err;
@@ -3822,9 +3822,9 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 	ip_vs_trash_cleanup(net);
 	ip_vs_stop_estimator(net, &ipvs->tot_stats);
 	ip_vs_control_net_cleanup_sysctl(net);
-	remove_proc_entry("ip_vs_stats_percpu", net->proc_net);
-	remove_proc_entry("ip_vs_stats", net->proc_net);
-	remove_proc_entry("ip_vs", net->proc_net);
+	proc_net_remove(net, "ip_vs_stats_percpu");
+	proc_net_remove(net, "ip_vs_stats");
+	proc_net_remove(net, "ip_vs");
 	free_percpu(ipvs->tot_stats.cpustats);
 }
 
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 8c10e3d..3e3bf89 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -568,8 +568,7 @@ static int exp_proc_init(struct net *net)
 #ifdef CONFIG_NF_CONNTRACK_PROCFS
 	struct proc_dir_entry *proc;
 
-	proc = proc_create("nf_conntrack_expect", 0440, net->proc_net,
-			   &exp_file_ops);
+	proc = proc_net_fops_create(net, "nf_conntrack_expect", 0440, &exp_file_ops);
 	if (!proc)
 		return -ENOMEM;
 #endif /* CONFIG_NF_CONNTRACK_PROCFS */
@@ -579,7 +578,7 @@ static int exp_proc_init(struct net *net)
 static void exp_proc_remove(struct net *net)
 {
 #ifdef CONFIG_NF_CONNTRACK_PROCFS
-	remove_proc_entry("nf_conntrack_expect", net->proc_net);
+	proc_net_remove(net, "nf_conntrack_expect");
 #endif /* CONFIG_NF_CONNTRACK_PROCFS */
 }
 
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 6bcce40..7936bf7 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -366,7 +366,7 @@ static int nf_conntrack_standalone_init_proc(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
-	pde = proc_create("nf_conntrack", 0440, net->proc_net, &ct_file_ops);
+	pde = proc_net_fops_create(net, "nf_conntrack", 0440, &ct_file_ops);
 	if (!pde)
 		goto out_nf_conntrack;
 
@@ -377,7 +377,7 @@ static int nf_conntrack_standalone_init_proc(struct net *net)
 	return 0;
 
 out_stat_nf_conntrack:
-	remove_proc_entry("nf_conntrack", net->proc_net);
+	proc_net_remove(net, "nf_conntrack");
 out_nf_conntrack:
 	return -ENOMEM;
 }
@@ -385,7 +385,7 @@ out_nf_conntrack:
 static void nf_conntrack_standalone_fini_proc(struct net *net)
 {
 	remove_proc_entry("nf_conntrack", net->proc_net_stat);
-	remove_proc_entry("nf_conntrack", net->proc_net);
+	proc_net_remove(net, "nf_conntrack");
 }
 #else
 static int nf_conntrack_standalone_init_proc(struct net *net)
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 686c771..7b3a9e5 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1323,12 +1323,12 @@ int xt_proto_init(struct net *net, u_int8_t af)
 out_remove_matches:
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_MATCHES, sizeof(buf));
-	remove_proc_entry(buf, net->proc_net);
+	proc_net_remove(net, buf);
 
 out_remove_tables:
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_TABLES, sizeof(buf));
-	remove_proc_entry(buf, net->proc_net);
+	proc_net_remove(net, buf);
 out:
 	return -1;
 #endif
@@ -1342,15 +1342,15 @@ void xt_proto_fini(struct net *net, u_int8_t af)
 
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_TABLES, sizeof(buf));
-	remove_proc_entry(buf, net->proc_net);
+	proc_net_remove(net, buf);
 
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_TARGETS, sizeof(buf));
-	remove_proc_entry(buf, net->proc_net);
+	proc_net_remove(net, buf);
 
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_MATCHES, sizeof(buf));
-	remove_proc_entry(buf, net->proc_net);
+	proc_net_remove(net, buf);
 #endif /*CONFIG_PROC_FS*/
 }
 EXPORT_SYMBOL_GPL(xt_proto_fini);
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index f330e8b..78e4a45 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -864,7 +864,7 @@ static int __net_init hashlimit_proc_net_init(struct net *net)
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	hashlimit_net->ip6t_hashlimit = proc_mkdir("ip6t_hashlimit", net->proc_net);
 	if (!hashlimit_net->ip6t_hashlimit) {
-		remove_proc_entry("ipt_hashlimit", net->proc_net);
+		proc_net_remove(net, "ipt_hashlimit");
 		return -ENOMEM;
 	}
 #endif
@@ -893,9 +893,9 @@ static void __net_exit hashlimit_proc_net_exit(struct net *net)
 	hashlimit_net->ip6t_hashlimit = NULL;
 	mutex_unlock(&hashlimit_mutex);
 
-	remove_proc_entry("ipt_hashlimit", net->proc_net);
+	proc_net_remove(net, "ipt_hashlimit");
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
-	remove_proc_entry("ip6t_hashlimit", net->proc_net);
+	proc_net_remove(net, "ip6t_hashlimit");
 #endif
 }
 
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index d9cad31..c3cdcb4 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -643,7 +643,7 @@ static void __net_exit recent_proc_net_exit(struct net *net)
 	recent_net->xt_recent = NULL;
 	spin_unlock_bh(&recent_lock);
 
-	remove_proc_entry("xt_recent", net->proc_net);
+	proc_net_remove(net, "xt_recent");
 }
 #else
 static inline int recent_proc_net_init(struct net *net)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1e3fd5b..ffddbee 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2137,7 +2137,7 @@ static const struct net_proto_family netlink_family_ops = {
 static int __net_init netlink_net_init(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	if (!proc_create("netlink", 0, net->proc_net, &netlink_seq_fops))
+	if (!proc_net_fops_create(net, "netlink", 0, &netlink_seq_fops))
 		return -ENOMEM;
 #endif
 	return 0;
@@ -2146,7 +2146,7 @@ static int __net_init netlink_net_init(struct net *net)
 static void __net_exit netlink_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	remove_proc_entry("netlink", net->proc_net);
+	proc_net_remove(net, "netlink");
 #endif
 }
 
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index d1fa1d9..92c43aa 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1448,9 +1448,9 @@ static int __init nr_proto_init(void)
 
 	nr_loopback_init();
 
-	proc_create("nr", S_IRUGO, init_net.proc_net, &nr_info_fops);
-	proc_create("nr_neigh", S_IRUGO, init_net.proc_net, &nr_neigh_fops);
-	proc_create("nr_nodes", S_IRUGO, init_net.proc_net, &nr_nodes_fops);
+	proc_net_fops_create(&init_net, "nr", S_IRUGO, &nr_info_fops);
+	proc_net_fops_create(&init_net, "nr_neigh", S_IRUGO, &nr_neigh_fops);
+	proc_net_fops_create(&init_net, "nr_nodes", S_IRUGO, &nr_nodes_fops);
 out:
 	return rc;
 fail:
@@ -1478,9 +1478,9 @@ static void __exit nr_exit(void)
 {
 	int i;
 
-	remove_proc_entry("nr", init_net.proc_net);
-	remove_proc_entry("nr_neigh", init_net.proc_net);
-	remove_proc_entry("nr_nodes", init_net.proc_net);
+	proc_net_remove(&init_net, "nr");
+	proc_net_remove(&init_net, "nr_neigh");
+	proc_net_remove(&init_net, "nr_nodes");
 	nr_loopback_clear();
 
 	nr_rt_free();
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1d6793d..6a5d590 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3827,7 +3827,7 @@ static int __net_init packet_net_init(struct net *net)
 	mutex_init(&net->packet.sklist_lock);
 	INIT_HLIST_HEAD(&net->packet.sklist);
 
-	if (!proc_create("packet", 0, net->proc_net, &packet_seq_fops))
+	if (!proc_net_fops_create(net, "packet", 0, &packet_seq_fops))
 		return -ENOMEM;
 
 	return 0;
@@ -3835,7 +3835,7 @@ static int __net_init packet_net_init(struct net *net)
 
 static void __net_exit packet_net_exit(struct net *net)
 {
-	remove_proc_entry("packet", net->proc_net);
+	proc_net_remove(net, "packet");
 }
 
 static struct pernet_operations packet_net_ops = {
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 45a7df6..5bf6341 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -320,7 +320,7 @@ static int __net_init phonet_init_net(struct net *net)
 {
 	struct phonet_net *pnn = phonet_pernet(net);
 
-	if (!proc_create("phonet", 0, net->proc_net, &pn_sock_seq_fops))
+	if (!proc_net_fops_create(net, "phonet", 0, &pn_sock_seq_fops))
 		return -ENOMEM;
 
 	INIT_LIST_HEAD(&pnn->pndevs.list);
@@ -331,7 +331,7 @@ static int __net_init phonet_init_net(struct net *net)
 
 static void __net_exit phonet_exit_net(struct net *net)
 {
-	remove_proc_entry("phonet", net->proc_net);
+	proc_net_remove(net, "phonet");
 }
 
 static struct pernet_operations phonet_net_ops = {
@@ -348,7 +348,7 @@ int __init phonet_device_init(void)
 	if (err)
 		return err;
 
-	proc_create("pnresource", 0, init_net.proc_net, &pn_res_seq_fops);
+	proc_net_fops_create(&init_net, "pnresource", 0, &pn_res_seq_fops);
 	register_netdevice_notifier(&phonet_device_notifier);
 	err = phonet_netlink_register();
 	if (err)
@@ -361,7 +361,7 @@ void phonet_device_exit(void)
 	rtnl_unregister_all(PF_PHONET);
 	unregister_netdevice_notifier(&phonet_device_notifier);
 	unregister_pernet_subsys(&phonet_net_ops);
-	remove_proc_entry("pnresource", init_net.proc_net);
+	proc_net_remove(&init_net, "pnresource");
 }
 
 int phonet_route_add(struct net_device *dev, u8 daddr)
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index cf68e6e..39396d8 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1571,13 +1571,10 @@ static int __init rose_proto_init(void)
 
 	rose_add_loopback_neigh();
 
-	proc_create("rose", S_IRUGO, init_net.proc_net, &rose_info_fops);
-	proc_create("rose_neigh", S_IRUGO, init_net.proc_net,
-		    &rose_neigh_fops);
-	proc_create("rose_nodes", S_IRUGO, init_net.proc_net,
-		    &rose_nodes_fops);
-	proc_create("rose_routes", S_IRUGO, init_net.proc_net,
-		    &rose_routes_fops);
+	proc_net_fops_create(&init_net, "rose", S_IRUGO, &rose_info_fops);
+	proc_net_fops_create(&init_net, "rose_neigh", S_IRUGO, &rose_neigh_fops);
+	proc_net_fops_create(&init_net, "rose_nodes", S_IRUGO, &rose_nodes_fops);
+	proc_net_fops_create(&init_net, "rose_routes", S_IRUGO, &rose_routes_fops);
 out:
 	return rc;
 fail:
@@ -1604,10 +1601,10 @@ static void __exit rose_exit(void)
 {
 	int i;
 
-	remove_proc_entry("rose", init_net.proc_net);
-	remove_proc_entry("rose_neigh", init_net.proc_net);
-	remove_proc_entry("rose_nodes", init_net.proc_net);
-	remove_proc_entry("rose_routes", init_net.proc_net);
+	proc_net_remove(&init_net, "rose");
+	proc_net_remove(&init_net, "rose_neigh");
+	proc_net_remove(&init_net, "rose_nodes");
+	proc_net_remove(&init_net, "rose_routes");
 	rose_loopback_clear();
 
 	rose_rt_free();
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index e61aa60..5b0fd29 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -839,9 +839,8 @@ static int __init af_rxrpc_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc_create("rxrpc_calls", 0, init_net.proc_net, &rxrpc_call_seq_fops);
-	proc_create("rxrpc_conns", 0, init_net.proc_net,
-		    &rxrpc_connection_seq_fops);
+	proc_net_fops_create(&init_net, "rxrpc_calls", 0, &rxrpc_call_seq_fops);
+	proc_net_fops_create(&init_net, "rxrpc_conns", 0, &rxrpc_connection_seq_fops);
 #endif
 	return 0;
 
@@ -879,8 +878,8 @@ static void __exit af_rxrpc_exit(void)
 
 	_debug("flush scheduled work");
 	flush_workqueue(rxrpc_workqueue);
-	remove_proc_entry("rxrpc_conns", init_net.proc_net);
-	remove_proc_entry("rxrpc_calls", init_net.proc_net);
+	proc_net_remove(&init_net, "rxrpc_conns");
+	proc_net_remove(&init_net, "rxrpc_calls");
 	destroy_workqueue(rxrpc_workqueue);
 	kmem_cache_destroy(rxrpc_call_jar);
 	_leave("");
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c297e2a..265f6ff 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1768,7 +1768,7 @@ static int __net_init psched_net_init(struct net *net)
 {
 	struct proc_dir_entry *e;
 
-	e = proc_create("psched", 0, net->proc_net, &psched_fops);
+	e = proc_net_fops_create(net, "psched", 0, &psched_fops);
 	if (e == NULL)
 		return -ENOMEM;
 
@@ -1777,7 +1777,7 @@ static int __net_init psched_net_init(struct net *net)
 
 static void __net_exit psched_net_exit(struct net *net)
 {
-	remove_proc_entry("psched", net->proc_net);
+	proc_net_remove(net, "psched");
 }
 #else
 static int __net_init psched_net_init(struct net *net)
diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index ad0dba8..261b7b9 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -195,8 +195,8 @@ static __init int sctpprobe_init(void)
 	if (kfifo_alloc(&sctpw.fifo, bufsize, GFP_KERNEL))
 		return ret;
 
-	if (!proc_create(procname, S_IRUSR, init_net.proc_net,
-			 &sctpprobe_fops))
+	if (!proc_net_fops_create(&init_net, procname, S_IRUSR,
+				  &sctpprobe_fops))
 		goto free_kfifo;
 
 	ret = register_jprobe(&sctp_recv_probe);
@@ -208,7 +208,7 @@ static __init int sctpprobe_init(void)
 	return 0;
 
 remove_proc:
-	remove_proc_entry(procname, init_net.proc_net);
+	proc_net_remove(&init_net, procname);
 free_kfifo:
 	kfifo_free(&sctpw.fifo);
 	return ret;
@@ -217,7 +217,7 @@ free_kfifo:
 static __exit void sctpprobe_exit(void)
 {
 	kfifo_free(&sctpw.fifo);
-	remove_proc_entry(procname, init_net.proc_net);
+	proc_net_remove(&init_net, procname);
 	unregister_jprobe(&sctp_recv_probe);
 }
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51be64f..97d303c 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2400,7 +2400,7 @@ static int __net_init unix_net_init(struct net *net)
 		goto out;
 
 #ifdef CONFIG_PROC_FS
-	if (!proc_create("unix", 0, net->proc_net, &unix_seq_fops)) {
+	if (!proc_net_fops_create(net, "unix", 0, &unix_seq_fops)) {
 		unix_sysctl_unregister(net);
 		goto out;
 	}
@@ -2413,7 +2413,7 @@ out:
 static void __net_exit unix_net_exit(struct net *net)
 {
 	unix_sysctl_unregister(net);
-	remove_proc_entry("unix", net->proc_net);
+	proc_net_remove(net, "unix");
 }
 
 static struct pernet_operations unix_net_ops = {
diff --git a/net/wireless/wext-proc.c b/net/wireless/wext-proc.c
index e98a01c..8bafa31 100644
--- a/net/wireless/wext-proc.c
+++ b/net/wireless/wext-proc.c
@@ -143,8 +143,7 @@ static const struct file_operations wireless_seq_fops = {
 int __net_init wext_proc_init(struct net *net)
 {
 	/* Create /proc/net/wireless entry */
-	if (!proc_create("wireless", S_IRUGO, net->proc_net,
-			 &wireless_seq_fops))
+	if (!proc_net_fops_create(net, "wireless", S_IRUGO, &wireless_seq_fops))
 		return -ENOMEM;
 
 	return 0;
@@ -152,5 +151,5 @@ int __net_init wext_proc_init(struct net *net)
 
 void __net_exit wext_proc_exit(struct net *net)
 {
-	remove_proc_entry("wireless", net->proc_net);
+	proc_net_remove(net, "wireless");
 }
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index c721b0d..6039038 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -74,13 +74,13 @@ static const struct file_operations xfrm_statistics_seq_fops = {
 
 int __net_init xfrm_proc_init(struct net *net)
 {
-	if (!proc_create("xfrm_stat", S_IRUGO, net->proc_net,
-			 &xfrm_statistics_seq_fops))
+	if (!proc_net_fops_create(net, "xfrm_stat", S_IRUGO,
+				  &xfrm_statistics_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
 
 void xfrm_proc_fini(struct net *net)
 {
-	remove_proc_entry("xfrm_stat", net->proc_net);
+	proc_net_remove(net, "xfrm_stat");
 }
