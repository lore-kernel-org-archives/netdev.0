From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 13/24] sysctl: cookie: share nf_ct_sysctl_table between nets
Date: Sat,  2 Apr 2011 04:53:27 +0200
Message-ID: <b8987bfb42921de6d648bc58456441fc41322287.1301711868.git.lucian.grijincu__24502.7297678918$1301713080$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32917 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab1DBCyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:40 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, minor reordering at unregister: unregister sysctls in reverse order of registering.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/netfilter/nf_conntrack_standalone.c |   30 ++++++------------------------
 1 files changed, 6 insertions(+), 24 deletions(-)

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 0ae1428..42b8c3b 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -420,28 +420,28 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.data		= &init_net.ct.count,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname       = "nf_conntrack_buckets",
 		.data           = &init_net.ct.htable_size,
 		.maxlen         = sizeof(unsigned int),
 		.mode           = 0444,
-		.proc_handler   = proc_dointvec,
+		.proc_handler   = netns_proc_dointvec,
 	},
 	{
 		.procname	= "nf_conntrack_checksum",
 		.data		= &init_net.ct.sysctl_checksum,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "nf_conntrack_log_invalid",
 		.data		= &init_net.ct.sysctl_log_invalid,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
+		.proc_handler	= netns_proc_dointvec_minmax,
 		.extra1		= &log_invalid_proto_min,
 		.extra2		= &log_invalid_proto_max,
 	},
@@ -475,8 +475,6 @@ static struct ctl_path nf_ct_path[] = {
 
 static int nf_conntrack_standalone_init_sysctl(struct net *net)
 {
-	struct ctl_table *table;
-
 	if (net_eq(net, &init_net)) {
 		nf_ct_netfilter_header =
 		       register_sysctl_paths(nf_ct_path, nf_ct_netfilter_table);
@@ -484,26 +482,14 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 			goto out;
 	}
 
-	table = kmemdup(nf_ct_sysctl_table, sizeof(nf_ct_sysctl_table),
-			GFP_KERNEL);
-	if (!table)
-		goto out_kmemdup;
-
-	table[1].data = &net->ct.count;
-	table[2].data = &net->ct.htable_size;
-	table[3].data = &net->ct.sysctl_checksum;
-	table[4].data = &net->ct.sysctl_log_invalid;
-
 	net->ct.sysctl_header = register_net_sysctl_table(net,
-					nf_net_netfilter_sysctl_path, table);
+			nf_net_netfilter_sysctl_path, nf_ct_sysctl_table);
 	if (!net->ct.sysctl_header)
 		goto out_unregister_netfilter;
 
 	return 0;
 
 out_unregister_netfilter:
-	kfree(table);
-out_kmemdup:
 	if (net_eq(net, &init_net))
 		unregister_sysctl_table(nf_ct_netfilter_header);
 out:
@@ -513,13 +499,9 @@ out:
 
 static void nf_conntrack_standalone_fini_sysctl(struct net *net)
 {
-	struct ctl_table *table;
-
+	unregister_net_sysctl_table(net->ct.sysctl_header);
 	if (net_eq(net, &init_net))
 		unregister_sysctl_table(nf_ct_netfilter_header);
-	table = net->ct.sysctl_header->ctl_table_arg;
-	unregister_net_sysctl_table(net->ct.sysctl_header);
-	kfree(table);
 }
 #else
 static int nf_conntrack_standalone_init_sysctl(struct net *net)
-- 
1.7.5.rc0

