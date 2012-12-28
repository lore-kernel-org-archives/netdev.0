From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 15/19] netfilter: sctp: move registration codes out of pernet_operations
Date: Fri, 28 Dec 2012 10:36:42 +0800
Message-ID: <1356662206-2260-16-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:26245 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753118Ab2L1Ciy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 21:38:54 -0500
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the proto (un)registration codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_sctp.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 0aa91dd..62ef799 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -891,11 +891,32 @@ static struct pernet_operations sctp_net_ops = {
 
 static int __init nf_conntrack_proto_sctp_init(void)
 {
-	return register_pernet_subsys(&sctp_net_ops);
+	int ret;
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp4);
+	if (ret < 0)
+		goto out_sctp4;
+
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp6);
+	if (ret < 0)
+		goto out_sctp6;
+
+	ret = register_pernet_subsys(&sctp_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
+	return 0;
+out_pernet:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
+out_sctp6:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
+out_sctp4:
+	return ret;
 }
 
 static void __exit nf_conntrack_proto_sctp_fini(void)
 {
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
 	unregister_pernet_subsys(&sctp_net_ops);
 }
 
-- 
1.7.11.7
