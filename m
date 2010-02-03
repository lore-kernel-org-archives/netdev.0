From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Wed, 03 Feb 2010 13:10:36 +0100
Message-ID: <4B6967BC.600@trash.net>
References: <1264813832.2793.446.camel@tonnant>	 <1265023437.2848.30.camel@edumazet-laptop>	 <1265035970.2848.50.camel@edumazet-laptop>	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>	 <1265036548.2848.55.camel@edumazet-laptop>	 <1265108690.2861.118.camel@tonnant> <1265110504.2861.135.camel@tonnant>	 <1265129192.2861.141.camel@tonnant> <4B685756.8010107@trash.net>	 <1265130426.2861.158.camel@tonnant>	 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com> <1265134598.2861.191.camel@tonnant> <4B6870AF.6060109@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070806000507070702070402"
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51975 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754519Ab0BCMKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 07:10:39 -0500
In-Reply-To: <4B6870AF.6060109@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070806000507070702070402
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Jon Masters wrote:
>> On Tue, 2010-02-02 at 19:58 +0200, Alexey Dobriyan wrote:
>>
>>> Yes, moving to init_net-only function is fine.
>> So moving the "setup up fake conntrack" bits to init_init_net from
>> init_net still results in the panic, which means that the use count
>> really is dropping to zero and we really are trying to free it when
>> using multiple namespaces. Per ns is probably an easier way to go.
> 
> Agreed, that will also avoid problems in the future with the
> ct_net pointer pointing to &init_net. I'll take care of this
> tommorrow.

Unfortunately a per-namespace conntrack is not easily possible without
larger changes (most of which are already queued in nf-next-2.6.git
though). So for now I just moved the untrack handling to the init_net
setup and cleanup functions and we can try to fix the remainder in
2.6.34.

Jon, could you give this patch a try please?

--------------070806000507070702070402
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

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

--------------070806000507070702070402--
