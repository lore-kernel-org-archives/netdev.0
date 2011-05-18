From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 09:32:07 -0400
Message-ID: <4DD3CA57.5060709@hp.com>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>	<1305704885.2983.4.camel@edumazet-laptop>	<BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>	<1305707358.2983.14.camel@edumazet-laptop>	<4DD38B30.9090601@cn.fujitsu.com>	<4DD3BC8F.9050802@hp.com>	<BANLkTinQAy+jq_VUwky2rxchomuN3avPQg@mail.gmail.com>	<1305723046.2991.19.camel@edumazet-laptop> <BANLkTi=cDwLFSqaBt5szaFOaWmxYzkya9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>, netdev@vger.kernel.org
To: Jacek Luczak <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:43574 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932801Ab1ERNoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 09:44:09 -0400
In-Reply-To: <BANLkTi=cDwLFSqaBt5szaFOaWmxYzkya9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2011 09:11 AM, Jacek Luczak wrote:
> 2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:
>> Le mercredi 18 mai 2011 =E0 14:47 +0200, Jacek Luczak a =E9crit :
>>
>>> OK then, at the end what Eric suggested is IMO valid:
>>>
>>> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
>>> index faf71d1..0025d90 100644
>>> --- a/net/sctp/bind_addr.c
>>> +++ b/net/sctp/bind_addr.c
>>> @@ -144,10 +144,9 @@ static void sctp_bind_addr_clean(struct sctp_b=
ind_addr *bp)
>>>         struct list_head *pos, *temp;
>>>
>>>         /* Empty the bind address list. */
>>> -       list_for_each_safe(pos, temp, &bp->address_list) {
>>> -               addr =3D list_entry(pos, struct sctp_sockaddr_entry=
, list);
>>> -               list_del(pos);
>>> -               kfree(addr);
>>> +       list_for_each_entry(pos, &bp->address_list, list) {
>>
>> a 'safe' version is needed here, since we remove items in iterator.
>=20
> Yep.
>=20
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index faf71d1..6150ac5 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr
> *bp, __u16 port)
>  /* Dispose of the address list. */
>  static void sctp_bind_addr_clean(struct sctp_bind_addr *bp)
>  {
> -       struct sctp_sockaddr_entry *addr;
> -       struct list_head *pos, *temp;
> +       struct sctp_sockaddr_entry *addr, *temp;
>=20
>         /* Empty the bind address list. */
> -       list_for_each_safe(pos, temp, &bp->address_list) {
> -               addr =3D list_entry(pos, struct sctp_sockaddr_entry, =
list);
> -               list_del(pos);
> -               kfree(addr);
> +       list_for_each_entry_safe(addr, temp, &bp->address_list, list)=
 {
> +               list_del_rcu(&addr->list);
> +               call_rcu(&addr->rcu, sctp_local_addr_free);
>                 SCTP_DBG_OBJCNT_DEC(addr);
>         }
>  }
>=20
> Does it now look good?

Yes.  It should the fix the race.

-vlad

>=20
> -Jacek
>=20

