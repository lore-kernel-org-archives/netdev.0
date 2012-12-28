From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 14/19] netfilter: ipv6: move registration codes out of pernet_operations
Date: Fri, 28 Dec 2012 10:36:41 +0800
Message-ID: <1356662206-2260-15-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the proto (un)registration codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 8db8182..6787ab1 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -499,12 +499,31 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 		       "hook.\n");
 		goto cleanup_ipv6;
 	}
+
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp6);
+	if (ret < 0)
+		goto cleanup_tcp6;
+
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp6);
+	if (ret < 0)
+		goto cleanup_udp6;
+
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmpv6);
+	if (ret < 0)
+		goto cleanup_icmpv6;
+
 	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv6);
 	if (ret < 0)
 		goto cleanup_proto;
 	return ret;
 
  cleanup_proto:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
+ cleanup_icmpv6:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
+ cleanup_udp6:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
+ cleanup_tcp6:
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
  cleanup_ipv6:
 	unregister_pernet_subsys(&ipv6_net_ops);
@@ -516,6 +535,9 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 {
 	synchronize_net();
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
 	unregister_pernet_subsys(&ipv6_net_ops);
-- 
1.7.11.7

