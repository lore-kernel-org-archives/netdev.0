From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 12/24] sysctl: cookie: share event_sysctl_table between nets
Date: Sat,  2 Apr 2011 04:53:26 +0200
Message-ID: <561af9ebd11c312e98bfa237479c251140718740.1301711868.git.lucian.grijincu__18130.7324477986$1301713139$gmane$org@gmail.com>
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
	with ESMTP id S1755476Ab1DBCyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:38 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/netfilter/nf_conntrack_ecache.c |   30 +++++-------------------------
 1 files changed, 5 insertions(+), 25 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 63a1b91..b799e9e 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -163,14 +163,14 @@ static struct ctl_table event_sysctl_table[] = {
 		.data		= &init_net.ct.sysctl_events,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "nf_conntrack_events_retry_timeout",
 		.data		= &init_net.ct.sysctl_events_retry_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
+		.proc_handler	= netns_proc_dointvec_jiffies,
 	},
 	{}
 };
@@ -185,38 +185,18 @@ static struct nf_ct_ext_type event_extend __read_mostly = {
 #ifdef CONFIG_SYSCTL
 static int nf_conntrack_event_init_sysctl(struct net *net)
 {
-	struct ctl_table *table;
-
-	table = kmemdup(event_sysctl_table, sizeof(event_sysctl_table),
-			GFP_KERNEL);
-	if (!table)
-		goto out;
-
-	table[0].data = &net->ct.sysctl_events;
-	table[1].data = &net->ct.sysctl_events_retry_timeout;
-
-	net->ct.event_sysctl_header =
-		register_net_sysctl_table(net,
-					  nf_net_netfilter_sysctl_path, table);
+	net->ct.event_sysctl_header = register_net_sysctl_table(net,
+			  nf_net_netfilter_sysctl_path, event_sysctl_table);
 	if (!net->ct.event_sysctl_header) {
 		printk(KERN_ERR "nf_ct_event: can't register to sysctl.\n");
-		goto out_register;
+		return -ENOMEM;
 	}
 	return 0;
-
-out_register:
-	kfree(table);
-out:
-	return -ENOMEM;
 }
 
 static void nf_conntrack_event_fini_sysctl(struct net *net)
 {
-	struct ctl_table *table;
-
-	table = net->ct.event_sysctl_header->ctl_table_arg;
 	unregister_net_sysctl_table(net->ct.event_sysctl_header);
-	kfree(table);
 }
 #else
 static int nf_conntrack_event_init_sysctl(struct net *net)
-- 
1.7.5.rc0

