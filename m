From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] Question about potential problem in net/ipv4/route.c
Date: Thu, 12 Oct 2006 08:35:47 +0200
Message-ID: <452DE243.7050903@cosmosbay.com>
References: <200610111511.19028.dada1@cosmosbay.com>
 <20061011.220506.76273501.davem@davemloft.net>
 <452DD724.4030502@cosmosbay.com>
 <20061011.230233.122062793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:25243 "EHLO smTp.neuf.fr")
	by vger.kernel.org with ESMTP id S932483AbWJLGfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 02:35:43 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604003mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J70009S4FNIYY00@sp604003mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Thu, 12 Oct 2006 08:35:42 +0200 (CEST)
In-reply-to: <20061011.230233.122062793.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 12 Oct 2006 07:48:20 +0200
>=20
>> Not on my gcc here (gcc version 3.4.4) : It wont zeros out the paddi=
ng bytes
>=20
> Patrick just proved this too :)
>=20
>> Well, on this machine I have these oprofile numbers :
>>
>> <rt_intern_hash>: /* rt_intern_hash total: 993464  0.3619 */
>>
>>   31751  0.0116 :ffffffff803e8d26:   repz cmpsb %es:(%rdi),%ds:(%rsi=
)
>> 433438  0.1579 :ffffffff803e8d28:   jne    ffffffff803e8f80 <rt_inte=
rn_hash+0x310>
>=20
> Indeed, numbers talk bullshit walks :)
>=20
> How about something like this as a start?
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index c41ddba..4d4b1bd 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -566,9 +566,13 @@ static inline u32 rt_score(struct rtable
> =20
>  static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
>  {
> -	return memcmp(&fl1->nl_u.ip4_u, &fl2->nl_u.ip4_u, sizeof(fl1->nl_u.=
ip4_u)) =3D=3D 0 &&
> -	       fl1->oif     =3D=3D fl2->oif &&
> -	       fl1->iif     =3D=3D fl2->iif;
> +	return ((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
> +		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |
> +		(fl1->nl_u.ip4_u.fwmark ^ fl2->nl_u.ip4_u.fwmark) |
> +		(*(u16 *)&fl1->nl_u.ip4_u.tos ^
> +		 *(u16 *)&fl2->nl_u.ip4_u.tos) |
> +		(fl1->oif ^ fl2->oif) |
> +		(fl1->iif ^ fl2->iif)) =3D=3D 0;
>  }
> =20
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
>=20
>=20

Yes it seems a nice start :)

How about avoiding the fwmark thing if !CONFIG_IP_ROUTE_FWMARK

 > +	return ((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
 > +		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |

#ifdef CONFIG_IP_ROUTE_FWMARK

 > +		(fl1->nl_u.ip4_u.fwmark ^ fl2->nl_u.ip4_u.fwmark) |

#endif

 > +		(*(u16 *)&fl1->nl_u.ip4_u.tos ^
 > +		 *(u16 *)&fl2->nl_u.ip4_u.tos) |
 > +		(fl1->oif ^ fl2->oif) |
 > +		(fl1->iif ^ fl2->iif)) =3D=3D 0;


Eric

