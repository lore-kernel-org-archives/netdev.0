From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] [RFC] netfilter: nf_conntrack: don't relase a conntrack
 with non-zero refcnt
Date: Mon, 3 Feb 2014 00:30:46 +0100
Message-ID: <20140202233046.GA4137@localhost>
References: <1389710201.31367.255.camel@edumazet-glaptop2.roam.corp.google.com>
 <1389720948-7883-1-git-send-email-avagin@openvz.org>
 <20140114185329.GB28205@breakpoint.cc>
 <20140115180844.GA3605@paralelels.com>
 <20140116092301.GF28205@breakpoint.cc>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Cc: Andrew Vagin <avagin@parallels.com>,
	Andrey Vagin <avagin@openvz.org>,
	netfilter-devel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Vasiliy Averin <vvs@parallels.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140116092301.GF28205@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 16, 2014 at 10:23:01AM +0100, Florian Westphal wrote:
> Andrew Vagin <avagin@parallels.com> wrote:
> > > I think it would be nice if we could keep it that way.
> > > If everything fails we could proably intoduce a 'larval' dummy list
> > > similar to the one used by template conntracks?
> > 
> > I'm not sure, that this is required. Could you elaborate when this can
> > be useful?
> 
> You can dump the lists via ctnetlink.  Its meant as a debugging aid in
> case one suspects refcnt leaks.
> 
> Granted, in this situation there should be no leak since we put the newly
> allocated entry in the error case.
> 
> > Now I see only overhead, because we need to take the nf_conntrack_lock
> > lock to add conntrack in a list.
> 
> True. I don't have any preference, I guess I'd just do the insertion into the
> unconfirmed list when we know we cannot track to keep the "unhashed"
> bug trap in the destroy function.
> 
> Pablo, any preference?

I think we can initially set to zero the refcount and bump it once it
gets into any of the lists, so Eric's golden rule also stands for
conntracks that are released without being inserted in any list via
nf_conntrack_free().

My idea was to use dying list to detect possible runtime leaks (ie.
missing nf_ct_put somewhere), not simple leaks the initialization
path, as you said, it would add too much overhead to catch them with
the dying list, so we can skip those.

Please, let me know if you find any issue with this approach.

--IS0zKkzwUGydFO0o
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="x.patch"

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 01ea6ee..b2ac624 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -284,6 +284,8 @@ extern unsigned int nf_conntrack_max;
 extern unsigned int nf_conntrack_hash_rnd;
 void init_nf_conntrack_hash_rnd(void);
 
+void nf_conntrack_tmpl_insert(struct net *net, struct nf_conn *tmpl);
+
 #define NF_CT_STAT_INC(net, count)	  __this_cpu_inc((net)->ct.stat->count)
 #define NF_CT_STAT_INC_ATOMIC(net, count) this_cpu_inc((net)->ct.stat->count)
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 4d1fb5d..bd5ec5a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -448,7 +448,8 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 			goto out;
 
 	add_timer(&ct->timeout);
-	nf_conntrack_get(&ct->ct_general);
+	/* The caller holds a reference to this object */
+	atomic_set(&ct->ct_general.use, 2);
 	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 	NF_CT_STAT_INC(net, insert);
 	spin_unlock_bh(&nf_conntrack_lock);
@@ -462,6 +463,21 @@ out:
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_hash_check_insert);
 
+/* deletion from this larval template list happens via nf_ct_put() */
+void nf_conntrack_tmpl_insert(struct net *net, struct nf_conn *tmpl)
+{
+	__set_bit(IPS_TEMPLATE_BIT, &tmpl->status);
+	__set_bit(IPS_CONFIRMED_BIT, &tmpl->status);
+	nf_conntrack_get(&tmpl->ct_general);
+
+	spin_lock_bh(&nf_conntrack_lock);
+	/* Overload tuple linked list to put us in template list. */
+	hlist_nulls_add_head_rcu(&tmpl->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
+				 &net->ct.tmpl);
+	spin_unlock_bh(&nf_conntrack_lock);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_tmpl_insert);
+
 /* Confirm a connection given skb; places it in hash table */
 int
 __nf_conntrack_confirm(struct sk_buff *skb)
@@ -733,11 +749,11 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 		nf_ct_zone->id = zone;
 	}
 #endif
-	/*
-	 * changes to lookup keys must be done before setting refcnt to 1
+	/* Because we use RCU lookups, we set ct_general.use to zero before
+	 * this is inserted in any list.
 	 */
 	smp_wmb();
-	atomic_set(&ct->ct_general.use, 1);
+	atomic_set(&ct->ct_general.use, 0);
 	return ct;
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
@@ -761,6 +777,11 @@ void nf_conntrack_free(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
 
+	/* A freed object has refcnt == 0, thats
+	 * the golden rule for SLAB_DESTROY_BY_RCU
+	 */
+	NF_CT_ASSERT(atomic_read(&ct->ct_general.use) == 0);
+
 	nf_ct_ext_destroy(ct);
 	nf_ct_ext_free(ct);
 	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
@@ -856,6 +877,9 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 		NF_CT_STAT_INC(net, new);
 	}
 
+	/* Now it is inserted into the hashes, bump refcount */
+	nf_conntrack_get(&ct->ct_general);
+
 	/* Overload tuple linked list to put us in unconfirmed list. */
 	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
 		       &net->ct.unconfirmed);
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 9858e3e..52e20c9 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -363,9 +363,8 @@ static int __net_init synproxy_net_init(struct net *net)
 		goto err2;
 	if (!nfct_synproxy_ext_add(ct))
 		goto err2;
-	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
-	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
 
+	nf_conntrack_tmpl_insert(net, ct);
 	snet->tmpl = ct;
 
 	snet->stats = alloc_percpu(struct synproxy_stats);
@@ -390,7 +389,7 @@ static void __net_exit synproxy_net_exit(struct net *net)
 {
 	struct synproxy_net *snet = synproxy_pernet(net);
 
-	nf_conntrack_free(snet->tmpl);
+	nf_ct_put(snet->tmpl);
 	synproxy_proc_exit(net);
 	free_percpu(snet->stats);
 }
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 5929be6..75747ae 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -228,12 +228,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 			goto err3;
 	}
 
-	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
-	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
-
-	/* Overload tuple linked list to put us in template list. */
-	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
-				 &par->net->ct.tmpl);
+	nf_conntrack_tmpl_insert(par->net, ct);
 out:
 	info->ct = ct;
 	return 0;

--IS0zKkzwUGydFO0o--
