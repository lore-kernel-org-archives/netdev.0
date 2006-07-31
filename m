From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Mon, 31 Jul 2006 23:36:29 +0200
Message-ID: <44CE77DD.9030902@trash.net>
References: <44CDDDF7.70004@trash.net>	<20060731113050.GA25972@gondor.apana.org.au>	<44CE4DCA.8000609@trash.net> <20060731.141559.95507027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24011 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030469AbWGaViU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 17:38:20 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060731.141559.95507027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I noticed a subtle semantic change for nf_queue().  Previously, if we
> can't grab the module reference for the matching entry, we'd not free
> the skb, return 0, and the caller tries to iterate to the next hook.
> 
> That behavior is preserved for singleton frames, but that's not what
> happens for GSO frames.  Instead, the GSO frame is split up and we
> always return "1" even if some of the subsegments cause __nf_queue()
> to return 0 due to the case described in the previous paragraph.

I couldn't think of a better way to handle this except to just deliver
everything we can and drop the rest, since the caller doesn't know
anything about the individual segments we can't simply deliver the
remaining ones to the next hook.

> It is, however, mindful to free up the kfree_skb so it doesn't cause a
> leak or anything like that.
> 
> Does this matter?

I don't think it does. Its a huge corner case (unloading of the
module which issued the QUEUE verdict while queueing the packet),
and worst case is that we drop some segments or the entire packet.

