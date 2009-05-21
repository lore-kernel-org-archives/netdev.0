From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [RFC] virtio: orphan skbs if we're relying on timer to free them
Date: Thu, 21 May 2009 10:24:31 -0700
Message-ID: <4A158E4F.9070005@chelsio.com>
References: <200905182218.47975.rusty@rustcorp.com.au>	<20090518.194013.109631461.davem@davemloft.net>	<200905211627.05814.rusty@rustcorp.com.au> <20090521.001503.90069315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16667 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbZEUSEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 14:04:36 -0400
In-Reply-To: <20090521.001503.90069315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Thu, 21 May 2009 16:27:05 +0930
> 
>> On Tue, 19 May 2009 12:10:13 pm David Miller wrote:
>>> What you're doing by orphan'ing is creating a situation where a single
>>> UDP socket can loop doing sends and monopolize the TX queue of a
>>> device.  The only control we have over a sender for fairness in
>>> datagram protocols is that send buffer allocation.
>> Urgh, that hadn't even occurred to me.  Good point.
> 
> Now this all is predicated on this actually mattering. :-)
> 
> You could argue that the scheduler as well as the size of the
> TX queue should be limiting and enforcing fairness.
> 
> Someone really needs to test this.  Just skb_orphan() every packet
> at the beginning of dev_hard_start_xmit(), then run some test
> program with two clients looping out UDP packets to see if one
> can monopolize the device and get a significantly larger amount
> of TX resources than the other.  Repeat for 3, 4, 5, etc. clients.

The cxgb3 driver has had skb_orphan in its transmit routine forever (also 
due to lack of Tx interrupts) and I am not aware of adverse effects caused 
by doing so.  It does skip skb_orphan when skb_shared but probably nobody 
sends sharead skbs with destructors.

The only application I know of that has trouble with lazy skb freeing is 
pktgen because it treats freeing as an indication that the packet has been 
transmitted so it's thrown off if packets sit there for a while.  (Also 
freeing just indicates that the DMA is done, not that the packet has been 
sent, and modern devices have quite a bit of buffering.)

> 
>> I haven't thought this through properly, but how about a hack where
>> we don't orphan packets if the ring is over half full?
> 
> That would also work.  And for the NIU case this would be great
> because I DO have a marker bit for triggering interrupts in the TX
> descriptors.  There's just no "all empty" interrupt on TX (who
> designs these things? :( ).
> 
>> Then I guess we could overload the watchdog as a more general
>> timer-after-no- xmit?
> 
> Yes, but it means that teardown of a socket can be delayed up to
> the amount of that timer.  Factor in all of this crazy
> round_jiffies() stuff people do these days and it could cause
> pauses for real use cases and drive users batty.
> 
> Probably the most profitable avenue is to see if this is a real issue
> afterall (see above).  If we can get away with having the socket
> buffer represent socket --> device space only, that's the most ideal
> solution.  It will probably also improve performance a lot across the
> board, especially on NUMA/SMP boxes as our TX complete events tend to
> be in difference places than the SKB producer.

There's a comment in the cxgb3 driver where it calls skb_orphan that 
explains the rationale and includes some of what you're saying.


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

