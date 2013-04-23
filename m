From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] GRE: Use IS_ERR_OR_NULL in gre_gso_segment
Date: Tue, 23 Apr 2013 13:47:34 -0700
Message-ID: <CAEP_g=93aAXPk+A2u7LzAzEk6Fr33y7HiEMmXBCEkD8+B90kZQ@mail.gmail.com>
References: <1366367073.3205.105.camel@edumazet-glaptop> <20130419.142852.1914290650706288260.davem@davemloft.net>
 <20130422013557.GF15680@verge.net.au> <20130421.214433.1585372696150221161.davem@davemloft.net>
 <20130422021341.GG15680@verge.net.au> <20130423075042.GA25776@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, xeb@mail.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:37733 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755293Ab3DWUrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 16:47:55 -0400
Received: by mail-oa0-f71.google.com with SMTP id o17so6821995oag.2
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 13:47:54 -0700 (PDT)
In-Reply-To: <20130423075042.GA25776@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 12:50 AM, Simon Horman <horms@verge.net.au> wrote:
> [ CC Herbert ]
>
> On Mon, Apr 22, 2013 at 11:13:41AM +0900, Simon Horman wrote:
>> On Sun, Apr 21, 2013 at 09:44:33PM -0400, David Miller wrote:
>> > From: Simon Horman <horms@verge.net.au>
>> > Date: Mon, 22 Apr 2013 10:35:57 +0900
>> >
>> > > On Fri, Apr 19, 2013 at 02:28:52PM -0400, David Miller wrote:
>> > >> From: Eric Dumazet <eric.dumazet@gmail.com>
>> > >> Date: Fri, 19 Apr 2013 03:24:33 -0700
>> > >>
>> > >> > On Fri, 2013-04-19 at 15:48 +0900, Simon Horman wrote:
>> > >> >> Signed-off-by: Simon Horman <horms@verge.net.au>
>> > >> >> ---
>> > >> >>  net/ipv4/gre.c |    2 +-
>> > >> >>  1 file changed, 1 insertion(+), 1 deletion(-)
>> > >> >>
>> > >> >> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
>> > >> >> index d2d5a99..0ae998b 100644
>> > >> >> --- a/net/ipv4/gre.c
>> > >> >> +++ b/net/ipv4/gre.c
>> > >> >> @@ -168,7 +168,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>> > >> >>       /* segment inner packet. */
>> > >> >>       enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
>> > >> >>       segs = skb_mac_gso_segment(skb, enc_features);
>> > >> >> -     if (!segs || IS_ERR(segs))
>> > >> >> +     if (IS_ERR_OR_NULL(segs))
>> > >> >>               goto out;
>> > >> >>
>> > >> >>       skb = segs;
>> > >> >
>> > >> > Hi Simon
>> > >> >
>> > >> > AFAIK I would change things so that NULL is not a possible value.
>> > >> >
>> > >> > I don't really like IS_ERR_OR_NULL() because it hides some lazyness of
>> > >> > ours, and is more expensive (2 tests)
>> > >> >
>> > >> > If we return NULL for an error, why not instead return -Esomething,
>> > >> > since caller is OK to get -ENOMEM,-Exxxxx,... ?
>> > >>
>> > >> Sometimes IS_ERR_OR_NULL is appropriate, but not here, since the caller
>> > >> can more easily just provide good error codes all the time instead of
>> > >> sometimes returning nULL.
>> > >
>> > > I am confused.
>> > >
>> > > I'm not sure that my change actually alters the logic at all.
>> > > Is the suggestion that the logic should be changed somehow?
>> >
>> > We're saying change skb_mac_gso_segment() to never return NULL, and
>> > always an error encoded pointer, rather than change the callers.
>>
>> Thanks, I understand now.
>
> I have looked into this and it seems that the returning
> NULL was introduced by Herbert in 576a30eb6453439b3c37ba24455ac7090c247b5a
> ("Added GSO header verification").
>
> And it seems that only dev_gso_segment() relies on this behaviour.
>
> One option I can think of is to choose an error value to return
> instead of NULL for the case of verifying header integrity.
>
>
> As things stand the following seem suspicious as it seems
> that a NULL value could be dereferenced.
>
> 1. Use of return value of call to __skb_gso_segment() in
>    net/openvswitch/datapath.c:queue_gso_packets().

I don't think this is actually a problem since there is a check for
skb_is_gso() earlier in the code path and no GSO types are supported
in the call to __skb_gso_segment(). However, I can't say that I'm a
big fan of this function possibly returning NULL since it makes it
unnecessarily difficult to reason about.
