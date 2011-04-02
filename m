From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 09/24] sysctl: cookie: share ip6_frags_ns_ctl_table between nets
Date: Sat,  2 Apr 2011 04:53:23 +0200
Message-ID: <f415165e7e814190b379e6005ec8a305b151e415.1301711868.git.lucian.grijincu__25405.2654411227$1301713160$gmane$org@gmail.com>
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
	with ESMTP id S1755111Ab1DBCya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:30 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv6/reassembly.c |   34 ++++++----------------------------
 1 files changed, 6 insertions(+), 28 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 07beeb0..405dc11 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -600,21 +600,21 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv6.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "ip6frag_low_thresh",
 		.data		= &init_net.ipv6.frags.low_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "ip6frag_time",
 		.data		= &init_net.ipv6.frags.timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
+		.proc_handler	= netns_proc_dointvec_jiffies,
 	},
 	{ }
 };
@@ -632,42 +632,20 @@ static struct ctl_table ip6_frags_ctl_table[] = {
 
 static int __net_init ip6_frags_ns_sysctl_register(struct net *net)
 {
-	struct ctl_table *table;
 	struct ctl_table_header *hdr;
 
-	table = ip6_frags_ns_ctl_table;
-	if (!net_eq(net, &init_net)) {
-		table = kmemdup(table, sizeof(ip6_frags_ns_ctl_table), GFP_KERNEL);
-		if (table == NULL)
-			goto err_alloc;
-
-		table[0].data = &net->ipv6.frags.high_thresh;
-		table[1].data = &net->ipv6.frags.low_thresh;
-		table[2].data = &net->ipv6.frags.timeout;
-	}
-
-	hdr = register_net_sysctl_table(net, net_ipv6_ctl_path, table);
+	hdr = register_net_sysctl_table(net, net_ipv6_ctl_path,
+					ip6_frags_ns_ctl_table);
 	if (hdr == NULL)
-		goto err_reg;
+		return -ENOMEM;
 
 	net->ipv6.sysctl.frags_hdr = hdr;
 	return 0;
-
-err_reg:
-	if (!net_eq(net, &init_net))
-		kfree(table);
-err_alloc:
-	return -ENOMEM;
 }
 
 static void __net_exit ip6_frags_ns_sysctl_unregister(struct net *net)
 {
-	struct ctl_table *table;
-
-	table = net->ipv6.sysctl.frags_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->ipv6.sysctl.frags_hdr);
-	if (!net_eq(net, &init_net))
-		kfree(table);
 }
 
 static struct ctl_table_header *ip6_ctl_header;
-- 
1.7.5.rc0

