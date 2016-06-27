From: Florian Westphal <fw@strlen.de>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Mon, 27 Jun 2016 17:38:20 +0200
Message-ID: <20160627153820.GB10613@breakpoint.cc>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
 <20160627142238.GA10613@breakpoint.cc>
 <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Marc Dionne <marc.c.dionne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42406 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751638AbcF0Pi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 11:38:26 -0400
Content-Disposition: inline
In-Reply-To: <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Dionne <marc.c.dionne@gmail.com> wrote:
> On Mon, Jun 27, 2016 at 11:22 AM, Florian Westphal <fw@strlen.de> wrote:
> > Marc Dionne <marc.c.dionne@gmail.com> wrote:
> >> Hi,

> >         hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[hash], hnnode)
> >                 if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
> > -                                   zone, net))
> > -                       goto out;
> > +                                   zone, net)) {
> > +                       nf_ct_add_to_dying_list(ct);
> > +                       ret = nf_ct_resolve_clash(net, skb, ctinfo, h);
> > +                       goto dying;
> > +               }

This is bogus as h can be a reply too (key compare does not deal
with it).

Below is what I actually intended; I can't come up with a reason why
you experience this issue other than that we're getting confused over
reply/original direction.

If the patch doesn't help either, can you tell us what kind of iptables
rules are installed on the affected system or perhaps report perf drop
monitor stat when things go wrong?

Thanks!

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -638,6 +638,12 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
 	struct nf_conntrack_l4proto *l4proto;
 
+	/* skb being confirmed is always original dir; do not attach to
+	 * a reply tuple.
+	 */
+	if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
+		goto out;
+
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto->allow_clash &&
 	    !nf_ct_is_dying(ct) &&
@@ -650,6 +656,7 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 		skb->nfct = &ct->ct_general;
 		return NF_ACCEPT;
 	}
+ out:
 	NF_CT_STAT_INC(net, drop);
 	return NF_DROP;
 }
