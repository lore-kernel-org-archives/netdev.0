From: Rick Jones <rick.jones2@hp.com>
Subject: Re: "meaningful" spinlock contention when bound to non-intr CPU?
Date: Fri, 02 Feb 2007 10:46:55 -0800
Message-ID: <45C3871F.2030301@hp.com>
References: <45C242C9.1010601@hp.com> <p731wl8nz5q.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:57016 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946026AbXBBSq4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 13:46:56 -0500
In-Reply-To: <p731wl8nz5q.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Rick Jones <rick.jones2@hp.com> writes:
> 
>>Still, does this look like something worth persuing?  In a past
>>life/OS when one was able to eliminate one percentage point of
>>spinlock contention, two percentage points of improvement ensued.
> 
> 
> The stack is really designed to go fast with per CPU local RX processing 
> of packets. This normally works because waking on up a task 
> the scheduler tries to move it to that CPU. Since the wakeups are
> on the CPU that process the incoming packets it should usually
> end up correctly.
> 
> The trouble is when your NICs are so fast that a single
> CPU can't keep up, or when you have programs that process many
> different sockets from a single thread.
> 
> The fast NIC case will be eventually fixed by adding proper
> support for MSI-X and connection hashing. Then the NIC can fan 
> out to multiple interrupts and use multiple CPUs to process
> the incoming packets. 

If that is implemented "well" (for some definition of well) then it 
might address the many sockets from a thread issue too, but if not...

If it is simple "hash on the headers" then you still have issues with a 
process/thread servicing mutiple connections - the hash of the different 
  headers will take things up different CPUs and you induce the 
scheduler to flip the process back and forth between them.

The meta question behind all that would seem to be whether the scheduler 
should be telling us where to perform the network processing, or should 
the network processing be telling the scheduler what to do? (eg all my 
old blathering about IPS vs TOPS in HP-UX...)

> Then there is the case of a single process having many 
> sockets from different NICs This will be of course somewhat slower
> because there will be cross CPU traffic. 

The extreme case I see with the netperf test suggests it will be a 
pretty big hit.  Dragging cachelines from CPU to CPU is evil.  Sometimes 
a necessary evil of course, but still evil.

> However there should
> be not much socket lock contention because a process handling
> many sockets will be hopefully unlikely to bang on each of
> its many sockets at the exactly same time as the stack
> receives RX packets. This should also eliminate the spinlock
> contenion.
> 
> From that theory your test sounds somewhat unrealistic to me. 
> 
> Do you have any evidence you're modelling a real world scenario
> here? I somehow doubt it.

Well, yes and no.  If I drop the "burst" and instead have N times more 
netperf's going, I see the same lock contention situation.  I wasn't 
expecting to - thinking that if there were then N different processes on 
each CPU the likelihood of there being a contention on any one socket 
was low, but it was there just the same.

That is part of what makes me wonder if there is a race between wakeup 
and release of a lock.


rick
