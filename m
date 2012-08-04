From: Jan Ariyasu <jan.ariyasu@gmail.com>
Subject: [PATCH 03/13] SCTP: These changes register procfs for netns.
Date: Sat,  4 Aug 2012 15:32:27 -0600
Message-ID: <1344115947-6250-1-git-send-email-jan.ariyasu@hp.com>
Cc: Jan Ariyasu <jan.ariyasu@hp.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modified proc to initialization to be namespace compatible.

Signed-off-by: Jan Ariyasu <jan.ariyasu@hp.com>
---
 include/net/sctp/sctp.h |   17 +++++-----
 net/sctp/objcnt.c       |    8 ++---
 net/sctp/proc.c         |   77 +++++++++++++++++++++++++-------------------
 net/sctp/protocol.c     |   81 +++++++++++++++++++++++------------------------
 4 files changed, 97 insertions(+), 86 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index c2dfeea..97ba550 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -177,14 +177,14 @@ void sctp_backlog_migrate(struct sctp_association *assoc,
 /*
  * sctp/proc.c
  */
-int sctp_snmp_proc_init(void);
-void sctp_snmp_proc_exit(void);
-int sctp_eps_proc_init(void);
-void sctp_eps_proc_exit(void);
-int sctp_assocs_proc_init(void);
-void sctp_assocs_proc_exit(void);
-int sctp_remaddr_proc_init(void);
-void sctp_remaddr_proc_exit(void);
+int sctp_snmp_proc_init(struct net *);
+void sctp_snmp_proc_exit(struct net *);
+int sctp_eps_proc_init(struct net *);
+void sctp_eps_proc_exit(struct net *);
+int sctp_assocs_proc_init(struct net *);
+void sctp_assocs_proc_exit(struct net *);
+int sctp_remaddr_proc_init(struct net *);
+void sctp_remaddr_proc_exit(struct net *);
 
 
 /*
@@ -590,7 +590,6 @@ for (pos = chunk->subh.fwdtsn_hdr->skip;\
 
 extern struct proto sctp_prot;
 extern struct proto sctpv6_prot;
-extern struct proc_dir_entry *proc_net_sctp;
 void sctp_put_port(struct sock *sk);
 
 extern struct idr sctp_assocs_id;
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index 8ef8e7d..42fa43a 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -132,9 +132,10 @@ static const struct file_operations sctp_objcnt_ops = {
 void sctp_dbg_objcnt_init(void)
 {
 	struct proc_dir_entry *ent;
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(&init_net);
 
 	ent = proc_create("sctp_dbg_objcnt", 0,
-			  proc_net_sctp, &sctp_objcnt_ops);
+			  ns_globals->sctp_proc_dir, &sctp_objcnt_ops);
 	if (!ent)
 		pr_warn("sctp_dbg_objcnt: Unable to create /proc entry.\n");
 }
@@ -142,7 +143,6 @@ void sctp_dbg_objcnt_init(void)
 /* Cleanup the objcount entry in the proc filesystem.  */
 void sctp_dbg_objcnt_exit(void)
 {
-	remove_proc_entry("sctp_dbg_objcnt", proc_net_sctp);
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(&init_net);
+	remove_proc_entry("sctp_dbg_objcnt", ns_globals->sctp_proc_dir);
 }
-
-
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 1e2eee8..d8f7b94 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -40,6 +40,7 @@
 #include <linux/export.h>
 #include <net/sctp/sctp.h>
 #include <net/ip.h> /* for snmp_fold_field */
+#include <net/net_namespace.h>
 
 static const struct snmp_mib sctp_snmp_list[] = {
 	SNMP_MIB_ITEM("SctpCurrEstab", SCTP_MIB_CURRESTAB),
@@ -93,7 +94,7 @@ static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 /* Initialize the seq file operations for 'snmp' object. */
 static int sctp_snmp_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, sctp_snmp_seq_show, NULL);
+	return single_open_net(inode, file, sctp_snmp_seq_show);
 }
 
 static const struct file_operations sctp_snmp_seq_fops = {
@@ -101,25 +102,29 @@ static const struct file_operations sctp_snmp_seq_fops = {
 	.open	 = sctp_snmp_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = single_release_net,
 };
 
 /* Set up the proc fs entry for 'snmp' object. */
-int __init sctp_snmp_proc_init(void)
+int __net_init sctp_snmp_proc_init(struct net *net)
 {
-	struct proc_dir_entry *p;
-
-	p = proc_create("snmp", S_IRUGO, proc_net_sctp, &sctp_snmp_seq_fops);
-	if (!p)
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	ns_globals->sctp_proc_snmp =
+		 proc_create("snmp", S_IRUGO, ns_globals->sctp_proc_dir,
+				&sctp_snmp_seq_fops);
+	if (!ns_globals->sctp_proc_snmp) {
+		pr_err("Couldn't create proc snmp for sctp\n");
 		return -ENOMEM;
+	}
 
 	return 0;
 }
 
 /* Cleanup the proc fs entry for 'snmp' object. */
-void sctp_snmp_proc_exit(void)
+void sctp_snmp_proc_exit(struct net *net)
 {
-	remove_proc_entry("snmp", proc_net_sctp);
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	remove_proc_entry("snmp", ns_globals->sctp_proc_dir);
 }
 
 /* Dump local addresses of an association/endpoint. */
@@ -238,7 +243,8 @@ static const struct seq_operations sctp_eps_ops = {
 /* Initialize the seq file operations for 'eps' object. */
 static int sctp_eps_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &sctp_eps_ops);
+	return seq_open_net(inode, file, &sctp_eps_ops,
+				sizeof(struct seq_net_private));
 }
 
 static const struct file_operations sctp_eps_seq_fops = {
@@ -249,21 +255,23 @@ static const struct file_operations sctp_eps_seq_fops = {
 };
 
 /* Set up the proc fs entry for 'eps' object. */
-int __init sctp_eps_proc_init(void)
+int __net_init sctp_eps_proc_init(struct net *net)
 {
-	struct proc_dir_entry *p;
-
-	p = proc_create("eps", S_IRUGO, proc_net_sctp, &sctp_eps_seq_fops);
-	if (!p)
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	ns_globals->sctp_proc_eps =
+		proc_create("eps", S_IRUGO, ns_globals->sctp_proc_dir,
+				&sctp_eps_seq_fops);
+	if (!ns_globals->sctp_proc_eps)
 		return -ENOMEM;
 
 	return 0;
 }
 
 /* Cleanup the proc fs entry for 'eps' object. */
-void sctp_eps_proc_exit(void)
+void sctp_eps_proc_exit(struct net *net)
 {
-	remove_proc_entry("eps", proc_net_sctp);
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	remove_proc_entry("eps", ns_globals->sctp_proc_dir);
 }
 
 
@@ -354,7 +362,8 @@ static const struct seq_operations sctp_assoc_ops = {
 /* Initialize the seq file operations for 'assocs' object. */
 static int sctp_assocs_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &sctp_assoc_ops);
+	return seq_open_net(inode, file, &sctp_assoc_ops,
+				sizeof(struct seq_net_private));
 }
 
 static const struct file_operations sctp_assocs_seq_fops = {
@@ -365,22 +374,23 @@ static const struct file_operations sctp_assocs_seq_fops = {
 };
 
 /* Set up the proc fs entry for 'assocs' object. */
-int __init sctp_assocs_proc_init(void)
+int __net_init sctp_assocs_proc_init(struct net *net)
 {
-	struct proc_dir_entry *p;
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
 
-	p = proc_create("assocs", S_IRUGO, proc_net_sctp,
-			&sctp_assocs_seq_fops);
-	if (!p)
+	ns_globals->sctp_proc_assocs = proc_create("assocs", S_IRUGO,
+			ns_globals->sctp_proc_dir, &sctp_assocs_seq_fops);
+	if (!ns_globals->sctp_proc_assocs)
 		return -ENOMEM;
 
 	return 0;
 }
 
 /* Cleanup the proc fs entry for 'assocs' object. */
-void sctp_assocs_proc_exit(void)
+void sctp_assocs_proc_exit(struct net *net)
 {
-	remove_proc_entry("assocs", proc_net_sctp);
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	remove_proc_entry("assocs", ns_globals->sctp_proc_dir);
 }
 
 static void *sctp_remaddr_seq_start(struct seq_file *seq, loff_t *pos)
@@ -489,14 +499,16 @@ static const struct seq_operations sctp_remaddr_ops = {
 };
 
 /* Cleanup the proc fs entry for 'remaddr' object. */
-void sctp_remaddr_proc_exit(void)
+void sctp_remaddr_proc_exit(struct net *net)
 {
-	remove_proc_entry("remaddr", proc_net_sctp);
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	remove_proc_entry("remaddr", ns_globals->sctp_proc_dir);
 }
 
 static int sctp_remaddr_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &sctp_remaddr_ops);
