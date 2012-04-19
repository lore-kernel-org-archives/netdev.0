From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 05/19] net: Move all of the network sysctls without a namespace into init_net.
Date: Thu, 19 Apr 2012 16:24:33 -0700
Message-ID: <m1k41bgv9q.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:55891 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab2DSXUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:20:36 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This makes it clearer which sysctls are relative to your current network
namespace.

This makes it a little less error prone by not exposing sysctls for the
initial network namespace in other namespaces.

This is the same way we handle all of our other network interfaces to
userspace and I can't honestly remember why we didn't do this for
sysctls right from the start.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/infiniband/core/ucma.c          |    4 ++--
 net/802/tr.c                            |    2 +-
 net/appletalk/sysctl_net_atalk.c        |    4 ++--
 net/ax25/sysctl_net_ax25.c              |    4 ++--
 net/bridge/br_netfilter.c               |    4 ++--
 net/core/neighbour.c                    |    2 +-
 net/core/sysctl_net_core.c              |    2 +-
 net/dccp/sysctl.c                       |    4 ++--
 net/decnet/dn_dev.c                     |    4 ++--
 net/decnet/sysctl_net_decnet.c          |    4 ++--
 net/ipv4/netfilter/ip_queue.c           |    6 +++---
 net/ipv4/route.c                        |    2 +-
 net/ipv4/sysctl_net_ipv4.c              |    4 ++--
 net/ipv6/netfilter/ip6_queue.c          |    6 +++---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    4 ++--
 net/ipv6/sysctl_net_ipv6.c              |    2 +-
 net/ipx/sysctl_net_ipx.c                |    5 +++--
 net/irda/irsysctl.c                     |    4 ++--
 net/llc/sysctl_net_llc.c                |    5 +++--
 net/netfilter/nf_conntrack_proto.c      |    4 ++--
 net/netfilter/nf_conntrack_standalone.c |    6 +++---
 net/netfilter/nf_log.c                  |    2 +-
 net/netrom/sysctl_net_netrom.c          |    4 ++--
 net/phonet/sysctl.c                     |    4 ++--
 net/rds/ib_sysctl.c                     |    4 ++--
 net/rds/iw_sysctl.c                     |    4 ++--
 net/rds/sysctl.c                        |    4 ++--
 net/rose/sysctl_net_rose.c              |    4 ++--
 net/sctp/sysctl.c                       |    4 ++--
 net/unix/sysctl_net_unix.c              |    2 +-
 net/x25/sysctl_net_x25.c                |    4 ++--
 31 files changed, 60 insertions(+), 58 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 5861cdb..9f3e2be 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -1392,7 +1392,7 @@ static int __init ucma_init(void)
 		goto err1;
 	}
 
