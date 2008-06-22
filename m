From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 24/25] netns ct: make per-netns some sysctls
Date: Sun, 22 Jun 2008 05:21:32 +0400
Message-ID: <20080622012132.GZ5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:8740 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbYFVBZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 21:25:45 -0400
Received: by ug-out-1314.google.com with SMTP id h2so245896ugf.16
        for <netdev@vger.kernel.org>; Sat, 21 Jun 2008 18:25:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net.nf_conntrack_max
net.nf_conntrack_count
net.nf_conntrack_expect_max

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/conntrack.h           |    5 ++
 net/netfilter/nf_conntrack_standalone.c |   78 +++++++++++++++++++++-----------
 2 files changed, 57 insertions(+), 26 deletions(-)

--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -4,6 +4,8 @@
 #include <linux/list.h>
 #include <asm/atomic.h>
 
+struct ctl_table_header;
+
 struct netns_ct {
 	atomic_t		count;
 	int			max;
@@ -14,5 +16,8 @@ struct netns_ct {
 	struct hlist_head	*expect_hash;
 	int			expect_vmalloc;
 	struct hlist_head	unconfirmed;
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header	*sysctl_header;
+#endif
 };
 #endif
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -338,8 +338,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_checksum);
 static int log_invalid_proto_min = 0;
 static int log_invalid_proto_max = 255;
 
-static struct ctl_table_header *nf_ct_sysctl_header;
-
 static ctl_table nf_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_NF_CONNTRACK_MAX,
@@ -422,29 +420,65 @@ static struct ctl_path nf_ct_path[] = {
 
 EXPORT_SYMBOL_GPL(nf_ct_log_invalid);
 
-static int nf_conntrack_standalone_init_sysctl(void)
+static int nf_conntrack_standalone_init_sysctl(struct net *net)
 {
-	nf_ct_sysctl_header =
-		register_sysctl_paths(nf_ct_path, nf_ct_netfilter_table);
-	if (nf_ct_sysctl_header == NULL) {
+	struct ctl_table *table_nf, *table_ct;
+
+	table_nf = nf_ct_netfilter_table;
+	table_ct = nf_ct_sysctl_table;
+	if (net != &init_net) {
+		table_nf = kmemdup(table_nf, sizeof(nf_ct_netfilter_table),
+				   GFP_KERNEL);
+		if (!table_nf)
+			goto out_kmemdup_nf;
+		table_ct = kmemdup(table_ct, sizeof(nf_ct_sysctl_table),
+				   GFP_KERNEL);
+		if (!table_ct)
+			goto out_kmemdup_ct;
+
+		table_nf[0].child = table_ct;
+		table_ct[0].data = &net->ct.max;
+		table_ct[1].data = &net->ct.count;
+		table_ct[5].data = &net->ct.expect_max;
+		table_nf[1].data = &net->ct.max;
+	}
+	net->ct.sysctl_header =
+		register_net_sysctl_table(net, nf_ct_path, table_nf);
+	if (net->ct.sysctl_header == NULL) {
 		printk("nf_conntrack: can't register to sysctl.\n");
-		return -ENOMEM;
+		goto out_register;
 	}
 	return 0;
 
+out_register:
+	if (net != &init_net)
+		kfree(table_ct);
+out_kmemdup_ct:
+	if (net != &init_net)
+		kfree(table_nf);
+out_kmemdup_nf:
+	return -ENOMEM;
 }
 
-static void nf_conntrack_standalone_fini_sysctl(void)
+static void nf_conntrack_standalone_fini_sysctl(struct net *net)
 {
-	unregister_sysctl_table(nf_ct_sysctl_header);
+	struct ctl_table *table_nf, *table_ct;
+
+	table_nf = net->ct.sysctl_header->ctl_table_arg;
+	table_ct = table_nf->child;
+	unregister_net_sysctl_table(net->ct.sysctl_header);
+	if (net != &init_net) {
+		kfree(table_ct);
+		kfree(table_nf);
+	}
 }
 #else
-static int nf_conntrack_standalone_init_sysctl(void)
+static int nf_conntrack_standalone_init_sysctl(struct net *net)
 {
 	return 0;
 }
 
-static void nf_conntrack_standalone_fini_sysctl(void)
+static void nf_conntrack_standalone_fini_sysctl(struct net *net)
 {
 }
 #endif /* CONFIG_SYSCTL */
@@ -459,8 +493,13 @@ static int nf_conntrack_net_init(struct net *net)
 	ret = nf_conntrack_standalone_init_proc(net);
 	if (ret < 0)
 		goto out_proc;
+	ret = nf_conntrack_standalone_init_sysctl(net);
+	if (ret < 0)
+		goto out_sysctl;
 	return 0;
 
+out_sysctl:
+	nf_conntrack_standalone_fini_proc(net);
 out_proc:
 	nf_conntrack_cleanup(net);
 out_init:
@@ -469,6 +508,7 @@ out_init:
 
 static void nf_conntrack_net_exit(struct net *net)
 {
+	nf_conntrack_standalone_fini_sysctl(net);
 	nf_conntrack_standalone_fini_proc(net);
 	nf_conntrack_cleanup(net);
 }
@@ -480,25 +520,11 @@ static struct pernet_operations nf_conntrack_net_ops = {
 
 static int __init nf_conntrack_standalone_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&nf_conntrack_net_ops);
-	if (ret < 0)
-		goto out;
-	ret = nf_conntrack_standalone_init_sysctl();
-	if (ret < 0)
-		goto out_sysctl;
-	return 0;
-
-out_sysctl:
-	unregister_pernet_subsys(&nf_conntrack_net_ops);
-out:
-	return ret;
+	return register_pernet_subsys(&nf_conntrack_net_ops);
 }
 
 static void __exit nf_conntrack_standalone_fini(void)
 {
-	nf_conntrack_standalone_fini_sysctl();
 	unregister_pernet_subsys(&nf_conntrack_net_ops);
 }
 
-- 
1.5.4.5


