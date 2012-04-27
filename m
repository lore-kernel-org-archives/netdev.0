From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 10/17] netfilter: add namespace support for l3proto_ipv6
Date: Fri, 27 Apr 2012 17:37:57 +0800
Message-ID: <1335519484-6089-11-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55061 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759963Ab2D0Jhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:37:54 -0400
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add pernet_operations ipv6_net_ops and register it when
module nf_conntrack_ipv6 is loaded.

move the l4proto_register and l3proto_register from module_init
function to ipv6_net_ops.init.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   88 ++++++++++++++++--------
 1 files changed, 59 insertions(+), 29 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index fe925e4..b847bbf 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -334,37 +334,75 @@ MODULE_ALIAS("nf_conntrack-" __stringify(AF_INET6));
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Yasuyuki KOZAKAI @USAGI <yasuyuki.kozakai@toshiba.co.jp>");
 
-static int __init nf_conntrack_l3proto_ipv6_init(void)
+static int ipv6_net_init(struct net *net)
 {
 	int ret = 0;
 
-	need_conntrack();
-	nf_defrag_ipv6_enable();
-
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp6);
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_tcp6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: can't register tcp.\n");
-		return ret;
+		printk(KERN_ERR "nf_conntrack_l4proto_tcp6: protocol register failed\n");
+		goto out;
 	}
-
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp6);
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_udp6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: can't register udp.\n");
-		goto cleanup_tcp;
+		printk(KERN_ERR "nf_conntrack_l4proto_udp6: protocol register failed\n");
+		goto cleanup_tcp6;
 	}
-
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmpv6);
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_icmpv6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: can't register icmpv6.\n");
-		goto cleanup_udp;
+		printk(KERN_ERR "nf_conntrack_l4proto_icmp6: protocol register failed\n");
+		goto cleanup_udp6;
 	}
-
-	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv6);
+	ret = nf_conntrack_l3proto_register(net,
+					    &nf_conntrack_l3proto_ipv6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: can't register ipv6\n");
+		printk(KERN_ERR "nf_conntrack_l3proto_ipv6: protocol register failed\n");
 		goto cleanup_icmpv6;
 	}
+	return 0;
+ cleanup_icmpv6:
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_icmpv6);
+ cleanup_udp6:
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_udp6);
+ cleanup_tcp6:
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_tcp6);
+ out:
+	return ret;
+}
 
+static void ipv6_net_exit(struct net *net)
+{
+	nf_conntrack_l3proto_unregister(net,
+					&nf_conntrack_l3proto_ipv6);
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_icmpv6);
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_udp6);
+	nf_conntrack_l4proto_unregister(net,
+					&nf_conntrack_l4proto_tcp6);
+}
+
+static struct pernet_operations ipv6_net_ops = {
+	.init = ipv6_net_init,
+	.exit = ipv6_net_exit,
+};
+
+static int __init nf_conntrack_l3proto_ipv6_init(void)
+{
+	int ret = 0;
+
+	need_conntrack();
+	nf_defrag_ipv6_enable();
+
+	ret = register_pernet_subsys(&ipv6_net_ops);
+	if (ret < 0)
+		goto cleanup_pernet;
 	ret = nf_register_hooks(ipv6_conntrack_ops,
 				ARRAY_SIZE(ipv6_conntrack_ops));
 	if (ret < 0) {
@@ -375,13 +413,8 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	return ret;
 
  cleanup_ipv6:
-	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
- cleanup_icmpv6:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
- cleanup_udp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
- cleanup_tcp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
+	unregister_pernet_subsys(&ipv6_net_ops);
+ cleanup_pernet:
 	return ret;
 }
 
@@ -389,10 +422,7 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 {
 	synchronize_net();
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
-	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
+	unregister_pernet_subsys(&ipv6_net_ops);
 }
 
 module_init(nf_conntrack_l3proto_ipv6_init);
-- 
1.7.7.6
