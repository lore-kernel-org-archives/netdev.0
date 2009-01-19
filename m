From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Mainline kernel OLTP performance update
Date: Mon, 19 Jan 2009 14:19:39 -0800
Message-ID: <4974FC7B.3080404@hp.com>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>	<200901161746.25205.nickpiggin@yahoo.com.au>	<4970CDB6.6040705@hp.com> <200901191843.33490.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, matthew@wil.cx, matthew.r.wilcox@intel.com,
	chinang.ma@intel.com, linux-kernel@vger.kernel.org,
	sharad.c.tripathi@intel.com, arjan@linux.intel.com,
	andi.kleen@intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200901191843.33490.nickpiggin@yahoo.com.au>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>System is a 2socket, 4 core AMD.
>>
>>Not exactly a large system :)  Barely NUMA even with just two sockets.
> 
> 
> You're right ;)
> 
> But at least it is exercising the NUMA paths in the allocator, and
> represents a pretty common size of system...
> 
> I can run some tests on bigger systems at SUSE, but it is not always
> easy to set up "real" meaningful workloads on them or configure
> significant IO for them.

Not sure if I know enough git to pull your trees, or if this cobbler's child will 
have much in the way of bigger systems, but there is a chance I might - contact 
me offline with some pointers on how to pull and build the bits and such.

>>>Netperf UDP unidirectional send test (10 runs, higher better):
>>>
>>>Server and client bound to same CPU
>>>SLAB AVG=60.111 STD=1.59382
>>>SLQB AVG=60.167 STD=0.685347
>>>SLUB AVG=58.277 STD=0.788328
>>>
>>>Server and client bound to same socket, different CPUs
>>>SLAB AVG=85.938 STD=0.875794
>>>SLQB AVG=93.662 STD=2.07434
>>>SLUB AVG=81.983 STD=0.864362
>>>
>>>Server and client bound to different sockets
>>>SLAB AVG=78.801 STD=1.44118
>>>SLQB AVG=78.269 STD=1.10457
>>>SLUB AVG=71.334 STD=1.16809
>>>
>>
>> > ...
>>
>>>I haven't done any non-local network tests. Networking is the one of the
>>>subsystems most heavily dependent on slab performance, so if anybody
>>>cares to run their favourite tests, that would be really helpful.
>>
>>I'm guessing, but then are these Mbit/s figures? Would that be the sending
>>throughput or the receiving throughput?
> 
> 
> Yes, Mbit/s. They were... hmm, sending throughput I think, but each pair
> of numbers seemed to be identical IIRC?

Mega *bits* per second?  And those were 4K sends right?  That seems rather low 
for loopback - I would have expected nearly two orders of magnitude more.  I 
wonder if the intra-stack flow control kicked-in?  You might try adding test 
specific -S and -s options to set much larger socket buffers to try to avoid 
that.  Or simply use TCP.

netperf -H <foo> ... -- -s 1M -S 1M -m 4K

>>I love to see netperf used, but why UDP and loopback?
> 
> 
> No really good reason. I guess I was hoping to keep other variables as
> small as possible. But I guess a real remote test would be a lot more
> realistic as a networking test. Hmm, but I could probably set up a test
> over a simple GbE link here.  I'll try that.

If bandwidth is an issue, that is to say one saturates the link before much of 
anything "interesting" happens in the host you can use something like aggregate 
TCP_RR - ./configure with --enable_burst and then something like

netperf -H <remote> -t TCP_RR -- -D -b 32

and it will have as many as 33 discrete transactions in flight at one time on the 
one connection.  The -D is there to set TCP_NODELAY to preclude TCP chunking the 
single-byte (default, take your pick of a more reasonable size) transactions into 
one segment.

>>Also, how about the service demands?
> 
> 
> Well, over loopback and using CPU binding, I was hoping it wouldn't
> change much... 

Hope... but verify :)

> but I see netperf does some measurements for you. I
> will consider those in future too.
> 
> BTW. is it possible to do parallel netperf tests?

Yes, by (ab)using the confidence intervals code.  Poke around in 
http://www.netperf.org/svn/netperf2/doc/netperf.html in the "Aggregates" section, 
and I can go into further details offline (or here if folks want to see the 
discussion).

rick jones
