From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 1 Sep 2016 15:00:10 +0200
Message-ID: <89b605ce-5281-ba41-2921-116bb3073098@redhat.com>
References: <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472650688.32433.115.camel@redhat.com>
 <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831164216.2901190c@redhat.com>
 <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831214043.2f44cf08@redhat.com>
 <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831235116.33b1946b@redhat.com> <20160901130231.58355405@redhat.com>
 <20160901115356.GT10153@twins.programming.kicks-ass.net>
 <20160901142925.63a5031b@redhat.com> <20160901143859.730826ed@redhat.com>
 <1472734643.5019.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472734643.5019.9.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01.09.2016 14:57, Eric Dumazet wrote:
> On Thu, 2016-09-01 at 14:38 +0200, Jesper Dangaard Brouer wrote:
> 
>> Correction, on the server-under-test, I'm actually running RHEL7.2
>>
>>
>>> How do I verify/check if I have enabled a cpu-cgroup?
>>
>> Hannes says I can look in "/proc/self/cgroup"
>>
>>  $ cat /proc/self/cgroup
>>  7:net_cls:/
>>  6:blkio:/
>>  5:devices:/
>>  4:perf_event:/
>>  3:cpu,cpuacct:/
>>  2:cpuset:/
>>  1:name=systemd:/user.slice/user-1000.slice/session-c1.scope
>>  
>> And that "/" indicate I've not enabled cgroups, right?
>>
> 
> In my experience, I found that times displayed by top are often off for
> softirq processing.
> 
> Before applying my patch, top shows very small amount of cpu time for
> udp_rcv and ksoftirqd/0 , while obviously cpu 0 is completely busy.
> 
> Make sure to try latest Linus tree, as I did yesterday, because
> apparently things are better than a few weeks back.
> 
> BTW, even 'perf top' has sometimes problems showing me cycles spent in
> softirq. I need to make sure the cpu processing NIC interrupts also
> spend cycles in some user space program to get meaningful results.

I think that ksoftirqd time is actually accounted to system:

excerpt from irqtime_account_process_tick in kernel/sched/cputime.c

	if (this_cpu_ksoftirqd() == p) {
		/*
		 * ksoftirqd time do not get accounted in cpu_softirq_time.
		 * So, we have to handle it separately here.
		 * Also, p->stime needs to be updated for ksoftirqd.
		 */
		__account_system_time(p, cputime, scaled, CPUTIME_SOFTIRQ);
	} else if (user_tick) {
