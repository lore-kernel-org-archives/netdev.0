From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: sunvnet and ->xmit_more
Date: Tue, 7 Oct 2014 15:29:22 -0400
Message-ID: <20141007192922.GA31406@oracle.com>
References: <20141007.151849.84417269004453869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, david.stevens@oracle.com,
	Raghuram.Kothakota@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26588 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401AbaJGT3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 15:29:31 -0400
Content-Disposition: inline
In-Reply-To: <20141007.151849.84417269004453869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/07/14 15:18), David Miller wrote:
> 
> David and others working on sunvnet, I just wanted to point out that
> in the net-next tree there is a new facility that can improve
> performance quite a bit in sunvnet.
> 
> Basically in the ->ndo_start_xmit() handler, if you see skb->xmit_more
> set then the stack is telling you that it guarentees that another
> packet will be given to you immediately when ->ndo_start_xmit()
> returns.
> 
> This means that, unless you have filled up your TX queue, you can
> defer the TX indication to the device.

I'm not sure how this can be useful to sunvnet- in sunvnet's case
we send the TX indication at the *start* of a burst, so if xmit_more
was set, sure- we can send out another packet immediately, and
avoid another START message (which we already do today), but 
nothing else to be gained from xmit_more?

BTW, I have most of the NAPI done, getting it stress-tested etc
(the recent jumbo commit added a few more races between vnet_port_remove
and vnet_start_xmit, thanks to the extra clean_timer) but I figure
I might as well fully test this internally since net-next is closed
for the moment anyway?

> 
> For example, in the virtio_net driver the test is:
> 
> 	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more)
> 		virtqueue_kick(sq->vq);
> 
> The pktgen module also has a new "burst" parameter you can use to test
> out this facility directly, and the qdisc layer has heuristics for
> dequeueing multiple packets at a time for normal traffic.
> 
> Just FYI...
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
