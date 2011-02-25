From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 4/9] sysctl: ipv4: ipfrag: share ip4_frags_ns_ctl_table between nets
Date: Fri, 25 Feb 2011 20:52:36 +0200
Message-ID: <1298659961-23863-5-git-send-email-lucian.grijincu@gmail.com>
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

The only reason we were creating a copy of this table was to set
->data to point to data from within the newly created net. The
netns_proc_* handlers do this dynamically.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/ip_fragment.c |   34 ++++++----------------------------
 net/sysctl_net.c       |    2 +-
 2 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a1151b8..ffca3cc 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -677,21 +677,21 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv4.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{
 		.procname	= "ipfrag_low_thresh",
 		.data		= &init_net.ipv4.frags.low_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= (proc_handler *) netns_proc_dointvec
 	},
 	{
 		.procname	= "ipfrag_time",
 		.data		= &init_net.ipv4.frags.timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
+		.proc_handler	= (proc_handler *) netns_proc_dointvec_jiffies,
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
index 60b36ad..d80e9c4 100644
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
1.7.4.rc1.7.g2cf08.dirty
