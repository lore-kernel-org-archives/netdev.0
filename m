From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 11 Oct 2008 20:13:50 +0200
Message-ID: <1223748830.4598.16.camel@marge.simson.net>
References: <20081009231759.GA8664@tservice.net.ru>
	 <1223633623.4138.86.camel@marge.simson.net>
	 <20081011131352.GA16908@tservice.net.ru>  <1223735947.8485.33.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <s0mbre@tservice.net.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:38255 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1762300AbYJKSOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2008 14:14:03 -0400
In-Reply-To: <1223735947.8485.33.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-10-11 at 16:39 +0200, Peter Zijlstra wrote:

> That said, we can probably still avoid the division for the top level
> stuff, because the sum of the top level weights is still invariant
> between all tasks.

Less math would be nice of course...

> I'll have a stab at doing so... I initially didn't do this because my
> first try gave some real ugly code, but we'll see - these numbers are a
> very convincing reason to try again.

...but the numbers I get on Q6600 don't pin the tail on the math donkey.

Update to UP test log.

2.6.27-final-up
ring-test   - 1.193 us/cycle  = 838 KHz  (gcc-4.3)
tbench      - 337.377 MB/sec           tso/gso on
tbench      - 340.362 MB/sec           tso/gso off
netperf     - 120751.30 rr/s           tso/gso on
netperf     - 121293.48 rr/s           tso/gso off

2.6.27-final-up
patches/revert_weight_and_asym_stuff.diff
ring-test   - 1.133 us/cycle  = 882 KHz  (gcc-4.3)
tbench      - 340.481 MB/sec           tso/gso on
tbench      - 343.472 MB/sec           tso/gso off
netperf     - 119486.14 rr/s           tso/gso on
netperf     - 121035.56 rr/s           tso/gso off

2.6.28-up
ring-test   - 1.149 us/cycle  = 870 KHz  (gcc-4.3)
tbench      - 343.681 MB/sec           tso/gso off
netperf     - 122812.54 rr/s           tso/gso off

My SMP log, updated to account for TSO/GSO monkey-wrench.

(<bleep> truckload of time <bleep> wasted chasing unbisectable
<bleepity-bleep> tso gizmo. <bleep!>)

SMP config, same as UP kernels tested, except SMP.

tbench -t 60 4 localhost followed by four 60 sec netperf
TCP_RR pairs, each pair on it's own core of my Q6600.

2.6.22.19

Throughput 1250.73 MB/sec 4 procs                  1.00

16384  87380  1        1       60.01    111272.55  1.00
16384  87380  1        1       60.00    104689.58
16384  87380  1        1       60.00    110733.05
16384  87380  1        1       60.00    110748.88

2.6.22.19-cfs-v24.1

Throughput 1213.21 MB/sec 4 procs                  .970

16384  87380  1        1       60.01    108569.27  .992
16384  87380  1        1       60.01    108541.04
16384  87380  1        1       60.00    108579.63
16384  87380  1        1       60.01    108519.09

2.6.23.17

Throughput 1200.46 MB/sec 4 procs                  .959

16384  87380  1        1       60.01    95987.66   .866
16384  87380  1        1       60.01    92819.98
16384  87380  1        1       60.01    95454.00
16384  87380  1        1       60.01    94834.84

2.6.23.17-cfs-v24.1

Throughput 1238.68 MB/sec 4 procs                  .990

16384  87380  1        1       60.01    105871.52  .969
16384  87380  1        1       60.01    105813.11
16384  87380  1        1       60.01    106106.31
16384  87380  1        1       60.01    106310.20

2.6.24.7

Throughput 1204 MB/sec 4 procs                     .962

16384  87380  1        1       60.00    99599.27   .910
16384  87380  1        1       60.00    99439.95
16384  87380  1        1       60.00    99556.38
16384  87380  1        1       60.00    99500.45

2.6.25.17

Throughput 1223.16 MB/sec 4 procs                  .977
16384  87380  1        1       60.00    101768.95  .930
16384  87380  1        1       60.00    101888.46
16384  87380  1        1       60.01    101608.21
16384  87380  1        1       60.01    101833.05

2.6.26.5

Throughput 1183.47 MB/sec 4 procs                  .945

16384  87380  1        1       60.00    100837.12  .922
16384  87380  1        1       60.00    101230.12
16384  87380  1        1       60.00    100868.45
16384  87380  1        1       60.00    100491.41

numbers above here are gcc-4.1, below gcc-4.3

2.6.26.6

Throughput 1177.18 MB/sec 4 procs

16384  87380  1        1       60.00    100896.10
16384  87380  1        1       60.00    100028.16
16384  87380  1        1       60.00    101729.44
16384  87380  1        1       60.01    100341.26

TSO/GSO off

2.6.27-final

Throughput 1177.39 MB/sec 4 procs

16384  87380  1        1       60.00    98830.65
16384  87380  1        1       60.00    98722.47
16384  87380  1        1       60.00    98565.17
16384  87380  1        1       60.00    98633.03

2.6.27-final
patches/revert_weight_and_asym_stuff.diff

Throughput 1167.67 MB/sec 4 procs

16384  87380  1        1       60.00    97003.05
16384  87380  1        1       60.00    96758.42
16384  87380  1        1       60.00    96432.01
16384  87380  1        1       60.00    97060.98

2.6.28.git

Throughput 1173.14 MB/sec 4 procs

16384  87380  1        1       60.00    98449.33
16384  87380  1        1       60.00    98484.92
16384  87380  1        1       60.00    98657.98
16384  87380  1        1       60.00    98467.39



