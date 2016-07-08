From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/4] udp offload: allow GRO on 0 checksum packets
Date: Fri, 8 Jul 2016 12:56:37 -0400
Message-ID: <e33d6b7f-0f89-9779-e405-17c390747220@stressinduktion.org>
References: <cover.1467907022.git.pabeni@redhat.com>
 <60369c715ef9948b088416639f0bec800f632f9a.1467907022.git.pabeni@redhat.com>
 <CAKgT0UeONTtXw2SeVr7Zm_AZT50xqeFhLE8mTOAicabsifMLXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:37922 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755163AbcGHQ4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 12:56:39 -0400
In-Reply-To: <CAKgT0UeONTtXw2SeVr7Zm_AZT50xqeFhLE8mTOAicabsifMLXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.07.2016 12:46, Alexander Duyck wrote:
> On Thu, Jul 7, 2016 at 8:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>> currently, UDP packets with zero checksum are not allowed to
>> use udp offload's GRO. This patch admits such packets to
>> GRO, if the related socket settings allow it: ipv6 packets
>> are not admitted if the sockets don't have the no_check6_rx
>> flag set.
>>
>> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>> ---
>>  net/ipv4/udp_offload.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index 9c37338..ac783f4 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -257,7 +257,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>>         struct sock *sk;
>>
>>         if (NAPI_GRO_CB(skb)->encap_mark ||
>> -           (skb->ip_summed != CHECKSUM_PARTIAL &&
>> +           (uh->check && skb->ip_summed != CHECKSUM_PARTIAL &&
>>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>>              !NAPI_GRO_CB(skb)->csum_valid))
>>                 goto out;
> 
> So now all zero checksum UDP traffic will be targeted for GRO if I am
> understanding this right.  Have you looked into how much of an impact
> this might have on performance for non-tunnel UDP traffic using a zero
> checksum?  I'm thinking it will be negative.  The issue is you are now
> going to be performing an extra socket lookup for all incoming UDP
> frames that have a zero checksum.

Are zero checksummed UDP protocols rare and only happen in case where we
have tunneling protocols, which need the socket lookup anyway? That
said, we haven't really focused on the impact here and thought it
shouldn't matter to try to speed up zero checksum UDP protocols over
zero ones.

> Also in the line below this line we are setting the encap_mark.  That
> will probably need to be moved down to the point just before we call
> gro_receive so that we can avoid setting unneeded data in the
> NAPI_GRO_CB.

Ack.

>> @@ -271,6 +271,10 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>>         if (!sk || !udp_sk(sk)->gro_receive)
>>                 goto out_unlock;
>>
>> +       if (!uh->check && skb->protocol == cpu_to_be16(ETH_P_IPV6) &&
>> +           !udp_sk(sk)->no_check6_rx)
>> +               goto out_unlock;
>> +
>>         flush = 0;
>>
>>         for (p = *head; p; p = p->next) {
> 
> So I am pretty sure this check doesn't pass the sniff test.
> Specifically I don't believe you can use skb->protocol like you
> currently are as it could be an 8021q frame for instance that is being
> aggregated so the skb->protocol would be invalid.  I think what you
> should probably be using is NAPI_GRO_CB(skb)->is_ipv6 although it
> occurs to me that in the case of tunnels I don't know if that value is
> being reset for IPv4 like it should be.

Thanks, we probably should switch to sk->sk_family (we don't allow dual
family sockets with tunnel drivers so far)?

Bye,
Hannes
