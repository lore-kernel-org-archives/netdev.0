From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: Network driver behaviour when loosing link
Date: Sun, 22 May 2005 02:52:31 +0200
Message-ID: <428FD7CF.3050904@tpack.net>
References: <428F949C.8080707@otaku42.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Renzmann <netdev@nospam.otaku42.de>
In-Reply-To: <428F949C.8080707@otaku42.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Renzmann wrote:
> Hi all.
> 
> I'm playing with a network driver and came across one thing I'd like to 
> ask something about.
> 
> Let's assume a driver detects a link status change (for example, the 
> link is dropped). I would have expected that the driver should signal 
> the change via netif_carrier_on/_off (if used at all) and tell the 
> kernel to stop/resume sending packets to the driver (via 
> netif_wake_queue/netif_stop_queue).
> 
> When checking several drivers I found some that call 
> netif_[wake|stop]_queue (e100, e1000), while others don't (natsemi, tg3).
> 
> Hence the question: what is the recommended behaviour in such a case? Is 

netif_carrier_on/off should certainly be used.

The use of netif_stop_queue depends on your HW:

  A) If your NIC continues taking packets from the ring buffer while link
     is down, then just let it do so.  No need to call netif_stop_queue.
     Since recently, the stack will seize sending packets to your driver
     anyway.  NB: this doesn't happen instantly, but typically within 1 sec.
     after calling netif_carrier_off.

  B) If your NIC stops DMA'ing packets when link is down, you have two
     options:
     1) Check netif_carrier_ok in your hard_start_xmit function.
     2) Call netif_stop_queue when link is lost.
     In both cases you have to flush the NIC's TX ring buffer, in order not
     to hold up resources (and not to send out stale packets when link is
     restored).

> it ok to call netif_[stop|wake]_queue? How about adjusting the 

The queue state is assumed stable when holding dev->xmit_lock, so you can
only call netif_stop_queue/wake_queue when this lock is held.  However,
this requirement doesn't seem do be followed everywhere.  And then there
is the LLTX drivers...

> IFF_RUNNING flag accordingly? Is there any documentation available on 
> this topic?

Drivers shouldn't touch IFF_RUNNING.  It is maintained by the stack.

Documentation?  I haven't really seen any myself, except for the usual:
source code, and mailing-list discussions.  Any pointers are welcome'd.

-Tommy
