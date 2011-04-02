From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 06/24] sysctl: cookie: share netns_core_table between nets
Date: Sat,  2 Apr 2011 04:53:20 +0200
Message-ID: <d94e115426f8053c5ff5cd8a61149fbbe781f7c6.1301711868.git.lucian.grijincu__12403.5242166885$1301713196$gmane$org@gmail.com>
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
	with ESMTP id S1754312Ab1DBCyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:22 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/core/sysctl_net_core.c |   28 +++-------------------------
 1 files changed, 3 insertions(+), 25 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 923ae0f..c4571cc 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -183,7 +183,7 @@ static struct ctl_table netns_core_table[] = {
 		.data		= &init_net.core.sysctl_somaxconn,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{ }
 };
@@ -196,41 +196,19 @@ __net_initdata struct ctl_path net_core_path[] = {
 
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
1.7.5.rc0

