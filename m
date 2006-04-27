From: Robin Humble <rjh@cita.utoronto.ca>
Subject: Re: [RFC] e1000 performance patch
Date: Wed, 26 Apr 2006 22:43:26 -0400
Message-ID: <20060427024326.GA6318@lemming.cita.utoronto.ca>
References: <20060426221353.GA22143@lemming.cita.utoronto.ca> <444FF389.2090002@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from quail.cita.utoronto.ca ([128.100.76.6]:6344 "EHLO
	quail.cita.utoronto.ca") by vger.kernel.org with ESMTP
	id S964898AbWD0CoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 22:44:05 -0400
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <444FF389.2090002@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Rick,

thanks for your comments.

On Wed, Apr 26, 2006 at 03:26:17PM -0700, Rick Jones wrote:
>Robin Humble wrote:
>>attached is a small patch for e1000 that dynamically changes Interrupt
>>Throttle Rate for best performance - both latency and bandwidth.
>>it makes e1000 look really good on netpipe with a ~28 us latency and
>>890 Mbit/s bandwidth.
>>
>>the basic idea is that high InterruptThrottleRate (~200k) is best for
>>small messages, 
>Best for small numbers of small messages?  If one is looking to have 
>high aggregate small packet rates, the higher throttle rate may degrade 
>the peak PPS one can achieve.

if small is <1kB, and there's a single client, then it looks to me like
the higher ITR the better.
for a single netpipe client (running 10k repetitions and from 0 byte to
1kB messages), the driver chooses 200k ITR until it gets close to 1kB
messages, when it drops to its next level of 90k ITR. about 15-20% cpu
is used.

<short delay whilst I run some tests>

for 3 netpipe clients (again running 10k repetitions and from 0 byte to
1kB messages, all with the patched e1000 driver), the server is at 200k
ITR until the 3 clients get to ~96 bytes, then it drops to 90k ITR, and
at ~512 byte messages it drops the ITR once more to 30k.

so I think the patched driver is doing the right thing there and
lowering the ITR more rapidly as it gets more clients.

but clearly I should be using netperf to get more accurate cpu numbers
and a more convincing aggregate table :-)

>It is a bit rough/messy as a writeup, but here is what I've seen wrt the 
>latency vs throughput tradeoffs:
>ftp://ftp.cup.hp.com/dist/networking/briefs/nic_latency_vs_tput.txt

from a quick read it looks like just the case with 32kB messages,
multiple simultaneous clients, and driver set to unlimited ITR sees
reduced throughput. is that right?

if so, then I'm not surprised.
this graph
  http://www.cita.utoronto.ca/mediawiki/index.php/Image:Cpu.100k.png
shows that (for our hardware etc. etc.) at 32kB the cpu usage if one
was using 100k ITR is already excessive, and unlimited ITR would be
worse than that... :-/
so for 32kB messages and a single client (never mind multiple clients)
I'd agree with your study that unlimited ITR is probably not a good
idea.

with a single client doing 32kB messages, my patched driver is probably
doing the right thing as it's at 30k ITR (and at its minimum ITR of
15k with multiple clients doing 32kB messages).

>> uint32_t goc = max(adapter->gotcl, adapter->gorcl) / 1000000;
>> uint32_t itr = goc > 10 ? (goc > 20 ? (goc > 100 ? 15000: 30000): 90000): 200000;

Hmmmm... I've just noticed that the gotcl/gorcl count is >200M on the
server when 3 clients are doing 32kB netpipes... so I can probably use
goc of > 150 or 200 as a threshold to switch to a lower ITR again.
maybe 3k or 6k...


but overall I'm actually more worried about a mix of small and large
messages than multiple clients.

a large/small mix might well occur in 'the real world' and it'll be 2s
until the watchdog routine can adapt the ITR. potentially that 2s will
be at 200k ITR which is too high for large messages, and up to 2s of
cpu will be burnt needlessly.

can netperf (or some other tool) mix up big and small message sizes
like 'the real world' perhaps does?
that might help me find a good frequency at which to try to adapt the
ITR... (eg. 1, 10, 100 or 1000 times a second)

cheers,
robin
