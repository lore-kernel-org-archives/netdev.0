From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 07/24] sysctl: cookie: share ipv4_route_flush_table between nets
Date: Sat,  2 Apr 2011 04:53:21 +0200
Message-ID: <f52d34fd4084fcdfed0450aa1c74fd09d3608518.1301711868.git.lucian.grijincu__5604.57123579017$1301713212$gmane$org@gmail.com>
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
	with ESMTP id S1754857Ab1DBCyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:25 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/route.c |   30 ++++--------------------------
 1 files changed, 4 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0c66ea6..1e99f01 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3015,13 +3015,12 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 	if (write) {
 		int flush_delay;
 		ctl_table ctl;
-		struct net *net;
+		struct net *net = (struct net *) cookie;
 
 		memcpy(&ctl, __ctl, sizeof(ctl));
 		ctl.data = &flush_delay;
 		proc_dointvec(&ctl, write, buffer, lenp, ppos, NULL);
 
-		net = (struct net *)__ctl->extra1;
 		rt_cache_flush(net, flush_delay);
 		return 0;
 	}
@@ -3176,37 +3175,16 @@ static __net_initdata struct ctl_path ipv4_route_path[] = {
 
 static __net_init int sysctl_route_net_init(struct net *net)
 {
-	struct ctl_table *tbl;
-
-	tbl = ipv4_route_flush_table;
-	if (!net_eq(net, &init_net)) {
-		tbl = kmemdup(tbl, sizeof(ipv4_route_flush_table), GFP_KERNEL);
-		if (tbl == NULL)
-			goto err_dup;
-	}
-	tbl[0].extra1 = net;
-
-	net->ipv4.route_hdr =
-		register_net_sysctl_table(net, ipv4_route_path, tbl);
+	net->ipv4.route_hdr = register_net_sysctl_table(net,
+				ipv4_route_path, ipv4_route_flush_table);
 	if (net->ipv4.route_hdr == NULL)
-		goto err_reg;
+		return -ENOMEM;
 	return 0;
-
-err_reg:
-	if (tbl != ipv4_route_flush_table)
-		kfree(tbl);
-err_dup:
-	return -ENOMEM;
 }
 
 static __net_exit void sysctl_route_net_exit(struct net *net)
 {
-	struct ctl_table *tbl;
-
-	tbl = net->ipv4.route_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->ipv4.route_hdr);
-	BUG_ON(tbl == ipv4_route_flush_table);
-	kfree(tbl);
 }
 
 static __net_initdata struct pernet_operations sysctl_route_ops = {
-- 
1.7.5.rc0

