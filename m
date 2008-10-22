From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 2/4] netns: Export nets id to /proc/net/netns
Date: Wed, 22 Oct 2008 17:22:04 +0200
Message-ID: <20081022152144.753988954@theryb.frec.bull.fr>
References: <20081022152144.351965414@theryb.frec.bull.fr>
Cc: Eric Biederman <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Serge Hallyn <serue@us.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:37021 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755447AbYJVPXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 11:23:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches exports the new 'struct net' net->id value to /proc/net/nsid
file.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/core/net_namespace.c |   50 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

Index: net-next-2.6/net/core/net_namespace.c
===================================================================
--- net-next-2.6.orig/net/core/net_namespace.c
+++ net-next-2.6/net/core/net_namespace.c
@@ -6,6 +6,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 #include <linux/idr.h>
+#include <linux/proc_fs.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -211,6 +212,53 @@ struct net *copy_net_ns(unsigned long fl
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
