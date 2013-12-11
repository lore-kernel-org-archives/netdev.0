From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-gro: Prepare GRO stack for the upcoming
 tunneling support
Date: Thu, 12 Dec 2013 03:07:33 +0800
Message-ID: <CAPshTCjaDSgq4y72Lc2rDsTS3O+pFE5ZUwjgKKdpoMZbepJrcg@mail.gmail.com>
References: <1386518682-30488-1-git-send-email-hkchu@google.com>
	<1386531839.30495.296.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f53.google.com ([209.85.128.53]:54299 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab3LKTHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:07:36 -0500
Received: by mail-qe0-f53.google.com with SMTP id nc12so5557227qeb.40
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 11:07:36 -0800 (PST)
In-Reply-To: <1386531839.30495.296.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 9, 2013 at 3:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2013-12-08 at 08:04 -0800, H.K. Jerry Chu wrote:
>> From: Jerry Chu <hkchu@google.com>
>>
>> This patch modifies the GRO stack to remove the assumption that
>> only one IP hdr is present in the encapsulation chain. It avoids
>> the use of ip_hdr()/ipv6_hdr() macro in IP's *_gro_receive()/
>> *_gro_complete() functions because there may be more than one IP
>> hdr present in the encapsulation chain when various flavors of IP
>> tunneling support are added. By doing so it also allows multiple
>> level, not just a single level (i.e., with only two IP hdrs like
>> IP-in-IP) of encapsulation to be supported in the future.
>>
>> With this patch, the GRO stack traversing now is mostly based on
>> skb_gro_offset rather than special hdr offsets saved in skb (e.g.,
>> skb->network_header, skb->transport_header,...) As a consequence
>> all but the top layer (which is likely to be the transport layer)
>> must have hdrs of the same length in order for a pkt to be
>> considered for aggregation. Therefore when adding a new layer
>> (e.g., for tunneling), one must check and skip flows (e.g., setting
>> NAPI_GRO_CB(p)->same_flow to 0) that have a different hdr length.
>>
>
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 2718fed..53e3e9f 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3083,7 +3083,6 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>>
>>       skb_set_mac_header(nskb, skb_mac_header(p) - p->data);
>>       skb_set_network_header(nskb, skb_network_offset(p));
>> -     skb_set_transport_header(nskb, skb_transport_offset(p));
>>
>>       __skb_pull(p, skb_gro_offset(p));
>>       memcpy(skb_mac_header(nskb), skb_mac_header(p),
>
>
>> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
>> index 70011e0..cb406e9 100644
>> --- a/net/ipv4/af_inet.c
>> +++ b/net/ipv4/af_inet.c
>> @@ -1397,8 +1401,12 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
>>       }
>>
>>       NAPI_GRO_CB(skb)->flush |= flush;
>> +     skb_set_network_header(skb, off);
>> +     /* The above will be needed by the transport layer if there is one
>> +      * immediately following this IP hdr.
>> +      */
>> +
>>       skb_gro_pull(skb, sizeof(*iph));
>> -     skb_set_transport_header(skb, skb_gro_offset(skb));
>>
>>       pp = ops->callbacks.gro_receive(head, skb);
>>
>
> I am wondering if you tested installing a qdisc at ingress ?
>
> qdisc_pkt_len_init() depends that GRO packets have set transport header.
>
> Note this might be hidden by the check done in
> __netif_receive_skb_core()
>
> if (!skb_transport_header_was_set(skb))
>     skb_reset_transport_header(skb);
>
> To test your changes without playing with ingress qdisc, you could add :
>
> if (!skb_transport_header_was_set(skb)) {
>     BUG_ON(skb_is_gso(skb))
>     skb_reset_transport_header(skb);

Yes indeed GSO skb will get here w/o transport header set. This has been fixed
in the v2 patch.

Thanks,

Jerry

> }
>
>
