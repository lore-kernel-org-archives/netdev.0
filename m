From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Mon, 13 Apr 2015 20:40:52 +0200
Message-ID: <1428950452.3833058.253180861.49ADF43A@webmail.messagingengine.com>
References: <1428704189-31247-1-git-send-email-fw@strlen.de>
 <20150413.135348.461869719021663434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:57625 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754608AbbDMSkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 14:40:55 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 37B6C20F6F
	for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 14:40:52 -0400 (EDT)
In-Reply-To: <20150413.135348.461869719021663434.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Apr 13, 2015, at 19:53, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sat, 11 Apr 2015 00:16:26 +0200
> 
> > This series alters ipv4 and ipv6 fragmentation to ensure that we do not
> > increase the size of the original fragments when refragmenting.
> > 
> > For IPv4, we only do this when DF bit was set on original fragments since
> > path mtu discovery doesn't happen otherwise.
> 
> What really saddens me is that in my opinion the code was doing the
> right thing prior to commit 6aafeef03b9d ("netfilter: push reasm skb
> through instead of original frag skbs").

This commit aligns IPv6 code with what IPv4 did for years already. I
fear that changing that would lead to semantically backwards
incompatible changes (pushing the original skbs through the netfilter
hooks).

> I would rather we investigate making the previous scheme work
> properly.
> 
> Because then there is no ambiguity at all, you preserve on output
> exactly what you had on input.  The same geometry, the same
> everything.  No special checks, no max frag len, none of this crap.
> Those are all hacks trying to work around the _fundamental_ issue
> which is that we potentially change the thing when we refrag.

netfilter does alter the skbs destructiveley. So the only reason we
could use those unaltered skbs would be to save the lengths of the
individual fragments so we could reapply them to the altered
(constructed by reassembly) one in the output path. This seems much more
complex to me. :/

> The commit in question claims that the "problem" is that if some of
> the sub-frags don't match the same we have problems.  Well that is so
> easy to test for, and if such a test triggers take a slow path.
> 
> Netfilter should not ever change the geometry of a fragmented frame.
> And the only way to do that is to maintain the fraglist of the
> individual fragments through the netfilter stack.
> 
> The end result should be much faster than what we have now too.

In the end netfilter has to deal with fragments where the split is in
the transport layer (like a split directly in the tcp header to confuse
firewalls, fragment offset=1). To do this correctly, I think we have to
always pass in the original skb.

But I actually prefer Jesse's suggestion to set max_frag_size
unconditionally.

Bye,
Hannes
