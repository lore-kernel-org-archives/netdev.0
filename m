From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Fri, 15 Feb 2008 07:05:09 +0100
Message-ID: <47B52B95.3070607@cosmosbay.com>
References: <1203040321.3027.131.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764421AbYBOGFc@vger.kernel.org>
In-Reply-To: <1203040321.3027.131.camel@ymzhang>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zhang, Yanmin a =C3=A9crit :
> Comparing with kernel 2.6.24, tbench result has regression with
> 2.6.25-rc1.
>=20
> 1) On 2 quad-core processor stoakley: 4%.
> 2) On 4 quad-core processor tigerton: more than 30%.
>=20
> bisect located below patch.
>=20
> b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b is first bad commit
> commit b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Tue Nov 13 21:33:32 2007 -0800
>=20
>     [IPV6]: Move nfheader_len into rt6_info
>    =20
>     The dst member nfheader_len is only used by IPv6.  It's also curr=
ently
>     creating a rather ugly alignment hole in struct dst.  Therefore t=
his patch
>     moves it from there into struct rt6_info.
>=20
>=20
> As tbench uses ipv4, so the patch's real impact on ipv4 is it deletes
> nfheader_len in dst_entry. It might change cache line alignment.
>=20
> To verify my finding, I just added nfheader_len back to dst_entry in =
2.6.25-rc1
> and reran tbench on the 2 machines. Performance could be recovered co=
mpletely.
>=20
> I started cpu_number*2 tbench processes. On my 16-core tigerton:
> #./tbench_srv &
> #./tbench 32 127.0.0.1
>=20
> -yanmin

Yup. struct dst is sensitive to alignements, especially for benches.

In the real world, we need to make sure that next pointer start at a ca=
che=20
line bondary (or a litle bit after), so that RT cache lookups use one c=
ache=20
line per entry instead of two. This permits better behavior in DDOS att=
acks.

(check commit 1e19e02ca0c5e33ea73a25127dbe6c3b8fcaac4b for reference)

Are you using a 64 or a 32 bit kernel ?
