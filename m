From: Jeff Garzik <jeff@garzik.org>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 02 Apr 2008 15:06:43 -0400
Message-ID: <47F3D943.5040201@garzik.org>
References: <20080402171104.9591.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<20080402.012406.246863209.davem@davemloft.net>	<1207134299.8514.771.camel@twins> <20080402.114545.17950613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, kosaki.motohiro@jp.fujitsu.com,
	akpm@linux-foundation.org, csnook@redhat.com,
	davej@codemonkey.org.uk, nickpiggin@yahoo.com.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53374 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760524AbYDBTH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 15:07:26 -0400
In-Reply-To: <20080402.114545.17950613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Wed, 02 Apr 2008 13:04:59 +0200
> 
>> Would we not hope that most net drivers can handle {,net}dev_alloc_skb()
>> failing? Otherwise we have some serious trouble.
> 
> False presumption.
> 
> Most can but some legacy ones really do not handle this well.

Correct...

In addition, I remain worried about potential edge cases in drivers that 
do "burst refill" style allocations, rather than the [IMO safer] 
as-you-go style that tg3 employs.

I haven't done a serious audit, but I have nagging doubts about the 
behavior of burst-refill drivers when faced with a burst of failed 
allocations...  do they stop DMA operation, or do they permit hardware 
to wander into part of the DMA ring where, in the previous "cycle" 
through the ring, valid DMA addresses were placed.  But now with a 
string of allocation failures, you have a sequence of DMA ring 
descriptors that point to invalid memory.  If the DMA engine is not 
stopped, or in some other way made to avoid those invalid DMA 
descriptors, then you can easily run into problems.

Sometimes, it's as easy as making sure to properly police the 'OWN' bit 
of each descriptor, something easily and commonly done as a matter of 
course.  But modern hardware with multi-descriptor packets make things 
more complex, so it is actually getting more difficult to get these 
details right.

</ramble>

	Jeff


