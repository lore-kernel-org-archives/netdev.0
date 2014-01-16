From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next v3 2/2] net: Check skb->rxhash in gro_receive
Date: Wed, 15 Jan 2014 21:01:36 -0800
Message-ID: <CAPshTCgy=+p0ZNd+dzb76OVCQAwUK2UfOdo=haQ=QCcLEM-pgA@mail.gmail.com>
References: <alpine.DEB.2.02.1401150853400.14933@tomh.mtv.corp.google.com>
	<1389806708.31367.354.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:47432 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbaAPFBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 00:01:37 -0500
Received: by mail-qc0-f181.google.com with SMTP id e9so1889525qcy.26
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 21:01:36 -0800 (PST)
In-Reply-To: <1389806708.31367.354.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 9:25 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-01-15 at 08:58 -0800, Tom Herbert wrote:
>> When initializing a gro_list for a packet, first check the rxhash of
>> the incoming skb against that of the skb's in the list. This should be
>> a very strong inidicator of whether the flow is going to be matched,
>> and potentially allows a lot of other checks to be short circuited.
>> Use skb_hash_raw so that we don't force the hash to be calculated.
>>
>> Tested by running netperf 200 TCP_STREAMs between two machines with
>> GRO, HW rxhash, and 1G. Saw no performance degration, slight reduction
>> of time in dev_gro_receive.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  net/core/dev.c | 9 ++++++++-
>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 20c834e..c063c7c 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3818,10 +3818,18 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
>>  {
>>       struct sk_buff *p;
>>       unsigned int maclen = skb->dev->hard_header_len;
>> +     u32 hash = skb_get_hash_raw(skb);
>>
>>       for (p = napi->gro_list; p; p = p->next) {
>>               unsigned long diffs;
>>
>> +             NAPI_GRO_CB(p)->flush = 0;
>> +
>> +             if (hash != skb_get_hash_raw(p)) {
>> +                     NAPI_GRO_CB(p)->same_flow = 0;
>> +                     continue;
>> +             }
>> +
>>               diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
>>               diffs |= p->vlan_tci ^ skb->vlan_tci;
>>               if (maclen == ETH_HLEN)
>> @@ -3832,7 +3840,6 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
>>                                      skb_gro_mac_header(skb),
>>                                      maclen);
>>               NAPI_GRO_CB(p)->same_flow = !diffs;
>> -             NAPI_GRO_CB(p)->flush = 0;
>>       }
>>  }
>>
>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
> Hmm, this looks like we should clear flush_id in ipv6 handler,
> otherwise we might reuse a flush_id set from a prior gro invocation in
> ipv4 (skb can be reused in napi_reuse_skb())

Good catch! It's also needed for the IPv6 encaped in IPv4 case (i forgot
there is no frag/id hence no such check for IPv6).

>
> Jerry, what do you think of following fix ?
>
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 1e8683b135bb..598acd76ca4a 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -256,6 +256,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
>                 /* flush if Traffic Class fields are different */
>                 NAPI_GRO_CB(p)->flush |= !!(first_word & htonl(0x0FF00000));
>                 NAPI_GRO_CB(p)->flush |= flush;
> +               NAPI_GRO_CB(p)->flush_id = 0;
>         }
>
>         NAPI_GRO_CB(skb)->flush |= flush;

Acked-by: H.K. Jerry Chu <hkchu@google.com>

>
>
>
