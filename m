From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH] dst: check if dst is freed in dst_check()
Date: Wed, 21 Jul 2010 09:03:41 +0200
Message-ID: <4C469BCD.4050804@6wind.com>
References: <4C457120.9070105@6wind.com> <1279679288.2492.15.camel@edumazet-laptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39110 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933410Ab0GUHDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 03:03:46 -0400
Received: by wwj40 with SMTP id 40so1883819wwj.1
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 00:03:45 -0700 (PDT)
In-Reply-To: <1279679288.2492.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

I was thinking to use this function in sctp, but I misread xfrm part.
Sorry for the noise.


Regards,
Nicolas

Le 21.07.2010 04:28, Eric Dumazet a =C3=A9crit :
> Le mardi 20 juillet 2010 =C3=A0 11:49 +0200, Nicolas Dichtel a =C3=A9=
crit :
>> Hi,
>>
>> I probably missed something, but I cannot find where obsolete field =
is checked=20
>> when dst_check() is called. If dst->obsolete is > 1, dst cannot be u=
sed!
>>
>> Attached is a proposal to fix this issue.
>>
>>
>=20
>> diff --git a/include/net/dst.h b/include/net/dst.h
>> index 81d1413..7bf4f9a 100644
>> --- a/include/net/dst.h
>> +++ b/include/net/dst.h
>> @@ -319,6 +319,8 @@ static inline int dst_input(struct sk_buff *skb)
>> =20
>>  static inline struct dst_entry *dst_check(struct dst_entry *dst, u3=
2 cookie)
>>  {
>> +	if (dst->obsolete > 1)
>> +		return NULL;
>>  	if (dst->obsolete)
>>  		dst =3D dst->ops->check(dst, cookie);
>>  	return dst;
>=20
> I believe this is not needed and redundant.
>=20
> In what case do you think this matters ?
>=20
> To my knowledge dst_check() is only used by net/xfrm/xfrm_policy.c
>=20
> And xfrm_dst_check() does the necessary checks.
>=20
> static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 co=
okie)
> {
>         /* Code (such as __xfrm4_bundle_create()) sets dst->obsolete
>          * to "-1" to force all XFRM destinations to get validated by
>          * dst_ops->check on every use.  We do this because when a
>          * normal route referenced by an XFRM dst is obsoleted we do
>          * not go looking around for all parent referencing XFRM dsts
>          * so that we can invalidate them.  It is just too much work.
>          * Instead we make the checks here on every use.  For example=
:
>          *
>          *      XFRM dst A --> IPv4 dst X
>          *
>          * X is the "xdst->route" of A (X is also the "dst->path" of =
A
>          * in this example).  If X is marked obsolete, "A" will not
>          * notice.  That's what we are validating here via the
>          * stale_bundle() check.
>          *
>          * When a policy's bundle is pruned, we dst_free() the XFRM
>          * dst which causes it's ->obsolete field to be set to a
>          * positive non-zero integer.  If an XFRM dst has been pruned
>          * like this, we want to force a new route lookup.
>          */
>         if (dst->obsolete < 0 && !stale_bundle(dst))
>                 return dst;
>=20
>         return NULL;
> }
