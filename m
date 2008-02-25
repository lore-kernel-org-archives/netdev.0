From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH] nf_conntrack: less hairy ifdefs around proc and sysctl
Date: Mon, 25 Feb 2008 12:54:28 +0300
Message-ID: <20080225095428.GA3789@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1536 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742AbYBYJyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 04:54:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch splits creation of /proc/net/nf_conntrack, /proc/net/stat/nf_conntrack
and net.netfilter hierarchy into their own functions with dummy ones
if PROC_FS or SYSCTL is not set. Also, remove dead "ret = 0" write
while I'm at it.

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 net/netfilter/nf_conntrack_standalone.c |  119 ++++++++++++++++++++------------
 1 file changed, 76 insertions(+), 43 deletions(-)

--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -295,6 +295,41 @@ static const struct file_operations ct_cpu_seq_fops = {
 	.llseek	 = seq_lseek,
 	.release = seq_release_private,
 };
+
+static int nf_conntrack_standalone_init_proc(void)
+{
+	struct proc_dir_entry *pde;
+
+	pde = proc_net_fops_create(&init_net, "nf_conntrack", 0440, &ct_file_ops);
+	if (!pde)
+		goto out_nf_conntrack;
+	pde = create_proc_entry("nf_conntrack", S_IRUGO, init_net.proc_net_stat);
+	if (!pde)
+		goto out_stat_nf_conntrack;
+	pde->proc_fops = &ct_cpu_seq_fops;
+	pde->owner = THIS_MODULE;
+	return 0;
+
+out_stat_nf_conntrack:
+	proc_net_remove(&init_net, "nf_conntrack");
+out_nf_conntrack:
+	return -ENOMEM;
+}
+
+static void nf_conntrack_standalone_fini_proc(void)
+{
+	remove_proc_entry("nf_conntrack", init_net.proc_net_stat);
+	proc_net_remove(&init_net, "nf_conntrack");
+}
+#else
+static int nf_conntrack_standalone_init_proc(void)
+{
+	return 0;
+}
+
+static void nf_conntrack_standalone_fini_proc(void)
+{
+}
 #endif /* CONFIG_PROC_FS */
 
 /* Sysctl support */
@@ -390,63 +425,61 @@ static struct ctl_path nf_ct_path[] = {
 };
 
 EXPORT_SYMBOL_GPL(nf_ct_log_invalid);
+
+static int nf_conntrack_standalone_init_sysctl(void)
+{
+	nf_ct_sysctl_header =
+		register_sysctl_paths(nf_ct_path, nf_ct_netfilter_table);
+	if (nf_ct_sysctl_header == NULL) {
+		printk("nf_conntrack: can't register to sysctl.\n");
+		return -ENOMEM;
+	}
+	return 0;
+
+}
+
+static void nf_conntrack_standalone_fini_sysctl(void)
+{
+	unregister_sysctl_table(nf_ct_sysctl_header);
+}
+#else
+static int nf_conntrack_standalone_init_sysctl(void)
+{
+	return 0;
+}
+
+static void nf_conntrack_standalone_fini_sysctl(void)
+{
+}
 #endif /* CONFIG_SYSCTL */
 
 static int __init nf_conntrack_standalone_init(void)
 {
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *proc, *proc_stat;
-#endif
-	int ret = 0;
+	int ret;
 
 	ret = nf_conntrack_init();
 	if (ret < 0)
-		return ret;
-
-#ifdef CONFIG_PROC_FS
-	proc = proc_net_fops_create(&init_net, "nf_conntrack", 0440, &ct_file_ops);
-	if (!proc) goto cleanup_init;
-
-	proc_stat = create_proc_entry("nf_conntrack", S_IRUGO, init_net.proc_net_stat);
-	if (!proc_stat)
-		goto cleanup_proc;
-
-	proc_stat->proc_fops = &ct_cpu_seq_fops;
-	proc_stat->owner = THIS_MODULE;
-#endif
-#ifdef CONFIG_SYSCTL
-	nf_ct_sysctl_header = register_sysctl_paths(nf_ct_path,
-			nf_ct_netfilter_table);
-	if (nf_ct_sysctl_header == NULL) {
-		printk("nf_conntrack: can't register to sysctl.\n");
-		ret = -ENOMEM;
-		goto cleanup_proc_stat;
-	}
-#endif
-	return ret;
+		goto out;
+	ret = nf_conntrack_standalone_init_proc();
+	if (ret < 0)
+		goto out_proc;
+	ret = nf_conntrack_standalone_init_sysctl();
+	if (ret < 0)
+		goto out_sysctl;
+	return 0;
 
-#ifdef CONFIG_SYSCTL
- cleanup_proc_stat:
-#endif
-#ifdef CONFIG_PROC_FS
-	remove_proc_entry("nf_conntrack", init_net. proc_net_stat);
- cleanup_proc:
-	proc_net_remove(&init_net, "nf_conntrack");
- cleanup_init:
-#endif /* CNFIG_PROC_FS */
+out_sysctl:
+	nf_conntrack_standalone_fini_proc();
+out_proc:
 	nf_conntrack_cleanup();
+out:
 	return ret;
 }
 
 static void __exit nf_conntrack_standalone_fini(void)
 {
-#ifdef CONFIG_SYSCTL
-	unregister_sysctl_table(nf_ct_sysctl_header);
-#endif
-#ifdef CONFIG_PROC_FS
-	remove_proc_entry("nf_conntrack", init_net.proc_net_stat);
-	proc_net_remove(&init_net, "nf_conntrack");
-#endif /* CNFIG_PROC_FS */
+	nf_conntrack_standalone_fini_sysctl();
+	nf_conntrack_standalone_fini_proc();
 	nf_conntrack_cleanup();
 }
 

