From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Wed, 20 Feb 2008 15:04:41 +0800
Message-ID: <1203491081.3248.60.camel@ymzhang>
References: <47B52B95.3070607@cosmosbay.com>
	 <1203057044.3027.134.camel@ymzhang> <47B59FFC.4030603@cosmosbay.com>
	 <20080215.152200.145584182.davem@davemloft.net>
	 <1203322358.3027.200.camel@ymzhang>
	 <20040.1203356033@turing-police.cc.vt.edu>
	 <1203403903.3248.29.camel@ymzhang>  <47BA87F0.1050709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:48363 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751957AbYBTHGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 02:06:19 -0500
In-Reply-To: <47BA87F0.1050709@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-02-19 at 08:40 +0100, Eric Dumazet wrote:
> Zhang, Yanmin a =E9crit :
> > On Mon, 2008-02-18 at 12:33 -0500, Valdis.Kletnieks@vt.edu wrote:=20
> >> On Mon, 18 Feb 2008 16:12:38 +0800, "Zhang, Yanmin" said:
> >>
> >>> I also think __refcnt is the key. I did a new testing by adding 2=
 unsigned long
> >>> pading before lastuse, so the 3 members are moved to next cache l=
ine. The performance is
> >>> recovered.
> >>>
> >>> How about below patch? Almost all performance is recovered with t=
he new patch.
> >>>
> >>> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
> >> Could you add a comment someplace that says "refcnt wants to be on=
 a different
> >> cache line from input/output/ops or performance tanks badly", to w=
arn some
> >> future kernel hacker who starts adding new fields to the structure=
?
> > Ok. Below is the new patch.
> >=20
> > 1) Move tclassid under ops in case CONFIG_NET_CLS_ROUTE=3Dy. So siz=
eof(dst_entry)=3D200
> > no matter if CONFIG_NET_CLS_ROUTE=3Dy/n. I tested many patches on m=
y 16-core tigerton by
> > moving tclassid to different place. It looks like tclassid could al=
so have impact on
> > performance.
> > If moving tclassid before metrics, or just don't move tclassid, the=
 performance isn't
> > good. So I move it behind metrics.
> >=20
> > 2) Add comments before __refcnt.
> >=20
> > If CONFIG_NET_CLS_ROUTE=3Dy, the result with below patch is about 1=
8% better than
> > the one without the patch.
> >=20
> > If CONFIG_NET_CLS_ROUTE=3Dn, the result with below patch is about 3=
0% better than
> > the one without the patch.
> >=20
> > Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
> >=20
> > ---
> >=20
> > --- linux-2.6.25-rc1/include/net/dst.h	2008-02-21 14:33:43.00000000=
0 +0800
> > +++ linux-2.6.25-rc1_work/include/net/dst.h	2008-02-22 12:52:19.000=
000000 +0800
> > @@ -52,15 +52,10 @@ struct dst_entry
> >  	unsigned short		header_len;	/* more space at head required */
> >  	unsigned short		trailer_len;	/* space to reserve at tail */
> > =20
> > -	u32			metrics[RTAX_MAX];
> > -	struct dst_entry	*path;
> > -
> > -	unsigned long		rate_last;	/* rate limiting for ICMP */
> >  	unsigned int		rate_tokens;
> > +	unsigned long		rate_last;	/* rate limiting for ICMP */
> > =20
> > -#ifdef CONFIG_NET_CLS_ROUTE
> > -	__u32			tclassid;
> > -#endif
> > +	struct dst_entry	*path;
> > =20
> >  	struct neighbour	*neighbour;
> >  	struct hh_cache		*hh;
> > @@ -70,10 +65,20 @@ struct dst_entry
> >  	int			(*output)(struct sk_buff*);
> > =20
> >  	struct  dst_ops	        *ops;
> > -	=09
> > -	unsigned long		lastuse;
> > +
> > +	u32			metrics[RTAX_MAX];
> > +
> > +#ifdef CONFIG_NET_CLS_ROUTE
> > +	__u32			tclassid;
> > +#endif
> > +
> > +	/*
> > +	 * __refcnt wants to be on a different cache line from
> > +	 * input/output/ops or performance tanks badly
> > +	 */
> >  	atomic_t		__refcnt;	/* client references	*/
> >  	int			__use;
> > +	unsigned long		lastuse;
> >  	union {
> >  		struct dst_entry *next;
> >  		struct rtable    *rt_next;
> >=20
> >=20
> >=20
>=20
> I prefer this patch, but unfortunatly your perf numbers are for 64 bi=
ts kernels.
>=20
> Could you please test now with 32 bits one ?
I tested it with 32bit 2.6.25-rc1 on 8-core stoakley. The result almost=
 has no difference
between pure kernel and patched kernel.

New update: On 8-core stoakley, the regression becomes 2~3% with kernel=
 2.6.25-rc2. On
tigerton, the regression is still 30% with 2.6.25-rc2. On Tulsa( 8 core=
s+hyperthreading),
the regression is still 4% with 2.6.25-rc2.

With my patch, on tigerton, almost all regression disappears. On tulsa,=
 only about 2%
regression disappears.

So this issue is triggerred with multiple-cpu. Perhaps process schedule=
r is another
factor causing the issue to happen, but it's very hard to change schedu=
ler.


Eric,

I tested your new patch in function loopback_xmit. It has no improvemen=
t, while it doesn't
introduce new issues. As you tested it on dual-core machine and got imp=
rovement, how about
merging your patch with mine?

-yanmin


