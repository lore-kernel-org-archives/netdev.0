From: Krzysztof Piotr Oledzki <ole@ans.pl>
Subject: [PATCH] netfilter: fix two recent sysctl problems
Date: Wed, 06 Aug 2008 05:08:31 +0200
Message-ID: <489915af.VNn/ufBuUNr78bc1%ole@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netfilter: fix two recent sysctl problems

Starting with 9043476f726802f4b00c96d0c4f418dde48d1304 we have two
netfilter releated problems:

 - WARNING: at kernel/sysctl.c:1966 unregister_sysctl_table+0xcc/0x103(),
   caused by wrong order of ini/fini calls

 - net.netfilter is duplicated and has truncated set of records

Thanks to very useful guidelines from Al Viro, this patch fixes both of them.

Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>

diff -Nur linux-2.6.27-rc1-orig/net/netfilter/nf_conntrack_core.c linux-2.6.27-rc1/net/netfilter/nf_conntrack_core.c
--- linux-2.6.27-rc1-orig/net/netfilter/nf_conntrack_core.c	2008-07-29 04:40:31.000000000 +0200
+++ linux-2.6.27-rc1/net/netfilter/nf_conntrack_core.c	2008-08-06 04:06:48.000000000 +0200
@@ -1032,10 +1032,10 @@
 	nf_ct_free_hashtable(nf_conntrack_hash, nf_conntrack_vmalloc,
 			     nf_conntrack_htable_size);
 
-	nf_conntrack_proto_fini();
-	nf_conntrack_helper_fini();
-	nf_conntrack_expect_fini();
 	nf_conntrack_acct_fini();
+	nf_conntrack_expect_fini();
+	nf_conntrack_helper_fini();
+	nf_conntrack_proto_fini();
 }
 
 struct hlist_head *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced)
diff -Nur linux-2.6.27-rc1-orig/net/netfilter/nf_conntrack_standalone.c linux-2.6.27-rc1/net/netfilter/nf_conntrack_standalone.c
--- linux-2.6.27-rc1-orig/net/netfilter/nf_conntrack_standalone.c	2008-07-29 04:40:31.000000000 +0200
+++ linux-2.6.27-rc1/net/netfilter/nf_conntrack_standalone.c	2008-08-06 04:44:13.000000000 +0200
@@ -324,6 +324,7 @@
 static int log_invalid_proto_max = 255;
 
 static struct ctl_table_header *nf_ct_sysctl_header;
+static struct ctl_table_header *nf_ct_netfilter_header;
 
 static ctl_table nf_ct_sysctl_table[] = {
 	{
@@ -384,12 +385,6 @@
 
 static ctl_table nf_ct_netfilter_table[] = {
 	{
-		.ctl_name	= NET_NETFILTER,
-		.procname	= "netfilter",
-		.mode		= 0555,
-		.child		= nf_ct_sysctl_table,
-	},
-	{
 		.ctl_name	= NET_NF_CONNTRACK_MAX,
 		.procname	= "nf_conntrack_max",
 		.data		= &nf_conntrack_max,
@@ -409,18 +404,29 @@
 
 static int nf_conntrack_standalone_init_sysctl(void)
 {
-	nf_ct_sysctl_header =
+	nf_ct_netfilter_header =
 		register_sysctl_paths(nf_ct_path, nf_ct_netfilter_table);
-	if (nf_ct_sysctl_header == NULL) {
-		printk("nf_conntrack: can't register to sysctl.\n");
-		return -ENOMEM;
-	}
+	if (!nf_ct_netfilter_header)
+		goto out;
+
+	nf_ct_sysctl_header =
+		 register_sysctl_paths(nf_net_netfilter_sysctl_path,
+					nf_ct_sysctl_table);
+	if (!nf_ct_sysctl_header)
+		goto out_unregister_netfilter;
+
 	return 0;
 
+out_unregister_netfilter:
+	unregister_sysctl_table(nf_ct_netfilter_header);
+out:
+	printk("nf_conntrack: can't register to sysctl.\n");
+	return -ENOMEM;
 }
 
 static void nf_conntrack_standalone_fini_sysctl(void)
 {
+	unregister_sysctl_table(nf_ct_netfilter_header);
 	unregister_sysctl_table(nf_ct_sysctl_header);
 }
 #else
