From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 09/12] netfilter: ipv6 sysctl support for net namespace
Date: Tue, 17 Apr 2012 10:56:20 +0800
Message-ID: <1334631383-12326-10-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:11141 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754706Ab2DQDfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 23:35:06 -0400
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

register pernet_operations nf_conntrack_net_proto_ipv6_ops
when loading nf_conntrack_ipv6 module,and unregister it when
removing.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   48 ++++++++++++++++++++++++
 1 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 4111050..8c0456c 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -333,6 +333,43 @@ MODULE_ALIAS("nf_conntrack-" __stringify(AF_INET6));
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Yasuyuki KOZAKAI @USAGI <yasuyuki.kozakai@toshiba.co.jp>");
 
+static int nf_conntrack_net_proto_ipv6_init(struct net *net)
+{
+	int ret;
+
+	ret = nf_conntrack_proto_ipv6_tcp_init(net);
+	if (ret < 0)
+		return ret;
+
+	ret = nf_conntrack_proto_ipv6_udp_init(net);
+	if (ret < 0)
+		goto cleanup_tcp;
+
+	ret = nf_conntrack_proto_icmpv6_net_init(net);
+	if (ret < 0)
+		goto cleanup_udp;
+	return 0;
+ cleanup_udp:
+	nf_conntrack_proto_ipv6_udp_fini(net);
+ 
+ cleanup_tcp:
+	nf_conntrack_proto_ipv6_tcp_fini(net);
+
+	return ret;
+}
+
+static void nf_conntrack_net_proto_ipv6_fini(struct net *net)
+{
+	nf_conntrack_proto_icmpv6_net_fini(net);
+	nf_conntrack_proto_ipv6_udp_fini(net);
+	nf_conntrack_proto_ipv6_tcp_fini(net);
+}
+
+static struct pernet_operations nf_conntrack_net_proto_ipv6_ops = {
+	.init = nf_conntrack_net_proto_ipv6_init,
+	.exit = nf_conntrack_net_proto_ipv6_fini,
+};
+
 static int __init nf_conntrack_l3proto_ipv6_init(void)
 {
 	int ret = 0;
@@ -371,8 +408,18 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 		       "hook.\n");
 		goto cleanup_ipv6;
 	}
+
+	ret = register_pernet_subsys(&nf_conntrack_net_proto_ipv6_ops);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv6: can't register pernet subsys.\n");
+		goto cleanup_hooks;
+	}
+
 	return ret;
 
+ cleanup_hooks:
+	nf_unregister_hooks(ipv6_conntrack_ops,
+			    ARRAY_SIZE(ipv6_conntrack_ops));
  cleanup_ipv6:
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
  cleanup_icmpv6:
@@ -387,6 +434,7 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 {
 	synchronize_net();
+	unregister_pernet_subsys(&nf_conntrack_net_proto_ipv6_ops);
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
-- 
1.7.7.6
