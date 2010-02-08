From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/05: nf_conntrack: fix memory corruption with multiple namespaces
Date: Mon,  8 Feb 2010 18:10:27 +0100 (MET)
Message-ID: <20100208171025.15522.74.sendpatchset@x2.localnet>
References: <20100208171024.15522.8136.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38900 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab0BHRK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 12:10:28 -0500
In-Reply-To: <20100208171024.15522.8136.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 056ff3e3bd1563969a311697323ff929df94415c
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 3 12:58:06 2010 +0100

    netfilter: nf_conntrack: fix memory corruption with multiple namespaces
    
    As discovered by Jon Masters <jonathan@jonmasters.org>, the "untracked"
    conntrack, which is located in the data section, might be accidentally
    freed when a new namespace is instantiated while the untracked conntrack
    is attached to a skb because the reference count it re-initialized.
    
    The best fix would be to use a seperate untracked conntrack per
    namespace since it includes a namespace pointer. Unfortunately this is
    not possible without larger changes since the namespace is not easily
    available everywhere we need it. For now move the untracked conntrack
    initialization to the init_net setup function to make sure the reference
    count is not re-initialized and handle cleanup in the init_net cleanup
    function to make sure namespaces can exit properly while the untracked
    conntrack is in use in other namespaces.
    
    Cc: stable@kernel.org
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 0e98c32..37e2b88 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1113,6 +1113,10 @@ static void nf_ct_release_dying_list(struct net *net)
 
 static void nf_conntrack_cleanup_init_net(void)
 {
+	/* wait until all references to nf_conntrack_untracked are dropped */
+	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
+		schedule();
+
 	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
 	kmem_cache_destroy(nf_conntrack_cachep);
@@ -1127,9 +1131,6 @@ static void nf_conntrack_cleanup_net(struct net *net)
 		schedule();
 		goto i_see_dead_people;
 	}
-	/* wait until all references to nf_conntrack_untracked are dropped */
-	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
-		schedule();
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
@@ -1288,6 +1289,14 @@ static int nf_conntrack_init_init_net(void)
 	if (ret < 0)
 		goto err_helper;
 
+	/* Set up fake conntrack: to never be deleted, not in any hashes */
+#ifdef CONFIG_NET_NS
+	nf_conntrack_untracked.ct_net = &init_net;
+#endif
+	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
+	/*  - and look it like as a confirmed connection */
+	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
+
 	return 0;
 
 err_helper:
@@ -1333,15 +1342,6 @@ static int nf_conntrack_init_net(struct net *net)
 	if (ret < 0)
 		goto err_ecache;
 
-	/* Set up fake conntrack:
-	    - to never be deleted, not in any hashes */
-#ifdef CONFIG_NET_NS
-	nf_conntrack_untracked.ct_net = &init_net;
-#endif
-	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
-	/*  - and look it like as a confirmed connection */
-	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
-
 	return 0;
 
 err_ecache:
