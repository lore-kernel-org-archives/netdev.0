From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Tue, 19 Feb 2008 08:40:32 +0100
Message-ID: <47BA87F0.1050709@cosmosbay.com>
References: <47B52B95.3070607@cosmosbay.com>	 <1203057044.3027.134.camel@ymzhang> <47B59FFC.4030603@cosmosbay.com>	 <20080215.152200.145584182.davem@davemloft.net>	 <1203322358.3027.200.camel@ymzhang>	 <20040.1203356033@turing-police.cc.vt.edu> <1203403903.3248.29.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762809AbYBSHky@vger.kernel.org>
In-Reply-To: <1203403903.3248.29.camel@ymzhang>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zhang, Yanmin a =C3=A9crit :
> On Mon, 2008-02-18 at 12:33 -0500, Valdis.Kletnieks@vt.edu wrote:=20
>> On Mon, 18 Feb 2008 16:12:38 +0800, "Zhang, Yanmin" said:
>>
>>> I also think __refcnt is the key. I did a new testing by adding 2 u=
nsigned long
>>> pading before lastuse, so the 3 members are moved to next cache lin=
e. The performance is
>>> recovered.
>>>
>>> How about below patch? Almost all performance is recovered with the=
 new patch.
>>>
>>> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
>> Could you add a comment someplace that says "refcnt wants to be on a=
 different
>> cache line from input/output/ops or performance tanks badly", to war=
n some
>> future kernel hacker who starts adding new fields to the structure?
> Ok. Below is the new patch.
>=20
> 1) Move tclassid under ops in case CONFIG_NET_CLS_ROUTE=3Dy. So sizeo=
f(dst_entry)=3D200
> no matter if CONFIG_NET_CLS_ROUTE=3Dy/n. I tested many patches on my =
16-core tigerton by
> moving tclassid to different place. It looks like tclassid could also=
 have impact on
> performance.
> If moving tclassid before metrics, or just don't move tclassid, the p=
erformance isn't
> good. So I move it behind metrics.
>=20
> 2) Add comments before __refcnt.
>=20
> If CONFIG_NET_CLS_ROUTE=3Dy, the result with below patch is about 18%=
 better than
> the one without the patch.
>=20
> If CONFIG_NET_CLS_ROUTE=3Dn, the result with below patch is about 30%=
 better than
> the one without the patch.
>=20
> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
>=20
> ---
>=20
> --- linux-2.6.25-rc1/include/net/dst.h	2008-02-21 14:33:43.000000000 =
+0800
> +++ linux-2.6.25-rc1_work/include/net/dst.h	2008-02-22 12:52:19.00000=
0000 +0800
> @@ -52,15 +52,10 @@ struct dst_entry
>  	unsigned short		header_len;	/* more space at head required */
>  	unsigned short		trailer_len;	/* space to reserve at tail */
> =20
> -	u32			metrics[RTAX_MAX];
> -	struct dst_entry	*path;
> -
> -	unsigned long		rate_last;	/* rate limiting for ICMP */
>  	unsigned int		rate_tokens;
> +	unsigned long		rate_last;	/* rate limiting for ICMP */
> =20
> -#ifdef CONFIG_NET_CLS_ROUTE
> -	__u32			tclassid;
> -#endif
> +	struct dst_entry	*path;
> =20
>  	struct neighbour	*neighbour;
>  	struct hh_cache		*hh;
> @@ -70,10 +65,20 @@ struct dst_entry
>  	int			(*output)(struct sk_buff*);
> =20
>  	struct  dst_ops	        *ops;
> -	=09
> -	unsigned long		lastuse;
> +
> +	u32			metrics[RTAX_MAX];
> +
> +#ifdef CONFIG_NET_CLS_ROUTE
> +	__u32			tclassid;
> +#endif
> +
> +	/*
> +	 * __refcnt wants to be on a different cache line from
> +	 * input/output/ops or performance tanks badly
> +	 */
>  	atomic_t		__refcnt;	/* client references	*/
>  	int			__use;
> +	unsigned long		lastuse;
>  	union {
>  		struct dst_entry *next;
>  		struct rtable    *rt_next;
>=20
>=20
>=20

I prefer this patch, but unfortunatly your perf numbers are for 64 bits=
 kernels.

Could you please test now with 32 bits one ?

Thank you
