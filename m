From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Fri, 10 Jan 2014 10:15:31 -0800
Message-ID: <CA+mtBx-8=tiYw=-_TydO0bC_tJXK6MqxjnZQaCXqUtxLSF7xhQ@mail.gmail.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	<1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	<1389375935.31367.102.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:43085 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbaAJSPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:15:32 -0500
Received: by mail-ig0-f179.google.com with SMTP id hk11so11203472igb.0
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 10:15:31 -0800 (PST)
In-Reply-To: <1389375935.31367.102.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 9:45 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-01-10 at 08:27 -0800, Tom Herbert wrote:
>> On Thu, Jan 9, 2014 at 9:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Thu, 2014-01-09 at 20:54 -0800, Tom Herbert wrote:
>> >> When initializing a gro_list for a packet, first check the rxhash of
>> >> the incoming skb against that of the skb's in the list. This should be
>> >> a very strong inidicator of whether the flow is going to be matched,
>> >> and potentially allows a lot of other checks to be short circuited.
>> >>
>> >
>> > Hmm... this idea was discussed in the past. I used it when attempting to
>> > use a hash table instead of a gro_list last year.
>> >
>> > Unfortunately this added lot of cycles when rxhash is not provided by
>> > hardware, and my tests found it was not a win.
>> >
>> > Remember : in most cases, gro_list contains one flow, so this test does
>> > nothing special but adds overhead.
>>
>> I don't understand what your basis is that gro_list in most cases
>> contains one flow, but assuming that were true, maybe we should make
>> the it only contain one flow eliminating the complexity of multiple
>> flows (same_flow logic is convoluted and layers of encapsulation is
>> not going to simplify things).
>>
>
> The complexity of GRO is the aggregation itself. You wont avoid it.
>
>> If we are doing RPS or RFS, rxhash will be computed anyway, so the
>> case your optimizing is pretty narrow: no RPS, no RFS, no hardware
>> hash, and a single flow in gro_list. Nevertheless, if this is really
>> an important concern, we can make the check directly against
>> skb->rxhash so to be opportunistic and avoid the possibility of
>> computation.
>
>
> We'll compute rxhash once per GRO packet, containing up to 40 MSS
> packets.
>
> Thats a big difference.
>
The objective is to compute the rxhash at most once per packet.

> If your patch was doing this, I would have no complain.
>
> (No new conditional branch, and skb->rxhash, if provided by the NIC,
> can give a hint.)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ce01847793c0..c9f7a26d7ce7 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3798,7 +3798,8 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
>         for (p = napi->gro_list; p; p = p->next) {
>                 unsigned long diffs;
>
> -               diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
> +               diffs = p->rxhash ^ skb->rxhash;
> +               diffs |= (unsigned long)p->dev ^ (unsigned long)skb->dev;
>                 diffs |= p->vlan_tci ^ skb->vlan_tci;
>                 if (maclen == ETH_HLEN)
>                         diffs |= compare_ether_header(skb_mac_header(p),
>
As I said in the commit log, the skb->rxhash should be a very strong
indicator of that flows will match (maybe >99% ?), so putting that
first potentially short circuits a lot of work even in just this
function.

>
>
