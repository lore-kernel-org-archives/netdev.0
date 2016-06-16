From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 1/8] net: Change SKB_GSO_DODGY to be a tx_flag
Date: Thu, 16 Jun 2016 13:33:26 -0700
Message-ID: <CAKgT0Ue0+yj8kBFZc_qDYFzN6=Qi2=TDTZVho94_r4yHXrS6bw@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <1466099522-690741-2-git-send-email-tom@herbertland.com> <CAKgT0Ud-QEtTTdzGzKkxnextMu63RZL9f2Hp=4VGxiUbeMcUkQ@mail.gmail.com>
 <CALx6S35sirk9983WBuVtR0qz=FgDLK-h=hSAGMkgrjH_7oDPWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:33694 "EHLO
	mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbcFPUd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 16:33:28 -0400
Received: by mail-it0-f46.google.com with SMTP id i6so25660291ith.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 13:33:28 -0700 (PDT)
In-Reply-To: <CALx6S35sirk9983WBuVtR0qz=FgDLK-h=hSAGMkgrjH_7oDPWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 1:18 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, Jun 16, 2016 at 11:58 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Thu, Jun 16, 2016 at 10:51 AM, Tom Herbert <tom@herbertland.com> wrote:
>>> This replaces gso_type SKB_GSO_DODGY with a new tx_flag named
>>> SKBTX_UNTRUSTED_SOURCE. This more generically desrcibes the skb
>>> being created from a untrusted source as a characteristic of and skbuff.
>>> This also frees up one gso_type flag bit.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>
>> Instead of leaving this bit in the shared_info why not look at moving
>> it into the sk_buff itself?  It seems like this might be a better
>> candidate for something like that as a large part of what the dodgy
>> bit represents is that the header offsets are likely not set correctly
>> and need to be parsed out and updated.  It might make more sense to
>> place this in the slot just after remcsum_offload.  That way once all
>> the header offsets have been updated you could just update this one
>> bit to indicate that the header offsets stored in this sk_buff are
>> valid.
>>
>> I also don't see where these changes address any changes needed to
>> skb_gso_ok in order to actually trigger the partial walk though the
>> GSO code.  You probably need to look at adding a statement there to do
>> a check for your untrusted source bit versus the GSO_ROBUST feature.
>> It probably doesn't need to be much, just something like tacking on a
>> "&& (!skb_is_untrustued(skb) || (features & NETIF_F_GSO_ROBUST)" to
>> the conditional statement.
>>
> All the places where SKB_GSO_DODGY was being checked should have been
> replaced with SKBTX_UNTRUSTED_SOURCE.

Yes and no.  So net_gso_ok used to be one of those places but you
moved the one bit and dropped the other so is it no longer is being
checked there.

That is why I mentioned looking at adding one additional check for the
untrusted bit and NETIF_F_GSO_ROBUST.  You could probably just tack it
on at the end of the features check at the end of net_gso_ok.

- Alex
