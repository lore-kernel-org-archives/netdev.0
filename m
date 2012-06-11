From: pablo@netfilter.org
Subject: [PATCH 12/25] netfilter: nf_ct_ipv6: add namespace support
Date: Mon, 11 Jun 2012 16:43:48 +0200
Message-ID: <1339425841-24171-13-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32870 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359Ab2FKOpC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 10:45:02 -0400
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch adds namespace support for IPv6 protocol tracker.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   88 ++++++++++++++++--------
 1 file changed, 59 insertions(+), 29 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 7334cbf..fca10da 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -333,37 +333,75 @@ MODULE_ALIAS("nf_conntrack-" __stringify(AF_INET6));
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Yasuyuki KOZAKAI @USAGI <yasuyuki.kozakai@toshiba.co.jp>");
 
-static int __init nf_conntrack_l3proto_ipv6_init(void)
+static int ipv6_net_init(struct net *net)
 {
 	int ret = 0;
 
-	need_conntrack();
-	nf_defrag_ipv6_enable();
-
-	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_tcp6);
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_tcp6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: can't register tcp.\n");
-		return ret;
+		printk(KERN_ERR "nf_conntrack_l4proto_tcp6: protocol register failed\n");
+		goto out;
 	}
-
-	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udp6);
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_udp6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: can't register udp.\n");
-		goto cleanup_tcp;
+		printk(KERN_ERR "nf_conntrack_l4proto_udp6: protocol register failed\n");
+		goto cleanup_tcp6;
 	}
-
-	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_icmpv6);
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_icmpv6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: can't register icmpv6.\n");
-		goto cleanup_udp;
+		printk(KERN_ERR "nf_conntrack_l4proto_icmp6: protocol register failed\n");
+		goto cleanup_udp6;
 	}
-
-	ret = nf_conntrack_l3proto_register(&init_net, &nf_conntrack_l3proto_ipv6);
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
@@ -374,13 +412,8 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	return ret;
 
  cleanup_ipv6:
-	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv6);
- cleanup_icmpv6:
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
- cleanup_udp:
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp6);
- cleanup_tcp:
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp6);
+	unregister_pernet_subsys(&ipv6_net_ops);
+ cleanup_pernet:
 	return ret;
 }
 
@@ -388,10 +421,7 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 {
 	synchronize_net();
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
-	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv6);
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp6);
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp6);
+	unregister_pernet_subsys(&ipv6_net_ops);
 }
 
 module_init(nf_conntrack_l3proto_ipv6_init);
-- 
1.7.10
