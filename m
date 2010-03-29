From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: behavior of recvmmsg() on blocking sockets
Date: Mon, 29 Mar 2010 11:48:22 -0600
Message-ID: <4BB0E7E6.6030304@nortel.com>
References: <84621a61003240915p2a4ce6bbjd0c6bfb02ab05ba8@mail.gmail.com>	 <4BAA4EE4.3090900@nortel.com>	 <84621a61003241128x3afbcea1w387aeaa68c887320@mail.gmail.com>	 <4BAA69BF.3080600@nortel.com>	 <84621a61003241255i74282f53v3bb0111808895401@mail.gmail.com>	 <84621a61003270619p6b4fe81bi24bb1961aba77ffb@mail.gmail.com>	 <4BB0D2CF.9040903@nortel.com> <84621a61003291024r38121763o546e0f09e2d63bc3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Brandon Black <blblack@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <84621a61003291024r38121763o546e0f09e2d63bc3@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/29/2010 11:24 AM, Brandon Black wrote:
> On Mon, Mar 29, 2010 at 11:18 AM, Chris Friesen <cfriesen@nortel.com> wrote:
>>
>> prev = current time
>> loop forever
>>        cur = current time
>>        timeout = max_latency - (cur - prev)
>>        recvmmsg(timeout)
>>        process all received messages
>>        prev = cur
>>
>>
>> Basically you determine the max latency you're willing to wait for a
>> packet to be handled, then subtract the amount of time you spent
>> processing messages from that and pass it into the recvmmsg() call as
>> the timeout.  That way no messages will be delayed for longer than the
>> max latency. (Not considering scheduling delays.)
> 
> With a blocking socket, you'd also need to set SO_RCVTIMEO on the
> underlying socket to some value that makes sense and is below your max
> latency, because recvmmsg()'s timeout argument only applies in-between
> underlying recvmsg() calls, not during them.

Hmm...that's a good point.  For some reason I had been under the
impression that the timeout affected the underlying recvmsg() calls as
well.  It think it would make more sense for the kernel to abort a
blocking recvmsg() call once the timeout expires.

As for spending a lot of time spinning if there are gaps in the input
stream...in the cases where the time-based usage makes sense the normal
situation is that there are a lot of packets coming in.  A 10gig
ethernet pipe can theoretically receive something like 19 packets per
usec.  Doesn't take much of a delay before you probably have packets
waiting.

Chris
