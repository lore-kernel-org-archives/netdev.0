From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] mld, igmp: Fix reserved tailroom calculation
Date: Tue, 1 Mar 2016 11:09:53 +0100
Message-ID: <56D56A71.8050400@stressinduktion.org>
References: <56D48DCE.3090705@stressinduktion.org>
 <1456787013-3277-1-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:58568 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752711AbcCAKJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 05:09:56 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 8C19720FE2
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2016 05:09:55 -0500 (EST)
In-Reply-To: <1456787013-3277-1-git-send-email-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.03.2016 00:03, Benjamin Poirier wrote:
> The current reserved_tailroom calculation fails to take hlen and tlen into
> account.
>
> skb:
> [__hlen__|__data____________|__tlen___|__extra__]
> ^                                               ^
> head                                            skb_end_offset
>
> In this representation, hlen + data + tlen is the size passed to alloc_skb.
> "extra" is the extra space made available in __alloc_skb because of
> rounding up by kmalloc. We can reorder the representation like so:
>
> [__hlen__|__data____________|__extra__|__tlen___]
> ^                                               ^
> head                                            skb_end_offset
>
> The maximum space available for ip headers and payload without
> fragmentation is min(mtu, data + extra). Therefore,
> reserved_tailroom
> = data + extra + tlen - min(mtu, data + extra)
> = skb_end_offset - hlen - min(mtu, skb_end_offset - hlen - tlen)
> = skb_tailroom - min(mtu, skb_tailroom - tlen) ; after skb_reserve(hlen)
>
> Compare the second line to the current expression:
> reserved_tailroom = skb_end_offset - min(mtu, skb_end_offset)
> and we can see that hlen and tlen are not taken into account.
>
> The min() in the third line can be expanded into:
> if mtu < skb_tailroom - tlen:
> 	reserved_tailroom = skb_tailroom - mtu
> else:
> 	reserved_tailroom = tlen
>
> Depending on hlen, tlen, mtu and the number of multicast address records,
> the current code may output skbs that have less tailroom than
> dev->needed_tailroom or it may output more skbs than needed because not all
> space available is used.
>
> Fixes: 4c672e4b ("ipv6: mld: fix add_grhead skb_over_panic for devs with large MTUs")
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

I like it, thanks a lot!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
