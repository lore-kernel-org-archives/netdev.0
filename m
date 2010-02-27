From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 1/7 v2]IPv6:netfilter: defrag: Handle sysctls
 about IPv6 conntrack defragment per-netns
Date: Sat, 27 Feb 2010 14:39:53 +0800
Message-ID: <4B88BE39.6050307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52679 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753092Ab0B0Gjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 01:39:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register nf_conntrack_frag6_{timeout,high_thresh,low_thresh} sysctls per-netns.
nf_conntrack_frag6_timeout and ip6frag_time, nf_conntrack_frag6_low_thresh and ip6frag_low_thresh,
nf_conntrack_frag6_high_thresh and ip6frag_high_thresh, the three sets are equivalent.
The former sysctls are just an alias for he latter ones of IPv6.

More discussion about it, see http://marc.info/?l=netfilter-devel&m=126709777922959&w=2.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 Documentation/feature-removal-schedule.txt     |   19 +++++
 include/net/netns/ipv6.h                       |    1 +
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    4 -
 net/ipv6/netfilter/nf_conntrack_reasm.c        |   85 ++++++++++++++++++++++--
 4 files changed, 99 insertions(+), 10 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 721a2aa..127b6d6 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -531,3 +531,22 @@ Why:	udev fully replaces this special file system that only contains CAPI
 	NCCI TTY device nodes. User space (pppdcapiplugin) works without
 	noticing the difference.
 Who:	Jan Kiszka <jan.kiszka@web.de>
+
+---------------------------
+
+What:	- /proc/sys/net/netfilter/nf_conntrack_frag6_timeout
+	- /proc/sys/net/netfilter/nf_conntrack_frag6_high_thresh
+	- /proc/sys/net/netfilter/nf_conntrack_frag6_low_thresh
+When:	February 2011
+
+Why:	IPv6 conntrack defragment has introduced network name space, and shares
+	per-netns_frags with IPv6 stack. ip6frag_low_thresh, ip6frag_time and
+	ip6frag_high_thresh manage queue numbers and memory thresh size of
+	both IPv6 conntrack fragment queue and IPv6 stack fragment queue.
+	So nf_conntrack_frag6_timeout and ip6frag_time have the same effect,
+	nf_conntrack_frag6_low_thresh and ip6frag_low_thresh also have the same
+	effect, nf_conntrack_frag6_high_thresh and ip6frag_high_thresh too.
+	These there sysctls of IPv6 conntrack will be removed in the future,
+	please use those of IPv6.
+
+Who:	Shan Wei <shanwei@cn.fujitsu.com>
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 1f11ebc..e8fac24 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -14,6 +14,7 @@ struct netns_sysctl_ipv6 {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header *table;
 	struct ctl_table_header *frags_hdr;
+	struct ctl_table_header *nf_ct_frags_hdr;
 #endif
 	int bindv6only;
 	int flush_delay;
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 996c3f4..03a6b8d 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -387,10 +387,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
 	.nlattr_to_tuple	= ipv6_nlattr_to_tuple,
 	.nla_policy		= ipv6_nla_policy,
 #endif
-#ifdef CONFIG_SYSCTL
-	.ctl_table_path		= nf_net_netfilter_sysctl_path,
-	.ctl_table		= nf_ct_ipv6_sysctl_table,
-#endif
 	.me			= THIS_MODULE,
 };
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index f1171b7..6af4497 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -75,27 +75,88 @@ static struct netns_frags nf_init_frags;
 struct ctl_table nf_ct_ipv6_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_frag6_timeout",
-		.data		= &nf_init_frags.timeout,
-		.maxlen		= sizeof(unsigned int),
+		.data		= &init_net.ipv6.frags.timeout,
+		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_frag6_low_thresh",
-		.data		= &nf_init_frags.low_thresh,
-		.maxlen		= sizeof(unsigned int),
+		.data		= &init_net.ipv6.frags.low_thresh,
+		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "nf_conntrack_frag6_high_thresh",
-		.data		= &nf_init_frags.high_thresh,
-		.maxlen		= sizeof(unsigned int),
+		.data		= &init_net.ipv6.frags.high_thresh,
+		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
 	{ }
 };
+
+static const char SYSCTLS_WARN_INFO[] = "nf_conntrack_frag6_timeout and \
+ip6frag_time, nf_conntrack_frag6_low_thresh and ip6frag_low_thresh, \
+nf_conntrack_frag6_high_thresh and ip6frag_high_thresh, \
+the three sets are equivalent. nf_conntrack_frag6_timeout is just an alias \
+for ip6frag_time. The former parameters of IPv6 conntrack will be removed \
+in February 2011, please use the latter ones of IPv6.";
+
+static int nf_frags_init_net(struct net *net)
+{
+	struct ctl_table *table;
+	struct ctl_table_header *hdr;
+
+	table = nf_ct_ipv6_sysctl_table;
+	if (!net_eq(net, &init_net)) {
+		table = kmemdup(table, sizeof(nf_ct_ipv6_sysctl_table),
+				GFP_KERNEL);
+		if (table == NULL)
+			goto err_alloc;
+
+		table[0].data = &net->ipv6.frags.high_thresh;
+		table[1].data = &net->ipv6.frags.low_thresh;
+		table[2].data = &net->ipv6.frags.timeout;
+	}
+
+	hdr = register_net_sysctl_table(net, nf_net_netfilter_sysctl_path,
+					table);
+	if (hdr == NULL)
+		goto err_reg;
+
+	printk(KERN_WARNING "Netfilter:%s\n", SYSCTLS_WARN_INFO);
+
+	net->ipv6.sysctl.nf_ct_frags_hdr = hdr;
+	return 0;
+
+err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(table);
+err_alloc:
+	return -ENOMEM;
+}
+
+static void nf_frags_exit_net(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = net->ipv6.sysctl.nf_ct_frags_hdr->ctl_table_arg;
+	unregister_net_sysctl_table(net->ipv6.sysctl.nf_ct_frags_hdr);
+	if (!net_eq(net, &init_net))
+		kfree(table);
+}
+
+#else
+static int nf_frags_init_net(struct net *net)
+{
+	return 0;
+}
+
+static void nf_frags_exit_net(struct net *net)
+{
+}
 #endif
 
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
@@ -650,8 +711,19 @@ void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
 	nf_conntrack_put_reasm(skb);
 }
 
+static struct pernet_operations ip6_nf_frags_ops = {
+	.init = nf_frags_init_net,
+	.exit = nf_frags_exit_net,
+};
+
 int nf_ct_frag6_init(void)
 {
+	int ret;
+
+	ret = register_pernet_subsys(&ip6_nf_frags_ops);
+	if (ret)
+		return ret;
+
 	nf_frags.hashfn = nf_hashfn;
 	nf_frags.constructor = ip6_frag_init;
 	nf_frags.destructor = NULL;
@@ -675,4 +747,5 @@ void nf_ct_frag6_cleanup(void)
 
 	nf_init_frags.low_thresh = 0;
 	nf_ct_frag6_evictor();
+	unregister_pernet_subsys(&ip6_nf_frags_ops);
 }
-- 
1.6.3.3
