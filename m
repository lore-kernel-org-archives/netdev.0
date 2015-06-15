From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: fix search limit handling in skb_find_text()
Date: Mon, 15 Jun 2015 19:06:39 +0200
Message-ID: <20150615170639.GA21117@salvia>
References: <1434359518-16897-1-git-send-email-khimov@altell.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, roman@khimov.ru,
	Phil Oester <kernel@linuxace.com>, Thomas Graf <tgraf@suug.ch>
To: Roman I Khimov <khimov@altell.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53261 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbbFORBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 13:01:34 -0400
Content-Disposition: inline
In-Reply-To: <1434359518-16897-1-git-send-email-khimov@altell.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc'ing Thomas.

On Mon, Jun 15, 2015 at 12:11:58PM +0300, Roman I Khimov wrote:
> Suppose that we're trying to use an xt_string netfilter module to match a
> string in a specially crafted packet that has "a nice string" starting at
> offset 28.
> 
> It could be done in iptables like this:
> 
> -A some_chain -m string --string "a nice string" --algo bm --from 28 --to 38 -j DROP
> 
> And it would work as expected. Now changing that to
> 
> -A some_chain -m string --string "a nice string" --algo bm --from 29 --to 38 -j DROP
> 
> breaks the match, as expected. But, if we try to make
> 
> -A some_chain -m string --string "a nice string" --algo bm --from 20 --to 28 -j DROP
>
> then it suddenly works again! So the 'to' parameter seems to be inclusive, not
> working as an offset after which no search should be done. OK, now if we try:
> 
> -A some_chain -m string --string "a nice string" --algo bm --from 28 --to 28 -j DROP

Can you reproduce the same behaviour with the km algo?

> it doesn't work. So, for the case of equal 'from' and 'to' it's treated in a
> different way.
>
> The first behaviour (matching at 'to' offset) comes from skb_find_text()
> comparison. The second one (not matching if 'from' and 'to' are equal) comes
> from skb_seq_read() check for (abs_offset >= st->upper_offset).
> 
> I think that the way skb_find_text() handles 'to' is wrong and should be fixed
> so that we always have predictable behaviour -- only match before 'to' offset.
>
> There are currently only five usages of skb_find_text() in the kernel and it
> looks to me that none of them expect to match something at the 'to' offset,
> so probably this change is safe.

So both 'from' and 'to' are inclusive which seems consistent to me. If
you make 'to' non-inclusive, then that will change the third example
above, right? That will break existing setups for people that are
relying on this behaviour. This has been exposed in this way for long
time, so we should avoid that breakage.

I would suggest you fix the --from X --to Y where X == Y which is not
doing what people would expect.
