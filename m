From: Jann Horn <jann@thejh.net>
Subject: [PATCH] net: explicitly whitelist sysctls for unpriv namespaces
Date: Sun, 18 Sep 2016 22:58:20 +0200
Message-ID: <1474232300-8423-1-git-send-email-jann@thejh.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thejh.net ([37.221.195.125]:46590 "EHLO thejh.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936667AbcIRU6e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 16:58:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were two net sysctls that could be written from unprivileged net
namespaces, but weren't actually namespaced.

To fix the existing issues and prevent stuff this from happening again in
the future, explicitly whitelist permitted sysctls.

Note: The current whitelist is "allow everything that was previously
accessible and that doesn't obviously modify global state".

On my system, this patch just removes the write permissions for
ipv4/netfilter/ip_conntrack_max, which would have been usable for a local
DoS. With a different config, the ipv4/vs/debug_level sysctl would also be
affected.

Maximum impact of this seems to be local DoS, and it's a fairly large
commit, so I'm sending this publicly directly.

An alternative (and much smaller) fix would be to just change the
permissions of the two files in question to be 0444 in non-privileged
namespaces, but I believe that this solution is slightly less error-prone.
If you think I should switch to the simple fix, let me know.

Signed-off-by: Jann Horn <jann@thejh.net>
---
 include/linux/sysctl.h                         |  1 +
 net/ax25/sysctl_net_ax25.c                     |  4 +++-
 net/ieee802154/6lowpan/reassembly.c            |  7 +++++--
 net/ipv4/devinet.c                             |  2 ++
 net/ipv4/ip_fragment.c                         | 10 ++++++---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  3 +++
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  2 ++
 net/ipv4/sysctl_net_ipv4.c                     |  4 +++-
 net/ipv4/xfrm4_policy.c                        |  1 +
 net/ipv6/addrconf.c                            |  1 +
 net/ipv6/icmp.c                                |  1 +
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  1 +
 net/ipv6/netfilter/nf_conntrack_reasm.c        |  7 +++++--
 net/ipv6/sysctl_net_ipv6.c                     | 23 ++++++++++++++-------
 net/ipv6/xfrm6_policy.c                        |  1 +
 net/mpls/af_mpls.c                             |  2 ++
 net/netfilter/ipvs/ip_vs_ctl.c                 | 26 ++++++++++++++++++++++++
 net/netfilter/nf_conntrack_proto_generic.c     |  2 ++
 net/netfilter/nf_conntrack_proto_sctp.c        | 16 +++++++++++++++
 net/netfilter/nf_conntrack_proto_tcp.c         | 26 ++++++++++++++++++++++++
 net/netfilter/nf_conntrack_proto_udp.c         |  4 ++++
 net/netfilter/nf_conntrack_proto_udplite.c     |  2 ++
 net/netfilter/nf_log.c                         |  1 +
 net/rds/tcp.c                                  |  2 ++
 net/sctp/sysctl.c                              |  4 +++-
 net/sysctl_net.c                               | 28 +++++++++++++++++---------
 26 files changed, 154 insertions(+), 27 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index a4f7203..c47c52d 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -116,6 +116,7 @@ struct ctl_table
 	struct ctl_table_poll *poll;
 	void *extra1;
 	void *extra2;
+	bool namespaced;		/* allow writes in unpriv netns? */
 };
 
 struct ctl_node {
diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index 919a5ce..8e6ab36 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -158,8 +158,10 @@ int ax25_register_dev_sysctl(ax25_dev *ax25_dev)
 	if (!table)
 		return -ENOMEM;
 
-	for (k = 0; k < AX25_MAX_VALUES; k++)
+	for (k = 0; k < AX25_MAX_VALUES; k++) {
 		table[k].data = &ax25_dev->values[k];
+		table[k].namespaced = true;
+	}
 
 	snprintf(path, sizeof(path), "net/ax25/%s", ax25_dev->dev->name);
 	ax25_dev->sysheader = register_net_sysctl(&init_net, path, table);
diff --git a/net/ieee802154/6lowpan/reassembly.c b/net/ieee802154/6lowpan/reassembly.c
index 30d875d..8a1d5b7 100644
--- a/net/ieee802154/6lowpan/reassembly.c
+++ b/net/ieee802154/6lowpan/reassembly.c
@@ -456,7 +456,8 @@ static struct ctl_table lowpan_frags_ns_ctl_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &init_net.ieee802154_lowpan.frags.low_thresh
+		.extra1		= &init_net.ieee802154_lowpan.frags.low_thresh,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "6lowpanfrag_low_thresh",
@@ -465,7 +466,8 @@ static struct ctl_table lowpan_frags_ns_ctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero,
-		.extra2		= &init_net.ieee802154_lowpan.frags.high_thresh
+		.extra2		= &init_net.ieee802154_lowpan.frags.high_thresh,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "6lowpanfrag_time",
@@ -473,6 +475,7 @@ static struct ctl_table lowpan_frags_ns_ctl_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 062a67c..8bbed18 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2166,6 +2166,7 @@ static int ipv4_doint_and_flush(struct ctl_table *ctl, int write,
 		.mode		= mval, \
 		.proc_handler	= proc, \
 		.extra1		= &ipv4_devconf, \
+		.namespaced	= true, \
 	}
 
 #define DEVINET_SYSCTL_RW_ENTRY(attr, name) \
@@ -2310,6 +2311,7 @@ static struct ctl_table ctl_forward_entry[] = {
 		.proc_handler	= devinet_sysctl_forward,
 		.extra1		= &ipv4_devconf,
 		.extra2		= &init_net,
+		.namespaced	= true,
 	},
 	{ },
 };
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index bbe7f72..49a62e0 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -729,7 +729,8 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &init_net.ipv4.frags.low_thresh
+		.extra1		= &init_net.ipv4.frags.low_thresh,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ipfrag_low_thresh",
@@ -738,7 +739,8 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero,
-		.extra2		= &init_net.ipv4.frags.high_thresh
+		.extra2		= &init_net.ipv4.frags.high_thresh,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ipfrag_time",
@@ -746,6 +748,7 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ipfrag_max_dist",
@@ -753,7 +756,8 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero
+		.extra1		= &zero,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index ae1a71a..8ade484 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -218,6 +218,7 @@ static struct ctl_table ip_ct_sysctl_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_buckets",
@@ -230,6 +231,7 @@ static struct ctl_table ip_ct_sysctl_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_log_invalid",
@@ -238,6 +240,7 @@ static struct ctl_table ip_ct_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &log_invalid_proto_min,
 		.extra2		= &log_invalid_proto_max,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index c567e1b..6d5be74 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -324,6 +324,7 @@ static struct ctl_table icmp_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
