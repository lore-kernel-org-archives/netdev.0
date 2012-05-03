From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Thu, 03 May 2012 00:08:55 -0700
Message-ID: <4FA22F07.6060306@gmail.com>
References: <4FA21087.1080801@gmail.com>	<1336022373.12425.24.camel@edumazet-glaptop>	<4FA21A90.3010008@gmail.com> <20120503.015018.1396745597972676005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:61646 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754526Ab2ECHJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 03:09:05 -0400
Received: by dady13 with SMTP id y13so1208459dad.5
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 00:09:05 -0700 (PDT)
In-Reply-To: <20120503.015018.1396745597972676005.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2012 10:50 PM, David Miller wrote:
> From: Alexander Duyck<alexander.duyck@gmail.com>
> Date: Wed, 02 May 2012 22:41:36 -0700
>
>> I think the part that has me confused is how being more precise about
>> removing from truesize gets in the way of detecting abuses of
>> truesize.  It seems like it should be more as good as or better then
>> the original approach of just using skb->len.
> You can only trim from truesize if you can be absolutely certain that
> you have removed any reference in the fraglist, or the page'd head, to
> the entire "block" of data.
>
> If the skb still refers to even just one byte in a particular block,
> we must still charge the entire block in the truesize.
I get that, and that is what my code was doing that the old code wasn't 
doing.  That is why I am confused.  I should have another patch ready in 
an hour or so that should help to make my position clear.

> For example, NIU has three pools of power-of-2 blocks of data it
> maintainers and the device pulls from to build incoming packets.
>
> So if the chip used one of the 2048 byte buffers, we charge the entire
> 2048 bytes even of the packet is much smaller.
>
> Conversely this means we cannot trim the 2048 part of the truesize of
> that SKB unless we had some mechanism to know for certain 1) what the
> block size of the underlying data is and 2) that we've removed all
> references to that.
>
> Currently this is not really possible, so we therefore defer truesize
> adjustments.
This is true for the frags, but not for the head buffer allocated with 
__alloc_skb or build_skb.  For either of these we set both truesize and 
the end pointer offset based on the ksize(data).  The truesize is the 
value plus SKB_DATA_ALIGNED(sizeof(struct sk_buff)), and the end pointer 
offset is the value minus SKB_DATA_ALIGNED(sizeof(struct 
skb_shared_info)).  So in the case where we are removing the sk_buff and 
skb->head, I am subtracting the end pointer offset plus the aligned 
shared info and sk_buff values from skb->truesize to get the size of 
just the paged region.

> Behaving otherwise is dangerous, because then we'd potentially end up
> with a lot of memory used, but not actually accounted for by anyone.
I fully agree that is why I was surprised when I was told not to use the 
values for skb->truesize that were computed back when we allocated the 
skb to determine the truesize to remove from the delta when we were 
removing it.

Thanks,

Alex
