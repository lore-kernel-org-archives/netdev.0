From: Andi Kleen <ak@muc.de>
Subject: Re: design for TSO performance fix
Date: Fri, 28 Jan 2005 07:25:54 +0100
Message-ID: <m1zmyu2hot.fsf@muc.de>
References: <20050127163146.33b01e95.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050127163146.33b01e95.davem@davemloft.net> (David S.
 Miller's message of "Thu, 27 Jan 2005 16:31:46 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:

> Ok, here is the best idea I've been able to come up with
> so far.
>
> The basic idea is that we stop trying to build TSO frames
> in the actual transmit queue.  Instead, TSO packets are
> built impromptu when we actually output packets on the
> transmit queue.

I don't quite get how it should work.

Currently tcp_sendmsg will always push the first packet when the send_head
is empty way down to hard_queue_xmit, and then queue up some others
and then finally push them out. You would always miss the first
one with that right? (assuming MTU sized packets)

I looked at this some time ago to pass lists of packets
to qdisc and hard_queue_xmit, because that would allow less locking
overhead and allow some drivers to send stuff more efficiently
to the hardware registers
(It was one of the items in my "how to speed up the stack" list ;-) 

I never ended up implementing it because TSO gave most of the advantages
anyways.

> Advantages:
>
> 1) No knowledge of TSO frames need exist anywhere besides
>    tcp_write_xmit(), tcp_transmit_skb(), and
>    tcp_xmit_retransmit_queue()
>
> 2) As a result of #1, all the pcount crap goes away.
>    The need for two MSS state variables (mss_cache,
>    and mss_cache_std) and assosciated complexity is
>    eliminated as well.
>
> 3) Keeping TSO enabled after packet loss "just works".
>
> 4) CWND sampled at the correct moment when deciding
>    the TSO packet arity.
>
> The one disadvantage is that it might be a tiny bit more
> expensive to build TSO frames.  But I am sure we can find
> ways to optimize that quite well.

Without lists of packets through qdiscs etc. it will likely need
a lot more spin locking than it used to be (and spinlocks
tend to be quite expensive). Luckily the high level queuing
you need for this could be used to implement the list of 
packets too (and then finally pass them to hard_queue_xmit
to allow drivers more optimizations) 

-Andi
