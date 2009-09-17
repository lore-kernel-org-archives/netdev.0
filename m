From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 02/04: nf_conntrack: netns fix re reliable conntrack event delivery
Date: Thu, 17 Sep 2009 13:58:28 +0200 (MEST)
Message-ID: <20090917115825.12728.69202.sendpatchset@x2.localnet>
References: <20090917115823.12728.87778.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090917115823.12728.87778.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 352a76c896217cfa1d61a49e5b2e3f1e9760943f
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Sep 17 13:28:48 2009 +0200

    netfilter: nf_conntrack: netns fix re reliable conntrack event delivery
    
    Upstream commit ee254fa4:
    
    Conntracks in netns other than init_net dying list were never killed.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index b5869b9..b8614c6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1089,14 +1089,14 @@ void nf_conntrack_flush_report(struct net *net, u32 pid, int report)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_flush_report);
 
-static void nf_ct_release_dying_list(void)
+static void nf_ct_release_dying_list(struct net *net)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	struct hlist_nulls_node *n;
 
 	spin_lock_bh(&nf_conntrack_lock);
-	hlist_nulls_for_each_entry(h, n, &init_net.ct.dying, hnnode) {
+	hlist_nulls_for_each_entry(h, n, &net->ct.dying, hnnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		/* never fails to remove them, no listeners at this point */
 		nf_ct_kill(ct);
@@ -1115,7 +1115,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 {
  i_see_dead_people:
 	nf_ct_iterate_cleanup(net, kill_all, NULL);
-	nf_ct_release_dying_list();
+	nf_ct_release_dying_list(net);
 	if (atomic_read(&net->ct.count) != 0) {
 		schedule();
 		goto i_see_dead_people;
