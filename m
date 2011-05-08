From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 08 May 2011 16:17:42 +0100
Message-ID: <AB9DE9E04289CF29CA79CC67@Ximines.local>
References: <178E8895FB84C07251538EF7@Ximines.local>
 <1304793174.3207.22.camel@edumazet-laptop>
 <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
 <F57561A93EFF5E88729A8D53@nimrod.local>
 <7B76F9D75FD26D716624004B@nimrod.local>
 <20110508125028.GK2641@linux.vnet.ibm.com>
 <B2891EFD056565BBD4DBCE16@nimrod.local>
 <20110508134425.GL2641@linux.vnet.ibm.com>
 <C449131127D58077CB25C9D8@Ximines.local>
 <20110508144749.GR2641@linux.vnet.ibm.com>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Alex Bligh <alex@alex.org.uk>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:44961 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585Ab1EHPRp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 11:17:45 -0400
In-Reply-To: <20110508144749.GR2641@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul,

>> No, I waited a few minutes after boot for the system to stabilize, and
>> all CPUs were definitely online.
>>
>> The patch to the kernel I am running is below.
>
> OK, interesting...
>
> My guess is that you need to be using ktime_get_ts().  Isn't ktime_get()
> subject to various sorts of adjustment?

It's Eric's code, not mine, but:

kernel/time/timekeeping.c suggests they do the same thing
(adjust xtime by wall_to_monotonic), just one returns a
struct timespec and the other returns a ktime_t.

>> >> There is nothing much going on these systems (idle, no other users,
>> >> just normal system daemons).
>> >
>> > And normal system daemons might cause this, right?
>>
>> Yes. Everything is normal, except I did
>> service udev stop
>> unshare -n bash
>> which together stop the system running interface scripts when
>> interfaces are created (as upstart and upstart-udev-bridge are
>> now integrated, you can't kill upstart, so you have to rely on
>> unshare -n to stop the events being propagated). That's just
>> to avoid measuring the time it takes to execute the scripts.
>
> OK, so you really could be seeing grace periods started by these system
> daemons.

In 50% of 200 calls? That seems pretty unlikely. I think it's more
likely to be the 6 jiffies per call to ensure cpus are idle,
plus the 3 calls per interface destroy.

If 6 jiffies per call to ensure cpus are idle is a fact of life,
then the question goes back to why interface removal is waiting
for rcu readers to be released synchronously, as opposed to
doing the update bits synchronously, then doing the reclaim
element (freeing the memory) afterwards using call_rcu.

-- 
Alex Bligh
