From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Mon, 13 Apr 2015 22:33:06 +0200
Message-ID: <1428957186.3857244.253240553.6718F0F7@webmail.messagingengine.com>
References: <1428704189-31247-1-git-send-email-fw@strlen.de>
 <20150413.135348.461869719021663434.davem@davemloft.net>
 <1428950452.3833058.253180861.49ADF43A@webmail.messagingengine.com>
 <20150413.161638.1169173491693514924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56584 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754949AbbDMUdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 16:33:07 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 00BA620F46
	for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 16:33:06 -0400 (EDT)
In-Reply-To: <20150413.161638.1169173491693514924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Apr 13, 2015, at 22:16, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 13 Apr 2015 20:40:52 +0200
> 
> > netfilter does alter the skbs destructiveley. So the only reason we
> > could use those unaltered skbs would be to save the lengths of the
> > individual fragments so we could reapply them to the altered
> > (constructed by reassembly) one in the output path. This seems much more
> > complex to me. :/
> 
> It could process the individual fragments one by one then.  Then
> at the end you could see what the final verdicts look like.

This exactly sounds like the reassembly engine we have now.

Consider we have a split in the TCP header, so we definitely have to
keep this skb in the input path as we got the final segments. We could
try to teach netfilter instead of just using tcp_hdr to be aware of that
the header could not be fully reassembled and peek into the next skb,
but this really seems to complex just to me. After that we have the
netfilter connection tracking helpers which suddenly need to handle all
those packets, too.

Before "netfilter: push reasm skb through instead of original frag skbs"
we simply dropped packets where the necessary header was not available,
which also was just a very seldom situation but this is still a
correctness issue.

> What happens right now is so damn expensive, has the geometry
> issue, and is totally unnecessary %99.99999 of the time.

Yes, totally.

The reason we try to pursue this way is that we found no way to actually
build something completely transparent, the state we would need to carry
around is just to immense. Consider fragmentation duplicates and such. I
think, the only think to worry about is correct PMTU behavior here, and
this patchset tries to keep this intact all the time.

> I therefore think there is massive value in trying to make it work to
> keep the original frags around as a group and try to process them that
> way.

I also do think that fragmented traffic is not a common traffic pattern
we should optimize for.

Thanks,
Hannes
