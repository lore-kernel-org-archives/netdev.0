From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [nf-next PATCH 0/5] (repost) netfilter: conntrack:
 optimization, remove central spinlock
Date: Fri, 28 Feb 2014 10:47:38 +0100
Message-ID: <20140228104738.6707b8f1@redhat.com>
References: <20140227182220.25907.12758.stgit@dragon>
 <20140227.183415.788592676169519032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
	pablo@netfilter.org, netdev@vger.kernel.org, fw@strlen.de,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140227.183415.788592676169519032.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Feb 2014 18:34:15 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Thu, 27 Feb 2014 19:23:24 +0100
> 
> > (Repost to netfilter-devel list)
> > 
> > This patchset change the conntrack locking and provides a huge
> > performance improvements.
> > 
> > This patchset is based upon Eric Dumazet's proposed patch:
> >   http://thread.gmane.org/gmane.linux.network/268758/focus=47306
> > I have in agreement with Eric Dumazet, taken over this patch (and
> > turned it into a entire patchset).
> > 
> > Primary focus is to remove the central spinlock nf_conntrack_lock.
> > This requires several steps to be acheived.
> 
> I only worry about the raw_smp_processor_id()'s.
> 
> If preemption will be disabled in these contexts, then it's safe and
> we can just use plain smp_processor_id().

Most of the contexts are safe, one were not by mistake, and one is not.
I've corrected the code (patch diff below) and tested with lockdep etc.

> If preemption is not necessarily disabled in these spots, the use
> is not correct.  We'll need to use get_cpu/put_cpu sequences, or
> (considering what these patches are doing) something like:
> 
> 	struct ct_pcpu *pcpu;
> 
> 	/* add this conntrack to the (per cpu) unconfirmed list */
> 	local_bh_disable();
> 	ct->cpu = smp_processor_id();
> 	pcpu = per_cpu_ptr(nf_ct_net(ct)->ct.pcpu_lists, ct->cpu);
> 
> 	spin_lock(&pcpu->lock);
> 	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
> 			     &pcpu->unconfirmed);
> 	spin_unlock_bh(&pcpu->lock);

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ac85fd1..289b279 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -192,34 +192,37 @@ clean_from_lists(struct nf_conn *ct)
 	nf_ct_remove_expectations(ct);
 }
 
+/* must be called with local_bh_disable */
 static void nf_ct_add_to_dying_list(struct nf_conn *ct)
 {
 	struct ct_pcpu *pcpu;
 
 	/* add this conntrack to the (per cpu) dying list */
-	ct->cpu = raw_smp_processor_id();
+	ct->cpu = smp_processor_id();
 	pcpu = per_cpu_ptr(nf_ct_net(ct)->ct.pcpu_lists, ct->cpu);
 
-	spin_lock_bh(&pcpu->lock);
+	spin_lock(&pcpu->lock);
 	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
 			     &pcpu->dying);
-	spin_unlock_bh(&pcpu->lock);
+	spin_unlock(&pcpu->lock);
 }
 
+/* must be called with local_bh_disable */
 static void nf_ct_add_to_unconfirmed_list(struct nf_conn *ct)
 {
 	struct ct_pcpu *pcpu;
 
 	/* add this conntrack to the (per cpu) unconfirmed list */
-	ct->cpu = raw_smp_processor_id();
+	ct->cpu = smp_processor_id();
 	pcpu = per_cpu_ptr(nf_ct_net(ct)->ct.pcpu_lists, ct->cpu);
 
-	spin_lock_bh(&pcpu->lock);
+	spin_lock(&pcpu->lock);
 	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
 			     &pcpu->unconfirmed);
-	spin_unlock_bh(&pcpu->lock);
+	spin_unlock(&pcpu->lock);
 }
 
+/* must be called with local_bh_disable */
 static void nf_ct_del_from_dying_or_unconfirmed_list(struct nf_conn *ct)
 {
 	struct ct_pcpu *pcpu;
@@ -227,10 +230,10 @@ static void nf_ct_del_from_dying_or_unconfirmed_list(struct nf_conn *ct)
 	/* We overload first tuple to link into unconfirmed or dying list.*/
 	pcpu = per_cpu_ptr(nf_ct_net(ct)->ct.pcpu_lists, ct->cpu);
 
-	spin_lock_bh(&pcpu->lock);
+	spin_lock(&pcpu->lock);
 	BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode));
 	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
-	spin_unlock_bh(&pcpu->lock);
+	spin_unlock(&pcpu->lock);
 }
 
 static void
@@ -511,10 +514,11 @@ void nf_conntrack_tmpl_insert(struct net *net, struct nf_conn *tmpl)
 	nf_conntrack_get(&tmpl->ct_general);
 
 	/* add this conntrack to the (per cpu) tmpl list */
-	tmpl->cpu = raw_smp_processor_id();
+	local_bh_disable();
+	tmpl->cpu = smp_processor_id();
 	pcpu = per_cpu_ptr(nf_ct_net(tmpl)->ct.pcpu_lists, tmpl->cpu);
 
-	spin_lock_bh(&pcpu->lock);
+	spin_lock(&pcpu->lock);
 	/* Overload tuple linked list to put us in template list. */
 	hlist_nulls_add_head_rcu(&tmpl->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
 				 &pcpu->tmpl);
@@ -921,11 +925,9 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 
 	/* Now it is inserted into the unconfirmed list, bump refcount */
 	nf_conntrack_get(&ct->ct_general);
-
-	spin_unlock_bh(&nf_conntrack_lock);
-
 	nf_ct_add_to_unconfirmed_list(ct);
 
+	spin_unlock_bh(&nf_conntrack_lock);
 
 	if (exp) {
 		if (exp->expectfn)
