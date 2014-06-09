From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Mon, 9 Jun 2014 00:04:14 -0700
Message-ID: <CAB_+Fg5akovVdbRPd-aRT9nMvx4gL3OJSmvi3rczftLoo=EfGw@mail.gmail.com>
References: <539319F6.2090907@cogentembedded.com>
	<1402151680-11434-1-git-send-email-per.hurtig@kau.se>
	<1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
	<539413BA.7060903@kau.se>
	<1402245301.3645.336.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Per Hurtig <per.hurtig@kau.se>, Netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	sergei.shtylyov@cogentembedded.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:46967 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbaFIHEP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 03:04:15 -0400
Received: by mail-ob0-f169.google.com with SMTP id wp18so2894160obc.14
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 00:04:14 -0700 (PDT)
In-Reply-To: <1402245301.3645.336.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 8, 2014 at 9:35 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Sun, 2014-06-08 at 09:41 +0200, Per Hurtig wrote:
>>
>> On s=C3=B6n  8 jun 2014 04:58:25, Eric Dumazet wrote:
>> > On Sat, 2014-06-07 at 16:34 +0200, Per Hurtig wrote:
>> >> Fix to a problem observed when losing a FIN segment that does not
>> >> contain data.  In such situations, TLP is unable to recover from
>> >> *any* tail loss and instead adds at least PTO ms to the
>> >> retransmission process, i.e., RTO =3D RTO + PTO.
>> >>
>> >> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>> >> ---
>> >>   net/ipv4/tcp_output.c | 6 ++++--
>> >>   1 file changed, 4 insertions(+), 2 deletions(-)
>> >>
>> >> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> >> index d463c35..6573765 100644
>> >> --- a/net/ipv4/tcp_output.c
>> >> +++ b/net/ipv4/tcp_output.c
>> >> @@ -2130,8 +2130,10 @@ void tcp_send_loss_probe(struct sock *sk)
>> >>    if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
>> >>            goto rearm_timer;
>> >>
>> >> -  /* Probe with zero data doesn't trigger fast recovery. */
>> >> -  if (skb->len > 0)
>> >> +  /* Probe with zero data doesn't trigger fast recovery, if FIN
>> >> +   * flag is not set.
>> >> +   */
>> >> +  if ((skb->len > 0) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN=
))
>> >>            err =3D __tcp_retransmit_skb(sk, skb);
>> >>
>> >>    /* Record snd_nxt for loss detection. */
>> >
>> >
>> > You know, I believe the test was exactly to avoid sending data les=
s FIN
>> > packets.
>> >
>> > If you write :
>> >
>> >      if (A  || !A)
>> >
>> > Better remove the condition, completely ;)
>> >
>> Obviously, but I don't think that FINs are the only segments
>> who are targeted by this condition (or targeted at all given
>> the implications of this statement). Furthermore, the comment above
>> the if statement would probably have mentioned FINs explicity
>> and not zero sized segments in general if this were the case.
>>
>
>
> I see no other possibilities than FIN segments here, or the WARN_ON(!
> tcp_skb_pcount(skb)) right before would trigger.
>
> If we believe it could trigger, then we need to remove the WARN_ON(),
> because its far more disruptive than waiting a bit more for the RTO.
> Remember : RTO is conservative.
>
> The if (skb->len > 0) only is true for FIN with no data.
>
> This was exactly the intent : Not sending FIN at this stage.
>
> If pure FIN is OK here, just remove the comment and test, this is so
> confusing and useless.

I agree - if pure FIN can indeed trigger recovery, let's just remove
the test and comment.

Nandita
