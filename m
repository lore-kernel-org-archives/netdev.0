From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 17/19] netfilter: dccp: move registration codes out of pernet_operations
Date: Fri, 28 Dec 2012 10:36:44 +0800
Message-ID: <1356662206-2260-18-git-send-email-gaofeng@cn.fujitsu.com>
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
 net/netfilter/nf_conntrack_proto_dccp.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 3850d68..5f84e2b 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -972,11 +972,32 @@ static struct pernet_operations dccp_net_ops = {
 
 static int __init nf_conntrack_proto_dccp_init(void)
 {
-	return register_pernet_subsys(&dccp_net_ops);
+	int ret;
+	ret = nf_conntrack_l4proto_register(&dccp_proto4);
+	if (ret < 0)
+		goto out_dccp4;
+
+	ret = nf_conntrack_l4proto_register(&dccp_proto6);
+	if (ret < 0)
+		goto out_dccp6;
+
+	ret = register_pernet_subsys(&dccp_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
+	return 0;
+out_pernet:
+	nf_conntrack_l4proto_unregister(&dccp_proto6);
+out_dccp6:
+	nf_conntrack_l4proto_unregister(&dccp_proto4);
+out_dccp4:
+	return ret;
 }
 
 static void __exit nf_conntrack_proto_dccp_fini(void)
 {
+	nf_conntrack_l4proto_unregister(&dccp_proto6);
+	nf_conntrack_l4proto_unregister(&dccp_proto4);
 	unregister_pernet_subsys(&dccp_net_ops);
 }
 
-- 
1.7.11.7

