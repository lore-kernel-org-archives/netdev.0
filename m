From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 11/20] net: Simplify conntrack_proto_gre pernet operations.
Date: Sun, 29 Nov 2009 17:46:08 -0800
Message-ID: <1259545577-7466-11-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46448 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbZK3Bq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:29 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Take advantage of the new pernet automatic storage management,
and stop using compatibility network namespace functions.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/netfilter/nf_conntrack_proto_gre.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 91d0e71..c99cfba 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -300,32 +300,24 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 
 static int proto_gre_net_init(struct net *net)
 {
-	struct netns_proto_gre *net_gre;
-	int rv;
+	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
 
-	net_gre = kmalloc(sizeof(struct netns_proto_gre), GFP_KERNEL);
-	if (!net_gre)
-		return -ENOMEM;
 	rwlock_init(&net_gre->keymap_lock);
 	INIT_LIST_HEAD(&net_gre->keymap_list);
 
-	rv = net_assign_generic(net, proto_gre_net_id, net_gre);
-	if (rv < 0)
-		kfree(net_gre);
-	return rv;
+	return 0;
 }
 
 static void proto_gre_net_exit(struct net *net)
 {
-	struct netns_proto_gre *net_gre = net_generic(net, proto_gre_net_id);
-
 	nf_ct_gre_keymap_flush(net);
-	kfree(net_gre);
 }
 
 static struct pernet_operations proto_gre_net_ops = {
 	.init = proto_gre_net_init,
 	.exit = proto_gre_net_exit,
+	.id   = &proto_gre_net_id,
+	.size = sizeof(struct netns_proto_gre),
 };
 
 static int __init nf_ct_proto_gre_init(void)
@@ -335,7 +327,7 @@ static int __init nf_ct_proto_gre_init(void)
 	rv = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_gre4);
 	if (rv < 0)
 		return rv;
-	rv = register_pernet_gen_subsys(&proto_gre_net_id, &proto_gre_net_ops);
+	rv = register_pernet_subsys(&proto_gre_net_ops);
 	if (rv < 0)
 		nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
 	return rv;
@@ -344,7 +336,7 @@ static int __init nf_ct_proto_gre_init(void)
 static void __exit nf_ct_proto_gre_fini(void)
 {
 	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
-	unregister_pernet_gen_subsys(proto_gre_net_id, &proto_gre_net_ops);
+	unregister_pernet_subsys(&proto_gre_net_ops);
 }
 
 module_init(nf_ct_proto_gre_init);
-- 
1.6.5.2.143.g8cc62

