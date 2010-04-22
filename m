From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 16:36:01 +0200
Message-ID: <1271946961.7895.5665.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BD04C74.9020402@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 22 avril 2010 =C3=A0 15:17 +0200, Patrick McHardy a =C3=A9crit=
 :
> Changli Gao wrote:
> > On Thu, Apr 22, 2010 at 8:58 PM, Jesper Dangaard Brouer <hawk@comx.=
dk> wrote:
> >> At an unnamed ISP, we experienced a DDoS attack against one of our
> >> customers.  This attack also caused problems for one of our Linux
> >> based routers.
> >>
> >> The attack was "only" generating 300 kpps (packets per sec), which
> >> usually isn't a problem for this (fairly old) Linux Router.  But t=
he
> >> conntracking system chocked and reduced pps processing power to
> >> 40kpps.
> >>
> >> I do extensive RRD/graph monitoring of the machines.  The IP connt=
rack
> >> searches in the period exploded, to a stunning 700.000 searches pe=
r
> >> sec.
> >>
> >> http://people.netfilter.org/hawk/DDoS/2010-04-12__001/conntrack_se=
arches001.png
> >>
> >> First I though it might be caused by bad hashing, but after readin=
g
> >> the kernel code (func: __nf_conntrack_find()), I think its caused =
by
> >> the loop restart (goto begin) of the conntrack search, running und=
er
> >> local_bh_disable().  These RCU changes to conntrack were introduce=
d in
> >> ea781f19 by Eric Dumazet.
> >>
> >> Code: net/netfilter/nf_conntrack_core.c
> >> Func: __nf_conntrack_find()
> >>
> >> struct nf_conntrack_tuple_hash *
> >> __nf_conntrack_find(struct net *net, const struct nf_conntrack_tup=
le *tuple)
> >> {
> >>        struct nf_conntrack_tuple_hash *h;
> >>        struct hlist_nulls_node *n;
> >>        unsigned int hash =3D hash_conntrack(tuple);
> >>
> >>        /* Disable BHs the entire time since we normally need to di=
sable them
> >>         * at least once for the stats anyway.
> >>         */
> >>        local_bh_disable();
> >> begin:
> >>        hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], h=
nnode) {
> >>                if (nf_ct_tuple_equal(tuple, &h->tuple)) {
> >>                        NF_CT_STAT_INC(net, found);
> >>                        local_bh_enable();
> >>                        return h;
> >>                }
> >>                NF_CT_STAT_INC(net, searched);
> >>        }
> >>        /*
> >>         * if the nulls value we got at the end of this lookup is
> >>         * not the expected one, we must restart lookup.
> >>         * We probably met an item that was moved to another chain.
> >>         */
> >>        if (get_nulls_value(n) !=3D hash)
> >>                goto begin;
> >>        local_bh_enable();
> >>
> >=20
> > We should add a retry limit there.
>=20
> We can't do that since that would allow false negatives.

If one hash slot is under attack, then there is a bug somewhere.

If we cannot avoid this, we can fallback to a secure mode at the second
retry, and take the spinlock.

Tis way, most of lookups stay lockless (one pass), and some might take
the slot lock to avoid the possibility of a loop.

I suspect a bug elsewhere, quite frankly !

We have a chain that have an end pointer that doesnt match the expected
one.




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
