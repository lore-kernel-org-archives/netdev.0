From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: behavior of recvmmsg() on blocking sockets
Date: Wed, 24 Mar 2010 11:41:56 -0600
Message-ID: <4BAA4EE4.3090900@nortel.com>
References: <84621a61003240915p2a4ce6bbjd0c6bfb02ab05ba8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Brandon Black <blblack@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <84621a61003240915p2a4ce6bbjd0c6bfb02ab05ba8@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/24/2010 10:15 AM, Brandon Black wrote:
> [Not on the list, please CC responses]

Adding netdev to the CC list.

> Currently, my application code uses blocking UDP sockets and is
> basically structured like this:
> 
> while(1) {
>     recvmsg(fd, ...);
>     // do some work on the packet
>     sendmsg(fd, ...);
> }
> 
> It uses a thread-per-socket model

This doesn't scale well to large numbers of sockets....you get a lot of
unnecessary context switching.


, and the "do some work" code is very
> fast, and so this turns out to be more efficient than non-blocking
> techniques for my use case.  Today I started playing with 2.6.33's new
> recvmmsg(), hoping to convert my code like so (still on blocking
> sockets):
> 
> while(1) {
>     recvmmsg(fd, ...);
>     // do some work on up to N packets
>     // loop over sendmsg() foreach packet to be sent
>     //   (or sendmmsg() if/when that interface becomes available)
> }
> 
> The catch I ran into is that on a blocking socket, recvmmsg() will
> block until *all* vlen packets have been received.  The behavior I'd
> prefer for my use case would be for it to only block until at least
> one packet is available, not until all are available.  Or in code
> terms, the first internal call to recvmsg should use the supplied
> flags, and the rest of the recvmsg calls should use flags &
> MSG_DONTWAIT.  It's not clear to me which is the better default
> behavior, but I feel like at the very least there should be a flag
> that can switch behavior between the two possible interpretations of
> "blocking".

On a sufficiently fast CPU there will always only be 1 packet waiting
but we'll waste a lot of time doing one syscall per packet.

I suspect the intent is that you set the timeout to indicate the max
latency you're willing to accomodate.  Once the timeout expires then the
call will return with the packets received to that point.

Chris
