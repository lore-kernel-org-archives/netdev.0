From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 21:13:48 +0800
Message-ID: <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
References: <1271941082.14501.189.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: hawk@comx.dk
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1271941082.14501.189.camel@jdb-workstation>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 22, 2010 at 8:58 PM, Jesper Dangaard Brouer <hawk@comx.dk> =
wrote:
>
> At an unnamed ISP, we experienced a DDoS attack against one of our
> customers. =C2=A0This attack also caused problems for one of our Linu=
x
> based routers.
>
> The attack was "only" generating 300 kpps (packets per sec), which
> usually isn't a problem for this (fairly old) Linux Router. =C2=A0But=
 the
> conntracking system chocked and reduced pps processing power to
> 40kpps.
>
> I do extensive RRD/graph monitoring of the machines. =C2=A0The IP con=
ntrack
> searches in the period exploded, to a stunning 700.000 searches per
> sec.
>
> http://people.netfilter.org/hawk/DDoS/2010-04-12__001/conntrack_searc=
hes001.png
>
> First I though it might be caused by bad hashing, but after reading
> the kernel code (func: __nf_conntrack_find()), I think its caused by
> the loop restart (goto begin) of the conntrack search, running under
> local_bh_disable(). =C2=A0These RCU changes to conntrack were introdu=
ced in
> ea781f19 by Eric Dumazet.
>
> Code: net/netfilter/nf_conntrack_core.c
> Func: __nf_conntrack_find()
>
> struct nf_conntrack_tuple_hash *
> __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple =
*tuple)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct nf_conntrack_tuple_hash *h;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct hlist_nulls_node *n;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int hash =3D hash_conntrack(tuple=
);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable BHs the entire time since we no=
rmally need to disable them
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * at least once for the stats anyway.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_bh_disable();
> begin:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0hlist_nulls_for_each_entry_rcu(h, n, &net-=
>ct.hash[hash], hnnode) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nf_ct_tupl=
e_equal(tuple, &h->tuple)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0NF_CT_STAT_INC(net, found);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0local_bh_enable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return h;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0NF_CT_STAT_INC=
(net, searched);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * if the nulls value we got at the end of=
 this lookup is
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * not the expected one, we must restart l=
ookup.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * We probably met an item that was moved =
to another chain.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (get_nulls_value(n) !=3D hash)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto begin;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_bh_enable();
>

We should add a retry limit there.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
