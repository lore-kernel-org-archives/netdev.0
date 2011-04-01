From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Fri, 01 Apr 2011 07:30:40 +0200
Message-ID: <1301635840.2881.19.camel@edumazet-laptop>
References: <118081298480841@web25.yandex.ru> <4D6E2BEB.50805@trash.net>
	 <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com>
	 <124481299095426@web67.yandex.ru>
	 <AANLkTik87dd0=CqcMOcwKN-Hx7W6KD7A36DUhGAzLddr@mail.gmail.com>
	 <AANLkTi=v_Ckn00N=b2R2pW7jb3BmyyWPSkeCYRxBW0CW@mail.gmail.com>
	 <586191301580222@web107.yandex.ru>
	 <1301582872.3169.44.camel@edumazet-laptop>
	 <AANLkTinBn+dKCaHN2Hq7kOocfMsvCO8wBpOgWd3VBV3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinBn+dKCaHN2Hq7kOocfMsvCO8wBpOgWd3VBV3g@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 01 avril 2011 =C3=A0 10:02 +0800, Changli Gao a =C3=A9crit =
:
> On Thu, Mar 31, 2011 at 10:47 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> >
> > I wonder if this is not hiding another bug.
> >
> > Adding an RCU grace period might reduce the probability window.
>=20
> What bug? This one?
>=20

Yes. I am saying your patch is a brown paper bag.

Real bug is elsewhere, and we must find it, not make it happen less
frequently.

Maybe its a missing barrier, and adding a full RCU grace period is a
waste (of cpu caches space, since call_rcu() fill a potential big list)

> >
> > By the time nf_conntrack_free(ct) is called, no other cpu/thread
> > could/should use ct, or ct->ext ?
>=20
> nat->ct may refer it.
>=20

conntrack must have a real problem of refcounting then.

Each time an object A has a reference to object B, we should increase B
refcount, so B cannot disappear.

nat->ct _cannot_ refer ct if we are freeing ct. Thats quite simple rule=
=2E

> >
> > Sure, another thread can find/pass_on ct in a lookup but should not=
 use
> > it, since its refcount (ct_general.use) should be 0.
> >
> >
>=20
> As SLAB_DESTROY_BY_RCU is used, we should validate ct->orig_tuple too=
=2E
>=20
> There is another minor problem.
>=20

minor or serious ?


> nf_nat_core.c:
>=20
> 133         rcu_read_lock();
> 134         hlist_for_each_entry_rcu(nat, n,
> &net->ipv4.nat_bysource[h], bysourc    e) {
> 135                 ct =3D nat->ct;
> 136                 if (same_src(ct, tuple) && nf_ct_zone(ct) =3D=3D =
zone) {
> 137                         /* Copy source part from reply tuple. */
> 138                         nf_ct_invert_tuplepr(result,
> 139
> &ct->tuplehash[IP_CT_DIR_REPLY].tuple    );
> 140                         result->dst =3D tuple->dst;
> 141
> 142                         if (in_range(result, range)) {
> 143                                 rcu_read_unlock();
> 144                                 return 1;
> 145                         }
> 146                 }
> 147         }
> 148         rcu_read_unlock();
>=20
> If the ct is reused, NAT mapping will be wrong. It isn't a serious
> problem, and can't be fixed, even though we check the reference
> counter before using it, but we can't validate it with the original
> tuple.
>=20

I call this a serious problem. netfilter is not a fuzzy logic.

> Maybe we can do it in this way
>=20
>                 ct =3D nat->ct;
>                 if (!nf_ct_is_dying(ct) &&
> atomic_inc_not_zero(&ct->ct_general.use))) {
>                                if (nf_ct_ext_find(ct, NF_CT_EXT_NAT) =
=3D=3D nat) {
>                                         /* ct is valid, do sth... */
>                                }
>                                nf_ct_put(ct);
>                 }
>=20
> I think two additional atomic operations are expensive. It isn't a go=
od idea.
>=20

It depends. This is better than taking the conntrack lock.

SLAB_DESTROY_BY_RCU is not allowing for fuzzy logic. Rules are we _must=
_
take a reference on object after finding it, and _recheck_ validity of
the object before using it.

Another way to avoid atomic operations in find_appropriate_src() is to
use a seqcount (or seqlock), and change the seqcount every time
something is changed in ct.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
