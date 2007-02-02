From: Andi Kleen <ak@suse.de>
Subject: Re: "meaningful" spinlock contention when bound to non-intr CPU?
Date: 02 Feb 2007 20:21:37 +0100
Message-ID: <p731wl8nz5q.fsf@bingen.suse.de>
References: <45C242C9.1010601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39410 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946010AbXBBSVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 13:21:05 -0500
In-Reply-To: <45C242C9.1010601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> writes:
> 
> Still, does this look like something worth persuing?  In a past
> life/OS when one was able to eliminate one percentage point of
> spinlock contention, two percentage points of improvement ensued.

The stack is really designed to go fast with per CPU local RX processing 
of packets. This normally works because waking on up a task 
the scheduler tries to move it to that CPU. Since the wakeups are
on the CPU that process the incoming packets it should usually
end up correctly.

The trouble is when your NICs are so fast that a single
CPU can't keep up, or when you have programs that process many
different sockets from a single thread.

The fast NIC case will be eventually fixed by adding proper
support for MSI-X and connection hashing. Then the NIC can fan 
out to multiple interrupts and use multiple CPUs to process
the incoming packets. 

Then there is the case of a single process having many 
sockets from different NICs This will be of course somewhat slower
because there will be cross CPU traffic. However there should
be not much socket lock contention because a process handling
many sockets will be hopefully unlikely to bang on each of
its many sockets at the exactly same time as the stack
receives RX packets. This should also eliminate the spinlock
contenion.

>From that theory your test sounds somewhat unrealistic to me. 

Do you have any evidence you're modelling a real world scenario
here? I somehow doubt it.

-Andi 
