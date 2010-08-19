From: yao zhao <dragonlinux@gmail.com>
Subject: Re: [PATCH v2] netfilter: save the hash of the tuple in the original
 direction for latter use
Date: Thu, 19 Aug 2010 11:41:44 -0400
Message-ID: <AANLkTikB6eggCzHuPZo9gHQyN66M_wuaahzAe2PM1M9F@mail.gmail.com>
References: <1282228389-3029-1-git-send-email-xiaosuo@gmail.com>
	<20100819152149.GA19744@Krystal>
	<AANLkTim5wn0Y-+081gvm7FkWx3NioRvtRMWy2uF4nji2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim5wn0Y-+081gvm7FkWx3NioRvtRMWy2uF4nji2@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 19, 2010 at 11:35 AM, Changli Gao <xiaosuo@gmail.com> wrote=
:
> On Thu, Aug 19, 2010 at 11:21 PM, Mathieu Desnoyers
> <mathieu.desnoyers@polymtl.ca> wrote:
>> * Changli Gao (xiaosuo@gmail.com) wrote:
>>> Since we don't change the tuple in the original direction, we can s=
ave it
>>> in ct->tuplehash[IP_CT_DIR_REPLY].hnode.pprev for __nf_conntrack_co=
nfirm()
>>> use.
>>>
>>> __hash_conntrack() is split into two steps: ____hash_conntrack() is=
 used
>>> to get the raw hash, and __hash_bucket() is used to get the bucket =
id.
>>>
>>> In SYN-flood case, early_drop() doesn't need to recompute the hash =
again.
>>>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>> ---
>>> v2: use cmpxchg() to save 2 variables.
>>> =A0net/netfilter/nf_conntrack_core.c | =A0114 +++++++++++++++++++++=
+++++------------
>>> =A01 file changed, 79 insertions(+), 35 deletions(-)
>>> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_c=
onntrack_core.c
>>> index df3eedb..0e02205 100644
>>> --- a/net/netfilter/nf_conntrack_core.c
>>> +++ b/net/netfilter/nf_conntrack_core.c
>>> @@ -65,14 +65,20 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
>>> =A0DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
>>> =A0EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
>>>
>>> -static int nf_conntrack_hash_rnd_initted;
>>> -static unsigned int nf_conntrack_hash_rnd;
>>> -
>>> -static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple =
*tuple,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 z=
one, unsigned int size, unsigned int rnd)
>>> +static u32 ____hash_conntrack(const struct nf_conntrack_tuple *tup=
le, u16 zone)
>>> =A0{
>>> =A0 =A0 =A0 unsigned int n;
>>> =A0 =A0 =A0 u_int32_t h;
>>> + =A0 =A0 static unsigned int rnd;
>>
>> Why are you putting a hidden static variable here ? It should probab=
ly
>> be declared outside of the function scope.
>
> It is only used in this function.

Looks like it is only initialized once to rnd then it should go a "init=
".

>
>>
>>> +
>>> + =A0 =A0 if (unlikely(!rnd)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 unsigned int rand;
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 get_random_bytes(&rand, sizeof(rand));
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!rand)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rand =3D 1;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 cmpxchg(&rnd, 0, rand);
>>
>> This really belongs to a "init()" function, not in a dynamic check i=
n
>> the __hash_conntrack hot path. If you do that a init time, then you
>> don't even need the cmpxchg.
>>
>> Or maybe I completely misunderstand you goal here; maybe you are rea=
lly
>> trying to re-calculate random bytes. But more explanation is called =
for,
>> because I really don't see where the value is brought back to 0.
>>
>
> In fact, I don't know the reason clearly. This code is derived from
> the older one. Maybe there isn't enough entropy when initializing.
>
> --
> Regards,
> Changli Gao(xiaosuo@gmail.com)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

yao
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
