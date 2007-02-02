From: Rick Jones <rick.jones2@hp.com>
Subject: Re: "meaningful" spinlock contention when bound to non-intr CPU?
Date: Fri, 02 Feb 2007 11:54:14 -0800
Message-ID: <45C396E6.3080705@hp.com>
References: <45C242C9.1010601@hp.com> <p731wl8nz5q.fsf@bingen.suse.de>	<45C3871F.2030301@hp.com> <200702022006.31934.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:57097 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423188AbXBBTyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 14:54:17 -0500
In-Reply-To: <200702022006.31934.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>>The meta question behind all that would seem to be whether the scheduler 
>>should be telling us where to perform the network processing, or should 
>>the network processing be telling the scheduler what to do? (eg all my 
>>old blathering about IPS vs TOPS in HP-UX...)
> 
> 
> That's an unsolved problem.  But past experiments suggest that giving
> the scheduler more imperatives than just "use CPUs well" are often net-losses.

I wasn't thinking about giving the scheduler more imperitives really 
(?), just letting "networking" know more about where threads executed 
accessing given connections. (eg TOPS)

> I suspect it cannot be completely solved in the general case. 

Not unless the NIC can peer into the connection table and see where each 
connection was last accessed by user-space.

>>Well, yes and no.  If I drop the "burst" and instead have N times more 
>>netperf's going, I see the same lock contention situation.  I wasn't 
>>expecting to - thinking that if there were then N different processes on 
>>each CPU the likelihood of there being a contention on any one socket 
>>was low, but it was there just the same.
>>
>>That is part of what makes me wonder if there is a race between wakeup 
> 
> 
> A race?

Perhaps a poor choice of words on my part - something along the lines of:

hold_lock();
wake_up_someone();
release_lock();

where the someone being awoken can try to grab the lock before the path 
doing the waking manages to release it.

> 
> 
>>and release of a lock.
> 
> 
> You could try with echo 1 > /proc/sys/net/ipv4/tcp_low_latency.
> That should change RX locking behaviour significantly.

Running the same 8 netperf's with TCP_RR and burst bound to different 
CPU than the NIC interrupt, the lockmeter output looks virtually 
unchanged.  Still release_sock, tcp_v4_rcv, lock_sock_nested at their 
same offsets.

However, if I run the multiple-connection-per-thread code, and have each 
service 32 concurrent connections, and bind to a CPU other than the 
interrupt CPU, the lock contention in this case does appear to go away.

rick jones
