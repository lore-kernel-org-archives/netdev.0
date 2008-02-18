From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Mon, 18 Feb 2008 09:39:06 +0800
Message-ID: <1203298746.3027.179.camel@ymzhang>
References: <1203040321.3027.131.camel@ymzhang>
	 <47B52B95.3070607@cosmosbay.com> <1203057044.3027.134.camel@ymzhang>
	 <47B59FFC.4030603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:10078 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751814AbYBRBoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2008 20:44:17 -0500
In-Reply-To: <47B59FFC.4030603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-02-15 at 15:21 +0100, Eric Dumazet wrote:
> Zhang, Yanmin a =C3=A9crit :
> > On Fri, 2008-02-15 at 07:05 +0100, Eric Dumazet wrote:
> >  =20
> >> Zhang, Yanmin a =EF=BF=BDcrit :
> >>    =20
> >>> Comparing with kernel 2.6.24, tbench result has regression with
> >>> 2.6.25-rc1.
> >>>
> >>> 1) On 2 quad-core processor stoakley: 4%.
> >>> 2) On 4 quad-core processor tigerton: more than 30%.
> >>>
> >>> bisect located below patch.
> >>>
> >>> b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b is first bad commit
> >>> commit b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b
> >>> Author: Herbert Xu <herbert@gondor.apana.org.au>
> >>> Date:   Tue Nov 13 21:33:32 2007 -0800
> >>>
> >>>     [IPV6]: Move nfheader_len into rt6_info
> >>>    =20
> >>>     The dst member nfheader_len is only used by IPv6.  It's also =
currently
> >>>     creating a rather ugly alignment hole in struct dst.  Therefo=
re this patch
> >>>     moves it from there into struct rt6_info.
> >>>
> >>>
> >>> As tbench uses ipv4, so the patch's real impact on ipv4 is it del=
etes
> >>> nfheader_len in dst_entry. It might change cache line alignment.
> >>>
> >>> To verify my finding, I just added nfheader_len back to dst_entry=
 in 2.6.25-rc1
> >>> and reran tbench on the 2 machines. Performance could be recovere=
d completely.
> >>>
> >>> I started cpu_number*2 tbench processes. On my 16-core tigerton:
> >>> #./tbench_srv &
> >>> #./tbench 32 127.0.0.1
> >>>
> >>> -yanmin
> >>>      =20
> >> Yup. struct dst is sensitive to alignements, especially for benche=
s.
> >>
> >> In the real world, we need to make sure that next pointer start at=
 a cache=20
> >> line bondary (or a litle bit after), so that RT cache lookups use =
one cache=20
> >> line per entry instead of two. This permits better behavior in DDO=
S attacks.
> >>
> >> (check commit 1e19e02ca0c5e33ea73a25127dbe6c3b8fcaac4b for referen=
ce)
> >>
> >> Are you using a 64 or a 32 bit kernel ?
> >>    =20
> > 64bit x86-64 machine. On another 4-way Madison Itanium machine, tbe=
nch has the
> > similiar regression.
> >
> >  =20
>=20
> On linux-2.6.25-rc1 x86_64 :
>=20
> offsetof(struct dst_entry, lastuse)=3D0xb0
> offsetof(struct dst_entry, __refcnt)=3D0xb8
> offsetof(struct dst_entry, __use)=3D0xbc
> offsetof(struct dst_entry, next)=3D0xc0
>=20
> So it should be optimal... I dont know why tbench prefers __refcnt be=
ing=20
> on 0xc0, since in this case lastuse will be on a different cache line=
=2E..
>=20
> Each incoming IP packet will need to change lastuse, __refcnt and __u=
se,=20
> so keeping them in the same cache line is a win.
>=20
> I suspect then that even this patch could help tbench, since it avoid=
s=20
> writing lastuse...
>=20
> diff --git a/include/net/dst.h b/include/net/dst.h
> index e3ac7d0..24d3c4e 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -147,7 +147,8 @@ static inline void dst_use(struct dst_entry *dst,=
=20
> unsigned long time)
>  {
>         dst_hold(dst);
>         dst->__use++;
> -       dst->lastuse =3D time;
> +       if (time !=3D dst->lastuse)
> +               dst->lastuse =3D time;
>  }
I did a quick test and this patch doesn't help tbench.

Thanks,
-yanmin


