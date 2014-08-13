From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a
 tasklet from ldc_rx path
Date: Wed, 13 Aug 2014 16:29:07 -0700 (PDT)
Message-ID: <20140813.162907.967701143801775936.davem@davemloft.net>
References: <20140813015817.GA13600@oracle.com>
	<20140812.212513.96441522917129709.davem@davemloft.net>
	<20140813112010.GC16865@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbaHMX3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 19:29:08 -0400
In-Reply-To: <20140813112010.GC16865@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 13 Aug 2014 07:20:10 -0400

> On (08/12/14 21:25), David Miller wrote:
>> 
>> However, don't get ahead of yourself.  All I'm saying in the context
>> of reviewing this patch #3 is that you should leave vnet_tx_timeout()
>> alone and just put what you were putting into vnet_tx_timeout() into
>> maybe_tx_wakeup().
> 
> And just leave vnet_tx_timeout() as before (i.e, "XXX implement me"?)?

Yes, and I see this is what you have done.

> Note that, as I pointed out to Raghuram already, doing ldc_disconnect
> does *not* send any reset events. The code may have other missing
> functionality. 

For the caller of ldc_disconnect() the reset is implied, if this is
what you are talking about.

I don't see any value for generating an event the user of the LDC
channel itself generated.

>> So the question is how to manage this on the driver side, and the most
>> natural way I see do this would be to use multiple TX netdev queues
>> and a custom netdev_ops->ndo_select_queue() method which selects the
>> queue based upon the peer that would be selected.
> 
> This might work well for the current sunvnet model (and even
> there, it has limitations- if all the traffic is going out 
> via the switchport to a gateway, you are again back to the 
> head-of-line blocking model).
> 
> But how generally useful is this model? For point-to-multipoint links
> like ethernet, I dont think you actually track one channel per
> peer.  

I don't understand what your concern could be.

Ethernet is a broadcast medium, so all traffic (as far as the NIC is
concerned) goes via the same single queue.

But here we have independent queues leading up to different
destinations, so representing that as independent queues makes
sense.

This way, if one non-switch peer goes down, all switch based traffic
will still continue to flow, and vice versa.
