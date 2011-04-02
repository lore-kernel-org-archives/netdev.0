From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 05/24] sysctl: cookie: share ip4_frags_ns_ctl_table between nets
Date: Sat,  2 Apr 2011 04:53:19 +0200
Message-ID: <45aa3e8a8d47ba8bb697f430fa4e070835b22b96.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40187 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184Ab1DBCyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:20 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were creating a copy of this table was to set ctl_table->data to
point to data from within the newly created 'struct net*'.

The netns_proc_* handlers do this dynamically.

Also change register_net_sysctl_table() to send the net as a cookie.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/ip_fragment.c |   34 ++++++----------------------------
 net/sysctl_net.c       |    2 +-
 2 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a1151b8..f8fd613 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -677,21 +677,21 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv4.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec
 	},
 	{
 		.procname	= "ipfrag_low_thresh",
 		.data		= &init_net.ipv4.frags.low_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec
 	},
 	{
 		.procname	= "ipfrag_time",
 		.data		= &init_net.ipv4.frags.timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
+		.proc_handler	= netns_proc_dointvec_jiffies,
 	},
 	{ }
 };
@@ -717,41 +717,19 @@ static struct ctl_table ip4_frags_ctl_table[] = {
 
 static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 {
-	struct ctl_table *table;
 	struct ctl_table_header *hdr;
-
-	table = ip4_frags_ns_ctl_table;
-	if (!net_eq(net, &init_net)) {
-		table = kmemdup(table, sizeof(ip4_frags_ns_ctl_table), GFP_KERNEL);
-		if (table == NULL)
-			goto err_alloc;
-
-		table[0].data = &net->ipv4.frags.high_thresh;
-		table[1].data = &net->ipv4.frags.low_thresh;
-		table[2].data = &net->ipv4.frags.timeout;
-	}
-
-	hdr = register_net_sysctl_table(net, net_ipv4_ctl_path, table);
+	hdr = register_net_sysctl_table(net, net_ipv4_ctl_path,
+					ip4_frags_ns_ctl_table);
 	if (hdr == NULL)
-		goto err_reg;
+		return -ENOMEM;
 
 	net->ipv4.frags_hdr = hdr;
 	return 0;
-
-err_reg:
-	if (!net_eq(net, &init_net))
-		kfree(table);
-err_alloc:
-	return -ENOMEM;
 }
 
 static void __net_exit ip4_frags_ns_ctl_unregister(struct net *net)
 {
-	struct ctl_table *table;
-
-	table = net->ipv4.frags_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->ipv4.frags_hdr);
-	kfree(table);
 }
 
 static void ip4_frags_ctl_register(void)
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index dfff9a3..7447d6e 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -110,7 +110,7 @@ struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	namespaces = *current->nsproxy;
 	namespaces.net_ns = net;
 	return __register_sysctl_paths(&net_sysctl_root, &namespaces, path,
-				       table, NULL);
+				       table, net);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_table);
 
-- 
1.7.5.rc0

