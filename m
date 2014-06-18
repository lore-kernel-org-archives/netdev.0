From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/13] netfilter: nf_nat: fix oops on netns removal
Date: Wed, 18 Jun 2014 11:44:38 +0200
Message-ID: <1403084679-11227-13-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41472 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965706AbaFRJo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 05:44:59 -0400
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Quoting Samu Kallio:

 Basically what's happening is, during netns cleanup,
 nf_nat_net_exit gets called before ipv4_net_exit. As I understand
 it, nf_nat_net_exit is supposed to kill any conntrack entries which
 have NAT context (through nf_ct_iterate_cleanup), but for some
 reason this doesn't happen (perhaps something else is still holding
 refs to those entries?).

 When ipv4_net_exit is called, conntrack entries (including those
 with NAT context) are cleaned up, but the
 nat_bysource hashtable is long gone - freed in nf_nat_net_exit. The
 bug happens when attempting to free a conntrack entry whose NAT hash
 'prev' field points to a slot in the freed hash table (head for that
 bin).

We ignore conntracks with null nat bindings.  But this is wrong,
as these are in bysource hash table as well.

Restore nat-cleaning for the netns-is-being-removed case.

bug:
https://bugzilla.kernel.org/show_bug.cgi?id=65191

Fixes: c2d421e1718 ('netfilter: nf_nat: fix race when unloading protocol modules')
Reported-by: Samu Kallio <samu.kallio@aberdeencloud.com>
Debugged-by: Samu Kallio <samu.kallio@aberdeencloud.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Tested-by: Samu Kallio <samu.kallio@aberdeencloud.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c |   35 ++++++++++++++++++++++++++++++++++-
 1 file changed, 34 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 09096a6..a49907b 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -525,6 +525,39 @@ static int nf_nat_proto_remove(struct nf_conn *i, void *data)
 	return i->status & IPS_NAT_MASK ? 1 : 0;
 }
 
+static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
+{
+	struct nf_conn_nat *nat = nfct_nat(ct);
+
+	if (nf_nat_proto_remove(ct, data))
+		return 1;
+
+	if (!nat || !nat->ct)
+		return 0;
+
+	/* This netns is being destroyed, and conntrack has nat null binding.
+	 * Remove it from bysource hash, as the table will be freed soon.
+	 *
+	 * Else, when the conntrack is destoyed, nf_nat_cleanup_conntrack()
+	 * will delete entry from already-freed table.
+	 */
+	if (!del_timer(&ct->timeout))
+		return 1;
+
+	spin_lock_bh(&nf_nat_lock);
+	hlist_del_rcu(&nat->bysource);
+	ct->status &= ~IPS_NAT_DONE_MASK;
+	nat->ct = NULL;
+	spin_unlock_bh(&nf_nat_lock);
+
+	add_timer(&ct->timeout);
+
+	/* don't delete conntrack.  Although that would make things a lot
+	 * simpler, we'd end up flushing all conntracks on nat rmmod.
+	 */
+	return 0;
+}
+
 static void nf_nat_l4proto_clean(u8 l3proto, u8 l4proto)
 {
 	struct nf_nat_proto_clean clean = {
@@ -795,7 +828,7 @@ static void __net_exit nf_nat_net_exit(struct net *net)
 {
 	struct nf_nat_proto_clean clean = {};
 
-	nf_ct_iterate_cleanup(net, &nf_nat_proto_remove, &clean, 0, 0);
+	nf_ct_iterate_cleanup(net, nf_nat_proto_clean, &clean, 0, 0);
 	synchronize_rcu();
 	nf_ct_free_hashtable(net->ct.nat_bysource, net->ct.nat_htable_size);
 }
-- 
1.7.10.4
