From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 08/13] net/mlx5e: Add fragmented memory support
 for RX multi packet WQE
Date: Fri, 11 Mar 2016 21:25:29 +0200
Message-ID: <CALzJLG_XU-KMp8dMqcNOpu1OxZRnJro4LFQohK=FLX+5uJKXpQ@mail.gmail.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
	<1457703594-9482-9-git-send-email-saeedm@mellanox.com>
	<1457706771.2663.37.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36147 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbcCKTZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:25:30 -0500
Received: by mail-yw0-f195.google.com with SMTP id p65so6659470ywb.3
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 11:25:29 -0800 (PST)
In-Reply-To: <1457706771.2663.37.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> -void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
>> +static void mlx5e_add_skb_frag(struct sk_buff *skb, int len, struct page *page,
>> +                            int page_offset)
>> +{
>> +     int f = skb_shinfo(skb)->nr_frags++;
>> +     skb_frag_t *fr = &skb_shinfo(skb)->frags[f];
>> +
>> +     skb->len += len;
>> +     skb->data_len += len;
>> +     get_page(page);
>> +     skb_frag_set_page(skb, f, page);
>> +     skb_frag_size_set(fr, len);
>> +     fr->page_offset = page_offset;
>> +     skb->truesize  = SKB_TRUESIZE(skb->len);
>> +}
>
> Really I am speechless.
>
> It is hard to believe how much effort some drivers authors spend trying
> to fool linux stack and risk OOM a host under stress.

Eric, you got it all wrong my friend, no one is trying to fool nobody here.
I will explain it to you below.

>
> SKB_TRUESIZE() is absolutely not something a driver is allowed to use.
>
> Here you want instead :
>
> skb->truesize += PAGE_SIZE;
>
> Assuming you allocate and use an order-0 page per fragment. Fact that
> you receive say 100 bytes datagram is irrelevant to truesize.

Your assumption is wrong, we allocate as many pages as a WQE needs,
and a WQE can describe/handle
up to 1024 packets which share the same page/pages, so the skb should
really have a true size of the strides
of that page it used and not the WHOLE page as you think.

you should already learn this from the previous patch.

each WQE (Receive Work Queue Element) contains 1024 strides each of
the size 128B,
i.e, a packet of the size 128B or less will consume only one stride of
that WQE page, next packets on that WQE
will use the following strides in that same page.

So in opposite of what you think this new scheme is better than our
old one in terms of memory utilization.
before, we wasted MTU size per SKB/Packet regardless of the real
packet size, now each SKB will consume only
as much as 128B strides it will need, no more no less.

BTW there will be only 16 WQEs per ring :), so this new approach
doesn't drastically consume more memory than the previous one.
But it sure can handle more small packets bursts.

>
> truesize is the real memory usage of one skb. Not the minimal size of an
> optimally allocated skb for a given payload.

I totally agree with this, we should have reported  skb->truesize +=
(consumed strides)*(stride size).
but again this is not as critical as you think, in the worst case
skb->truesize will be off by 127B at most.

I will discuss this with Tariq and fix it.

>
>
> Better RX speed should not be done at the risk of system stability.

The whole idea of this patch is not improving RX speed ! No ! not at
all ! it just improves the driver resiliency
when the system is under stress on the expense of performance!

So I really think we should get a "thumbs up" from you.

>
> Now if for some reason you need to increase max TCP RWIN, that would be
> a TCP stack change, not some obscure lie in a driver trying to be faster
> than competitors.

No we are not trying to max TCP RWIN in here, Sorry you think of it
this way, I hope my explanation above changes your mind.

Thanks,
Saeed
