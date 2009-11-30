From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 10/20] net: Simplify conntrack_proto_dccp pernet operations.
Date: Sun, 29 Nov 2009 17:46:07 -0800
Message-ID: <1259545577-7466-10-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46442 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbZK3Bq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:28 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/netfilter/nf_conntrack_proto_dccp.c |   31 ++++++++-----------------------
 1 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 80abdf2..98916ef 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -810,12 +810,7 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 
 static __net_init int dccp_net_init(struct net *net)
 {
-	struct dccp_net *dn;
-	int err;
-
-	dn = kmalloc(sizeof(*dn), GFP_KERNEL);
-	if (!dn)
-		return -ENOMEM;
+	struct dccp_net *dn = dccp_pernet(net);
 
 	/* default values */
 	dn->dccp_loose = 1;
@@ -827,16 +822,11 @@ static __net_init int dccp_net_init(struct net *net)
 	dn->dccp_timeout[CT_DCCP_CLOSING]	= 64 * HZ;
 	dn->dccp_timeout[CT_DCCP_TIMEWAIT]	= 2 * DCCP_MSL;
 
-	err = net_assign_generic(net, dccp_net_id, dn);
-	if (err)
-		goto out;
-
 #ifdef CONFIG_SYSCTL
-	err = -ENOMEM;
 	dn->sysctl_table = kmemdup(dccp_sysctl_table,
 			sizeof(dccp_sysctl_table), GFP_KERNEL);
 	if (!dn->sysctl_table)
-		goto out;
+		return -ENOMEM;
 
 	dn->sysctl_table[0].data = &dn->dccp_timeout[CT_DCCP_REQUEST];
 	dn->sysctl_table[1].data = &dn->dccp_timeout[CT_DCCP_RESPOND];
@@ -851,15 +841,11 @@ static __net_init int dccp_net_init(struct net *net)
 			nf_net_netfilter_sysctl_path, dn->sysctl_table);
 	if (!dn->sysctl_header) {
 		kfree(dn->sysctl_table);
-		goto out;
+		return -ENOMEM;
 	}
 #endif
 
 	return 0;
-
-out:
-	kfree(dn);
-	return err;
 }
 
 static __net_exit void dccp_net_exit(struct net *net)
@@ -869,21 +855,20 @@ static __net_exit void dccp_net_exit(struct net *net)
 	unregister_net_sysctl_table(dn->sysctl_header);
 	kfree(dn->sysctl_table);
 #endif
-	kfree(dn);
-
-	net_assign_generic(net, dccp_net_id, NULL);
 }
 
 static struct pernet_operations dccp_net_ops = {
 	.init = dccp_net_init,
 	.exit = dccp_net_exit,
+	.id   = &dccp_net_id,
+	.size = sizeof(struct dccp_net),
 };
 
 static int __init nf_conntrack_proto_dccp_init(void)
 {
 	int err;
 
-	err = register_pernet_gen_subsys(&dccp_net_id, &dccp_net_ops);
+	err = register_pernet_subsys(&dccp_net_ops);
 	if (err < 0)
 		goto err1;
 
@@ -899,14 +884,14 @@ static int __init nf_conntrack_proto_dccp_init(void)
 err3:
 	nf_conntrack_l4proto_unregister(&dccp_proto4);
 err2:
-	unregister_pernet_gen_subsys(dccp_net_id, &dccp_net_ops);
+	unregister_pernet_subsys(&dccp_net_ops);
 err1:
 	return err;
 }
 
 static void __exit nf_conntrack_proto_dccp_fini(void)
 {
-	unregister_pernet_gen_subsys(dccp_net_id, &dccp_net_ops);
+	unregister_pernet_subsys(&dccp_net_ops);
 	nf_conntrack_l4proto_unregister(&dccp_proto6);
 	nf_conntrack_l4proto_unregister(&dccp_proto4);
 }
-- 
1.6.5.2.143.g8cc62

