From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 13:01:11 +0200
Message-ID: <BANLkTikVxfxU2uW3AA--q8qt16og=HdDLg@mail.gmail.com>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
	<1305704885.2983.4.camel@edumazet-laptop>
	<BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
	<1305707358.2983.14.camel@edumazet-laptop>
	<4DD38B30.9090601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:53623 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932619Ab1ERLDU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 07:03:20 -0400
Received: by pwi15 with SMTP id 15so694758pwi.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 04:03:20 -0700 (PDT)
In-Reply-To: <4DD38B30.9090601@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/18 Wei Yongjun <yjwei@cn.fujitsu.com>:
>
>> Le mercredi 18 mai 2011 =E0 10:06 +0200, Jacek Luczak a =E9crit :
>>> 2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:
>>>> If you're removing items from this list, you must be a writer here=
, with
>>>> exclusive access. So rcu_read_lock()/rcu_read_unlock() is not nece=
ssary.
>>> I could agree to some extend ... but strict RCU section IMO is need=
ed here.
>>> I can check this if the issue exists.
>>>
>> I can tell you for sure rcu_read_lock() is not needed here. Its only
>> showing confusion from code's author.
>>
>> Please read Documentation/RCU/listRCU.txt for concise explanations,
>> line 117.
>>
>>
>>>> Therefore, I guess following code is better :
>>>>
>>>> list_for_each_entry(addr, &bp->address_list, list) {
>>>> =A0 =A0 =A0 =A0list_del_rcu(&addr->list);
>>>> =A0 =A0 =A0 =A0call_rcu(&addr->rcu, sctp_local_addr_free);
>>>> =A0 =A0 =A0 =A0SCTP_DBG_OBJCNT_DEC(addr);
>>>> }
>>>>
>>>> Then, why dont you fix sctp_bind_addr_clean() instead ?
>>>>
>>>> if 'struct sctp_sockaddr_entry' is recu protected, then all frees =
should
>>>> be protected as well.
>>> The _clean() as claimed by Vlad is called many times from various p=
laces
>>> in code and this could give a overhead. I guess Vlad would need to =
comment.
>> I guess a full review of this code is needed. You'll have to prove
>> sctp_bind_addr_clean() is always called after one RCU grace period i=
f
>> you want to leave it as is.
>>
>> You cant get RCU for free, some rules must be followed or you risk
>> crashes.
>>
>
> fix the race between sctp_bind_addr_free() and sctp_bind_addr_conflic=
t(), maybe you just
> need to remove the socket from the port hash before empty the bind ad=
dress list.
> some thing like this, not test.
>
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index c8cc24e..924d846 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -268,12 +268,13 @@ static void sctp_endpoint_destroy(struct sctp_e=
ndpoint *ep)
>
> =A0 =A0 =A0 =A0/* Cleanup. */
> =A0 =A0 =A0 =A0sctp_inq_free(&ep->base.inqueue);
> - =A0 =A0 =A0 sctp_bind_addr_free(&ep->base.bind_addr);
>
> =A0 =A0 =A0 =A0/* Remove and free the port */
> =A0 =A0 =A0 =A0if (sctp_sk(ep->base.sk)->bind_hash)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sctp_put_port(ep->base.sk);
>
> + =A0 =A0 =A0 sctp_bind_addr_free(&ep->base.bind_addr);
> +
> =A0 =A0 =A0 =A0/* Give up our hold on the sock. */
> =A0 =A0 =A0 =A0if (ep->base.sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sock_put(ep->base.sk);
>

Done tests with that one and looks like it survive the flood.

How then this will be handled is up to you. Both ways fix
the issue which makes me happy as damn hell.

@Eric, if you will take a look into the code you might notice
that there are few places where list operations could be
optimised and the main question here is do we really care
to have the data ,,safe'' so that things like that won't popup.
The good example can be the set of _local_ functions.
Ahhh... and I'm aware of how tricky can be abuse of RCU.

-Jacek
