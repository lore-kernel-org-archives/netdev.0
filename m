From: bert hubert <bert.hubert@netherlabs.nl>
Subject: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 17:27:14 +0100
Message-ID: <20070220162714.GA3245@outpost.ds9a.nl>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:32902 "EHLO outpost.ds9a.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030220AbXBTQ1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:27:20 -0500
Content-Disposition: inline
In-Reply-To: <p73d545drx6.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 11:50:13AM +0100, Andi Kleen wrote:
> P4s are pretty slow at taking locks (or rather doing atomical operations)
> and there are several of them in this path. You could try it with a UP
> kernel. Actually hotunplugging the other virtual CPU should be sufficient 
> with recent kernels.

This is on a UP kernel, on a single CPU. It does have hyperthreading, but
the kernel is uniprocessor, non-preempt. No frequency scaling. Linux
2.6.20-rc4, 2.6.19, 2.6.18, P4, P-M, Athlon 64. Ubunty Edgy Eft on the P4.

> Also BTW RDTSC on P4 is not very accurate for small measurements
> because it has a quite high overhead by itself, i would suggest
> running it in a loop.

I've done so, with some interesting results. Source on
http://ds9a.nl/tmp/recvtimings.c - be careful to adjust the '3000' divider
to your CPU frequency if you care about absolute numbers!

These are two groups, each consisting of 10 consecutive nonblocking UDP
recvfroms, with 10 packets preloaded. Reported is the number of microseconds
per recvfrom call which yielded a packet:

$ ./recvtimings
4.142333
2.237667
1.927333
1.580000
1.770000
1.632333
1.712667
1.685000
1.620000
2.415000
1.347333
1.545000
1.492667
1.902333
1.485000
1.532667
1.460000
1.517667
1.492333
1.580000

This in a nearly quiet P4 - I've removed the first line:
$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0      0 290064 307036 296036    0    0     0     0  124   58  0  0 100  0
 0  0      0 289972 307036 296036    0    0     0     4  139   95  0  0 100  0
 0  0      0 289972 307036 296036    0    0     0     0  119   55  0  0 100  0
 1  0      0 289972 307036 296036    0    0     0     0  135   71  0  0 100  0

HZ is clearly 100. If I usleep in between, timings for each recvfrom call
become higher. If I sleep for a full second, I get nearly flat results:
4.250000
5.317667
3.525000
4.147333
3.360000
3.552667
3.087667

Various differing CPUs report more or less the same results. Now I know we
have caching effects, but these effects are HUGE.

Is this supposed to be the case? I'm on an up to date system, glibc 2.4.

	Bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
