From: Brandon Black <blblack@gmail.com>
Subject: Re: behavior of recvmmsg() on blocking sockets
Date: Wed, 24 Mar 2010 13:28:46 -0500
Message-ID: <84621a61003241128x3afbcea1w387aeaa68c887320@mail.gmail.com>
References: <84621a61003240915p2a4ce6bbjd0c6bfb02ab05ba8@mail.gmail.com>
	 <4BAA4EE4.3090900@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BAA4EE4.3090900@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 24, 2010 at 12:41 PM, Chris Friesen <cfriesen@nortel.com> w=
rote:
> On 03/24/2010 10:15 AM, Brandon Black wrote:
>> It uses a thread-per-socket model
>
> This doesn't scale well to large numbers of sockets....you get a lot =
of
> unnecessary context switching.

It scales great actually, within my measurement error of linear in
testing so far.  These are UDP server sockets, and the traffic pattern
is one request packet maps to one response packet, with no longer-term
per-client state (this is a DNS server, to be specific).  The "do some
work" code doesn't have any inter-thread contention (no locks, no
writes to the same memory, etc), so the "threads" here may as well be
processes if that makes the discussion less confusing.  I haven't yet
found a model that scales as well for me.

> On a sufficiently fast CPU there will always only be 1 packet waiting
> but we'll waste a lot of time doing one syscall per packet.

Based on loopback interface testing, when the socket is saturated with
packet throughput (one CPU core is locked up handling one socket), the
"do some work" code accounts for an average of roughly 10-20% of the
cpu time per request right now on a fairly fast Xeon, the rest is
spent in recvmsg()/sendmsg().  One potential way for things to "get
behind" would be that the time spent in my user code isn't a constant:
some requests will be processed slower than others.  If a particular
request is unusually slow for some reason (and there are potential
reasons) and 2+ packets backlog while handling it, recvmmsg() allows
me to catch up faster.

I'm also just not personally sure whether there are network
interfaces/drivers out there that could queue packets to the kernel
(to a single socket) faster than recvmsg() could dequeue them to
userspace, which is another reason recvmmsg() would make sense for
this.  Maybe that's not even possible, I have no idea.  But for the
moment, I've been operating on the assumption that if it's not
possible now, it likely will be possible at some point in the future.

> I suspect the intent is that you set the timeout to indicate the max
> latency you're willing to accomodate. =C2=A0Once the timeout expires =
then the
> call will return with the packets received to that point.

Yes, I agree that's another option I have here, to use the timeout to
set a small but acceptable latency window for gathering multiple
packets.  That timeout value wouldn't have a universally right value
though, so I'd probably have to pass it off to the user as a config
option and let them tune it.  Assuming no change is made to
recvmmsg(), this is probably the route I'll test and benchmark (versus
just sticking with plain recvmsg()).

I still think having a "block until at least one packet arrives" mode
for recvmmsg() makes sense though.

Thanks for the input,
-- Brandon