-	ucma_ctl_table_hdr = register_sysctl_paths(ucma_ctl_path, ucma_ctl_table);
+	ucma_ctl_table_hdr = register_net_sysctl_table(&init_net, ucma_ctl_path, ucma_ctl_table);
 	if (!ucma_ctl_table_hdr) {
 		printk(KERN_ERR "rdma_ucm: couldn't register sysctl paths\n");
 		ret = -ENOMEM;
@@ -1408,7 +1408,7 @@ err1:
 
 static void __exit ucma_cleanup(void)
 {
-	unregister_sysctl_table(ucma_ctl_table_hdr);
+	unregister_net_sysctl_table(ucma_ctl_table_hdr);
 	device_remove_file(ucma_misc.this_device, &dev_attr_abi_version);
 	misc_deregister(&ucma_misc);
 	idr_destroy(&ctx_idr);
diff --git a/net/802/tr.c b/net/802/tr.c
index e65f0b8..103e020 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -662,7 +662,7 @@ static int __init rif_init(void)
 	setup_timer(&rif_timer, rif_check_expire, 0);
 	add_timer(&rif_timer);
 #ifdef CONFIG_SYSCTL
-	register_sysctl_paths(tr_path, tr_table);
+	register_net_sysctl_table(&init_net, tr_path, tr_table);
 #endif
 	proc_net_fops_create(&init_net, "tr_rif", S_IRUGO, &rif_seq_fops);
 	return 0;
diff --git a/net/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net_atalk.c
index 04e9c0d..5edce8f 100644
--- a/net/appletalk/sysctl_net_atalk.c
+++ b/net/appletalk/sysctl_net_atalk.c
@@ -52,10 +52,10 @@ static struct ctl_table_header *atalk_table_header;
 
 void atalk_register_sysctl(void)
 {
-	atalk_table_header = register_sysctl_paths(atalk_path, atalk_table);
+	atalk_table_header = register_net_sysctl_table(&init_net, atalk_path, atalk_table);
 }
 
 void atalk_unregister_sysctl(void)
 {
-	unregister_sysctl_table(atalk_table_header);
+	unregister_net_sysctl_table(atalk_table_header);
 }
diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index ebe0ef3..7ba381b 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -196,13 +196,13 @@ void ax25_register_sysctl(void)
 	}
 	spin_unlock_bh(&ax25_dev_lock);
 
-	ax25_table_header = register_sysctl_paths(ax25_path, ax25_table);
+	ax25_table_header = register_net_sysctl_table(&init_net, ax25_path, ax25_table);
 }
 
 void ax25_unregister_sysctl(void)
 {
 	ctl_table *p;
-	unregister_sysctl_table(ax25_table_header);
+	unregister_net_sysctl_table(ax25_table_header);
 
 	for (p = ax25_table; p->procname; p++)
 		kfree(p->child);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index dec4f38..4f4c4a6 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -1030,7 +1030,7 @@ int __init br_netfilter_init(void)
 		return ret;
 	}
 #ifdef CONFIG_SYSCTL
