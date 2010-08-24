From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Tue, 24 Aug 2010 00:31:43 -0400
Message-ID: <20100824003143.243eb046.billfink@mindspring.com>
References: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:51744 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751362Ab0HXEbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 00:31:45 -0400
In-Reply-To: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Aug 2010, Tom Herbert wrote:

> This patch implements transmit packet steering (XPS) for multiqueue
> devices.  XPS selects a transmit queue during packet transmission based
> on configuration.  This is done by mapping the CPU transmitting the
> packet to a queue.  This is the transmit side analogue to RPS-- where
> RPS is selecting a CPU based on receive queue, XPS selects a queue
> based on the CPU (previously there was an XPS patch from Eric
> Dumazet, but that might more appropriately be called transmit completion
> steering).
> 
> Each transmit queue can be associated with a number of CPUs which will
> used the queue to send packets.  This is configured as a CPU mask on a
> per queue basis in:
> 
> /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus
> 
> The mappings are stored per device in an inverted data structure that
> maps CPUs to queues.  In the netdevice structure this is an array of
> num_possible_cpu structures where each array entry contains a bit map
> of queues which that CPU can use.
> 
> We also allow the mapping of a socket to queue to be modified, for
> instance if a thread is scheduled on a different CPU the desired queue
> for transmitting packets would likely change.  To maintain in order
> packet transmission a flag (ooo_okay) has been added to the sk_buf
> structure.  If a transport layer sets this flag on a packet, the
> transmit queue can be changed for this socket.  Presumably, the
> transport would set this is there was no possbility of creating ooo
> packets (for instance there are no packets in flight for the socket).
> This patch includes the modification in TCP output for setting this
> flag.
> 
> The benefits of XPS are improved locality in the per queue data
> strutures.  Also, transmit completions are more likely to be done
> nearer to the sending thread so this should promote locality back 
> to the socket (e.g. UDP).  The benefits of XPS are dependent on
> cache hierarchy, application load, and other factors.  XPS would
> nominally be configured so that a queue would only be shared by CPUs
> which are sharing a cache, the degenerative configuration woud be that
> each CPU has it's own queue.
> 
> Below are some benchmark results which show the potential benfit of
> this patch.  The netperf test has 500 instances of netperf TCP_RR test
> with 1 byte req. and resp.
> 
> bnx2x on 16 core AMD
>    XPS (16 queues, 1 TX queue per CPU)	1015K at 99% CPU
>    No XPS (16 queues)			1127K at 98% CPU

I don't grok your performance numbers.  What do the 1015K and 1127K
numbers represent?  I was originally guessing that they were basically
transactions per second, but that would seem to imply that the No XPS
case was better.  Please clarify.

						-Thanks

						-Bill
