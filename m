From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/4] udp offload: allow GRO on 0 checksum packets
Date: Fri, 8 Jul 2016 10:08:24 -0700
Message-ID: <CAKgT0Uc8NZyiibi5hAg4azNfiVds-Uo-mbBAtdScOma-jakHkg@mail.gmail.com>
References: <cover.1467907022.git.pabeni@redhat.com> <60369c715ef9948b088416639f0bec800f632f9a.1467907022.git.pabeni@redhat.com>
 <CAKgT0UeONTtXw2SeVr7Zm_AZT50xqeFhLE8mTOAicabsifMLXQ@mail.gmail.com> <e33d6b7f-0f89-9779-e405-17c390747220@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paolo Abeni <pabeni@redhat.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32908 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932923AbcGHRI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 13:08:26 -0400
Received: by mail-it0-f67.google.com with SMTP id y93so5656843ita.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 10:08:25 -0700 (PDT)
In-Reply-To: <e33d6b7f-0f89-9779-e405-17c390747220@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2016 at 9:56 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 08.07.2016 12:46, Alexander Duyck wrote:
>> On Thu, Jul 7, 2016 at 8:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>>> currently, UDP packets with zero checksum are not allowed to
>>> use udp offload's GRO. This patch admits such packets to
>>> GRO, if the related socket settings allow it: ipv6 packets
>>> are not admitted if the sockets don't have the no_check6_rx
>>> flag set.
>>>
>>> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>>> ---
>>>  net/ipv4/udp_offload.c | 6 +++++-
>>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>>> index 9c37338..ac783f4 100644
>>> --- a/net/ipv4/udp_offload.c
>>> +++ b/net/ipv4/udp_offload.c
>>> @@ -257,7 +257,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>>>         struct sock *sk;
>>>
>>>         if (NAPI_GRO_CB(skb)->encap_mark ||
>>> -           (skb->ip_summed != CHECKSUM_PARTIAL &&
>>> +           (uh->check && skb->ip_summed != CHECKSUM_PARTIAL &&
>>>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>>>              !NAPI_GRO_CB(skb)->csum_valid))
>>>                 goto out;
>>
>> So now all zero checksum UDP traffic will be targeted for GRO if I am
>> understanding this right.  Have you looked into how much of an impact
>> this might have on performance for non-tunnel UDP traffic using a zero
>> checksum?  I'm thinking it will be negative.  The issue is you are now
>> going to be performing an extra socket lookup for all incoming UDP
>> frames that have a zero checksum.
>
> Are zero checksummed UDP protocols rare and only happen in case where we
> have tunneling protocols, which need the socket lookup anyway? That
> said, we haven't really focused on the impact here and thought it
> shouldn't matter to try to speed up zero checksum UDP protocols over
> zero ones.

I'm not sure how rare they are, but I know they are used for more than
just tunnels, especially in the case of IPv4.  What I suspect will
happen with this being implemented is that we will end up with all
sorts of people coming forward complaining about performance
regressions when we add an extra socket lookup to their fast-path.
I'm sure Jesper's pktgen tests would show a some negatives with
something like this as pktgen uses a 0 UDP checksum as I recall.
However I would suspect he probably runs such tests with GRO already
disabled.

>> Also in the line below this line we are setting the encap_mark.  That
>> will probably need to be moved down to the point just before we call
>> gro_receive so that we can avoid setting unneeded data in the
>> NAPI_GRO_CB.
>
> Ack.
>
>>> @@ -271,6 +271,10 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>>>         if (!sk || !udp_sk(sk)->gro_receive)
>>>                 goto out_unlock;
>>>
>>> +       if (!uh->check && skb->protocol == cpu_to_be16(ETH_P_IPV6) &&
>>> +           !udp_sk(sk)->no_check6_rx)
>>> +               goto out_unlock;
>>> +
>>>         flush = 0;
>>>
>>>         for (p = *head; p; p = p->next) {
>>
>> So I am pretty sure this check doesn't pass the sniff test.
>> Specifically I don't believe you can use skb->protocol like you
>> currently are as it could be an 8021q frame for instance that is being
>> aggregated so the skb->protocol would be invalid.  I think what you
>> should probably be using is NAPI_GRO_CB(skb)->is_ipv6 although it
>> occurs to me that in the case of tunnels I don't know if that value is
>> being reset for IPv4 like it should be.

I just looked at the function and verified the v4 path for UDP GRO is
setting this to zero as it should.

> Thanks, we probably should switch to sk->sk_family (we don't allow dual
> family sockets with tunnel drivers so far)?

I don't know what the situation there is.  I just now that for v4 vs
v6 UDP the NAPI_GRO_CB has a field called is_ipv6 which is populated
just before calling into the tunnel GRO path.  If you use that you can
guarantee that you are looking at the right type for the protocol
instead of guessing at it based on skb->protocol.

- Alex
