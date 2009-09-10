From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 28/31: nf_conntrack: netns fix re reliable conntrack event delivery
Date: Thu, 10 Sep 2009 18:12:22 +0200 (MEST)
Message-ID: <20090910161218.31179.89011.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit ee254fa44d902ab89fd0d66851701098f07872a7
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Mon Aug 31 14:23:15 2009 +0200

    netfilter: nf_conntrack: netns fix re reliable conntrack event delivery
    
    Conntracks in netns other than init_net dying list were never killed.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 565c3a8..b371098 100644
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
