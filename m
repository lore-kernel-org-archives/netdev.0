From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Fri, 10 Jan 2014 15:22:43 -0800
Message-ID: <CA+mtBx-hs1PzSL0hnFPTSYwxBCx-MWTop5wd4Vvgsm2UJ9mBbQ@mail.gmail.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	<1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	<1389375935.31367.102.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx-8=tiYw=-_TydO0bC_tJXK6MqxjnZQaCXqUtxLSF7xhQ@mail.gmail.com>
	<1389380077.31367.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx-OHxHCTQO50F9_aw=T8VSg93E2eCkzdLL3PZapcR-CFQ@mail.gmail.com>
	<1389386629.31367.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:37001 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbaAJXWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 18:22:43 -0500
Received: by mail-ie0-f170.google.com with SMTP id tq11so5209672ieb.1
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 15:22:43 -0800 (PST)
In-Reply-To: <1389386629.31367.142.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 12:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-01-10 at 11:42 -0800, Tom Herbert wrote:
>> > Really, 99% of the time gro_list contains zero or one single slot, I
>> > have hard data saying so.
>> >
>> Please provide the data.
>
> Based on a Google patch you can run on your lab host.
>
I don't think your data supports your supposition to be generally true
:-). Just by setting MTU to 500 in your test conditions I was able to
lower the zero or one slot ratio to 80%. In any case, I don't see any
reason to believe that real NAT boxes, routers, cable modems, Android
devices, etc. aren't getting lower rates-- this would *not* be a bad
thing, as link rate increases, request sizes get larger, and there are
more active flows there are going to be more opportunities for packet
aggregation and thus more entries in the gro_list anyway. Throw in
fact that GRO is increasingly important for its value in
virtualization and encapsulation (cases where LRO doesn't apply), and
it's clear that GRO path performance is important and should be
scrutinized!

> lpaa5:~# ethtool -S eth1|egrep "rx_packets|gro"
>      rx_packets: 235709959
>      gro_complete[0]: 5895809
>      gro_overflows[0]: 1495
>      gro_nogro[0]: 63584
>      gro_msgs[0]: 9791617
>      gro_segs[0]: 52290544
>      gro_flush[0]: 25
>      gro_complete[1]: 6464583
>      gro_overflows[1]: 5920
>      gro_nogro[1]: 74680
>      gro_msgs[1]: 11797481
>      gro_segs[1]: 62081299
>      gro_flush[1]: 35
>      gro_complete[2]: 6289929
>      gro_overflows[2]: 4016
>      gro_nogro[2]: 71479
>      gro_msgs[2]: 11111473
>      gro_segs[2]: 58518690
>      gro_flush[2]: 42
>      gro_complete[3]: 6448928
>      gro_overflows[3]: 6781
>      gro_nogro[3]: 76417
>      gro_msgs[3]: 11845717
>      gro_segs[3]: 62730931
>      gro_flush[3]: 42
>      gro_complete: 25099249
>      gro_overflows: 18212
>      gro_nogro: 286160
>      gro_msgs: 44546288
>      gro_segs: 235621464
>      gro_flush: 144
>
> The key is the gro_complete thing, meaning that most NAPI poll are
> completed and GRO list flushed.
>
> Here the results are from a synthetic bench (400 concurrent TCP_STREAM),
> very small number of RX queues (trying to force stress load you want),
> increase coalescing parameters on the NIC (to really try to increase
> batches load), plenty of ECN marking to force GRO flushes, and even so,
> you can see :
>
> Average aggregation is : (235621464-286160)/44546288 = 5.28 frames per
> GRO packet.
>
> average NAPI run handles 235709959/25099249 = 9.39 packets
>
> Very few overflows of the gro_list : 18212
>
>
>> > If you want to optimize the case where list is fully populated (because
>> > of yet another synthetic benchmark you use), you really need to build a
>> > temporary list so that all layers do not even have to check
>> > NAPI_GRO_CB(p)->same_flow
>> >
>> Well if you prefer, you can think of the "synthetic benchmark" as
>> emulating an obvious DOS attack by pumping MSS sized TCP segments with
>> random ports to a server. The stack needs to be resilient to such
>> things, an O(n*m) algorithm in the data path is a red flag.
>
> SYN floods are way more effective, or sending small packets with
> MSS=10 : Even with one flow your host wont be resilient at all.
>
> n is what , and m is what ?
>
> GRO is O(8), or O(1). This is the least of your concerns under attack.
>
> I played last year adding a hash table (based on rxhash), and
> my performance tests were not good enough.
>
> profile exactly showed flow dissection being a problem. This is what
> your patch is trying to do.
>
> Optimizing GRO stack to better react to attacks, but lowering
> performance in normal cases was not a win.
>
> So if you believe your patch is really useful in its current form,
> please provide your data.
>
> My opinion is that this one liner is much better.
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ce01847793c0..be3135d6c12a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3800,6 +3800,7 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
>
>                 diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
>                 diffs |= p->vlan_tci ^ skb->vlan_tci;
> +               diffs |= p->rxhash ^ skb->rxhash;
>                 if (maclen == ETH_HLEN)
>                         diffs |= compare_ether_header(skb_mac_header(p),
>                                                       skb_gro_mac_header(skb));
>
>
