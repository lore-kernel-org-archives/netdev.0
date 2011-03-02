From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Wed, 2 Mar 2011 22:37:11 +0800
Message-ID: <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com>
References: <118081298480841@web25.yandex.ru> <4D6E2BEB.50805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Oleg A. Arkhangelsky" <sysoleg@yandex.ru>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D6E2BEB.50805@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 2, 2011 at 7:37 PM, Patrick McHardy <kaber@trash.net> wrote=
:
> Am 23.02.2011 18:07, schrieb "Oleg A. Arkhangelsky":
>> Hello,
>>
>> Got this panic yesterday:
>> http://www.progtech.ru/~oleg/crash.txt
>>
>> The offending instruction is:
>> cmpb 54(%edx), %cl # <variable>.tuple.dst.protonum,
>>
>> and here is the assembler code of net/ipv4/netfilter/nf_nat_core.c:
>> http://www.progtech.ru/~oleg/nf_nat_core.s
>>
>> Quick investigation lead me to conclusion that the problem is in
>> return of same_src function:
>>
>> =A0 =A0 =A0 =A0 return (t->dst.protonum =3D=3D tuple->dst.protonum &=
&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 t->src.u3.ip =3D=3D tuple->src.u3.ip=
 &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 t->src.u.all =3D=3D tuple->src.u.all=
);
>>
>> So either t or tuple pointer is bad, but I don't understand how
>> this can be.
>

t should be NULL here, as offsetof(struct nf_conn, dst.protonum) =3D=3D=
 0x36.
We should free the nf_ct_extend with call_rcu(), since nat ext is
referenced in the rcu read context.

 717 void nf_conntrack_free(struct nf_conn *ct)
 718 {
 719         struct net *net =3D nf_ct_net(ct);
 720
 721         nf_ct_ext_destroy(ct);
 722         atomic_dec(&net->ct.count);
 723         nf_ct_ext_free(ct);

if (ct->ext)
   call_rcu(&ct->ext->rcu, __nf_ct_ext_free_rcu);

 724         kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
 725 }
 726 EXPORT_SYMBOL_GPL(nf_conntrack_free);

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
