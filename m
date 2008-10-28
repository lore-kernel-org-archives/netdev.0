From: Vivien Chappelier <vivien.chappelier@thomson.net>
Subject: [PATCH 2/6] netns: export nets id to /proc/net/netns
Date: Tue, 28 Oct 2008 18:40:54 +0100
Message-ID: <20081028174054.GB8471@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>, jleu@mindspring.com,
	linux-vrf-general@lists.sourceforge.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmzraw4.extranet.thmulti.com ([141.11.234.72]:34414 "EHLO
	dmzraw4.extranet.thmulti.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754518AbYJ1SPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 14:15:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch initially submitted by Benjamin Thery, provided again here for reference.

This patch exports the new 'struct net' net->id value to /proc/net/nsid
file.
---
 net/core/net_namespace.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 894b35e..418abe0 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -6,6 +6,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 #include <linux/idr.h>
+#include <linux/proc_fs.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -211,6 +212,53 @@ struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 }
 #endif
 
+#ifdef CONFIG_PROC_FS
+static int netns_seq_show(struct seq_file *seq, void *v)
+{
+	struct net *net = seq->private;
+
+	seq_printf(seq, "%x\n", net->id);
+	return 0;
+}
+
+static int netns_seq_open(struct inode *inode, struct file *file)
+{
+        return single_open_net(inode, file, netns_seq_show);
+}
+
+static const struct file_operations netns_seq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = netns_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = single_release_net,
+};
+
+static int __net_init netns_net_init(struct net *net)
+{
+	if (!proc_net_fops_create(net, "nsid", S_IRUGO, &netns_seq_fops))
+		return -ENOMEM;
+	return 0;
+}
+
+static void __net_exit netns_net_exit(struct net *net)
+{
+	proc_net_remove(net, "nsid");
+}
+
+static struct pernet_operations netns_proc_ops = {
+	.init = netns_net_init,
+	.exit = netns_net_exit,
+};
+
+static int __init netns_proc_init()
+{
+	return register_pernet_subsys(&netns_proc_ops);
+}
+#else
+#define netns_proc_init() 0
+#endif /* CONFIG_PROC_FS */
+
 static int __init net_ns_init(void)
 {
 	int err;
@@ -226,6 +274,8 @@ static int __init net_ns_init(void)
 	if (!netns_wq)
 		panic("Could not create netns workq");
 #endif
+	if (netns_proc_init())
+		panic("Could not register netns subsys");
 
 	mutex_lock(&net_mutex);
 	err = setup_net(&init_net);
-- 
1.5.4.4

