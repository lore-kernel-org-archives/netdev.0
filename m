From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 08 May 2011 13:18:55 +0100
Message-ID: <7B76F9D75FD26D716624004B@nimrod.local>
References: <891B02256A0667292521A4BF@Ximines.local>	
 <1304770926.2821.1157.camel@edumazet-laptop>	
 <0F4A638C2A523577CDBC295E@Ximines.local>	
 <1304785589.3207.5.camel@edumazet-laptop>	
 <178E8895FB84C07251538EF7@Ximines.local>	
 <1304793174.3207.22.camel@edumazet-laptop>	
 <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
 <F57561A93EFF5E88729A8D53@nimrod.local>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Alex Bligh <alex@alex.org.uk>
To: Alex Bligh <alex@alex.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:32790 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559Ab1EHMTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 08:19:01 -0400
In-Reply-To: <F57561A93EFF5E88729A8D53@nimrod.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 8 May 2011 10:35:02 +0100 Alex Bligh <alex@alex.org.uk> wrote:

> I suspect this may just mean an rcu reader holds the rcu_read_lock
> for a jiffies related time. Though I'm having difficulty seeing
> what that might be on a system where the net is in essence idle.

Having read the RCU docs, this can't be right, because blocking
is not legal when in the rcu_read_lock critical section.

The system concerned is an 8 cpu system but I get comparable
results on a 2 cpu system.

I am guessing that when the synchronize_sched() happens, all cores
but the cpu on which that is executing are idle (at least on
the vast majority of calls) as the machine itself is idle.
As I understand, RCU synchronization (in the absence of lots
of callbacks etc.) is meant to wait until it knows all RCU
read critical sections which are running on entry have
been left. It exploits the fact that RCU read critical sections
cannot block by waiting for a context switch on each cpu, OR
for that cpu to be in the idle state or running user code (also
incompatible with a read critical section).

The fact that increasing HZ masks the problem seems to imply that
sychronize_sched() is waiting when it shouldn't be, as it suggests
it's waiting for a context switch. But surely it shouldn't be
waiting for context switch if all other cpu cores are idle?
It knows that it (the caller) doesn't hold an rcu_read_lock,
and presumably can see the other cpus are in the idle state,
in which case surely it should return immediately? Distribution
of latency in synchronize_sched() looks like this:

 20-49 us 110 instances (27.500%)
 50-99 us 45 instances (11.250%)
 5000-9999 us 5 instances (1.250%)
 10000-19999 us 33 instances (8.250%)
 20000-49999 us 4 instances (1.000%)
 50000-99999 us 191 instances (47.750%)
 100000-199999 us 12 instances (3.000%)

-- 
Alex Bligh
