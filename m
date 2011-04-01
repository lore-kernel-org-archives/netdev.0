From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Fri, 1 Apr 2011 10:02:03 +0800
Message-ID: <AANLkTinBn+dKCaHN2Hq7kOocfMsvCO8wBpOgWd3VBV3g@mail.gmail.com>
References: <118081298480841@web25.yandex.ru> <4D6E2BEB.50805@trash.net>
 <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com>
 <124481299095426@web67.yandex.ru> <AANLkTik87dd0=CqcMOcwKN-Hx7W6KD7A36DUhGAzLddr@mail.gmail.com>
 <AANLkTi=v_Ckn00N=b2R2pW7jb3BmyyWPSkeCYRxBW0CW@mail.gmail.com>
 <586191301580222@web107.yandex.ru> <1301582872.3169.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1301582872.3169.44.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2011 at 10:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> I wonder if this is not hiding another bug.
>
> Adding an RCU grace period might reduce the probability window.

What bug? This one?

>
> By the time nf_conntrack_free(ct) is called, no other cpu/thread
> could/should use ct, or ct->ext ?

nat->ct may refer it.

>
> Sure, another thread can find/pass_on ct in a lookup but should not use
> it, since its refcount (ct_general.use) should be 0.
>
>

As SLAB_DESTROY_BY_RCU is used, we should validate ct->orig_tuple too.

There is another minor problem.

nf_nat_core.c:

133         rcu_read_lock();
134         hlist_for_each_entry_rcu(nat, n,
&net->ipv4.nat_bysource[h], bysourc    e) {
135                 ct = nat->ct;
136                 if (same_src(ct, tuple) && nf_ct_zone(ct) == zone) {
137                         /* Copy source part from reply tuple. */
138                         nf_ct_invert_tuplepr(result,
139
&ct->tuplehash[IP_CT_DIR_REPLY].tuple    );
140                         result->dst = tuple->dst;
141
142                         if (in_range(result, range)) {
143                                 rcu_read_unlock();
144                                 return 1;
145                         }
146                 }
147         }
148         rcu_read_unlock();

If the ct is reused, NAT mapping will be wrong. It isn't a serious
problem, and can't be fixed, even though we check the reference
counter before using it, but we can't validate it with the original
tuple.

Maybe we can do it in this way

                ct = nat->ct;
                if (!nf_ct_is_dying(ct) &&
atomic_inc_not_zero(&ct->ct_general.use))) {
                               if (nf_ct_ext_find(ct, NF_CT_EXT_NAT) == nat) {
                                        /* ct is valid, do sth... */
                               }
                               nf_ct_put(ct);
                }

I think two additional atomic operations are expensive. It isn't a good idea.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
