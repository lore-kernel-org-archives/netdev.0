From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] TCP congestion schedulers
Date: Mon, 21 Mar 2005 16:10:36 -0800
Message-ID: <423F627C.2060100@hp.com>
References: <421CF5E5.1060606@ev-en.org>	<20050223135732.39e62c6c.davem@davemloft.net>	<421D1E66.5090301@osdl.org> <421D30FA.1060900@ev-en.org>	<20050225120814.5fa77b13@dxpl.pdx.osdl.net>	<20050309210442.3e9786a6.davem@davemloft.net>	<4230288F.1030202@ev-en.org>	<20050310182629.1eab09ec.davem@davemloft.net>	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>	<20050311201011.360c00da.davem@davemloft.net>	<20050314151726.532af90d@dxpl.pdx.osdl.net> <m13bur5qyo.fsf@muc.de> <Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> On Sat, 19 Mar 2005, Andi Kleen wrote:
> 
> 
>>Stephen Hemminger <shemminger@osdl.org> writes:
>>
>>
>>>Since developers want to experiment with different congestion
>>>control mechanisms, and the kernel is getting bloated with overlapping
>>>data structure and code for multiple algorithms; here is a patch to
>>>split out the Reno, Vegas, Westwood, BIC congestion control stuff
>>>into an infrastructure similar to the I/O schedulers.
>>
>>[...]
>>
>>Did you do any benchmarks to check that wont slow it down?
>>
>>I would recommend to try it on a IA64 machine if possible. In the
>>past we found that adding indirect function calls on IA64 to networking
>>caused measurable slowdowns in macrobenchmarks.
>>In that case it was LSM callbacks, but your code looks like it will
>>add even more.
> 
> 
> Is there a canonical benchmark?

I would put-forth netperf - but then I'm of course biased.  It is reasonably 
straightforward to run, is sophisticated enough to look for interesting things, 
and not so big as some benchmarketing benchmarks that require other software 
besides the stack (eg web servers and whatnot).

If using netperf (not to be confused with Linux versions) versions < 2.4.0 then 
make sure it is compiled with the makefile edited to have -DUSE_PROC_STAT and 
_NOT_ have -DHISTOGRAM or -DINTERVALS.  If using the rc1 of 2.4.0, just typing 
"configure" after unpacking the tar file should suffice under linux, but before 
compiling make sure config.h has a "USE_PROC_STAT" in it.  If it is missing 
USE_PROC_STAT then add a --enable-cpuutil=procstat to the configure step.

Be certain to request CPU utilization numbers with the -c/-C options.  Probably 
best to request confidence intervals. I'd suggest a "128x32" TCP_STREAM test and 
a "1x1" TCP_RR test.  So, something along the lines of:

netperf -H <remote> -i 10,3 -I 99,5 -l 60 -t TCP_STREAM -- -s 128K -S 128K -m 32K

to have netperf reqeust 128KB socket buffers, and pass 32KB in each call to 
send.  Each iteration lasting 60 seconds, and running at least three and no more 
than 10 iterations to get to the point that it is 99% certain ("confident") that 
the reported mean for throughput and CPU util is within +/- 2.5% of the actual 
mean.  You can make that -I 99,2 to be +/- 1% at the risk of having a harder 
time hitting the confidence intervals.  If at first you do not hit the 
confidence intervals you can increase the values in -i up to 30 and/or increase 
the iteration run time with -l.

For the TCP_RR test:

netperf -H <remote> -I 10,3 -I 99,5 -l 60 -t TCP_RR

which will be as above except running a TCP_RR test.  The default in a TCP_RR 
test is to have a single-byte request and a single-byte response.

If you grab 2.4.0rc1 and run on an MP system, it may be good for reproducability 
to use the -T option to pin netperf and/or netserver to specific CPUs.

-T 0 will attempt to bind both netperf and netserver to CPU 0

-T 1,0 will attempt to bind netperf to CPU 1 and netserver to CPU 0

-T 0, will bind netperf to CPU 0 and leave netserver floating

-T ,1 will bind netserver to CPU 1 and leave netperf floating

I would suggest two sitations - netperf/netserver bound to the same CPU as that 
taking interrupts from the NIC, and one where it is not.  How broad the "where 
it is not" case needs/wants to be depends on just how many degrees of "not the 
same CPU" as one hase on the system (thinking NUMA).

netperf bits can be found at:

ftp://ftp.cup.hp.com/dist/networking/benchmarks/netperf/

with the 2.4.0rc1 bits in the experimental/ subdirectory.  There is a Debian 
package floating around somewhere but I cannot recall the revision of netperf on 
which it is based so probably best to grab source bits and compile them.

Interrupt avoidance/coalescing may have a noticable effect on the single-stream 
netperf TCP_RR performance, capping it at a lower transaction per second rating 
no matter the increase in CPU util. So, it is very important to include the CPU 
util measurements.  Similarly, if a system can already max-out a GbE link, just 
looking at Bits per second does not sufice.

For situations where the CPU utilization measurement mechanism is questionable 
(I'm still not sure about the -DUSE_PROC_STAT stuff and interrupt time...any 
comments there most welcome) it may be preferred to run aggregate tests. 
Netperf2 has no explicit synchronization, but if one is content with "stopwatch" 
accuracy, aggregate performance along the lines of:

for i in 1 2 ... N
do
netperf -t TCP_RR -H <remote> -i 30 -L 60 -P 0 -v 0 &
done

may suffice.  The -P 0 stuff disables output of the test headers.  The -v 0 will 
cause just the Single Figure of Merit (SFM) to be displayed - in this case the 
transaction per second rate.  Here the -i 30 is to make each instance of netperf 
run 30 iterations.  The idea being that at least 28 of them will be while the 
other N-1 netperfs are running.  And, hitting the (default -I 99,5) confidence 
interval gives us some confidence that any skew is reasonably close to epsilon.

The idea is to take N high enough to saturate the CPU(s) in the system and peak 
the aggregate transaction rate.  Single-byte is used to avoid pegging the link 
on bits per second.  Since this is "stopwatch" I tend to watch to make sure that 
they all start and end "close" to one another. (NB the combination of -i 30 and 
-l 60 means the test will run for an hour...alter at your discression)

For aggregate tests it is generally best to have three systems - the System 
Under Test (SUT) and a pair or more of LG's - sometimes just using a pair of 
systems saturates before driving the SUT with two or more LGs would.

> Would you really expect a single extra indirect call per ack to have a
> significant performance impact?  This is surprising to me.  Where does the
> cost come from?  Replacing instruction cache lines?

I don't have specific data on hand, but the way the selinux stuff (used?) to be 
implemented did indeed not run very well at all even when selinux was disabled 
(enabled was another story entirely...)

Even if a single extra indirect call is nearly epsilon, the "thousand cuts" 
principle would apply.  Enough of them and the claims about other OSes having 
faster networking may actually become true - if it isn't true already. But I may 
be drifting...

rick jones
