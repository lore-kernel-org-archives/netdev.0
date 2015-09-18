From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: ip6_fragment: fix headroom tests and skb leak
Date: Thu, 17 Sep 2015 21:36:41 -0700 (PDT)
Message-ID: <20150917.213641.103324145037364919.davem@davemloft.net>
References: <1442417174-6229-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dwmw2@infradead.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbIREgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 00:36:41 -0400
In-Reply-To: <1442417174-6229-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 16 Sep 2015 17:26:14 +0200

> David Woodhouse reports skb_under_panic when we try to push ethernet
> header to fragmented ipv6 skbs:
> 
>  skbuff: skb_under_panic: text:c1277f1e len:1294 put:14 head:dec98000
>  data:dec97ffc tail:0xdec9850a end:0xdec98f40 dev:br-lan
> [..]
> ip6_finish_output2+0x196/0x4da
> 
> David further debugged this:
>   [..] offending fragments were arriving here with skb_headroom(skb)==10.
>   Which is reasonable, being the Solos ADSL card's header of 8 bytes
>   followed by 2 bytes of PPP frame type.
> 
> The problem is that if netfilter ipv6 defragmentation is used, skb_cow()
> in ip6_forward will only see reassembled skb.
> 
> Therefore, headroom is overestimated by 8 bytes (we pulled fragment
> header) and we don't check the skbs in the frag_list either.
> 
> We can't do these checks in netfilter defrag since outdev isn't known yet.
> 
> Furthermore, existing tests in ip6_fragment did not consider the fragment
> or ipv6 header size when checking headroom of the fraglist skbs.
> 
> While at it, also fix a skb leak on memory allocation -- ip6_fragment
> must consume the skb.
> 
> I tested this e1000 driver hacked to not allocate additional headroom
> (we end up in slowpath, since LL_RESERVED_SPACE is 16).
> 
> If 2 bytes of headroom are allocated, fastpath is taken (14 byte
> ethernet header was pulled, so 16 byte headroom available in all
> fragments).
> 
> Reported-by: David Woodhouse <dwmw2@infradead.org>
> Diagnosed-by: David Woodhouse <dwmw2@infradead.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
