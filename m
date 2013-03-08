From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] netfilter: register pernet subsystem before register L4 proto
Date: Fri, 8 Mar 2013 11:20:46 +0800
Message-ID: <1362712846-12954-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit c296bb4d5d417d466c9bcc8afef68a3db5449a64
"netfilter: nf_conntrack: refactor l4proto support for netns",
we register l4proto gre/dccp/udplite/sctp before register
pernet subsystem,it's a wrong order.

We should register pernet subsystem before register L4proto,
since after register L4proto, init_conntrack may try to access
the resources which allocated in register_pernet_subsys.

Reported-by: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_dccp.c    | 12 ++++++------
 net/netfilter/nf_conntrack_proto_gre.c     | 12 ++++++------
 net/netfilter/nf_conntrack_proto_sctp.c    | 12 ++++++------
 net/netfilter/nf_conntrack_proto_udplite.c | 12 ++++++------
 4 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 432f957..ba65b20 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -969,6 +969,10 @@ static int __init nf_conntrack_proto_dccp_init(void)
 {
 	int ret;
 
+	ret = register_pernet_subsys(&dccp_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
 	ret = nf_ct_l4proto_register(&dccp_proto4);
 	if (ret < 0)
 		goto out_dccp4;
@@ -977,16 +981,12 @@ static int __init nf_conntrack_proto_dccp_init(void)
 	if (ret < 0)
 		goto out_dccp6;
 
-	ret = register_pernet_subsys(&dccp_net_ops);
-	if (ret < 0)
-		goto out_pernet;
-
 	return 0;
-out_pernet:
-	nf_ct_l4proto_unregister(&dccp_proto6);
 out_dccp6:
 	nf_ct_l4proto_unregister(&dccp_proto4);
 out_dccp4:
+	unregister_pernet_subsys(&dccp_net_ops);
+out_pernet:
 	return ret;
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index bd7d01d..155ce9f 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -420,18 +420,18 @@ static int __init nf_ct_proto_gre_init(void)
 {
 	int ret;
 
-	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_gre4);
-	if (ret < 0)
-		goto out_gre4;
-
 	ret = register_pernet_subsys(&proto_gre_net_ops);
 	if (ret < 0)
 		goto out_pernet;
 
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_gre4);
+	if (ret < 0)
+		goto out_gre4;
+
 	return 0;
-out_pernet:
-	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_gre4);
 out_gre4:
+	unregister_pernet_subsys(&proto_gre_net_ops);
+out_pernet:
 	return ret;
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 480f616..ec83536 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -888,6 +888,10 @@ static int __init nf_conntrack_proto_sctp_init(void)
 {
 	int ret;
 
+	ret = register_pernet_subsys(&sctp_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
 	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_sctp4);
 	if (ret < 0)
 		goto out_sctp4;
@@ -896,16 +900,12 @@ static int __init nf_conntrack_proto_sctp_init(void)
 	if (ret < 0)
 		goto out_sctp6;
 
-	ret = register_pernet_subsys(&sctp_net_ops);
-	if (ret < 0)
-		goto out_pernet;
-
 	return 0;
-out_pernet:
-	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
 out_sctp6:
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
 out_sctp4:
+	unregister_pernet_subsys(&sctp_net_ops);
+out_pernet:
 	return ret;
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 1574895..ca969f6 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -371,6 +371,10 @@ static int __init nf_conntrack_proto_udplite_init(void)
 {
 	int ret;
 
+	ret = register_pernet_subsys(&udplite_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
 	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_udplite4);
 	if (ret < 0)
 		goto out_udplite4;
@@ -379,16 +383,12 @@ static int __init nf_conntrack_proto_udplite_init(void)
 	if (ret < 0)
 		goto out_udplite6;
 
-	ret = register_pernet_subsys(&udplite_net_ops);
-	if (ret < 0)
-		goto out_pernet;
-
 	return 0;
-out_pernet:
-	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udplite6);
 out_udplite6:
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
 out_udplite4:
+	unregister_pernet_subsys(&udplite_net_ops);
+out_pernet:
 	return ret;
 }
 
-- 
1.7.11.7

