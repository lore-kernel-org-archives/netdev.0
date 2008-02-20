From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Wed, 20 Feb 2008 08:38:17 +0100
Message-ID: <47BBD8E9.2090700@cosmosbay.com>
References: <47B52B95.3070607@cosmosbay.com>	 <1203057044.3027.134.camel@ymzhang> <47B59FFC.4030603@cosmosbay.com>	 <20080215.152200.145584182.davem@davemloft.net>	 <1203322358.3027.200.camel@ymzhang>	 <20040.1203356033@turing-police.cc.vt.edu>	 <1203403903.3248.29.camel@ymzhang>  <47BA87F0.1050709@cosmosbay.com> <1203491081.3248.60.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:39775
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750814AbYBTHiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 02:38:15 -0500
In-Reply-To: <1203491081.3248.60.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhang, Yanmin a =C3=A9crit :
> On Tue, 2008-02-19 at 08:40 +0100, Eric Dumazet wrote:
>> Zhang, Yanmin a =EF=BF=BDcrit :
>>> On Mon, 2008-02-18 at 12:33 -0500, Valdis.Kletnieks@vt.edu wrote:=20
>>>> On Mon, 18 Feb 2008 16:12:38 +0800, "Zhang, Yanmin" said:
>>>>
>>>>> I also think __refcnt is the key. I did a new testing by adding 2=
 unsigned long
>>>>> pading before lastuse, so the 3 members are moved to next cache l=
ine. The performance is
>>>>> recovered.
>>>>>
>>>>> How about below patch? Almost all performance is recovered with t=
he new patch.
>>>>>
>>>>> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
>>>> Could you add a comment someplace that says "refcnt wants to be on=
 a different
>>>> cache line from input/output/ops or performance tanks badly", to w=
arn some
>>>> future kernel hacker who starts adding new fields to the structure=
?
>>> Ok. Below is the new patch.
>>>
>>> 1) Move tclassid under ops in case CONFIG_NET_CLS_ROUTE=3Dy. So siz=
eof(dst_entry)=3D200
>>> no matter if CONFIG_NET_CLS_ROUTE=3Dy/n. I tested many patches on m=
y 16-core tigerton by
>>> moving tclassid to different place. It looks like tclassid could al=
so have impact on
>>> performance.
>>> If moving tclassid before metrics, or just don't move tclassid, the=
 performance isn't
>>> good. So I move it behind metrics.
>>>
>>> 2) Add comments before __refcnt.
>>>
>>> If CONFIG_NET_CLS_ROUTE=3Dy, the result with below patch is about 1=
8% better than
>>> the one without the patch.
>>>
>>> If CONFIG_NET_CLS_ROUTE=3Dn, the result with below patch is about 3=
0% better than
>>> the one without the patch.
>>>
>>> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
>>>
>>> ---
>>>
>>> --- linux-2.6.25-rc1/include/net/dst.h	2008-02-21 14:33:43.00000000=
0 +0800
>>> +++ linux-2.6.25-rc1_work/include/net/dst.h	2008-02-22 12:52:19.000=
000000 +0800
>>> @@ -52,15 +52,10 @@ struct dst_entry
>>>  	unsigned short		header_len;	/* more space at head required */
>>>  	unsigned short		trailer_len;	/* space to reserve at tail */
>>> =20
>>> -	u32			metrics[RTAX_MAX];
>>> -	struct dst_entry	*path;
>>> -
>>> -	unsigned long		rate_last;	/* rate limiting for ICMP */
>>>  	unsigned int		rate_tokens;
>>> +	unsigned long		rate_last;	/* rate limiting for ICMP */
>>> =20
>>> -#ifdef CONFIG_NET_CLS_ROUTE
>>> -	__u32			tclassid;
>>> -#endif
>>> +	struct dst_entry	*path;
>>> =20
>>>  	struct neighbour	*neighbour;
>>>  	struct hh_cache		*hh;
>>> @@ -70,10 +65,20 @@ struct dst_entry
>>>  	int			(*output)(struct sk_buff*);
>>> =20
>>>  	struct  dst_ops	        *ops;
>>> -	=09
>>> -	unsigned long		lastuse;
>>> +
>>> +	u32			metrics[RTAX_MAX];
>>> +
>>> +#ifdef CONFIG_NET_CLS_ROUTE
>>> +	__u32			tclassid;
>>> +#endif
>>> +
>>> +	/*
>>> +	 * __refcnt wants to be on a different cache line from
>>> +	 * input/output/ops or performance tanks badly
>>> +	 */
>>>  	atomic_t		__refcnt;	/* client references	*/
>>>  	int			__use;
>>> +	unsigned long		lastuse;
>>>  	union {
>>>  		struct dst_entry *next;
>>>  		struct rtable    *rt_next;
>>>
>>>
>>>
>> I prefer this patch, but unfortunatly your perf numbers are for 64 b=
its kernels.
>>
>> Could you please test now with 32 bits one ?
> I tested it with 32bit 2.6.25-rc1 on 8-core stoakley. The result almo=
st has no difference
> between pure kernel and patched kernel.
>=20
> New update: On 8-core stoakley, the regression becomes 2~3% with kern=
el 2.6.25-rc2. On
> tigerton, the regression is still 30% with 2.6.25-rc2. On Tulsa( 8 co=
res+hyperthreading),
> the regression is still 4% with 2.6.25-rc2.
>=20
> With my patch, on tigerton, almost all regression disappears. On tuls=
a, only about 2%
> regression disappears.
>=20
> So this issue is triggerred with multiple-cpu. Perhaps process schedu=
ler is another
> factor causing the issue to happen, but it's very hard to change sche=
duler.
>=20

Thanks very much Yanmin, I think we can apply your patch as is, if no=20
regression was found for 32bits.

>=20
> Eric,
>=20
> I tested your new patch in function loopback_xmit. It has no improvem=
ent, while it doesn't
> introduce new issues. As you tested it on dual-core machine and got i=
mprovement, how about
> merging your patch with mine?

No, thank you, that was an experiment and is not related to your findin=
gs on=20
dst_entry.

I am currently working on a 'distributed refcount' infrastructure, to b=
e able=20
to spread on several nodes (for NUMA machines) or several cache lines (=
normal=20
SMP machines)  the high pressure we currently have on some refcnt (stru=
ct=20
dst_entry, struct net_device, and many more refcnts ...)

Instead of NR_CPUS allocations, goal is to be able to restrict to a sma=
ll=20
value like 4, 8 or 16 the number of 32bits entities used to store one r=
efcnt,=20
even if NR_CPUS=3D4096 or so.

atomic_inc(&p->refcnt) ->  distref_inc(&p->refcnt)

distref_inc(struct distref *p)
{
	atomic_inc(myptr[p->offset]);
}

