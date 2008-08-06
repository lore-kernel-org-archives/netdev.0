From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] AX.25: Fix sysctl registration if
	!CONFIG_AX25_DAMA_SLAVE
Date: Wed, 6 Aug 2008 02:59:50 +0100
Message-ID: <20080806015950.GM28946@ZenIV.linux.org.uk>
References: <20080805223736.GA16608@linux-mips.org> <20080805.184737.158103058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralf@linux-mips.org, stable@kernel.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, thomas@osterried.de,
	jann@linux-mips.org, dl5di@gmx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54082 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755840AbYHFB74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 21:59:56 -0400
Content-Disposition: inline
In-Reply-To: <20080805.184737.158103058.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 06:47:37PM -0700, David Miller wrote:
> From: Ralf Baechle <ralf@linux-mips.org>
> Date: Tue, 5 Aug 2008 23:37:36 +0100
> 
> > Since 49ffcf8f99e8d33ec8afb450956804af518fd788
> > setting struct ctl_table.procname = NULL does no longer work as it used to
> > the way the AX.25 code is expecting it to resulting in the AX.25 sysctl
> > registration code to break if CONFIG_AX25_DAMA_SLAVE was not set as in some
> > distribution kernels.  Kernel releases from 2.6.24 are affected.
> > 
> > Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> Applied, and I'll queue it up for -stable too.

BTW, here's netfilter sysctl one:

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 292fa28..655d743 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -264,6 +264,12 @@ EXPORT_SYMBOL(proc_net_netfilter);
 void __init netfilter_init(void)
 {
 	int i, h;
+
+#ifdef CONFIG_SYSCTL
+	static struct ctl_table empty[1];
+	register_sysctl_paths(nf_net_netfilter_sysctl_path, empty);
+#endif
+
 	for (i = 0; i < NPROTO; i++) {
 		for (h = 0; h < NF_MAX_HOOKS; h++)
 			INIT_LIST_HEAD(&nf_hooks[i][h]);
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 869ef93..deddf21 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -324,6 +324,7 @@ static int log_invalid_proto_min = 0;
 static int log_invalid_proto_max = 255;
 
 static struct ctl_table_header *nf_ct_sysctl_header;
+static struct ctl_table_header *nf_ct_sysctl_netfilter_header;
 
 static ctl_table nf_ct_sysctl_table[] = {
 	{
@@ -384,12 +385,6 @@ static ctl_table nf_ct_sysctl_table[] = {
 
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
@@ -409,19 +404,28 @@ EXPORT_SYMBOL_GPL(nf_ct_log_invalid);
 
 static int nf_conntrack_standalone_init_sysctl(void)
 {
-	nf_ct_sysctl_header =
+	nf_ct_sysctl_netfilter_header =
 		register_sysctl_paths(nf_ct_path, nf_ct_netfilter_table);
-	if (nf_ct_sysctl_header == NULL) {
-		printk("nf_conntrack: can't register to sysctl.\n");
-		return -ENOMEM;
-	}
+	if (!nf_ct_sysctl_netfilter_header)
+		goto out;
+	nf_ct_sysctl_header =
+		register_sysctl_paths(nf_net_netfilter_sysctl_path,
+					nf_ct_sysctl_table);
+	if (!nf_ct_sysctl_header)
+		goto out1;
 	return 0;
 
+out1:
+	unregister_sysctl_table(nf_ct_sysctl_netfilter_header);
+out:
+	printk("nf_conntrack: can't register to sysctl.\n");
+	return -ENOMEM;
 }
 
 static void nf_conntrack_standalone_fini_sysctl(void)
 {
 	unregister_sysctl_table(nf_ct_sysctl_header);
+	unregister_sysctl_table(nf_ct_sysctl_netfilter_header);
 }
 #else
 static int nf_conntrack_standalone_init_sysctl(void)