@@ -334,6 +335,7 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1cb67de..9791f69 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -987,8 +987,10 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 			goto err_alloc;
 
 		/* Update the variables to point into the current struct net */
-		for (i = 0; i < ARRAY_SIZE(ipv4_net_table) - 1; i++)
+		for (i = 0; i < ARRAY_SIZE(ipv4_net_table) - 1; i++) {
 			table[i].data += (void *)net - (void *)&init_net;
+			table[i].namespaced = true;
+		}
 	}
 
 	net->ipv4.ipv4_hdr = register_net_sysctl(net, "net/ipv4", table);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 41f5b50..be8436e 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -291,6 +291,7 @@ static struct ctl_table xfrm4_policy_table[] = {
 		.maxlen         = sizeof(int),
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
+		.namespaced     = true,
 	},
 	{ }
 };
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2f1f5d4..73b01c0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -6046,6 +6046,7 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		table[i].data += (char *)p - (char *)&ipv6_devconf;
 		table[i].extra1 = idev; /* embedded; no ref */
 		table[i].extra2 = net;
+		table[i].namespaced = true;
 	}
 
 	snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index bd59c34..8c5d737 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -1067,6 +1067,7 @@ static struct ctl_table ipv6_icmp_table_template[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_ms_jiffies,
+		.namespaced	= true,
 	},
 	{ },
 };
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 660bc10..4a45fd9 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -331,6 +331,7 @@ static struct ctl_table icmpv6_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index e4347ae..b09f454 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -72,6 +72,7 @@ static struct ctl_table nf_ct_frag6_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_frag6_low_thresh",
@@ -80,7 +81,8 @@ static struct ctl_table nf_ct_frag6_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero,
-		.extra2		= &init_net.nf_frag.frags.high_thresh
+		.extra2		= &init_net.nf_frag.frags.high_thresh,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_frag6_high_thresh",
@@ -88,7 +90,8 @@ static struct ctl_table nf_ct_frag6_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &init_net.nf_frag.frags.low_thresh
+		.extra1		= &init_net.nf_frag.frags.low_thresh,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 69c50e7..9e482a2 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -30,21 +30,24 @@ static struct ctl_table ipv6_table_template[] = {
 		.data		= &init_net.ipv6.sysctl.bindv6only,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "anycast_src_echo_reply",
 		.data		= &init_net.ipv6.sysctl.anycast_src_echo_reply,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "flowlabel_consistency",
 		.data		= &init_net.ipv6.sysctl.flowlabel_consistency,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "auto_flowlabels",
@@ -53,14 +56,16 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &auto_flowlabels_min,
-		.extra2		= &auto_flowlabels_max
+		.extra2		= &auto_flowlabels_max,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "fwmark_reflect",
 		.data		= &init_net.ipv6.sysctl.fwmark_reflect,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "idgen_retries",
@@ -68,6 +73,7 @@ static struct ctl_table ipv6_table_template[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "idgen_delay",
@@ -75,20 +81,23 @@ static struct ctl_table ipv6_table_template[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "flowlabel_state_ranges",
 		.data		= &init_net.ipv6.sysctl.flowlabel_state_ranges,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_nonlocal_bind",
 		.data		= &init_net.ipv6.sysctl.ip_nonlocal_bind,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 70a86ad..7cadc2e 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -321,6 +321,7 @@ static struct ctl_table xfrm6_policy_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler   = proc_dointvec,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 5c161e7..ce00a55 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -863,6 +863,7 @@ static const struct ctl_table mpls_dev_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 		.data		= MPLS_PERDEV_SYSCTL_OFFSET(input_enabled),
+		.namespaced	= true,
 	},
 	{ }
 };
@@ -1648,6 +1649,7 @@ static const struct ctl_table mpls_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= mpls_platform_labels,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c3c809b..0d325cf 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1734,24 +1734,28 @@ static struct ctl_table vs_vars[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "am_droprate",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "drop_entry",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "drop_packet",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
+		.namespaced	= true,
 	},
 #ifdef CONFIG_IP_VS_NFCT
 	{
@@ -1759,6 +1763,7 @@ static struct ctl_table vs_vars[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
+		.namespaced	= true,
 	},
 #endif
 	{
@@ -1766,72 +1771,84 @@ static struct ctl_table vs_vars[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "snat_reroute",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sync_version",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_do_sync_mode,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sync_ports",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_do_sync_ports,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sync_persist_mode",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sync_qlen_max",
 		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sync_sock_size",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "cache_bypass",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "expire_nodest_conn",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sloppy_tcp",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sloppy_sctp",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "expire_quiescent_template",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sync_threshold",
@@ -1839,12 +1856,14 @@ static struct ctl_table vs_vars[] = {
 			sizeof(((struct netns_ipvs *)0)->sysctl_sync_threshold),
 		.mode		= 0644,
 		.proc_handler	= proc_do_sync_threshold,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sync_refresh_period",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "sync_retries",
@@ -1853,42 +1872,49 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero,
 		.extra2		= &three,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nat_icmp_send",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "pmtu_disc",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "backup_only",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "conn_reuse_mode",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "schedule_icmp",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ignore_tunneled",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 86dc752..3f80df5 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -148,6 +148,7 @@ static struct ctl_table generic_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
@@ -158,6 +159,7 @@ static struct ctl_table generic_compat_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 1d7ab96..c260427 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -654,54 +654,63 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_cookie_wait",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_cookie_echoed",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_established",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_sent",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_recd",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_ack_sent",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_heartbeat_sent",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_heartbeat_acked",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
@@ -713,42 +722,49 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_cookie_wait",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_cookie_echoed",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_established",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_sent",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_recd",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_ack_sent",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 70c8381..2ca7d20 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1406,78 +1406,91 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_syn_recv",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_established",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_fin_wait",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_close_wait",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_last_ack",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_time_wait",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_close",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_max_retrans",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_unacknowledged",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_loose",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname       = "nf_conntrack_tcp_be_liberal",
 		.maxlen         = sizeof(unsigned int),
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_max_retrans",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{ }
 };
@@ -1489,78 +1502,91 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_sent2",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_established",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_fin_wait",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_close_wait",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_last_ack",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_time_wait",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_close",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_max_retrans",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_loose",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_be_liberal",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_max_retrans",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 4fd0405..ab1773f 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -209,12 +209,14 @@ static struct ctl_table udp_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_udp_timeout_stream",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
@@ -225,12 +227,14 @@ static struct ctl_table udp_compat_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "ip_conntrack_udp_timeout_stream",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 9d692f5..17bb377 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -224,12 +224,14 @@ static struct ctl_table udplite_sysctl_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{
 		.procname	= "nf_conntrack_udplite_timeout_stream",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index aa5847a..78a69e2 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -481,6 +481,7 @@ static int netfilter_log_sysctl_init(struct net *net)
 				nf_log_proc_dostring;
 			nf_log_sysctl_table[i].extra1 =
 				(void *)(unsigned long) i;
+			nf_log_sysctl_table[i].namespaced = true;
 		}
 	}
 
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index fcddacc..74a73e8 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -68,6 +68,7 @@ static struct ctl_table rds_tcp_sysctl_table[] = {
 		.mode           = 0644,
 		.proc_handler   = rds_tcp_skbuf_handler,
 		.extra1		= &rds_tcp_min_sndbuf,
+		.namespaced	= true,
 	},
 #define	RDS_TCP_RCVBUF	1
 	{
@@ -77,6 +78,7 @@ static struct ctl_table rds_tcp_sysctl_table[] = {
 		.mode           = 0644,
 		.proc_handler   = rds_tcp_skbuf_handler,
 		.extra1		= &rds_tcp_min_rcvbuf,
+		.namespaced	= true,
 	},
 	{ }
 };
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index daf8554..5d676e8 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -473,8 +473,10 @@ int sctp_sysctl_net_register(struct net *net)
 	if (!table)
 		return -ENOMEM;
 
-	for (i = 0; table[i].data; i++)
+	for (i = 0; table[i].data; i++) {
 		table[i].data += (char *)(&net->sctp) - (char *)&init_net.sctp;
+		table[i].namespaced = true;
+	}
 
 	net->sctp.sysctl_header = register_net_sysctl(net, "net/sctp", table);
 	if (net->sctp.sysctl_header == NULL) {
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 46a71c7..dd6742b 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -45,16 +45,24 @@ static int net_ctl_permissions(struct ctl_table_header *head,
 	kuid_t root_uid = make_kuid(net->user_ns, 0);
 	kgid_t root_gid = make_kgid(net->user_ns, 0);
 
-	/* Allow network administrator to have same access as root. */
-	if (ns_capable_noaudit(net->user_ns, CAP_NET_ADMIN) ||
-	    uid_eq(root_uid, current_euid())) {
-		int mode = (table->mode >> 6) & 7;
-		return (mode << 6) | (mode << 3) | mode;
-	}
-	/* Allow netns root group to have the same access as the root group */
-	if (in_egroup_p(root_gid)) {
-		int mode = (table->mode >> 3) & 7;
-		return (mode << 3) | mode;
+	/* Allow network administrator to have same access as root - but only if
+	 * namespacing is implemented for this sysctl.
+	 */
+	if (table->namespaced) {
+		if (ns_capable_noaudit(net->user_ns, CAP_NET_ADMIN) ||
+		    uid_eq(root_uid, current_euid())) {
+			int mode = (table->mode >> 6) & 7;
+
+			return (mode << 6) | (mode << 3) | mode;
+		}
+		/* Allow netns root group to have the same access as the root
+		 * group.
+		 */
+		if (in_egroup_p(root_gid)) {
+			int mode = (table->mode >> 3) & 7;
+
+			return (mode << 3) | mode;
+		}
 	}
 	return table->mode;
 }
-- 
2.1.4
