From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Mon, 13 Apr 2015 13:53:48 -0400 (EDT)
Message-ID: <20150413.135348.461869719021663434.davem@davemloft.net>
References: <1428704189-31247-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbbDMRxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:53:49 -0400
In-Reply-To: <1428704189-31247-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 11 Apr 2015 00:16:26 +0200

> This series alters ipv4 and ipv6 fragmentation to ensure that we do not
> increase the size of the original fragments when refragmenting.
> 
> For IPv4, we only do this when DF bit was set on original fragments since
> path mtu discovery doesn't happen otherwise.

What really saddens me is that in my opinion the code was doing the
right thing prior to commit 6aafeef03b9d ("netfilter: push reasm skb
through instead of original frag skbs").

I would rather we investigate making the previous scheme work
properly.

Because then there is no ambiguity at all, you preserve on output
exactly what you had on input.  The same geometry, the same
everything.  No special checks, no max frag len, none of this crap.
Those are all hacks trying to work around the _fundamental_ issue
which is that we potentially change the thing when we refrag.

The commit in question claims that the "problem" is that if some of
the sub-frags don't match the same we have problems.  Well that is so
easy to test for, and if such a test triggers take a slow path.

Netfilter should not ever change the geometry of a fragmented frame.
And the only way to do that is to maintain the fraglist of the
individual fragments through the netfilter stack.

The end result should be much faster than what we have now too.
