From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 14/14] mlx4: remove duplicate code in mlx4_en_process_rx_cq()
Date: Thu, 9 Feb 2017 09:26:24 -0800
Message-ID: <CANn89i+FFHaaRLEHGs6nLOCjJv1tdgLpqRTdw=T4JKRECoXRnA@mail.gmail.com>
References: <20170209135838.16487-1-edumazet@google.com> <20170209135838.16487-15-edumazet@google.com>
 <CALzJLG-rNgKSroZg5+XsHRF8vPb=+b4V2cSchAz3c6+cvOW96w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:36156 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932082AbdBIR0b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:26:31 -0500
Received: by mail-it0-f49.google.com with SMTP id c7so130224479itd.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:26:31 -0800 (PST)
In-Reply-To: <CALzJLG-rNgKSroZg5+XsHRF8vPb=+b4V2cSchAz3c6+cvOW96w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 9:15 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Thu, Feb 9, 2017 at 3:58 PM, Eric Dumazet <edumazet@google.com> wrote:
>> We should keep one way to build skbs, regardless of GRO being on or off.
>>
>> Note that I made sure to defer as much as possible the point we need to
>> pull data from the frame, so that future prefetch() we might add
>> are more effective.
>>
>> These skb attributes derive from the CQE or ring :
>>  ip_summed, csum
>>  hash
>>  vlan offload
>>  hwtstamps
>>  queue_mapping
>>
>> As a bonus, this patch removes mlx4 dependency on eth_get_headlen()
>
> So no copy at all in driver RX ?  as it is handled in
> napi_gro_frags(&cq->napi); ?

Absolutely.

>
> General question, why not just use build_skb() ? which approach is better ?


napi_gro_frags() is better.

Especially if you want MTU = 1800 or so.

But also because the page is meant to be read only, when using
page-recycling technique.

>
>> which is very often broken enough to give us headaches.
>>
                 }
>
> Why just not move this whole csum logic to a dedicated function ?
> all it needs to do is update some csum statistics and determine
> "ip_summed" value;

I guess we could.



> Not required anymore ?  I know napi_frags_skb does the job,
> but what about skb->pkt_type field which is handled in eth_type_trans ?

Look at napi_frags_skb()

>

>> +               nr = mlx4_en_complete_rx_desc(priv, frags, skb, length);
>> +               if (nr) {
>
> likely() ?
>
>> +                       skb_shinfo(skb)->nr_frags = nr;
>> +                       skb->len = length;
>> +                       skb->data_len = length;
>> +                       napi_gro_frags(&cq->napi);
>>                 }
>
> no need to kfree_skb/reset some SKB fields in case nr == 0 ?
> since this SKB will be returned via napi_get_frags if you didn't
> actually consume it ..
>
> for example 1st packet is a valn packet and for some reason
> mlx4_en_complete_rx_desc returned 0 on it.
> next packet is a non vlan packet that will get the same skb of the 1st
> packet with non clean SKB fields such as (skb->vlan_tci) !

Good points. For one reason I mixed with napi_reuse_skb().

Note that I do not believe this path can ever be taken anyway.

By definition, we allow the NIC to use one RX ring slot if and only if
all the page fragmenst were properly allocated.
