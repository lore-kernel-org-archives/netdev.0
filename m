From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Sun, 27 Mar 2016 22:36:12 -0700
Message-ID: <CAEh+42iqaSg5WNCsc_iJbpxtwi+mjVtH+Wg5WY5HdWF7-5eM1Q@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain> <20160318232522.14955.13475.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:45910 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752140AbcC1Fga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 01:36:30 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 5E382202B8
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 05:36:29 +0000 (UTC)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DC98220272
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 05:36:27 +0000 (UTC)
Received: by mail-qk0-f174.google.com with SMTP id i4so58848809qkc.3
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 22:36:27 -0700 (PDT)
In-Reply-To: <20160318232522.14955.13475.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 4:25 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> diff --git a/net/core/dev.c b/net/core/dev.c
> index edb7179bc051..666cf427898b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2711,6 +2711,19 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
[...]
> +       /* Only report GSO partial support if it will enable us to
> +        * support segmentation on this frame without needing additional
> +        * work.
> +        */
> +       if (features & NETIF_F_GSO_PARTIAL) {
> +               netdev_features_t partial_features;
> +               struct net_device *dev = skb->dev;
> +
> +               partial_features = dev->features & dev->gso_partial_features;
> +               if (!skb_gso_ok(skb, features | partial_features))
> +                       features &= ~NETIF_F_GSO_PARTIAL;

I think we need to add NETIF_F_GSO_ROBUST into the skb_gso_ok() check
- otherwise packets coming from VMs fail this test and we lose GSO
partial. It's totally safe to expose this feature, since we'll compute
gso_segs anyways.

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f044f970f1a6..bdcba77e164c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3281,6 +3291,15 @@ perform_csum_check:
>          */
>         segs->prev = tail;
>
> +       /* Update GSO info on first skb in partial sequence. */
> +       if (partial_segs) {
> +               skb_shinfo(segs)->gso_size = mss / partial_segs;

One small thing: this gso_size is the same as the original MSS, right?
It seems like we could trivially stick it in a local variable and
avoid the extra division.

> +               skb_shinfo(segs)->gso_segs = partial_segs;
> +               skb_shinfo(segs)->gso_type = skb_shinfo(head_skb)->gso_type |
> +                                            SKB_GSO_PARTIAL;

Since we're computing the gso_segs ourselves, it might be nice to
strip out SKB_GSO_DODGY when we set the type.

I just wanted to say that this is really nice work - I was expecting
it to turn out to be really messy and unmaintainable but this is very
clean. Thanks!
