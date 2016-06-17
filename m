From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/8] net: Change SKB_GSO_DODGY to be a tx_flag
Date: Fri, 17 Jun 2016 15:33:15 -0700
Message-ID: <CALx6S37skO4uRbaSaGfjM=PEV9wW-kQrHmpWERmvySpVUXKPZA@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
	<1466099522-690741-2-git-send-email-tom@herbertland.com>
	<CAKgT0Ud-QEtTTdzGzKkxnextMu63RZL9f2Hp=4VGxiUbeMcUkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33696 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbcFQWdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 18:33:16 -0400
Received: by mail-it0-f66.google.com with SMTP id y82so589498itf.0
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 15:33:16 -0700 (PDT)
In-Reply-To: <CAKgT0Ud-QEtTTdzGzKkxnextMu63RZL9f2Hp=4VGxiUbeMcUkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 11:58 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Thu, Jun 16, 2016 at 10:51 AM, Tom Herbert <tom@herbertland.com> wrote:
>> This replaces gso_type SKB_GSO_DODGY with a new tx_flag named
>> SKBTX_UNTRUSTED_SOURCE. This more generically desrcibes the skb
>> being created from a untrusted source as a characteristic of and skbuff.
>> This also frees up one gso_type flag bit.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>
> Instead of leaving this bit in the shared_info why not look at moving
> it into the sk_buff itself?  It seems like this might be a better
> candidate for something like that as a large part of what the dodgy
> bit represents is that the header offsets are likely not set correctly
> and need to be parsed out and updated.  It might make more sense to
> place this in the slot just after remcsum_offload.  That way once all
> the header offsets have been updated you could just update this one
> bit to indicate that the header offsets stored in this sk_buff are
> valid.
>
I don't really understand what the point of SKB_GSO_DODGY is. Seems
like we should be verifying the correct values are set up front in the
vnet, not relying on the core stack to have to worry about this narrow
use case. Fields in the skbuff should be set correctly all the time in
the stack as an invariant I think, if there not correct it is the
fault of the code setting the fields.

> I also don't see where these changes address any changes needed to
> skb_gso_ok in order to actually trigger the partial walk though the
> GSO code.  You probably need to look at adding a statement there to do
> a check for your untrusted source bit versus the GSO_ROBUST feature.
> It probably doesn't need to be much, just something like tacking on a
> "&& (!skb_is_untrustued(skb) || (features & NETIF_F_GSO_ROBUST)" to
> the conditional statement.
>
> - Alex
