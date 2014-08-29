From: Florian Westphal <fw@strlen.de>
Subject: Re: net_ns cleanup / RCU overhead
Date: Sat, 30 Aug 2014 01:52:06 +0200
Message-ID: <20140829235206.GA15853@breakpoint.cc>
References: <20140820055855.GB5579@hostway.ca>
 <20140828192431.GF5001@linux.vnet.ibm.com>
 <20140828194422.GB8867@hostway.ca>
 <87oav4l5g9.fsf@x220.int.ebiederm.org>
 <20140828204658.GL5001@linux.vnet.ibm.com>
 <20140829004029.GA18300@hostway.ca>
 <alpine.LFD.2.11.1408290635530.1520@ja.home.ssi.bg>
 <87ppfjj6x6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, Simon Kirby <sim@hostway.ca>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87ppfjj6x6.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman <ebiederm@xmission.com> wrote:
> Julian Anastasov <ja@ssi.bg> writes:
> 
> > 	Hello,
> >
> > On Thu, 28 Aug 2014, Simon Kirby wrote:
> >
> >> I noticed that [kworker/u16:0]'s stack is often:
> >> 
> >> [<ffffffff810942a6>] wait_rcu_gp+0x46/0x50
> >> [<ffffffff8109607e>] synchronize_sched+0x2e/0x50
> >> [<ffffffffa00385ac>] nf_nat_net_exit+0x2c/0x50 [nf_nat]
> >
> > 	I guess the problem is in nf_nat_net_exit,
> > may be other nf exit handlers too. pernet-exit handlers
> > should avoid synchronize_rcu and rcu_barrier.
> > A RCU callback and rcu_barrier in module-exit is the way
> > to go. cleanup_net includes rcu_barrier, so pernet-exit
> > does not need such calls.
> 
> In principle I agree, however in this particular case it looks a bit
> tricky because a separate hash table to track nat state per network
> namespace.
> 
> At the same time all of the packets should be drained before
> we get to nf_nat_net_exit so it doesn't look the synchronize_rcu
> in nf_nat_exit is actually protecting anything.

Hmm, the problem is with the conntrack entries living in the netns being
destroyed.

I don't think they are guaranteed to be removed by the time
the nat netns exit function runs.

> Further calling a rcu delay function in net_exit methods largely
> destroys the batched cleanup of network namespaces, so it is very
> unpleasant.
> 
> Could someone who knows nf_nat_core.c better than I do look and
> see if we can just remove the synchronize_rcu in nf_nat_exit?

If I remember correctly its needed to ensure that
all conntracks with nat extensions that might still be referenced
on other cpu have finished (i.e., nf_conntrack_destroy() has been
called, which calls nf_nat_cleanup_conntrack() which deletes
the extension from the hash table).

As we remove the ct from that table ourselves EXCEPT in the
case where we cannot steal the timers' reference we should
be able to avoid that call virtually every time.

Perhaps this is worth a shot (not even compile tested):

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 4e0b478..80cfe10 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -508,6 +508,7 @@ EXPORT_SYMBOL_GPL(nf_nat_packet);
 struct nf_nat_proto_clean {
 	u8	l3proto;
 	u8	l4proto;
+	bool	need_sync_rcu;
 };
 
 /* kill conntracks with affected NAT section */
@@ -528,23 +529,32 @@ static int nf_nat_proto_remove(struct nf_conn *i, void *data)
 
 static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 {
+	struct nf_nat_proto_clean *clean = data;
 	struct nf_conn_nat *nat = nfct_nat(ct);
 
-	if (nf_nat_proto_remove(ct, data))
-		return 1;
-
 	if (!nat || !nat->ct)
 		return 0;
 
-	/* This netns is being destroyed, and conntrack has nat null binding.
+	/* This netns is being destroyed, and conntrack has nat binding.
 	 * Remove it from bysource hash, as the table will be freed soon.
 	 *
-	 * Else, when the conntrack is destoyed, nf_nat_cleanup_conntrack()
+	 * Else, when the conntrack is destroyed, nf_nat_cleanup_conntrack()
 	 * will delete entry from already-freed table.
 	 */
-	if (!del_timer(&ct->timeout))
+	if (!del_timer(&ct->timeout)) {
+		/* We have nat binding, but destruction
+		 * might already be in progress.
+		 *
+		 * nat entry is removed only after last
+		 * nf_ct_put().
+		 */
+		clean->need_sync_rcu = true;
 		return 1;
+	}
 
+	/* We stole refcount owned by timer;
+	 * conntrack cannot go away.
+	 */
 	spin_lock_bh(&nf_nat_lock);
 	hlist_del_rcu(&nat->bysource);
 	ct->status &= ~IPS_NAT_DONE_MASK;
@@ -553,6 +563,9 @@ static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 
 	add_timer(&ct->timeout);
 
+	if (nf_nat_proto_remove(ct, data))
+		return 1;
+
 	/* don't delete conntrack.  Although that would make things a lot
 	 * simpler, we'd end up flushing all conntracks on nat rmmod.
 	 */
@@ -830,7 +843,8 @@ static void __net_exit nf_nat_net_exit(struct net *net)
 	struct nf_nat_proto_clean clean = {};
 
 	nf_ct_iterate_cleanup(net, nf_nat_proto_clean, &clean, 0, 0);
-	synchronize_rcu();
+	if (clean.need_sync_rcu)
+		synchronize_rcu();
 	nf_ct_free_hashtable(net->ct.nat_bysource, net->ct.nat_htable_size);
 }
 
