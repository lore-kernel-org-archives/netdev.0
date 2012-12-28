From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 16/19] netfilter: udplite: move registration codes out of pernet_operations
Date: Fri, 28 Dec 2012 10:36:43 +0800
Message-ID: <1356662206-2260-17-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36421 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753199Ab2L1Ciy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 21:38:54 -0500
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the proto (un)registration codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_udplite.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 56e53c0..6ad1e5c 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -374,11 +374,32 @@ static struct pernet_operations udplite_net_ops = {
 
 static int __init nf_conntrack_proto_udplite_init(void)
 {
-	return register_pernet_subsys(&udplite_net_ops);
+	int ret;
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udplite4);
+	if (ret < 0)
+		goto out_udplite4;
+
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udplite6);
+	if (ret < 0)
+		goto out_udplite6;
+
+	ret = register_pernet_subsys(&udplite_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
+	return 0;
+out_pernet:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite6);
+out_udplite6:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
+out_udplite4:
+	return ret;
 }
 
 static void __exit nf_conntrack_proto_udplite_exit(void)
 {
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite6);
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
 	unregister_pernet_subsys(&udplite_net_ops);
 }
 
-- 
1.7.11.7
