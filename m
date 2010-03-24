From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: behavior of recvmmsg() on blocking sockets
Date: Wed, 24 Mar 2010 13:36:31 -0600
Message-ID: <4BAA69BF.3080600@nortel.com>
References: <84621a61003240915p2a4ce6bbjd0c6bfb02ab05ba8@mail.gmail.com>	 <4BAA4EE4.3090900@nortel.com> <84621a61003241128x3afbcea1w387aeaa68c887320@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Brandon Black <blblack@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <84621a61003241128x3afbcea1w387aeaa68c887320@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/24/2010 12:28 PM, Brandon Black wrote:
> On Wed, Mar 24, 2010 at 12:41 PM, Chris Friesen <cfriesen@nortel.com> wrote:
>> On 03/24/2010 10:15 AM, Brandon Black wrote:
>>> It uses a thread-per-socket model
>>
>> This doesn't scale well to large numbers of sockets....you get a lot of
>> unnecessary context switching.
> 
> It scales great actually, within my measurement error of linear in
> testing so far.  These are UDP server sockets, and the traffic pattern
> is one request packet maps to one response packet, with no longer-term
> per-client state (this is a DNS server, to be specific).  The "do some
> work" code doesn't have any inter-thread contention (no locks, no
> writes to the same memory, etc), so the "threads" here may as well be
> processes if that makes the discussion less confusing.  I haven't yet
> found a model that scales as well for me.

Note that I said "large numbers of sockets".  Like tens of thousands.
In addition to context switch overhead this can also lead to issues with
memory consumption due to stack frames.

> I'm also just not personally sure whether there are network
> interfaces/drivers out there that could queue packets to the kernel
> (to a single socket) faster than recvmsg() could dequeue them to
> userspace

A 10Gig NIC could do this easily depending on your CPU.

> I still think having a "block until at least one packet arrives" mode
> for recvmmsg() makes sense though.

Agreed, as long as developers are aware that it won't be the most
efficient mode of operation.

Consider the case where you want to do some other useful work in
addition to running your network server.  Every cpu cycle spent on the
network server is robbed from the other work.  In this scenario you want
to handle packets as efficiently as possible, so the timeout-based
behaviour is better since it is more likely to give you multiple packets
per syscall.

Chris
