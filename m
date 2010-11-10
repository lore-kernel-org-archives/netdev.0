From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Wed, 10 Nov 2010 12:24:16 +0100
Message-ID: <1289388256.15004.66.camel@firesoul.comx.local>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <1289311159.17448.9.camel@traveldev.cxnet.dk>
	 <1289312178.17448.20.camel@traveldev.cxnet.dk>
	 <1289313516.17448.28.camel@traveldev.cxnet.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, acme@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:55101 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402Ab0KJLYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 06:24:17 -0500
In-Reply-To: <1289313516.17448.28.camel@traveldev.cxnet.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-09 at 15:38 +0100, Jesper Dangaard Brouer wrote:
> On Tue, 2010-11-09 at 15:16 +0100, Jesper Dangaard Brouer wrote:
> > On Tue, 2010-11-09 at 14:59 +0100, Jesper Dangaard Brouer wrote:
> > > On Mon, 2010-11-08 at 16:06 +0100, Eric Dumazet wrote:
> > > ...
> > 
> > To fix this I added "-q 0" to netcat.  Thus my working commands are:
> > 
> >  netcat -l -p 9999 >/dev/null &
> >  time dd if=/dev/zero bs=1M count=10000 | netcat -q0 127.0.0.1 9999
> > 
> > Running this on my "big" 10G testlab system, Dual Xeon 5550 2.67GHz,
> > kernel version 2.6.32-5-amd64 (which I usually don't use)
> > The results are 7.487 sec
> 
> Using kernel 2.6.35.8-comx01+ (which is 35-stable with some minor
> patches of my own) on the same type of hardware (our preprod server).
> The result is 12 sec.
> 
> time dd if=/dev/zero bs=1M count=10000 | netcat -q0 127.0.0.1 9999
> 10000+0 records in
> 10000+0 records out
> 10485760000 bytes (10 GB) copied, 12,0805 s, 868 MB/s
> 
> real    0m12.082s
> user    0m0.311s
> sys     0m15.896s

On the same system I can better performance IF I pin the processes on
different CPUs. BUT the trick here is I choose CPUs with different "core
id", thus I avoid the HT CPUs in the system (hint look in /proc/cpuinfo
for choosing the CPUs).

Commands:
 taskset 16 netcat -lv -p 9999 >/dev/null &
 time taskset 1 dd if=/dev/zero bs=1M count=10000 | taskset 4 netcat -q0 127.0.0.1 9999

Result:
 10485760000 bytes (10 GB) copied, 8,74021 s, 1,2 GB/s
 real    0m8.742s
 user    0m0.208s
 sys     0m11.426s

So, perhaps the Core i7 has a problem with the HT CPUs with this
workload?

Forcing dd and netcat on the same HT CPU gives a result of approx 18
sec!

Commands:
 taskset 16 netcat -lv -p 9999 >/dev/null
 time taskset 1 dd if=/dev/zero bs=1M count=10000 | taskset 2 netcat -q0 127.0.0.1 9999

Result:
 10485760000 bytes (10 GB) copied, 18,6575 s, 562 MB/s
 real    0m18.659s
 user    0m0.341s
 sys     0m18.969s


> BUT perf top reveals that its probably related to the function
> 'find_busiest_group' ... any kernel config hints how I get rid of that?

The 'find_busiest_group' seems to be an artifact of "perf top", if I use
"perf record" then the 'find_busiest_group' function disappears.  Which
is kind of strange, as 'find_busiest_group' seem the be related to
sched_fair.c.

perf --version
perf version 2.6.35.7.1.g60d9c

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