-	brnf_sysctl_header = register_sysctl_paths(brnf_path, brnf_table);
+	brnf_sysctl_header = register_net_sysctl_table(&init_net, brnf_path, brnf_table);
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
@@ -1047,7 +1047,7 @@ void br_netfilter_fini(void)
 {
 	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
 #ifdef CONFIG_SYSCTL
-	unregister_sysctl_table(brnf_sysctl_header);
+	unregister_net_sysctl_table(brnf_sysctl_header);
 #endif
 	dst_entries_destroy(&fake_dst_ops);
 }
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 434eed8..0c2df3d 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -3017,7 +3017,7 @@ void neigh_sysctl_unregister(struct neigh_parms *p)
 	if (p->sysctl_table) {
 		struct neigh_sysctl_table *t = p->sysctl_table;
 		p->sysctl_table = NULL;
-		unregister_sysctl_table(t->sysctl_header);
+		unregister_net_sysctl_table(t->sysctl_header);
 		kfree(t->dev_name);
 		kfree(t);
 	}
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 9504086..dfe2885 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -256,7 +256,7 @@ static __init int sysctl_core_init(void)
 {
 	static struct ctl_table empty[1];
 
-	kmemleak_not_leak(register_sysctl_paths(net_core_path, empty));
+	kmemleak_not_leak(register_net_sysctl_table(&init_net, net_core_path, empty));
 	register_net_sysctl(&init_net, "net/core", net_core_table);
 	return register_pernet_subsys(&sysctl_core_ops);
 }
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index 4234882..329e139 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -109,7 +109,7 @@ static struct ctl_table_header *dccp_table_header;
 
 int __init dccp_sysctl_init(void)
 {
-	dccp_table_header = register_sysctl_paths(dccp_path,
+	dccp_table_header = register_net_sysctl_table(&init_net, dccp_path,
 			dccp_default_table);
 
 	return dccp_table_header != NULL ? 0 : -ENOMEM;
@@ -118,7 +118,7 @@ int __init dccp_sysctl_init(void)
 void dccp_sysctl_exit(void)
 {
 	if (dccp_table_header != NULL) {
-		unregister_sysctl_table(dccp_table_header);
+		unregister_net_sysctl_table(dccp_table_header);
 		dccp_table_header = NULL;
 	}
 }
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index a4aecb0..ce8a184 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -236,7 +236,7 @@ static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *
 
 	t->dn_dev_vars[0].extra1 = (void *)dev;
 
-	t->sysctl_header = register_sysctl_paths(dn_ctl_path, t->dn_dev_vars);
+	t->sysctl_header = register_net_sysctl_table(&init_net, dn_ctl_path, t->dn_dev_vars);
 	if (t->sysctl_header == NULL)
 		kfree(t);
 	else
@@ -248,7 +248,7 @@ static void dn_dev_sysctl_unregister(struct dn_dev_parms *parms)
 	if (parms->sysctl) {
 		struct dn_dev_sysctl_table *t = parms->sysctl;
 		parms->sysctl = NULL;
-		unregister_sysctl_table(t->sysctl_header);
+		unregister_net_sysctl_table(t->sysctl_header);
 		kfree(t);
 	}
 }
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index 02e75d1..4380b8e 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -359,12 +359,12 @@ static struct ctl_path dn_path[] = {
 
 void dn_register_sysctl(void)
 {
-	dn_table_header = register_sysctl_paths(dn_path, dn_table);
+	dn_table_header = register_net_sysctl_table(&init_net, dn_path, dn_table);
 }
 
 void dn_unregister_sysctl(void)
 {
-	unregister_sysctl_table(dn_table_header);
+	unregister_net_sysctl_table(dn_table_header);
 }
 
 #else  /* CONFIG_SYSCTL */
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 94d45e1..766485d 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -586,7 +586,7 @@ static int __init ip_queue_init(void)
 #endif
 	register_netdevice_notifier(&ipq_dev_notifier);
 #ifdef CONFIG_SYSCTL
-	ipq_sysctl_header = register_sysctl_paths(net_ipv4_ctl_path, ipq_table);
+	ipq_sysctl_header = register_net_sysctl_table(&init_net, net_ipv4_ctl_path, ipq_table);
 #endif
 	status = nf_register_queue_handler(NFPROTO_IPV4, &nfqh);
 	if (status < 0) {
@@ -597,7 +597,7 @@ static int __init ip_queue_init(void)
 
 cleanup_sysctl:
 #ifdef CONFIG_SYSCTL
-	unregister_sysctl_table(ipq_sysctl_header);
+	unregister_net_sysctl_table(ipq_sysctl_header);
 #endif
 	unregister_netdevice_notifier(&ipq_dev_notifier);
 	proc_net_remove(&init_net, IPQ_PROC_FS_NAME);
@@ -618,7 +618,7 @@ static void __exit ip_queue_fini(void)
 	ipq_flush(NULL, 0);
 
 #ifdef CONFIG_SYSCTL
-	unregister_sysctl_table(ipq_sysctl_header);
+	unregister_net_sysctl_table(ipq_sysctl_header);
 #endif
 	unregister_netdevice_notifier(&ipq_dev_notifier);
 	proc_net_remove(&init_net, IPQ_PROC_FS_NAME);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bcd4744..f9c474e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3514,6 +3514,6 @@ int __init ip_rt_init(void)
  */
 void __init ip_static_sysctl_init(void)
 {
-	kmemleak_not_leak(register_sysctl_paths(ipv4_path, ipv4_skeleton));
+	kmemleak_not_leak(register_net_sysctl_table(&init_net, ipv4_path, ipv4_skeleton));
 }
 #endif
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 34a6286..e7a6fa3 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -857,12 +857,12 @@ static __init int sysctl_ipv4_init(void)
 	if (!i->procname)
 		return -EINVAL;
 
-	hdr = register_sysctl_paths(net_ipv4_ctl_path, ipv4_table);
+	hdr = register_net_sysctl_table(&init_net, net_ipv4_ctl_path, ipv4_table);
 	if (hdr == NULL)
 		return -ENOMEM;
 
 	if (register_pernet_subsys(&ipv4_sysctl_ops)) {
-		unregister_sysctl_table(hdr);
+		unregister_net_sysctl_table(hdr);
 		return -ENOMEM;
 	}
 
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index a34c9e4..6785f50 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -588,7 +588,7 @@ static int __init ip6_queue_init(void)
 #endif
 	register_netdevice_notifier(&ipq_dev_notifier);
 #ifdef CONFIG_SYSCTL
-	ipq_sysctl_header = register_sysctl_paths(net_ipv6_ctl_path, ipq_table);
+	ipq_sysctl_header = register_net_sysctl_table(&init_net, net_ipv6_ctl_path, ipq_table);
 #endif
 	status = nf_register_queue_handler(NFPROTO_IPV6, &nfqh);
 	if (status < 0) {
@@ -599,7 +599,7 @@ static int __init ip6_queue_init(void)
 
 cleanup_sysctl:
 #ifdef CONFIG_SYSCTL
-	unregister_sysctl_table(ipq_sysctl_header);
+	unregister_net_sysctl_table(ipq_sysctl_header);
 #endif
 	unregister_netdevice_notifier(&ipq_dev_notifier);
 	proc_net_remove(&init_net, IPQ_PROC_FS_NAME);
@@ -621,7 +621,7 @@ static void __exit ip6_queue_fini(void)
 	ipq_flush(NULL, 0);
 
 #ifdef CONFIG_SYSCTL
-	unregister_sysctl_table(ipq_sysctl_header);
+	unregister_net_sysctl_table(ipq_sysctl_header);
 #endif
 	unregister_netdevice_notifier(&ipq_dev_notifier);
 	proc_net_remove(&init_net, IPQ_PROC_FS_NAME);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 38f00b0..7548144 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -626,7 +626,7 @@ int nf_ct_frag6_init(void)
 	inet_frags_init(&nf_frags);
 
 #ifdef CONFIG_SYSCTL
-	nf_ct_frag6_sysctl_header = register_sysctl_paths(nf_net_netfilter_sysctl_path,
+	nf_ct_frag6_sysctl_header = register_net_sysctl_table(&init_net, nf_net_netfilter_sysctl_path,
 							  nf_ct_frag6_sysctl_table);
 	if (!nf_ct_frag6_sysctl_header) {
 		inet_frags_fini(&nf_frags);
@@ -640,7 +640,7 @@ int nf_ct_frag6_init(void)
 void nf_ct_frag6_cleanup(void)
 {
 #ifdef CONFIG_SYSCTL
-	unregister_sysctl_table(nf_ct_frag6_sysctl_header);
+	unregister_net_sysctl_table(nf_ct_frag6_sysctl_header);
 	nf_ct_frag6_sysctl_header = NULL;
 #endif
 	inet_frags_fini(&nf_frags);
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 06f21e5..99279c8 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -165,7 +165,7 @@ static struct ctl_table_header *ip6_base;
 
 int ipv6_static_sysctl_register(void)
 {
-	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, ipv6_static_skeleton);
+	ip6_base = register_net_sysctl_table(&init_net, net_ipv6_ctl_path, ipv6_static_skeleton);
 	if (ip6_base == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/net/ipx/sysctl_net_ipx.c b/net/ipx/sysctl_net_ipx.c
index bd6dca0..0358807 100644
--- a/net/ipx/sysctl_net_ipx.c
+++ b/net/ipx/sysctl_net_ipx.c
@@ -8,6 +8,7 @@
 
 #include <linux/mm.h>
 #include <linux/sysctl.h>
+#include <net/net_namespace.h>
 
 #ifndef CONFIG_SYSCTL
 #error This file should not be compiled without CONFIG_SYSCTL defined
@@ -37,10 +38,10 @@ static struct ctl_table_header *ipx_table_header;
 
 void ipx_register_sysctl(void)
 {
-	ipx_table_header = register_sysctl_paths(ipx_path, ipx_table);
+	ipx_table_header = register_net_sysctl_table(&init_net, ipx_path, ipx_table);
 }
 
 void ipx_unregister_sysctl(void)
 {
-	unregister_sysctl_table(ipx_table_header);
+	unregister_net_sysctl_table(ipx_table_header);
 }
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index 2615ffc..20ced38 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -251,7 +251,7 @@ static struct ctl_table_header *irda_table_header;
  */
 int __init irda_sysctl_register(void)
 {
-	irda_table_header = register_sysctl_paths(irda_path, irda_table);
+	irda_table_header = register_net_sysctl_table(&init_net, irda_path, irda_table);
 	if (!irda_table_header)
 		return -ENOMEM;
 
@@ -266,7 +266,7 @@ int __init irda_sysctl_register(void)
  */
 void irda_sysctl_unregister(void)
 {
-	unregister_sysctl_table(irda_table_header);
+	unregister_net_sysctl_table(irda_table_header);
 }
 
 
diff --git a/net/llc/sysctl_net_llc.c b/net/llc/sysctl_net_llc.c
index e2ebe35..9a6a65f 100644
--- a/net/llc/sysctl_net_llc.c
+++ b/net/llc/sysctl_net_llc.c
@@ -7,6 +7,7 @@
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/sysctl.h>
+#include <net/net_namespace.h>
 #include <net/llc.h>
 
 #ifndef CONFIG_SYSCTL
@@ -89,7 +90,7 @@ static struct ctl_table_header *llc_table_header;
 
 int __init llc_sysctl_init(void)
 {
-	llc_table_header = register_sysctl_paths(llc_path, llc_table);
+	llc_table_header = register_net_sysctl_table(&init_net, llc_path, llc_table);
 
 	return llc_table_header ? 0 : -ENOMEM;
 }
@@ -97,7 +98,7 @@ int __init llc_sysctl_init(void)
 void llc_sysctl_exit(void)
 {
 	if (llc_table_header) {
-		unregister_sysctl_table(llc_table_header);
+		unregister_net_sysctl_table(llc_table_header);
 		llc_table_header = NULL;
 	}
 }
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index be3da2c..bbc753f 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -40,7 +40,7 @@ nf_ct_register_sysctl(struct ctl_table_header **header, struct ctl_path *path,
 		      struct ctl_table *table, unsigned int *users)
 {
 	if (*header == NULL) {
-		*header = register_sysctl_paths(path, table);
+		*header = register_net_sysctl_table(&init_net, path, table);
 		if (*header == NULL)
 			return -ENOMEM;
 	}
@@ -56,7 +56,7 @@ nf_ct_unregister_sysctl(struct ctl_table_header **header,
 	if (users != NULL && --*users > 0)
 		return;
 
-	unregister_sysctl_table(*header);
+	unregister_net_sysctl_table(*header);
 	*header = NULL;
 }
 #endif
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 885f5ab..0c3888d 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -479,7 +479,7 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 
 	if (net_eq(net, &init_net)) {
 		nf_ct_netfilter_header =
-		       register_sysctl_paths(nf_ct_path, nf_ct_netfilter_table);
+		       register_net_sysctl_table(&init_net, nf_ct_path, nf_ct_netfilter_table);
 		if (!nf_ct_netfilter_header)
 			goto out;
 	}
@@ -505,7 +505,7 @@ out_unregister_netfilter:
 	kfree(table);
 out_kmemdup:
 	if (net_eq(net, &init_net))
-		unregister_sysctl_table(nf_ct_netfilter_header);
+		unregister_net_sysctl_table(nf_ct_netfilter_header);
 out:
 	printk(KERN_ERR "nf_conntrack: can't register to sysctl.\n");
 	return -ENOMEM;
@@ -516,7 +516,7 @@ static void nf_conntrack_standalone_fini_sysctl(struct net *net)
 	struct ctl_table *table;
 
 	if (net_eq(net, &init_net))
-		unregister_sysctl_table(nf_ct_netfilter_header);
+		unregister_net_sysctl_table(nf_ct_netfilter_header);
 	table = net->ct.sysctl_header->ctl_table_arg;
 	unregister_net_sysctl_table(net->ct.sysctl_header);
 	kfree(table);
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 957374a..04fca48 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -283,7 +283,7 @@ static __init int netfilter_log_sysctl_init(void)
 		nf_log_sysctl_table[i].extra1 = (void *)(unsigned long) i;
 	}
 
-	nf_log_dir_header = register_sysctl_paths(nf_log_sysctl_path,
+	nf_log_dir_header = register_net_sysctl_table(&init_net, nf_log_sysctl_path,
 				       nf_log_sysctl_table);
 	if (!nf_log_dir_header)
 		return -ENOMEM;
diff --git a/net/netrom/sysctl_net_netrom.c b/net/netrom/sysctl_net_netrom.c
index 1e0fa9e5..4ed149e 100644
--- a/net/netrom/sysctl_net_netrom.c
+++ b/net/netrom/sysctl_net_netrom.c
@@ -154,10 +154,10 @@ static struct ctl_path nr_path[] = {
 
 void __init nr_register_sysctl(void)
 {
-	nr_table_header = register_sysctl_paths(nr_path, nr_table);
+	nr_table_header = register_net_sysctl_table(&init_net, nr_path, nr_table);
 }
 
 void nr_unregister_sysctl(void)
 {
-	unregister_sysctl_table(nr_table_header);
+	unregister_net_sysctl_table(nr_table_header);
 }
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index 8bed767..aa55db5 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -106,11 +106,11 @@ static struct ctl_path phonet_ctl_path[] = {
 
 int __init phonet_sysctl_init(void)
 {
-	phonet_table_hrd = register_sysctl_paths(phonet_ctl_path, phonet_table);
+	phonet_table_hrd = register_net_sysctl_table(&init_net, phonet_ctl_path, phonet_table);
 	return phonet_table_hrd == NULL ? -ENOMEM : 0;
 }
 
 void phonet_sysctl_exit(void)
 {
-	unregister_sysctl_table(phonet_table_hrd);
+	unregister_net_sysctl_table(phonet_table_hrd);
 }
diff --git a/net/rds/ib_sysctl.c b/net/rds/ib_sysctl.c
index 1253b00..0fef3e1 100644
--- a/net/rds/ib_sysctl.c
+++ b/net/rds/ib_sysctl.c
@@ -116,12 +116,12 @@ static struct ctl_path rds_ib_sysctl_path[] = {
 void rds_ib_sysctl_exit(void)
 {
 	if (rds_ib_sysctl_hdr)
-		unregister_sysctl_table(rds_ib_sysctl_hdr);
+		unregister_net_sysctl_table(rds_ib_sysctl_hdr);
 }
 
 int rds_ib_sysctl_init(void)
 {
-	rds_ib_sysctl_hdr = register_sysctl_paths(rds_ib_sysctl_path, rds_ib_sysctl_table);
+	rds_ib_sysctl_hdr = register_net_sysctl_table(&init_net, rds_ib_sysctl_path, rds_ib_sysctl_table);
 	if (!rds_ib_sysctl_hdr)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rds/iw_sysctl.c b/net/rds/iw_sysctl.c
index e2e4717..bcfe36d 100644
--- a/net/rds/iw_sysctl.c
+++ b/net/rds/iw_sysctl.c
@@ -119,12 +119,12 @@ static struct ctl_path rds_iw_sysctl_path[] = {
 void rds_iw_sysctl_exit(void)
 {
 	if (rds_iw_sysctl_hdr)
-		unregister_sysctl_table(rds_iw_sysctl_hdr);
+		unregister_net_sysctl_table(rds_iw_sysctl_hdr);
 }
 
 int rds_iw_sysctl_init(void)
 {
-	rds_iw_sysctl_hdr = register_sysctl_paths(rds_iw_sysctl_path, rds_iw_sysctl_table);
+	rds_iw_sysctl_hdr = register_net_sysctl_table(&init_net, rds_iw_sysctl_path, rds_iw_sysctl_table);
 	if (!rds_iw_sysctl_hdr)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rds/sysctl.c b/net/rds/sysctl.c
index 25ad0c7..30354b8 100644
--- a/net/rds/sysctl.c
+++ b/net/rds/sysctl.c
@@ -102,7 +102,7 @@ static struct ctl_path rds_sysctl_path[] = {
 void rds_sysctl_exit(void)
 {
 	if (rds_sysctl_reg_table)
-		unregister_sysctl_table(rds_sysctl_reg_table);
+		unregister_net_sysctl_table(rds_sysctl_reg_table);
 }
 
 int rds_sysctl_init(void)
@@ -110,7 +110,7 @@ int rds_sysctl_init(void)
 	rds_sysctl_reconnect_min = msecs_to_jiffies(1);
 	rds_sysctl_reconnect_min_jiffies = rds_sysctl_reconnect_min;
 
-	rds_sysctl_reg_table = register_sysctl_paths(rds_sysctl_path, rds_sysctl_rds_table);
+	rds_sysctl_reg_table = register_net_sysctl_table(&init_net, rds_sysctl_path, rds_sysctl_rds_table);
 	if (!rds_sysctl_reg_table)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rose/sysctl_net_rose.c b/net/rose/sysctl_net_rose.c
index df6d9da..02b7397 100644
--- a/net/rose/sysctl_net_rose.c
+++ b/net/rose/sysctl_net_rose.c
@@ -126,10 +126,10 @@ static struct ctl_path rose_path[] = {
 
 void __init rose_register_sysctl(void)
 {
-	rose_table_header = register_sysctl_paths(rose_path, rose_table);
+	rose_table_header = register_net_sysctl_table(&init_net, rose_path, rose_table);
 }
 
 void rose_unregister_sysctl(void)
 {
-	unregister_sysctl_table(rose_table_header);
+	unregister_net_sysctl_table(rose_table_header);
 }
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 60ffbd0..1e385b4 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -286,11 +286,11 @@ static struct ctl_table_header * sctp_sysctl_header;
 /* Sysctl registration.  */
 void sctp_sysctl_register(void)
 {
-	sctp_sysctl_header = register_sysctl_paths(sctp_path, sctp_table);
+	sctp_sysctl_header = register_net_sysctl_table(&init_net, sctp_path, sctp_table);
 }
 
 /* Sysctl deregistration.  */
 void sctp_sysctl_unregister(void)
 {
-	unregister_sysctl_table(sctp_sysctl_header);
+	unregister_net_sysctl_table(sctp_sysctl_header);
 }
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 397cffe..4f6979c 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -58,6 +58,6 @@ void unix_sysctl_unregister(struct net *net)
 	struct ctl_table *table;
 
 	table = net->unx.ctl->ctl_table_arg;
-	unregister_sysctl_table(net->unx.ctl);
+	unregister_net_sysctl_table(net->unx.ctl);
 	kfree(table);
 }
diff --git a/net/x25/sysctl_net_x25.c b/net/x25/sysctl_net_x25.c
index d2efd29..08337cb 100644
--- a/net/x25/sysctl_net_x25.c
+++ b/net/x25/sysctl_net_x25.c
@@ -81,10 +81,10 @@ static struct ctl_path x25_path[] = {
 
 void __init x25_register_sysctl(void)
 {
-	x25_table_header = register_sysctl_paths(x25_path, x25_table);
+	x25_table_header = register_net_sysctl_table(&init_net, x25_path, x25_table);
 }
 
 void x25_unregister_sysctl(void)
 {
-	unregister_sysctl_table(x25_table_header);
+	unregister_net_sysctl_table(x25_table_header);
 }
-- 
1.7.2.5
