From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Mon, 9 Jun 2014 00:02:45 -0700
Message-ID: <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
References: <539319F6.2090907@cogentembedded.com>
	<1402151680-11434-1-git-send-email-per.hurtig@kau.se>
	<1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
	<539413BA.7060903@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	sergei.shtylyov@cogentembedded.com
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:46449 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaFIHCq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 03:02:46 -0400
Received: by mail-oa0-f49.google.com with SMTP id i7so687107oag.22
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 00:02:46 -0700 (PDT)
In-Reply-To: <539413BA.7060903@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 8, 2014 at 12:41 AM, Per Hurtig <per.hurtig@kau.se> wrote:
>
>
> On s=C3=B6n  8 jun 2014 04:58:25, Eric Dumazet wrote:
>>
>> On Sat, 2014-06-07 at 16:34 +0200, Per Hurtig wrote:
>>>
>>> Fix to a problem observed when losing a FIN segment that does not
>>> contain data.  In such situations, TLP is unable to recover from
>>> *any* tail loss and instead adds at least PTO ms to the
>>> retransmission process, i.e., RTO =3D RTO + PTO.
>>>
>>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>>> ---
>>>   net/ipv4/tcp_output.c | 6 ++++--
>>>   1 file changed, 4 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>>> index d463c35..6573765 100644
>>> --- a/net/ipv4/tcp_output.c
>>> +++ b/net/ipv4/tcp_output.c
>>> @@ -2130,8 +2130,10 @@ void tcp_send_loss_probe(struct sock *sk)
>>>         if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
>>>                 goto rearm_timer;
>>>
>>> -       /* Probe with zero data doesn't trigger fast recovery. */
>>> -       if (skb->len > 0)
>>> +       /* Probe with zero data doesn't trigger fast recovery, if F=
IN
>>> +        * flag is not set.
>>> +        */
>>> +       if ((skb->len > 0) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_=
=46IN))
>>>                 err =3D __tcp_retransmit_skb(sk, skb);
>>>
>>>         /* Record snd_nxt for loss detection. */
>>
>>
>>
>> You know, I believe the test was exactly to avoid sending data less =
=46IN
>> packets.
>>
>> If you write :
>>
>>      if (A  || !A)
>>
>> Better remove the condition, completely ;)
>>
> Obviously, but I don't think that FINs are the only segments
> who are targeted by this condition (or targeted at all given
> the implications of this statement). Furthermore, the comment above
> the if statement would probably have mentioned FINs explicity
> and not zero sized segments in general if this were the case.
>
>
>
>>
>> Nandita, why FIN packet wont trigger fast retransnmits ?
>>
>
> They do, that's the whole thing with this patch.
>
>
>> It sounds like if the timer is the issue you want to fix, you might
>> simply rearm a timer with RTO-PTO instead of RTO ?
>>
>>
> No I want to enable TLP for tail loss where an empty FIN is involved,
> this does not work now.

I understand the tail loss case you want to solve - essentially when a
tail loss occurs that involves data segments as well as that of an
empty FIN. However, have you verified that re-sending an empty FIN
triggers fast recovery? I would be surprised if it did, because I
think the sender needs to receive a SACK of at least 1-byte of data
before sender can trigger FACK based fast recovery.

If you have verified that a pure FIN does indeed trigger recovery, can
you tell me what part of the code makes that happen?

Nandita
