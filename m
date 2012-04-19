From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 12/19] net neighbour:  Convert to use register_net_sysctl
Date: Thu, 19 Apr 2012 16:38:03 -0700
Message-ID: <m1ehrjfg2s.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53256 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314Ab2DSXeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:34:05 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Using an ascii path to register_net_sysctl as opposed to the slightly
awkward ctl_path allows for much simpler code.

We no longer need to malloc dev_name to keep it alive the length of our
sysctl register instead we can use a small temporary buffer on the
stack.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/neighbour.c |   33 ++++++---------------------------
 1 files changed, 6 insertions(+), 27 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 0c2df3d..fadaa81 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2799,7 +2799,6 @@ enum {
 static struct neigh_sysctl_table {
 	struct ctl_table_header *sysctl_header;
 	struct ctl_table neigh_vars[NEIGH_VAR_MAX + 1];
-	char *dev_name;
 } neigh_sysctl_template __read_mostly = {
 	.neigh_vars = {
 		[NEIGH_VAR_MCAST_PROBE] = {
@@ -2925,19 +2924,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 {
 	struct neigh_sysctl_table *t;
 	const char *dev_name_source = NULL;
-
-#define NEIGH_CTL_PATH_ROOT	0
-#define NEIGH_CTL_PATH_PROTO	1
-#define NEIGH_CTL_PATH_NEIGH	2
-#define NEIGH_CTL_PATH_DEV	3
-
-	struct ctl_path neigh_path[] = {
-		{ .procname = "net",	 },
-		{ .procname = "proto",	 },
-		{ .procname = "neigh",	 },
-		{ .procname = "default", },
-		{ },
-	};
+	char neigh_path[ sizeof("net//neigh/") + IFNAMSIZ + IFNAMSIZ ];
 
 	t = kmemdup(&neigh_sysctl_template, sizeof(*t), GFP_KERNEL);
 	if (!t)
@@ -2965,7 +2952,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 		memset(&t->neigh_vars[NEIGH_VAR_GC_INTERVAL], 0,
 		       sizeof(t->neigh_vars[NEIGH_VAR_GC_INTERVAL]));
 	} else {
-		dev_name_source = neigh_path[NEIGH_CTL_PATH_DEV].procname;
+		dev_name_source = "default";
 		t->neigh_vars[NEIGH_VAR_GC_INTERVAL].data = (int *)(p + 1);
 		t->neigh_vars[NEIGH_VAR_GC_THRESH1].data = (int *)(p + 1) + 1;
 		t->neigh_vars[NEIGH_VAR_GC_THRESH2].data = (int *)(p + 1) + 2;
@@ -2988,23 +2975,16 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].extra1 = dev;
 	}
 
-	t->dev_name = kstrdup(dev_name_source, GFP_KERNEL);
-	if (!t->dev_name)
-		goto free;
-
-	neigh_path[NEIGH_CTL_PATH_DEV].procname = t->dev_name;
-	neigh_path[NEIGH_CTL_PATH_PROTO].procname = p_name;
-
+	snprintf(neigh_path, sizeof(neigh_path), "net/%s/neigh/%s",
+		p_name, dev_name_source);
 	t->sysctl_header =
-		register_net_sysctl_table(neigh_parms_net(p), neigh_path, t->neigh_vars);
+		register_net_sysctl(neigh_parms_net(p), neigh_path, t->neigh_vars);
 	if (!t->sysctl_header)
-		goto free_procname;
+		goto free;
 
 	p->sysctl_table = t;
 	return 0;
 
-free_procname:
-	kfree(t->dev_name);
 free:
 	kfree(t);
 err:
@@ -3018,7 +2998,6 @@ void neigh_sysctl_unregister(struct neigh_parms *p)
 		struct neigh_sysctl_table *t = p->sysctl_table;
 		p->sysctl_table = NULL;
 		unregister_net_sysctl_table(t->sysctl_header);
-		kfree(t->dev_name);
 		kfree(t);
 	}
 }
-- 
1.7.2.5
