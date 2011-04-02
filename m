From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 15/24] sysctl: cookie: share xfrm_table between nets
Date: Sat,  2 Apr 2011 04:53:29 +0200
Message-ID: <01493b74f7d705e8dbfbf90ccdc4e9e20aa1ae0a.1301711868.git.lucian.grijincu__12118.1956179955$1301713071$gmane$org@gmail.com>
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
	with ESMTP id S1755394Ab1DBCyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:45 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/xfrm/xfrm_sysctl.c |   37 +++++++++++--------------------------
 1 files changed, 11 insertions(+), 26 deletions(-)

diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
index 05640bc..9ca4e05 100644
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -15,63 +15,48 @@ static void __net_init __xfrm_sysctl_init(struct net *net)
 static struct ctl_table xfrm_table[] = {
 	{
 		.procname	= "xfrm_aevent_etime",
+		.data		= &init_net.xfrm.sysctl_aevent_etime,
 		.maxlen		= sizeof(u32),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "xfrm_aevent_rseqth",
+		.data		= &init_net.xfrm.sysctl_aevent_rseqth,
 		.maxlen		= sizeof(u32),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "xfrm_larval_drop",
+		.data		= &init_net.xfrm.sysctl_larval_drop,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "xfrm_acq_expires",
+		.data		= &init_net.xfrm.sysctl_acq_expires,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{}
 };
 
 int __net_init xfrm_sysctl_init(struct net *net)
 {
-	struct ctl_table *table;
-
 	__xfrm_sysctl_init(net);
-
-	table = kmemdup(xfrm_table, sizeof(xfrm_table), GFP_KERNEL);
-	if (!table)
-		goto out_kmemdup;
-	table[0].data = &net->xfrm.sysctl_aevent_etime;
-	table[1].data = &net->xfrm.sysctl_aevent_rseqth;
-	table[2].data = &net->xfrm.sysctl_larval_drop;
-	table[3].data = &net->xfrm.sysctl_acq_expires;
-
-	net->xfrm.sysctl_hdr = register_net_sysctl_table(net, net_core_path, table);
+	net->xfrm.sysctl_hdr = register_net_sysctl_table(net,
+				 net_core_path, xfrm_table);
 	if (!net->xfrm.sysctl_hdr)
-		goto out_register;
+		return -ENOMEM;
 	return 0;
-
-out_register:
-	kfree(table);
-out_kmemdup:
-	return -ENOMEM;
 }
 
 void __net_exit xfrm_sysctl_fini(struct net *net)
 {
-	struct ctl_table *table;
-
-	table = net->xfrm.sysctl_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->xfrm.sysctl_hdr);
-	kfree(table);
 }
 #else
 int __net_init xfrm_sysctl_init(struct net *net)
-- 
1.7.5.rc0

