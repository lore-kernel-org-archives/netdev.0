From: achiad shochat <achiad.mellanox@gmail.com>
Subject: Re: [PATCH net-next 08/13] net/mlx5e: Add fragmented memory support
 for RX multi packet WQE
Date: Sun, 13 Mar 2016 12:29:25 +0200
Message-ID: <CAEHy93LY7kRRgAfJxtoVj+oR+N2hziDggE61C39Z4+W4JZCSMw@mail.gmail.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
	<1457703594-9482-9-git-send-email-saeedm@mellanox.com>
	<1457706771.2663.37.camel@edumazet-ThinkPad-T530>
	<CALzJLG_XU-KMp8dMqcNOpu1OxZRnJro4LFQohK=FLX+5uJKXpQ@mail.gmail.com>
	<1457726319.2663.50.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35330 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbcCMK30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 06:29:26 -0400
Received: by mail-oi0-f68.google.com with SMTP id r187so9222494oih.2
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 03:29:26 -0700 (PDT)
In-Reply-To: <1457726319.2663.50.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11 March 2016 at 21:58, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On ven., 2016-03-11 at 21:25 +0200, Saeed Mahameed wrote:
>> >> -void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
>> >> +static void mlx5e_add_skb_frag(struct sk_buff *skb, int len, struct page *page,
>> >> +                            int page_offset)
>> >> +{
>> >> +     int f = skb_shinfo(skb)->nr_frags++;
>> >> +     skb_frag_t *fr = &skb_shinfo(skb)->frags[f];
>> >> +
>> >> +     skb->len += len;
>> >> +     skb->data_len += len;
>> >> +     get_page(page);
>> >> +     skb_frag_set_page(skb, f, page);
>> >> +     skb_frag_size_set(fr, len);
>> >> +     fr->page_offset = page_offset;
>> >> +     skb->truesize  = SKB_TRUESIZE(skb->len);
>> >> +}
>> >
>> > Really I am speechless.
>> >
>> > It is hard to believe how much effort some drivers authors spend trying
>> > to fool linux stack and risk OOM a host under stress.
>>
>> Eric, you got it all wrong my friend, no one is trying to fool nobody here.
>> I will explain it to you below.
>>
>> >
>> > SKB_TRUESIZE() is absolutely not something a driver is allowed to use.
>> >
>> > Here you want instead :
>> >
>> > skb->truesize += PAGE_SIZE;
>> >
>> > Assuming you allocate and use an order-0 page per fragment. Fact that
>> > you receive say 100 bytes datagram is irrelevant to truesize.
>>
>> Your assumption is wrong, we allocate as many pages as a WQE needs,
>> and a WQE can describe/handle
>> up to 1024 packets which share the same page/pages, so the skb should
>> really have a true size of the strides
>> of that page it used and not the WHOLE page as you think.
>>
>> you should already learn this from the previous patch.
>>
>> each WQE (Receive Work Queue Element) contains 1024 strides each of
>> the size 128B,
>> i.e, a packet of the size 128B or less will consume only one stride of
>> that WQE page, next packets on that WQE
>> will use the following strides in that same page.
>>
>> So in opposite of what you think this new scheme is better than our
>> old one in terms of memory utilization.
>> before, we wasted MTU size per SKB/Packet regardless of the real
>> packet size, now each SKB will consume only
>> as much as 128B strides it will need, no more no less.
>>
>> BTW there will be only 16 WQEs per ring :), so this new approach
>> doesn't drastically consume more memory than the previous one.
>> But it sure can handle more small packets bursts.
>>
>> >
>> > truesize is the real memory usage of one skb. Not the minimal size of an
>> > optimally allocated skb for a given payload.
>>
>> I totally agree with this, we should have reported  skb->truesize +=
>> (consumed strides)*(stride size).
>> but again this is not as critical as you think, in the worst case
>> skb->truesize will be off by 127B at most.
>
> Ouch. really you are completely wrong.
>
> If one skb has a fragment of a page, and sits in a queue for a long
> time, it really uses a full page, because the remaining part of the page
> is not reusable. Only kmalloc(128) can deal with that idea of allowing
> other parts of the page being 'freed and reusable'
>
> It is trivial for an attacker to make sure the host will consume one
> page + sk_buff + skb->head = 4096 + 256 + 512, by specially sending out
> of order packets on TCP flows.
>
> It is very tempting to have special memory allocators you know, but you
> have to understand attackers are smart. Smarter than us.
>
> If now you are telling me you plan to allocate 131072 bytes pages (1024
> strides of 128 bytes), then a smart attacker can actually bump skb
> truesize to 128KB
>
> Really your RX allocation schem is easily DOSable.
>
>

It seems you did not understand the new scheme at all.
With the new scheme each incoming packet uses only the fraction of the
page that it needs.
This is optimal memory utilization and locality.

So if one skb has a fragment of a page, and sits in a queue for a long
time, it really does _not_ use a full page, because the remaining part
of the page
_is_ usable for other incoming packets.

BTW, this new scheme was actually introduced in the previous patch
"[PATCH net-next 06/13] net/mlx5e: Support RX multi-packet WQE
(Striding RQ)" rather than in this one.
