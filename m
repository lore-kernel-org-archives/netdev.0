From: David Miller <davem@davemloft.net>
Subject: Re: sunvnet and ->xmit_more
Date: Tue, 07 Oct 2014 15:38:29 -0400 (EDT)
Message-ID: <20141007.153829.1919460115976279645.davem@davemloft.net>
References: <20141007.151849.84417269004453869.davem@davemloft.net>
	<20141007192922.GA31406@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.stevens@oracle.com,
	Raghuram.Kothakota@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193AbaJGTib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 15:38:31 -0400
In-Reply-To: <20141007192922.GA31406@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 7 Oct 2014 15:29:22 -0400

> I'm not sure how this can be useful to sunvnet- in sunvnet's case
> we send the TX indication at the *start* of a burst, so if xmit_more
> was set, sure- we can send out another packet immediately, and
> avoid another START message (which we already do today), but 
> nothing else to be gained from xmit_more?

If you defer that __vnet_tx_trigger() call through all the ->xmit_more
SKBs, then you are less likely to see the DRING_STOPPED event from the
peer which will make you have to send a START again.

So, for an xmit_more burst of 3, instead of:

	->ndo_start_xmit()
		__vnet_tx_trigger()
	->ndo_start_xmit()
IRQ -> vnet_ack() -> STOPPED
	->ndo_start_xmit()
		__vnet_tx_trigger()

You would do something like:

	->ndo_start_xmit()
	->ndo_start_xmit()
	->ndo_start_xmit()
		__vnet_tx_trigger()

> BTW, I have most of the NAPI done, getting it stress-tested etc
> (the recent jumbo commit added a few more races between vnet_port_remove
> and vnet_start_xmit, thanks to the extra clean_timer) but I figure
> I might as well fully test this internally since net-next is closed
> for the moment anyway?

Yeah no rush.
