From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] virtio: orphan skbs if we're relying on timer to free
 them
Date: Thu, 21 May 2009 00:15:03 -0700 (PDT)
Message-ID: <20090521.001503.90069315.davem@davemloft.net>
References: <200905182218.47975.rusty@rustcorp.com.au>
	<20090518.194013.109631461.davem@davemloft.net>
	<200905211627.05814.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45865
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751042AbZEUHPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 03:15:06 -0400
In-Reply-To: <200905211627.05814.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 21 May 2009 16:27:05 +0930

> On Tue, 19 May 2009 12:10:13 pm David Miller wrote:
>> What you're doing by orphan'ing is creating a situation where a single
>> UDP socket can loop doing sends and monopolize the TX queue of a
>> device.  The only control we have over a sender for fairness in
>> datagram protocols is that send buffer allocation.
> 
> Urgh, that hadn't even occurred to me.  Good point.

Now this all is predicated on this actually mattering. :-)

You could argue that the scheduler as well as the size of the
TX queue should be limiting and enforcing fairness.

Someone really needs to test this.  Just skb_orphan() every packet
at the beginning of dev_hard_start_xmit(), then run some test
program with two clients looping out UDP packets to see if one
can monopolize the device and get a significantly larger amount
of TX resources than the other.  Repeat for 3, 4, 5, etc. clients.

> I haven't thought this through properly, but how about a hack where
> we don't orphan packets if the ring is over half full?

That would also work.  And for the NIU case this would be great
because I DO have a marker bit for triggering interrupts in the TX
descriptors.  There's just no "all empty" interrupt on TX (who
designs these things? :( ).

> Then I guess we could overload the watchdog as a more general
> timer-after-no- xmit?

Yes, but it means that teardown of a socket can be delayed up to
the amount of that timer.  Factor in all of this crazy
round_jiffies() stuff people do these days and it could cause
pauses for real use cases and drive users batty.

Probably the most profitable avenue is to see if this is a real issue
afterall (see above).  If we can get away with having the socket
buffer represent socket --> device space only, that's the most ideal
solution.  It will probably also improve performance a lot across the
board, especially on NUMA/SMP boxes as our TX complete events tend to
be in difference places than the SKB producer.
