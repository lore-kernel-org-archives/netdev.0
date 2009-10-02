From: Greg KH <gregkh@suse.de>
Subject: [082/136] netfilter: nf_conntrack: netns fix re reliable conntrack event delivery
Date: Thu, 01 Oct 2009 18:17:10 -0700
Message-ID: <20091002012419.543259734@mini.kroah.org>
References: <20091002011548.335611824@mini.kroah.org>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756784AbZJBBdp@vger.kernel.org>
Content-Disposition: inline; filename=netfilter-nf_conntrack-netns-fix-re-reliable-conntrack-event-delivery.patch
In-Reply-To: <20091002012911.GA18542@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


2.6.31-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Patrick McHardy <kaber@trash.net>

netfilter: nf_conntrack: netns fix re reliable conntrack event delivery

Upstream commit ee254fa4:

Conntracks in netns other than init_net dying list were never killed.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/netfilter/nf_conntrack_core.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1089,14 +1089,14 @@ void nf_conntrack_flush_report(struct ne
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
@@ -1115,7 +1115,7 @@ static void nf_conntrack_cleanup_net(str
 {
  i_see_dead_people:
 	nf_ct_iterate_cleanup(net, kill_all, NULL);
-	nf_ct_release_dying_list();
+	nf_ct_release_dying_list(net);
 	if (atomic_read(&net->ct.count) != 0) {
 		schedule();
 		goto i_see_dead_people;
