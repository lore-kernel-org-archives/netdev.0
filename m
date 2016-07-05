From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Tue, 5 Jul 2016 14:28:03 +0200
Message-ID: <20160705122803.GA26862@salvia>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
 <20160627142238.GA10613@breakpoint.cc>
 <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
 <20160627153820.GB10613@breakpoint.cc>
 <CAB9dFdvQ4UyKNMmOSx+FePyR0_Q425XLJRb_k5h+4JOSkQkf3w@mail.gmail.com>
 <CAB9dFds7KQxihReHhW9CXJeY9+=4BPema3ZawVA89U45QL5uBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	regressions@leemhuis.info, netfilter-devel@vger.kernel.org
To: Marc Dionne <marc.c.dionne@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB9dFds7KQxihReHhW9CXJeY9+=4BPema3ZawVA89U45QL5uBw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

On Mon, Jul 04, 2016 at 09:35:28AM -0300, Marc Dionne wrote:
> If there is no quick fix, seems like a revert should be considered:
> - Looks to me like the commit attempts to fix a long standing bug
> (exists at least as far back as 3.5,
> https://bugzilla.kernel.org/show_bug.cgi?id=52991)
> - The above bug has a simple workaround (at least for us) that we
> implemented more than 3 years ago

I guess the workaround consists of using a rule to NOTRACK this
traffic. Or there is any custom patch that you've used on your side to
resolve this?

> - The commit reverts cleanly, restoring the original behaviour
> - From that bug report, bind was one of the affected applications; I
> would suspect that this regression is likely to affect bind as well
> 
> I'd be more than happy to test suggested fixes or give feedback with
> debugging patches, etc.

Could you monitor

# conntrack -S

or alternatively (if conntrack utility not available in your system):

# cat /proc/net/stat/nf_conntrack

?

Please, watch for insert_failed and drop statistics.

Are you observing any splat or just large packet drops? Could you
compile your kernel with lockdep on and retest?

Is there any chance I can get your test file that generates the UDP
client threads to reproduce this here?

I'm also attaching a patch to drop old ct that lost race path out from
hashtable locks to avoid releasing the ct object while holding the
locks, although I couldn't come up with any interaction so far
triggering the condition that you're observing.

Thanks.

--vtzGhvizbBRQ85DL
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="x.patch"

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 62c42e9..98a71f1 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -638,7 +638,8 @@ static void nf_ct_acct_merge(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 /* Resolve race on insertion if this protocol allows this. */
 static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 			       enum ip_conntrack_info ctinfo,
-			       struct nf_conntrack_tuple_hash *h)
+			       struct nf_conntrack_tuple_hash *h,
+			       struct nf_conn **old_ct)
 {
 	/* This is the conntrack entry already in hashes that won race. */
 	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
@@ -649,7 +650,7 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 	    !nf_ct_is_dying(ct) &&
 	    atomic_inc_not_zero(&ct->ct_general.use)) {
 		nf_ct_acct_merge(ct, ctinfo, (struct nf_conn *)skb->nfct);
-		nf_conntrack_put(skb->nfct);
+		*old_ct = (struct nf_conn *)skb->nfct;
 		/* Assign conntrack already in hashes to this skbuff. Don't
 		 * modify skb->nfctinfo to ensure consistent stateful filtering.
 		 */
@@ -667,7 +668,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	const struct nf_conntrack_zone *zone;
 	unsigned int hash, reply_hash;
 	struct nf_conntrack_tuple_hash *h;
-	struct nf_conn *ct;
+	struct nf_conn *ct, *old_ct = NULL;
 	struct nf_conn_help *help;
 	struct nf_conn_tstamp *tstamp;
 	struct hlist_nulls_node *n;
@@ -771,11 +772,14 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 
 out:
 	nf_ct_add_to_dying_list(ct);
-	ret = nf_ct_resolve_clash(net, skb, ctinfo, h);
+	ret = nf_ct_resolve_clash(net, skb, ctinfo, h, &old_ct);
 dying:
 	nf_conntrack_double_unlock(hash, reply_hash);
 	NF_CT_STAT_INC(net, insert_failed);
 	local_bh_enable();
+	if (old_ct)
+		nf_ct_put(old_ct);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(__nf_conntrack_confirm);

--vtzGhvizbBRQ85DL--
