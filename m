From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Sun, 08 Jun 2014 09:41:46 +0200
Message-ID: <539413BA.7060903@kau.se>
References: <539319F6.2090907@cogentembedded.com> <1402151680-11434-1-git-send-email-per.hurtig@kau.se> <1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, anna.brunstrom@kau.se,
	mohammad.rajiullah@kau.se, ncardwell@google.com,
	nanditad@google.com, sergei.shtylyov@cogentembedded.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:19960 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753317AbaFHHtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 03:49:19 -0400
In-Reply-To: <1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On s=C3=B6n  8 jun 2014 04:58:25, Eric Dumazet wrote:
> On Sat, 2014-06-07 at 16:34 +0200, Per Hurtig wrote:
>> Fix to a problem observed when losing a FIN segment that does not
>> contain data.  In such situations, TLP is unable to recover from
>> *any* tail loss and instead adds at least PTO ms to the
>> retransmission process, i.e., RTO =3D RTO + PTO.
>>
>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>> ---
>>   net/ipv4/tcp_output.c | 6 ++++--
>>   1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> index d463c35..6573765 100644
>> --- a/net/ipv4/tcp_output.c
>> +++ b/net/ipv4/tcp_output.c
>> @@ -2130,8 +2130,10 @@ void tcp_send_loss_probe(struct sock *sk)
>>   	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
>>   		goto rearm_timer;
>>
>> -	/* Probe with zero data doesn't trigger fast recovery. */
>> -	if (skb->len > 0)
>> +	/* Probe with zero data doesn't trigger fast recovery, if FIN
>> +	 * flag is not set.
>> +	 */
>> +	if ((skb->len > 0) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
>>   		err =3D __tcp_retransmit_skb(sk, skb);
>>
>>   	/* Record snd_nxt for loss detection. */
>
>
> You know, I believe the test was exactly to avoid sending data less F=
IN
> packets.
>
> If you write :
>
>      if (A  || !A)
>
> Better remove the condition, completely ;)
>
Obviously, but I don't think that FINs are the only segments
who are targeted by this condition (or targeted at all given
the implications of this statement). Furthermore, the comment above
the if statement would probably have mentioned FINs explicity
and not zero sized segments in general if this were the case.


>
> Nandita, why FIN packet wont trigger fast retransnmits ?
>

They do, that's the whole thing with this patch.

> It sounds like if the timer is the issue you want to fix, you might
> simply rearm a timer with RTO-PTO instead of RTO ?
>
>
No I want to enable TLP for tail loss where an empty FIN is involved,
this does not work now.

>
