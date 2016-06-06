From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH 09/12] net: mediatek: increase watchdog_timeo
Date: Mon, 6 Jun 2016 14:38:43 +0200
Message-ID: <5d1b3fe3-4577-207a-3e28-831218158144@phrozen.org>
References: <1465108385-38286-1-git-send-email-john@phrozen.org>
 <1465108385-38286-10-git-send-email-john@phrozen.org>
 <20160605145632.GI12165@lunn.ch>
 <0da64a49-d100-f83d-e6d3-91b706710660@phrozen.org>
 <20160606122132.GM12165@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@nbd.name>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160606122132.GM12165@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 06/06/2016 14:21, Andrew Lunn wrote:
>> Hi Andrew,
>>
>> it is waiting for the watchdog to trigger :-) TBH the 1s seems to be too
>> short to for the dma ring length to be flushed and i had to pick some
>> value and 5 is used most places.
>>
>> it really depends on the amount of packets in the queue, their length
>> and the mac setting. the timeout needs to be large enough that it would
>> not trigger incorrectly even if the mac is on 10mbit half duplex and all
>> frames in the queue were maximum size.
> 
> So you are saying there is 5 seconds worth of traffic in the transmit ring.
> 
> As a general point, not specific to this driver, is that wise? Isn't
> that really bad buffer bloat?
> 
> I just wondered what happened to cause it to have 5 seconds worth of
> traffic in the transmit ring. Did downstream signal a pause?  But i
> thought the byte queue limit was designed to prevent a big backlog in
> the transmit queue? At 10/Half, is it not reacting fast enough?  Since
> it is half duplex, do you have a lot of traffic coming the other way
> and something is not being fair at distributing up and down traffic?
> 
> I'm just wondering if by increasing the watchdog to 5 seconds, you are
> just hiding a problem.
> 
>     Andrew

Hi Andrew,

running the driver without any QoS and using the typical ringsize for
gigabit devices, 1s is not enough. we were seeing false positive
watchdog events. then i grepped to see what other drivers do and most
set 5seconds. ideally the watchdog never triggers as the driver is
functional an does not suffer from deadlocks.

at gbit ethernet can transmit 83 packets that are 1500 bytes long /
second, if there are no pause gaps. at 10Mbit that would be 6 packets.

so assuming we have a ring of 128 and napi set to 64, we would want at
least 2 seconds, 3 if there are a lot of pause gaps, 4-5 if it is half
duplex ... so i took the value commonly used, which is 5 according to grep.

figuring out when the queue is stuck seems to be a little bit more
complicated. imho the trigger should not be based on how long it took to
send a packet, but how long since the last packet was dequeued from dma.

personally i'd rather fix the deadlocks that can happen, which is what
we did, than rely on the watchdog to reset the queue. right now we can
hammer the driver with several streams on both macs utilizing all 4 cpu
cores for several days without seeing any hickups.

		John
