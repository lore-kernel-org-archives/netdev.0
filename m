From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Mon, 28 Mar 2016 09:25:14 -0700
Message-ID: <CAKgT0UezT1YMa6iD2y_qzPVhZL1ChYphnonRpOcdvwhvybHavw@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232522.14955.13475.stgit@localhost.localdomain>
	<CAEh+42iqaSg5WNCsc_iJbpxtwi+mjVtH+Wg5WY5HdWF7-5eM1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37598 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761AbcC1QZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 12:25:16 -0400
Received: by mail-ig0-f173.google.com with SMTP id l20so59715244igf.0
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 09:25:15 -0700 (PDT)
In-Reply-To: <CAEh+42iqaSg5WNCsc_iJbpxtwi+mjVtH+Wg5WY5HdWF7-5eM1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 27, 2016 at 10:36 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Fri, Mar 18, 2016 at 4:25 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index edb7179bc051..666cf427898b 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2711,6 +2711,19 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
> [...]
>> +       /* Only report GSO partial support if it will enable us to
>> +        * support segmentation on this frame without needing additional
>> +        * work.
>> +        */
>> +       if (features & NETIF_F_GSO_PARTIAL) {
>> +               netdev_features_t partial_features;
>> +               struct net_device *dev = skb->dev;
>> +
>> +               partial_features = dev->features & dev->gso_partial_features;
>> +               if (!skb_gso_ok(skb, features | partial_features))
>> +                       features &= ~NETIF_F_GSO_PARTIAL;
>
> I think we need to add NETIF_F_GSO_ROBUST into the skb_gso_ok() check
> - otherwise packets coming from VMs fail this test and we lose GSO
> partial. It's totally safe to expose this feature, since we'll compute
> gso_segs anyways.

Good point.  I will update that before submitting for net-next.

>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index f044f970f1a6..bdcba77e164c 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3281,6 +3291,15 @@ perform_csum_check:
>>          */
>>         segs->prev = tail;
>>
>> +       /* Update GSO info on first skb in partial sequence. */
>> +       if (partial_segs) {
>> +               skb_shinfo(segs)->gso_size = mss / partial_segs;
>
> One small thing: this gso_size is the same as the original MSS, right?
> It seems like we could trivially stick it in a local variable and
> avoid the extra division.

Nice catch.  I was a bit too in the mindset of having to use the same
variable throughout.

>> +               skb_shinfo(segs)->gso_segs = partial_segs;
>> +               skb_shinfo(segs)->gso_type = skb_shinfo(head_skb)->gso_type |
>> +                                            SKB_GSO_PARTIAL;
>
> Since we're computing the gso_segs ourselves, it might be nice to
> strip out SKB_GSO_DODGY when we set the type.

I will have that fixed for the version I submit for net-next.

> I just wanted to say that this is really nice work - I was expecting
> it to turn out to be really messy and unmaintainable but this is very
> clean. Thanks!

Thanks.

- Alex
