From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Fri, 15 Feb 2008 15:21:48 +0100
Message-ID: <47B59FFC.4030603@cosmosbay.com>
References: <1203040321.3027.131.camel@ymzhang>	 <47B52B95.3070607@cosmosbay.com> <1203057044.3027.134.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.orange.fr ([193.252.22.22]:15089 "EHLO smtp25.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934702AbYBOOVz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 09:21:55 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2526.orange.fr (SMTP Server) with ESMTP id 8EE7D1C000A4
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 15:21:53 +0100 (CET)
In-Reply-To: <1203057044.3027.134.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhang, Yanmin a =C3=A9crit :
> On Fri, 2008-02-15 at 07:05 +0100, Eric Dumazet wrote:
>  =20
>> Zhang, Yanmin a =EF=BF=BDcrit :
>>    =20
>>> Comparing with kernel 2.6.24, tbench result has regression with
>>> 2.6.25-rc1.
>>>
>>> 1) On 2 quad-core processor stoakley: 4%.
>>> 2) On 4 quad-core processor tigerton: more than 30%.
>>>
>>> bisect located below patch.
>>>
>>> b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b is first bad commit
>>> commit b4ce92775c2e7ff9cf79cca4e0a19c8c5fd6287b
>>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>>> Date:   Tue Nov 13 21:33:32 2007 -0800
>>>
>>>     [IPV6]: Move nfheader_len into rt6_info
>>>    =20
>>>     The dst member nfheader_len is only used by IPv6.  It's also cu=
rrently
>>>     creating a rather ugly alignment hole in struct dst.  Therefore=
 this patch
>>>     moves it from there into struct rt6_info.
>>>
>>>
>>> As tbench uses ipv4, so the patch's real impact on ipv4 is it delet=
es
>>> nfheader_len in dst_entry. It might change cache line alignment.
>>>
>>> To verify my finding, I just added nfheader_len back to dst_entry i=
n 2.6.25-rc1
>>> and reran tbench on the 2 machines. Performance could be recovered =
completely.
>>>
>>> I started cpu_number*2 tbench processes. On my 16-core tigerton:
>>> #./tbench_srv &
>>> #./tbench 32 127.0.0.1
>>>
>>> -yanmin
>>>      =20
>> Yup. struct dst is sensitive to alignements, especially for benches.
>>
>> In the real world, we need to make sure that next pointer start at a=
 cache=20
>> line bondary (or a litle bit after), so that RT cache lookups use on=
e cache=20
>> line per entry instead of two. This permits better behavior in DDOS =
attacks.
>>
>> (check commit 1e19e02ca0c5e33ea73a25127dbe6c3b8fcaac4b for reference=
)
>>
>> Are you using a 64 or a 32 bit kernel ?
>>    =20
> 64bit x86-64 machine. On another 4-way Madison Itanium machine, tbenc=
h has the
> similiar regression.
>
>  =20

On linux-2.6.25-rc1 x86_64 :

offsetof(struct dst_entry, lastuse)=3D0xb0
offsetof(struct dst_entry, __refcnt)=3D0xb8
offsetof(struct dst_entry, __use)=3D0xbc
offsetof(struct dst_entry, next)=3D0xc0

So it should be optimal... I dont know why tbench prefers __refcnt bein=
g=20
on 0xc0, since in this case lastuse will be on a different cache line..=
=2E

Each incoming IP packet will need to change lastuse, __refcnt and __use=
,=20
so keeping them in the same cache line is a win.

I suspect then that even this patch could help tbench, since it avoids=20
writing lastuse...

diff --git a/include/net/dst.h b/include/net/dst.h
index e3ac7d0..24d3c4e 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -147,7 +147,8 @@ static inline void dst_use(struct dst_entry *dst,=20
unsigned long time)
 {
        dst_hold(dst);
        dst->__use++;
-       dst->lastuse =3D time;
+       if (time !=3D dst->lastuse)
+               dst->lastuse =3D time;
 }







