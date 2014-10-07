From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: sunvnet and ->xmit_more
Date: Tue, 7 Oct 2014 13:38:07 -0700
Message-ID: <9BB04EDE-1842-4DB0-93BE-5186B2D187AB@oracle.com>
References: <20141007.151849.84417269004453869.davem@davemloft.net> <20141007192922.GA31406@oracle.com> <20141007.153829.1919460115976279645.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	david.stevens@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21661 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753917AbaJGUiM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:38:12 -0400
In-Reply-To: <20141007.153829.1919460115976279645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 7, 2014, at 12:38 PM, David Miller <davem@davemloft.net> wrote:

> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Date: Tue, 7 Oct 2014 15:29:22 -0400
> 
>> I'm not sure how this can be useful to sunvnet- in sunvnet's case
>> we send the TX indication at the *start* of a burst, so if xmit_more
>> was set, sure- we can send out another packet immediately, and
>> avoid another START message (which we already do today), but 
>> nothing else to be gained from xmit_more?
> 
> If you defer that __vnet_tx_trigger() call through all the ->xmit_more
> SKBs, then you are less likely to see the DRING_STOPPED event from the
> peer which will make you have to send a START again.
> 
> So, for an xmit_more burst of 3, instead of:
> 
> 	->ndo_start_xmit()
> 		__vnet_tx_trigger()
> 	->ndo_start_xmit()
> IRQ -> vnet_ack() -> STOPPED
> 	->ndo_start_xmit()
> 		__vnet_tx_trigger()
> 
> You would do something like:
> 
> 	->ndo_start_xmit()
> 	->ndo_start_xmit()
> 	->ndo_start_xmit()
> 		__vnet_tx_trigger()

In case of sunvnet,  consumer starting as soon as possible would help
as the consumer is slower as it copies the data to local buffers. The recent
change by DLS avoids the copy in the Tx side, so the producer could be
faster than the receiver.  If the trigger is sent after n packets, then consumer
will really start after n packets in the ring and it may have lost that much time
to pickup the packets.

-Raghuram

> 
>> BTW, I have most of the NAPI done, getting it stress-tested etc
>> (the recent jumbo commit added a few more races between vnet_port_remove
>> and vnet_start_xmit, thanks to the extra clean_timer) but I figure
>> I might as well fully test this internally since net-next is closed
>> for the moment anyway?
> 
> Yeah no rush.