+	return seq_open_net(inode, file, &sctp_remaddr_ops,
+				sizeof(struct seq_net_private));
 }
 
 static const struct file_operations sctp_remaddr_seq_fops = {
@@ -506,12 +518,13 @@ static const struct file_operations sctp_remaddr_seq_fops = {
 	.release = seq_release,
 };
 
-int __init sctp_remaddr_proc_init(void)
+int __net_init sctp_remaddr_proc_init(struct net *net)
 {
-	struct proc_dir_entry *p;
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
 
-	p = proc_create("remaddr", S_IRUGO, proc_net_sctp, &sctp_remaddr_seq_fops);
-	if (!p)
+	ns_globals->sctp_proc_remaddr = proc_create("remaddr", S_IRUGO,
+			ns_globals->sctp_proc_dir, &sctp_remaddr_seq_fops);
+	if (!ns_globals->sctp_proc_remaddr)
 		return -ENOMEM;
 	return 0;
 }
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5c1a18c..28dbef2 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -71,10 +71,6 @@
 struct sctp_globals sctp_globals __read_mostly;
 DEFINE_SNMP_STAT(struct sctp_mib, sctp_statistics) __read_mostly;
 
-#ifdef CONFIG_PROC_FS
-struct proc_dir_entry	*proc_net_sctp;
-#endif
-
 struct idr sctp_assocs_id;
 DEFINE_SPINLOCK(sctp_assocs_id_lock);
 
@@ -97,43 +93,46 @@ int sysctl_sctp_rmem[3];
 int sysctl_sctp_wmem[3];
 
 /* Set up the proc fs entry for the SCTP protocol. */
-static __init int sctp_proc_init(void)
+static __net_init int sctp_proc_init(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
 	int status = 0;
-	if (!proc_net_sctp) {
-		proc_net_sctp = proc_mkdir("sctp", init_net.proc_net);
-		if (!proc_net_sctp) {
-			status = -ENOMEM;
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	ns_globals->sctp_proc_dir = proc_net_mkdir(net, "sctp", net->proc_net);
+	if (!ns_globals->sctp_proc_dir->name) {
+		pr_err("Failed to create sctp procfs directory\n");
+		status = -ENOBUFS;
 			goto out;
 		}
-	}
 
-	status = sctp_snmp_proc_init();
+	status = sctp_snmp_proc_init(net);
 	if (status)
 		goto out_snmp_proc_init;
-	status = sctp_eps_proc_init();
+
+	status = sctp_eps_proc_init(net);
 	if (status)
 		goto out_eps_proc_init;
-	status = sctp_assocs_proc_init();
+
+	status = sctp_assocs_proc_init(net);
 	if (status)
 		goto out_assocs_proc_init;
-	status = sctp_remaddr_proc_init();
+
+	status = sctp_remaddr_proc_init(net);
 	if (status)
 		goto out_remaddr_proc_init;
 
 	return status;
 
 out_remaddr_proc_init:
-	sctp_assocs_proc_exit();
+	sctp_assocs_proc_exit(net);
 out_assocs_proc_init:
-	sctp_eps_proc_exit();
+	sctp_eps_proc_exit(net);
 out_eps_proc_init:
-	sctp_snmp_proc_exit();
+	sctp_snmp_proc_exit(net);
 out_snmp_proc_init:
-	if (proc_net_sctp) {
-		proc_net_sctp = NULL;
-		remove_proc_entry("sctp", init_net.proc_net);
+	if (ns_globals->sctp_proc_dir) {
+		ns_globals->sctp_proc_dir = NULL;
+		remove_proc_entry("sctp", ns_globals->sctp_proc_dir);
 	}
 out:
 	return status;
@@ -146,17 +145,18 @@ out:
  * Note: Do not make this __exit as it is used in the init error
  * path.
  */
-static void sctp_proc_exit(void)
+static void sctp_proc_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	sctp_snmp_proc_exit();
-	sctp_eps_proc_exit();
-	sctp_assocs_proc_exit();
-	sctp_remaddr_proc_exit();
-
-	if (proc_net_sctp) {
-		proc_net_sctp = NULL;
-		remove_proc_entry("sctp", init_net.proc_net);
+	struct sctp_ns_globals *ns_globals = sctp_get_ns_globals(net);
+	sctp_snmp_proc_exit(net);
+	sctp_eps_proc_exit(net);
+	sctp_assocs_proc_exit(net);
+	sctp_remaddr_proc_exit(net);
+
+	if (ns_globals->sctp_proc_dir) {
+		proc_net_remove(net, "sctp");
+		ns_globals->sctp_proc_dir = NULL;
 	}
 #endif
 }
@@ -1271,7 +1271,6 @@ static void sctp_global_param_init(void)
 	return;
 }
 
-
 static int sctp_net_param_init(struct net *net)
 {
 	struct sctp_net_params *net_params = sctp_get_params(net);
@@ -1555,11 +1554,17 @@ static int __net_init sctp_net_init(struct net *net)
 	if (err)
 		goto out;
 
+	err = sctp_proc_init(net);
+	if (err)
+		goto err_proc_init;
+
 	err = sctp_net_param_init(net);
 	if (err)
 		goto err_param_init;
 
 err_param_init:
+	sctp_proc_exit(net);
+err_proc_init:
 	sctp_ctl_sock_destroy(net);
 out:
 	return err;
@@ -1568,6 +1573,7 @@ out:
 static void __net_exit sctp_net_exit(struct net *net)
 {
 	sctp_ctl_sock_destroy(net);
+	sctp_proc_exit(net);
 }
 
 static __net_initdata struct pernet_operations sctp_sk_ops = {
@@ -1642,10 +1648,14 @@ SCTP_STATIC __init int sctp_init(void)
 	if (status)
 		goto err_add_protocol;
 
+	/* Register SCTP with inet6 layer.  */
 	status = sctp_v6_add_protocol();
 	if (status)
 		goto err_v6_add_protocol;
 
+	/*  Set up sysctl parameters.   */
+	sctp_sysctl_register();
+
 	/*
 	 * Register for pernet packet handling
 	 */
@@ -1655,17 +1665,9 @@ SCTP_STATIC __init int sctp_init(void)
 		goto err_ns_init;
 	}
 
-	/* Initialize proc fs directory.  */
-	status = sctp_proc_init();
-	if (status)
-		goto err_init_proc;
-
 	/* Initialize object count debugging.  */
 	sctp_dbg_objcnt_init();
 
-	/*  Set up sysctl parameters.   */
-	sctp_sysctl_register();
-
 	/* Allocate and initialise sctp mibs.  */
 	status = init_sctp_mibs();
 	if (status)
@@ -1677,8 +1679,6 @@ SCTP_STATIC __init int sctp_init(void)
 err_mib_init:
 	sctp_sysctl_unregister();
 	sctp_dbg_objcnt_exit();
-	sctp_proc_exit();
-err_init_proc:
 	sctp_ns_exit();
 err_ns_init:
 	sctp_v6_del_protocol();
@@ -1727,7 +1727,6 @@ SCTP_STATIC __exit void sctp_exit(void)
 	sctp_hashtable_globals_free();
 
 	sctp_dbg_objcnt_exit();
-	sctp_proc_exit();
 	percpu_counter_destroy(&sctp_sockets_allocated);
 	cleanup_sctp_mibs();
 
-- 
1.7.9.5
