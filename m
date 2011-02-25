From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 5/9] sysctl: net: share netns_core_table between nets
Date: Fri, 25 Feb 2011 20:52:37 +0200
Message-ID: <1298659961-23863-6-git-send-email-lucian.grijincu@gmail.com>
References: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>, netdev@vger.kernel.org,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:41821 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756562Ab1BYSxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 13:53:20 -0500
In-Reply-To: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/core/sysctl_net_core.c |   28 +++-------------------------
 1 files changed, 3 insertions(+), 25 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 385b609..e5a1544 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -182,7 +182,7 @@ static struct ctl_table netns_core_table[] = {
 		.data		= &init_net.core.sysctl_somaxconn,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{ }
 };
@@ -195,41 +195,19 @@ __net_initdata struct ctl_path net_core_path[] = {
 
 static __net_init int sysctl_core_net_init(struct net *net)
 {
-	struct ctl_table *tbl;
-
 	net->core.sysctl_somaxconn = SOMAXCONN;
 
-	tbl = netns_core_table;
-	if (!net_eq(net, &init_net)) {
-		tbl = kmemdup(tbl, sizeof(netns_core_table), GFP_KERNEL);
-		if (tbl == NULL)
-			goto err_dup;
-
-		tbl[0].data = &net->core.sysctl_somaxconn;
-	}
-
 	net->core.sysctl_hdr = register_net_sysctl_table(net,
-			net_core_path, tbl);
+			net_core_path, netns_core_table);
 	if (net->core.sysctl_hdr == NULL)
-		goto err_reg;
+		return -ENOMEM;
 
 	return 0;
-
-err_reg:
-	if (tbl != netns_core_table)
-		kfree(tbl);
-err_dup:
-	return -ENOMEM;
 }
 
 static __net_exit void sysctl_core_net_exit(struct net *net)
 {
-	struct ctl_table *tbl;
-
-	tbl = net->core.sysctl_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->core.sysctl_hdr);
-	BUG_ON(tbl == netns_core_table);
-	kfree(tbl);
 }
 
 static __net_initdata struct pernet_operations sysctl_core_ops = {
-- 
1.7.4.rc1.7.g2cf08.dirty

