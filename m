From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 6/9] sysctl: route: share ipv4_route_flush_table between nets
Date: Fri, 25 Feb 2011 20:52:38 +0200
Message-ID: <1298659961-23863-7-git-send-email-lucian.grijincu@gmail.com>
References: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>, netdev@vger.kernel.org,
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/route.c |   36 +++++++-----------------------------
 1 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6ed6603..8fd0208 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3038,19 +3038,18 @@ void ip_rt_multicast_event(struct in_device *in_dev)
 
 #ifdef CONFIG_SYSCTL
 static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
-					void __user *buffer,
-					size_t *lenp, loff_t *ppos)
+				     void __user *buffer,
+				     size_t *lenp, loff_t *ppos, void *cookie)
 {
 	if (write) {
 		int flush_delay;
 		ctl_table ctl;
-		struct net *net;
+		struct net *net = (struct net *) cookie;
 
 		memcpy(&ctl, __ctl, sizeof(ctl));
 		ctl.data = &flush_delay;
 		proc_dointvec(&ctl, write, buffer, lenp, ppos);
 
-		net = (struct net *)__ctl->extra1;
 		rt_cache_flush(net, flush_delay);
 		return 0;
 	}
@@ -3191,7 +3190,7 @@ static struct ctl_table ipv4_route_flush_table[] = {
 		.procname	= "flush",
 		.maxlen		= sizeof(int),
 		.mode		= 0200,
-		.proc_handler	= ipv4_sysctl_rtcache_flush,
+		.proc_handler	= (proc_handler *) ipv4_sysctl_rtcache_flush,
 	},
 	{ },
 };
@@ -3205,37 +3204,16 @@ static __net_initdata struct ctl_path ipv4_route_path[] = {
 
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
1.7.4.rc1.7.g2cf08.dirty
